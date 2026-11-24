import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/tactics.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/match/lineup_builder.dart';
import 'package:futbol/domain/match/match_engine_2d.dart';
import 'package:futbol/domain/match/match_rules.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/match_models.dart';

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

void _playOut(MatchSession s) {
  while (!s.finished) {
    s.stepTick();
  }
}

void main() {
  group('Pergantian', () {
    test('pergantian hanya bisa saat kesempatan pergantian dibuka', () {
      final s = _session(1);
      for (var i = 0; i < 10; i++) {
        s.stepTick();
      }
      final out = s.onPitch(true).first;
      final inn = s.benchPlayers(true).first;
      expect(
        () => s.substitute(true, out.id, inn.id),
        throwsStateError,
      );
      s.openSubWindow(true);
      s.substitute(true, out.id, inn.id);
      expect(s.subsUsed(true), 1);
    });

    test('maksimal tiga kesempatan berhenti per tim', () {
      final s = _session(2);
      for (var i = 0; i < 10; i++) {
        s.stepTick();
      }
      for (var k = 0; k < MatchRules.maxSubWindows; k++) {
        s.openSubWindow(true);
        s.closeSubWindow();
      }
      expect(s.windowsUsed(true), MatchRules.maxSubWindows);
      expect(() => s.openSubWindow(true), throwsStateError);
      // Tim lawan punya kuota sendiri.
      s.openSubWindow(false);
      expect(s.windowsUsed(false), 1);
    });

    test('pergantian tidak melebihi lima per tim', () {
      final s = _session(3);
      for (var i = 0; i < 10; i++) {
        s.stepTick();
      }
      s.openSubWindow(true);
      for (var k = 0; k < MatchRules.maxSubstitutions; k++) {
        final out = s.onPitch(true).last;
        final inn = s.benchPlayers(true).first;
        s.substitute(true, out.id, inn.id);
      }
      final out = s.onPitch(true).last;
      expect(
        () => s.substitute(true, out.id, s.benchPlayers(true).first.id),
        throwsStateError,
      );
    });
  });

  group('Jeda babak dan waktu tambahan', () {
    test('jeda babak berhenti di akhir babak pertama dan pergantian bebas', () {
      final s = _session(4);
      while (!s.isHalfTimeBreak && !s.finished) {
        s.stepTick();
      }
      expect(s.isHalfTimeBreak, isTrue);
      final out = s.onPitch(false).first;
      final inn = s.benchPlayers(false).first;
      // Saat jeda tidak perlu membuka kesempatan dan tidak memakai kuota.
      s.substitute(false, out.id, inn.id);
      expect(s.windowsUsed(false), 0);
    });

    test('babak kedua dimulai dari menit 46 dan peluit akhir di menit 90 atau lebih', () {
      final s = _session(6);
      while (!s.isHalfTimeBreak) {
        s.stepTick();
      }
      s.stepTick();
      _playOut(s);
      final full = s.events.firstWhere((e) => e.type == MatchEventType.fullTime);
      expect(full.minute, MatchSession.fullMinutes);
      expect(full.extra, greaterThanOrEqualTo(0));
    });

    test('label menit tambahan muncul sebagai "45+x" atau "90+x"', () {
      var sawExtra = false;
      for (var seed = 1; seed <= 6; seed++) {
        final s = _session(seed);
        _playOut(s);
        for (final e in s.events) {
          if (e.extra > 0) {
            sawExtra = true;
            expect(e.label, matches(RegExp(r"^(45|90)\+\d+'$")));
          }
        }
      }
      expect(sawExtra, isTrue);
    });

    test('laga dengan waktu tambahan lebih panjang dari 90 menit', () {
      var longer = 0;
      for (var seed = 1; seed <= 6; seed++) {
        final s = _session(seed);
        _playOut(s);
        final r = s.result(fixtureId: seed);
        expect(r.matchMinutes, greaterThanOrEqualTo(90));
        if (r.matchMinutes > 90) longer++;
      }
      expect(longer, greaterThan(0));
    });
  });

  group('Offside, penalti, VAR, dan disiplin', () {
    test('offside tercatat dan garis offside muncul pada tick yang sama', () {
      var offsides = 0;
      var linesOnSameTick = 0;
      for (var seed = 1; seed <= 6; seed++) {
        final s = _session(seed);
        while (!s.finished) {
          final f = s.stepTick();
          final hasOffside = f.events.any((e) => e.type == MatchEventType.offside);
          if (hasOffside) {
            offsides++;
            if (f.offsideX != null) linesOnSameTick++;
          }
          expect(f.offsideX == null || hasOffside, isTrue);
        }
      }
      expect(offsides, greaterThan(0));
      expect(linesOnSameTick, offsides);
    });

    test('penalti selalu diikuti gol atau penyelamatan', () {
      var penalties = 0;
      for (var seed = 1; seed <= 30; seed++) {
        final s = _session(seed);
        _playOut(s);
        final ev = s.events;
        for (var i = 0; i < ev.length; i++) {
          if (ev[i].type != MatchEventType.penalty) continue;
          penalties++;
          // Setelah penalti (kadang diselingi info VAR) harus ada hasil.
          final after = ev.skip(i + 1).take(4).map((e) => e.type);
          expect(
            after.any(
              (t) => t == MatchEventType.goal || t == MatchEventType.save,
            ),
            isTrue,
            reason: 'seed $seed, penalti menit ${ev[i].minute}',
          );
        }
      }
      // Jalur penalti harus benar-benar pernah terpicu di rentang seed ini.
      expect(penalties, greaterThanOrEqualTo(1));
    });

    test('statistik tetap konsisten dengan penalti, mistar, dan GLT', () {
      for (var seed = 1; seed <= 10; seed++) {
        final s = _session(seed);
        _playOut(s);
        final r = s.result(fixtureId: seed);
        expect(r.stats.home.onTarget, r.homeGoals + r.stats.away.saves);
        expect(r.stats.away.onTarget, r.awayGoals + r.stats.home.saves);
        expect(r.stats.home.onTarget, lessThanOrEqualTo(r.stats.home.shots));
        expect(r.stats.away.onTarget, lessThanOrEqualTo(r.stats.away.shots));
      }
    });

    test('kartu merah langsung dan dua kuning tidak merusak hitungan pemain', () {
      for (var seed = 1; seed <= 10; seed++) {
        final s = _session(seed);
        _playOut(s);
        final sentOff = s.events.where((e) => e.type == MatchEventType.red).length;
        expect(sentOff, lessThanOrEqualTo(4));
        expect(s.onPitch(true).length, greaterThanOrEqualTo(7));
        expect(s.onPitch(false).length, greaterThanOrEqualTo(7));
      }
    });
  });
}
