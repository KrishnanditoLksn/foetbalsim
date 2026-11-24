import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/domain/enums/inbox.dart';
import 'package:futbol/domain/enums/transfer.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/season_models.dart';
import 'package:futbol/domain/transfer/transfer_window.dart';

const _ourClub = 'real-madrid';

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  late AppDatabase db;
  late GameEngine engine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final world = WorldGenerator.generate(seedJson: seedJson, seed: 99);
    await WorldRepository(db).saveWorld(
      world,
      GameState(
        currentDate: WorldGenerator.seasonStart,
        managerName: 'Tester',
        clubId: _ourClub,
        seed: 99,
      ),
    );
    engine = GameEngine(db);
    await engine.ensureSeasonInitialized();
  });

  tearDown(() async => db.close());

  String choiceFor(InboxMessage m) => switch (m.actionType) {
    InboxActionType.acceptTarget => 'accept',
    InboxActionType.contractDecision => 'leave',
    InboxActionType.incomingTransferOffer => 'reject',
    InboxActionType.contractNegotiation => 'cancel',
    InboxActionType.counterOffer => 'cancel',
    InboxActionType.none => '',
  };

  /// Menjalankan CONTINUE / laga tim sendiri sampai [until] terpenuhi.
  /// Aksi inbox biasa diselesaikan dengan pilihan default.
  Future<GameStatus> autoPlay(
    bool Function(GameStatus s) until, {
    int max = 800,
  }) async {
    for (var i = 0; i < max; i++) {
      final s = await engine.status();
      if (until(s)) return s;
      if (s.pendingActions.isNotEmpty) {
        final m = s.pendingActions.first;
        if (m.actionType == InboxActionType.contractNegotiation) {
          throw StateError('negosiasi tidak diharapkan di sini');
        }
        await engine.resolveMessage(m, choiceFor(m));
        continue;
      }
      if (s.todayFixture != null) {
        await engine.playMatchDay();
        continue;
      }
      if (s.seasonOver) break;
      await engine.continueGame(maxDays: 1);
    }
    return engine.status();
  }

  int minWageOf(InboxMessage m) {
    for (final part in m.payload!.split('|')) {
      if (part.startsWith('min:')) return int.parse(part.substring(4));
    }
    throw StateError('payload tanpa min');
  }

  /// Harga minta untuk klub kita saat tawaran diajukan (yang ditampilkan di
  /// UI), termasuk premi rival lokal. Ditambah 1% sebagai ruang untuk
  /// perubahan harga harian sampai tanggal respons.
  Future<int> bidFee(Player p) async {
    final ask = (await engine.transferQuote(p.id)).askingFee;
    return (ask * 1.01).round();
  }

  /// Menyelesaikan sambutan dewan (aksi pertama di awal karier).
  Future<void> resolveWelcome() async {
    final s = await engine.status();
    for (final m in s.pendingActions) {
      await engine.resolveMessage(m, choiceFor(m));
    }
  }

  test('tawaran diterima, negosiasi disetujui, pemain pindah klub', () async {
    await resolveWelcome();

    // Pemain Barcelona yang akan ditawar.
    final target = (await PlayerRepository(db).squad('barcelona')).first;
    final fee = await bidFee(target);
    await engine.placeBid(target.id, fee);

    final s = await autoPlay(
      (s) => s.pendingActions.any(
        (m) => m.actionType == InboxActionType.contractNegotiation,
      ),
    );
    final nego = s.pendingActions.firstWhere(
      (m) => m.actionType == InboxActionType.contractNegotiation,
    );
    final wage = minWageOf(nego);
    await engine.resolveMessage(nego, 'wage:$wage|years:3');

    final moved = await PlayerRepository(db).byId(target.id);
    expect(moved!.clubId, _ourClub);

    final history = await TransferRepository(db).history();
    final record = history.firstWhere((r) => r.playerId == target.id);
    expect(record.fee, fee);
    expect(record.toClubId, _ourClub);
    expect(record.type, TransferType.buy);

    final offers = await TransferRepository(db).offersFor(_ourClub);
    final offer = offers.firstWhere((o) => o.playerId == target.id);
    expect(offer.status, TransferOfferStatus.completed);
  });

  test('gaji di bawah ekspektasi pemain membuat negosiasi gagal', () async {
    await resolveWelcome();
    final target = (await PlayerRepository(db).squad('barcelona')).first;
    await engine.placeBid(target.id, await bidFee(target));

    final s = await autoPlay(
      (s) => s.pendingActions.any(
        (m) => m.actionType == InboxActionType.contractNegotiation,
      ),
    );
    final nego = s.pendingActions.firstWhere(
      (m) => m.actionType == InboxActionType.contractNegotiation,
    );
    await engine.resolveMessage(nego, 'wage:1|years:3');

    final stillThere = await PlayerRepository(db).byId(target.id);
    expect(stillThere!.clubId, 'barcelona');
    final offers = await TransferRepository(db).offersFor(_ourClub);
    final offer = offers.firstWhere((o) => o.playerId == target.id);
    expect(offer.status, TransferOfferStatus.failed);
  });

  test('tawaran ditolak di luar jendela transfer', () async {
    await resolveWelcome();
    // Majukan sampai bursa musim panas tutup (setelah 31 Agustus).
    await autoPlay((s) => s.date.isAfter(DateTime.utc(2026, 8, 31)));
    final status = await engine.status();
    expect(TransferWindow.isOpen(status.date), isFalse);

    final target = (await PlayerRepository(db).squad('barcelona')).first;
    expect(
      () => engine.placeBid(target.id, 1000),
      throwsStateError,
    );
  });

  test('pemain daftar jual memicu tawaran masuk dan bisa dijual', () async {
    await resolveWelcome();
    final ours = (await PlayerRepository(db).squad(_ourClub)).first;
    await engine.setListed(ours.id, true);

    final s = await autoPlay(
      (s) => s.pendingActions.any(
        (m) => m.actionType == InboxActionType.incomingTransferOffer,
      ),
    );
    final offerMsg = s.pendingActions.firstWhere(
      (m) => m.actionType == InboxActionType.incomingTransferOffer,
    );
    await engine.resolveMessage(offerMsg, 'accept');

    final after = await PlayerRepository(db).byId(ours.id);
    expect(after!.clubId, isNot(_ourClub));
    expect(after.isTransferListed, isFalse);

    final history = await TransferRepository(db).history();
    final sale = history.firstWhere((r) => r.playerId == ours.id);
    expect(sale.type, TransferType.sell);
    expect(sale.fromClubId, _ourClub);
  });
}
