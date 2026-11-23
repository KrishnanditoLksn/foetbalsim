import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/tactics.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/match/lineup_builder.dart';
import 'package:futbol/domain/match/match_engine_2d.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/match_models.dart';

class _Run {
  /// Posisi per pemain per menit (indeks pemain → daftar posisi).
  final Map<int, List<PlayerDot>> positions = {};

  /// Pembawa bola pada tiap menit (indeks pemain).
  final List<int> carriers = [];
}

_Run _simulate(int seed) {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final world = WorldGenerator.generate(seedJson: seedJson, seed: 7);
  List<Player> squad(String id) =>
      world.players.where((p) => p.clubId == id).toList();
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
  final run = _Run();
  while (!s.finished) {
    s.step();
    run.carriers.add(s.carrierIndex);
    for (final d in s.currentDots()) {
      run.positions.putIfAbsent(d.index, () => []).add(d);
    }
  }
  return run;
}

void main() {
  test('setiap pemain bergerak terbatas per menit (tidak loncat)', () {
    for (var seed = 1; seed <= 3; seed++) {
      final run = _simulate(seed);
      run.positions.forEach((index, list) {
        for (var m = 1; m < list.length; m++) {
          // Pembawa bola ikut bergerak bersama bola (boleh lebih jauh).
          if (run.carriers[m] == index || run.carriers[m - 1] == index) {
            continue;
          }
          expect(
            (list[m].x - list[m - 1].x).abs(),
            lessThanOrEqualTo(0.11),
            reason: 'pemain $index menit $m',
          );
          expect(
            (list[m].y - list[m - 1].y).abs(),
            lessThanOrEqualTo(0.11),
            reason: 'pemain $index menit $m',
          );
        }
      });
    }
  });

  test('gerak maju-mundur bolak-balik berkurang (di bawah 45%)', () {
    // Catatan: sebelum inersia posisi rasio ini sekitar 69%. Sisanya berasal
    // dari bola yang sering berpindah sisi lapangan antar menit.
    var pairs = 0;
    var reversals = 0;
    for (var seed = 1; seed <= 3; seed++) {
      final run = _simulate(seed);
      run.positions.forEach((index, list) {
        for (var m = 2; m < list.length; m++) {
          if (run.carriers[m] == index ||
              run.carriers[m - 1] == index ||
              run.carriers[m - 2] == index) {
            continue;
          }
          final d1 = list[m - 1].x - list[m - 2].x;
          final d2 = list[m].x - list[m - 1].x;
          if (d1.abs() > 0.01 && d2.abs() > 0.01) {
            pairs++;
            if ((d1 > 0) != (d2 > 0)) reversals++;
          }
        }
      });
    }
    final ratio = reversals / pairs;
    // ignore: avoid_print
    print('reversal ratio = ${ratio.toStringAsFixed(3)} ($reversals/$pairs)');
    expect(ratio, lessThan(0.45));
  });

  test('pemain tidak beku: rata-rata gerak per menit cukup terlihat', () {
    var moveSum = 0.0;
    var moveN = 0;
    for (var seed = 1; seed <= 3; seed++) {
      final run = _simulate(seed);
      run.positions.forEach((index, list) {
        for (var m = 1; m < list.length; m++) {
          if (run.carriers[m] == index || run.carriers[m - 1] == index) {
            continue;
          }
          moveSum += (list[m].x - list[m - 1].x).abs();
          moveN++;
        }
      });
    }
    final avg = moveSum / moveN;
    // ignore: avoid_print
    print('rata-rata gerak per menit = ${avg.toStringAsFixed(4)}');
    expect(avg, greaterThan(0.005));
  });
}
