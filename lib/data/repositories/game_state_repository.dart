import 'package:drift/drift.dart';

import '../../domain/models/game_models.dart';
import '../database/app_database.dart';
import 'row_mappers.dart';

class GameStateRepository {
  GameStateRepository(this._db);

  final AppDatabase _db;

  Future<GameState?> load() async {
    final row =
        await (_db.select(_db.gameStates)
          ..where((t) => t.id.equals(1))).getSingleOrNull();
    return row == null ? null : RowMappers.gameState(row);
  }

  Future<void> save(GameState state) {
    return _db
        .into(_db.gameStates)
        .insertOnConflictUpdate(
          GameStatesCompanion.insert(
            id: const Value(1),
            currentDate: state.currentDate,
            managerName: state.managerName,
            clubId: Value(state.clubId),
            seed: state.seed,
          ),
        );
  }
}
