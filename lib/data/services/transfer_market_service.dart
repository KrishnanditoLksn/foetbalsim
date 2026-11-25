import '../../core/rng/seeded_random.dart';
import '../../domain/enums/inbox.dart';
import '../../domain/enums/squad_status.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/transfer/club_ai_profile.dart';
import '../../domain/transfer/interest_engine.dart';
import '../../domain/transfer/market_heat.dart';
import '../../domain/transfer/negotiation_ai.dart';
import '../../domain/transfer/player_willingness.dart';
import '../../domain/transfer/squad_needs.dart';
import '../../domain/transfer/transfer_rules.dart';
import '../../domain/transfer/transfer_window.dart';
import '../../domain/transfer/valuation.dart';
import '../database/app_database.dart';
import '../repositories/club_repository.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/transfer_repository.dart';
import 'transfer_service.dart';

/// Aktivitas bursa harian (README_FASE3 B.6–B.9, B.10):
/// - Minat & rumor: klub memindai pemain di posisi yang dibutuhkan.
/// - Transfer AI↔AI: intensitas mengikuti fase jendela (Deadline Day tertinggi).
/// - Tawaran masuk untuk pemain kita yang didaftar jual.
/// - AI menawarkan pemain ke user lewat berita dan inbox.
/// - Saat jendela tutup: negosiasi dibatalkan dan ringkasan dikirim.
///
/// Semua keputusan deterministik dari (seed, tanggal).
class TransferMarketService {
  TransferMarketService(AppDatabase db)
    : _clubs = ClubRepository(db),
      _players = PlayerRepository(db),
      _transfers = TransferRepository(db),
      _inbox = InboxRepository(db),
      _service = TransferService(db);

  final ClubRepository _clubs;
  final PlayerRepository _players;
  final TransferRepository _transfers;
  final InboxRepository _inbox;
  final TransferService _service;

  static const int maxSoldStartersPerWindow = 3;
  static const int minSquad = 22;
  static const int maxSquad = 30;

  /// Dipanggil engine setiap hari (1 hari = 1 langkah).
  Future<void> processDay({
    required DateTime date,
    required int seed,
    required String ourClubId,
  }) async {
    final openNow = TransferWindow.isOpen(date);
    final openBefore = TransferWindow.isOpen(date.subtract(const Duration(days: 1)));

    // Cicilan jatuh tempo dan respons atas tawaran kita (juga saat bursa tutup).
    await _service.payDueInstallments(date);
    await _service.resolveDueBids(date: date, ourClubId: ourClubId, seed: seed);

    if (openBefore && !openNow) {
      await _closeWindow(date, ourClubId);
      return;
    }
    if (!openNow) return;

    final rng = SeededRandom(_daySeed(seed, date));
    final phase = MarketHeat.phase(date);
    if (TransferWindow.isDeadlineDay(date) &&
        !TransferWindow.isDeadlineDay(date.subtract(const Duration(days: 1)))) {
      await _news(date, 'deadline', 'DEADLINE DAY dimulai: pasar paling panas.', '');
    }

    // Satu snapshot per hari; diambil ulang hanya setelah ada pemain pindah.
    var world = await _snapshot();
    await _scanInterests(date, seed, ourClubId, rng, world);
    await _expireInterests();
    final deals = switch (phase) {
      WindowPhase.start => rng.range(0, 1),
      WindowPhase.middle => rng.range(0, 2),
      WindowPhase.lastWeek => rng.range(1, 3),
      WindowPhase.deadlineDay => rng.range(2, 4),
      WindowPhase.closed => 0,
    };
    for (var i = 0; i < deals; i++) {
      if (await _aiDeal(date, seed, ourClubId, rng, world)) {
        world = await _snapshot();
      }
    }
    await _incomingForUser(date, seed, ourClubId, rng, world);
    await _offerToUser(date, seed, ourClubId, rng, world);
  }

  // --- Snapshot dunia -------------------------------------------------------------

  Future<_World> _snapshot() async {
    final rows = await _players.allForSearch();
    final squads = <String, List<Player>>{};
    final contracts = <int, Contract>{};
    for (final r in rows) {
      squads.putIfAbsent(r.player.clubId, () => []).add(r.player);
      if (r.contract != null) contracts[r.player.id] = r.contract!;
    }
    final clubs = {for (final c in await _clubs.allClubs()) c.id: c};
    final benchmark = SquadNeeds.benchmarkCa(squads.values, contracts);
    return _World(clubs, squads, contracts, benchmark);
  }

  // --- Minat & rumor --------------------------------------------------------------

  /// Sepertiga klub dipindai tiap hari (bergilir). Skor ≥ 40 disimpan; rumor
  /// dibuat bila pemain milik user dipantau klub yang kuat (0–2 per hari).
  Future<void> _scanInterests(
    DateTime date,
    int seed,
    String ourClubId,
    SeededRandom rng,
    _World w,
  ) async {
    final aiClubs = w.clubs.values.where((c) => c.id != ourClubId).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final dayIndex = date.difference(DateTime.utc(date.year, 1, 1)).inDays;
    var rumours = 0;
    for (var i = 0; i < aiClubs.length; i++) {
      if (i % 3 != dayIndex % 3) continue;
      final club = aiClubs[i];
      final profile = await _service.profileOf(club.id, seed);
      if (profile == null) continue;
      final squad = w.squads[club.id] ?? const <Player>[];
      final needs = SquadNeeds.analyze(
        squad: squad,
        contracts: w.contracts,
        now: date,
        benchmarkCa: w.benchmark,
      );
      if (needs.isEmpty) continue;
      final group = needs.entries.reduce((a, b) => a.value >= b.value ? a : b);
      if (group.value < 30) continue;

      // Pemain klub user ikut dipindai: semua klub boleh berminat pada
      // pemain mana pun (README B.10.6).
      final candidates = <Player>[];
      for (final entry in w.squads.entries) {
        if (entry.key == club.id) continue;
        for (final p in entry.value) {
          if (p.position.group == group.key &&
              p.currentAbility >= w.benchmark - 15 &&
              p.currentAbility <= w.benchmark + 25) {
            candidates.add(p);
          }
        }
      }
      if (candidates.isEmpty) continue;
      for (var k = 0; k < 4; k++) {
        final p = candidates[rng.nextInt(candidates.length)];
        final contract = w.contracts[p.id];
        final ask = DynamicValuation.askingFee(
          player: p,
          contract: contract,
          now: date,
          sellerPersonality: (await _service.profileOf(p.clubId, seed))?.personality,
        );
        final score = _interestScore(p, profile, group.value, squad, club, ask, contract, date);
        if (score < 40) continue;
        final level = InterestEngine.levelFor(score);
        await _transfers.upsertInterest(
          clubId: club.id,
          playerId: p.id,
          score: score,
          level: level,
          date: date,
        );
        if (p.clubId == ourClubId && score >= 60 && rumours < 2) {
          rumours++;
          await _news(
            date,
            'rumour',
            '${club.name} memantau ${p.fullName} (${p.position.label}).',
            '${club.id},$ourClubId',
          );
        }
      }
    }
  }

  int _interestScore(
    Player p,
    ClubAiProfile profile,
    int needPriority,
    List<Player> squad,
    Club club,
    int ask,
    Contract? contract,
    DateTime date,
  ) {
    final starters = squad
        .where((s) => s.position.group == p.position.group)
        .toList()
      ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
    final bestHere = starters.isEmpty ? 50 : starters.first.currentAbility;
    final upgrade = (50 + (p.currentAbility - bestHere) * 2.5).clamp(0, 100).toInt();
    final profileFit = switch (profile.personality) {
      ClubPersonality.youthDeveloper => p.age <= 23 ? 90 : 30,
      ClubPersonality.moneyball => p.marketValue < DynamicValuation.expectedWage(p) * 40 ? 80 : 40,
      ClubPersonality.bigSpender => p.currentAbility >= 110 ? 85 : 40,
      _ => 60,
    };
    final budget = club.transferBudget;
    final affordability = (budget / ask * 100).clamp(0, 100).toInt();
    final expiring = contract != null &&
        contract.endDate.difference(date).inDays <= 365;
    final opportunity = (profile.sellingWillingness ~/ 2 + (expiring ? 35 : 0) +
            (p.isTransferListed ? 20 : 0))
        .clamp(0, 100)
        .toInt();
    return InterestEngine.score(
      needFit: needPriority,
      upgrade: upgrade,
      profileFit: profileFit,
      affordability: affordability,
      opportunity: opportunity,
    );
  }

  Future<void> _expireInterests() => _transfers.deleteInterestsBelow(40);

  // --- Transfer AI↔AI ------------------------------------------------------------

  /// Satu percobaan transfer AI↔AI. Mengembalikan true bila pemain pindah.
  Future<bool> _aiDeal(
    DateTime date,
    int seed,
    String ourClubId,
    SeededRandom rng,
    _World w,
  ) async {
    final aiClubs = w.clubs.values.where((c) => c.id != ourClubId).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (aiClubs.length < 2) return false;
    final buyer = aiClubs[rng.nextInt(aiClubs.length)];
    if (buyer.transferBudget < 2000) return false;
    final buyerSquad = w.squads[buyer.id] ?? const <Player>[];
    if (buyerSquad.length >= maxSquad) return false;
    final needs = SquadNeeds.analyze(
      squad: buyerSquad,
      contracts: w.contracts,
      now: date,
      benchmarkCa: w.benchmark,
    );
    if (needs.isEmpty) return false;
    final group = needs.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final sellers = aiClubs.where((c) => c.id != buyer.id).toList();
    final seller = sellers[rng.nextInt(sellers.length)];
    final sellerSquad = w.squads[seller.id] ?? const <Player>[];
    if (sellerSquad.length <= minSquad) return false;
    final candidates = sellerSquad
        .where((p) => p.position.group == group && _unlocked(p, date))
        .toList();
    if (candidates.isEmpty) return false;
    final player = candidates[rng.nextInt(candidates.length)];
    final contract = w.contracts[player.id];
    final starter = contract?.squadStatus == SquadStatus.starter ||
        contract?.squadStatus == SquadStatus.keyPlayer;
    final windowKey = _windowKey(date);
    if (starter &&
        await _transfers.memory('sold:${seller.id}:$windowKey') >=
            maxSoldStartersPerWindow) {
      return false;
    }
    // Maks 6 pemain masuk dan 6 keluar per klub dalam satu jendela.
    final start = TransferRules.windowStart(date)!;
    if ((await _transfers.movesSince(buyer.id, start)).incoming >=
            TransferRules.maxMovesPerWindow ||
        (await _transfers.movesSince(seller.id, start)).outgoing >=
            TransferRules.maxMovesPerWindow) {
      return false;
    }

    final sellerProfile = await _service.profileOf(seller.id, seed);
    final buyerProfile = await _service.profileOf(buyer.id, seed);
    if (sellerProfile == null || buyerProfile == null) return false;
    var ask = DynamicValuation.askingFee(
      player: player,
      contract: contract,
      now: date,
      marketHeat: MarketHeat.multiplier(date: date, positionDemand: 0.5),
      sellerPersonality: sellerProfile.personality,
    );
    if (TransferRules.areRivals(buyer.id, seller.id)) {
      ask = (ask * TransferRules.rivalPremium).round();
    }
    final offer = (ask * (0.85 + rng.nextDouble() * 0.2)).round();
    final indispensable = starter &&
        sellerSquad.where((s) => s.id != player.id && s.position.group == group).length < 2;
    final verdict = NegotiationAi.evaluate(
      offer: offer,
      ask: ask,
      seller: sellerProfile,
      isIndispensable: indispensable,
    );

    int? fee;
    if (verdict.verdict == NegotiationVerdict.accept) fee = offer;
    if (verdict.verdict == NegotiationVerdict.counter) {
      final counter = verdict.counterFee!;
      if (counter <= buyer.transferBudget && counter <= ask * 1.1) fee = counter;
    }
    if (fee == null) return false;
    if (fee > buyer.transferBudget || fee > buyer.balance) return false;

    final wage = contract?.wage ?? DynamicValuation.expectedWage(player);
    final will = PlayerWillingness.decide(
      player: player,
      fromRep: w.clubs[seller.id]?.reputation ?? 50,
      toRep: buyer.reputation,
      wageOffer: (wage * 1.05).round(),
      expectedWage: wage,
      isBenchPlayer: contract?.squadStatus == SquadStatus.backup ||
          contract?.squadStatus == SquadStatus.youth,
      shortContractInJanuary: false,
    );
    if (!will.willing) return false;

    await _service.completeTransfer(
      player: player,
      buyerId: buyer.id,
      sellerId: seller.id,
      fee: fee,
      wage: wage,
      years: 3,
      date: date,
      type: TransferType.aiDeal,
    );
    if (starter) {
      await _transfers.setMemory(
        'sold:${seller.id}:$windowKey',
        await _transfers.memory('sold:${seller.id}:$windowKey') + 1,
      );
    }
    await _news(
      date,
      'deal',
      '${seller.name} menjual ${player.fullName} ke ${buyer.name} '
          'seharga ${moneyLabel(fee)}.',
      '${seller.id},${buyer.id}',
    );
    return true;
  }

  bool _unlocked(Player p, DateTime date) =>
      p.lockedUntil == null || !p.lockedUntil!.isAfter(date);

  // --- Tawaran masuk & tawaran AI ke user ----------------------------------------

  /// Klub AI menawar pemain kita (aksi blocking Terima / Tolak / Kontra):
  /// pemain di daftar jual, atau pemain yang menjadi target utama klub lain
  /// (README B.10.6). Pemain yang tidak dijual hanya ditawar di atas harga.
  Future<void> _incomingForUser(
    DateTime date,
    int seed,
    String ourClubId,
    SeededRandom rng,
    _World w,
  ) async {
    final ours = w.squads[ourClubId] ?? const <Player>[];
    final buyers = w.clubs.values
        .where(
          (c) =>
              c.id != ourClubId &&
              c.transferBudget >= 3000 &&
              (w.squads[c.id]?.length ?? 0) < maxSquad,
        )
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (buyers.isEmpty) return;
    for (final p in ours) {
      if (!_unlocked(p, date)) continue;
      // Klub yang menjadikan pemain ini target utama menawar lebih dulu.
      Club? suitor;
      for (final (clubId, _, level) in await _transfers.interestsForPlayer(p.id)) {
        final c = w.clubs[clubId];
        if (level == InterestLevel.target && c != null && buyers.contains(c)) {
          suitor = c;
          break;
        }
      }
      final listed = p.isTransferListed;
      if (!listed && suitor == null) continue;
      if (!rng.chance(listed ? 0.10 : 0.06)) continue;
      if ((await _transfers.activeOffersForPlayer(p.id)).isNotEmpty) continue;
      final buyer = suitor ?? buyers[rng.nextInt(buyers.length)];
      var ask = DynamicValuation.askingFee(
        player: p,
        contract: w.contracts[p.id],
        now: date,
      );
      if (TransferRules.areRivals(buyer.id, ourClubId)) {
        ask = (ask * TransferRules.rivalPremium).round();
      }
      final fee = ((ask * (listed ? 0.95 : 1.05) + ask * rng.nextDouble() * 0.25) / 10)
              .round() *
          10;
      if (fee > buyer.transferBudget || fee > buyer.balance) continue;
      final offerId = await _transfers.insertOffer(
        playerId: p.id,
        fromClubId: buyer.id,
        toClubId: ourClubId,
        fee: fee,
        status: TransferOfferStatus.awaitingContract,
        createdDate: date,
        responseDate: date,
      );
      await _inbox.add(
        InboxMessage(
          id: 0,
          date: date,
          category: InboxCategory.transfer,
          title: 'Tawaran masuk: ${p.fullName}',
          body: '${buyer.name} menawar ${p.fullName} dengan ${moneyLabel(fee)}'
              '${listed ? '' : ' (pemain tidak didaftar jual)'}. '
              'Terima, tolak, atau tawar harga lewat agen pemain di Ruang '
              'Negosiasi.',
          isRead: false,
          actionType: InboxActionType.incomingTransferOffer,
          payload: 'offer:$offerId',
          resolved: false,
          choice: null,
        ),
      );
    }
  }

  /// AI menawarkan pemain yang cocok dengan kebutuhan kita (berita + info).
  Future<void> _offerToUser(
    DateTime date,
    int seed,
    String ourClubId,
    SeededRandom rng,
    _World w,
  ) async {
    if (!rng.chance(0.20)) return;
    final ours = w.squads[ourClubId] ?? const <Player>[];
    final needs = SquadNeeds.analyze(
      squad: ours,
      contracts: w.contracts,
      now: date,
      benchmarkCa: w.benchmark,
    );
    if (needs.isEmpty) return;
    final group = needs.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final options = <Player>[];
    for (final entry in w.squads.entries) {
      if (entry.key == ourClubId || entry.value.length <= minSquad + 2) continue;
      for (final p in entry.value) {
        if (p.position.group == group &&
            p.currentAbility >= w.benchmark - 5 &&
            _unlocked(p, date)) {
          options.add(p);
        }
      }
    }
    if (options.isEmpty) return;
    final p = options[rng.nextInt(options.length)];
    final club = w.clubs[p.clubId];
    final ask = DynamicValuation.askingFee(
      player: p,
      contract: w.contracts[p.id],
      now: date,
    );
    final text = '${club?.name ?? p.clubId} menawarkan ${p.fullName} '
        '(${p.position.label}, ${p.age} th) seharga ${moneyLabel(ask)}.';
    await _news(date, 'offer', text, '${p.clubId},$ourClubId');
    await _inbox.add(
      InboxMessage(
        id: 0,
        date: date,
        category: InboxCategory.transfer,
        title: 'Tawaran pemain: ${p.fullName}',
        body: '$text Cari pemain ini di Cari Pemain untuk menawar.',
        isRead: false,
        actionType: InboxActionType.none,
        payload: 'player:${p.id}',
        resolved: false,
        choice: null,
      ),
    );
  }

  // --- Penutupan bursa -----------------------------------------------------------

  /// Negosiasi yang belum tuntas dibatalkan, lalu ringkasan bursa ke inbox.
  Future<void> _closeWindow(DateTime date, String ourClubId) async {
    final start = date.month == 1 ? DateTime.utc(date.year, 1, 1) : DateTime.utc(date.year, 7, 1);
    final history = await _transfers.history(limit: 500);
    final inWindow = history.where((r) => !r.date.isBefore(start) && !r.date.isAfter(date)).toList();
    final biggest = inWindow.isEmpty
        ? null
        : inWindow.reduce((a, b) => a.fee >= b.fee ? a : b);
    for (final o in await _transfers.offersFor(ourClubId)) {
      if (o.isActive || o.status == TransferOfferStatus.countered) {
        await _transfers.updateOffer(
          o.id,
          status: TransferOfferStatus.withdrawn,
          responseDate: date,
        );
      }
    }
    await _news(
      date,
      'deadline',
      'Bursa ditutup: ${inWindow.length} transfer'
          '${biggest == null ? '' : ', terbesar ${moneyLabel(biggest.fee)} (${biggest.playerName})'}.',
      '',
    );
    await _inbox.add(
      InboxMessage(
        id: 0,
        date: date,
        category: InboxCategory.transfer,
        title: 'Bursa ditutup',
        body: 'Bursa transfer ditutup: ${inWindow.length} transfer di liga. '
            'Negosiasi yang belum tuntas dibatalkan.',
        isRead: false,
        actionType: InboxActionType.none,
        payload: null,
        resolved: false,
        choice: null,
      ),
    );
  }

  // --- Util -----------------------------------------------------------------------

  Future<void> _news(DateTime date, String kind, String body, String clubIds) =>
      _transfers.addNews(date: date, kind: kind, body: body, clubIds: clubIds);

  static String _windowKey(DateTime d) => '${d.year}-${d.month == 1 ? 'w' : 's'}';

  /// Hash hari: (seed, jumlah hari sejak 2000) → seed RNG harian.
  static int _daySeed(int seed, DateTime d) {
    final dayKey = d.difference(DateTime.utc(2000)).inDays;
    return (seed * 31 + dayKey * 7919 + 17) & 0x7FFFFFFF;
  }
}

class _World {
  _World(this.clubs, this.squads, this.contracts, this.benchmark);

  final Map<String, Club> clubs;
  final Map<String, List<Player>> squads;
  final Map<int, Contract> contracts;
  final int benchmark;
}
