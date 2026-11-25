import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/providers.dart';
import 'package:futbol/app/router.dart';
import 'package:futbol/app/theme.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/data/services/transfer_service.dart';
import 'package:futbol/domain/enums/transfer.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/features/transfer/negotiation_room_screen.dart';

/// Ruang Negosiasi di berbagai ukuran layar dan skala teks: tidak boleh ada
/// overflow, dan tombol utama harus tetap terjangkau.
///
/// Ukuran dalam dp. OPPO A57 (2016) ≈ 360×640, OPPO A57 (2022) ≈ 360×800.
const _screens = <String, Size>{
  'ponsel mungil 320×568': Size(320, 568),
  'OPPO A57 2016 360×640': Size(360, 640),
  'OPPO A57 2022 360×800': Size(360, 800),
  'ponsel besar 412×915': Size(412, 915),
  'lanskap 800×360': Size(800, 360),
  'tablet 800×1280': Size(800, 1280),
};
const _textScales = [1.0, 1.3, 1.6];

const _us = 'real-madrid';

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final start = WorldGenerator.seasonStart;

  late AppDatabase db;
  late TransferService svc;
  late int buyId;
  late int sellId;

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    final world = WorldGenerator.generate(seedJson: seedJson, seed: 99);
    await WorldRepository(db).saveWorld(
      world,
      GameState(currentDate: start, managerName: 'T', clubId: _us, seed: 99),
    );
    await GameEngine(db).ensureSeasonInitialized();
    svc = TransferService(db);

    // Pemain dengan nama belakang terpanjang: kasus terberat untuk judul.
    final squad = await PlayerRepository(db).squad('getafe');
    squad.sort((a, b) => b.lastName.length.compareTo(a.lastName.length));
    final p = squad.firstWhere((x) => x.marketValue >= 1000);
    final ask =
        (await svc.quote(playerId: p.id, ourClubId: _us, now: start, seed: 99))
            .askingFee;
    await svc.placeBid(
      ourClubId: _us,
      now: start,
      playerId: p.id,
      fee: (ask * 0.85).round(),
      seed: 99,
    );
    await svc.resolveDueBids(
      date: start.add(const Duration(days: 2)),
      ourClubId: _us,
      seed: 99,
    );
    buyId = (await TransferRepository(db).offersFor(_us))
        .firstWhere((o) => o.playerId == p.id)
        .id;

    final ours = await PlayerRepository(db).squad(_us);
    sellId = await TransferRepository(db).insertOffer(
      playerId: ours.first.id,
      fromClubId: 'sevilla',
      toClubId: _us,
      fee: 12500,
      status: TransferOfferStatus.awaitingContract,
      createdDate: start,
      responseDate: start,
    );
  });

  tearDownAll(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpRoom(
    WidgetTester tester,
    int offerId,
    Size size,
    double textScale,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentDatabaseProvider.overrideWith((ref) => db)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
          home: NegotiationRoomScreen(offerId: offerId),
        ),
      ),
    );
    await settle(tester);
  }

  for (final entry in _screens.entries) {
    for (final scale in _textScales) {
      for (final mode in ['beli', 'jual']) {
        testWidgets('${entry.key}, teks ×$scale, mode $mode', (tester) async {
          await pumpRoom(
            tester,
            mode == 'beli' ? buyId : sellId,
            entry.value,
            scale,
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(NegotiationRoomScreen), findsOneWidget);
          // Tombol aksi selalu terlihat di dalam layar.
          final submit = find.text('Ajukan tawaran');
          expect(submit, findsOneWidget);
          final rect = tester.getRect(submit);
          expect(rect.bottom, lessThanOrEqualTo(entry.value.height));
          expect(rect.right, lessThanOrEqualTo(entry.value.width));
        });
      }
    }
  }
}
