import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/providers.dart';
import 'package:futbol/app/router.dart';
import 'package:futbol/app/theme.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/data/services/transfer_service.dart';
import 'package:futbol/domain/enums/transfer.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/transfer/agent_negotiator.dart';
import 'package:futbol/features/player/player_detail_screen.dart';
import 'package:futbol/features/shell/main_shell_screen.dart';
import 'package:futbol/features/squad/squad_screen.dart';
import 'package:futbol/features/transfer/negotiation_room_screen.dart';

/// Tab Skuad → detail pemain dengan alur terbaru: agen pemain, negosiasi
/// yang berjalan beserta kesabaran agen, dan tombol ke Ruang Negosiasi.
/// Diuji di layar OPPO A57 (360×640 dp).
const _us = 'real-sociedad';

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final start = WorldGenerator.seasonStart;
  late AppDatabase db;

  Future<void> settle(WidgetTester tester, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('Skuad → detail pemain → negosiasi berjalan → Ruang Negosiasi', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final world = WorldGenerator.generate(seedJson: seedJson, seed: 11);
      await WorldRepository(db).saveWorld(
        world,
        GameState(currentDate: start, managerName: 'Uji', clubId: _us, seed: 11),
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

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Skuad'),
      ),
    );
    await settle(tester);

    // Pemain teratas di daftar skuad mendapat tawaran Sevilla, dan
    // tawar-menawarnya sudah dibuka di Ruang Negosiasi.
    final card = find.byType(PlayerListCard).first;
    final player = tester.widget<PlayerListCard>(card).player;
    await tester.runAsync(() async {
      final id = await TransferRepository(db).insertOffer(
        playerId: player.id,
        fromClubId: 'sevilla',
        toClubId: _us,
        fee: 4000,
        status: TransferOfferStatus.awaitingContract,
        createdDate: start,
        responseDate: start,
      );
      await TransferService(db).openNegotiation(
        offerId: id,
        ourClubId: _us,
        date: start,
        seed: 11,
      );
    });
    ProviderScope.containerOf(
      tester.element(find.byType(MainShellScreen)),
    ).read(worldVersionProvider.notifier).state++;

    await tester.tap(card);
    await settle(tester, rounds: 15);
    expect(find.byType(PlayerDetailScreen), findsOneWidget);

    // Bagian Transfer: agen, tawaran berjalan, kesabaran agen.
    final agent = AgentProfile.forPlayer(seed: 11, playerId: player.id);
    final scrollable = find.descendant(
      of: find.byType(PlayerDetailScreen),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Lanjutkan negosiasi'),
      200,
      scrollable: scrollable.first,
    );
    await settle(tester);
    expect(find.textContaining(agent.name, findRichText: true), findsOneWidget);
    expect(find.textContaining('Tawaran Sevilla'), findsOneWidget);
    expect(find.textContaining('kesabaran agen 100%'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Lanjutkan negosiasi'));
    await settle(tester);
    expect(find.byType(NegotiationRoomScreen), findsOneWidget);
    expect(find.text('Tawaran pembeli'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
