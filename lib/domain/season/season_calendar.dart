/// Kalender pekan: pekan 1 mulai Sabtu 16 Agustus 2025, satu pekan per minggu,
/// dengan libur musim dingin (22 Des – 2 Jan) yang dilewati.
abstract final class SeasonCalendar {
  static final DateTime firstRound = DateTime.utc(2025, 8, 16);

  static bool isWinterBreak(DateTime d) =>
      (d.month == 12 && d.day >= 22) || (d.month == 1 && d.day <= 2);

  /// Tanggal Sabtu untuk setiap pekan, sebanyak [rounds].
  static List<DateTime> roundSaturdays(int rounds) {
    final result = <DateTime>[];
    var candidate = firstRound;
    while (result.length < rounds) {
      if (!isWinterBreak(candidate)) result.add(candidate);
      candidate = candidate.add(const Duration(days: 7));
    }
    return result;
  }
}
