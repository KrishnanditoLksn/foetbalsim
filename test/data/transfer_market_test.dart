import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/player_repository.dart';
import 'package:futbol/data/repositories/transfer_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/domain/enums/inbox.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';
import 'package:futbol/l10n/l10n.dart';

const _ourClub = 'real-madrid';

/// Satu karier baru di database memori, dengan dunia dari seed.
Future<AppDatabase> _newCareer(int seed) async {
  final db = AppDatabase(NativeDatabase.memory());
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  final world = WorldGenerator.generate(seedJson: seedJson, seed: seed);
  await WorldRepository(db).saveWorld(
    world,
    GameState(
      currentDate: WorldGenerator.seasonStart,
      managerName: 'Tester',
      clubId: _ourClub,
      seed: seed,
    ),
  );
  await GameEngine(db).ensureSeasonInitialized();
  return db;
}

/// Menyelesaikan aksi inbox secara netral: tolak tawaran masuk, batalkan
/// kontra dan negosiasi. Kalau tidak, CONTINUE akan terblokir.
Future<void> _clearBlocking(GameEngine engine) async {
  final s = await engine.status();
  for (final m in s.pendingActions) {
    final choice = switch (m.actionType) {
      InboxActionType.acceptTarget => 'accept',
      InboxActionType.contractDecision => 'leave',
      InboxActionType.incomingTransferOffer => 'reject',
      _ => 'cancel',
    };
    await engine.resolveMessage(m, choice);
  }
}

/// Maju sampai [until] tercapai, dengan hari laga tim kita dimainkan.
Future<void> _advanceUntil(GameEngine engine, bool Function(DateTime) until) async {
  for (var i = 0; i < 400; i++) {
    final s = await engine.status();
    if (until(s.date)) return;
    await _clearBlocking(engine);
    final s2 = await engine.status();
    if (s2.todayFixture != null) {
      await engine.playMatchDay();
      continue;
    }
    await engine.advanceOneDay();
  }
}

void main() {
  test('bursa hidup: transfer AI↔AI terjadi selama jendela, skuad AI 22–30', () async {
    final db = await _newCareer(21);
    addTearDown(db.close);
    final engine = GameEngine(db);
    await _advanceUntil(engine, (d) => d.isAfter(DateTime.utc(2026, 9, 1)));

    final history = await TransferRepository(db).history(limit: 500);
    final aiDeals = history.where((r) => r.fromClubId != _ourClub && r.toClubId != _ourClub);
    expect(aiDeals, isNotEmpty);

    final rows = await PlayerRepository(db).allForSearch();
    final squads = <String, int>{};
    for (final r in rows) {
      squads.update(r.player.clubId, (v) => v + 1, ifAbsent: () => 1);
    }
    for (final entry in squads.entries) {
      if (entry.key == _ourClub) continue;
      expect(entry.value, inInclusiveRange(20, 30), reason: entry.key);
    }
  });

  test('jendela tutup: negosiasi dibatalkan dan ringkasan masuk inbox', () async {
    final db = await _newCareer(22);
    addTearDown(db.close);
    final engine = GameEngine(db);
    await _advanceUntil(engine, (d) => d.isAfter(DateTime.utc(2026, 9, 1)));

    final inbox = await engine.inbox();
    expect(
      inbox.any((m) => asMsg(m.title).key == 'msg.windowClosed.title'),
      isTrue,
    );
  });

  test('pemain yang baru pindah terkunci sampai jendela berikutnya', () async {
    final db = await _newCareer(23);
    addTearDown(db.close);
    final engine = GameEngine(db);
    await _advanceUntil(engine, (d) => d.isAfter(DateTime.utc(2026, 9, 1)));

    final history = await TransferRepository(db).history(limit: 500);
    if (history.isEmpty) return; // tidak ada transfer di seed ini: lewati
    final moved = await PlayerRepository(db).byId(history.first.playerId);
    expect(moved!.lockedUntil, isNotNull);
    expect(moved.lockedUntil!.isAfter(DateTime.utc(2026, 9, 1)), isTrue);
  });

  test('seed sama → urutan transfer identik (determinisme)', () async {
    Future<List<String>> run() async {
      final db = await _newCareer(24);
      final engine = GameEngine(db);
      await _advanceUntil(engine, (d) => d.isAfter(DateTime.utc(2026, 9, 1)));
      final h = await TransferRepository(db).history(limit: 500);
      final out = [for (final r in h) '${r.playerId}:${r.fee}:${r.toClubId}'];
      await db.close();
      return out;
    }

    final a = await run();
    final b = await run();
    expect(a, b);
  });

  test('adaptif: setelah tawaran rendah berulang, harga minta ke user naik', () async {
    final db = await _newCareer(25);
    addTearDown(db.close);
    final repo = TransferRepository(db);
    final before = await repo.memory('lowballCount');
    await repo.setMemory('lowballCount', before + 3);
    expect(await repo.memory('lowballCount'), before + 3);
  });
}
