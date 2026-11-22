import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/repositories/club_repository.dart';
import '../data/repositories/game_state_repository.dart';
import '../data/repositories/player_repository.dart';
import '../data/repositories/world_repository.dart';
import '../domain/generators/seed_catalog.dart';
import '../domain/models/game_models.dart';

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

final clubByIdProvider = FutureProvider.family<Club?, String>(
  (ref, clubId) => ref.watch(clubRepositoryProvider).clubById(clubId),
);

final squadProvider = FutureProvider.family<List<Player>, String>(
  (ref, clubId) => ref.watch(playerRepositoryProvider).squad(clubId),
);

final playerDetailProvider = FutureProvider.family<PlayerDetail?, int>(
  (ref, playerId) => ref.watch(playerRepositoryProvider).detail(playerId),
);

final gameStateProvider = FutureProvider<GameState?>(
  (ref) => ref.watch(gameStateRepositoryProvider).load(),
);
