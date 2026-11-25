import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/providers.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/features/player/player_detail_screen.dart';
import 'package:futbol/features/transfer/transfer_dialogs.dart';

/// Alur UI: detail pemain → Ajukan tawaran → isi nominal → Kirim.
/// Regresi: controller dialog dulu di-dispose saat animasi tutup dialog masih
/// berjalan, sehingga aplikasi error dan berhenti merespons.
void main() {
  testWidgets('mengajukan tawaran dari detail pemain tidak error', (
    tester,
  ) async {
    final seedJson = File('assets/seed/spain.json').readAsStringSync();
    late AppDatabase db;
    late Player target;

    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final world = WorldGenerator.generate(seedJson: seedJson, seed: 99);
      await WorldRepository(db).saveWorld(
        world,
        GameState(
          currentDate: WorldGenerator.seasonStart,
          managerName: 'Tester',
          clubId: 'real-madrid',
          seed: 99,
        ),
      );
      await GameEngine(db).ensureSeasonInitialized();
      final squad = await PlayerRepository(db).squad('barcelona');
      squad.sort((a, b) => a.marketValue.compareTo(b.marketValue));
      target = squad.first; // termurah, agar muat di anggaran
    });
    addTearDown(() => tester.runAsync(db.close));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentDatabaseProvider.overrideWith((ref) => db)],
        child: MaterialApp(home: PlayerDetailScreen(playerId: target.id)),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await settle();
    final bidButton = find.text('Ajukan tawaran');
    await tester.ensureVisible(bidButton);
    await tester.tap(bidButton);
    await settle();
    expect(find.byType(BidDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), '${target.marketValue}');
    await tester.tap(find.text('Kirim'));
    await settle();

    // Dialog tertutup tanpa exception dan tawaran tersimpan.
    expect(tester.takeException(), isNull);
    expect(find.byType(BidDialog), findsNothing);
    final offers = await tester.runAsync(
      () => TransferRepository(db).offersFor('real-madrid'),
    );
    expect(offers!.any((o) => o.playerId == target.id), isTrue);
    expect(
      find.textContaining('Menunggu respons klub penjual'),
      findsOneWidget,
    );
  });
}
