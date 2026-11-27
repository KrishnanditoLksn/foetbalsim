import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/inbox_repository.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/data/services/legacy_inbox_upgrade.dart';
import 'package:futbol/domain/enums/inbox.dart';
import 'package:futbol/domain/enums/transfer.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/season_models.dart';
import 'package:futbol/domain/models/transfer_models.dart';
import 'package:futbol/domain/models/transfer_news_payload.dart';
import 'package:futbol/l10n/l10n.dart';

/// Save lama: pesan Inbox berupa teks Indonesia mentah tanpa rincian
/// transfer. Saat save dibuka, pesan diubah agar ikut bahasa aplikasi dan
/// berita transfer mendapat kartu detail.
void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final start = WorldGenerator.seasonStart;
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final world = WorldGenerator.generate(seedJson: seedJson, seed: 5);
    await WorldRepository(db).saveWorld(
      world,
      GameState(
        currentDate: start,
        managerName: 'Lama',
        clubId: 'barcelona',
        seed: 5,
      ),
    );
    await GameEngine(db).ensureSeasonInitialized();
  });
  tearDown(() => db.close());

  Future<void> legacy(String title, String body, {String? payload}) =>
      InboxRepository(db).add(
        InboxMessage(
          id: 0,
          date: start,
          category: InboxCategory.transfer,
          title: title,
          body: body,
          isRead: false,
          actionType: InboxActionType.none,
          payload: payload,
          resolved: false,
          choice: null,
        ),
      );

  test('teks lama diterjemahkan dan berita transfer dilengkapi', () async {
    final moved = (await PlayerRepository(db).squad('getafe')).first;
    final offered = (await PlayerRepository(db).squad('sevilla')).first;
    await TransferRepository(db).addHistory(
      TransferRecord(
        id: 0,
        date: start,
        playerId: moved.id,
        playerName: moved.fullName,
        fromClubId: 'getafe',
        toClubId: 'girona',
        fee: 373,
        type: TransferType.aiDeal,
      ),
    );
    await legacy(
      'Transfer selesai: ${moved.fullName}',
      '${moved.fullName} pindah dari Getafe ke Girona dengan €373 rb.',
    );
    await legacy(
      'Tawaran pemain: ${offered.fullName}',
      'Sevilla menawarkan ${offered.fullName} (DC, 28 th) seharga €5.3 jt. '
          'Cari pemain ini di Cari Pemain untuk menawar.',
      payload: 'player:${offered.id}',
    );
    await legacy('Catatan bebas', 'Teks yang tidak dikenali.');

    final changed = await LegacyInboxUpgrade(db).run();
    expect(changed, 2);
    expect(await LegacyInboxUpgrade(db).run(), 0, reason: 'idempoten');

    final all = await InboxRepository(db).all();
    InboxMessage byPlayer(Player p) =>
        all.firstWhere((m) => trText(m.title).contains(p.fullName));

    L10n.current = AppLanguage.en;
    addTearDown(() => L10n.current = AppLanguage.id);

    final done = byPlayer(moved);
    expect(trText(done.title), 'Transfer completed: ${moved.fullName}');
    expect(
      trText(done.body),
      '${moved.fullName} moves from Getafe to Girona for €373K.',
    );
    final doneNews = TransferNewsPayload.tryParse(done.payload)!;
    expect(doneNews.status, TransferNewsStatus.completed);
    expect(doneNews.fromClubId, 'getafe');
    expect(doneNews.toClubId, 'girona');
    expect(doneNews.fee, 373);
    expect(doneNews.transferType, TransferType.aiDeal);

    final offer = byPlayer(offered);
    expect(trText(offer.title), 'Player offered: ${offered.fullName}');
    expect(offer.payload, startsWith('player:${offered.id}|tx:'));
    final offerNews = TransferNewsPayload.tryParse(offer.payload)!;
    expect(offerNews.status, TransferNewsStatus.offered);
    expect(offerNews.fromClubId, 'sevilla');
    expect(offerNews.toClubId, 'barcelona');
    expect(offerNews.fee, 5300);

    // Teks yang tidak dikenali dibiarkan, tanpa error.
    final free = all.firstWhere((m) => m.title == 'Catatan bebas');
    expect(free.payload, isNull);
  });
}
