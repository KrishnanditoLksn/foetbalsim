import 'package:drift/drift.dart';

import '../../domain/models/season_models.dart';
import '../database/app_database.dart';

class FixtureRepository {
  FixtureRepository(this._db);

  final AppDatabase _db;

  Future<bool> hasAny() async {
    final row = await (_db.select(_db.fixtures)..limit(1)).getSingleOrNull();
    return row != null;
  }

  Future<void> insertAll(List<Fixture> fixtures) {
    return _db.batch((batch) {
      batch.insertAll(_db.fixtures, [
        for (final f in fixtures)
          FixturesCompanion.insert(
            id: Value(f.id),
            leagueId: f.leagueId,
            round: f.round,
            date: f.date,
            homeClubId: f.homeClubId,
            awayClubId: f.awayClubId,
          ),
      ], mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<Fixture>> forClub(String clubId) async {
    final rows =
        await (_db.select(_db.fixtures)
              ..where(
                (t) =>
                    t.homeClubId.equals(clubId) | t.awayClubId.equals(clubId),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.date),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows.map(_map).toList();
  }

  Future<List<Fixture>> forLeague(String leagueId) async {
    final rows =
        await (_db.select(_db.fixtures)
              ..where((t) => t.leagueId.equals(leagueId))
              ..orderBy([
                (t) => OrderingTerm.asc(t.date),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows.map(_map).toList();
  }

  Future<List<Fixture>> onDate(DateTime date) async {
    final rows =
        await (_db.select(_db.fixtures)
              ..where((t) => t.date.equals(date))
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
    return rows.map(_map).toList();
  }

  Future<void> setResult(int fixtureId, int homeGoals, int awayGoals) {
    return (_db.update(_db.fixtures)
      ..where((t) => t.id.equals(fixtureId))).write(
      FixturesCompanion(
        homeGoals: Value(homeGoals),
        awayGoals: Value(awayGoals),
      ),
    );
  }

  static Fixture _map(FixtureRow r) => Fixture(
    id: r.id,
    leagueId: r.leagueId,
    round: r.round,
    date: r.date.toUtc(),
    homeClubId: r.homeClubId,
    awayClubId: r.awayClubId,
    homeGoals: r.homeGoals,
    awayGoals: r.awayGoals,
  );
}
