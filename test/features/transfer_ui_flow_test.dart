import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/providers.dart';
import 'package:futbol/app/router.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/inbox_repository.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/data/services/transfer_service.dart';
import 'package:futbol/domain/enums/inbox.dart';
import 'package:futbol/domain/enums/transfer.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/season_models.dart';
import 'package:futbol/domain/transfer/agent_negotiator.dart';
import 'package:futbol/features/inbox/inbox_screen.dart';
import 'package:futbol/features/transfer/negotiation_room_screen.dart';
import 'package:futbol/features/transfer/transfer_screen.dart';

/// Alur UI Ruang Negosiasi (README_NEGOTIATION_ROOM F): dari Inbox dan tab
/// Negosiasi sampai sepakat, termasuk layar ponsel 360 dp.
const _us = 'real-madrid';
const _seller = 'getafe';

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final start = WorldGenerator.seasonStart;

  late AppDatabase db;
  late TransferService svc;

  Future<void> setUpWorld(WidgetTester tester) async {
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final world = WorldGenerator.generate(seedJson: seedJson, seed: 99);
      await WorldRepository(db).saveWorld(
        world,
        GameState(currentDate: start, managerName: 'T', clubId: _us, seed: 99),
      );
      await GameEngine(db).ensureSeasonInitialized();
      svc = TransferService(db);
    });
    addTearDown(() => tester.runAsync(db.close));
  }

  Future<T> io<T>(WidgetTester tester, Future<T> Function() fn) async =>
      (await tester.runAsync(fn)) as T;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> show(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentDatabaseProvider.overrideWith((ref) => db)],
        child: MaterialApp(
          home: screen,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    await tester.ensureVisible(finder.last);
    await tester.tap(finder.last);
    await settle(tester);
  }

  /// Ponsel tinggi agar seluruh isi ruangan ter-build tanpa digulir.
  void tallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// Pemain Getafe bernilai ≥ €3 jt, tawaran 85% → kontra-tawaran.
  Future<(Player, int)> countered(WidgetTester tester) => io(tester, () async {
    final squad = await PlayerRepository(db).squad(_seller);
    squad.sort((a, b) => a.marketValue.compareTo(b.marketValue));
    final p = squad.firstWhere((x) => x.marketValue >= 3000);
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
    final offer = (await TransferRepository(db).offersFor(_us)).firstWhere(
      (o) => o.playerId == p.id,
    );
    return (p, offer.id);
  });

  testWidgets('Inbox → Ruang Negosiasi → ajukan tawaran (layar 360 dp)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await setUpWorld(tester);
    final (p, offerId) = await countered(tester);

    await show(tester, const InboxScreen());
    await tester.tap(find.text('Kontra-tawaran: ${p.fullName}'));
    await settle(tester);
    await tester.tap(find.text('Masuk ruang negosiasi'));
    await settle(tester);

    expect(find.byType(NegotiationRoomScreen), findsOneWidget);
    final agent = AgentProfile.forPlayer(seed: 99, playerId: p.id);
    expect(find.text(agent.name), findsOneWidget);
    expect(find.text('Patokan agen'), findsOneWidget);
    expect(find.textContaining('Kesabaran 100%'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Ajukan tawaran'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    final offer = await io(tester, () => TransferRepository(db).offerById(offerId));
    // Kontra dari agen: tawaran masih berjalan, pesan inbox belum selesai.
    expect(offer!.isActive, isTrue);
    expect(find.textContaining('Kesabaran 100%'), findsNothing);
    final pending = await io(tester, () => InboxRepository(db).pendingActions());
    expect(
      pending.any((m) => m.actionType == InboxActionType.counterOffer),
      isTrue,
    );
  });

  testWidgets('Tab Negosiasi: sepakat harga lalu kontrak sampai pemain pindah', (
    tester,
  ) async {
    tallPhone(tester);
    await setUpWorld(tester);
    final (p, offerId) = await countered(tester);

    await show(tester, const TransferScreen(initialTab: 3));
    expect(find.text(p.fullName), findsWidgets);
    await tester.tap(find.widgetWithText(FilledButton, 'Negosiasi'));
    await settle(tester);
    expect(find.byType(NegotiationRoomScreen), findsOneWidget);

    await tester.tap(find.byWidgetPredicate(
      (w) => w is FilledButton && w.child is FittedBox,
    ));
    await settle(tester);
    expect(find.text('Sepakat'), findsOneWidget);
    expect(
      (await io(tester, () => TransferRepository(db).offerById(offerId)))!.status,
      TransferOfferStatus.awaitingContract,
    );

    await tapText(tester, 'Lanjut ke kontrak');
    expect(find.text('Gaji diminta agen'), findsOneWidget);
    await tester.tap(find.byWidgetPredicate(
      (w) => w is FilledButton && w.child is FittedBox,
    ));
    await settle(tester);

    expect(tester.takeException(), isNull);
    final moved = await io(tester, () => PlayerRepository(db).byId(p.id));
    expect(moved!.clubId, _us);
  });

  testWidgets('Inbox: tawaran masuk ditawar di Ruang Negosiasi lalu dijual', (
    tester,
  ) async {
    tallPhone(tester);
    await setUpWorld(tester);
    final (p, offerId) = await io(tester, () async {
      final ours = await PlayerRepository(db).squad(_us);
      ours.sort((a, b) => a.marketValue.compareTo(b.marketValue));
      final p = ours.first;
      final id = await TransferRepository(db).insertOffer(
        playerId: p.id,
        fromClubId: 'sevilla',
        toClubId: _us,
        fee: 1000,
        status: TransferOfferStatus.awaitingContract,
        createdDate: start,
        responseDate: start,
      );
      await InboxRepository(db).add(
        InboxMessage(
          id: 0,
          date: start,
          category: InboxCategory.transfer,
          title: 'Tawaran masuk: ${p.fullName}',
          body: 'Sevilla menawar.',
          isRead: false,
          actionType: InboxActionType.incomingTransferOffer,
          payload: 'offer:$id',
          resolved: false,
          choice: null,
        ),
      );
      return (p, id);
    });

    await show(tester, const InboxScreen());
    await tester.tap(find.text('Tawaran masuk: ${p.fullName}'));
    await settle(tester);
    await tester.tap(find.text('Masuk ruang negosiasi'));
    await settle(tester);
    expect(find.text('Tawaran pembeli'), findsOneWidget);

    // Minta 8% lebih tinggi: pembeli menaikkan tawaran atau langsung setuju.
    await tester.enterText(find.byType(TextField), '1080');
    await settle(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ajukan tawaran'));
    await settle(tester);
    if (find.text('Sepakat').evaluate().isEmpty) {
      await tester.tap(find.byWidgetPredicate(
        (w) => w is FilledButton && w.child is FittedBox,
      ));
      await settle(tester);
    }

    expect(tester.takeException(), isNull);
    expect(find.text('Sepakat'), findsOneWidget);
    final offer = await io(tester, () => TransferRepository(db).offerById(offerId));
    expect(offer!.status, TransferOfferStatus.completed);
    final moved = await io(tester, () => PlayerRepository(db).byId(p.id));
    expect(moved!.clubId, 'sevilla');
    final pending = await io(tester, () => InboxRepository(db).pendingActions());
    expect(pending.where((m) => m.payload == 'offer:$offerId'), isEmpty);
  });
}
