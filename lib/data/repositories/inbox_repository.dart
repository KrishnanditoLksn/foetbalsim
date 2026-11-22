import 'package:drift/drift.dart';

import '../../domain/models/season_models.dart';
import '../database/app_database.dart';

class InboxRepository {
  InboxRepository(this._db);

  final AppDatabase _db;

  Future<bool> hasAny() async {
    final row =
        await (_db.select(_db.inboxMessages)..limit(1)).getSingleOrNull();
    return row != null;
  }

  /// Menyimpan pesan baru dan mengembalikan id-nya.
  Future<int> add(InboxMessage m) {
    return _db
        .into(_db.inboxMessages)
        .insert(
          InboxMessagesCompanion.insert(
            date: m.date,
            category: m.category,
            title: m.title,
            body: m.body,
            actionType: m.actionType,
            payload: Value(m.payload),
          ),
        );
  }

  Future<List<InboxMessage>> all() async {
    final rows =
        await (_db.select(_db.inboxMessages)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
    return rows.map(_map).toList();
  }

  /// Pesan yang belum diselesaikan dan butuh tindakan.
  Future<List<InboxMessage>> pendingActions() async {
    final rows =
        await (_db.select(_db.inboxMessages)
              ..where((t) => t.resolved.equals(false))
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
    return rows.map(_map).where((m) => m.needsAction).toList();
  }

  Future<void> markRead(int id) {
    return (_db.update(_db.inboxMessages)..where(
      (t) => t.id.equals(id),
    )).write(const InboxMessagesCompanion(isRead: Value(true)));
  }

  Future<void> resolve(int id, String choice) {
    return (_db.update(_db.inboxMessages)..where((t) => t.id.equals(id))).write(
      InboxMessagesCompanion(
        resolved: const Value(true),
        isRead: const Value(true),
        choice: Value(choice),
      ),
    );
  }

  static InboxMessage _map(InboxRow r) => InboxMessage(
    id: r.id,
    date: r.date.toUtc(),
    category: r.category,
    title: r.title,
    body: r.body,
    isRead: r.isRead,
    actionType: r.actionType,
    payload: r.payload,
    resolved: r.resolved,
    choice: r.choice,
  );
}
