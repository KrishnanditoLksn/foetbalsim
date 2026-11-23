import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/tactics.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/match/lineup_builder.dart';
import 'package:futbol/domain/match/match_engine_2d.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/match_models.dart';
import 'package:futbol/features/match/pitch_animator.dart';

PlayerDot dot(int index, double x, double y) => PlayerDot(
  index: index,
  playerId: index + 100,
  isHome: index < 11,
  shirt: index + 1,
  x: x,
  y: y,
);

void main() {
  group('Pemain', () {
    test('berinterpolasi dari awal ke akhir tick', () {
      final a = PitchAnimator()
        ..setTick(
          from: [dot(0, 0.2, 0.5)],
          to: [dot(0, 0.6, 0.5)],
          path: const [],
          carrier: -1,
          tickStart: 0,
        );
      a.update(0);
      expect(a.poses.first.x, closeTo(0.2, 1e-9));
      a.update(0.5);
      expect(a.poses.first.x, closeTo(0.4, 1e-9));
      a.update(1);
      expect(a.poses.first.x, closeTo(0.6, 1e-9));
    });

    test('retarget menjaga pemain lama dan memunculkan pemain baru', () {
      final a = PitchAnimator()
        ..snap(
          [dot(0, 0.2, 0.5), dot(1, 0.3, 0.5)],
          ballX: 0.5,
          ballY: 0.5,
          carrier: 0,
        )
        ..retarget([dot(1, 0.3, 0.5), dot(2, 0.4, 0.4)], carrier: 1);
      expect(a.poses.map((p) => p.dot.index).toList(), [1, 2]);
      expect(a.poses.last.x, closeTo(0.4, 1e-12));
    });

    test('pose diurutkan per indeks', () {
      final a = PitchAnimator()
        ..snap(
          [dot(5, 0.5, 0.5), dot(2, 0.2, 0.2)],
          ballX: 0.5,
          ballY: 0.5,
          carrier: 5,
        );
      expect(a.poses.map((p) => p.dot.index).toList(), [2, 5]);
    });
  });

  group('Bola', () {
    test('umpan di udara mulai dan berhenti dengan lembut (ease-in-out)', () {
      // Panjang 0,5 → durasi 1,7 tick. Pada 10% durasi, bola harus lebih
      // dekat ke titik awal daripada gerak linier.
      final a = PitchAnimator()
        ..setTick(
          from: [dot(0, 0.5, 0.5)],
          to: [dot(0, 0.5, 0.5)],
          path: const [BallWaypoint(0.1, 0.5), BallWaypoint(0.6, 0.5)],
          carrier: -1,
          tickStart: 0,
        );
      a.update(0.17); // ≈ 10% dari 1,7 tick
      final linear = 0.1 + 0.5 * 0.1;
      expect(a.ballX, lessThan(linear - 0.005));

      a.update(0.85); // ≈ 50%: tepat di tengah
      expect(a.ballX, closeTo(0.35, 0.01));

      a.update(1.7);
      expect(a.ballX, closeTo(0.6, 1e-9));
    });

    test('menggiring bergulir linier dan pemain pembawa menempel', () {
      final a = PitchAnimator()
        ..setTick(
          from: [dot(0, 0.3, 0.5), dot(11, 0.9, 0.5)],
          to: [dot(0, 0.4, 0.5), dot(11, 0.9, 0.5)],
          path: const [
            BallWaypoint(0.3, 0.5, owner: 0),
            BallWaypoint(0.4, 0.5, owner: 0),
          ],
          carrier: 0,
          tickStart: 0,
        );
      // Durasi gulir 0,5 tick; pada 0,25 tick bola di tengah (linier).
      a.update(0.25);
      expect(a.ballX, closeTo(0.35, 1e-9));
      final p0 = a.poses.firstWhere((p) => p.dot.index == 0);
      expect(p0.x, closeTo(a.ballX, 1e-9));
      expect(p0.y, closeTo(a.ballY, 1e-9));
    });

    test('umpan tidak menarik pengumpan ke posisi bola', () {
      final a = PitchAnimator()
        ..setTick(
          from: [dot(0, 0.3, 0.5), dot(11, 0.9, 0.5)],
          to: [dot(0, 0.3, 0.5), dot(11, 0.9, 0.5)],
          path: const [
            BallWaypoint(0.3, 0.5, owner: 0),
            BallWaypoint(0.5, 0.5, owner: -1),
            BallWaypoint(0.9, 0.5, owner: 11),
          ],
          carrier: 11,
          tickStart: 0,
        );
      a.update(0.3);
      final p0 = a.poses.firstWhere((p) => p.dot.index == 0);
      expect(p0.x, closeTo(0.3, 1e-9));
      expect(a.ballX, greaterThan(0.3));
    });

    test('timeline bola tidak tertinggal jauh saat tick berturut-turut', () {
      final a = PitchAnimator()
        ..snap([dot(0, 0.5, 0.5)], ballX: 0.1, ballY: 0.5, carrier: -1);
      for (var k = 0; k < 60; k++) {
        a.setTick(
          from: [dot(0, 0.5, 0.5)],
          to: [dot(0, 0.5, 0.5)],
          path: const [BallWaypoint(0.1, 0.5), BallWaypoint(0.6, 0.5)],
          carrier: -1,
          tickStart: k.toDouble(),
        );
        a.update(k + 1.0);
      }
      expect(a.ballLag, lessThan(2.5));
    });
  });

  group('Notifikasi', () {
    test('update hanya memberi notifikasi bila tampilan berubah', () {
      final a = PitchAnimator()
        ..setTick(
          from: [dot(0, 0.2, 0.5)],
          to: [dot(0, 0.6, 0.5)],
          path: const [],
          carrier: -1,
          tickStart: 0,
        );
      var notes = 0;
      a.addListener(() => notes++);
      a.update(0.25);
      a.update(0.25);
      a.update(0.25);
      expect(notes, 1);
    });
  });

  test('laga nyata: lintasan bola dari engine dapat dijadwalkan', () {
    final seedJson = File('assets/seed/spain.json').readAsStringSync();
    final world = WorldGenerator.generate(seedJson: seedJson, seed: 7);
    List<Player> squad(String id) =>
        world.players.where((p) => p.clubId == id).toList();
    final h = LineupBuilder.auto(squad('real-madrid'), Formation.f442);
    final a = LineupBuilder.auto(squad('barcelona'), Formation.f433);
    final s = MatchSession(
      seed: 3,
      fixtureId: 39,
      home: MatchTeamSetup(
        clubId: 'real-madrid',
        name: 'R',
        formation: Formation.f442,
        mentality: Mentality.balanced,
        starters: h.starters,
        bench: h.bench,
      ),
      away: MatchTeamSetup(
        clubId: 'barcelona',
        name: 'B',
        formation: Formation.f433,
        mentality: Mentality.balanced,
        starters: a.starters,
        bench: a.bench,
      ),
    );
    final anim = PitchAnimator()
      ..snap(s.currentDots(), ballX: s.ballX, ballY: s.ballY, carrier: s.carrierIndex);
    var clock = 0.0;
    for (var k = 0; k < 120; k++) {
      final f = s.stepTick();
      anim.setTick(
        from: f.from,
        to: f.to,
        path: f.ballPath,
        carrier: f.carrierIndex,
        tickStart: (f.tick - 1).toDouble(),
      );
      clock = (f.tick - 1).toDouble();
      for (var j = 0; j <= 4; j++) {
        anim.update(clock + j / 4);
        for (final p in anim.poses) {
          expect(p.x.isFinite && p.y.isFinite, isTrue);
          expect(p.x, inInclusiveRange(0.0, 1.0));
          expect(p.y, inInclusiveRange(0.0, 1.0));
        }
      }
    }
    expect(anim.ballLag, lessThan(3.0));
  });
}
