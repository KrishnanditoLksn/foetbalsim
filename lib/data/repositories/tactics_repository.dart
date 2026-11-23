import 'package:drift/drift.dart';

import '../../domain/models/match_models.dart';
import '../database/app_database.dart';

/// Simpan/muat taktik & lineup per klub (tabel ClubTactics).
class TacticsRepository {
  TacticsRepository(this._db);

  final AppDatabase _db;

  Future<ClubTactic?> load(String clubId) async {
    final row =
        await (_db.select(_db.clubTactics)
          ..where((t) => t.clubId.equals(clubId))).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  Future<void> save(ClubTactic t) {
    return _db
        .into(_db.clubTactics)
        .insertOnConflictUpdate(
          ClubTacticsCompanion.insert(
            clubId: t.clubId,
            formation: t.formation,
            mentality: t.mentality,
            starterIds: Value(t.starterIds.join(',')),
            subIds: Value(t.subIds.join(',')),
          ),
        );
  }

  static List<int> parseIds(String raw) => raw.isEmpty
      ? const []
      : raw.split(',').map(int.parse).toList();

  static ClubTactic _map(ClubTacticRow r) => ClubTactic(
    clubId: r.clubId,
    formation: r.formation,
    mentality: r.mentality,
    starterIds: parseIds(r.starterIds),
    subIds: parseIds(r.subIds),
  );
}
