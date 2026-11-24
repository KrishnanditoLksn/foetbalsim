/// Aturan dasar pertandingan untuk Match Engine 2D (LaLiga & liga reguler).
///
/// Nilai di sini adalah satu sumber kebenaran. Waktu dihitung dalam tick
/// simulasi (1 menit permainan = 6 tick), lihat `MatchSession.ticksPerMinute`.
abstract final class MatchRules {
  // --- Pergantian -----------------------------------------------------------

  /// Kuota pergantian per tim (dari bangku cadangan).
  static const int maxSubstitutions = 5;

  /// Kesempatan berhenti (stoppage) untuk pergantian per tim. Jeda babak
  /// tidak mengurangi kuota ini.
  static const int maxSubWindows = 3;

  /// Pergantian belum memodelkan cedera kepala. Aturan concussion sub
  /// menunggu model cedera.
  static const bool concussionSubsEnabled = false;

  // --- Waktu tambahan (injury time) ----------------------------------------

  /// Waktu terbuang per kejadian, dalam tick (1 tick = 10 detik).
  static const int stoppageTicksPerSubstitution = 3; // 30 detik
  static const int stoppageTicksPerGoal = 3; // 30 detik (selebrasi)
  static const int stoppageTicksPerVarReview = 6; // 1 menit

  /// Keunggulan (advantage): wasit tidak meniup peluit akhir saat bola
  /// berbahaya di kotak penalti, diberi satu tambahan singkat per babak.
  static const int advantageTicks = 2;

  // --- VAR & Goal-Line Technology ----------------------------------------

  /// Peluang VAR meninjau keputusan penalti atau kartu merah.
  static const double varReviewChance = 0.5;

  /// Peluang keputusan wasit dibatalkan setelah ditinjau VAR.
  static const double varOverturnChance = 0.2;

  /// Peluang tembakan membentur mistar/tiang, sehingga GLT dipakai.
  static const double postHitChance = 0.03;

  // --- Disiplin --------------------------------------------------------------

  /// Peluang pelanggaran di kotak penalti pada peluang emas (DOGSO), dengan
  /// kartu merah langsung dan penalti.
  static const double dogsoChance = 0.4;

  /// Peluang pemain menjatuhkan diri (diving) saat dribel gagal di kotak.
  static const double diveChance = 0.06;

  // --- Babak tambahan --------------------------------------------------------

  /// Perpanjangan waktu dan adu penalti belum disimulasikan. Flag ini
  /// disiapkan untuk babak gugur di fase berikutnya.
  static const bool allowExtraTimeAndPenalties = false;
}
