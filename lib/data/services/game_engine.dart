import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../domain/enums/inbox.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/season/fixture_generator.dart';
import '../../domain/season/league_table.dart';
import '../../domain/season/quick_match_simulator.dart';
import '../../domain/season/season_calendar.dart';
import '../database/app_database.dart';
import '../repositories/club_repository.dart';
import '../repositories/fixture_repository.dart';
import '../repositories/game_state_repository.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/player_repository.dart';

enum ContinueStop { blockingAction, matchDay, seasonOver, dayLimit }

class ContinueResult {
  const ContinueResult({required this.daysAdvanced, required this.stop});

  final int daysAdvanced;
  final ContinueStop stop;
}

class MatchOutcome {
  const MatchOutcome({
    required this.fixtureId,
    required this.date,
    required this.homeClubId,
    required this.awayClubId,
    required this.homeName,
    required this.awayName,
    required this.homeGoals,
    required this.awayGoals,
  });

  final int fixtureId;
  final DateTime date;
  final String homeClubId;
  final String awayClubId;
  final String homeName;
  final String awayName;
  final int homeGoals;
  final int awayGoals;
}

class MatchDayResult {
  const MatchDayResult({required this.ours, required this.others});

  final MatchOutcome ours;
  final List<MatchOutcome> others; // hasil laga lain di tanggal yang sama
}

class GameStatus {
  const GameStatus({
    required this.date,
    required this.clubId,
    required this.pendingActions,
    required this.todayFixture,
    required this.nextFixture,
    required this.seasonOver,
  });

  final DateTime date;
  final String? clubId;
  final List<InboxMessage> pendingActions;
  final Fixture? todayFixture; // laga tim kita hari ini (belum dimainkan)
  final Fixture? nextFixture; // laga tim kita berikutnya
  final bool seasonOver;
}

/// Mesin musim: kalender, CONTINUE, simulasi laga, dan inbox.
class GameEngine {
  GameEngine(this._db)
    : _clubs = ClubRepository(_db),
      _players = PlayerRepository(_db),
      _fixtures = FixtureRepository(_db),
      _inbox = InboxRepository(_db),
      _states = GameStateRepository(_db);

  final AppDatabase _db;
  final ClubRepository _clubs;
  final PlayerRepository _players;
  final FixtureRepository _fixtures;
  final InboxRepository _inbox;
  final GameStateRepository _states;

  static const int maxDaysPerContinue = 120;
  static const int recoveryPerDay = 5;

  // --- Inisialisasi ----------------------------------------------------------

  /// Membuat jadwal dan pesan sambutan bila belum ada. Aman dipanggil berulang.
  Future<void> ensureSeasonInitialized() async {
    final state = await _states.load();
    if (state == null) return;
    if (!await _fixtures.hasAny()) await _createSchedule();
    if (!await _inbox.hasAny() && state.clubId != null) {
      await _addWelcome(state);
    }
  }

  Future<void> _createSchedule() async {
    final leagues = await _clubs.leagues();
    final all = <Fixture>[];
    var nextId = 1;
    for (final league in leagues) {
      final clubs = await _clubs.clubsByLeague(league.id);
      final ids = clubs.map((c) => c.id).toList()..sort();
      final saturdays = SeasonCalendar.roundSaturdays(2 * (ids.length - 1));
      final list = FixtureGenerator.generate(
        leagueId: league.id,
        clubIds: ids,
        roundSaturdays: saturdays,
        startId: nextId,
      );
      nextId += list.length;
      all.addAll(list);
    }
    await _fixtures.insertAll(all);
  }

  Future<void> _addWelcome(GameState state) async {
    final club = await _clubs.clubById(state.clubId!);
    if (club == null) return;
    final teams = (await _clubs.clubsByLeague(club.leagueId)).length;
    final target = LeagueTable.targetPosition(club.reputation, teams);
    await _inbox.add(
      InboxMessage(
        id: 0,
        date: state.currentDate,
        category: InboxCategory.board,
        title: 'Sambutan dewan',
        body:
            'Selamat datang di ${club.name}, Manajer ${state.managerName}. '
            'Target musim ini: finis di posisi $target atau lebih baik. '
            'Terima target ini untuk memulai musim.',
        isRead: false,
        actionType: InboxActionType.acceptTarget,
        payload: 'target:$target',
        resolved: false,
        choice: null,
      ),
    );
  }

  // --- Status ----------------------------------------------------------------

  Future<GameStatus> status() async {
    final state = await _states.load();
    if (state == null) throw StateError('Save belum berisi data karier.');

    final clubId = state.clubId;
    Fixture? today;
    Fixture? next;
    var over = false;
    if (clubId != null) {
      final ours = await _fixtures.forClub(clubId);
      final unplayed = ours.where((f) => !f.played).toList();
      for (final f in unplayed) {
        if (f.date == state.currentDate) {
          today = f;
          break;
        }
      }
      for (final f in unplayed) {
        if (!f.date.isBefore(state.currentDate)) {
          next = f;
          break;
        }
      }
      over = ours.isNotEmpty && unplayed.isEmpty;
    }

    return GameStatus(
      date: state.currentDate,
      clubId: clubId,
      pendingActions: await _inbox.pendingActions(),
      todayFixture: today,
      nextFixture: next,
      seasonOver: over,
    );
  }

  // --- CONTINUE --------------------------------------------------------------

  /// Maju hari demi hari sampai ada tindakan, hari laga tim kita, musim
  /// selesai, atau batas [maxDays] tercapai.
  Future<ContinueResult> continueGame({
    int maxDays = maxDaysPerContinue,
  }) async {
    var advanced = 0;
    while (true) {
      final s = await status();
      if (s.pendingActions.isNotEmpty) {
        return ContinueResult(
          daysAdvanced: advanced,
          stop: ContinueStop.blockingAction,
        );
      }
      if (s.todayFixture != null) {
        return ContinueResult(
          daysAdvanced: advanced,
          stop: ContinueStop.matchDay,
        );
      }
      if (s.seasonOver) {
        return ContinueResult(
          daysAdvanced: advanced,
          stop: ContinueStop.seasonOver,
        );
      }
      if (advanced >= maxDays) {
        return ContinueResult(
          daysAdvanced: advanced,
          stop: ContinueStop.dayLimit,
        );
      }

      final next = s.date.add(const Duration(days: 1));
      await _db.transaction(() async {
        await _setDate(next);
        await _processDay(next, s.clubId);
      });
      advanced++;
    }
  }

  Future<void> _setDate(DateTime date) async {
    final state = await _states.load();
    if (state == null) return;
    await _states.save(
      GameState(
        currentDate: date,
        managerName: state.managerName,
        clubId: state.clubId,
        seed: state.seed,
      ),
    );
  }

  Future<void> _processDay(DateTime d, String? clubId) async {
    // Pemulihan kondisi +5 untuk semua pemain (dibatasi 100).
    await _db.customUpdate(
      'UPDATE players SET "condition" = MIN(100, "condition" + $recoveryPerDay)',
      updates: {_db.players},
    );

    if (d.day == 1) await _payMonthlyWages();

    if (clubId != null) {
      if (d.month == 1 && d.day == 1) await _contractExpiry(d, clubId);
      await _scoutingReport(d, clubId);
    }

    final seed = (await _states.load())!.seed;
    for (final f in await _fixtures.onDate(d)) {
      if (f.played) continue;
      // Laga tim kita tidak diproses di sini; dimainkan lewat playMatchDay().
      if (clubId != null && f.involves(clubId)) continue;
      await _playFixture(f, seed);
    }
  }

  // --- Hari laga tim kita ----------------------------------------------------

  Future<MatchDayResult> playMatchDay() async {
    final state = await _states.load();
    if (state == null) throw StateError('Save belum berisi data karier.');
    final s = await status();
    final f = s.todayFixture;
    final clubId = state.clubId;
    if (f == null || clubId == null) {
      throw StateError('Tidak ada laga tim Anda hari ini.');
    }

    final ours = await _playFixture(f, state.seed);
    final goalsFor = f.homeClubId == clubId ? ours.homeGoals : ours.awayGoals;
    final goalsAgainst =
        f.homeClubId == clubId ? ours.awayGoals : ours.homeGoals;
    final delta =
        goalsFor > goalsAgainst
            ? 4
            : goalsFor == goalsAgainst
            ? 0
            : -4;
    await _applyMorale(clubId, delta);

    await _inbox.add(
      InboxMessage(
        id: 0,
        date: state.currentDate,
        category: InboxCategory.match,
        title:
            'Hasil: ${ours.homeName} ${ours.homeGoals}-${ours.awayGoals} ${ours.awayName}',
        body:
            'Moral skuad ${delta > 0
                ? 'naik'
                : delta < 0
                ? 'turun'
                : 'tetap'} '
            '(${delta >= 0 ? '+' : ''}$delta).',
        isRead: false,
        actionType: InboxActionType.none,
        payload: null,
        resolved: false,
        choice: null,
      ),
    );

    final others = <MatchOutcome>[];
    for (final o in await _fixtures.onDate(state.currentDate)) {
      if (o.played && !o.involves(clubId)) others.add(await _outcome(o));
    }

    if ((await status()).seasonOver) {
      await _addSeasonSummary(clubId, state.currentDate);
    }
    return MatchDayResult(ours: ours, others: others);
  }

  // --- Inbox -----------------------------------------------------------------

  Future<void> resolveMessage(InboxMessage m, String choice) async {
    if (m.actionType == InboxActionType.contractDecision && choice == 'renew') {
      final playerId = int.parse(m.payload!.split(':').last);
      final contract =
          await (_db.select(_db.contracts)
            ..where((t) => t.playerId.equals(playerId))).getSingleOrNull();
      if (contract != null) {
        final end = contract.endDate.toUtc();
        await (_db.update(_db.contracts)
          ..where((t) => t.playerId.equals(playerId))).write(
          ContractsCompanion(
            endDate: Value(DateTime.utc(end.year + 2, 6, 30)),
            wage: Value((contract.wage * 1.1).round()),
          ),
        );
      }
    }
    await _inbox.resolve(m.id, choice);
  }

  Future<void> markRead(int id) => _inbox.markRead(id);

  Future<List<InboxMessage>> inbox() => _inbox.all();

  // --- Helper: pesan otomatis -------------------------------------------------

  Future<void> _scoutingReport(DateTime d, String clubId) async {
    final tomorrow = d.add(const Duration(days: 1));
    Fixture? f;
    for (final x in await _fixtures.forClub(clubId)) {
      if (!x.played && x.date == tomorrow) {
        f = x;
        break;
      }
    }
    if (f == null) return;

    final oppId = f.homeClubId == clubId ? f.awayClubId : f.homeClubId;
    final opp = await _clubs.clubById(oppId);
    final squad = await _players.squad(oppId);
    final table = await _tableOf(f.leagueId);
    final pos = table.indexWhere((r) => r.clubId == oppId);
    if (opp == null || pos < 0 || squad.isEmpty) return;
    final row = table[pos];
    final key = squad.first;

    await _inbox.add(
      InboxMessage(
        id: 0,
        date: d,
        category: InboxCategory.scouting,
        title: 'Laporan lawan: ${opp.name}',
        body:
            'Laga ${f.homeClubId == clubId ? 'kandang' : 'tandang'} besok. '
            '${opp.name} di posisi ${pos + 1} dengan ${row.points} poin. '
            'Bentuk terakhir: ${row.form.isEmpty ? '-' : row.form.join(' ')}. '
            'Pemain kunci: ${key.fullName} (CA ${key.currentAbility}).',
        isRead: false,
        actionType: InboxActionType.none,
        payload: null,
        resolved: false,
        choice: null,
      ),
    );
  }

  Future<void> _contractExpiry(DateTime d, String clubId) async {
    final expiring =
        await (_db.select(_db.contracts)..where(
          (t) =>
              t.clubId.equals(clubId) &
              t.endDate.equals(DateTime.utc(d.year, 6, 30)),
        )).get();
    if (expiring.isEmpty) return;

    final squad = await _players.squad(clubId);
    for (final c in expiring) {
      Player? p;
      for (final x in squad) {
        if (x.id == c.playerId) {
          p = x;
          break;
        }
      }
      if (p == null) continue;
      await _inbox.add(
        InboxMessage(
          id: 0,
          date: d,
          category: InboxCategory.contract,
          title: 'Kontrak ${p.fullName} segera berakhir',
          body:
              'Kontrak berakhir 30 Juni ${d.year}. Gaji saat ini '
              '${_money(c.wage)}/tahun. Perpanjang 2 tahun dengan kenaikan '
              'gaji 10%, atau biarkan pergi.',
          isRead: false,
          actionType: InboxActionType.contractDecision,
          payload: 'player:${p.id}',
          resolved: false,
          choice: null,
        ),
      );
    }
  }

  Future<void> _addSeasonSummary(String clubId, DateTime date) async {
    final club = await _clubs.clubById(clubId);
    if (club == null) return;
    final table = await _tableOf(club.leagueId);
    final pos = table.indexWhere((r) => r.clubId == clubId) + 1;
    final row = table[pos - 1];
    final target = LeagueTable.targetPosition(club.reputation, table.length);
    await _inbox.add(
      InboxMessage(
        id: 0,
        date: date,
        category: InboxCategory.season,
        title: 'Musim selesai',
        body:
            'Posisi akhir $pos dari ${table.length} dengan ${row.points} poin '
            '(${row.won}M ${row.drawn}S ${row.lost}K). Target dewan: posisi $target. '
            '${pos <= target ? 'Target tercapai.' : 'Target belum tercapai.'}',
        isRead: false,
        actionType: InboxActionType.none,
        payload: null,
        resolved: false,
        choice: null,
      ),
    );
  }

  // --- Simulasi & keuangan ---------------------------------------------------

  Future<List<LeagueTableRow>> _tableOf(String leagueId) async {
    final clubs =
        (await _clubs.clubsByLeague(leagueId)).map((c) => c.id).toList()
          ..sort();
    final fixtures = await _fixtures.forLeague(leagueId);
    return LeagueTable.compute(clubIds: clubs, fixtures: fixtures);
  }

  Future<MatchOutcome> _playFixture(Fixture f, int seed) async {
    final homeSquad = await _players.squad(f.homeClubId);
    final awaySquad = await _players.squad(f.awayClubId);
    final xiH = QuickMatchSimulator.startingXI(homeSquad);
    final xiA = QuickMatchSimulator.startingXI(awaySquad);

    final (hg, ag) = QuickMatchSimulator.simulate(
      homeRating: QuickMatchSimulator.teamRating(xiH),
      awayRating: QuickMatchSimulator.teamRating(xiA),
      seed: seed,
      fixtureId: f.id,
    );
    await _fixtures.setResult(f.id, hg, ag);
    await _applyFatigue([...xiH, ...xiA], seed, f.id);

    final home = await _clubs.clubById(f.homeClubId);
    if (home != null) await _addTicketRevenue(home);

    return _outcome(
      Fixture(
        id: f.id,
        leagueId: f.leagueId,
        round: f.round,
        date: f.date,
        homeClubId: f.homeClubId,
        awayClubId: f.awayClubId,
        homeGoals: hg,
        awayGoals: ag,
      ),
    );
  }

  Future<MatchOutcome> _outcome(Fixture f) async {
    final home = await _clubs.clubById(f.homeClubId);
    final away = await _clubs.clubById(f.awayClubId);
    return MatchOutcome(
      fixtureId: f.id,
      date: f.date,
      homeClubId: f.homeClubId,
      awayClubId: f.awayClubId,
      homeName: home?.name ?? f.homeClubId,
      awayName: away?.name ?? f.awayClubId,
      homeGoals: f.homeGoals ?? 0,
      awayGoals: f.awayGoals ?? 0,
    );
  }

  Future<void> _applyFatigue(List<Player> xi, int seed, int fixtureId) async {
    await _db.batch((b) {
      for (final p in xi) {
        final loss = QuickMatchSimulator.conditionLoss(seed, fixtureId, p.id);
        final next = math.max(0, p.condition - loss);
        b.update(
          _db.players,
          PlayersCompanion(condition: Value(next)),
          where: (t) => t.id.equals(p.id),
        );
      }
    });
  }

  Future<void> _applyMorale(String clubId, int delta) async {
    final squad = await _players.squad(clubId);
    await _db.batch((b) {
      for (final p in squad) {
        final next = math.max(0, math.min(100, p.morale + delta));
        b.update(
          _db.players,
          PlayersCompanion(morale: Value(next)),
          where: (t) => t.id.equals(p.id),
        );
      }
    });
  }

  /// Pendapatan tiket tuan rumah: kapasitas × 90% × harga tiket (€20 + rep×0,4).
  Future<void> _addTicketRevenue(Club home) async {
    final ticket = 20 + home.reputation * 0.4;
    final revenueK = (home.capacity * 0.9 * ticket / 1000).round();
    await _db.customUpdate(
      'UPDATE clubs SET balance = balance + ? WHERE id = ?',
      variables: [Variable.withInt(revenueK), Variable.withString(home.id)],
      updates: {_db.clubs},
    );
  }

  /// Gaji bulanan (1/12 gaji tahunan) dipotong dari saldo tiap klub.
  Future<void> _payMonthlyWages() async {
    final contracts = await _db.select(_db.contracts).get();
    final perClub = <String, int>{};
    for (final c in contracts) {
      perClub.update(
        c.clubId,
        (v) => v + c.wage ~/ 12,
        ifAbsent: () => c.wage ~/ 12,
      );
    }
    for (final e in perClub.entries) {
      await _db.customUpdate(
        'UPDATE clubs SET balance = balance - ? WHERE id = ?',
        variables: [Variable.withInt(e.value), Variable.withString(e.key)],
        updates: {_db.clubs},
      );
    }
  }

  static String _money(int thousands) =>
      thousands >= 1000
          ? '€${(thousands / 1000).toStringAsFixed(1)} jt'
          : '€$thousands rb';
}
