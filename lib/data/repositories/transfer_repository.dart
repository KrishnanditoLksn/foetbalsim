import 'package:drift/drift.dart';

import '../../domain/enums/transfer.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/club_ai_profile.dart';
import '../../domain/transfer/interest_engine.dart';
import '../database/app_database.dart';

/// Query tawaran transfer, riwayat transfer, shortlist, dan arus dana klub.
class TransferRepository {
  TransferRepository(this._db);

  final AppDatabase _db;

  // --- Tawaran ---------------------------------------------------------------

  Future<int> insertOffer({
    required int playerId,
    required String fromClubId,
    required String toClubId,
    required int fee,
    required TransferOfferStatus status,
    required DateTime createdDate,
    required DateTime? responseDate,
    int installmentYears = 1,
    int sellOnPct = 0,
  }) {
    return _db
        .into(_db.transferOffers)
        .insert(
          TransferOffersCompanion.insert(
            playerId: playerId,
            fromClubId: fromClubId,
            toClubId: toClubId,
            fee: fee,
            status: status,
            createdDate: createdDate,
            responseDate: Value(responseDate),
            installmentYears: Value(installmentYears),
            sellOnPct: Value(sellOnPct),
          ),
        );
  }

  Future<TransferOffer?> offerById(int id) async {
    final row =
        await (_db.select(_db.transferOffers)
          ..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapOffer(row);
  }

  /// Semua tawaran yang melibatkan klub (sebagai penawar atau penerima).
  Future<List<TransferOffer>> offersFor(String clubId) async {
    final rows =
        await (_db.select(_db.transferOffers)
              ..where(
                (t) =>
                    t.fromClubId.equals(clubId) | t.toClubId.equals(clubId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.id)]))
            .get();
    return rows.map(_mapOffer).toList();
  }

  /// Tawaran aktif (belum selesai) untuk satu pemain.
  Future<List<TransferOffer>> activeOffersForPlayer(int playerId) async {
    final rows =
        await (_db.select(_db.transferOffers)..where(
          (t) =>
              t.playerId.equals(playerId) &
              t.status.isInValues(_activeStatuses),
        )).get();
    return rows.map(_mapOffer).toList();
  }

  /// Tawaran berstatus [pending] yang tanggal responsnya sudah tiba.
  Future<List<TransferOffer>> dueOffers(DateTime date) async {
    final rows =
        await (_db.select(_db.transferOffers)
              ..where(
                (t) =>
                    t.status.equalsValue(TransferOfferStatus.pending) &
                    t.responseDate.isSmallerOrEqualValue(date),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
    return rows.map(_mapOffer).toList();
  }

  Future<void> updateOffer(
    int id, {
    required TransferOfferStatus status,
    DateTime? responseDate,
    int? fee,
    int? installmentYears,
    int? sellOnPct,
    String? reason,
  }) async {
    await (_db.update(_db.transferOffers)..where((t) => t.id.equals(id))).write(
      TransferOffersCompanion(
        status: Value(status),
        responseDate: Value(responseDate),
        fee: fee == null ? const Value.absent() : Value(fee),
        installmentYears:
            installmentYears == null
                ? const Value.absent()
                : Value(installmentYears),
        sellOnPct: sellOnPct == null ? const Value.absent() : Value(sellOnPct),
        reason: reason == null ? const Value.absent() : Value(reason),
      ),
    );
    if (!_activeStatuses.contains(status)) await _pruneSessions();
  }

  /// Membatalkan tawaran aktif lain untuk pemain yang sudah berpindah klub.
  Future<void> withdrawActiveOffers(int playerId, {int? exceptId}) async {
    await (_db.update(_db.transferOffers)..where(
      (t) =>
          t.playerId.equals(playerId) &
          t.status.isInValues(_activeStatuses) &
          (exceptId == null ? const Constant(true) : t.id.isNotValue(exceptId)),
    )).write(
      const TransferOffersCompanion(status: Value(TransferOfferStatus.withdrawn)),
    );
    await _pruneSessions();
  }

  // --- Sesi negosiasi ----------------------------------------------------------

  Future<NegotiationSessionRow?> session(int offerId, String mode) {
    return (_db.select(_db.negotiationSessions)..where(
      (t) => t.offerId.equals(offerId) & t.mode.equals(mode),
    )).getSingleOrNull();
  }

  /// Sesi yang masih berjalan untuk tawaran-tawaran ini (indikator di tab
  /// Negosiasi).
  Future<List<NegotiationSessionRow>> activeSessions() {
    return (_db.select(_db.negotiationSessions)
      ..where((t) => t.status.equals('active'))).get();
  }

  Future<void> saveSession(NegotiationSessionsCompanion row) =>
      _db.into(_db.negotiationSessions).insertOnConflictUpdate(row);

  Future<void> deleteSession(int offerId, String mode) {
    return (_db.delete(_db.negotiationSessions)..where(
      (t) => t.offerId.equals(offerId) & t.mode.equals(mode),
    )).go();
  }

  /// Walk-out terakhir agen pemain [playerId] pada mode [mode]: dipakai untuk
  /// jeda 1 minggu dan ingatan agen.
  Future<NegotiationSessionRow?> lastWalkOut(int playerId, String mode) async {
    final rows = await (_db.select(_db.negotiationSessions)
          ..where(
            (t) =>
                t.playerId.equals(playerId) &
                t.mode.equals(mode) &
                t.status.equals('walkedOut'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedDate)])
          ..limit(1))
        .get();
    return rows.firstOrNull;
  }

  /// Jeda walk-out yang masih berlaku untuk pemain (mode apa pun).
  Future<NegotiationSessionRow?> activeCooldown(int playerId, DateTime now) async {
    final rows = await (_db.select(_db.negotiationSessions)..where(
      (t) =>
          t.playerId.equals(playerId) &
          t.status.equals('walkedOut') &
          t.cooldownUntil.isBiggerThanValue(now),
    )).get();
    return rows.firstOrNull;
  }

  /// Sesi milik tawaran yang sudah selesai dihapus, kecuali catatan
  /// walk-out (disimpan untuk jeda dan ingatan agen).
  Future<void> _pruneSessions() {
    return _db.customStatement(
      "DELETE FROM negotiation_sessions WHERE status <> 'walkedOut' AND "
      'offer_id NOT IN (SELECT id FROM transfer_offers WHERE status IN '
      "('pending', 'awaitingContract', 'countered'))",
    );
  }

  // --- Riwayat ---------------------------------------------------------------

  Future<void> addHistory(TransferRecord r) {
    return _db
        .into(_db.transferHistory)
        .insert(
          TransferHistoryCompanion.insert(
            date: r.date,
            playerId: r.playerId,
            playerName: r.playerName,
            fromClubId: r.fromClubId,
            toClubId: r.toClubId,
            fee: r.fee,
            type: r.type,
          ),
        );
  }

  /// Jumlah pemain yang masuk ke / keluar dari [clubId] sejak [since].
  Future<({int incoming, int outgoing})> movesSince(
    String clubId,
    DateTime since,
  ) async {
    final rows =
        await (_db.select(_db.transferHistory)..where(
          (t) =>
              t.date.isBiggerOrEqualValue(since) &
              (t.fromClubId.equals(clubId) | t.toClubId.equals(clubId)),
        )).get();
    var incoming = 0;
    var outgoing = 0;
    for (final r in rows) {
      if (r.toClubId == clubId) incoming++;
      if (r.fromClubId == clubId) outgoing++;
    }
    return (incoming: incoming, outgoing: outgoing);
  }

  /// Riwayat terbaru lebih dulu.
  Future<List<TransferRecord>> history({int limit = 200}) async {
    final rows =
        await (_db.select(_db.transferHistory)
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(limit))
            .get();
    return rows
        .map(
          (r) => TransferRecord(
            id: r.id,
            date: r.date.toUtc(),
            playerId: r.playerId,
            playerName: r.playerName,
            fromClubId: r.fromClubId,
            toClubId: r.toClubId,
            fee: r.fee,
            type: r.type,
          ),
        )
        .toList();
  }

  // --- Shortlist -------------------------------------------------------------

  Future<Set<int>> shortlistIds() async {
    final rows = await _db.select(_db.shortlist).get();
    return rows.map((r) => r.playerId).toSet();
  }

  Future<void> setShortlisted(int playerId, bool value, DateTime now) async {
    if (value) {
      await _db
          .into(_db.shortlist)
          .insertOnConflictUpdate(
            ShortlistCompanion.insert(playerId: Value(playerId), addedDate: now),
          );
    } else {
      await (_db.delete(_db.shortlist)
        ..where((t) => t.playerId.equals(playerId))).go();
    }
  }

  // --- Keuangan klub ---------------------------------------------------------

  /// Menambah/mengurangi saldo dan anggaran transfer klub (€K).
  Future<void> adjustFinance(
    String clubId, {
    int balanceDelta = 0,
    int transferBudgetDelta = 0,
  }) {
    return _db.customUpdate(
      'UPDATE clubs SET balance = balance + ?, transfer_budget = transfer_budget + ? '
      'WHERE id = ?',
      variables: [
        Variable.withInt(balanceDelta),
        Variable.withInt(transferBudgetDelta),
        Variable.withString(clubId),
      ],
      updates: {_db.clubs},
    );
  }

  // --- Profil AI ---------------------------------------------------------------

  Future<ClubAiProfile?> profileFor(String clubId) async {
    final r = await (_db.select(_db.clubAiProfiles)
      ..where((t) => t.clubId.equals(clubId))).getSingleOrNull();
    return r == null ? null : _mapProfile(r);
  }

  Future<void> saveProfile(ClubAiProfile p) {
    return _db
        .into(_db.clubAiProfiles)
        .insertOnConflictUpdate(
          ClubAiProfilesCompanion.insert(
            clubId: p.clubId,
            personality: p.personality.name,
            ambition: p.ambition,
            riskTolerance: p.riskTolerance,
            negotiationSkill: p.negotiationSkill,
            sellingWillingness: p.sellingWillingness,
            youthFocus: p.youthFocus,
          ),
        );
  }

  static ClubAiProfile _mapProfile(ClubAiProfileRow r) => ClubAiProfile(
    clubId: r.clubId,
    personality: ClubPersonality.values.byName(r.personality),
    ambition: r.ambition,
    riskTolerance: r.riskTolerance,
    negotiationSkill: r.negotiationSkill,
    sellingWillingness: r.sellingWillingness,
    youthFocus: r.youthFocus,
  );

  // --- Minat ------------------------------------------------------------------

  Future<void> upsertInterest({
    required String clubId,
    required int playerId,
    required int score,
    required InterestLevel level,
    required DateTime date,
  }) {
    return _db
        .into(_db.transferInterests)
        .insertOnConflictUpdate(
          TransferInterestsCompanion.insert(
            clubId: clubId,
            playerId: playerId,
            score: score,
            level: level.name,
            updatedDate: date,
          ),
        );
  }

  /// Klub yang berminat pada pemain, skor tertinggi lebih dulu.
  Future<List<(String, int, InterestLevel)>> interestsForPlayer(int playerId) async {
    final rows = await (_db.select(_db.transferInterests)
          ..where((t) => t.playerId.equals(playerId))
          ..orderBy([(t) => OrderingTerm.desc(t.score)]))
        .get();
    return [
      for (final r in rows)
        (r.clubId, r.score, InterestLevel.values.byName(r.level)),
    ];
  }

  Future<void> deleteInterestsBelow(int minScore) {
    return (_db.delete(_db.transferInterests)
          ..where((t) => t.score.isSmallerThanValue(minScore)))
        .go();
  }

  // --- Berita -----------------------------------------------------------------

  Future<void> addNews({
    required DateTime date,
    required String kind,
    required String body,
    String clubIds = '',
  }) {
    return _db
        .into(_db.transferNews)
        .insert(
          TransferNewsCompanion.insert(
            date: date,
            kind: kind,
            body: body,
            clubIds: Value(clubIds),
          ),
        );
  }

  Future<List<String>> newsOn(DateTime date) async {
    final rows = await (_db.select(_db.transferNews)
          ..where((t) => t.date.equals(date))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return [for (final r in rows) r.body];
  }

  /// Berita bursa terbaru lebih dulu.
  Future<List<TransferNewsItem>> recentNews({int limit = 100}) async {
    final rows = await (_db.select(_db.transferNews)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(limit))
        .get();
    return [
      for (final r in rows)
        TransferNewsItem(date: r.date.toUtc(), kind: r.kind, body: r.body),
    ];
  }

  // --- Memori pasar -----------------------------------------------------------

  Future<int> memory(String key) async {
    final r = await (_db.select(_db.marketMemory)
      ..where((t) => t.key.equals(key))).getSingleOrNull();
    return r?.value ?? 0;
  }

  Future<void> setMemory(String key, int value) {
    return _db
        .into(_db.marketMemory)
        .insertOnConflictUpdate(
          MarketMemoryCompanion.insert(key: key, value: value),
        );
  }

  /// Semua entri memori yang kuncinya diawali [prefix].
  Future<Map<String, int>> memoryWithPrefix(String prefix) async {
    final rows = await (_db.select(_db.marketMemory)
          ..where((t) => t.key.like('$prefix%')))
        .get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> deleteMemory(String key) =>
      (_db.delete(_db.marketMemory)..where((t) => t.key.equals(key))).go();

  static const List<TransferOfferStatus> _activeStatuses = [
    TransferOfferStatus.pending,
    TransferOfferStatus.awaitingContract,
    TransferOfferStatus.countered,
  ];

  static TransferOffer _mapOffer(TransferOfferRow r) => TransferOffer(
    id: r.id,
    playerId: r.playerId,
    fromClubId: r.fromClubId,
    toClubId: r.toClubId,
    fee: r.fee,
    status: r.status,
    createdDate: r.createdDate.toUtc(),
    responseDate: r.responseDate?.toUtc(),
    // Kolom lama berisi 1 sebagai bawaan; nilai di luar opsi dianggap langsung.
    installmentYears: r.installmentYears.clamp(1, 3),
    sellOnPct: r.sellOnPct,
    reason: r.reason,
  );
}
