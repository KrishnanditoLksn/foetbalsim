import 'package:drift/drift.dart' show Value;

import '../../domain/enums/inbox.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/models/transfer_news_payload.dart';
import '../../l10n/l10n.dart';
import '../../l10n/legacy_text.dart';
import '../database/app_database.dart';
import '../repositories/club_repository.dart';
import '../repositories/game_state_repository.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/transfer_repository.dart';

/// Memperbarui pesan Inbox (dan berita bursa) dari save lama, sekali saat
/// save dibuka:
///
/// 1. Teks Indonesia mentah (dibuat sebelum ada terjemahan) diubah menjadi
///    [Msg] agar ikut berganti bahasa ([LegacyText]).
/// 2. Berita transfer tanpa rincian `tx:` dilengkapi dari tawaran, riwayat
///    transfer, dan data pemain, agar Inbox bisa menampilkan kartu detail.
///
/// Aman dijalankan berulang: pesan yang sudah diperbarui dilewati.
class LegacyInboxUpgrade {
  LegacyInboxUpgrade(this._db)
    : _inbox = InboxRepository(_db),
      _players = PlayerRepository(_db),
      _transfers = TransferRepository(_db),
      _clubs = ClubRepository(_db);

  final AppDatabase _db;
  final InboxRepository _inbox;
  final PlayerRepository _players;
  final TransferRepository _transfers;
  final ClubRepository _clubs;

  Map<String, Club>? _clubMap;
  List<TransferRecord>? _history;
  Map<String, int>? _playerIdsByName;

  /// Jumlah pesan yang diubah.
  Future<int> run() async {
    var changed = 0;
    for (final m in await _inbox.all()) {
      final title = _upgradeText(m.title);
      final body = _upgradeText(m.body);
      String? payload = m.payload;
      if (m.category == InboxCategory.transfer &&
          TransferNewsPayload.tryParse(m.payload) == null) {
        final news = await _newsFor(m, asMsg(title ?? m.title), body ?? m.body);
        if (news != null) {
          payload = news.encode(head: m.payload);
        }
      }
      if (title == null && body == null && payload == m.payload) continue;
      await (_db.update(_db.inboxMessages)
        ..where((t) => t.id.equals(m.id))).write(
        InboxMessagesCompanion(
          title: Value(title ?? m.title),
          body: Value(body ?? m.body),
          payload: Value(payload),
        ),
      );
      changed++;
    }
    // Berita bursa (tab Transfer) dari save lama.
    for (final row in await _db.select(_db.transferNews).get()) {
      if (Msg.tryDecode(row.body) != null) continue;
      final msg = LegacyText.match(row.body, prefix: 'news.');
      if (msg == null) continue;
      await (_db.update(_db.transferNews)..where(
        (t) => t.id.equals(row.id),
      )).write(TransferNewsCompanion(body: Value(msg.encode())));
      changed++;
    }
    return changed;
  }

  /// Teks baru bila [stored] teks lama yang dikenali, selain itu null.
  static String? _upgradeText(String stored) {
    if (Msg.tryDecode(stored) != null) return null;
    return LegacyText.match(stored)?.encode();
  }

  Future<TransferNewsPayload?> _newsFor(
    InboxMessage m,
    Msg title,
    String body,
  ) async {
    final key = title.key;
    final status = switch (key) {
      'msg.completed.title' => TransferNewsStatus.completed,
      'msg.bidSent.title' => TransferNewsStatus.pendingBid,
      'msg.counter.title' => TransferNewsStatus.counterOffer,
      'msg.feeAgreed.title' => TransferNewsStatus.contractTalks,
      'msg.incoming.title' => TransferNewsStatus.incomingOffer,
      'msg.playerOffered.title' => TransferNewsStatus.offered,
      'msg.rejected.title' => TransferNewsStatus.rejected,
      'msg.failed.title' => TransferNewsStatus.failed,
      _ => null,
    };
    if (status == null) return null;
    final playerName = '${title.args['player'] ?? ''}';

    // Berita yang terkait tawaran: rincian dari baris tawaran.
    final offerId = TransferNewsPayload.offerIdOf(m.payload);
    final offer = offerId == null ? null : await _transfers.offerById(offerId);
    if (offer != null) {
      final player = await _players.byId(offer.playerId);
      final contract = (await _players.detail(offer.playerId))?.contract;
      return TransferNewsPayload(
        playerId: offer.playerId,
        playerName: player?.fullName ?? playerName,
        fromClubId: offer.toClubId,
        toClubId: offer.fromClubId,
        status: status,
        fee: offer.fee,
        installmentYears: offer.installmentYears,
        sellOnPct: offer.sellOnPct,
        contractEndDate: contract?.endDate,
        wage: contract?.wage,
        squadStatus: contract?.squadStatus,
        offerId: offer.id,
      );
    }

    final bodyMsg = Msg.tryDecode(body);
    if (status == TransferNewsStatus.completed) {
      return _completedNews(m.date, playerName, bodyMsg?.args['terms']);
    }
    if (status == TransferNewsStatus.offered) {
      final playerId =
          TransferNewsPayload.playerIdOf(m.payload) ??
          await _playerIdByName(playerName);
      if (playerId == null) return null;
      final text = bodyMsg?.args['text'];
      final fee = text is Msg ? _money(text.args['fee']) : null;
      final clubName = text is Msg ? '${text.args['club']}' : null;
      return _currentNews(
        playerId,
        playerName,
        status,
        fromClubId: await _clubIdByName(clubName),
        fee: fee,
      );
    }
    // Ditolak / gagal tanpa id tawaran: cari pemain dari namanya.
    final playerId = await _playerIdByName(playerName);
    if (playerId == null) return null;
    final terms = bodyMsg?.args['terms'];
    return _currentNews(playerId, playerName, status, fee: _money(terms));
  }

  Future<TransferNewsPayload?> _completedNews(
    DateTime date,
    String playerName,
    Object? terms,
  ) async {
    _history ??= await _transfers.history(limit: 100000);
    final day = DateTime.utc(date.year, date.month, date.day);
    TransferRecord? record;
    for (final r in _history!) {
      final d = r.date.toUtc();
      if (r.playerName == playerName &&
          DateTime.utc(d.year, d.month, d.day) == day) {
        record = r;
        break;
      }
    }
    if (record == null) return null;
    final detail = await _players.detail(record.playerId);
    // Kontrak sekarang = kontrak dari transfer ini selama pemain masih di
    // klub tujuan.
    final contract =
        detail?.player.clubId == record.toClubId ? detail?.contract : null;
    return TransferNewsPayload(
      playerId: record.playerId,
      playerName: record.playerName,
      fromClubId: record.fromClubId,
      toClubId: record.toClubId,
      status: TransferNewsStatus.completed,
      transferType: record.type,
      // Riwayat tidak menyimpan cicilan/sell-on; ambil dari teks berita.
      installmentYears: _extra(terms, 'terms.installments', 'n') ?? 1,
      sellOnPct: _extra(terms, 'terms.sellOn', 'pct') ?? 0,
      fee: record.fee,
      contractYears:
          contract == null
              ? null
              : contract.endDate.toUtc().year - record.date.toUtc().year,
      contractEndDate: contract?.endDate,
      wage: contract?.wage,
      squadStatus: contract?.squadStatus,
    );
  }

  /// Rincian dengan kontrak pemain saat ini; tujuan = klub kita.
  Future<TransferNewsPayload?> _currentNews(
    int playerId,
    String playerName,
    TransferNewsStatus status, {
    String? fromClubId,
    int? fee,
  }) async {
    final detail = await _players.detail(playerId);
    if (detail == null) return null;
    final ourClubId = (await GameStateRepository(_db).load())?.clubId;
    if (ourClubId == null) return null;
    final from = fromClubId ?? detail.player.clubId;
    return TransferNewsPayload(
      playerId: playerId,
      playerName: detail.player.fullName,
      fromClubId: from,
      toClubId: ourClubId,
      status: status,
      fee: fee ?? detail.player.marketValue,
      contractEndDate: detail.contract?.endDate,
      wage: detail.contract?.wage,
      squadStatus: detail.contract?.squadStatus,
    );
  }

  /// Angka [arg] dari syarat tambahan berkunci [key] di dalam [terms]
  /// (`terms.withExtras` → `extras` → [key]).
  static int? _extra(Object? terms, String key, String arg) {
    if (terms is! Msg) return null;
    if (terms.key == key) return (terms.args[arg] as num?)?.toInt();
    for (final v in terms.args.values) {
      final found = _extra(v, key, arg);
      if (found != null) return found;
    }
    return null;
  }

  static int? _money(Object? arg) {
    if (arg is! Msg) return null;
    if (arg.key == '#money') return (arg.args['v'] as num).toInt();
    return _money(arg.args['fee']);
  }

  Future<String?> _clubIdByName(String? name) async {
    if (name == null) return null;
    _clubMap ??= {
      for (final l in await _clubs.leagues())
        for (final c in await _clubs.clubsByLeague(l.id)) c.id: c,
    };
    for (final c in _clubMap!.values) {
      if (c.name == name) return c.id;
    }
    return null;
  }

  Future<int?> _playerIdByName(String name) async {
    if (name.isEmpty) return null;
    final byName =
        _playerIdsByName ??= {
          for (final r in await _players.allForSearch())
            r.player.fullName: r.player.id,
        };
    return byName[name];
  }
}
