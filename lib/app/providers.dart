import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/repositories/club_repository.dart';
import '../data/repositories/fixture_repository.dart';
import '../data/repositories/game_state_repository.dart';
import '../data/repositories/player_repository.dart';
import '../data/repositories/world_repository.dart';
import '../data/services/game_engine.dart';
import '../domain/generators/seed_catalog.dart';
import '../domain/models/game_models.dart';
import '../domain/models/season_models.dart';
import '../domain/season/league_table.dart';

/// Katalog liga & klub dari seed JSON. Tidak membutuhkan database,
/// sehingga aman dipakai sebelum karier dibuat.
final seedCatalogProvider = FutureProvider<SeedCatalog>((ref) async {
  final json = await WorldRepository.loadSeedJson();
  return SeedCatalog.parse(json);
});

/// Database save yang sedang aktif (null = belum ada save dibuka).
final currentDatabaseProvider = StateProvider<AppDatabase?>((ref) => null);

/// Slot save yang sedang aktif (1–3).
final activeSaveSlotProvider = StateProvider<int?>((ref) => null);

/// Naik setiap kali data permainan berubah. Provider yang membaca data
/// permainan menonton angka ini agar otomatis dihitung ulang.
final worldVersionProvider = StateProvider<int>((ref) => 0);

/// Database save aktif. Melempar error jika belum ada save yang dibuka.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = ref.watch(currentDatabaseProvider);
  if (db == null) {
    throw StateError('Belum ada save aktif. Buka atau buat karier dulu.');
  }
  return db;
});

final clubRepositoryProvider = Provider<ClubRepository>(
  (ref) => ClubRepository(ref.watch(databaseProvider)),
);

final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => PlayerRepository(ref.watch(databaseProvider)),
);

final gameStateRepositoryProvider = Provider<GameStateRepository>(
  (ref) => GameStateRepository(ref.watch(databaseProvider)),
);

final fixtureRepositoryProvider = Provider<FixtureRepository>(
  (ref) => FixtureRepository(ref.watch(databaseProvider)),
);

final gameEngineProvider = Provider<GameEngine>(
  (ref) => GameEngine(ref.watch(databaseProvider)),
);

final clubByIdProvider = FutureProvider.family<Club?, String>((ref, clubId) {
  ref.watch(worldVersionProvider);
  return ref.watch(clubRepositoryProvider).clubById(clubId);
});

/// Semua klub dalam satu peta (id → klub), untuk menampilkan nama lawan.
final allClubsMapProvider = FutureProvider<Map<String, Club>>((ref) async {
  ref.watch(worldVersionProvider);
  final repo = ref.watch(clubRepositoryProvider);
  final leagues = await repo.leagues();
  final map = <String, Club>{};
  for (final league in leagues) {
    for (final club in await repo.clubsByLeague(league.id)) {
      map[club.id] = club;
    }
  }
  return map;
});

final squadProvider = FutureProvider.family<List<Player>, String>((
  ref,
  clubId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(playerRepositoryProvider).squad(clubId);
});

final playerDetailProvider = FutureProvider.family<PlayerDetail?, int>((
  ref,
  playerId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(playerRepositoryProvider).detail(playerId);
});

final gameStateProvider = FutureProvider<GameState?>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(gameStateRepositoryProvider).load();
});

final gameStatusProvider = FutureProvider<GameStatus>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(gameEngineProvider).status();
});

final inboxProvider = FutureProvider<List<InboxMessage>>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(gameEngineProvider).inbox();
});

/// Jadwal satu liga (kedua liga dipakai di layar jadwal).
final leagueFixturesProvider = FutureProvider.family<List<Fixture>, String>((
  ref,
  leagueId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(fixtureRepositoryProvider).forLeague(leagueId);
});

/// Jadwal tim kita (kandang & tandang).
final clubFixturesProvider = FutureProvider.family<List<Fixture>, String>((
  ref,
  clubId,
) {
  ref.watch(worldVersionProvider);
  return ref.watch(fixtureRepositoryProvider).forClub(clubId);
});

/// Klasemen satu liga, dihitung dari hasil laga.
final leagueTableProvider = FutureProvider.family<List<LeagueTableRow>, String>(
  (ref, leagueId) async {
    final fixtures = await ref.watch(leagueFixturesProvider(leagueId).future);
    final clubs = await ref
        .watch(clubRepositoryProvider)
        .clubsByLeague(leagueId);
    return LeagueTable.compute(
      clubIds: clubs.map((c) => c.id).toList(),
      fixtures: fixtures,
    );
  },
);

/// Daftar liga dari database (dipakai setelah karier dibuat).
final leaguesProvider = FutureProvider<List<League>>((ref) {
  ref.watch(worldVersionProvider);
  return ref.watch(clubRepositoryProvider).leagues();
});
