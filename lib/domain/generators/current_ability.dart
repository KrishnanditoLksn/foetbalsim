import 'dart:math' as math;

import '../enums/attribute.dart';
import '../enums/position.dart';
import '../models/player_attributes.dart';

/// Perhitungan Current Ability (CA) berbasis atribut berbobot per posisi.
///
/// CA = rata-rata tertimbang atribut relevan × 10, dibatasi 1–200.
/// Bintang UI = CA / 40 (lihat `caToStars`).
abstract final class CurrentAbility {
  static const Map<Position, Map<Attribute, double>> _profiles = {
    Position.gk: {
      Attribute.handling: 3,
      Attribute.reflexes: 3,
      Attribute.oneOnOnes: 2,
      Attribute.aerialReach: 2,
      Attribute.positioning: 1.5,
      Attribute.decisions: 1.5,
      Attribute.composure: 1,
      Attribute.agility: 1,
    },
    Position.dr: {
      Attribute.tackling: 2.5,
      Attribute.positioning: 2,
      Attribute.pace: 2,
      Attribute.stamina: 2,
      Attribute.crossing: 1.5,
      Attribute.passing: 1.5,
      Attribute.workRate: 1.5,
      Attribute.decisions: 1.5,
      Attribute.acceleration: 1,
      Attribute.aggression: 1,
    },
    Position.dl: {
      Attribute.tackling: 2.5,
      Attribute.positioning: 2,
      Attribute.pace: 2,
      Attribute.stamina: 2,
      Attribute.crossing: 1.5,
      Attribute.passing: 1.5,
      Attribute.workRate: 1.5,
      Attribute.decisions: 1.5,
      Attribute.acceleration: 1,
      Attribute.aggression: 1,
    },
    Position.dc: {
      Attribute.tackling: 3,
      Attribute.heading: 2.5,
      Attribute.positioning: 2.5,
      Attribute.strength: 2,
      Attribute.aggression: 1.5,
      Attribute.decisions: 1.5,
      Attribute.composure: 1,
      Attribute.pace: 1,
      Attribute.passing: 1,
    },
    Position.dmc: {
      Attribute.tackling: 2,
      Attribute.passing: 2.5,
      Attribute.positioning: 2,
      Attribute.decisions: 2,
      Attribute.vision: 1.5,
      Attribute.workRate: 1.5,
      Attribute.stamina: 1.5,
      Attribute.composure: 1,
    },
    Position.mr: {
      Attribute.crossing: 2,
      Attribute.dribbling: 2,
      Attribute.pace: 2,
      Attribute.acceleration: 1.5,
      Attribute.passing: 1.5,
      Attribute.workRate: 1.5,
      Attribute.stamina: 1,
      Attribute.technique: 1,
    },
    Position.mc: {
      Attribute.passing: 2.5,
      Attribute.vision: 2,
      Attribute.firstTouch: 1.5,
      Attribute.technique: 1.5,
      Attribute.decisions: 1.5,
      Attribute.stamina: 1.5,
      Attribute.workRate: 1.5,
      Attribute.composure: 1,
    },
    Position.ml: {
      Attribute.crossing: 2,
      Attribute.dribbling: 2,
      Attribute.pace: 2,
      Attribute.acceleration: 1.5,
      Attribute.passing: 1.5,
      Attribute.workRate: 1.5,
      Attribute.stamina: 1,
      Attribute.technique: 1,
    },
    Position.amc: {
      Attribute.technique: 2.5,
      Attribute.firstTouch: 2,
      Attribute.vision: 2.5,
      Attribute.passing: 2,
      Attribute.dribbling: 1.5,
      Attribute.composure: 1.5,
      Attribute.finishing: 1.5,
      Attribute.decisions: 1,
    },
    Position.amr: {
      Attribute.dribbling: 2.5,
      Attribute.pace: 2,
      Attribute.acceleration: 2,
      Attribute.crossing: 1.5,
      Attribute.finishing: 1.5,
      Attribute.technique: 1.5,
      Attribute.firstTouch: 1,
      Attribute.agility: 1,
    },
    Position.aml: {
      Attribute.dribbling: 2.5,
      Attribute.pace: 2,
      Attribute.acceleration: 2,
      Attribute.crossing: 1.5,
      Attribute.finishing: 1.5,
      Attribute.technique: 1.5,
      Attribute.firstTouch: 1,
      Attribute.agility: 1,
    },
    Position.st: {
      Attribute.finishing: 3,
      Attribute.positioning: 2.5,
      Attribute.composure: 2,
      Attribute.firstTouch: 1.5,
      Attribute.heading: 1.5,
      Attribute.acceleration: 1.5,
      Attribute.pace: 1.5,
      Attribute.strength: 1,
      Attribute.decisions: 1,
    },
  };

  /// Bobot satu atribut untuk satu posisi (0 jika tidak relevan).
  static double weightOf(Position position, Attribute attribute) =>
      _profiles[position]?[attribute] ?? 0;

  static int compute(Position position, PlayerAttributes attributes) {
    final profile = _profiles[position]!;
    var weightedSum = 0.0;
    var totalWeight = 0.0;
    profile.forEach((attribute, weight) {
      weightedSum += attributes[attribute] * weight;
      totalWeight += weight;
    });
    final ca = (weightedSum / totalWeight * 10).round();
    return math.max(1, math.min(200, ca));
  }
}
