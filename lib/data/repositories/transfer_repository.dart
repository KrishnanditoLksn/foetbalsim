import 'package:drift/drift.dart';

import '../../domain/enums/transfer.dart';
import '../../domain/models/transfer_models.dart';
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
  }) {
    return (_db.update(_db.transferOffers)..where((t) => t.id.equals(id))).write(
      TransferOffersCompanion(
        status: Value(status),
        responseDate: Value(responseDate),
      ),
    );
  }

  /// Membatalkan tawaran aktif lain untuk pemain yang sudah berpindah klub.
  Future<void> withdrawActiveOffers(int playerId, {int? exceptId}) {
    return (_db.update(_db.transferOffers)..where(
      (t) =>
          t.playerId.equals(playerId) &
          t.status.isInValues(_activeStatuses) &
          (exceptId == null ? const Constant(true) : t.id.isNotValue(exceptId)),
    )).write(
      const TransferOffersCompanion(status: Value(TransferOfferStatus.withdrawn)),
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

  static const List<TransferOfferStatus> _activeStatuses = [
    TransferOfferStatus.pending,
    TransferOfferStatus.awaitingContract,
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
  );
}
