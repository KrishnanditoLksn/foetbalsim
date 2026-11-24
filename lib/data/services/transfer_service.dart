import '../../domain/enums/inbox.dart';
import '../../domain/enums/squad_status.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/club_ai_profile.dart';
import '../../domain/transfer/interest_engine.dart';
import '../../domain/transfer/market_heat.dart';
import '../../domain/transfer/negotiation_ai.dart';
import '../../domain/transfer/player_willingness.dart';
import '../../domain/transfer/transfer_rules.dart';
import '../../domain/transfer/transfer_window.dart';
import '../../domain/transfer/valuation.dart';
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
    var ask = DynamicValuation.askingFee(
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
    if (buyerClubId != null && TransferRules.areRivals(buyerClubId, player.clubId)) {
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
    if (player == null) throw StateError('Pemain tidak ditemukan.');
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
  Future<void> _checkCanBid(Player player, String ourClubId, DateTime now) async {
    if (!TransferWindow.isOpen(now)) {
      throw StateError('Jendela transfer sedang tertutup.');
    }
    if (player.clubId == ourClubId) {
      throw StateError('Pemain ini sudah bersama klub Anda.');
    }
    if (player.lockedUntil != null && player.lockedUntil!.isAfter(now)) {
      throw StateError(
        'Pemain baru pindah klub dan terkunci sampai jendela berikutnya.',
      );
    }
    final active = await _transfers.activeOffersForPlayer(player.id);
    if (active.any((o) => o.fromClubId == ourClubId)) {
      throw StateError('Sudah ada negosiasi berjalan untuk pemain ini.');
    }
    final squad = await _players.squad(ourClubId);
    if (squad.length >= TransferRules.maxSquad) {
      throw StateError(
        'Skuad penuh (maks ${TransferRules.maxSquad} pemain). Jual pemain dulu.',
      );
    }
    final start = TransferRules.windowStart(now)!;
    final moves = await _transfers.movesSince(ourClubId, start);
    if (moves.incoming >= TransferRules.maxMovesPerWindow) {
      throw StateError(
        'Batas ${TransferRules.maxMovesPerWindow} pemain masuk per jendela tercapai.',
      );
    }
  }

  /// Validasi dana: anggaran transfer menanggung biaya penuh, saldo harus
  /// cukup untuk pembayaran di muka (cicilan pertama).
  void _checkFunds(Club ours, int fee, int installmentYears) {
    if (fee > ours.transferBudget) {
      throw StateError(
        'Anggaran transfer tidak cukup (sisa ${moneyLabel(ours.transferBudget)}).',
      );
    }
    final upfront = TransferRules.upfront(fee, installmentYears);
    if (upfront > ours.balance) {
      throw StateError(
        'Saldo klub tidak cukup untuk pembayaran di muka ${moneyLabel(upfront)}.',
      );
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
    if (player == null) throw StateError('Pemain tidak ditemukan.');
    await _checkCanBid(player, ourClubId, now);
    if (fee <= 0) throw StateError('Nominal tawaran harus lebih dari nol.');
    if (!TransferRules.validInstallments(installmentYears)) {
      throw StateError('Cicilan hanya bisa langsung, 2, atau 3 tahun.');
    }
    if (!TransferRules.validSellOn(sellOnPct)) {
      throw StateError('Sell-on clause hanya 0% atau 10–30%.');
    }
    final ours = await _clubs.clubById(ourClubId);
    if (ours == null) throw StateError('Klub tidak ditemukan.');
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
    await _inbox.add(
      _info(
        now,
        'Tawaran dikirim: ${player.fullName}',
        'Tawaran ${termsLabel(fee, installmentYears, sellOnPct)} untuk '
            '${player.fullName} dikirim ke ${seller?.name ?? player.clubId}. '
            'Respons dalam $days hari.',
        payload: 'offer:$offerId',
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
    for (final (clubId, score, level) in await _transfers.interestsForPlayer(playerId)) {
      final club = await _clubs.clubById(clubId);
      list.add(
        PlayerInterest(
          clubId: clubId,
          clubName: club?.name ?? clubId,
          score: score,
          levelLabel: switch (level) {
            InterestLevel.target => 'Target utama',
            InterestLevel.interested => 'Tertarik',
            InterestLevel.watching => 'Memantau',
            InterestLevel.none => '-',
          },
        ),
      );
    }
    return list;
  }

  // --- Respons klub penjual atas tawaran kita -----------------------------------

  /// Mengevaluasi tawaran kita yang sudah jatuh tempo. Ronde 1 bisa diterima,
  /// dikontra, atau ditolak; ronde 3 (tawaran final) hanya diterima atau
  /// ditolak. Dipanggil setiap hari.
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
          reason: 'Pemain sudah pindah klub.',
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
      final isFinal = o.round >= TransferRules.maxRounds;
      // Tawaran final dinilai terhadap kontra penjual sendiri: diterima bila
      // ≥ 97% dari kontra, sehingga penjual konsisten dengan permintaannya.
      var reference = ask;
      if (isFinal) {
        final counter = await _transfers.memory('counter|${o.id}');
        await _transfers.deleteMemory('counter|${o.id}');
        if (counter > 0) {
          reference = TransferRules.offerValue(
            fee: counter,
            installmentYears: o.installmentYears,
            sellOnPct: o.sellOnPct,
          );
        }
      }
      final result = NegotiationAi.evaluate(
        offer: value,
        ask: reference,
        seller: seller!,
        isIndispensable: indispensable && !isFinal,
        round: isFinal ? 2 : 1,
      );
      final sellerName = (await _clubs.clubById(o.toClubId))?.name ?? o.toClubId;
      final terms = termsLabel(o.fee, o.installmentYears, o.sellOnPct);

      switch (result.verdict) {
        case NegotiationVerdict.accept:
          await _acceptFee(o, player, date, '$sellerName menerima tawaran $terms.');
        case NegotiationVerdict.counter:
          // Harga kontra dinyatakan dengan syarat pembayaran yang sama.
          final factor = TransferRules.termsFactor(
            installmentYears: o.installmentYears,
            sellOnPct: o.sellOnPct,
          );
          final counterFee = ((result.counterFee! / factor) / 10).round() * 10;
          await _transfers.updateOffer(
            o.id,
            status: TransferOfferStatus.countered,
            responseDate: date,
            fee: counterFee,
            round: 2,
          );
          await _inbox.add(
            InboxMessage(
              id: 0,
              date: date,
              category: InboxCategory.transfer,
              title: 'Kontra-tawaran: ${player.fullName}',
              body: '$sellerName meminta '
                  '${termsLabel(counterFee, o.installmentYears, o.sellOnPct)} '
                  'untuk ${player.fullName} (tawaran Anda $terms). '
                  'Terima harga ini, ajukan satu tawaran final, atau batalkan.',
              isRead: false,
              actionType: InboxActionType.counterOffer,
              payload: 'offer:${o.id}',
              resolved: false,
              choice: null,
            ),
          );
        case NegotiationVerdict.reject:
          if (value < ask * TransferRules.rejectBelow) {
            await _transfers.setMemory(
              'lowballCount',
              await _transfers.memory('lowballCount') + 1,
            );
          }
          final reason = result.reason ??
              (isFinal ? 'Tawaran final ditolak.' : 'Tawaran ditolak.');
          await _transfers.updateOffer(
            o.id,
            status: TransferOfferStatus.rejected,
            responseDate: date,
            reason: reason,
          );
          await _inbox.add(
            _info(
              date,
              'Tawaran ditolak: ${player.fullName}',
              '$sellerName menolak tawaran $terms. $reason',
            ),
          );
      }
    }
  }

  /// Harga disepakati klub penjual: lanjut ke negosiasi kontrak pemain.
  Future<void> _acceptFee(
    TransferOffer o,
    Player player,
    DateTime date,
    String lead,
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
        title: 'Harga disepakati: ${player.fullName}',
        body: '$lead ${player.fullName} mengharapkan gaji minimal '
            '${moneyLabel(wage)}/tahun. Ajukan kontrak untuk menyelesaikan '
            'transfer.',
        isRead: false,
        actionType: InboxActionType.contractNegotiation,
        payload: 'offer:${o.id}|min:$wage',
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
    final sameGroup = squad
        .where((s) => s.id != p.id && s.position.group == p.position.group)
        .toList();
    return sameGroup.length < 2;
  }

  // --- Keputusan user ---------------------------------------------------------------

  /// Menyelesaikan aksi transfer dari inbox atau tab Negosiasi.
  ///
  /// Pilihan:
  /// - tawaran masuk: `accept`, `reject`, `counter:HARGA`
  /// - kontra-tawaran: `accept`, `final:HARGA`, `cancel`
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
      throw StateError('Negosiasi ini sudah tidak berjalan.');
    }
    final player = await _players.byId(offer.playerId);
    if (player == null) throw StateError('Pemain tidak ditemukan.');

    if (offer.toClubId == ourClubId) {
      await _answerIncoming(offer, player, choice, date, ourClubId);
    } else if (offer.status == TransferOfferStatus.countered) {
      await _answerCounter(offer, player, choice, date, ourClubId);
    } else if (offer.status == TransferOfferStatus.awaitingContract) {
      await _negotiateContract(offer, player, choice, date, ourClubId);
    } else {
      throw StateError('Menunggu respons klub penjual.');
    }
  }

  /// Jawaban atas kontra-tawaran penjual: terima, satu tawaran final, atau batal.
  Future<void> _answerCounter(
    TransferOffer offer,
    Player player,
    String choice,
    DateTime date,
    String ourClubId,
  ) async {
    final ours = await _clubs.clubById(ourClubId);
    if (ours == null) throw StateError('Klub tidak ditemukan.');
    if (choice == 'accept') {
      _checkFunds(ours, offer.fee, offer.installmentYears);
      await _acceptFee(
        offer,
        player,
        date,
        'Anda menerima harga '
            '${termsLabel(offer.fee, offer.installmentYears, offer.sellOnPct)}.',
      );
      return;
    }
    if (choice.startsWith('final:')) {
      final fee = int.tryParse(choice.substring('final:'.length)) ?? 0;
      if (fee <= 0) throw StateError('Nominal tawaran final harus lebih dari nol.');
      if (fee >= offer.fee) {
        // Tawaran final tidak lebih rendah dari kontra = menerima kontra.
        await _answerCounter(offer, player, 'accept', date, ourClubId);
        return;
      }
      _checkFunds(ours, fee, offer.installmentYears);
      // Kontra penjual disimpan: tawaran final dinilai terhadap kontra ini.
      await _transfers.setMemory('counter|${offer.id}', offer.fee);
      await _transfers.updateOffer(
        offer.id,
        status: TransferOfferStatus.pending,
        responseDate: _day(date).add(const Duration(days: 1)),
        fee: fee,
        round: TransferRules.maxRounds,
      );
      await _inbox.add(
        _info(
          date,
          'Tawaran final dikirim: ${player.fullName}',
          'Tawaran final '
              '${termsLabel(fee, offer.installmentYears, offer.sellOnPct)} '
              'dikirim. Ini ronde terakhir: penjual akan menerima atau menolak.',
          payload: 'offer:${offer.id}',
        ),
      );
      return;
    }
    await _transfers.updateOffer(
      offer.id,
      status: TransferOfferStatus.withdrawn,
      responseDate: date,
      reason: 'Dibatalkan oleh klub Anda.',
    );
  }

  /// Tawaran masuk dari klub AI untuk pemain kita: terima, tolak, atau
  /// kontra ('counter:HARGA'). Kontra diterima bila tidak melebihi tawaran
  /// pembeli lebih dari 5%.
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
        reason: 'Ditolak oleh klub Anda.',
      );
      return;
    }
    var fee = offer.fee;
    if (choice.startsWith('counter:')) {
      final asked = int.tryParse(choice.substring('counter:'.length)) ?? 0;
      if (asked <= 0) throw StateError('Nominal harga harus lebih dari nol.');
      if (asked > (offer.fee * TransferRules.counterTolerance).round()) {
        final buyer = (await _clubs.clubById(offer.fromClubId))?.name ?? offer.fromClubId;
        await _transfers.updateOffer(
          offer.id,
          status: TransferOfferStatus.rejected,
          responseDate: date,
          reason: '$buyer tidak mau membayar ${moneyLabel(asked)}.',
        );
        await _inbox.add(
          _info(
            date,
            'Kontra ditolak: ${player.fullName}',
            '$buyer tidak mau membayar ${moneyLabel(asked)} dan mundur dari negosiasi.',
          ),
        );
        return;
      }
      fee = asked;
    } else if (choice != 'accept') {
      return;
    }
    await _checkCanSell(ourClubId, date);
    await _completeTransfer(
      player: player,
      buyerId: offer.fromClubId,
      sellerId: ourClubId,
      fee: fee,
      date: date,
      type: TransferType.sell,
      offerId: offer.id,
      installmentYears: offer.installmentYears,
      sellOnPct: offer.sellOnPct,
    );
  }

  /// Batas skuad minimum dan batas pemain keluar per jendela.
  Future<void> _checkCanSell(String ourClubId, DateTime date) async {
    final squad = await _players.squad(ourClubId);
    if (squad.length <= TransferRules.minSquad) {
      throw StateError(
        'Skuad minimal ${TransferRules.minSquad} pemain. Rekrut pemain dulu.',
      );
    }
    final start = TransferRules.windowStart(date);
    if (start != null) {
      final moves = await _transfers.movesSince(ourClubId, start);
      if (moves.outgoing >= TransferRules.maxMovesPerWindow) {
        throw StateError(
          'Batas ${TransferRules.maxMovesPerWindow} pemain keluar per jendela tercapai.',
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
        reason: 'Dibatalkan oleh klub Anda.',
      );
      return;
    }
    final parsed = _parseNegotiation(choice);
    if (parsed == null) {
      throw StateError('Isi gaji (lebih dari nol) dan durasi 1–5 tahun.');
    }
    final ours = await _clubs.clubById(ourClubId);
    if (ours == null) throw StateError('Klub tidak ditemukan.');
    _checkFunds(ours, offer.fee, offer.installmentYears);
    final squad = await _players.squad(ourClubId);
    if (squad.length >= TransferRules.maxSquad) {
      throw StateError('Skuad penuh (maks ${TransferRules.maxSquad} pemain).');
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
      isBenchPlayer: detail?.contract?.squadStatus == SquadStatus.backup ||
          detail?.contract?.squadStatus == SquadStatus.youth,
      shortContractInJanuary: _shortContractInJanuary(detail?.contract, date),
    );
    if (parsed.wage < expected || !will.willing) {
      final reason = will.reason ??
          '${player.fullName} menolak kontrak ${moneyLabel(parsed.wage)}/tahun. '
              'Ia menginginkan minimal ${moneyLabel(expected)}/tahun.';
      await _transfers.updateOffer(
        offer.id,
        status: TransferOfferStatus.failed,
        responseDate: date,
        reason: reason,
      );
      await _inbox.add(_info(date, 'Negosiasi gagal: ${player.fullName}', reason));
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
  }) async {
    final sellerName = (await _clubs.clubById(sellerId))?.name ?? sellerId;
    final buyerName = (await _clubs.clubById(buyerId))?.name ?? buyerId;
    final detail = await _players.detail(player.id);
    final newWage = wage ?? detail?.contract?.wage ?? DynamicValuation.expectedWage(player);
    final newYears = years ?? 3;
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
        endDate: DateTime.utc(date.year + newYears, 6, 30),
        squadStatus: SquadStatus.rotation,
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
          'Transfer selesai: ${player.fullName}',
          '${player.fullName} pindah dari $sellerName ke $buyerName dengan '
              '${termsLabel(fee, installmentYears, sellOnPct)}.',
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
  static String termsLabel(int fee, int installmentYears, int sellOnPct) {
    final extras = [
      if (installmentYears > 1) 'cicilan $installmentYears thn',
      if (sellOnPct > 0) 'sell-on $sellOnPct%',
    ];
    return extras.isEmpty
        ? moneyLabel(fee)
        : '${moneyLabel(fee)} (${extras.join(', ')})';
  }

  static DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  InboxMessage _info(
    DateTime date,
    String title,
    String body, {
    String? payload,
  }) => InboxMessage(
    id: 0,
    date: date,
    category: InboxCategory.transfer,
    title: title,
    body: body,
    isRead: false,
    actionType: InboxActionType.none,
    payload: payload,
    resolved: false,
    choice: null,
  );

  /// Payload pesan transfer: "offer:ID" atau "offer:ID|min:GAJI".
  static int? _offerIdOf(String? payload) {
    if (payload == null || !payload.startsWith('offer:')) return null;
    final head = payload.split('|').first;
    return int.tryParse(head.substring('offer:'.length));
  }

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
