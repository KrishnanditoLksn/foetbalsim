import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/rng/seeded_random.dart';
import '../data/database/save_storage.dart';
import '../data/repositories/world_repository.dart';
import '../domain/generators/world_generator.dart';
import '../domain/models/game_models.dart';
import 'providers.dart';

/// Membuka slot save dan menjadikannya save aktif. Database lama ditutup.
Future<void> activateSave(WidgetRef ref, int slot) async {
  final previous = ref.read(currentDatabaseProvider);
  final db = await SaveStorage.open(slot);
  ref.read(currentDatabaseProvider.notifier).state = db;
  ref.read(activeSaveSlotProvider.notifier).state = slot;
  await previous?.close();
}

/// Membuat karier baru di slot kosong pertama. Mengembalikan false bila slot penuh.
Future<bool> createNewCareer(
  WidgetRef ref, {
  required String seedJson,
  required String managerName,
  required String clubId,
}) async {
  final slot = await SaveStorage.firstFreeSlot();
  if (slot == null) return false;

  // Seed disimpan di save, sehingga dunia bisa dibangun ulang persis sama.
  final seed = SeededRandom(DateTime.now().microsecondsSinceEpoch).nextU32();

  await activateSave(ref, slot);
  try {
    final blueprint = await WorldRepository.buildBlueprint(
      seedJson: seedJson,
      seed: seed,
    );

    final state = GameState(
      currentDate: WorldGenerator.seasonStart,
      managerName: managerName,
      clubId: clubId,
      seed: seed,
    );
    await WorldRepository(
      ref.read(databaseProvider),
    ).saveWorld(blueprint, state);
  } catch (_) {
    // Jangan biarkan slot setengah jadi tersisa sebagai save "rusak".
    final db = ref.read(currentDatabaseProvider);
    ref.read(currentDatabaseProvider.notifier).state = null;
    ref.read(activeSaveSlotProvider.notifier).state = null;
    await db?.close();
    await SaveStorage.delete(slot);
    rethrow;
  }

  ref.invalidate(gameStateProvider);
  return true;
}
