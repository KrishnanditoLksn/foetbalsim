import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/tactics.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/match/lineup_builder.dart';
import 'package:futbol/domain/match/match_engine_2d.dart';
import 'package:futbol/domain/models/game_models.dart';

MatchSession _session(int seed) {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final world = WorldGenerator.generate(seedJson: seedJson, seed: 7);
  List<Player> squad(String id) =>
      world.players.where((p) => p.clubId == id).toList();
  final h = LineupBuilder.auto(squad('real-madrid'), Formation.f442);
  final a = LineupBuilder.auto(squad('barcelona'), Formation.f433);
  return MatchSession(
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
}

void main() {
  test('laga berakhir minimal 540 tick (90 menit) ditambah waktu tambahan', () {
    final s = _session(1);
    var ticks = 0;
    while (!s.finished) {
      s.stepTick();
      ticks++;
    }
    expect(ticks, greaterThanOrEqualTo(MatchSession.totalTicks));
    expect(ticks, s.tick);
    expect(s.minute, greaterThanOrEqualTo(MatchSession.fullMinutes));
  });

  test('menjalankan per tick menghasilkan laga yang sama dengan per menit', () {
    final byMinute = _session(5);
    while (!byMinute.finished) {
      byMinute.step();
    }
    final byTick = _session(5);
    while (!byTick.finished) {
      byTick.stepTick();
    }
    final a = byMinute.result(fixtureId: 1);
    final b = byTick.result(fixtureId: 1);
    expect(b.homeGoals, a.homeGoals);
    expect(b.awayGoals, a.awayGoals);
    expect(b.events.length, a.events.length);
    for (var i = 0; i < a.events.length; i++) {
      expect(b.events[i].text, a.events[i].text);
    }
  });

  test('peristiwa paruh waktu dan akhir tercatat pada menit yang benar', () {
    final s = _session(2);
    while (!s.finished) {
      s.stepTick();
    }
    final half = s.events.firstWhere((e) => e.text.startsWith('Turun minum'));
    final full = s.events.firstWhere((e) => e.text.startsWith('Peluit akhir'));
    expect(half.minute, 45);
    expect(full.minute, 90);
  });
}
