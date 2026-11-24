import '../enums/position.dart';
import '../enums/squad_status.dart';
import '../models/game_models.dart';

/// Analisis kebutuhan skuad (README_FASE3 B.3). Mengembalikan prioritas
/// 0–100 per grup posisi. Semakin tinggi, semakin mendesak kebutuhannya.
abstract final class SquadNeeds {
  /// Kedalaman minimal per grup (GK ≥ 2, Bek ≥ 7, Gelandang ≥ 6, Penyerang ≥ 4).
  static const Map<PositionGroup, int> minDepth = {
    PositionGroup.goalkeeper: 2,
    PositionGroup.defender: 7,
    PositionGroup.midfielder: 6,
    PositionGroup.forward: 4,
  };

  /// Prioritas kebutuhan tiap grup.
  ///
  /// - Kedalaman: kekurangan pemain layak dari batas minimal.
  /// - Gap kualitas: CA starter grup dibanding [benchmarkCa] (rata-rata 6
  ///   besar liga).
  /// - Usia: starter berusia ≥ 32 mendapat prioritas peremajaan.
  /// - Kontrak: pemain kunci berkontrak ≤ 12 bulan menambah kebutuhan.
  static Map<PositionGroup, int> analyze({
    required List<Player> squad,
    required Map<int, Contract> contracts,
    required DateTime now,
    required int benchmarkCa,
  }) {
    final result = <PositionGroup, int>{};
    for (final group in PositionGroup.values) {
      final members = squad.where((p) => p.position.group == group).toList()
        ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
      final target = minDepth[group] ?? 0;
      final fit = members.where((p) => p.condition >= 40).length;
      var priority = 0.0;

      if (fit < target) {
        priority += 40.0 * (target - fit) / target + 20;
      }

      final starters = members
          .where((p) => _isStarter(p, contracts))
          .toList();
      if (starters.isNotEmpty) {
        final avgCa = starters.fold<int>(0, (s, p) => s + p.currentAbility) /
            starters.length;
        if (avgCa < benchmarkCa) {
          priority += ((benchmarkCa - avgCa) / benchmarkCa * 100).clamp(0, 30);
        }
        final old = starters.where((p) => p.age >= 32).length;
        priority += 10.0 * old;
      } else if (members.isNotEmpty) {
        priority += 15;
      }

      final expiringKey = members.where((p) {
        final c = contracts[p.id];
        return c != null &&
            c.endDate.difference(now).inDays <= 365 &&
            _isStarter(p, contracts);
      }).length;
      priority += 8.0 * expiringKey;

      result[group] = priority.clamp(0, 100).round();
    }
    return result;
  }

  static bool _isStarter(Player p, Map<int, Contract> contracts) {
    final status = contracts[p.id]?.squadStatus;
    return status == SquadStatus.keyPlayer || status == SquadStatus.starter;
  }

  /// CA benchmark: rata-rata CA starter 6 besar liga (dari daftar skuad).
  static int benchmarkCa(Iterable<List<Player>> squads, Map<int, Contract> contracts) {
    final all = <int>[];
    for (final squad in squads) {
      final top = [...squad]
        ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
      all.addAll(top.take(6).map((p) => p.currentAbility));
    }
    if (all.isEmpty) return 70;
    return all.fold<int>(0, (s, v) => s + v) ~/ all.length;
  }
}
