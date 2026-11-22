import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/game_engine.dart';
import '../domain/models/season_models.dart';
import 'providers.dart';

/// Jembatan UI ↔ engine. Mencegah dua aksi berjalan bersamaan dan
/// memberi tahu provider bahwa data berubah.
final engineBusyProvider = StateProvider<bool>((ref) => false);

abstract final class GameActions {
  static Future<ContinueResult?> continueGame(WidgetRef ref) async {
    if (ref.read(engineBusyProvider)) return null;
    ref.read(engineBusyProvider.notifier).state = true;
    try {
      final result = await ref.read(gameEngineProvider).continueGame();
      return result;
    } finally {
      ref.read(worldVersionProvider.notifier).state++;
      ref.read(engineBusyProvider.notifier).state = false;
    }
  }

  static Future<MatchDayResult?> playMatchDay(WidgetRef ref) async {
    if (ref.read(engineBusyProvider)) return null;
    ref.read(engineBusyProvider.notifier).state = true;
    try {
      return await ref.read(gameEngineProvider).playMatchDay();
    } finally {
      ref.read(worldVersionProvider.notifier).state++;
      ref.read(engineBusyProvider.notifier).state = false;
    }
  }

  static Future<void> resolve(
    WidgetRef ref,
    InboxMessage message,
    String choice,
  ) async {
    try {
      await ref.read(gameEngineProvider).resolveMessage(message, choice);
    } finally {
      ref.read(worldVersionProvider.notifier).state++;
    }
  }

  static Future<void> markRead(WidgetRef ref, int id) async {
    await ref.read(gameEngineProvider).markRead(id);
    ref.read(worldVersionProvider.notifier).state++;
  }
}
