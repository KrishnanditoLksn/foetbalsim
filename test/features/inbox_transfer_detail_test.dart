import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/app/providers.dart';
import 'package:futbol/app/router.dart';
import 'package:futbol/app/theme.dart';
import 'package:futbol/core/widgets/club_badge.dart';
import 'package:futbol/core/widgets/player_avatar.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/inbox_repository.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/data/services/transfer_service.dart';
import 'package:futbol/domain/enums/inbox.dart';
import 'package:futbol/domain/enums/transfer.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/domain/models/season_models.dart';
import 'package:futbol/domain/models/transfer_news_payload.dart';
import 'package:futbol/features/inbox/inbox_message_dialog.dart';
import 'package:futbol/features/inbox/inbox_screen.dart';
import 'package:futbol/features/inbox/transfer_news_detail_dialog.dart';
import 'package:futbol/features/player/player_detail_screen.dart';
import 'package:futbol/l10n/l10n.dart';

/// README_TRANSFER_NEWS_DETAIL F: kartu detail berita transfer di Inbox
/// (layar ponsel 360 dp), termasuk pesan dari save lama.
const _us = 'real-madrid';
const _seller = 'getafe';

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final start = WorldGenerator.seasonStart;
  late AppDatabase db;

  Future<T> io<T>(WidgetTester tester, Future<T> Function() fn) async =>
      (await tester.runAsync(fn)) as T;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> setUpWorld(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final world = WorldGenerator.generate(seedJson: seedJson, seed: 99);
      await WorldRepository(db).saveWorld(
        world,
        GameState(currentDate: start, managerName: 'T', clubId: _us, seed: 99),
      );
      await GameEngine(db).ensureSeasonInitialized();
    });
    addTearDown(() => tester.runAsync(db.close));
  }

  Future<void> showInbox(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentDatabaseProvider.overrideWith((ref) => db)],
        child: MaterialApp(
          theme: AppTheme.board(),
          home: const InboxScreen(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
    await settle(tester);
  }

  Future<Player> sellerPlayer(WidgetTester tester) =>
      io(tester, () async => (await PlayerRepository(db).squad(_seller)).first);

  Future<void> addMessage(WidgetTester tester, String title, String? payload) =>
      io(
        tester,
        () => InboxRepository(db).add(
          InboxMessage(
            id: 0,
            date: start,
            category: InboxCategory.transfer,
            title: title,
            body: 'Isi berita.',
            isRead: false,
            actionType: InboxActionType.none,
            payload: payload,
            resolved: false,
            choice: null,
          ),
        ),
      );

  Finder inDialog(Finder f) =>
      find.descendant(of: find.byType(TransferNewsDetailDialog), matching: f);

  testWidgets('transfer selesai: avatar, klub asal → tujuan, kontrak, status', (
    tester,
  ) async {
    await setUpWorld(tester);
    final p = await sellerPlayer(tester);
    await io(
      tester,
      () => TransferService(db).completeTransfer(
        player: p,
        buyerId: _us,
        sellerId: _seller,
        fee: 4200,
        wage: 900,
        years: 4,
        date: start,
        type: TransferType.buy,
      ),
    );
    final message = (await io(
      tester,
      () => InboxRepository(db).all(),
    )).firstWhere((m) => TransferNewsPayload.tryParse(m.payload) != null);

    await showInbox(tester);
    // Pratinjau di daftar: avatar mini, status, rute klub.
    expect(find.byType(PlayerAvatar), findsWidgets);
    expect(find.text('Resmi · Selesai'), findsOneWidget);
    expect(
      find.textContaining('Real Madrid · ${formatMoney(4200)}'),
      findsOneWidget,
    );

    await tester.tap(find.text(trText(message.title)));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(TransferNewsDetailDialog), findsOneWidget);
    expect(inDialog(find.byType(PlayerAvatar)), findsOneWidget);
    expect(inDialog(find.byType(ClubBadge)), findsNWidgets(2));
    expect(inDialog(find.text('Resmi · Selesai')), findsOneWidget);
    expect(inDialog(find.text(p.fullName)), findsOneWidget);
    expect(inDialog(find.text('Getafe')), findsOneWidget);
    expect(inDialog(find.text('Real Madrid')), findsOneWidget);
    expect(inDialog(find.text('Masa kontrak')), findsOneWidget);
    expect(inDialog(find.text('4 tahun')), findsOneWidget);
    expect(
      inDialog(
        find.text('Hingga ${formatDate(DateTime.utc(start.year + 4, 6, 30))}'),
      ),
      findsOneWidget,
    );
    expect(inDialog(find.text(formatMoney(4200))), findsOneWidget);
    expect(inDialog(find.text('Gaji tahunan')), findsOneWidget);
    expect(inDialog(find.text('Peran skuad')), findsOneWidget);

    await tester.tap(inDialog(find.text('Lihat pemain')));
    await settle(tester);
    expect(find.byType(PlayerDetailScreen), findsOneWidget);
  });

  testWidgets('ditolak: badge merah tanpa kontrak baru', (tester) async {
    await setUpWorld(tester);
    final p = await sellerPlayer(tester);
    await addMessage(
      tester,
      'Ditolak: ${p.fullName}',
      TransferNewsPayload(
        playerId: p.id,
        playerName: p.fullName,
        fromClubId: _seller,
        toClubId: _us,
        status: TransferNewsStatus.rejected,
        fee: 800,
        contractEndDate: DateTime.utc(2028, 6, 30),
        wage: 300,
      ).encode(),
    );
    await showInbox(tester);
    await tester.tap(find.text('Ditolak: ${p.fullName}'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(inDialog(find.text('Ditolak')), findsOneWidget);
    expect(inDialog(find.text('Nilai tawaran')), findsOneWidget);
    expect(inDialog(find.text('Masa kontrak')), findsNothing);
    expect(inDialog(find.text('Kontrak saat ini')), findsNothing);
  });

  testWidgets('pesan tanpa rincian transfer memakai kartu pesan', (tester) async {
    await setUpWorld(tester);
    await addMessage(tester, 'Berita lama tanpa payload', null);
    await addMessage(tester, 'Berita lama offer', 'offer:9999');
    await showInbox(tester);

    for (final title in ['Berita lama tanpa payload', 'Berita lama offer']) {
      await tester.tap(find.text(title).first);
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(TransferNewsDetailDialog), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(InboxMessageDialog), findsOneWidget);
      expect(find.text('Isi berita.'), findsOneWidget);
      await tester.tap(find.text('Tutup'));
      await settle(tester);
    }
  });
}
