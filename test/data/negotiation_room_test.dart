import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/club_repository.dart';
import 'package:futbol/data/repositories/inbox_repository.dart';
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
import 'package:futbol/domain/models/season_models.dart';
import 'package:futbol/domain/transfer/agent_negotiator.dart';

/// Ruang Negosiasi dari sisi layanan (README_NEGOTIATION_ROOM F).
const _us = 'real-madrid';
const _seller = 'getafe';

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final start = WorldGenerator.seasonStart;
  late AppDatabase db;
  late GameEngine engine;
  late TransferService svc;
  late TransferRepository repo;

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
    repo = TransferRepository(db);
  });

  tearDown(() async => db.close());

  DateTime day(int n) => start.add(Duration(days: n));

  /// Pemain rotasi/cadangan Getafe bernilai ≥ €3 jt.
  Future<Player> target() async {
    final players = PlayerRepository(db);
    final candidates = <Player>[];
    for (final p in await players.squad(_seller)) {
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

  Future<int> askFor(Player p, [DateTime? when]) async => (await svc.quote(
    playerId: p.id,
    ourClubId: _us,
    now: when ?? start,
    seed: 99,
  )).askingFee;

  /// Tawaran 85% → penjual belum setuju → Ruang Negosiasi (status countered).
  Future<int> countered(Player p, {DateTime? on}) async {
    final when = on ?? start;
    final ask = await askFor(p, when);
    await svc.placeBid(
      ourClubId: _us,
      now: when,
      playerId: p.id,
      fee: (ask * 0.85).round(),
      seed: 99,
    );
    await svc.resolveDueBids(
      date: when.add(const Duration(days: 2)),
      ourClubId: _us,
      seed: 99,
    );
    final offer = (await repo.offersFor(_us)).firstWhere(
      (o) => o.playerId == p.id && o.isActive,
    );
    expect(offer.status, TransferOfferStatus.countered);
    return offer.id;
  }

  Future<InboxMessage?> pendingFor(int offerId, InboxActionType type) async {
    for (final m in await InboxRepository(db).pendingActions()) {
      if (m.actionType == type && m.payload!.startsWith('offer:$offerId')) {
        return m;
      }
    }
    return null;
  }

  test('beli: patokan agen → tawar → sepakat → kontrak dengan peran → pindah', () async {
    final p = await target();
    final ask = await askFor(p);
    final id = await countered(p);

    final room = await engine.openNegotiation(id);
    expect(room.mode, NegotiationMode.transferBuy);
    expect(room.session.anchor, greaterThan(ask));
    expect(room.session.limit, lessThan(ask));
    expect(room.session.log.last.text, contains(room.counterpartName));

    // Satu tawaran wajar: agen mengajukan kontra, pesan inbox tetap menunggu.
    final step = await engine.negotiate(
      id,
      NegotiationOffer(amount: (ask * 0.95 / 10).round() * 10),
    );
    expect(step.verdict, AgentVerdict.counter);
    expect(step.response.session.patience, lessThan(100));
    expect(await pendingFor(id, InboxActionType.counterOffer), isNotNull);

    // Terima patokan agen: harga sepakat, lanjut ke kontrak.
    final deal = await engine.acceptAgentTerms(id, const NegotiationOffer(amount: 0));
    expect(deal.continuesToContract, isTrue);
    final afterFee = (await repo.offerById(id))!;
    expect(afterFee.status, TransferOfferStatus.awaitingContract);
    expect(afterFee.fee, deal.response.agreedOffer!.amount);
    expect(await pendingFor(id, InboxActionType.counterOffer), isNull);
    expect(await pendingFor(id, InboxActionType.contractNegotiation), isNotNull);

    // Kontrak: peran Starter.
    final contractRoom = await engine.openNegotiation(id);
    expect(contractRoom.mode, NegotiationMode.contract);
    final usBefore = (await ClubRepository(db).clubById(_us))!;
    final signed = await engine.acceptAgentTerms(
      id,
      NegotiationOffer(
        amount: 0,
        contractYears: contractRoom.session.preferredYears,
        squadStatus: SquadStatus.starter,
      ),
    );
    expect(signed.verdict, AgentVerdict.accept);
    final moved = await PlayerRepository(db).detail(p.id);
    expect(moved!.player.clubId, _us);
    expect(moved.contract!.squadStatus, SquadStatus.starter);
    expect(moved.contract!.wage, signed.response.agreedOffer!.amount);
    expect((await repo.offerById(id))!.status, TransferOfferStatus.completed);
    final usAfter = (await ClubRepository(db).clubById(_us))!;
    expect(usAfter.transferBudget, usBefore.transferBudget - afterFee.fee);
    expect(await pendingFor(id, InboxActionType.contractNegotiation), isNull);
    expect(await repo.activeSessions(), isEmpty);
  });

  test('keluar lalu masuk lagi: patokan, kesabaran, dan riwayat tetap', () async {
    final p = await target();
    final ask = await askFor(p);
    final id = await countered(p);
    await engine.openNegotiation(id);
    final step = await engine.negotiate(
      id,
      NegotiationOffer(amount: (ask * 0.92 / 10).round() * 10, sellOnPct: 10),
    );
    expect(step.verdict, AgentVerdict.counter);

    final again = await GameEngine(db).openNegotiation(id);
    expect(again.session.patience, step.response.session.patience);
    expect(again.session.anchor, step.response.session.anchor);
    expect(again.session.log.length, step.response.session.log.length);
    expect(again.session.lastOffer!.sellOnPct, 10);
  });

  test('tawaran melebihi anggaran ditolak tanpa mengurangi kesabaran', () async {
    final p = await target();
    final id = await countered(p);
    final budget = (await ClubRepository(db).clubById(_us))!.transferBudget;
    await engine.openNegotiation(id);
    await expectLater(
      engine.negotiate(id, NegotiationOffer(amount: budget + 1000)),
      throwsStateError,
    );
    expect((await engine.openNegotiation(id)).session.patience, 100);
  });

  test('lowball berulang: walk-out, lowball dicatat, jeda 1 minggu, agen ingat', () async {
    final p = await target();
    final ask = await askFor(p);
    final id = await countered(p);
    final lowballsBefore = await repo.memory('lowballCount');

    final room = await svc.openNegotiation(
      offerId: id,
      ourClubId: _us,
      date: day(2),
      seed: 99,
    );
    NegotiationStep? step;
    for (var i = 0; i < 6; i++) {
      step = await svc.submitNegotiationOffer(
        offerId: id,
        offer: NegotiationOffer(amount: (ask * 0.5).round()),
        ourClubId: _us,
        date: day(2),
        seed: 99,
      );
      if (step.finished) break;
    }
    expect(step!.verdict, AgentVerdict.walkOut);
    final offer = (await repo.offerById(id))!;
    expect(offer.status, TransferOfferStatus.rejected);
    expect(offer.reason, contains(room.agent.name));
    expect(await repo.memory('lowballCount'), lowballsBefore + 1);

    // Jeda: tidak bisa menawar selama seminggu.
    final blocked = await svc.quote(
      playerId: p.id,
      ourClubId: _us,
      now: day(5),
      seed: 99,
    );
    expect(blocked.blockedReason, contains('Agen'));
    final free = await svc.quote(
      playerId: p.id,
      ourClubId: _us,
      now: day(9),
      seed: 99,
    );
    expect(free.blockedReason, isNull);

    // Negosiasi berikutnya dibuka dari patokan terakhir yang diingat agen.
    final lastAnchor = step.response.session.anchor;
    final id2 = await countered(p, on: day(9));
    final again = await svc.openNegotiation(
      offerId: id2,
      ourClubId: _us,
      date: day(11),
      seed: 99,
    );
    expect(again.session.anchor, lastAnchor);
    expect(again.session.patience, 100);
    expect(again.session.log.first.text, contains('belum lupa'));
  });

  test('jual: pembeli naik bertahap, sepakat, pemain pindah dengan harga baru', () async {
    final ours = await PlayerRepository(db).squad(_us);
    ours.sort((a, b) => a.marketValue.compareTo(b.marketValue));
    final p = ours[ours.length ~/ 2];
    final id = await repo.insertOffer(
      playerId: p.id,
      fromClubId: 'sevilla',
      toClubId: _us,
      fee: 5000,
      status: TransferOfferStatus.awaitingContract,
      createdDate: start,
      responseDate: start,
    );
    final room = await engine.openNegotiation(id);
    expect(room.mode, NegotiationMode.transferSell);
    expect(AgentNegotiator.anchorOffer(room.session).amount, 5000);

    final step = await engine.negotiate(id, const NegotiationOffer(amount: 5600));
    expect(step.verdict, isNot(AgentVerdict.walkOut));
    var fee = 5600;
    if (step.verdict == AgentVerdict.counter) {
      final raised = AgentNegotiator.anchorOffer(step.response.session).amount;
      expect(raised, greaterThan(5000));
      final deal = await engine.acceptAgentTerms(id, const NegotiationOffer(amount: 0));
      expect(deal.verdict, AgentVerdict.accept);
      fee = deal.response.agreedOffer!.amount;
    }
    expect((await PlayerRepository(db).byId(p.id))!.clubId, 'sevilla');
    final sale = (await repo.history()).firstWhere((r) => r.playerId == p.id);
    expect(sale.fee, fee);
    expect(sale.fee, greaterThan(5000));
  });

  test('membatalkan dari ruangan menghapus sesi dan menutup pesan', () async {
    final p = await target();
    final id = await countered(p);
    await engine.openNegotiation(id);
    expect(await repo.activeSessions(), hasLength(1));
    await engine.respondToOffer(id, 'cancel');
    expect((await repo.offerById(id))!.status, TransferOfferStatus.withdrawn);
    expect(await repo.activeSessions(), isEmpty);
    expect(await pendingFor(id, InboxActionType.counterOffer), isNull);
  });
}
