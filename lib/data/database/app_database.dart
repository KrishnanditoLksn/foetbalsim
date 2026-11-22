import 'package:drift/drift.dart';

import '../../domain/enums/inbox.dart';
import '../../domain/enums/position.dart';
import '../../domain/enums/squad_status.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Satu instance = satu file save SQLite.
///
/// v1: data dunia (Fase 1).
/// v2: Fixtures + InboxMessages (Fase 2). Save v1 dimigrasi otomatis.
@DriftDatabase(
  tables: [
    Nations,
    Leagues,
    Clubs,
    Players,
    Contracts,
    GameStates,
    Fixtures,
    InboxMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(fixtures);
        await m.createTable(inboxMessages);
      }
    },
  );
}
