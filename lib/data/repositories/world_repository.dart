import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/generators/world_generator.dart';
import '../../domain/models/game_models.dart';
import '../database/app_database.dart';
import 'row_mappers.dart';

/// Membuat dunia baru dan menulisnya ke save (satu transaction).
class WorldRepository {
  WorldRepository(this._db);

  static const String spainSeedAsset = 'assets/seed/spain.json';

  final AppDatabase _db;

  static Future<String> loadSeedJson([String asset = spainSeedAsset]) =>
      rootBundle.loadString(asset);

  /// Generate dunia di isolate agar UI tidak macet. Hanya string + int yang
  /// dikirim masuk isolate; hasil berupa objek domain polos.
  static Future<WorldBlueprint> buildBlueprint({
    required String seedJson,
    required int seed,
  }) {
    return Isolate.run(
      () => WorldGenerator.generate(seedJson: seedJson, seed: seed),
    );
  }

  /// Menulis blueprint + game state dalam satu transaction.
  Future<void> saveWorld(WorldBlueprint world, GameState state) {
    return _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAll(_db.nations, [
          for (final n in world.nations)
            NationsCompanion.insert(id: n.id, name: n.name, code: n.code),
        ], mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.leagues, [
          for (final l in world.leagues)
            LeaguesCompanion.insert(
              id: l.id,
              nationId: l.nationId,
              name: l.name,
              tier: l.tier,
              jumlahTim: l.jumlahTim,
              slotPromosi: l.slotPromosi,
              slotDegradasi: l.slotDegradasi,
              slotPlayoff: Value(l.slotPlayoff),
            ),
        ], mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.clubs, [
          for (final c in world.clubs)
            ClubsCompanion.insert(
              id: c.id,
              leagueId: c.leagueId,
              name: c.name,
              shortName: c.shortName,
              primaryColor: c.primaryColor,
              secondaryColor: c.secondaryColor,
              reputation: c.reputation,
              stadiumName: c.stadiumName,
              capacity: c.capacity,
              balance: c.balance,
              transferBudget: c.transferBudget,
              wageBudget: c.wageBudget,
            ),
        ], mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.players, [
          for (final p in world.players) RowMappers.playerCompanion(p),
        ], mode: InsertMode.insertOrReplace);
        batch.insertAll(_db.contracts, [
          for (final c in world.contracts)
            ContractsCompanion.insert(
              playerId: Value(c.playerId),
              clubId: c.clubId,
              wage: c.wage,
              endDate: c.endDate,
              squadStatus: c.squadStatus,
            ),
        ], mode: InsertMode.insertOrReplace);
      });

      await _db
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
    });
  }
}
