/// Skor minat klub pada kandidat pemain klub lain (README_FASE3 B.10.3):
///
/// Skor = 35%·KecocokanKebutuhan + 25%·PeningkatanKualitas
///      + 15%·KecocokanProfil + 15%·Keterjangkauan + 10%·Peluang
enum InterestLevel { none, watching, interested, target }

class InterestEngine {
  /// Skor 0–100 dari lima komponen (masing-masing 0–100).
  static int score({
    required int needFit,
    required int upgrade,
    required int profileFit,
    required int affordability,
    required int opportunity,
  }) {
    final s =
        0.35 * needFit +
        0.25 * upgrade +
        0.15 * profileFit +
        0.15 * affordability +
        0.10 * opportunity;
    return s.round().clamp(0, 100).toInt();
  }

  /// 0–39 diabaikan · 40–59 memantau · 60–79 tertarik · 80–100 target utama.
  static InterestLevel levelFor(int score) {
    if (score >= 80) return InterestLevel.target;
    if (score >= 60) return InterestLevel.interested;
    if (score >= 40) return InterestLevel.watching;
    return InterestLevel.none;
  }

  /// Meluruh 5 poin per minggu bila tidak ditindaklanjuti.
  static int decay(int score, {int weeks = 1}) =>
      (score - 5 * weeks).clamp(0, 100).toInt();
}
