import 'package:drift/drift.dart' show Value;

import '../../domain/enums/inbox.dart';
import '../../domain/enums/squad_status.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_news_payload.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/agent_negotiator.dart';
import '../../domain/transfer/club_ai_profile.dart';
import '../../domain/transfer/interest_engine.dart';
import '../../domain/transfer/market_heat.dart';
import '../../domain/transfer/negotiation_ai.dart';
import '../../domain/transfer/player_willingness.dart';
import '../../domain/transfer/transfer_rules.dart';
import '../../domain/transfer/transfer_window.dart';
import '../../domain/transfer/valuation.dart';
import '../../l10n/l10n.dart';
import '../database/app_database.dart';
import '../repositories/club_repository.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/transfer_repository.dart';

/// Ringkasan harga untuk layar detail pemain: apa yang diminta penjual dari
/// klub kita dan apakah pemain bisa ditawar saat ini.
class TransferQuote {
  const TransferQuote({
    required this.askingFee,
    required this.expectedWage,
    required this.blockedReason,
    required this.isRival,
  });

  final int askingFee; // €K, sudah termasuk premi user (lowball, rival)
  final int expectedWage; // €K per tahun
  final String? blockedReason; // null = boleh ditawar
  final bool isRival;
}

/// Isi Ruang Negosiasi untuk satu tawaran: sesi agen plus konteks yang
/// ditampilkan (pemain, klub lawan, dana klub kita).
class NegotiationRoom {
  const NegotiationRoom({
    required this.offer,
    required this.player,
    required this.session,
    required this.counterpartName,
    required this.transferBudget,
    required this.balance,
    required this.expectedWage,
  });

  final TransferOffer offer;
  final Player player;
  final NegotiationSession session;

  /// Klub penjual (mode beli & kontrak) atau pembeli (mode jual).
  final String counterpartName;

  /// Dana klub kita (€K) untuk validasi langsung di layar.
  final int transferBudget;
  final int balance;
  final int expectedWage;

  NegotiationMode get mode => session.mode;
  AgentProfile get agent => session.agent;

  NegotiationRoom withSession(NegotiationSession s) => NegotiationRoom(
    offer: offer,
    player: player,
    session: s,
    counterpartName: counterpartName,
    transferBudget: transferBudget,
    balance: balance,
    expectedWage: expectedWage,
  );
}

/// Hasil satu langkah di Ruang Negosiasi.
class NegotiationStep {
  const NegotiationStep({required this.response, required this.summary});

  final AgentResponse response;

  /// Ringkasan hasil untuk snackbar, mis. "Pemain dijual." (null bila agen
  /// mengajukan kontra).
  final String? summary;

  AgentVerdict get verdict => response.verdict;

  /// Sesi untuk mode ini sudah berakhir (sepakat atau walk-out).
  bool get finished => verdict != AgentVerdict.counter;

  /// Harga transfer disepakati: lanjut ke negosiasi kontrak.
  bool get continuesToContract =>
      verdict == AgentVerdict.accept &&
      response.session.mode == NegotiationMode.transferBuy;
}

/// Aksi bursa dari sisi user dan penyelesaian transfer (README_FASE3 B.5,
/// B.9, B.10): tawaran keluar dengan cicilan & sell-on, negosiasi 3 ronde,
/// tawaran masuk, kontrak pemain, dan pemindahan pemain beserta dananya.
/// Aktivitas harian AI ada di `TransferMarketService`.
class TransferService {
  TransferService(this._db)
    : _clubs = ClubRepository(_db),
      _players = PlayerRepository(_db),
      _transfers = TransferRepository(_db),
      _inbox = InboxRepository(_db);

  final AppDatabase _db;
  final ClubRepository _clubs;
  final PlayerRepository _players;
  final TransferRepository _transfers;
  final InboxRepository _inbox;

  /// Profil klub: dari simpanan, atau diturunkan dari seed lalu disimpan.
  Future<ClubAiProfile?> profileOf(String clubId, int seed) async {
    final existing = await _transfers.profileFor(clubId);
    if (existing != null) return existing;
    final club = await _clubs.clubById(clubId);
    if (club == null) return null;
    final p = ClubAiProfile.derive(club: club, seed: seed);
    await _transfers.saveProfile(p);
    return p;
  }

  /// Harga minta untuk pemain. Untuk tawaran user ditambah premi bila user
  /// sering menawar rendah (README B.7, +5–15%). Transfer antar-rival lokal
  /// dikenai premi +30% (B.10.7).
  Future<int> askingFor({
    required Player player,
    required Contract? contract,
    required DateTime now,
    required int seed,
    bool forUser = false,
    String? buyerClubId,
  }) async {
    final profile = await profileOf(player.clubId, seed);
    final heat = MarketHeat.multiplier(date: now, positionDemand: 0.5);
    var ask =
        DynamicValuation.askingFee(
          player: player,
          contract: contract,
          now: now,
          marketHeat: heat,
          sellerPersonality: profile?.personality,
        ).toDouble();
    if (forUser) {
      final lowball = await _transfers.memory('lowballCount');
      ask *= 1 + (0.05 * lowball).clamp(0, 0.15);
    }
    if (buyerClubId != null &&
        TransferRules.areRivals(buyerClubId, player.clubId)) {
      ask *= TransferRules.rivalPremium;
    }
    return (ask / 10).round() * 10;
  }

  /// Harga, gaji yang diharapkan, dan alasan bila pemain tidak bisa ditawar.
  Future<TransferQuote> quote({
    required int playerId,
    required String ourClubId,
    required DateTime now,
    required int seed,
  }) async {
    final player = await _players.byId(playerId);
    if (player == null) throw StateError(tr('err.playerNotFound'));
    final detail = await _players.detail(playerId);
    final ask = await askingFor(
      player: player,
      contract: detail?.contract,
      now: now,
      seed: seed,
      forUser: true,
      buyerClubId: ourClubId,
    );
    String? blocked;
    try {
      await _checkCanBid(player, ourClubId, now);
    } on StateError catch (e) {
      blocked = e.message;
    }
    return TransferQuote(
      askingFee: ask,
      expectedWage: DynamicValuation.expectedWage(player),
      blockedReason: blocked,
      isRival: TransferRules.areRivals(ourClubId, player.clubId),
    );
  }

  /// Aturan yang harus dipenuhi sebelum menawar (tanpa melihat nominal).
  Future<void> _checkCanBid(
    Player player,
    String ourClubId,
    DateTime now,
  ) async {
    if (!TransferWindow.isOpen(now)) {
      throw StateError(tr('err.windowClosed'));
    }
    if (player.clubId == ourClubId) {
      throw StateError(tr('err.alreadyOurs'));
    }
    if (player.lockedUntil != null && player.lockedUntil!.isAfter(now)) {
      throw StateError(tr('err.playerLocked'));
    }
    final active = await _transfers.activeOffersForPlayer(player.id);
    if (active.any((o) => o.fromClubId == ourClubId)) {
      throw StateError(tr('err.alreadyNegotiating'));
    }
    final cooldown = await _transfers.activeCooldown(player.id, now);
    if (cooldown != null) {
      final until = cooldown.cooldownUntil!.toUtc();
      throw StateError(
        tr('err.agentCooldown', {
          'player': player.lastName,
          'date': formatDayMonth(until),
        }),
      );
    }
    final squad = await _players.squad(ourClubId);
    if (squad.length >= TransferRules.maxSquad) {
      throw StateError(
        tr('err.squadFullSell', {'max': TransferRules.maxSquad}),
      );
    }
    final start = TransferRules.windowStart(now)!;
    final moves = await _transfers.movesSince(ourClubId, start);
    if (moves.incoming >= TransferRules.maxMovesPerWindow) {
      throw StateError(
        tr('err.maxIncoming', {'n': TransferRules.maxMovesPerWindow}),
      );
    }
  }

  /// Validasi dana: anggaran transfer menanggung biaya penuh, saldo harus
  /// cukup untuk pembayaran di muka (cicilan pertama).
  void _checkFunds(Club ours, int fee, int installmentYears) {
    if (fee > ours.transferBudget) {
      throw StateError(
        tr('err.budget', {'left': moneyLabel(ours.transferBudget)}),
      );
    }
    final upfront = TransferRules.upfront(fee, installmentYears);
    if (upfront > ours.balance) {
      throw StateError(tr('err.balance', {'upfront': moneyLabel(upfront)}));
    }
  }

  /// Mengajukan tawaran (ronde 1) untuk pemain klub lain.
  Future<void> placeBid({
    required String ourClubId,
    required DateTime now,
    required int playerId,
    required int fee,
    required int seed,
    int installmentYears = 1,
    int sellOnPct = 0,
  }) async {
    final player = await _players.byId(playerId);
    if (player == null) throw StateError(tr('err.playerNotFound'));
    await _checkCanBid(player, ourClubId, now);
    if (fee <= 0) throw StateError(tr('err.amountPositive'));
    if (!TransferRules.validInstallments(installmentYears)) {
      throw StateError(tr('err.installments'));
    }
    if (!TransferRules.validSellOn(sellOnPct)) {
      throw StateError(tr('err.sellOn'));
    }
    final ours = await _clubs.clubById(ourClubId);
    if (ours == null) throw StateError(tr('err.clubNotFound'));
    _checkFunds(ours, fee, installmentYears);

    final seller = await _clubs.clubById(player.clubId);
    // Respons klub penjual 1–2 hari, ditentukan dari data (deterministik).
    final days = 1 + (playerId + fee) % 2;
    final offerId = await _transfers.insertOffer(
      playerId: playerId,
      fromClubId: ourClubId,
      toClubId: player.clubId,
      fee: fee,
      status: TransferOfferStatus.pending,
      createdDate: now,
      responseDate: _day(now).add(Duration(days: days)),
      installmentYears: installmentYears,
      sellOnPct: sellOnPct,
    );
    final news = await _currentContractNews(
      player,
      fromClubId: player.clubId,
      toClubId: ourClubId,
      status: TransferNewsStatus.pendingBid,
      fee: fee,
      installmentYears: installmentYears,
      sellOnPct: sellOnPct,
      offerId: offerId,
    );
    await _inbox.add(
      _info(
        now,
        Msg('msg.bidSent.title', {'player': player.fullName}),
        Msg('msg.bidSent.body', {
          'terms': termsMsg(fee, installmentYears, sellOnPct),
          'player': player.fullName,
          'club': seller?.name ?? player.clubId,
          'days': days,
        }),
        payload: news.encode(head: 'offer:$offerId'),
      ),
    );
  }

  Future<void> setListed(int playerId, bool listed) =>
      _players.setListed(playerId, listed);

  Future<void> setShortlisted(int playerId, bool value, DateTime now) =>
      _transfers.setShortlisted(playerId, value, now);

  /// Klub yang berminat pada pemain beserta level minatnya.
  Future<List<PlayerInterest>> interestsFor(int playerId) async {
    final list = <PlayerInterest>[];
    for (final (clubId, score, level) in await _transfers.interestsForPlayer(
      playerId,
    )) {
      final club = await _clubs.clubById(clubId);
      list.add(
        PlayerInterest(
          clubId: clubId,
          clubName: club?.name ?? clubId,
          score: score,
          levelLabel: switch (level) {
            InterestLevel.target => tr('interest.target'),
            InterestLevel.interested => tr('interest.interested'),
            InterestLevel.watching => tr('interest.watching'),
            InterestLevel.none => '-',
          },
        ),
      );
    }
    return list;
  }

  // --- Respons klub penjual atas tawaran kita -----------------------------------

  /// Mengevaluasi tawaran kita yang sudah jatuh tempo: diterima, ditolak,
  /// atau dibawa ke Ruang Negosiasi bersama agen pemain. Dipanggil setiap hari.
  Future<void> resolveDueBids({
    required DateTime date,
    required String ourClubId,
    required int seed,
  }) async {
    for (final o in await _transfers.dueOffers(date)) {
      if (o.fromClubId != ourClubId) continue;
      final player = await _players.byId(o.playerId);
      if (player == null || player.clubId != o.toClubId) {
        await _transfers.updateOffer(
          o.id,
          status: TransferOfferStatus.withdrawn,
          responseDate: date,
          reason: const Msg('reason.playerMoved').encode(),
        );
        continue;
      }
      final detail = await _players.detail(player.id);
      final ask = await askingFor(
        player: player,
        contract: detail?.contract,
        now: date,
        seed: seed,
        forUser: true,
        buyerClubId: ourClubId,
      );
      final seller = await profileOf(o.toClubId, seed);
      final squad = await _players.squad(o.toClubId);
      final indispensable = _isIndispensable(player, squad, detail?.contract);
      final value = TransferRules.offerValue(
        fee: o.fee,
        installmentYears: o.installmentYears,
        sellOnPct: o.sellOnPct,
      );
      final result = NegotiationAi.evaluate(
        offer: value,
        ask: ask,
        seller: seller!,
        isIndispensable: indispensable,
      );
      final sellerName =
          (await _clubs.clubById(o.toClubId))?.name ?? o.toClubId;
      final terms = termsMsg(o.fee, o.installmentYears, o.sellOnPct);

      switch (result.verdict) {
        case NegotiationVerdict.accept:
          await _acceptFee(
            o,
            player,
            date,
            Msg('msg.sellerAccepted', {'club': sellerName, 'terms': terms}),
          );
        case NegotiationVerdict.counter:
          final agent = AgentProfile.forPlayer(seed: seed, playerId: player.id);
          await _transfers.updateOffer(
            o.id,
            status: TransferOfferStatus.countered,
            responseDate: date,
          );
          await _inbox.add(
            InboxMessage(
              id: 0,
              date: date,
              category: InboxCategory.transfer,
              title:
                  Msg('msg.counter.title', {
                    'player': player.fullName,
                  }).encode(),
              body:
                  Msg('msg.counter.body', {
                    'club': sellerName,
                    'terms': terms,
                    'player': player.fullName,
                    'agent': agent.name,
                  }).encode(),
              isRead: false,
              actionType: InboxActionType.counterOffer,
              payload: (await _offerNews(
                o,
                player,
                TransferNewsStatus.counterOffer,
              )).encode(head: 'offer:${o.id}'),
              resolved: false,
              choice: null,
            ),
          );
        case NegotiationVerdict.reject:
          if (value < ask * TransferRules.rejectBelow) {
            await _addLowball();
          }
          final reason = result.reason ?? const Msg('reason.rejected').encode();
          await _transfers.updateOffer(
            o.id,
            status: TransferOfferStatus.rejected,
            responseDate: date,
            reason: reason,
          );
          await _inbox.add(
            _info(
              date,
              Msg('msg.rejected.title', {'player': player.fullName}),
              Msg('msg.rejected.body', {
                'club': sellerName,
                'terms': terms,
                'reason': asMsg(reason),
              }),
              payload:
                  (await _offerNews(
                    o,
                    player,
                    TransferNewsStatus.rejected,
                  )).encode(),
            ),
          );
      }
    }
  }

  Future<void> _addLowball() async => _transfers.setMemory(
    'lowballCount',
    await _transfers.memory('lowballCount') + 1,
  );

  /// Harga disepakati klub penjual: lanjut ke negosiasi kontrak pemain.
  Future<void> _acceptFee(
    TransferOffer o,
    Player player,
    DateTime date,
    Msg lead,
  ) async {
    final wage = DynamicValuation.expectedWage(player);
    await _transfers.updateOffer(
      o.id,
      status: TransferOfferStatus.awaitingContract,
      responseDate: date,
    );
    await _inbox.add(
      InboxMessage(
        id: 0,
        date: date,
        category: InboxCategory.transfer,
        title: Msg('msg.feeAgreed.title', {'player': player.fullName}).encode(),
        body:
            Msg('msg.feeAgreed.body', {
              'lead': lead,
              'player': player.fullName,
            }).encode(),
        isRead: false,
        actionType: InboxActionType.contractNegotiation,
        // Baca ulang: biaya bisa baru saja diubah ke harga kesepakatan agen.
        payload: (await _offerNews(
          await _transfers.offerById(o.id) ?? o,
          player,
          TransferNewsStatus.contractTalks,
          minWage: wage,
        )).encode(head: 'offer:${o.id}|min:$wage'),
        resolved: false,
        choice: null,
      ),
    );
  }

  bool _isIndispensable(Player p, List<Player> squad, Contract? contract) {
    final status = contract?.squadStatus;
    if (status != SquadStatus.keyPlayer && status != SquadStatus.starter) {
      return false;
    }
    // Tanpa pengganti di grup posisi yang sama, pemain dianggap inti.
    final sameGroup =
        squad
            .where((s) => s.id != p.id && s.position.group == p.position.group)
            .toList();
    return sameGroup.length < 2;
  }

  // --- Keputusan user tanpa tawar-menawar ----------------------------------------

  /// Menyelesaikan aksi transfer yang tidak perlu tawar-menawar (dari inbox
  /// atau tab Negosiasi). Tawar-menawar ada di Ruang Negosiasi.
  ///
  /// Pilihan:
  /// - tawaran masuk: `accept` (jual di harga pembeli), `reject`
  /// - kontra-tawaran: `cancel`
  /// - kontrak pemain: `wage:GAJI|years:TAHUN`, `cancel`
  Future<void> resolveAction({
    required InboxMessage message,
    required String choice,
    required DateTime date,
    required String ourClubId,
    required int seed,
  }) => respond(
    offerId: _offerIdOf(message.payload),
    choice: choice,
    date: date,
    ourClubId: ourClubId,
  );

  Future<void> respond({
    required int? offerId,
    required String choice,
    required DateTime date,
    required String ourClubId,
  }) async {
    if (offerId == null) return;
    final offer = await _transfers.offerById(offerId);
    if (offer == null || !offer.isActive) {
      throw StateError(tr('err.negotiationInactive'));
    }
    final player = await _players.byId(offer.playerId);
    if (player == null) throw StateError(tr('err.playerNotFound'));

    if (offer.isIncomingFor(ourClubId)) {
      await _answerIncoming(offer, player, choice, date, ourClubId);
    } else if (offer.status == TransferOfferStatus.countered) {
      if (choice != 'cancel') {
        throw StateError(tr('err.useRoom'));
      }
      await _withdraw(offer, date);
    } else if (offer.status == TransferOfferStatus.awaitingContract) {
      await _negotiateContract(offer, player, choice, date, ourClubId);
    } else {
      throw StateError(tr('err.awaitingSeller'));
    }
  }

  Future<void> _withdraw(TransferOffer offer, DateTime date) =>
      _transfers.updateOffer(
        offer.id,
        status: TransferOfferStatus.withdrawn,
        responseDate: date,
        reason: const Msg('reason.cancelledByUs').encode(),
      );

  /// Tawaran masuk dari klub AI untuk pemain kita: terima di harga pembeli
  /// atau tolak. Menawar harga dilakukan di Ruang Negosiasi.
  Future<void> _answerIncoming(
    TransferOffer offer,
    Player player,
    String choice,
    DateTime date,
    String ourClubId,
  ) async {
    if (choice == 'reject') {
      await _transfers.updateOffer(
        offer.id,
        status: TransferOfferStatus.rejected,
        responseDate: date,
        reason: const Msg('reason.rejectedByUs').encode(),
      );
      return;
    }
    if (choice != 'accept') {
      throw StateError(tr('err.useRoom'));
    }
    await _checkCanSell(ourClubId, date);
    await _completeTransfer(
      player: player,
      buyerId: offer.fromClubId,
      sellerId: ourClubId,
      fee: offer.fee,
      date: date,
      type: TransferType.sell,
      offerId: offer.id,
      installmentYears: offer.installmentYears,
      sellOnPct: offer.sellOnPct,
    );
  }

  // --- Ruang Negosiasi -----------------------------------------------------------

  /// Mode negosiasi yang berlaku untuk tawaran ini saat ini.
  static NegotiationMode _modeOf(TransferOffer offer, String ourClubId) {
    if (offer.isIncomingFor(ourClubId)) return NegotiationMode.transferSell;
    return switch (offer.status) {
      TransferOfferStatus.countered => NegotiationMode.transferBuy,
      TransferOfferStatus.awaitingContract => NegotiationMode.contract,
      _ => throw StateError(tr('err.awaitingSeller')),
    };
  }

  /// Membuka Ruang Negosiasi. Sesi yang sudah berjalan dilanjutkan (patokan,
  /// kesabaran, dan riwayat tetap); sesi baru dibuka dengan patokan agen.
  Future<NegotiationRoom> openNegotiation({
    required int offerId,
    required String ourClubId,
    required DateTime date,
    required int seed,
  }) async {
    final ctx = await _roomContext(offerId, ourClubId);
    final agent = AgentProfile.forPlayer(seed: seed, playerId: ctx.player.id);
    final row = await _transfers.session(offerId, ctx.mode.name);
    NegotiationSession? session;
    if (row != null && row.status == NegotiationStatus.active.name) {
      session = NegotiationSession.fromStored(
        mode: ctx.mode,
        agent: agent,
        status: NegotiationStatus.active,
        patience: row.patience,
        anchor: row.anchorValue,
        limit: row.limitValue,
        extras: row.extras,
      );
    } else {
      session = await _newSession(ctx, agent, date, seed, ourClubId);
      await _saveSession(ctx.offer, session, date);
    }
    return ctx.room(session);
  }

  /// Satu tawaran user ke agen. Validasi dana dan skuad dilakukan sebelum
  /// agen menilai, sehingga tawaran yang tidak sah tidak mengurangi
  /// kesabaran.
  Future<NegotiationStep> submitNegotiationOffer({
    required int offerId,
    required NegotiationOffer offer,
    required String ourClubId,
    required DateTime date,
    required int seed,
  }) async {
    final room = await openNegotiation(
      offerId: offerId,
      ourClubId: ourClubId,
      date: date,
      seed: seed,
    );
    await _validateNegotiationOffer(room, offer, ourClubId, date);
    final response = AgentNegotiator.respond(room.session, offer, _names(room));
    return _applyResponse(room, response, ourClubId, date);
  }

  /// User menerima patokan agen, dinyatakan dengan syarat [terms].
  Future<NegotiationStep> acceptAgentTerms({
    required int offerId,
    required NegotiationOffer terms,
    required String ourClubId,
    required DateTime date,
    required int seed,
  }) async {
    final room = await openNegotiation(
      offerId: offerId,
      ourClubId: ourClubId,
      date: date,
      seed: seed,
    );
    final deal = AgentNegotiator.anchorOffer(room.session, terms);
    await _validateNegotiationOffer(room, deal, ourClubId, date);
    final response = AgentNegotiator.respond(room.session, deal, _names(room));
    if (response.verdict != AgentVerdict.accept) {
      // Patokan agen memenuhi syaratnya sendiri; ini hanya terjadi bila
      // pembulatan nominal menggeser nilai terlalu jauh.
      throw StateError(tr('err.anchorChanged'));
    }
    return _applyResponse(room, response, ourClubId, date);
  }

  Future<_RoomContext> _roomContext(int offerId, String ourClubId) async {
    final offer = await _transfers.offerById(offerId);
    if (offer == null || !offer.isActive) {
      throw StateError(tr('err.negotiationInactive'));
    }
    final mode = _modeOf(offer, ourClubId);
    final player = await _players.byId(offer.playerId);
    if (player == null) throw StateError(tr('err.playerNotFound'));
    final ours = await _clubs.clubById(ourClubId);
    if (ours == null) throw StateError(tr('err.clubNotFound'));
    final otherId =
        offer.isIncomingFor(ourClubId) ? offer.fromClubId : offer.toClubId;
    final other = await _clubs.clubById(otherId);
    return _RoomContext(
      offer: offer,
      mode: mode,
      player: player,
      ours: ours,
      other: other,
      otherName: other?.name ?? otherId,
    );
  }

  NegotiationNames _names(NegotiationRoom room) => NegotiationNames(
    player: room.player.lastName,
    club: room.counterpartName,
  );

  /// Patokan awal dan batas rahasia agen (README B.2).
  Future<NegotiationSession> _newSession(
    _RoomContext ctx,
    AgentProfile agent,
    DateTime date,
    int seed,
    String ourClubId,
  ) async {
    final o = ctx.offer;
    final player = ctx.player;
    final names = NegotiationNames(
      player: player.lastName,
      club: ctx.otherName,
    );

    switch (ctx.mode) {
      case NegotiationMode.transferBuy:
        final detail = await _players.detail(player.id);
        final ask = await askingFor(
          player: player,
          contract: detail?.contract,
          now: date,
          seed: seed,
          forUser: true,
          buyerClubId: ourClubId,
        );
        final seller = await profileOf(o.toClubId, seed);
        final squad = await _players.squad(o.toClubId);
        final floorRatio =
            _isIndispensable(player, squad, detail?.contract)
                ? TransferRules.indispensableFloor
                : TransferRules.sellerFloorRatio(
                  seller?.negotiationSkill ?? 50,
                  agent.floorShift,
                );
        final terms = NegotiationOffer(
          amount: o.fee,
          installmentYears: o.installmentYears,
          sellOnPct: o.sellOnPct,
        );
        return AgentNegotiator.open(
          mode: ctx.mode,
          agent: agent,
          anchor: (ask * (1 + agent.openingMargin)).round(),
          limit: (ask * floorRatio).round(),
          agentTerms: terms,
          names: names,
          userOpening: terms,
          remembered: await _remembered(player.id, ctx.mode, agent),
        );

      case NegotiationMode.contract:
        final detail = await _players.detail(player.id);
        if (_shortContractInJanuary(detail?.contract, date)) {
          final reason = const Msg('reason.shortContract').encode();
          await _transfers.updateOffer(
            o.id,
            status: TransferOfferStatus.failed,
            responseDate: date,
            reason: reason,
          );
          throw StateError('${player.fullName}: ${trText(reason)}');
        }
        final expected = DynamicValuation.expectedWage(player);
        // Turun kelas tanpa alasan lain: pemain butuh gaji 15% di atas
        // ekspektasi (PlayerWillingness).
        final movingDown =
            ctx.ours.reputation <= (ctx.other?.reputation ?? 50) - 10 &&
            player.age < 31 &&
            player.morale >= 40;
        final floor = movingDown ? (expected * 1.15).round() : expected;
        final preferred = AgentNegotiator.preferredYears(player.age);
        final current = detail?.contract?.squadStatus ?? SquadStatus.rotation;
        final wanted =
            current == SquadStatus.youth ? SquadStatus.backup : current;
        return AgentNegotiator.open(
          mode: ctx.mode,
          agent: agent,
          anchor: (floor * (1 + agent.openingMargin)).round(),
          limit: floor,
          agentTerms: NegotiationOffer(
            amount: floor,
            contractYears: preferred,
            squadStatus: wanted,
          ),
          names: NegotiationNames(player: player.lastName, club: ctx.ours.name),
          preferredYears: preferred,
          remembered: await _remembered(player.id, ctx.mode, agent),
        );

      case NegotiationMode.transferSell:
        final buyer = await profileOf(o.fromClubId, seed);
        var ratio = agent.ceilingRatio;
        if (buyer?.personality == ClubPersonality.bigSpender) ratio += 0.03;
        if (buyer?.personality == ClubPersonality.survivalMode ||
            buyer?.personality == ClubPersonality.sellingClub) {
          ratio -= 0.03;
        }
        ratio = ratio.clamp(
          TransferRules.minBuyerCeiling,
          TransferRules.maxBuyerCeiling,
        );
        final terms = NegotiationOffer(
          amount: o.fee,
          installmentYears: o.installmentYears,
          sellOnPct: o.sellOnPct,
        );
        final opening = AgentNegotiator.valueOf(ctx.mode, terms, 3);
        var limit = (opening * ratio).round();
        // Pembeli tidak membayar lebih dari anggaran dan saldonya (dihitung
        // untuk cicilan terberat agar nominal tetap muat).
        final other = ctx.other;
        if (other != null) {
          final cash =
              other.transferBudget < other.balance
                  ? other.transferBudget
                  : other.balance;
          final cap = (cash * 0.92).round();
          if (limit > cap) limit = cap;
        }
        if (limit < opening) limit = opening;
        return AgentNegotiator.open(
          mode: ctx.mode,
          agent: agent,
          anchor: opening,
          limit: limit,
          agentTerms: terms,
          names: names,
        );
    }
  }

  /// Ingatan agen dari walk-out sebelumnya: patokan terakhir dan tawaran
  /// terakhir user dipakai lagi saat negosiasi baru dibuka.
  Future<NegotiationSession?> _remembered(
    int playerId,
    NegotiationMode mode,
    AgentProfile agent,
  ) async {
    final row = await _transfers.lastWalkOut(playerId, mode.name);
    if (row == null) return null;
    await _transfers.deleteSession(row.offerId, row.mode);
    return NegotiationSession.fromStored(
      mode: mode,
      agent: agent,
      status: NegotiationStatus.walkedOut,
      patience: row.patience,
      anchor: row.anchorValue,
      limit: row.limitValue,
      extras: row.extras,
    );
  }

  Future<void> _saveSession(
    TransferOffer offer,
    NegotiationSession s,
    DateTime date, {
    DateTime? cooldownUntil,
  }) => _transfers.saveSession(
    NegotiationSessionsCompanion.insert(
      offerId: offer.id,
      mode: s.mode.name,
      playerId: offer.playerId,
      status: s.status.name,
      patience: s.patience,
      anchorValue: s.anchor,
      limitValue: s.limit,
      extras: s.extrasJson(),
      updatedDate: date,
      cooldownUntil: Value(cooldownUntil),
    ),
  );

  /// README F.6: tawaran yang melanggar dana, syarat, atau batas skuad
  /// ditolak sebelum agen menilainya.
  Future<void> _validateNegotiationOffer(
    NegotiationRoom room,
    NegotiationOffer offer,
    String ourClubId,
    DateTime date,
  ) async {
    if (offer.amount <= 0) throw StateError(tr('err.amountPositive'));
    final ours = await _clubs.clubById(ourClubId);
    if (ours == null) throw StateError(tr('err.clubNotFound'));
    switch (room.mode) {
      case NegotiationMode.transferBuy:
        _checkTerms(offer);
        _checkFunds(ours, offer.amount, offer.installmentYears);
      case NegotiationMode.transferSell:
        _checkTerms(offer);
        await _checkCanSell(ourClubId, date);
      case NegotiationMode.contract:
        if (offer.contractYears < 1 || offer.contractYears > 5) {
          throw StateError(tr('err.contractYears'));
        }
        _checkFunds(ours, room.offer.fee, room.offer.installmentYears);
        final squad = await _players.squad(ourClubId);
        if (squad.length >= TransferRules.maxSquad) {
          throw StateError(
            tr('err.squadFull', {'max': TransferRules.maxSquad}),
          );
        }
    }
  }

  void _checkTerms(NegotiationOffer o) {
    if (!TransferRules.validInstallments(o.installmentYears)) {
      throw StateError(tr('err.installments'));
    }
    if (!TransferRules.validSellOn(o.sellOnPct)) {
      throw StateError(tr('err.sellOn'));
    }
  }

  /// Menyimpan jawaban agen dan menjalankan akibatnya: kesepakatan
  /// diteruskan ke transfer/kontrak, walk-out menutup tawaran.
  Future<NegotiationStep> _applyResponse(
    NegotiationRoom room,
    AgentResponse response,
    String ourClubId,
    DateTime date,
  ) async {
    final offer = room.offer;
    final player = room.player;
    final s = response.session;

    switch (response.verdict) {
      case AgentVerdict.counter:
        await _saveSession(offer, s, date);
        return NegotiationStep(response: response, summary: null);

      case AgentVerdict.walkOut:
        final reason =
            Msg('reason.agentWalkedOut', {'agent': room.agent.name}).encode();
        if (room.mode == NegotiationMode.transferSell) {
          await _transfers.deleteSession(offer.id, room.mode.name);
        } else {
          // Jeda 1 minggu; patokan terakhir diingat untuk negosiasi berikutnya.
          await _saveSession(
            offer,
            s,
            date,
            cooldownUntil: _day(date).add(TransferRules.walkOutCooldown),
          );
          if (s.lowballs > 0) await _addLowball();
        }
        await _transfers.updateOffer(
          offer.id,
          status:
              room.mode == NegotiationMode.contract
                  ? TransferOfferStatus.failed
                  : TransferOfferStatus.rejected,
          responseDate: date,
          reason: reason,
        );
        await _inbox.add(
          _info(
            date,
            Msg('msg.failed.title', {'player': player.fullName}),
            room.mode == NegotiationMode.transferSell
                ? Msg('msg.failed.buyerLeft', {
                  'club': room.counterpartName,
                  'player': player.fullName,
                })
                : Msg('msg.failed.cooldown', {
                  'reason': asMsg(reason),
                  'player': player.fullName,
                }),
            payload:
                (await _offerNews(
                  offer,
                  player,
                  TransferNewsStatus.failed,
                )).encode(),
          ),
        );
        return NegotiationStep(response: response, summary: trText(reason));

      case AgentVerdict.accept:
        final deal = response.agreedOffer!;
        await _transfers.deleteSession(offer.id, room.mode.name);
        switch (room.mode) {
          case NegotiationMode.transferBuy:
            await _transfers.updateOffer(
              offer.id,
              status: TransferOfferStatus.countered,
              responseDate: date,
              fee: deal.amount,
              installmentYears: deal.installmentYears,
              sellOnPct: deal.sellOnPct,
            );
            final terms = termsMsg(
              deal.amount,
              deal.installmentYears,
              deal.sellOnPct,
            );
            await _acceptFee(
              offer,
              player,
              date,
              Msg('msg.agreedWithAgent', {
                'agent': room.agent.name,
                'terms': terms,
              }),
            );
            return NegotiationStep(
              response: response,
              summary: tr('step.feeAgreed'),
            );
          case NegotiationMode.transferSell:
            await _completeTransfer(
              player: player,
              buyerId: offer.fromClubId,
              sellerId: ourClubId,
              fee: deal.amount,
              date: date,
              type: TransferType.sell,
              offerId: offer.id,
              installmentYears: deal.installmentYears,
              sellOnPct: deal.sellOnPct,
            );
            return NegotiationStep(
              response: response,
              summary: tr('step.playerSold'),
            );
          case NegotiationMode.contract:
            final value = AgentNegotiator.valueOf(
              room.mode,
              deal,
              s.preferredYears,
            );
            final refusal = await _contractRefusal(
              offer,
              player,
              value,
              ourClubId,
              date,
            );
            if (refusal != null) {
              await _transfers.updateOffer(
                offer.id,
                status: TransferOfferStatus.failed,
                responseDate: date,
                reason: refusal,
              );
              await _inbox.add(
                _info(
                  date,
                  Msg('msg.failed.title', {'player': player.fullName}),
                  asMsg(refusal),
                  payload:
                      (await _offerNews(
                        offer,
                        player,
                        TransferNewsStatus.failed,
                      )).encode(),
                ),
              );
              return NegotiationStep(
                response: response,
                summary: trText(refusal),
              );
            }
            await _completeTransfer(
              player: player,
              buyerId: ourClubId,
              sellerId: offer.toClubId,
              fee: offer.fee,
              date: date,
              type: TransferType.buy,
              wage: deal.amount,
              years: deal.contractYears,
              squadStatus: deal.squadStatus,
              offerId: offer.id,
              installmentYears: offer.installmentYears,
              sellOnPct: offer.sellOnPct,
            );
            return NegotiationStep(
              response: response,
              summary: tr('step.joined', {'player': player.fullName}),
            );
        }
    }
  }

  /// Alasan pemain menolak kontrak (null = mau). [effectiveWage] adalah gaji
  /// setelah memperhitungkan peran dan durasi.
  Future<String?> _contractRefusal(
    TransferOffer offer,
    Player player,
    int effectiveWage,
    String ourClubId,
    DateTime date,
  ) async {
    final ours = await _clubs.clubById(ourClubId);
    final from = await _clubs.clubById(offer.toClubId);
    final detail = await _players.detail(player.id);
    final will = PlayerWillingness.decide(
      player: player,
      fromRep: from?.reputation ?? 50,
      toRep: ours?.reputation ?? 50,
      wageOffer: effectiveWage,
      expectedWage: DynamicValuation.expectedWage(player),
      isBenchPlayer:
          detail?.contract?.squadStatus == SquadStatus.backup ||
          detail?.contract?.squadStatus == SquadStatus.youth,
      shortContractInJanuary: _shortContractInJanuary(detail?.contract, date),
    );
    return will.willing ? null : will.reason;
  }

  /// Batas skuad minimum dan batas pemain keluar per jendela.
  Future<void> _checkCanSell(String ourClubId, DateTime date) async {
    final squad = await _players.squad(ourClubId);
    if (squad.length <= TransferRules.minSquad) {
      throw StateError(tr('err.squadMin', {'min': TransferRules.minSquad}));
    }
    final start = TransferRules.windowStart(date);
    if (start != null) {
      final moves = await _transfers.movesSince(ourClubId, start);
      if (moves.outgoing >= TransferRules.maxMovesPerWindow) {
        throw StateError(
          tr('err.maxOutgoing', {'n': TransferRules.maxMovesPerWindow}),
        );
      }
    }
  }

  /// Negosiasi kontrak: gaji & durasi. Pemain menolak bila gaji di bawah
  /// ekspektasi atau kemauannya tidak terpenuhi (README B.10.4).
  Future<void> _negotiateContract(
    TransferOffer offer,
    Player player,
    String choice,
    DateTime date,
    String ourClubId,
  ) async {
    if (choice == 'cancel') {
      await _transfers.updateOffer(
        offer.id,
        status: TransferOfferStatus.withdrawn,
        responseDate: date,
        reason: const Msg('reason.cancelledByUs').encode(),
      );
      return;
    }
    final parsed = _parseNegotiation(choice);
    if (parsed == null) {
      throw StateError(tr('err.wageAndYears'));
    }
    final ours = await _clubs.clubById(ourClubId);
    if (ours == null) throw StateError(tr('err.clubNotFound'));
    _checkFunds(ours, offer.fee, offer.installmentYears);
    final squad = await _players.squad(ourClubId);
    if (squad.length >= TransferRules.maxSquad) {
      throw StateError(tr('err.squadFull', {'max': TransferRules.maxSquad}));
    }

    final expected = DynamicValuation.expectedWage(player);
    final detail = await _players.detail(player.id);
    final from = await _clubs.clubById(offer.toClubId);
    final will = PlayerWillingness.decide(
      player: player,
      fromRep: from?.reputation ?? 50,
      toRep: ours.reputation,
      wageOffer: parsed.wage,
      expectedWage: expected,
      isBenchPlayer:
          detail?.contract?.squadStatus == SquadStatus.backup ||
          detail?.contract?.squadStatus == SquadStatus.youth,
      shortContractInJanuary: _shortContractInJanuary(detail?.contract, date),
    );
    if (parsed.wage < expected || !will.willing) {
      final reason =
          will.reason ??
          Msg('reason.contractRefused', {
            'player': player.fullName,
            'wage': Msg.money(parsed.wage),
            'expected': Msg.money(expected),
          }).encode();
      await _transfers.updateOffer(
        offer.id,
        status: TransferOfferStatus.failed,
        responseDate: date,
        reason: reason,
      );
      await _inbox.add(
        _info(
          date,
          Msg('msg.failed.title', {'player': player.fullName}),
          asMsg(reason),
          payload:
              (await _offerNews(
                offer,
                player,
                TransferNewsStatus.failed,
              )).encode(),
        ),
      );
      return;
    }
    await _completeTransfer(
      player: player,
      buyerId: ourClubId,
      sellerId: offer.toClubId,
      fee: offer.fee,
      date: date,
      type: TransferType.buy,
      wage: parsed.wage,
      years: parsed.years,
      offerId: offer.id,
      installmentYears: offer.installmentYears,
      sellOnPct: offer.sellOnPct,
    );
  }

  bool _shortContractInJanuary(Contract? c, DateTime date) {
    if (c == null || date.month != 1) return false;
    return c.endDate.difference(date).inDays <= 183;
  }

  // --- Penyelesaian transfer ----------------------------------------------------

  /// Memindahkan pemain, memindahkan dana, mengunci pemain sampai jendela
  /// berikutnya, mencatat riwayat, dan membatalkan tawaran lain untuk pemain
  /// yang sama. Dipakai juga oleh bursa AI.
  Future<void> completeTransfer({
    required Player player,
    required String buyerId,
    required String sellerId,
    required int fee,
    required int wage,
    required int years,
    required DateTime date,
    required TransferType type,
    int? offerId,
  }) => _completeTransfer(
    player: player,
    buyerId: buyerId,
    sellerId: sellerId,
    fee: fee,
    date: date,
    type: type,
    wage: wage,
    years: years,
    offerId: offerId,
  );

  Future<void> _completeTransfer({
    required Player player,
    required String buyerId,
    required String sellerId,
    required int fee,
    required DateTime date,
    required TransferType type,
    int? wage,
    int? years,
    int? offerId,
    int installmentYears = 1,
    int sellOnPct = 0,
    SquadStatus squadStatus = SquadStatus.rotation,
  }) async {
    final sellerName = (await _clubs.clubById(sellerId))?.name ?? sellerId;
    final buyerName = (await _clubs.clubById(buyerId))?.name ?? buyerId;
    final detail = await _players.detail(player.id);
    final newWage =
        wage ?? detail?.contract?.wage ?? DynamicValuation.expectedWage(player);
    final newYears = years ?? 3;
    final newEndDate = DateTime.utc(date.year + newYears, 6, 30);
    final upfront = TransferRules.upfront(fee, installmentYears);
    final sellOns = await _transfers.memoryWithPrefix('sellon|${player.id}|');
    await _db.transaction(() async {
      // Anggaran transfer menanggung biaya penuh; saldo hanya cicilan pertama.
      await _transfers.adjustFinance(
        buyerId,
        balanceDelta: -upfront,
        transferBudgetDelta: -fee,
      );
      await _transfers.adjustFinance(sellerId, balanceDelta: upfront);
      if (installmentYears > 1) {
        final perYear = (fee - upfront) ~/ (installmentYears - 1);
        await _transfers.setMemory(
          'inst|$buyerId|$sellerId|$perYear|${player.id}-${date.millisecondsSinceEpoch}',
          installmentYears - 1,
        );
      }
      // Sell-on clause lama: klub asal mendapat bagian dari penjualan ini.
      for (final entry in sellOns.entries) {
        final origin = entry.key.split('|').last;
        await _transfers.deleteMemory(entry.key);
        if (origin == buyerId) continue;
        final share = fee * entry.value ~/ 100;
        await _transfers.adjustFinance(sellerId, balanceDelta: -share);
        await _transfers.adjustFinance(origin, balanceDelta: share);
      }
      if (sellOnPct > 0) {
        await _transfers.setMemory('sellon|${player.id}|$sellerId', sellOnPct);
      }
      await _players.moveToClub(
        playerId: player.id,
        clubId: buyerId,
        wage: newWage,
        endDate: newEndDate,
        squadStatus: squadStatus,
      );
      await _players.setLockedUntil(player.id, _nextWindowOpen(date));
      await _transfers.withdrawActiveOffers(player.id, exceptId: offerId);
      if (offerId != null) {
        await _transfers.updateOffer(
          offerId,
          status: TransferOfferStatus.completed,
          responseDate: date,
        );
      }
      await _transfers.addHistory(
        TransferRecord(
          id: 0,
          date: date,
          playerId: player.id,
          playerName: player.fullName,
          fromClubId: sellerId,
          toClubId: buyerId,
          fee: fee,
          type: type,
        ),
      );
      await _inbox.add(
        _info(
          date,
          Msg('msg.completed.title', {'player': player.fullName}),
          Msg('msg.completed.body', {
            'player': player.fullName,
            'from': sellerName,
            'to': buyerName,
            'terms': termsMsg(fee, installmentYears, sellOnPct),
          }),
          payload:
              TransferNewsPayload(
                playerId: player.id,
                playerName: player.fullName,
                fromClubId: sellerId,
                toClubId: buyerId,
                status: TransferNewsStatus.completed,
                transferType: type,
                fee: fee,
                installmentYears: installmentYears,
                sellOnPct: sellOnPct,
                contractYears: newYears,
                contractEndDate: newEndDate,
                wage: newWage,
                squadStatus: squadStatus,
                offerId: offerId,
              ).encode(),
        ),
      );
    });
  }

  /// Cicilan transfer jatuh tempo setiap 1 Juli.
  Future<void> payDueInstallments(DateTime date) async {
    if (date.month != 7 || date.day != 1) return;
    final due = await _transfers.memoryWithPrefix('inst|');
    for (final entry in due.entries) {
      final parts = entry.key.split('|');
      if (parts.length < 4) continue;
      final buyer = parts[1];
      final seller = parts[2];
      final amount = int.tryParse(parts[3]) ?? 0;
      await _transfers.adjustFinance(buyer, balanceDelta: -amount);
      await _transfers.adjustFinance(seller, balanceDelta: amount);
      if (entry.value <= 1) {
        await _transfers.deleteMemory(entry.key);
      } else {
        await _transfers.setMemory(entry.key, entry.value - 1);
      }
    }
  }

  /// Jendela transfer berikutnya yang akan dibuka setelah [date].
  static DateTime _nextWindowOpen(DateTime date) {
    final status = TransferWindow.status(date);
    if (status.isOpen) {
      final after = status.closesOn!.add(const Duration(days: 1));
      return TransferWindow.status(after).nextOpensOn ?? after;
    }
    return status.nextOpensOn!;
  }

  /// Teks syarat tawaran, mis. "€12,0 jt (cicilan 3 thn, sell-on 20%)".
  static String termsLabel(int fee, int installmentYears, int sellOnPct) =>
      termsMsg(fee, installmentYears, sellOnPct).resolve();

  /// [termsLabel] sebagai [Msg] untuk teks yang disimpan.
  static Msg termsMsg(int fee, int installmentYears, int sellOnPct) {
    final extras = [
      if (installmentYears > 1)
        Msg('terms.installments', {'n': installmentYears}),
      if (sellOnPct > 0) Msg('terms.sellOn', {'pct': sellOnPct}),
    ];
    if (extras.isEmpty) return Msg.money(fee);
    return Msg('terms.withExtras', {
      'fee': Msg.money(fee),
      'extras': Msg.join(extras, separator: ', '),
    });
  }

  static DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  InboxMessage _info(DateTime date, Msg title, Msg body, {String? payload}) =>
      InboxMessage(
        id: 0,
        date: date,
        category: InboxCategory.transfer,
        title: title.encode(),
        body: body.encode(),
        isRead: false,
        actionType: InboxActionType.none,
        payload: payload,
        resolved: false,
        choice: null,
      );

  /// Rincian berita untuk tawaran [o] (pemain pindah dari klub penjual
  /// `o.toClubId` ke klub penawar `o.fromClubId`). Kontrak yang dicatat =
  /// kontrak pemain saat ini.
  Future<TransferNewsPayload> _offerNews(
    TransferOffer o,
    Player player,
    TransferNewsStatus status, {
    int? minWage,
  }) => _currentContractNews(
    player,
    fromClubId: o.toClubId,
    toClubId: o.fromClubId,
    status: status,
    fee: o.fee,
    installmentYears: o.installmentYears,
    sellOnPct: o.sellOnPct,
    offerId: o.id,
    minWage: minWage,
  );

  Future<TransferNewsPayload> _currentContractNews(
    Player player, {
    required String fromClubId,
    required String toClubId,
    required TransferNewsStatus status,
    required int fee,
    int installmentYears = 1,
    int sellOnPct = 0,
    int? offerId,
    int? minWage,
  }) async {
    final contract = (await _players.detail(player.id))?.contract;
    return TransferNewsPayload(
      playerId: player.id,
      playerName: player.fullName,
      fromClubId: fromClubId,
      toClubId: toClubId,
      status: status,
      fee: fee,
      installmentYears: installmentYears,
      sellOnPct: sellOnPct,
      contractEndDate: contract?.endDate,
      wage: contract?.wage,
      squadStatus: contract?.squadStatus,
      offerId: offerId,
      minWage: minWage,
    );
  }

  /// Payload pesan transfer: "offer:ID", "offer:ID|min:GAJI", atau
  /// dengan rincian berita "offer:ID|tx:{...}".
  static int? _offerIdOf(String? payload) =>
      TransferNewsPayload.offerIdOf(payload);

  /// Format pilihan negosiasi: "wage:GAJI|years:TAHUN".
  static ({int wage, int years})? _parseNegotiation(String choice) {
    final parts = {
      for (final kv in choice.split('|'))
        if (kv.contains(':')) kv.split(':').first: kv.split(':').last,
    };
    final wage = int.tryParse(parts['wage'] ?? '');
    final years = int.tryParse(parts['years'] ?? '');
    if (wage == null || wage <= 0 || years == null || years < 1 || years > 5) {
      return null;
    }
    return (wage: wage, years: years);
  }
}

/// Data yang dibutuhkan untuk membuka atau melanjutkan satu sesi.
class _RoomContext {
  const _RoomContext({
    required this.offer,
    required this.mode,
    required this.player,
    required this.ours,
    required this.other,
    required this.otherName,
  });

  final TransferOffer offer;
  final NegotiationMode mode;
  final Player player;
  final Club ours;
  final Club? other;
  final String otherName;

  NegotiationRoom room(NegotiationSession session) => NegotiationRoom(
    offer: offer,
    player: player,
    session: session,
    counterpartName: otherName,
    transferBudget: ours.transferBudget,
    balance: ours.balance,
    expectedWage: DynamicValuation.expectedWage(player),
  );
}
