import 'dart:math' as math;

import '../../core/rng/seeded_random.dart';
import '../enums/position.dart';
import '../models/game_models.dart';

/// Simulasi instan: skor diundi dengan Poisson dari kekuatan tim.
/// Hasil hanya bergantung pada (seed save, id laga), sehingga bisa diulang.
abstract final class QuickMatchSimulator {
  /// 1 kiper terbaik + 10 pemain lapangan terbaik (berdasarkan CA).
  static List<Player> startingXI(List<Player> squad) {
    final gks =
        squad.where((p) => p.position == Position.gk).toList()
          ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
    final outfield =
        squad.where((p) => p.position != Position.gk).toList()
          ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
    return [...gks.take(1), ...outfield.take(10)];
  }

  /// Rata-rata CA starting XI × faktor kondisi (0,8–1,0).
  static double teamRating(List<Player> xi) {
    if (xi.isEmpty) return 1;
    final avgCa = xi.fold<int>(0, (s, p) => s + p.currentAbility) / xi.length;
    final avgCond = xi.fold<int>(0, (s, p) => s + p.condition) / xi.length;
    return avgCa * (0.8 + 0.2 * avgCond / 100);
  }

  static int matchSeed(int seed, int fixtureId) =>
      ((seed * 1000003) ^ (fixtureId * 2654435761)) & 0x7FFFFFFF;

  /// λ kandang = 1,45·e^(selisih/40), λ tandang = 1,10·e^(−selisih/40).
  static (int, int) simulate({
    required double homeRating,
    required double awayRating,
    required int seed,
    required int fixtureId,
  }) {
    final rng = SeededRandom(matchSeed(seed, fixtureId));
    final diff = homeRating - awayRating;
    final home = _poisson(rng, 1.45 * math.exp(diff / 40));
    final away = _poisson(rng, 1.10 * math.exp(-diff / 40));
    return (home, away);
  }

  /// Penurunan kondisi setelah bermain: 12–22.
  static int conditionLoss(int seed, int fixtureId, int playerId) {
    final rng = SeededRandom(matchSeed(seed, fixtureId) ^ (playerId * 97));
    return rng.range(12, 22);
  }

  static int _poisson(SeededRandom rng, double lambda) {
    final limit = math.exp(-lambda);
    var k = 0;
    var p = 1.0;
    do {
      k++;
      p *= rng.nextDouble();
    } while (p > limit && k < 50);
    return math.min(9, k - 1);
  }
}
