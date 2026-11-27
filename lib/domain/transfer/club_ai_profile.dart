import '../../l10n/l10n.dart';
import '../../core/rng/seeded_random.dart';
import '../models/game_models.dart';

/// Kepribadian klub AI di bursa (README_FASE3 B.2).
enum ClubPersonality {
  bigSpender,
  sellingClub,
  moneyball,
  youthDeveloper,
  survivalMode;

  String get label => tr('clubPersonality.$name');
}

/// Profil klub AI. Atribut 0–100 (README B.2).
class ClubAiProfile {
  const ClubAiProfile({
    required this.clubId,
    required this.personality,
    required this.ambition,
    required this.riskTolerance,
    required this.negotiationSkill,
    required this.sellingWillingness,
    required this.youthFocus,
  });

  final String clubId;
  final ClubPersonality personality;
  final int ambition;
  final int riskTolerance;
  final int negotiationSkill;
  final int sellingWillingness;
  final int youthFocus;

  /// Profil diturunkan dari reputasi, saldo, dan seed. Deterministik.
  static ClubAiProfile derive({required Club club, required int seed}) {
    final rng = SeededRandom(seed ^ _hash(club.id));
    final rep = club.reputation;
    final ClubPersonality personality;
    if (club.balance < 0) {
      personality = ClubPersonality.survivalMode;
    } else if (rep >= 80) {
      personality = ClubPersonality.bigSpender;
    } else if (rep <= 55) {
      personality =
          rng.chance(0.5)
              ? ClubPersonality.youthDeveloper
              : ClubPersonality.moneyball;
    } else {
      personality = rng.pick(const [
        ClubPersonality.sellingClub,
        ClubPersonality.moneyball,
        ClubPersonality.youthDeveloper,
      ]);
    }

    int jitter(int base, int spread) =>
        (base + rng.range(-spread, spread)).clamp(0, 100).toInt();

    return ClubAiProfile(
      clubId: club.id,
      personality: personality,
      ambition: jitter(rep, 10),
      riskTolerance: jitter(40, 30),
      negotiationSkill: jitter(40 + rep ~/ 2, 10),
      sellingWillingness:
          personality == ClubPersonality.sellingClub
              ? jitter(75, 10)
              : jitter(35, 15),
      youthFocus:
          personality == ClubPersonality.youthDeveloper
              ? jitter(80, 10)
              : jitter(30, 15),
    );
  }

  /// Hash FNV-1a 32-bit untuk nama klub (stabil lintas proses).
  static int _hash(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7FFFFFFF;
    }
    return h;
  }
}
