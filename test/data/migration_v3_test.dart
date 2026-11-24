import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/game_state_repository.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/tactics_repository.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/domain/enums/tactics.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/match_models.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late String dbPath;
  final seedJson = File('assets/seed/spain.json').readAsStringSync();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('futbol_migration_test_');
    dbPath = p.join(tempDir.path, 'save_1.sqlite');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('save v2 (tanpa tabel Fase 3) dibuka dan dimigrasi ke v3 tanpa kehilangan data', () async {
    const seed = 4242;
    final world = WorldGenerator.generate(seedJson: seedJson, seed: seed);
    final state = GameState(
      currentDate: WorldGenerator.seasonStart,
      managerName: 'Migrasi',
      clubId: 'real-madrid',
      seed: seed,
    );

    // 1) Buat save dengan skema terbaru, lalu turunkan ke bentuk v2.
    final first = AppDatabase(NativeDatabase(File(dbPath)));
    await WorldRepository(first).saveWorld(world, state);
    await first.customStatement(
      'ALTER TABLE players DROP COLUMN is_transfer_listed',
    );
    await first.customStatement('DROP TABLE club_tactics');
    await first.customStatement('DROP TABLE transfer_offers');
    await first.customStatement('DROP TABLE transfer_history');
    await first.customStatement('DROP TABLE shortlist');
    // Kolom dan tabel v4 juga dibuang, supaya save benar-benar berbentuk v2.
    await first.customStatement(
      'ALTER TABLE players DROP COLUMN locked_until',
    );
    await first.customStatement(
      'ALTER TABLE game_states DROP COLUMN season_start_year',
    );
    await first.customStatement(
      'ALTER TABLE fixtures DROP COLUMN season_start_year',
    );
    await first.customStatement('ALTER TABLE fixtures DROP COLUMN stage');
    await first.customStatement('ALTER TABLE fixtures DROP COLUMN leg');
    for (final t in [
      'club_ai_profiles',
      'transfer_interests',
      'transfer_news',
      'market_memory',
      'seasons',
      'season_archive',
      'honours',
    ]) {
      await first.customStatement('DROP TABLE $t');
    }
    await first.customStatement('PRAGMA user_version = 2');
    await first.close();

    // 2) Buka lagi: onUpgrade harus berjalan dari v2 ke v3.
    final second = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(second.close);

    final loaded = await GameStateRepository(second).load();
    expect(loaded, isNotNull);
    expect(loaded!.managerName, 'Migrasi');
    expect(loaded.seed, seed);

    final squad = await PlayerRepository(second).squad('real-madrid');
    final expected = world.players.where((x) => x.clubId == 'real-madrid');
    expect(squad.length, expected.length);
    expect(squad.every((x) => x.isTransferListed == false), isTrue);

    // Tabel baru langsung bisa dipakai.
    final tactics = TacticsRepository(second);
    expect(await tactics.load('real-madrid'), isNull);
    await tactics.save(
      ClubTactic(
        clubId: 'real-madrid',
        formation: Formation.f433,
        mentality: Mentality.attacking,
        starterIds: squad.take(11).map((x) => x.id).toList(),
        subIds: squad.skip(11).take(7).map((x) => x.id).toList(),
      ),
    );
    final saved = await tactics.load('real-madrid');
    expect(saved!.formation, Formation.f433);
    expect(saved.starterIds.length, 11);
    expect(saved.subIds.length, 7);

    final transfers = TransferRepository(second);
    expect(await transfers.history(), isEmpty);
    expect(await transfers.shortlistIds(), isEmpty);
  });
}
