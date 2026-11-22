import 'package:drift/drift.dart';

import '../../domain/models/game_models.dart';
import '../database/app_database.dart';
import 'row_mappers.dart';

class ClubRepository {
  ClubRepository(this._db);

  final AppDatabase _db;

  Future<List<Nation>> nations() async {
    final rows = await _db.select(_db.nations).get();
    return rows.map(RowMappers.nation).toList();
  }

  Future<List<League>> leagues() async {
    final rows =
        await (_db.select(_db.leagues)
          ..orderBy([(t) => OrderingTerm.asc(t.tier)])).get();
    return rows.map(RowMappers.league).toList();
  }

  Future<List<Club>> clubsByLeague(String leagueId) async {
    final rows =
        await (_db.select(_db.clubs)
              ..where((t) => t.leagueId.equals(leagueId))
              ..orderBy([(t) => OrderingTerm.desc(t.reputation)]))
            .get();
    return rows.map(RowMappers.club).toList();
  }

  Future<Club?> clubById(String id) async {
    final row =
        await (_db.select(_db.clubs)
          ..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : RowMappers.club(row);
  }
}
