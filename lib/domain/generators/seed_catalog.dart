import 'dart:convert';

import '../models/game_models.dart';

/// Daftar nation, liga, dan klub dari seed JSON, tanpa membuat pemain.
/// Dipakai layar karier baru sebelum database save dibuka.
class SeedCatalog {
  const SeedCatalog({
    required this.nations,
    required this.leagues,
    required this.clubs,
  });

  final List<Nation> nations;
  final List<League> leagues;
  final List<Club> clubs;

  List<Club> clubsOf(String leagueId) =>
      clubs.where((c) => c.leagueId == leagueId).toList();

  static SeedCatalog parse(String seedJson) {
    final root = jsonDecode(seedJson) as Map<String, dynamic>;

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

    return SeedCatalog(nations: nations, leagues: leagues, clubs: clubs);
  }
}
