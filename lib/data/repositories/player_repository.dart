import 'package:drift/drift.dart';

import '../../domain/models/game_models.dart';
import '../database/app_database.dart';
import 'row_mappers.dart';

/// Hasil gabungan pemain + kontraknya untuk layar detail.
class PlayerDetail {
  const PlayerDetail({required this.player, required this.contract});

  final Player player;
  final Contract? contract;
}

class PlayerRepository {
  PlayerRepository(this._db);

  final AppDatabase _db;

  Future<List<Player>> squad(String clubId) async {
    final rows =
        await (_db.select(_db.players)
              ..where((t) => t.clubId.equals(clubId))
              ..orderBy([(t) => OrderingTerm.desc(t.currentAbility)]))
            .get();
    return rows.map(RowMappers.player).toList();
  }

  Future<PlayerDetail?> detail(int playerId) async {
    final playerRow =
        await (_db.select(_db.players)
          ..where((t) => t.id.equals(playerId))).getSingleOrNull();
    if (playerRow == null) return null;

    final contractRow =
        await (_db.select(_db.contracts)
          ..where((t) => t.playerId.equals(playerId))).getSingleOrNull();

    return PlayerDetail(
      player: RowMappers.player(playerRow),
      contract: contractRow == null ? null : RowMappers.contract(contractRow),
    );
  }
}
