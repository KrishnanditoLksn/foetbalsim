import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/enums/attribute.dart';
import 'package:futbol/domain/enums/position.dart';
import 'package:futbol/domain/enums/tactics.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/match/lineup_builder.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/match_models.dart';
import 'package:futbol/domain/models/player_attributes.dart';
import 'package:futbol/domain/models/transfer_models.dart';
import 'package:futbol/domain/transfer/player_search.dart';
import 'package:futbol/domain/transfer/transfer_window.dart';

void main() {
  group('Jendela transfer Eropa', () {
    test('buka 1 Jul–31 Agu dan 1–31 Jan, tutup di luar itu', () {
      expect(TransferWindow.isOpen(DateTime.utc(2025, 7, 1)), isTrue);
      expect(TransferWindow.isOpen(DateTime.utc(2025, 8, 31)), isTrue);
      expect(TransferWindow.isOpen(DateTime.utc(2026, 1, 1)), isTrue);
      expect(TransferWindow.isOpen(DateTime.utc(2026, 1, 31)), isTrue);
      expect(TransferWindow.isOpen(DateTime.utc(2025, 6, 30)), isFalse);
      expect(TransferWindow.isOpen(DateTime.utc(2025, 9, 1)), isFalse);
      expect(TransferWindow.isOpen(DateTime.utc(2025, 12, 31)), isFalse);
      expect(TransferWindow.isOpen(DateTime.utc(2026, 2, 1)), isFalse);
    });

    test('status menunjukkan tanggal tutup atau buka berikutnya', () {
      final open = TransferWindow.status(DateTime.utc(2025, 7, 10));
      expect(open.isOpen, isTrue);
      expect(open.closesOn, DateTime.utc(2025, 8, 31));

      final closedAutumn = TransferWindow.status(DateTime.utc(2025, 10, 5));
      expect(closedAutumn.isOpen, isFalse);
      expect(closedAutumn.nextOpensOn, DateTime.utc(2026, 1, 1));

      final closedSpring = TransferWindow.status(DateTime.utc(2026, 3, 5));
      expect(closedSpring.nextOpensOn, DateTime.utc(2026, 7, 1));
    });
  });

  group('Valuasi transfer', () {
    final base = Player(
      id: 1,
      clubId: 'x',
      firstName: 'A',
      lastName: 'B',
      age: 25,
      nationality: 'ESP',
      position: Position.st,
      attributes: _attrs(),
      potentialAbility: 150,
      currentAbility: 120,
      condition: 90,
      morale: 60,
      marketValue: 10000,
    );

    test('pemain di daftar jual lebih murah dari yang tidak', () {
      final now = DateTime.utc(2025, 7, 1);
      final listed = TransferValuation.askingFee(
        player: _withListed(base, true),
        contract: null,
        now: now,
      );
      final notListed = TransferValuation.askingFee(
        player: base,
        contract: null,
        now: now,
      );
      expect(listed, lessThan(notListed));
    });

    test('tawaran di bawah 95% harga ditolak', () {
      expect(TransferValuation.fairFee(9500, 10000), isTrue);
      expect(TransferValuation.fairFee(9400, 10000), isFalse);
    });

    test('ekspektasi gaji naik seiring CA', () {
      final low = TransferValuation.expectedWage(_withCa(base, 80));
      final high = TransferValuation.expectedWage(_withCa(base, 160));
      expect(high, greaterThan(low));
    });
  });

  group('Pencarian pemain', () {
    late List<PlayerSearchRow> rows;
    final now = DateTime.utc(2025, 7, 1);

    setUpAll(() {
      final seedJson = File('assets/seed/spain.json').readAsStringSync();
      final world = WorldGenerator.generate(seedJson: seedJson, seed: 5);
      final clubLeague = {
        for (final c in world.clubs) c.id: c.leagueId,
      };
      final clubName = {for (final c in world.clubs) c.id: c.name};
      final contracts = {for (final c in world.contracts) c.playerId: c};
      rows = [
        for (final p in world.players)
          PlayerSearchRow(
            player: p,
            contract: contracts[p.id],
            clubName: clubName[p.clubId] ?? '-',
            leagueId: clubLeague[p.clubId],
            isForSale: p.isTransferListed,
          ),
      ];
    });

    test('filter posisi grup hanya mengembalikan posisi yang sesuai', () {
      final result = PlayerSearch.apply(
        rows,
        const PlayerSearchFilter(group: PositionGroup.goalkeeper),
        now: now,
      );
      expect(result, isNotEmpty);
      expect(
        result.every((r) => r.player.position.group == PositionGroup.goalkeeper),
        isTrue,
      );
    });

    test('rentang usia dan CA dipatuhi', () {
      final result = PlayerSearch.apply(
        rows,
        const PlayerSearchFilter(ageMin: 20, ageMax: 24, caMin: 90, caMax: 130),
        now: now,
      );
      for (final r in result) {
        expect(r.player.age, inInclusiveRange(20, 24));
        expect(r.player.currentAbility, inInclusiveRange(90, 130));
      }
    });

    test('pengurutan CA menurun lalu naik', () {
      final desc = PlayerSearch.apply(
        rows,
        const PlayerSearchFilter(sort: PlayerSort.ca),
        now: now,
      );
      for (var i = 1; i < desc.length; i++) {
        expect(
          desc[i - 1].player.currentAbility,
          greaterThanOrEqualTo(desc[i].player.currentAbility),
        );
      }
      final asc = PlayerSearch.apply(
        rows,
        const PlayerSearchFilter(sort: PlayerSort.ca, ascending: true),
        now: now,
      );
      expect(asc.first.player.currentAbility,
          lessThanOrEqualTo(asc.last.player.currentAbility));
    });

    test('pencarian nama tidak membedakan huruf besar kecil', () {
      final name = rows.first.player.lastName;
      final result = PlayerSearch.apply(
        rows,
        PlayerSearchFilter(query: name.toUpperCase()),
        now: now,
      );
      expect(result.any((r) => r.player.id == rows.first.player.id), isTrue);
    });

    test('status daftar jual dan agen bebas', () {
      final forSale = PlayerSearch.apply(
        rows,
        const PlayerSearchFilter(status: PlayerSearchStatus.forSale),
        now: now,
      );
      expect(forSale, isEmpty); // belum ada pemain yang didaftar jual

      final free = PlayerSearch.apply(
        rows,
        const PlayerSearchFilter(status: PlayerSearchStatus.freeAgent),
        now: now,
      );
      expect(free, isEmpty); // generator belum membuat agen bebas
    });

    test('kontrak habis ≤ 6 bulan', () {
      final result = PlayerSearch.apply(
        rows,
        const PlayerSearchFilter(status: PlayerSearchStatus.expiringSoon),
        now: DateTime.utc(2026, 6, 1),
      );
      expect(result, isNotEmpty);
      for (final r in result) {
        expect(
          r.contract!.endDate.isAfter(DateTime.utc(2026, 12, 1)),
          isFalse,
        );
      }
    });
  });

  group('Susunan taktik', () {
    test('setiap formasi punya 11 slot', () {
      for (final f in Formation.values) {
        expect(f.slots.length, 11, reason: f.label);
        expect(f.slots.first.role, SlotRole.gk);
      }
    });

    test('taktik tersimpan yang valid dipakai apa adanya', () {
      final squad = _squad();
      final auto = LineupBuilder.auto(squad, Formation.f442);
      final saved = ClubTactic(
        clubId: 'c',
        formation: Formation.f442,
        mentality: Mentality.attacking,
        starterIds: [for (final p in auto.starters.reversed) p.id],
        subIds: [for (final p in auto.bench.take(3)) p.id],
      );
      final resolved = LineupBuilder.resolve(squad, saved);
      expect(
        [for (final p in resolved.starters) p.id],
        saved.starterIds,
      );
      expect(resolved.bench.take(3).map((p) => p.id), saved.subIds);
    });

    test('taktik yang tidak valid (pemain hilang) jatuh ke susunan otomatis', () {
      final squad = _squad();
      final saved = ClubTactic(
        clubId: 'c',
        formation: Formation.f433,
        mentality: Mentality.balanced,
        starterIds: [9999, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        subIds: const [],
      );
      final resolved = LineupBuilder.resolve(squad, saved);
      expect(resolved.starters.length, 11);
      expect(resolved.starters.any((p) => p.id == 9999), isFalse);
    });

    test('bangku cadangan berisi kiper bila tersedia', () {
      final squad = _squad();
      final auto = LineupBuilder.auto(squad, Formation.f442);
      expect(auto.bench.any((p) => p.position == Position.gk), isTrue);
      expect(auto.bench.length, LineupBuilder.benchCount);
    });
  });
}

List<Player> _squad() {
  final list = <Player>[];
  var id = 1;
  for (final pos in [
    Position.gk,
    Position.gk,
    Position.dr,
    Position.dc,
    Position.dc,
    Position.dl,
    Position.dmc,
    Position.mc,
    Position.mc,
    Position.ml,
    Position.mr,
    Position.st,
    Position.st,
    Position.amc,
    Position.aml,
    Position.amr,
    Position.dc,
    Position.mc,
    Position.st,
    Position.dl,
  ]) {
    list.add(
      Player(
        id: id,
        clubId: 'c',
        firstName: 'F$id',
        lastName: 'L$id',
        age: 25,
        nationality: 'ESP',
        position: pos,
        attributes: _attrs(),
        potentialAbility: 130,
        currentAbility: 60 + id,
        condition: 90,
        morale: 60,
        marketValue: 1000,
      ),
    );
    id++;
  }
  return list;
}

Player _withListed(Player p, bool listed) => Player(
  id: p.id,
  clubId: p.clubId,
  firstName: p.firstName,
  lastName: p.lastName,
  age: p.age,
  nationality: p.nationality,
  position: p.position,
  attributes: p.attributes,
  potentialAbility: p.potentialAbility,
  currentAbility: p.currentAbility,
  condition: p.condition,
  morale: p.morale,
  marketValue: p.marketValue,
  isTransferListed: listed,
);

Player _withCa(Player p, int ca) => Player(
  id: p.id,
  clubId: p.clubId,
  firstName: p.firstName,
  lastName: p.lastName,
  age: p.age,
  nationality: p.nationality,
  position: p.position,
  attributes: p.attributes,
  potentialAbility: p.potentialAbility,
  currentAbility: ca,
  condition: p.condition,
  morale: p.morale,
  marketValue: p.marketValue,
);

/// Atribut seragam untuk pemain uji; nilai tidak memengaruhi logika yang diuji.
PlayerAttributes _attrs() => PlayerAttributes({
  for (final a in Attribute.values) a: 10,
});
