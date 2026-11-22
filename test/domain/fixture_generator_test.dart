import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/models/season_models.dart';
import 'package:futbol/domain/season/fixture_generator.dart';
import 'package:futbol/domain/season/season_calendar.dart';

List<Fixture> _build(int teams, {String league = 'x'}) {
  final ids = List<String>.generate(teams, (i) => 'club$i');
  final rounds = 2 * (teams - 1);
  return FixtureGenerator.generate(
    leagueId: league,
    clubIds: ids,
    roundSaturdays: SeasonCalendar.roundSaturdays(rounds),
    startId: 1,
  );
}

void main() {
  group('Kalender', () {
    test('pekan 1 adalah Sabtu 16 Agustus 2025', () {
      final sats = SeasonCalendar.roundSaturdays(3);
      expect(sats.first, DateTime.utc(2025, 8, 16));
      expect(sats.first.weekday, DateTime.saturday);
    });

    test('tidak ada pekan di masa libur musim dingin', () {
      final sats = SeasonCalendar.roundSaturdays(42);
      for (final d in sats) {
        expect(SeasonCalendar.isWinterBreak(d), isFalse, reason: '$d');
      }
      // Pekan berurutan dipisah 7 hari, kecuali saat libur (lompatan lebih).
      for (var i = 1; i < sats.length; i++) {
        expect(sats[i].difference(sats[i - 1]).inDays >= 7, isTrue);
      }
    });
  });

  group('Jadwal kompetisi', () {
    test('LaLiga 20 tim → 380 laga, 38 pekan', () {
      final list = _build(20);
      expect(list.length, 380);
      expect(list.map((f) => f.round).reduce((a, b) => a > b ? a : b), 38);
    });

    test('Hypermotion 22 tim → 462 laga, 42 pekan', () {
      final list = _build(22);
      expect(list.length, 462);
      expect(list.map((f) => f.round).reduce((a, b) => a > b ? a : b), 42);
    });

    test('tiap tim main tepat sekali per pekan', () {
      final list = _build(20);
      for (var round = 1; round <= 38; round++) {
        final inRound = list.where((f) => f.round == round).toList();
        final seen = <String>[];
        for (final f in inRound) {
          seen
            ..add(f.homeClubId)
            ..add(f.awayClubId);
        }
        expect(seen.toSet().length, 20, reason: 'pekan $round');
        expect(seen.length, 20, reason: 'pekan $round');
      }
    });

    test('tiap pasangan bertemu sekali di kandang dan sekali di tandang', () {
      final list = _build(22);
      final pairs = <String>{};
      for (final f in list) {
        final key = '${f.homeClubId}>${f.awayClubId}';
        expect(pairs.add(key), isTrue, reason: 'duplikat $key');
      }
      expect(pairs.length, 22 * 21);
    });

    test('jadwal identik bila dibuat ulang', () {
      final a = _build(20);
      final b = _build(20);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].homeClubId, b[i].homeClubId);
        expect(a[i].awayClubId, b[i].awayClubId);
        expect(a[i].date, b[i].date);
      }
    });
  });
}
