import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/game_engine.dart';
import '../domain/models/match_models.dart';
import '../domain/models/season_models.dart';
import 'providers.dart';

/// Jembatan UI ↔ engine. Mencegah dua aksi berjalan bersamaan dan
/// memberi tahu provider bahwa data berubah.
final engineBusyProvider = StateProvider<bool>((ref) => false);

abstract final class GameActions {
  /// LANJUTKAN = H+1. Menyimpan ringkasan hari untuk kartu "Hari Ini".
  static Future<DayReport?> advanceDay(WidgetRef ref) async {
    if (ref.read(engineBusyProvider)) return null;
    ref.read(engineBusyProvider.notifier).state = true;
    try {
      final report = await ref.read(gameEngineProvider).advanceOneDay();
      ref.read(lastDayReportProvider.notifier).state = report;
      return report;
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

  /// Menyimpan hasil laga 2D setelah peluit akhir.
  static Future<MatchDayResult?> commitMatch(
    WidgetRef ref,
    MatchResultData result,
  ) async {
    if (ref.read(engineBusyProvider)) return null;
    ref.read(engineBusyProvider.notifier).state = true;
    try {
      return await ref.read(gameEngineProvider).commitMatch(result);
    } finally {
      ref.read(worldVersionProvider.notifier).state++;
      ref.read(engineBusyProvider.notifier).state = false;
    }
  }

  /// Menjalankan aksi ringan pada data permainan (taktik, transfer, dll.)
  /// lalu memberi tahu provider bahwa data berubah. Error diteruskan ke
  /// pemanggil agar bisa ditampilkan.
  static Future<void> run(
    WidgetRef ref,
    Future<void> Function(GameEngine engine) action,
  ) async {
    try {
      await action(ref.read(gameEngineProvider));
    } finally {
      ref.read(worldVersionProvider.notifier).state++;
    }
  }
}
