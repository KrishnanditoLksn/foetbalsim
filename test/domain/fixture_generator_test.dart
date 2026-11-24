import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/models/season_models.dart';
import 'package:futbol/domain/season/fixture_generator.dart';
import 'package:futbol/domain/season/season_calendar.dart';

const _year = SeasonCalendar.firstSeasonYear;

/// Tanggal pekan sesuai tingkat liga, sama seperti GameEngine._createSchedule.
List<DateTime> _dates(int rounds, {int tier = 1}) => SeasonCalendar.roundDates(
  startYear: _year,
  rounds: rounds,
  last: tier == 1
      ? SeasonCalendar.lastLeagueRound(_year)
      : SeasonCalendar.lastSecondTierRound(_year),
);

List<Fixture> _build(int teams, {String league = 'x', int tier = 1}) {
  final ids = List<String>.generate(teams, (i) => 'club$i');
  final rounds = 2 * (teams - 1);
  return FixtureGenerator.generate(
    leagueId: league,
    clubIds: ids,
    roundSaturdays: _dates(rounds, tier: tier),
    startId: 1,
  );
}

void main() {
  group('Kalender', () {
    test('pekan 1 adalah Sabtu 15 Agustus 2026', () {
      final dates = _dates(3);
      expect(dates.first, DateTime.utc(2026, 8, 15));
      expect(dates.first.weekday, DateTime.saturday);
    });

    test('LaLiga: 38 pekan Sabtu, tanpa libur musim dingin', () {
      final dates = _dates(38);
      expect(dates.length, 38);
      for (final d in dates) {
        expect(d.weekday, DateTime.saturday, reason: '$d');
        expect(SeasonCalendar.isWinterBreak(d), isFalse, reason: '$d');
      }
      // Pekan berurutan dipisah 7 hari, kecuali saat libur (lompatan lebih).
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i].difference(dates[i - 1]).inDays >= 7, isTrue);
      }
      expect(dates.last.isAfter(SeasonCalendar.lastLeagueRound(_year)), isFalse);
    });

    test('Hypermotion: 42 pekan berurutan dalam musim (boleh midweek)', () {
      final dates = _dates(42, tier: 2);
      expect(dates.length, 42);
      for (var i = 0; i < dates.length; i++) {
        final d = dates[i];
        expect(SeasonCalendar.isWinterBreak(d), isFalse, reason: '$d');
        expect(
          d.weekday == DateTime.saturday || d.weekday == DateTime.wednesday,
          isTrue,
          reason: '$d',
        );
        if (i > 0) expect(d.isAfter(dates[i - 1]), isTrue, reason: '$d');
      }
      expect(
        dates.last.isAfter(SeasonCalendar.lastSecondTierRound(_year)),
        isFalse,
      );
    });
  });

  group('Jadwal kompetisi', () {
    test('LaLiga 20 tim → 380 laga, 38 pekan', () {
      final list = _build(20);
      expect(list.length, 380);
      expect(list.map((f) => f.round).reduce((a, b) => a > b ? a : b), 38);
    });

    test('Hypermotion 22 tim → 462 laga, 42 pekan', () {
      final list = _build(22, tier: 2);
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
      final list = _build(22, tier: 2);
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
