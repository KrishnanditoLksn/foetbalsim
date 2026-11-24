import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/providers.dart';
import 'package:futbol/app/router.dart';
import 'package:futbol/app/theme.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/features/shell/main_shell_screen.dart';

/// Shell 5 tab di layar ponsel portrait (360×780 dp): semua tab dan
/// sub-tab dibuka tanpa overflow/exception, dan tombol aksi Beranda
/// mengarahkan ke Inbox saat ada tindakan pending.
void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  late AppDatabase db;

  Future<void> settle(WidgetTester tester, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final world = WorldGenerator.generate(seedJson: seedJson, seed: 11);
      await WorldRepository(db).saveWorld(
        world,
        GameState(
          currentDate: WorldGenerator.seasonStart,
          managerName: 'Uji',
          clubId: 'real-sociedad',
          seed: 11,
        ),
      );
      await GameEngine(db).ensureSeasonInitialized();
    });
    addTearDown(() => tester.runAsync(db.close));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentDatabaseProvider.overrideWith((ref) => db)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: const MainShellScreen(),
        ),
      ),
    );
    await settle(tester, rounds: 20);
  }

  Future<void> goTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await settle(tester);
  }

  testWidgets('semua tab terbuka tanpa overflow di layar 360 dp', (
    tester,
  ) async {
    await pumpShell(tester);

    // Beranda: hero laga berikutnya + KPI + aksi utama.
    expect(
      find.text('kandang').evaluate().length +
          find.text('tandang').evaluate().length,
      1,
    );
    expect(find.text('Saldo klub'), findsOneWidget);
    // Tanggal awal (Sabtu, pekan 1) bisa jadi hari laga tim kita.
    expect(
      find.text('Laga berikutnya').evaluate().length +
          find.text('Hari ini ada laga').evaluate().length,
      1,
    );

    await goTab(tester, 'Skuad');
    expect(find.text('Daftar Skuad'), findsOneWidget);
    expect(find.text('Semua (25)'), findsOneWidget);
    await tester.tap(find.text('Kiper (3)'));
    await settle(tester);
    await tester.tap(find.text('Taktik'));
    await settle(tester);
    expect(find.text('Mentalitas'), findsOneWidget);

    await goTab(tester, 'Jadwal');
    await tester.tap(find.text('Klasemen'));
    await settle(tester);
    expect(find.text('Poin'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    await tester.tap(find.text('Pekan'));
    await settle(tester);
    expect(find.textContaining('Pekan 1 dari'), findsOneWidget);

    await goTab(tester, 'Transfer');
    expect(find.textContaining('Bursa buka'), findsOneWidget);

    await goTab(tester, 'Inbox');
    expect(find.text('Sambutan dewan'), findsOneWidget);
    expect(find.text('Menunggu keputusan Anda'), findsWidgets);

    expect(tester.takeException(), isNull);
  });

  testWidgets('TINDAKAN DIPERLUKAN membuka tab Inbox; detail pemain rapi', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('Ambil 1 keputusan di inbox'));
    await settle(tester);
    expect(find.text('Belum dibaca (1)'), findsOneWidget);

    // Kartu pemain pertama membuka detail: hero header + grid atribut.
    await goTab(tester, 'Skuad');
    expect(find.text('Daftar Skuad'), findsOneWidget);
    await tester.tap(find.textContaining(' th').first);
    await settle(tester, rounds: 15);
    expect(find.text('Profil pemain'), findsOneWidget);
    expect(find.text('Kemampuan (CA)'), findsOneWidget);
    // Grid atribut ada di bawah: gulir sampai terlihat (tanpa overflow).
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await settle(tester);
    // "Teknik" = judul kelompok dan nama atribut.
    expect(find.text('Teknik'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}
