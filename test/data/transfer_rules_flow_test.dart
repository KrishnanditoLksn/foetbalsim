import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/club_repository.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/data/services/transfer_service.dart';
import 'package:futbol/domain/enums/inbox.dart';
import 'package:futbol/domain/enums/squad_status.dart';
import 'package:futbol/domain/enums/transfer.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/transfer_models.dart';
import 'package:futbol/domain/transfer/transfer_rules.dart';
import 'package:futbol/domain/transfer/valuation.dart';

/// Ketentuan transfer README_FASE3 (B.5, B.9, B.10.7) dari sisi user.
const _us = 'real-madrid';
const _seller = 'getafe'; // bukan rival, reputasi lebih rendah dari kita

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final start = WorldGenerator.seasonStart;
  late AppDatabase db;
  late GameEngine engine;
  late TransferService svc;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final world = WorldGenerator.generate(seedJson: seedJson, seed: 99);
    await WorldRepository(db).saveWorld(
      world,
      GameState(currentDate: start, managerName: 'T', clubId: _us, seed: 99),
    );
    engine = GameEngine(db);
    await engine.ensureSeasonInitialized();
    svc = TransferService(db);
  });

  tearDown(() async => db.close());

  DateTime day(int n) => start.add(Duration(days: n));

  /// Pemain rotasi/cadangan dari klub penjual (bukan pemain inti, agar aturan
  /// "pemain inti tanpa pengganti" tidak ikut berlaku), bernilai minimal
  /// €3 jt supaya ada ruang di antara kontra dan tawaran final.
  Future<Player> target() async {
    final players = PlayerRepository(db);
    final squad = await players.squad(_seller);
    final candidates = <Player>[];
    for (final p in squad) {
      final status = (await players.detail(p.id))?.contract?.squadStatus;
      if (status == SquadStatus.rotation || status == SquadStatus.backup) {
        candidates.add(p);
      }
    }
    candidates.sort((a, b) => a.marketValue.compareTo(b.marketValue));
    return candidates.firstWhere(
      (p) => p.marketValue >= 3000,
      orElse: () => candidates.last,
    );
  }

  Future<int> askFor(Player p) async =>
      (await svc.quote(playerId: p.id, ourClubId: _us, now: start, seed: 99))
          .askingFee;

  Future<TransferOffer> offerOf(Player p) async =>
      (await TransferRepository(db).offersFor(_us)).firstWhere(
        (o) => o.playerId == p.id,
      );

  Future<Club> club(String id) async => (await ClubRepository(db).clubById(id))!;

  Future<void> bid(Player p, int fee, {int years = 1, int sellOn = 0}) =>
      svc.placeBid(
        ourClubId: _us,
        now: start,
        playerId: p.id,
        fee: fee,
        seed: 99,
        installmentYears: years,
        sellOnPct: sellOn,
      );

  Future<void> resolveOn(int n) =>
      svc.resolveDueBids(date: day(n), ourClubId: _us, seed: 99);

  test('syarat tawaran divalidasi: cicilan, sell-on, anggaran, jendela', () async {
    final p = await target();
    final ask = await askFor(p);
    expect(() => bid(p, ask, years: 4), throwsStateError);
    expect(() => bid(p, ask, sellOn: 5), throwsStateError);
    final budget = (await club(_us)).transferBudget;
    expect(() => bid(p, budget + 1000), throwsStateError);
    await expectLater(
      svc.placeBid(
        ourClubId: _us,
        now: DateTime.utc(2025, 10, 1),
        playerId: p.id,
        fee: ask,
        seed: 99,
      ),
      throwsStateError,
    );
  });

  test('3 ronde: kontra → tawaran final diterima → kontrak → pemain pindah', () async {
    final p = await target();
    final ask = await askFor(p);
    await bid(p, (ask * 0.85).round());

    await resolveOn(2);
    var offer = await offerOf(p);
    expect(offer.status, TransferOfferStatus.countered);
    expect(offer.round, 2);
    expect(offer.fee, greaterThan((ask * 0.85).round()));
    final counterMsg = (await engine.inbox()).firstWhere(
      (m) => m.actionType == InboxActionType.counterOffer && !m.resolved,
    );

    // Dijawab lewat engine (jalur tab Negosiasi): pesan inbox ikut selesai.
    final finalFee = TransferRules.finalMinimum(offer.fee);
    expect(finalFee, lessThan(offer.fee));
    await engine.respondToOffer(offer.id, 'final:$finalFee');
    offer = await offerOf(p);
    expect(offer.status, TransferOfferStatus.pending);
    expect(offer.round, TransferRules.maxRounds);
    final after = (await engine.inbox()).firstWhere((m) => m.id == counterMsg.id);
    expect(after.resolved, isTrue);

    await resolveOn(4);
    offer = await offerOf(p);
    expect(offer.status, TransferOfferStatus.awaitingContract);

    final wage = DynamicValuation.expectedWage(p);
    await engine.respondToOffer(offer.id, 'wage:$wage|years:3');
    expect((await offerOf(p)).status, TransferOfferStatus.completed);
    expect((await PlayerRepository(db).byId(p.id))!.clubId, _us);
  });

  test('tawaran final di bawah 97% dari kontra ditolak dengan alasan', () async {
    final p = await target();
    final ask = await askFor(p);
    await bid(p, (ask * 0.85).round());
    await resolveOn(2);
    final offer = await offerOf(p);
    await engine.respondToOffer(offer.id, 'final:${(offer.fee * 0.90).round()}');
    await resolveOn(4);
    final done = await offerOf(p);
    expect(done.status, TransferOfferStatus.rejected);
    expect(done.reason, isNotNull);
    expect(done.isActive, isFalse);
  });

  test('tawaran < 70% ditolak, dicatat sebagai lowball, harga awal naik', () async {
    final p = await target();
    final ask = await askFor(p);
    await bid(p, (ask * 0.5).round());
    await resolveOn(2);
    final offer = await offerOf(p);
    expect(offer.status, TransferOfferStatus.rejected);
    expect(offer.reason, 'Tawaran terlalu rendah.');
    expect(await TransferRepository(db).memory('lowballCount'), 1);
    expect(await askFor(p), greaterThan(ask));
  });

  test('kontra-tawaran dihitung sebagai negosiasi aktif (tidak bisa tawar dobel)', () async {
    final p = await target();
    final ask = await askFor(p);
    await bid(p, (ask * 0.85).round());
    await resolveOn(2);
    expect((await offerOf(p)).status, TransferOfferStatus.countered);
    expect(() => bid(p, ask), throwsStateError);
  });

  test('cicilan 2 tahun: di muka sekarang, sisanya tiap 1 Juli', () async {
    final p = await target();
    final ask = await askFor(p);
    final fee = (ask * 1.1 / 10).round() * 10;
    final usBefore = await club(_us);
    final sellerBefore = await club(_seller);

    await bid(p, fee, years: 2);
    await resolveOn(2);
    final offer = await offerOf(p);
    expect(offer.status, TransferOfferStatus.awaitingContract);
    await engine.respondToOffer(
      offer.id,
      'wage:${DynamicValuation.expectedWage(p)}|years:3',
    );

    final upfront = TransferRules.upfront(fee, 2);
    final usAfter = await club(_us);
    expect(usAfter.balance, usBefore.balance - upfront);
    expect(usAfter.transferBudget, usBefore.transferBudget - fee);
    expect((await club(_seller)).balance, sellerBefore.balance + upfront);

    await svc.payDueInstallments(DateTime.utc(start.year + 1, 7, 1));
    expect((await club(_us)).balance, usBefore.balance - fee);
    expect((await club(_seller)).balance, sellerBefore.balance + fee);
    expect(await TransferRepository(db).memoryWithPrefix('inst|'), isEmpty);
  });

  test('sell-on clause: klub asal mendapat bagian saat pemain dijual lagi', () async {
    final p = await target();
    final ask = await askFor(p);
    await bid(p, (ask * 1.01).round(), sellOn: 20);
    await resolveOn(2);
    final offer = await offerOf(p);
    await engine.respondToOffer(
      offer.id,
      'wage:${DynamicValuation.expectedWage(p)}|years:3',
    );
    expect((await PlayerRepository(db).byId(p.id))!.clubId, _us);

    final sellerBefore = await club(_seller);
    final usBefore = await club(_us);
    final moved = (await PlayerRepository(db).byId(p.id))!;
    await svc.completeTransfer(
      player: moved,
      buyerId: 'sevilla',
      sellerId: _us,
      fee: 10000,
      wage: 500,
      years: 2,
      date: DateTime.utc(start.year + 1, 1, 10),
      type: TransferType.sell,
    );
    expect((await club(_seller)).balance, sellerBefore.balance + 2000);
    expect((await club(_us)).balance, usBefore.balance + 10000 - 2000);
  });

  test('maks 6 pemain masuk per jendela', () async {
    final repo = TransferRepository(db);
    for (var i = 0; i < TransferRules.maxMovesPerWindow; i++) {
      await repo.addHistory(
        TransferRecord(
          id: 0,
          date: start,
          playerId: 900000 + i,
          playerName: 'Dummy $i',
          fromClubId: _seller,
          toClubId: _us,
          fee: 1000,
          type: TransferType.buy,
        ),
      );
    }
    final p = await target();
    final q = await svc.quote(playerId: p.id, ourClubId: _us, now: start, seed: 99);
    expect(q.blockedReason, contains('per jendela'));
    expect(() => bid(p, q.askingFee), throwsStateError);
  });

  test('transfer antar-rival lokal dikenai premi harga +30%', () async {
    final p = (await PlayerRepository(db).squad('barcelona')).first;
    final detail = await PlayerRepository(db).detail(p.id);
    final base = await svc.askingFor(
      player: p,
      contract: detail?.contract,
      now: start,
      seed: 99,
      forUser: true,
    );
    final q = await svc.quote(playerId: p.id, ourClubId: _us, now: start, seed: 99);
    expect(q.isRival, isTrue);
    expect(q.askingFee, closeTo(base * TransferRules.rivalPremium, 10));
  });
}
