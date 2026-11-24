import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/tactics.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/match/lineup_builder.dart';
import 'package:futbol/domain/match/match_engine_2d.dart';
import 'package:futbol/domain/models/game_models.dart';

void main() {
  test('lintasan bola berisi sentuhan menggiring dan umpan di udara', () {
    final seedJson = File('assets/seed/spain.json').readAsStringSync();
    final world = WorldGenerator.generate(seedJson: seedJson, seed: 7);
    List<Player> squad(String id) =>
        world.players.where((p) => p.clubId == id).toList();

    var dribbleSteps = 0;
    var airPoints = 0;
    for (var seed = 1; seed <= 3; seed++) {
      final h = LineupBuilder.auto(squad('real-madrid'), Formation.f442);
      final a = LineupBuilder.auto(squad('barcelona'), Formation.f433);
      final s = MatchSession(
        seed: seed,
        fixtureId: seed * 13,
        home: MatchTeamSetup(
          clubId: 'real-madrid',
          name: 'Real Madrid',
          formation: Formation.f442,
          mentality: Mentality.balanced,
          starters: h.starters,
          bench: h.bench,
        ),
        away: MatchTeamSetup(
          clubId: 'barcelona',
          name: 'Barcelona',
          formation: Formation.f433,
          mentality: Mentality.balanced,
          starters: a.starters,
          bench: a.bench,
        ),
      );

      ({double x, double y})? prev;
      while (!s.finished) {
        final f = s.stepTick();
        final path = f.ballPath;
        if (prev != null) {
          // Lintasan selalu mulai dari posisi bola tick sebelumnya.
          expect(path.first.x, closeTo(prev.x, 1e-9));
          expect(path.first.y, closeTo(prev.y, 1e-9));
        }
        for (var i = 0; i < path.length; i++) {
          if (path[i].owner == -1) airPoints++;
          if (i > 0 &&
              path[i].owner >= 0 &&
              path[i - 1].owner == path[i].owner) {
            dribbleSteps++;
          }
        }
        prev = (x: f.ballToX, y: f.ballToY);
      }
    }
    expect(dribbleSteps, greaterThan(0));
    expect(airPoints, greaterThan(0));
  });
}

