import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/club_repository.dart';
import 'package:futbol/data/repositories/game_state_repository.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late String dbPath;
  final seedJson = File('assets/seed/spain.json').readAsStringSync();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('futbol_save_test_');
    dbPath = p.join(tempDir.path, 'save_1.sqlite');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('save ditutup lalu dibuka kembali dengan data utuh', () async {
    const seed = 20250701;
    final world = WorldGenerator.generate(seedJson: seedJson, seed: seed);
    final state = GameState(
      currentDate: WorldGenerator.seasonStart,
      managerName: 'Tester',
      clubId: 'real-madrid',
      seed: seed,
    );

    // Sesi pertama: buat dunia lalu tutup database.
    final first = AppDatabase(NativeDatabase(File(dbPath)));
    await WorldRepository(first).saveWorld(world, state);
    await first.close();

    // Sesi kedua: buka file yang sama dan periksa isinya.
    final second = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(second.close);

    final loadedState = await GameStateRepository(second).load();
    expect(loadedState, isNotNull);
    expect(loadedState!.managerName, 'Tester');
    expect(loadedState.clubId, 'real-madrid');
    expect(loadedState.seed, seed);
    expect(loadedState.currentDate, WorldGenerator.seasonStart);

    final clubs = ClubRepository(second);
    expect((await clubs.leagues()).length, 2);
    expect((await clubs.clubsByLeague('laliga')).length, 20);
    expect((await clubs.clubsByLeague('laliga-hypermotion')).length, 22);

    final players = PlayerRepository(second);
    final squad = await players.squad('real-madrid');
    expect(squad.length, 25);

    final expectedFirst = world.players.firstWhere(
      (pl) => pl.id == squad.last.id,
    );
    expect(squad.last.fullName, expectedFirst.fullName);
    expect(squad.last.currentAbility, expectedFirst.currentAbility);
    expect(squad.last.attributes.values, expectedFirst.attributes.values);

    final detail = await players.detail(squad.first.id);
    expect(detail, isNotNull);
    expect(detail!.contract, isNotNull);
    expect(detail.contract!.clubId, 'real-madrid');
  });
}
