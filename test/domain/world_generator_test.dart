import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/position.dart';
import 'package:futbol/domain/generators/current_ability.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';

String _fingerprint(WorldBlueprint w) {
  final buf = StringBuffer();
  for (final p in w.players) {
    buf.write(
      '${p.id}|${p.clubId}|${p.firstName} ${p.lastName}|${p.age}|'
      '${p.position.name}|${p.currentAbility}|${p.potentialAbility}|'
      '${p.marketValue}|',
    );
    for (final e in p.attributes.values.entries) {
      buf.write('${e.key.name}=${e.value},');
    }
    buf.write('\n');
  }
  for (final c in w.contracts) {
    buf.write('${c.playerId}|${c.wage}|${c.endDate}|${c.squadStatus.name}\n');
  }
  return buf.toString();
}

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();

  WorldBlueprint build(int seed) =>
      WorldGenerator.generate(seedJson: seedJson, seed: seed);

  group('Seed data klub', () {
    late WorldBlueprint world;
    setUpAll(() => world = build(42));

    test('ada 42 klub: 20 LaLiga + 22 LaLiga Hypermotion', () {
      expect(world.clubs.length, 42);
      expect(world.clubs.where((c) => c.leagueId == 'laliga').length, 20);
      expect(
        world.clubs.where((c) => c.leagueId == 'laliga-hypermotion').length,
        22,
      );
    });

    test('jumlahTim liga sesuai jumlah klub di seed', () {
      for (final league in world.leagues) {
        final count = world.clubs.where((c) => c.leagueId == league.id).length;
        expect(count, league.jumlahTim, reason: league.name);
      }
    });

    test('shortName 3 huruf dan warna berformat #RRGGBB', () {
      final hex = RegExp(r'^#[0-9A-Fa-f]{6}$');
      for (final c in world.clubs) {
        expect(c.shortName.length, 3, reason: c.name);
        expect(hex.hasMatch(c.primaryColor), isTrue, reason: c.name);
        expect(hex.hasMatch(c.secondaryColor), isTrue, reason: c.name);
        expect(c.reputation, inInclusiveRange(1, 100), reason: c.name);
      }
    });
  });

  group('Generator pemain', () {
    late WorldBlueprint world;
    setUpAll(() => world = build(1234));

    test('tiap klub punya minimal 2 GK dan >= 22 pemain', () {
      for (final club in world.clubs) {
        final squad = world.players.where((p) => p.clubId == club.id).toList();
        final gks = squad.where((p) => p.position == Position.gk).length;
        expect(squad.length, greaterThanOrEqualTo(22), reason: club.name);
        expect(gks, greaterThanOrEqualTo(2), reason: club.name);
      }
    });

    test('usia 17–35, atribut 1–20, CA 1–200, PA >= CA', () {
      for (final p in world.players) {
        expect(p.age, inInclusiveRange(17, 35));
        expect(p.currentAbility, inInclusiveRange(1, 200));
        expect(p.potentialAbility, greaterThanOrEqualTo(p.currentAbility));
        for (final v in p.attributes.values.values) {
          expect(v, inInclusiveRange(1, 20));
        }
      }
    });

    test('CA tersimpan sama dengan hasil hitung ulang dari atribut', () {
      for (final p in world.players) {
        expect(
          p.currentAbility,
          CurrentAbility.compute(p.position, p.attributes),
        );
      }
    });

    test('tiap pemain punya tepat satu kontrak', () {
      expect(world.contracts.length, world.players.length);
      final ids = world.players.map((p) => p.id).toSet();
      expect(world.contracts.map((c) => c.playerId).toSet(), ids);
    });

    test('klub tier 1 rata-rata CA lebih tinggi dari tier 2', () {
      double avgCa(String leagueId) {
        final clubIds =
            world.clubs
                .where((c) => c.leagueId == leagueId)
                .map((c) => c.id)
                .toSet();
        final ps = world.players.where((p) => clubIds.contains(p.clubId));
        final total = ps.fold<int>(0, (s, p) => s + p.currentAbility);
        return total / ps.length;
      }

      expect(avgCa('laliga'), greaterThan(avgCa('laliga-hypermotion')));
    });

    test('seed sama menghasilkan dunia persis sama', () {
      expect(_fingerprint(build(777)), _fingerprint(build(777)));
    });

    test('seed berbeda menghasilkan dunia berbeda', () {
      expect(_fingerprint(build(1)) == _fingerprint(build(2)), isFalse);
    });
  });
}
