import 'dart:convert';
import 'dart:math' as math;

import '../../core/rng/seeded_random.dart';
import '../enums/attribute.dart';
import '../enums/position.dart';
import '../enums/squad_status.dart';
import '../models/game_models.dart';
import '../models/player_attributes.dart';
import '../season/season_calendar.dart';
import 'current_ability.dart';
import 'name_pool.dart';

/// Membangun dunia (klub asli + pemain fiktif) dari seed JSON dan satu angka seed.
///
/// Fungsi ini murni (tanpa I/O, tanpa Flutter) sehingga aman dijalankan di
/// isolate. Seed sama + JSON sama = [WorldBlueprint] identik.
abstract final class WorldGenerator {
  /// Tanggal save pertama dibuat: 15 Agustus 2026 (musim 2026/27), diambil
  /// dari kalender musim agar tidak ada tahun yang di-hardcode di sini.
  static final DateTime seasonStart =
      SeasonCalendar.careerStart(SeasonCalendar.firstSeasonYear);

  /// Komposisi skuad per klub: 3 GK, 8 bek, 8 gelandang, 6 penyerang (= 25).
  static const List<Position> squadTemplate = [
    Position.gk,
    Position.gk,
    Position.gk,
    Position.dr,
    Position.dc,
    Position.dc,
    Position.dl,
    Position.dr,
    Position.dc,
    Position.dl,
    Position.dc,
    Position.dmc,
    Position.mc,
    Position.mc,
    Position.mr,
    Position.ml,
    Position.amc,
    Position.mc,
    Position.dmc,
    Position.amr,
    Position.aml,
    Position.st,
    Position.st,
    Position.st,
    Position.st,
  ];

  static WorldBlueprint generate({
    required String seedJson,
    required int seed,
  }) {
    final root = jsonDecode(seedJson) as Map<String, dynamic>;
    final rng = SeededRandom(seed);

    final nations = [
      for (final n in root['nations'] as List<dynamic>)
        Nation(
          id: (n as Map)['id'] as String,
          name: n['name'] as String,
          code: n['code'] as String,
        ),
    ];

    final leagues = [
      for (final l in root['leagues'] as List<dynamic>)
        League(
          id: (l as Map)['id'] as String,
          nationId: l['nationId'] as String,
          name: l['name'] as String,
          tier: l['tier'] as int,
          jumlahTim: l['jumlahTim'] as int,
          slotPromosi: l['slotPromosi'] as int,
          slotDegradasi: l['slotDegradasi'] as int,
          slotPlayoff: l['slotPlayoff'] as int,
        ),
    ];

    final clubs = [
      for (final c in root['clubs'] as List<dynamic>)
        Club(
          id: (c as Map)['id'] as String,
          leagueId: c['leagueId'] as String,
          name: c['name'] as String,
          shortName: c['shortName'] as String,
          primaryColor: c['primaryColor'] as String,
          secondaryColor: c['secondaryColor'] as String,
          reputation: c['reputation'] as int,
          stadiumName: c['stadiumName'] as String,
          capacity: c['capacity'] as int,
          balance: c['balance'] as int,
          transferBudget: c['transferBudget'] as int,
          wageBudget: c['wageBudget'] as int,
        ),
    ];

    final players = <Player>[];
    final contracts = <Contract>[];
    var nextId = 1;

    for (final club in clubs) {
      final squad = <_Draft>[];
      for (final position in squadTemplate) {
        squad.add(_draftPlayer(rng, club, position));
      }

      // Peringkat berdasarkan CA menentukan peran di skuad.
      final ranked = [...squad]
        ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));

      for (var rank = 0; rank < ranked.length; rank++) {
        final d = ranked[rank];
        final status = _statusFor(rank, d.age);
        final id = nextId++;

        players.add(
          Player(
            id: id,
            clubId: club.id,
            firstName: d.firstName,
            lastName: d.lastName,
            age: d.age,
            nationality: d.nationality,
            position: d.position,
            attributes: d.attributes,
            potentialAbility: d.potentialAbility,
            currentAbility: d.currentAbility,
            condition: rng.range(85, 100),
            morale: rng.range(55, 85),
            marketValue: d.marketValue,
          ),
        );

        contracts.add(
          Contract(
            playerId: id,
            clubId: club.id,
            wage: d.wage,
            // Kontrak berakhir 30 Juni, 1–4 musim setelah musim pertama.
            endDate: DateTime.utc(
              SeasonCalendar.firstSeasonYear + 1 + rng.range(0, 4),
              6,
              30,
            ),
            squadStatus: status,
          ),
        );
      }
    }

    return WorldBlueprint(
      nations: nations,
      leagues: leagues,
      clubs: clubs,
      players: players,
      contracts: contracts,
    );
  }

  // --- Pemain -----------------------------------------------------------------

  static _Draft _draftPlayer(SeededRandom rng, Club club, Position position) {
    final age = rng.range(17, 35);
    final nationality =
        rng.chance(0.7) ? 'ESP' : rng.pick(NamePool.foreignNationalities);

    // Kualitas dasar mengikuti reputasi klub (tier 1 lebih tinggi).
    var quality = 6 + club.reputation / 100 * 8 + rng.gaussian(stdDev: 1.2);
    if (age < 23) quality -= (23 - age) * 0.35; // pemain muda belum matang
    if (age >= 31) quality -= (age - 30) * 0.25; // menurun setelah 30

    final values = <Attribute, int>{
      for (final a in Attribute.values)
        a: _attributeValue(rng, position, a, quality),
    };
    final attributes = PlayerAttributes(values);
    final ca = CurrentAbility.compute(position, attributes);

    return _Draft(
      firstName: rng.pick(NamePool.firstNames),
      lastName: rng.pick(NamePool.lastNames),
      age: age,
      nationality: nationality,
      position: position,
      attributes: attributes,
      currentAbility: ca,
      potentialAbility: _potential(rng, ca, age),
      marketValue: _marketValue(rng, ca, age),
      wage: _wage(rng, ca, age),
    );
  }

  static int _attributeValue(
    SeededRandom rng,
    Position position,
    Attribute attribute,
    double quality,
  ) {
    final isGkAttribute = attribute.group == AttributeGroup.goalkeeping;
    final weight = CurrentAbility.weightOf(position, attribute);

    var mean = quality;
    if (position == Position.gk) {
      if (isGkAttribute) {
        mean += 1.5;
      } else {
        mean -= 4;
      }
    } else if (isGkAttribute) {
      mean -= 6; // pemain lapangan jauh di bawah kiper di atribut kiper
    } else if (weight >= 2) {
      mean += 1.5; // atribut inti posisi
    } else if (weight == 0) {
      mean -= 2; // atribut tidak relevan
    }

    final value = (mean + rng.gaussian(stdDev: 1.8)).round();
    return math.max(1, math.min(20, value));
  }

  /// Pemain muda punya potensi lebih tinggi dari CA sekarang.
  static int _potential(SeededRandom rng, int ca, int age) {
    if (age >= 27) return ca;
    final gap = (27 - age) * 2.5 * (0.6 + rng.nextDouble() * 0.8);
    return math.min(199, ca + gap.round());
  }

  /// Nilai pasar dalam €K.
  static int _marketValue(SeededRandom rng, int ca, int age) {
    final ageFactor =
        age <= 23
            ? 1.3
            : age <= 28
            ? 1.0
            : age <= 31
            ? 0.7
            : 0.4;
    final raw =
        math.pow(ca / 100, 3).toDouble() *
        2000 *
        ageFactor *
        (0.8 + rng.nextDouble() * 0.4);
    return (raw / 10).round() * 10;
  }

  /// Gaji per tahun dalam €K.
  static int _wage(SeededRandom rng, int ca, int age) {
    final raw =
        math.pow(ca / 100, 2).toDouble() *
        400 *
        (age < 23 ? 0.6 : 1.0) *
        (0.9 + rng.nextDouble() * 0.2);
    return (raw / 5).round() * 5;
  }

  static SquadStatus _statusFor(int rank, int age) {
    if (rank < 3) return SquadStatus.keyPlayer;
    if (rank < 11) return SquadStatus.starter;
    if (rank < 19) return SquadStatus.rotation;
    if (age <= 21) return SquadStatus.youth;
    return SquadStatus.backup;
  }
}

class _Draft {
  const _Draft({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.nationality,
    required this.position,
    required this.attributes,
    required this.currentAbility,
    required this.potentialAbility,
    required this.marketValue,
    required this.wage,
  });

  final String firstName;
  final String lastName;
  final int age;
  final String nationality;
  final Position position;
  final PlayerAttributes attributes;
  final int currentAbility;
  final int potentialAbility;
  final int marketValue;
  final int wage;
}
