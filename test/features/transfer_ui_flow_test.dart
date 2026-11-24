import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/providers.dart';
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
import 'package:futbol/features/inbox/inbox_screen.dart';
import 'package:futbol/features/transfer/transfer_screen.dart';

/// Alur UI negosiasi lanjutan. Semua dialog di sini dulu membuang
/// TextEditingController saat dialog masih dianimasikan (aplikasi error).
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
    for (var i = 0; i < 10; i++) {
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
        child: MaterialApp(home: screen),
      ),
    );
    await settle(tester);
  }

  /// Pemain penjual bernilai ≥ €3 jt dengan tawaran 85% → kontra-tawaran.
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
    await svc.resolveDueBids(date: start.add(const Duration(days: 2)), ourClubId: _us, seed: 99);
    final offer = (await TransferRepository(db).offersFor(_us)).firstWhere(
      (o) => o.playerId == p.id,
    );
    return (p, offer.id);
  });

  testWidgets('Inbox: kontra-tawaran → tawaran final', (tester) async {
    await setUpWorld(tester);
    final (p, offerId) = await countered(tester);
    expect(
      (await io(tester, () => TransferRepository(db).offerById(offerId)))!.status,
      TransferOfferStatus.countered,
    );

    await show(tester, const InboxScreen());
    await tester.tap(find.text('Kontra-tawaran: ${p.fullName}'));
    await settle(tester);
    await tester.tap(find.text('Tawaran final'));
    await settle(tester);
    await tester.tap(find.text('Kirim tawaran final'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    final offer = await io(tester, () => TransferRepository(db).offerById(offerId));
    expect(offer!.status, TransferOfferStatus.pending);
    expect(offer.round, 3);
  });

  testWidgets('Negosiasi: ajukan kontrak sampai pemain pindah', (tester) async {
    await setUpWorld(tester);
    final (p, offerId) = await countered(tester);
    await io(
      tester,
      () => svc.respond(offerId: offerId, choice: 'accept', date: start, ourClubId: _us),
    );

    await show(tester, const TransferScreen(initialTab: 3));
    expect(find.text(p.fullName), findsWidgets);
    await tester.tap(find.widgetWithText(FilledButton, 'Ajukan kontrak'));
    await settle(tester);
    // "Negosiasi kontrak" juga label chip status, jadi cari di dalam dialog.
    expect(find.widgetWithText(AlertDialog, 'Negosiasi kontrak'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Ajukan kontrak').last);
    await settle(tester);

    expect(tester.takeException(), isNull);
    final moved = await io(tester, () => PlayerRepository(db).byId(p.id));
    expect(moved!.clubId, _us);
  });

  testWidgets('Inbox: kontra untuk tawaran masuk menjual pemain', (tester) async {
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
    await tester.tap(find.text('Kontra'));
    await settle(tester);
    expect(find.text('Ajukan harga'), findsOneWidget);
    await tester.tap(find.text('Kirim'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    final offer = await io(tester, () => TransferRepository(db).offerById(offerId));
    expect(offer!.status, TransferOfferStatus.completed);
    final moved = await io(tester, () => PlayerRepository(db).byId(p.id));
    expect(moved!.clubId, 'sevilla');
  });
}
