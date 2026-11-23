import '../../core/rng/seeded_random.dart';
import '../../domain/enums/inbox.dart';
import '../../domain/enums/squad_status.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/transfer_window.dart';
import '../database/app_database.dart';
import '../repositories/club_repository.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/transfer_repository.dart';

/// Tawaran & aktivitas bursa: ajukan tawaran, evaluasi AI, negosiasi kontrak,
/// tawaran masuk untuk pemain yang didaftar jual, dan transfer antar-klub AI.
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

  static const double aiDealChance = 0.12; // per hari, saat bursa buka
  static const double incomingChance = 0.10; // per pemain daftar jual/hari
  static const int minSquadForSale = 19;

  // --- Aksi pemain -----------------------------------------------------------

  /// Mengajukan tawaran untuk pemain klub lain. Dana belum berpindah sampai
  /// transfer selesai; validasi anggaran dilakukan di sini.
  Future<void> placeBid({
    required String ourClubId,
    required DateTime now,
    required int playerId,
    required int fee,
  }) async {
    if (!TransferWindow.isOpen(now)) {
      throw StateError('Jendela transfer sedang tertutup.');
    }
    final player = await _players.byId(playerId);
    if (player == null) throw StateError('Pemain tidak ditemukan.');
    if (player.clubId == ourClubId) {
      throw StateError('Pemain ini sudah bersama klub Anda.');
    }
    if (fee <= 0) throw StateError('Nominal tawaran harus lebih dari nol.');

    final ours = await _clubs.clubById(ourClubId);
    if (ours == null) throw StateError('Klub tidak ditemukan.');
    if (fee > ours.transferBudget) {
      throw StateError('Anggaran transfer tidak cukup.');
    }
    if (fee > ours.balance) {
      throw StateError('Saldo klub tidak cukup untuk tawaran ini.');
    }

    final active = await _transfers.activeOffersForPlayer(playerId);
    if (active.any((o) => o.fromClubId == ourClubId)) {
      throw StateError('Sudah ada tawaran aktif untuk pemain ini.');
    }

    final seller = await _clubs.clubById(player.clubId);
    // Respons klub penjual 1–2 hari, ditentukan dari data (deterministik).
    final days = 1 + (playerId + fee) % 2;
    final response = DateTime.utc(now.year, now.month, now.day)
        .add(Duration(days: days));
    final offerId = await _transfers.insertOffer(
      playerId: playerId,
      fromClubId: ourClubId,
      toClubId: player.clubId,
      fee: fee,
      status: TransferOfferStatus.pending,
      createdDate: now,
      responseDate: response,
    );
    await _inbox.add(
      InboxMessage(
        id: 0,
        date: now,
        category: InboxCategory.transfer,
        title: 'Tawaran dikirim: ${player.fullName}',
        body:
            'Tawaran ${moneyLabel(fee)} untuk ${player.fullName} dikirim ke '
            '${seller?.name ?? player.clubId}. Respons dalam $days hari.'
            ' (tawaran #$offerId)',
        isRead: false,
        actionType: InboxActionType.none,
        payload: 'offer:$offerId',
        resolved: false,
        choice: null,
      ),
    );
  }

  Future<void> setListed(int playerId, bool listed) =>
      _players.setListed(playerId, listed);

  Future<void> setShortlisted(int playerId, bool value, DateTime now) =>
      _transfers.setShortlisted(playerId, value, now);

  // --- Harian ----------------------------------------------------------------

  /// Dipanggil engine setiap hari: respons tawaran, tawaran masuk, dan
  /// aktivitas AI. Aktivitas AI hanya terjadi saat jendela transfer buka.
  Future<void> processDay({
    required DateTime date,
    required int seed,
    required String ourClubId,
  }) async {
    await _resolveDueOffers(date);
    if (!TransferWindow.isOpen(date)) return;

    final rng = SeededRandom(_dayKeySeed(seed, date));
    await _incomingOffers(date, ourClubId, rng);
    await _aiDeal(date, ourClubId, rng);
  }

  Future<void> _resolveDueOffers(DateTime date) async {
    for (final o in await _transfers.dueOffers(date)) {
      final player = await _players.byId(o.playerId);
      if (player == null || player.clubId != o.toClubId) {
        await _transfers.updateOffer(
          o.id,
          status: TransferOfferStatus.withdrawn,
          responseDate: date,
        );
        continue;
      }
      final detail = await _players.detail(player.id);
      final ask = TransferValuation.askingFee(
        player: player,
        contract: detail?.contract,
        now: date,
      );
      final sellerName = await _clubName(o.toClubId);
      if (TransferValuation.fairFee(o.fee, ask)) {
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
            title: 'Tawaran diterima: ${player.fullName}',
            body:
                '$sellerName menerima tawaran '
                '${moneyLabel(o.fee)}. Pemain mengharapkan gaji minimal '
                '${moneyLabel(TransferValuation.expectedWage(player))}/tahun. '
                'Ajukan kontrak untuk menyelesaikan transfer.',
            isRead: false,
            actionType: InboxActionType.contractNegotiation,
            payload:
                'offer:${o.id}|min:${TransferValuation.expectedWage(player)}',
            resolved: false,
            choice: null,
          ),
        );
      } else {
        await _transfers.updateOffer(
          o.id,
          status: TransferOfferStatus.rejected,
          responseDate: date,
        );
        await _inbox.add(
          InboxMessage(
            id: 0,
            date: date,
            category: InboxCategory.transfer,
            title: 'Tawaran ditolak: ${player.fullName}',
            body:
                '$sellerName menolak tawaran '
                '${moneyLabel(o.fee)}. Harga yang diterima: '
                '${moneyLabel(ask)}.',
            isRead: false,
            actionType: InboxActionType.none,
            payload: null,
            resolved: false,
            choice: null,
          ),
        );
      }
    }
  }

  /// Tawaran dari klub AI untuk pemain kita yang didaftar jual.
  Future<void> _incomingOffers(
    DateTime date,
    String ourClubId,
    SeededRandom rng,
  ) async {
    final squad = await _players.squad(ourClubId);
    final clubs = (await _clubs.allClubs())
        .where((c) => c.id != ourClubId)
        .toList();
    for (final p in squad) {
      if (!p.isTransferListed) continue;
      if (!rng.chance(incomingChance)) continue;
      if ((await _transfers.activeOffersForPlayer(p.id)).isNotEmpty) continue;

      final detail = await _players.detail(p.id);
      final ask = TransferValuation.askingFee(
        player: p,
        contract: detail?.contract,
        now: date,
      );
      final buyers = [
        for (final c in clubs)
          if (c.transferBudget >= ask) c,
      ];
      if (buyers.isEmpty) continue;
      final buyer = rng.pick(buyers);
      final fee = (ask * (0.95 + rng.nextDouble() * 0.3)).round();
      if (fee > buyer.transferBudget) continue;

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
          body:
              '${buyer.name} menawar ${p.fullName} dengan ${moneyLabel(fee)}. '
              'Terima atau tolak tawaran ini.',
          isRead: false,
          actionType: InboxActionType.incomingTransferOffer,
          payload: 'offer:$offerId',
          resolved: false,
          choice: null,
        ),
      );
    }
  }

  /// Transfer antar-klub AI (satu kemungkinan per hari).
  Future<void> _aiDeal(DateTime date, String ourClubId, SeededRandom rng) async {
    if (!rng.chance(aiDealChance)) return;
    final clubs = (await _clubs.allClubs())
        .where((c) => c.id != ourClubId)
        .toList();
    final buyers = [
      for (final c in clubs)
        if (c.transferBudget >= 2000) c,
    ];
    if (buyers.isEmpty) return;
    final buyer = rng.pick(buyers);

    final sellers = [
      for (final c in clubs)
        if (c.id != buyer.id) c,
    ];
    final seller = rng.pick(sellers);
    final squad = await _players.squad(seller.id);
    if (squad.length <= minSquadForSale) return;
    final player = squad[rng.nextInt(squad.length)];

    final detail = await _players.detail(player.id);
    final fee = TransferValuation.askingFee(
      player: player,
      contract: detail?.contract,
      now: date,
    );
    if (fee > buyer.transferBudget) return;

    await _complete(
      player: player,
      buyerId: buyer.id,
      sellerId: seller.id,
      fee: fee,
      wage: detail?.contract?.wage ?? TransferValuation.expectedWage(player),
      years: 3,
      date: date,
      type: TransferType.aiDeal,
    );
  }

  // --- Keputusan pemain ------------------------------------------------------

  /// Menyelesaikan aksi inbox transfer (tawaran masuk atau negosiasi kontrak).
  /// Mengembalikan pesan hasil untuk ditampilkan bila perlu.
  Future<void> resolveAction({
    required InboxMessage message,
    required String choice,
    required DateTime date,
    required String ourClubId,
  }) async {
    final offerId = _offerIdOf(message.payload);
    if (offerId == null) return;
    final offer = await _transfers.offerById(offerId);
    if (offer == null || !offer.isActive) return;
    final player = await _players.byId(offer.playerId);
    if (player == null) return;

    if (message.actionType == InboxActionType.incomingTransferOffer) {
      if (choice == 'accept') {
        final detail = await _players.detail(player.id);
        await _complete(
          player: player,
          buyerId: offer.fromClubId,
          sellerId: ourClubId,
          fee: offer.fee,
          wage: detail?.contract?.wage ??
              TransferValuation.expectedWage(player),
          years: 3,
          date: date,
          type: TransferType.sell,
          offerId: offer.id,
        );
      } else {
        await _transfers.updateOffer(
          offer.id,
          status: TransferOfferStatus.rejected,
          responseDate: date,
        );
      }
      return;
    }

    if (message.actionType == InboxActionType.contractNegotiation) {
      if (choice == 'cancel') {
        await _transfers.updateOffer(
          offer.id,
          status: TransferOfferStatus.withdrawn,
          responseDate: date,
        );
        return;
      }
      final parsed = _parseNegotiation(choice);
      if (parsed == null) return;
      final expected = TransferValuation.expectedWage(player);
      if (parsed.wage < expected) {
        await _transfers.updateOffer(
          offer.id,
          status: TransferOfferStatus.failed,
          responseDate: date,
        );
        await _inbox.add(
          InboxMessage(
            id: 0,
            date: date,
            category: InboxCategory.transfer,
            title: 'Negosiasi gagal: ${player.fullName}',
            body:
                '${player.fullName} menolak kontrak ${moneyLabel(parsed.wage)}/tahun. '
                'Ia menginginkan minimal ${moneyLabel(expected)}/tahun.',
            isRead: false,
            actionType: InboxActionType.none,
            payload: null,
            resolved: false,
            choice: null,
          ),
        );
        return;
      }
      await _complete(
        player: player,
        buyerId: ourClubId,
        sellerId: offer.toClubId,
        fee: offer.fee,
        wage: parsed.wage,
        years: parsed.years,
        date: date,
        type: TransferType.buy,
        offerId: offer.id,
      );
    }
  }

  // --- Penyelesaian transfer -------------------------------------------------

  /// Memindahkan pemain, memindahkan dana, mencatat riwayat, dan membatalkan
  /// tawaran lain untuk pemain yang sama.
  Future<void> _complete({
    required Player player,
    required String buyerId,
    required String sellerId,
    required int fee,
    required int wage,
    required int years,
    required DateTime date,
    required TransferType type,
    int? offerId,
  }) async {
    final sellerName = await _clubName(sellerId);
    final buyerName = await _clubName(buyerId);
    await _db.transaction(() async {
      await _transfers.adjustFinance(
        buyerId,
        balanceDelta: -fee,
        transferBudgetDelta: -fee,
      );
      await _transfers.adjustFinance(sellerId, balanceDelta: fee);
      await _players.moveToClub(
        playerId: player.id,
        clubId: buyerId,
        wage: wage,
        endDate: DateTime.utc(date.year + years, 6, 30),
        squadStatus: SquadStatus.rotation,
      );
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
        InboxMessage(
          id: 0,
          date: date,
          category: InboxCategory.transfer,
          title: 'Transfer selesai: ${player.fullName}',
          body:
              '${player.fullName} pindah dari $sellerName ke '
              '$buyerName dengan biaya ${moneyLabel(fee)}.',
          isRead: false,
          actionType: InboxActionType.none,
          payload: null,
          resolved: false,
          choice: null,
        ),
      );
    });
  }

  // --- Util ------------------------------------------------------------------

  Future<String> _clubName(String id) async =>
      (await _clubs.clubById(id))?.name ?? id;

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
    if (wage == null || years == null || years < 1 || years > 5) return null;
    return (wage: wage, years: years);
  }

  static int _dayKeySeed(int seed, DateTime d) {
    final dayKey = d.difference(DateTime.utc(2025)).inDays;
    return (seed * 31 + dayKey * 7919 + 17) & 0x7FFFFFFF;
  }
}
