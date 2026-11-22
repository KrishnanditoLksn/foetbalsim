import 'package:drift/drift.dart';

import '../../domain/enums/position.dart';
import '../../domain/enums/squad_status.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Satu instance = satu file save SQLite.
@DriftDatabase(
  tables: [Nations, Leagues, Clubs, Players, Contracts, GameStates],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
