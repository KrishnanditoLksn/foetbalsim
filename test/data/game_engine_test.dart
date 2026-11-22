import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/database/app_database.dart';
import 'package:futbol/data/repositories/fixture_repository.dart';
import 'package:futbol/data/repositories/world_repository.dart';
import 'package:futbol/data/services/game_engine.dart';
import 'package:futbol/domain/enums/inbox.dart';
import 'package:futbol/domain/generators/world_generator.dart';
import 'package:futbol/domain/models/game_models.dart';

const _clubId = 'real-madrid';

void main() {
  final seedJson = File('assets/seed/spain.json').readAsStringSync();
  late AppDatabase db;
  late GameEngine engine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final world = WorldGenerator.generate(seedJson: seedJson, seed: 99);
    await WorldRepository(db).saveWorld(
      world,
      GameState(
        currentDate: WorldGenerator.seasonStart,
        managerName: 'Tester',
        clubId: _clubId,
        seed: 99,
      ),
    );
    engine = GameEngine(db);
    await engine.ensureSeasonInitialized();
  });

  tearDown(() async => db.close());

  /// Menerima semua tindakan inbox yang tertunda.
  Future<void> resolveAllActions() async {
    final status = await engine.status();
    for (final m in status.pendingActions) {
      final choice =
          m.actionType == InboxActionType.acceptTarget ? 'accept' : 'leave';
      await engine.resolveMessage(m, choice);
    }
  }

  test('jadwal 842 laga dan sambutan dibuat sekali saja', () async {
    final fixtures = FixtureRepository(db);
    expect((await fixtures.forLeague('laliga')).length, 380);
    expect((await fixtures.forLeague('laliga-hypermotion')).length, 462);

    await engine.ensureSeasonInitialized(); // panggilan kedua tidak mengulang
    expect((await fixtures.forLeague('laliga')).length, 380);
    expect((await engine.inbox()).length, 1);
  });

  test('CONTINUE tertahan oleh sambutan dewan (0 hari)', () async {
    final result = await engine.continueGame();
    expect(result.daysAdvanced, 0);
    expect(result.stop, ContinueStop.blockingAction);
  });

  test(
    'setelah target diterima, CONTINUE berhenti di hari laga pertama',
    () async {
      await resolveAllActions();
      final result = await engine.continueGame();
      expect(result.stop, ContinueStop.matchDay);

      final status = await engine.status();
      expect(status.todayFixture, isNotNull);
      expect(status.date, status.todayFixture!.date);
      expect(status.date.isBefore(DateTime.utc(2025, 8, 15)), isFalse);
    },
  );

  test(
    'playMatchDay menyimpan skor dan laga tidak bisa dimainkan dua kali',
    () async {
      await resolveAllActions();
      await engine.continueGame();
      final today = (await engine.status()).todayFixture!;

      final res = await engine.playMatchDay();
      expect(res.ours.fixtureId, today.id);

      final saved = (await FixtureRepository(
        db,
      ).forClub(_clubId)).firstWhere((f) => f.id == today.id);
      expect(saved.played, isTrue);
      expect(saved.homeGoals, res.ours.homeGoals);
      expect(saved.awayGoals, res.ours.awayGoals);

      await expectLater(engine.playMatchDay(), throwsStateError);
    },
  );

  test(
    'musim penuh bisa dimainkan sampai selesai',
    () async {
      await resolveAllActions();

      var matchesPlayed = 0;
      for (var guard = 0; guard < 2000; guard++) {
        final result = await engine.continueGame();
        if (result.stop == ContinueStop.blockingAction) {
          await resolveAllActions();
        } else if (result.stop == ContinueStop.matchDay) {
          await engine.playMatchDay();
          matchesPlayed++;
        } else {
          break;
        }
      }

      final status = await engine.status();
      expect(status.seasonOver, isTrue);
      expect(
        matchesPlayed,
        38,
      ); // LaLiga: 38 pekan, tim kita bermain tiap pekan

      final ours = await FixtureRepository(db).forClub(_clubId);
      expect(ours.every((f) => f.played), isTrue);
      expect(ours.length, 38);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
