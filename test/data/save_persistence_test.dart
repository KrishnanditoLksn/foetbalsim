import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/database/save_storage.dart';
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

  group('SaveStorage: 5 slot dan hapus save', () {
    setUp(() => SaveStorage.savesDirOverride = () async => tempDir);
    tearDown(() => SaveStorage.savesDirOverride = null);

    Future<void> fill(Iterable<int> slots) async {
      for (final slot in slots) {
        await (await SaveStorage.slotFile(slot)).writeAsString('x');
      }
    }

    test('maksimal 5 slot', () {
      expect(SaveStorage.maxSlots, 5);
    });

    test('existingSlots dan firstFreeSlot bekerja sampai slot 5', () async {
      expect(await SaveStorage.existingSlots(), isEmpty);
      expect(await SaveStorage.firstFreeSlot(), 1);

      await fill([1, 2, 3, 4]);
      expect(await SaveStorage.existingSlots(), [1, 2, 3, 4]);
      expect(await SaveStorage.firstFreeSlot(), 5);

      await fill([5]);
      expect(await SaveStorage.existingSlots(), [1, 2, 3, 4, 5]);
      expect(await SaveStorage.firstFreeSlot(), isNull);

      // File di luar batas slot tidak dihitung.
      await File(p.join(tempDir.path, 'save_6.sqlite')).writeAsString('x');
      expect(await SaveStorage.existingSlots(), [1, 2, 3, 4, 5]);
    });

    test('delete menghapus .sqlite beserta -wal, -shm, -journal', () async {
      await fill([1, 2, 3, 4, 5]);
      final main = await SaveStorage.slotFile(3);
      final companions = [
        File('${main.path}-wal'),
        File('${main.path}-shm'),
        File('${main.path}-journal'),
      ];
      for (final f in companions) {
        await f.writeAsString('x');
      }

      await SaveStorage.delete(3);

      expect(await main.exists(), isFalse);
      for (final f in companions) {
        expect(await f.exists(), isFalse, reason: f.path);
      }
      expect(await SaveStorage.existingSlots(), [1, 2, 4, 5]);
      expect(await SaveStorage.firstFreeSlot(), 3);
      // Slot lain tidak tersentuh.
      expect(await (await SaveStorage.slotFile(2)).exists(), isTrue);
    });

    test('delete slot kosong tidak error', () async {
      await SaveStorage.delete(4);
      expect(await SaveStorage.existingSlots(), isEmpty);
    });

    test('save SQLite asli bisa dihapus setelah ditutup', () async {
      final file = await SaveStorage.slotFile(1);
      final db = AppDatabase(NativeDatabase(file));
      await GameStateRepository(db).load(); // memaksa file dibuat
      await db.close();
      expect(await SaveStorage.existingSlots(), [1]);

      await SaveStorage.delete(1);
      expect(await SaveStorage.existingSlots(), isEmpty);
      expect(tempDir.listSync(), isEmpty);
    });
  });
}
