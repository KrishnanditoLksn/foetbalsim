import '../../domain/generators/world_generator.dart';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../domain/enums/inbox.dart';
import '../../domain/enums/tactics.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/match/lineup_builder.dart';
import '../../domain/match/match_engine_2d.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/match_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/season/fixture_generator.dart';
import '../../domain/season/league_table.dart';
import '../../domain/season/quick_match_simulator.dart';
import '../../domain/season/season_calendar.dart';
import '../../domain/transfer/agent_negotiator.dart';
import '../database/app_database.dart';
import '../repositories/club_repository.dart';
import '../repositories/fixture_repository.dart';
import '../repositories/game_state_repository.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/tactics_repository.dart';
import '../repositories/transfer_repository.dart';
import 'transfer_market_service.dart';
import 'transfer_service.dart';

// ContinueStop dan DayReport didefinisikan di domain (season_models.dart) dan
// diekspor ulang agar pemakai GameEngine tetap bisa mengaksesnya dari sini.
export '../../domain/models/season_models.dart' show ContinueStop, DayReport;

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

/// Bahan untuk memulai laga 2D hari ini (laga tim kita).
class MatchSetup {
  const MatchSetup({
    required this.fixture,
    required this.seed,
    required this.home,
    required this.away,
  });

  final Fixture fixture;
  final int seed;
  final MatchTeamSetup home;
  final MatchTeamSetup away;
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
      _states = GameStateRepository(_db),
      _tactics = TacticsRepository(_db),
      _transfers = TransferService(_db),
      _market = TransferMarketService(_db);

  final AppDatabase _db;
  final ClubRepository _clubs;
  final PlayerRepository _players;
  final FixtureRepository _fixtures;
  final InboxRepository _inbox;
  final GameStateRepository _states;
  final TacticsRepository _tactics;
  final TransferService _transfers;
  final TransferMarketService _market;

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
      // Liga tingkat 1 selesai di batas LaLiga; tingkat 2 lebih awal (playoff).
      final last = league.tier == 1
          ? SeasonCalendar.lastLeagueRound(SeasonCalendar.firstSeasonYear)
          : SeasonCalendar.lastSecondTierRound(SeasonCalendar.firstSeasonYear);
      final roundDates = SeasonCalendar.roundDates(
        startYear: SeasonCalendar.firstSeasonYear,
        rounds: 2 * (ids.length - 1),
        last: last,
      );
      final list = FixtureGenerator.generate(
        leagueId: league.id,
        clubIds: ids,
        roundSaturdays: roundDates,
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

  /// LANJUTKAN = H+1 (README_FASE3 bagian A). Satu panggilan memajukan tepat
  /// satu hari, kecuali ada tindakan pending, hari laga tim kita, atau musim
  /// selesai: dalam kasus itu tanggal tidak berubah dan alasannya dikembalikan.
  Future<DayReport> advanceOneDay() async {
    final s = await status();
    final date = s.date;
    if (s.pendingActions.isNotEmpty) {
      return DayReport(
        date: date,
        advanced: false,
        stop: ContinueStop.blockingAction,
        notes: const [],
      );
    }
    if (s.todayFixture != null) {
      return DayReport(
        date: date,
        advanced: false,
        stop: ContinueStop.matchDay,
        notes: const [],
      );
    }
    if (s.seasonOver) {
      return DayReport(
        date: date,
        advanced: false,
        stop: ContinueStop.seasonOver,
        notes: const [],
      );
    }

    final next = date.add(const Duration(days: 1));
    await _db.transaction(() async {
      await _setDate(next);
      await _processDay(next, s.clubId);
    });
    return DayReport(
      date: next,
      advanced: true,
      stop: null,
      notes: await _dayNotes(next, s.clubId),
    );
  }

  /// Ringkasan "Hari Ini": hasil laga lain dan pesan inbox yang masuk pada
  /// tanggal [date].
  Future<List<String>> _dayNotes(DateTime date, String? clubId) async {
    final notes = <String>[];
    for (final f in await _fixtures.onDate(date)) {
      if (!f.played || (clubId != null && f.involves(clubId))) continue;
      final o = await _outcome(f);
      notes.add('${o.homeName} ${o.homeGoals}-${o.awayGoals} ${o.awayName}');
    }
    for (final m in await _inbox.all()) {
      if (m.date == date) notes.add(m.title);
    }
    return notes;
  }

  /// Menjalankan LANJUTKAN berulang (mode cepat dan tes). Berhenti pada
  /// tindakan, hari laga tim kita, musim selesai, atau batas [maxDays].
  Future<ContinueResult> continueGame({
    int maxDays = maxDaysPerContinue,
  }) async {
    var advanced = 0;
    while (true) {
      final report = await advanceOneDay();
      if (!report.advanced) {
        return ContinueResult(daysAdvanced: advanced, stop: report.stop!);
      }
      advanced++;
      if (advanced >= maxDays) {
        return ContinueResult(
          daysAdvanced: advanced,
          stop: ContinueStop.dayLimit,
        );
      }
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
      // Laga tim kita tidak diproses di sini; dimainkan lewat laga 2D.
      if (clubId != null && f.involves(clubId)) continue;
      await _playFixture(f, seed);
    }

    if (clubId != null) {
      await _market.processDay(date: d, seed: seed, ourClubId: clubId);
    }
  }

  // --- Hari laga tim kita ----------------------------------------------------

  /// Menyusun kedua tim untuk laga tim kita hari ini. Taktik tersimpan
  /// dipakai untuk tim kita; lawan memakai susunan otomatis 4-4-2.
  Future<MatchSetup> prepareMatch() async {
    final state = await _states.load();
    if (state == null) throw StateError('Save belum berisi data karier.');
    final s = await status();
    final f = s.todayFixture;
    final clubId = state.clubId;
    if (f == null || clubId == null) {
      throw StateError('Tidak ada laga tim Anda hari ini.');
    }

    final ourSide = f.homeClubId == clubId;
    final ourTeam = await _teamSetup(clubId, useSavedTactics: true);
    final oppTeam = await _teamSetup(
      ourSide ? f.awayClubId : f.homeClubId,
      useSavedTactics: false,
    );
    return MatchSetup(
      fixture: f,
      seed: state.seed,
      home: ourSide ? ourTeam : oppTeam,
      away: ourSide ? oppTeam : ourTeam,
    );
  }

  Future<MatchTeamSetup> _teamSetup(
    String clubId, {
    required bool useSavedTactics,
  }) async {
    final club = await _clubs.clubById(clubId);
    final squad = await _players.squad(clubId);
    final saved = useSavedTactics ? await _tactics.load(clubId) : null;
    final lineup = useSavedTactics
        ? LineupBuilder.resolve(squad, saved)
        : LineupBuilder.auto(squad, Formation.f442);
    return MatchTeamSetup(
      clubId: clubId,
      name: club?.name ?? clubId,
      formation: saved?.formation ?? Formation.f442,
      mentality: saved?.mentality ?? Mentality.balanced,
      starters: lineup.starters,
      bench: lineup.bench,
    );
  }

  /// Menyimpan hasil laga 2D tim kita: skor, kondisi & moral skuad, pendapatan
  /// tiket, dan laporan di inbox. Laga hanya bisa disimpan sekali.
  Future<MatchDayResult> commitMatch(MatchResultData r) async {
    final state = await _states.load();
    if (state == null) throw StateError('Save belum berisi data karier.');
    final clubId = state.clubId;
    if (clubId == null) throw StateError('Belum ada klub.');
    final fixtures = await _fixtures.forClub(clubId);
    final f = fixtures.firstWhere(
      (x) => x.id == r.fixtureId,
      orElse: () => throw StateError('Laga tidak ditemukan.'),
    );
    if (f.played) throw StateError('Laga ini sudah dimainkan.');

    await _fixtures.setResult(f.id, r.homeGoals, r.awayGoals);
    await _applyMatchLoad(r, state.seed);

    final home = await _clubs.clubById(f.homeClubId);
    if (home != null && f.homeClubId == clubId) {
      await _addTicketRevenue(home);
    }

    final goalsFor = f.homeClubId == clubId ? r.homeGoals : r.awayGoals;
    final goalsAgainst = f.homeClubId == clubId ? r.awayGoals : r.homeGoals;
    final delta =
        goalsFor > goalsAgainst
            ? 4
            : goalsFor == goalsAgainst
            ? 0
            : -4;
    await _applyMorale(clubId, delta);

    final ours = await _outcome(
      Fixture(
        id: f.id,
        leagueId: f.leagueId,
        round: f.round,
        date: f.date,
        homeClubId: f.homeClubId,
        awayClubId: f.awayClubId,
        homeGoals: r.homeGoals,
        awayGoals: r.awayGoals,
      ),
    );

    final st = r.stats;
    final scorers = [
      if (r.homeScorerNames.isNotEmpty)
        '${ours.homeName}: ${r.homeScorerNames.join(', ')}',
      if (r.awayScorerNames.isNotEmpty)
        '${ours.awayName}: ${r.awayScorerNames.join(', ')}',
    ];
    await _inbox.add(
      InboxMessage(
        id: 0,
        date: state.currentDate,
        category: InboxCategory.match,
        title:
            'Hasil: ${ours.homeName} ${ours.homeGoals}-${ours.awayGoals} ${ours.awayName}',
        body:
            '${scorers.isEmpty ? 'Tanpa gol.' : scorers.join('. ')}. '
            'Penguasaan bola ${st.homePossession}%-${st.awayPossession}%. '
            'Tembakan ${st.home.shots}-${st.away.shots} '
            '(tepat sasaran ${st.home.onTarget}-${st.away.onTarget}). '
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

  /// Simulasi cepat sampai peluit akhir, lalu disimpan. Dipakai bila laga
  /// tidak perlu ditonton (mis. tes). Hasilnya sama dengan laga 2D tanpa
  /// intervensi pemain.
  Future<MatchDayResult> playMatchDay() async {
    final setup = await prepareMatch();
    final session = MatchSession(
      seed: setup.seed,
      fixtureId: setup.fixture.id,
      home: setup.home,
      away: setup.away,
    );
    while (!session.finished) {
      session.step();
    }
    return commitMatch(
      session.result(fixtureId: setup.fixture.id),
    );
  }

  /// Kondisi pemain berkurang sesuai menit bermain (starter penuh 12–22).
  Future<void> _applyMatchLoad(MatchResultData r, int seed) async {
    for (final entry in r.minutesPlayed.entries) {
      final p = await _players.byId(entry.key);
      if (p == null) continue;
      final full = QuickMatchSimulator.conditionLoss(
        seed,
        r.fixtureId,
        entry.key,
      );
      final loss = (full * entry.value / r.matchMinutes).round();
      await (_db.update(_db.players)..where((t) => t.id.equals(p.id))).write(
        PlayersCompanion(condition: Value(math.max(0, p.condition - loss))),
      );
    }
  }

  /// Menyimpan taktik klub kita.
  Future<void> saveTactics(ClubTactic t) => _tactics.save(t);

  Future<ClubTactic?> tactics(String clubId) => _tactics.load(clubId);

  /// Tawaran transfer untuk layanan UI (ajukan, daftar jual, shortlist).
  Future<void> placeBid(
    int playerId,
    int fee, {
    int installmentYears = 1,
    int sellOnPct = 0,
  }) async {
    final state = await _ourState();
    await _transfers.placeBid(
      ourClubId: state.clubId!,
      now: state.currentDate,
      playerId: playerId,
      fee: fee,
      seed: state.seed,
      installmentYears: installmentYears,
      sellOnPct: sellOnPct,
    );
  }

  /// Harga minta untuk klub kita, gaji yang diharapkan, dan alasan bila
  /// pemain tidak bisa ditawar saat ini.
  Future<TransferQuote> transferQuote(int playerId) async {
    final state = await _ourState();
    return _transfers.quote(
      playerId: playerId,
      ourClubId: state.clubId!,
      now: state.currentDate,
      seed: state.seed,
    );
  }

  /// Menjawab negosiasi (kontra, tawaran final, kontrak, tawaran masuk).
  /// Pesan inbox yang terkait ikut diselesaikan, sehingga hasilnya sama
  /// baik dijawab dari Inbox maupun dari tab Negosiasi.
  Future<void> respondToOffer(int offerId, String choice) async {
    for (final m in await _inbox.pendingActions()) {
      final head = m.payload?.split('|').first;
      if (head == 'offer:$offerId') {
        await resolveMessage(m, choice);
        return;
      }
    }
    final state = await _ourState();
    await _transfers.respond(
      offerId: offerId,
      choice: choice,
      date: state.currentDate,
      ourClubId: state.clubId!,
    );
  }

  // --- Ruang Negosiasi ----------------------------------------------------------

  /// Membuka (atau melanjutkan) Ruang Negosiasi untuk satu tawaran.
  Future<NegotiationRoom> openNegotiation(int offerId) async {
    final state = await _ourState();
    return _transfers.openNegotiation(
      offerId: offerId,
      ourClubId: state.clubId!,
      date: state.currentDate,
      seed: state.seed,
    );
  }

  /// Mengajukan satu tawaran ke agen.
  Future<NegotiationStep> negotiate(int offerId, NegotiationOffer offer) =>
      _negotiationStep(
        offerId,
        (s) => _transfers.submitNegotiationOffer(
          offerId: offerId,
          offer: offer,
          ourClubId: s.clubId!,
          date: s.currentDate,
          seed: s.seed,
        ),
      );

  /// Menerima patokan agen dengan syarat [terms].
  Future<NegotiationStep> acceptAgentTerms(
    int offerId,
    NegotiationOffer terms,
  ) => _negotiationStep(
    offerId,
    (s) => _transfers.acceptAgentTerms(
      offerId: offerId,
      terms: terms,
      ourClubId: s.clubId!,
      date: s.currentDate,
      seed: s.seed,
    ),
  );

  /// Pesan inbox negosiasi baru diselesaikan saat sesinya berakhir (sepakat
  /// atau walk-out), bukan pada tawaran pertama, supaya Inbox tetap bisa
  /// membawa user kembali ke Ruang Negosiasi. Pesan dikumpulkan sebelum
  /// langkah dijalankan agar pesan kontrak yang baru dibuat tidak ikut
  /// diselesaikan.
  Future<NegotiationStep> _negotiationStep(
    int offerId,
    Future<NegotiationStep> Function(GameState s) run,
  ) async {
    final state = await _ourState();
    final messages = [
      for (final m in await _inbox.pendingActions())
        if (m.payload?.split('|').first == 'offer:$offerId') m,
    ];
    final step = await run(state);
    if (step.finished) {
      final choice = step.verdict == AgentVerdict.accept ? 'agreed' : 'walkOut';
      for (final m in messages) {
        await _inbox.resolve(m.id, choice);
      }
    }
    return step;
  }

  Future<List<PlayerInterest>> interestsFor(int playerId) =>
      _transfers.interestsFor(playerId);

  Future<List<TransferNewsItem>> transferNews({int limit = 100}) =>
      TransferRepository(_db).recentNews(limit: limit);

  Future<GameState> _ourState() async {
    final state = await _states.load();
    if (state == null || state.clubId == null) {
      throw StateError('Belum ada klub.');
    }
    return state;
  }

  Future<void> setListed(int playerId, bool listed) =>
      _transfers.setListed(playerId, listed);

  Future<void> setShortlisted(int playerId, bool value) async {
    final state = await _states.load();
    await _transfers.setShortlisted(
      playerId,
      value,
      state?.currentDate ?? WorldGenerator.seasonStart,
    );
  }

  // --- Inbox -----------------------------------------------------------------

  Future<void> resolveMessage(InboxMessage m, String choice) async {
    if (m.actionType == InboxActionType.incomingTransferOffer ||
        m.actionType == InboxActionType.counterOffer ||
        m.actionType == InboxActionType.contractNegotiation) {
      final state = await _states.load();
      await _transfers.resolveAction(
        message: m,
        choice: choice,
        date: state!.currentDate,
        ourClubId: state.clubId!,
        seed: state.seed,
      );
      await _inbox.resolve(m.id, choice);
      return;
    }
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

  static String _money(int thousands) => moneyLabel(thousands);
}
