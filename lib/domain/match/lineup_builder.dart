import '../enums/position.dart';
import '../enums/tactics.dart';
import '../models/game_models.dart';
import '../models/match_models.dart';

/// Penyusunan starter & bangku cadangan dari skuad.
abstract final class LineupBuilder {
  static const int starterCount = 11;
  static const int benchCount = 7;

  /// Kecocokan pemain di slot formasi (1.0 = posisi asli).
  static double slotFit(PositionGroup g, SlotRole r) {
    if (r == SlotRole.gk) return g == PositionGroup.goalkeeper ? 1.0 : 0.25;
    if (g == PositionGroup.goalkeeper) return 0.25;
    final sameGroup = switch (r) {
      SlotRole.def => PositionGroup.defender,
      SlotRole.mid => PositionGroup.midfielder,
      SlotRole.fwd => PositionGroup.forward,
      SlotRole.gk => PositionGroup.goalkeeper,
    };
    if (g == sameGroup) return 1.0;
    final adjacent =
        (g == PositionGroup.defender && r == SlotRole.mid) ||
        (g == PositionGroup.midfielder && r != SlotRole.mid) ||
        (g == PositionGroup.forward && r == SlotRole.mid);
    return adjacent ? 0.88 : 0.78;
  }

  /// Starter terbaik per slot (urut slot), lalu bangku berisi sisa skuad
  /// terbaik dengan minimal satu kiper bila tersedia.
  static ({List<Player> starters, List<Player> bench}) auto(
    List<Player> squad,
    Formation formation,
  ) {
    final pool = [...squad]
      ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
    final used = <int>{};
    final starters = <Player>[];

    for (final slot in formation.slots) {
      Player? best;
      var bestScore = -1.0;
      for (final p in pool) {
        if (used.contains(p.id)) continue;
        final score = p.currentAbility * slotFit(p.position.group, slot.role);
        if (score > bestScore) {
          bestScore = score;
          best = p;
        }
      }
      if (best == null) break;
      used.add(best.id);
      starters.add(best);
    }

    final rest = [
      for (final p in pool)
        if (!used.contains(p.id)) p,
    ];
    final bench = <Player>[];
    final gk = rest.where((p) => p.position == Position.gk).toList();
    if (gk.isNotEmpty) bench.add(gk.first);
    for (final p in rest) {
      if (bench.length >= benchCount) break;
      if (!bench.contains(p)) bench.add(p);
    }
    return (starters: starters, bench: bench);
  }

  /// Menerapkan taktik tersimpan bila masih valid terhadap skuad saat ini.
  /// Bila tidak valid (mis. pemain sudah dijual), susunan otomatis dipakai.
  static ({List<Player> starters, List<Player> bench}) resolve(
    List<Player> squad,
    ClubTactic? saved,
  ) {
    if (saved == null) return auto(squad, Formation.f442);
    final byId = {for (final p in squad) p.id: p};
    final starterIds = saved.starterIds;
    final subIds = saved.subIds;
    final valid =
        starterIds.length == starterCount &&
        starterIds.toSet().length == starterCount &&
        starterIds.every(byId.containsKey) &&
        subIds.length <= benchCount &&
        subIds.toSet().length == subIds.length &&
        subIds.every((id) => byId.containsKey(id) && !starterIds.contains(id));
    if (!valid) return auto(squad, saved.formation);

    final bench = [for (final id in subIds) byId[id]!];
    final rest = [
      for (final p in squad)
        if (!starterIds.contains(p.id) && !subIds.contains(p.id)) p,
    ]..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
    for (final p in rest) {
      if (bench.length >= benchCount) break;
      bench.add(p);
    }
    return (
      starters: [for (final id in starterIds) byId[id]!],
      bench: bench,
    );
  }
}
