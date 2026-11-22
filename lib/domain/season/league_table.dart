import 'dart:math' as math;

import '../models/season_models.dart';

/// Klasemen dihitung dari hasil laga (tidak disimpan di database).
abstract final class LeagueTable {
  /// Target posisi dari reputasi: reputasi tinggi → target lebih tinggi.
  static int targetPosition(int reputation, int teams) =>
      math.max(1, math.min(teams, (teams * (1 - reputation / 100)).round()));

  static List<LeagueTableRow> compute({
    required List<String> clubIds,
    required List<Fixture> fixtures,
  }) {
    final acc = {for (final id in clubIds) id: _Acc()};
    final played =
        fixtures.where((f) => f.played).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    for (final f in played) {
      final home = acc[f.homeClubId];
      final away = acc[f.awayClubId];
      if (home == null || away == null) continue;
      home.add(f.homeGoals!, f.awayGoals!);
      away.add(f.awayGoals!, f.homeGoals!);
    }

    final rows = [for (final id in clubIds) acc[id]!.toRow(id)];
    rows.sort((x, y) {
      var c = y.points.compareTo(x.points);
      if (c == 0) c = y.goalDiff.compareTo(x.goalDiff);
      if (c == 0) c = y.goalsFor.compareTo(x.goalsFor);
      if (c == 0) c = x.clubId.compareTo(y.clubId);
      return c;
    });
    return rows;
  }
}

class _Acc {
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int gf = 0;
  int ga = 0;
  final List<String> _form = [];

  void add(int goalsFor, int goalsAgainst) {
    played++;
    gf += goalsFor;
    ga += goalsAgainst;
    final result =
        goalsFor > goalsAgainst
            ? 'W'
            : goalsFor == goalsAgainst
            ? 'D'
            : 'L';
    if (result == 'W') {
      won++;
    } else if (result == 'D') {
      drawn++;
    } else {
      lost++;
    }
    _form.add(result);
  }

  LeagueTableRow toRow(String clubId) => LeagueTableRow(
    clubId: clubId,
    played: played,
    won: won,
    drawn: drawn,
    lost: lost,
    goalsFor: gf,
    goalsAgainst: ga,
    points: won * 3 + drawn,
    form:
        _form.length > 5
            ? _form.sublist(_form.length - 5)
            : List<String>.of(_form),
  );
}
