import '../models/season_models.dart';

/// Jadwal kompetisi penuh kandang-tandang dengan metode circle (Berger).
///
/// n tim → 2(n−1) pekan, n/2 laga per pekan. Separuh laga tiap pekan
/// dimainkan Sabtu, sisanya Minggu.
abstract final class FixtureGenerator {
  static List<Fixture> generate({
    required String leagueId,
    required List<String> clubIds,
    required List<DateTime> roundSaturdays,
    required int startId,
  }) {
    final n = clubIds.length;
    if (n < 2 || n.isOdd) {
      throw ArgumentError('Jumlah tim harus genap dan minimal 2.');
    }
    final half = n ~/ 2;
    final singleRounds = n - 1;
    final totalRounds = 2 * singleRounds;
    if (roundSaturdays.length < totalRounds) {
      throw ArgumentError('Kalender pekan kurang dari $totalRounds.');
    }

    // Pasangan setengah musim pertama (indeks ke clubIds).
    final order = List<int>.generate(n, (i) => i);
    final pairings = <List<(int, int)>>[];
    for (var r = 0; r < singleRounds; r++) {
      final pairs = <(int, int)>[];
      for (var i = 0; i < half; i++) {
        var (home, away) = (order[i], order[n - 1 - i]);
        if (i == 0 && r.isOdd) (home, away) = (away, home);
        pairs.add((home, away));
      }
      pairings.add(pairs);
      // Rotasi semua tim kecuali indeks 0.
      final last = order.removeLast();
      order.insert(1, last);
    }

    final satCount = (half + 1) ~/ 2;
    final result = <Fixture>[];
    var id = startId;
    for (var round = 0; round < totalRounds; round++) {
      final swap = round >= singleRounds;
      final pairs = pairings[round % singleRounds];
      final saturday = roundSaturdays[round];
      for (var i = 0; i < half; i++) {
        var (home, away) = pairs[i];
        if (swap) (home, away) = (away, home);
        result.add(
          Fixture(
            id: id++,
            leagueId: leagueId,
            round: round + 1,
            date: saturday.add(Duration(days: i < satCount ? 0 : 1)),
            homeClubId: clubIds[home],
            awayClubId: clubIds[away],
          ),
        );
      }
    }
    return result;
  }
}
