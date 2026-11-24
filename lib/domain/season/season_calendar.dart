/// Kalender musim Eropa berbasis tahun awal musim (README_SEASON_CALENDAR).
///
/// Semua tanggal dihitung dari `startYear` (2026 untuk musim 2026/27).
/// Tidak ada tahun yang di-hardcode di luar [firstSeasonYear].
abstract final class SeasonCalendar {
  /// Karier baru selalu dimulai pada musim 2026/27.
  static const int firstSeasonYear = 2026;

  /// Label musim, mis. `2026/27`.
  static String label(int startYear) =>
      '$startYear/${((startYear + 1) % 100).toString().padLeft(2, '0')}';

  /// Tanggal save pertama dibuat (hanya musim pertama): 15 Agustus, yaitu
  /// awal pekan 1 LaLiga. Untuk musim 2026/27 = 15 Agustus 2026.
  static DateTime careerStart(int startYear) => DateTime.utc(startYear, 8, 15);

  /// Musim berikutnya dibuat 1 Juli (off-season penuh di Juni).
  static DateTime seasonStart(int startYear) => DateTime.utc(startYear, 7, 1);

  /// Musim selesai 31 Mei tahun berikutnya.
  static DateTime seasonEnd(int startYear) => DateTime.utc(startYear + 1, 5, 31);

  /// Sabtu pertama pada atau setelah 15 Agustus: pekan 1.
  static DateTime firstRound(int startYear) {
    var d = DateTime.utc(startYear, 8, 15);
    while (d.weekday != DateTime.saturday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  /// Minggu terakhir Mei: batas pekan terakhir LaLiga.
  static DateTime lastLeagueRound(int startYear) {
    var d = DateTime.utc(startYear + 1, 5, 31);
    while (d.weekday != DateTime.sunday) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  /// Batas pekan terakhir Hypermotion: 14 hari sebelum batas LaLiga, memberi
  /// ruang untuk empat tanggal playoff.
  static DateTime lastSecondTierRound(int startYear) =>
      lastLeagueRound(startYear).subtract(const Duration(days: 14));

  /// Jendela transfer musim panas: 1 Juli – 31 Agustus.
  static (DateTime, DateTime) summerWindow(int startYear) =>
      (DateTime.utc(startYear, 7, 1), DateTime.utc(startYear, 8, 31));

  /// Jendela transfer musim dingin: 1 – 31 Januari tahun berikutnya.
  static (DateTime, DateTime) winterWindow(int startYear) =>
      (DateTime.utc(startYear + 1, 1, 1), DateTime.utc(startYear + 1, 1, 31));

  static bool isWinterBreak(DateTime d) =>
      (d.month == 12 && d.day >= 22) || (d.month == 1 && d.day <= 2);

  /// Tanggal [rounds] pekan liga, berurutan, dimulai dari pekan 1 musim
  /// [startYear] dan tidak melewati [last].
  ///
  /// Pekan utama adalah Sabtu mingguan (dilewati libur musim dingin). Bila
  /// jumlah Sabtu tidak cukup, selisihnya diisi pekan **Rabu (midweek)** yang
  /// disebar merata: tidak di tiga pekan pertama/terakhir, tidak di libur
  /// musim dingin, dan tidak berdekatan dengan midweek lain.
  static List<DateTime> roundDates({
    required int startYear,
    required int rounds,
    required DateTime last,
  }) {
    final first = firstRound(startYear);
    final saturdays = <DateTime>[];
    for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 7))) {
      if (!isWinterBreak(d)) saturdays.add(d);
    }
    if (saturdays.length >= rounds) return saturdays.take(rounds).toList();

    final extra = rounds - saturdays.length;
    // Kandidat midweek: Rabu di minggu yang sama dengan Sabtu, dengan jarak
    // dari awal dan akhir musim, serta di luar libur musim dingin.
    final weeks = <DateTime>[];
    for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 7))) {
      final wed = d.subtract(const Duration(days: 3));
      if (!isWinterBreak(wed) && !wed.isBefore(first)) weeks.add(wed);
    }
    final candidates = weeks.length <= 6
        ? <DateTime>[]
        : weeks.sublist(3, weeks.length - 3);
    if (candidates.length < extra * 2) {
      throw StateError(
        'Tidak cukup pekan untuk $rounds pekan sampai ${last.toIso8601String()}.',
      );
    }
    final midweeks = <DateTime>[
      for (var i = 0; i < extra; i++)
        candidates[((i + 0.5) * candidates.length / extra).floor()],
    ];
    final all = [...saturdays, ...midweeks]..sort();
    return all;
  }
}
