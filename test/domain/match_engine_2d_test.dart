import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/tactics.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/match/lineup_builder.dart';
import 'package:futbol/domain/match/match_engine_2d.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/match_models.dart';

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final world = WorldGenerator.generate(seedJson: seedJson, seed: 7);
  List<Player> squadOf(String id) =>
      world.players.where((p) => p.clubId == id).toList();

  MatchSession newSession({int seed = 1, int fixtureId = 13}) {
    final h = LineupBuilder.auto(squadOf('real-madrid'), Formation.f442);
    final a = LineupBuilder.auto(squadOf('barcelona'), Formation.f433);
    return MatchSession(
      seed: seed,
      fixtureId: fixtureId,
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

  void playOut(MatchSession s) {
    while (!s.finished) {
      s.step();
    }
  }

  test('seed dan id laga sama menghasilkan laga yang identik', () {
    final a = newSession(seed: 42, fixtureId: 5)..also(playOut);
    final b = newSession(seed: 42, fixtureId: 5)..also(playOut);
    final ra = a.result(fixtureId: 5);
    final rb = b.result(fixtureId: 5);
    expect(ra.homeGoals, rb.homeGoals);
    expect(ra.awayGoals, rb.awayGoals);
    expect(ra.events.length, rb.events.length);
    for (var i = 0; i < ra.events.length; i++) {
      expect(ra.events[i].text, rb.events[i].text);
      expect(ra.events[i].minute, rb.events[i].minute);
    }
  });

  test('seed berbeda menghasilkan jalannya laga berbeda', () {
    final texts = <String>{};
    for (var seed = 1; seed <= 5; seed++) {
      final s = newSession(seed: seed)..also(playOut);
      texts.add(s.events.map((e) => e.text).join('|'));
    }
    expect(texts.length, greaterThan(1));
  });

  test('statistik konsisten dan skor wajar dalam rentang banyak seed', () {
    var totalGoals = 0;
    const runs = 20;
    for (var seed = 1; seed <= runs; seed++) {
      final s = newSession(seed: seed, fixtureId: seed * 7)..also(playOut);
      final r = s.result(fixtureId: seed * 7);
      totalGoals += r.homeGoals + r.awayGoals;

      // Setiap tembakan tepat sasaran berakhir gol atau penyelamatan.
      expect(r.stats.home.onTarget, r.homeGoals + r.stats.away.saves);
      expect(r.stats.away.onTarget, r.awayGoals + r.stats.home.saves);
      expect(r.stats.home.onTarget, lessThanOrEqualTo(r.stats.home.shots));
      expect(r.stats.away.onTarget, lessThanOrEqualTo(r.stats.away.shots));

      // Jumlah gol di komentar sama dengan skor.
      final goalEvents = r.events.where((e) => e.type == MatchEventType.goal);
      expect(goalEvents.length, r.homeGoals + r.awayGoals);
      expect(r.homeScorerNames.length, r.homeGoals);
      expect(r.awayScorerNames.length, r.awayGoals);

      expect(r.stats.homePossession + r.stats.awayPossession, 100);
      expect(r.events.first.type, MatchEventType.kickOff);
      expect(
        r.events.where((e) => e.type == MatchEventType.fullTime).length,
        1,
      );
      expect(
        r.events.where((e) => e.type == MatchEventType.halfTime).length,
        1,
      );
    }
    // Rata-rata gol per laga dalam rentang sepakbola yang masuk akal.
    final avg = totalGoals / runs;
    expect(avg, inInclusiveRange(1.5, 5.0));
  });

  test('starter yang bermain penuh tercatat 90 menit', () {
    final s = newSession(seed: 3)..also(playOut);
    final r = s.result(fixtureId: 13);
    final starters = [
      ...LineupBuilder.auto(squadOf('real-madrid'), Formation.f442).starters,
      ...LineupBuilder.auto(squadOf('barcelona'), Formation.f433).starters,
    ];
    final redCards = r.stats.home.red + r.stats.away.red;
    if (redCards == 0) {
      for (final p in starters) {
        expect(r.minutesPlayed[p.id], r.matchMinutes, reason: p.fullName);
      }
    }
  });

  test('pergantian: masuk dari bangku, keluar dari lapangan, maks 5', () {
    final s = newSession(seed: 9);
    s.openSubWindow(true);
    for (var i = 0; i < 30; i++) {
      s.step();
    }
    final out = s.onPitch(true).first;
    final inn = s.benchPlayers(true).first;
    s.substitute(true, out.id, inn.id);
    expect(s.onPitch(true).any((p) => p.id == inn.id), isTrue);
    expect(s.onPitch(true).any((p) => p.id == out.id), isFalse);
    expect(s.subsUsed(true), 1);

    // Pemain yang sudah keluar tidak bisa keluar lagi.
    expect(
      () => s.substitute(true, out.id, s.benchPlayers(true).first.id),
      throwsStateError,
    );

    for (var k = 0; k < 4; k++) {
      final o = s.onPitch(true).last;
      final i = s.benchPlayers(true).first;
      s.substitute(true, o.id, i.id);
    }
    expect(s.subsLeft(true), 0);
    final o = s.onPitch(true).last;
    expect(
      () => s.substitute(true, o.id, s.benchPlayers(true).first.id),
      throwsStateError,
    );
    playOut(s);
    final r = s.result(fixtureId: 13);
    // Menit bermain tidak melebihi panjang laga (termasuk waktu tambahan).
    expect(r.minutesPlayed.values.every((m) => m >= 0 && m <= r.matchMinutes), isTrue);
  });

  test('ubah mentalitas tercatat di komentar dan laga tetap berjalan', () {
    final s = newSession(seed: 11);
    for (var i = 0; i < 20; i++) {
      s.step();
    }
    s.setMentality(true, Mentality.attacking);
    expect(s.mentality(true), Mentality.attacking);
    playOut(s);
    expect(
      s.events.any((e) => e.type == MatchEventType.mentality),
      isTrue,
    );
  });

  test('result tidak bisa diambil sebelum laga selesai', () {
    final s = newSession();
    s.step();
    expect(() => s.result(fixtureId: 1), throwsStateError);
  });
}

extension _Also<T> on T {
  T also(void Function(T) f) {
    f(this);
    return this;
  }
}
