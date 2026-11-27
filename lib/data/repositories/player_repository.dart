import 'package:drift/drift.dart';

import '../../domain/enums/squad_status.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/transfer_models.dart';
import '../database/app_database.dart';
import 'row_mappers.dart';

/// Hasil gabungan pemain + kontraknya untuk layar detail.
class PlayerDetail {
  const PlayerDetail({
    required this.player,
    required this.contract,
    required this.clubName,
    required this.leagueId,
  });

  final Player player;
  final Contract? contract;
  final String clubName;
  final String? leagueId;
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

  Future<Player?> byId(int playerId) async {
    final row =
        await (_db.select(_db.players)
          ..where((t) => t.id.equals(playerId))).getSingleOrNull();
    return row == null ? null : RowMappers.player(row);
  }

  Future<PlayerDetail?> detail(int playerId) async {
    final playerRow =
        await (_db.select(_db.players)
          ..where((t) => t.id.equals(playerId))).getSingleOrNull();
    if (playerRow == null) return null;

    final contractRow =
        await (_db.select(_db.contracts)
          ..where((t) => t.playerId.equals(playerId))).getSingleOrNull();

    final clubRow =
        await (_db.select(_db.clubs)
          ..where((t) => t.id.equals(playerRow.clubId))).getSingleOrNull();

    return PlayerDetail(
      player: RowMappers.player(playerRow),
      contract: contractRow == null ? null : RowMappers.contract(contractRow),
      clubName: clubRow?.name ?? '-',
      leagueId: clubRow?.leagueId,
    );
  }

  /// Semua pemain di database beserta kontrak dan info klubnya.
  Future<List<PlayerSearchRow>> allForSearch() async {
    final players = await _db.select(_db.players).get();
    final contracts = {
      for (final c in await _db.select(_db.contracts).get()) c.playerId: c,
    };
    final clubs = {for (final c in await _db.select(_db.clubs).get()) c.id: c};

    return [
      for (final p in players)
        PlayerSearchRow(
          player: RowMappers.player(p),
          contract:
              contracts[p.id] == null
                  ? null
                  : RowMappers.contract(contracts[p.id]!),
          clubName: clubs[p.clubId]?.name ?? '-',
          leagueId: clubs[p.clubId]?.leagueId,
          isForSale: p.isTransferListed,
        ),
    ];
  }

  /// Pemain yang baru pindah terkunci sampai [until] (tidak bolak-balik).
  Future<void> setLockedUntil(int playerId, DateTime? until) {
    return (_db.update(_db.players)..where(
      (t) => t.id.equals(playerId),
    )).write(PlayersCompanion(lockedUntil: Value(until)));
  }

  Future<void> setListed(int playerId, bool listed) {
    return (_db.update(_db.players)..where(
      (t) => t.id.equals(playerId),
    )).write(PlayersCompanion(isTransferListed: Value(listed)));
  }

  /// Memindahkan pemain ke klub lain beserta kontrak barunya.
  Future<void> moveToClub({
    required int playerId,
    required String clubId,
    required int wage,
    required DateTime endDate,
    required SquadStatus squadStatus,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.players)
        ..where((t) => t.id.equals(playerId))).write(
        PlayersCompanion(
          clubId: Value(clubId),
          isTransferListed: const Value(false),
        ),
      );
      await _db
          .into(_db.contracts)
          .insertOnConflictUpdate(
            ContractsCompanion.insert(
              playerId: Value(playerId),
              clubId: clubId,
              wage: wage,
              endDate: endDate,
              squadStatus: squadStatus,
            ),
          );
    });
  }
}
