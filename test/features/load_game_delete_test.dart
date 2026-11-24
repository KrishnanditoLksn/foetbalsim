import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/providers.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/database/save_storage.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/features/load_game/load_game_screen.dart';

/// Hapus save dari layar Muat Karier, termasuk slot yang sedang aktif
/// (database harus ditutup dulu agar file bisa dihapus).
void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  late Directory dir;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Database dibuka di isolate latar belakang: tunggu sampai [finder] muncul.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await settle(tester);
    }
    expect(finder, findsOneWidget);
  }

  testWidgets('batal tidak menghapus; hapus slot aktif menutup database', (
    tester,
  ) async {
    late AppDatabase active;
    await tester.runAsync(() async {
      dir = await Directory.systemTemp.createTemp('futbol_load_delete_');
      SaveStorage.savesDirOverride = () async => dir;
      final world = WorldGenerator.generate(seedJson: seedJson, seed: 7);
      for (final (slot, manager) in [(1, 'Ana'), (2, 'Budi')]) {
        final db = AppDatabase(
          NativeDatabase(await SaveStorage.slotFile(slot)),
        );
        await WorldRepository(db).saveWorld(
          world,
          GameState(
            currentDate: WorldGenerator.seasonStart,
            managerName: manager,
            clubId: 'getafe',
            seed: 7,
          ),
        );
        await db.close();
      }
      active = await SaveStorage.open(1);
    });
    addTearDown(() async {
      SaveStorage.savesDirOverride = null;
      await tester.runAsync(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(currentDatabaseProvider.notifier).state = active;
    container.read(activeSaveSlotProvider.notifier).state = 1;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoadGameScreen()),
      ),
    );
    await waitFor(tester, find.text('Muat Karier (2/${SaveStorage.maxSlots})'));
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Budi'), findsOneWidget);

    Finder deleteOf(String manager) => find.descendant(
      of: find.ancestor(of: find.text(manager), matching: find.byType(Card)),
      matching: find.byTooltip('Hapus save'),
    );

    // Batal: tidak ada yang berubah.
    await tester.tap(deleteOf('Ana'));
    await settle(tester);
    expect(find.text('Hapus save?'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await settle(tester);
    expect(find.text('Hapus save?'), findsNothing);
    expect(find.text('Ana'), findsOneWidget);
    expect(container.read(activeSaveSlotProvider), 1);

    // Hapus slot aktif.
    await tester.tap(deleteOf('Ana'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await waitFor(tester, find.text('Muat Karier (1/${SaveStorage.maxSlots})'));

    expect(tester.takeException(), isNull);
    expect(find.text('Save slot 1 berhasil dihapus.'), findsOneWidget);
    expect(find.text('Ana'), findsNothing);
    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('Muat Karier (1/${SaveStorage.maxSlots})'), findsOneWidget);
    expect(container.read(currentDatabaseProvider), isNull);
    expect(container.read(activeSaveSlotProvider), isNull);
    final slots = await tester.runAsync(SaveStorage.existingSlots);
    expect(slots, [2]);
    final free = await tester.runAsync(SaveStorage.firstFreeSlot);
    expect(free, 1);
  });
}
