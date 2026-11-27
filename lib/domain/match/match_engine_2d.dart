import 'dart:math' as math;

import '../../core/rng/seeded_random.dart';
import '../../l10n/l10n.dart';
import '../enums/attribute.dart';
import '../enums/tactics.dart';
import '../models/game_models.dart';
import '../models/match_models.dart';
import '../season/quick_match_simulator.dart';
import 'lineup_builder.dart';
import 'match_rules.dart';

/// Susunan satu tim sebelum laga: 11 starter berurutan sesuai slot formasi
/// dan bangku cadangan.
class MatchTeamSetup {
  const MatchTeamSetup({
    required this.clubId,
    required this.name,
    required this.formation,
    required this.mentality,
    required this.starters,
    required this.bench,
  });

  final String clubId;
  final String name;
  final Formation formation;
  final Mentality mentality;
  final List<Player> starters; // 11, urut slot formasi
  final List<Player> bench;
}

/// Simulasi laga 2D yang berjalan menit demi menit. Deterministik untuk
/// (seed, fixtureId) dan urutan keputusan pemain yang sama.
///
/// Pemakaian: panggil [step] berulang kali untuk memajukan satu menit,
/// [setMentality] dan [substitute] boleh dipanggil di antara menit.
class MatchSession {
  MatchSession({
    required int seed,
    required int fixtureId,
    required this.home,
    required this.away,
  }) : _rng = SeededRandom(QuickMatchSimulator.matchSeed(seed, fixtureId)),
       _mentality = [home.mentality, away.mentality] {
    for (var i = 0; i < 11; i++) {
      _pitch.add(_Slot.fromPlayer(home.starters[i], true, i, home.formation));
    }
    for (var i = 0; i < 11; i++) {
      _pitch.add(_Slot.fromPlayer(away.starters[i], false, i, away.formation));
    }
    _benchLeft = [
      home.bench.map((p) => p.id).toList(),
      away.bench.map((p) => p.id).toList(),
    ];
    _ballX = 0.5;
    _ballY = 0.5;
    _carrier = 6; // gelandang tengah tim kandang memulai
    _emitAt(0, MatchEventType.kickOff, tr('ev.kickOff'));
  }

  static const int fullMinutes = 90;
  static const int maxSubs = MatchRules.maxSubstitutions;
  static const int _halfTicks = 45 * ticksPerMinute;

  final MatchTeamSetup home;
  final MatchTeamSetup away;
  final SeededRandom _rng;
  final List<Mentality> _mentality; // [home, away]
  final List<_Slot> _pitch = [];
  late final List<List<int>> _benchLeft;
  final List<int> _subsUsed = [0, 0];
  final Map<int, int> _minutesPlayed = {};
  final Map<int, int> _yellows = {};
  final List<MatchEvent> _events = [];
  final List<String> _homeScorers = [];
  final List<String> _awayScorers = [];
  final List<_Counters> _counters = [_Counters(), _Counters()];
  int _homeGoals = 0;
  int _awayGoals = 0;
  int _minute = 0;
  int _tick = 0;
  int _minuteActions = 1;
  double _actionBudget = 0;
  int _carrier = 0;
  int? _lastPasser;
  double _ballX = 0.5;
  double _ballY = 0.5;
  List<MatchEvent> _minuteEvents = [];
  final List<BallWaypoint> _ballPath = [];

  /// Fase serangan tiap tim (+1 menyerang, -1 bertahan), dihaluskan per menit
  /// agar garis tim bergeser perlahan dan tidak bolak-balik setiap operan.
  final List<double> _phase = [0, 0];

  /// Posisi acuan tiap pemain yang dihaluskan antar menit (inersia gerak).
  static const double _refSmoothing = 0.068; // per tick (~0.35 per menit)
  final List<double> _refX = List.filled(22, 0.5);
  final List<double> _refY = List.filled(22, 0.5);
  bool _refReady = false;

  /// Peran tiap pemain pada menit sebelumnya (untuk histeresis peran).
  List<_Role> _lastRole = List.filled(22, _Role.none);
  bool _inStep = false;

  // Aturan: babak, waktu tambahan, dan kesempatan pergantian.
  bool _finished = false;
  int? _halfTimeTick; // tick saat babak pertama berakhir (null = belum)
  bool _halfTimeBreak = false; // jeda babak aktif (pergantian bebas)
  final List<int> _extraTicks = [0, 0]; // waktu tambahan per babak
  final List<bool> _advantageGiven = [false, false];
  final List<int> _windowsUsed = [0, 0];
  int _windowOwner = -1; // sisi yang sedang membuka kesempatan pergantian
  double? _offsideX; // garis offside pada tick ini (untuk tampilan)

  int get minute => _minute;
  bool get finished => _finished;

  /// Jeda babak pertama: pertandingan berhenti sebentar, pergantian bebas.
  bool get isHalfTimeBreak => _halfTimeBreak;

  /// Kesempatan berhenti yang sudah dipakai tim (tidak termasuk jeda babak).
  int windowsUsed(bool isHome) => _windowsUsed[isHome ? 0 : 1];

  /// Penanda waktu untuk tampilan, mis. "45+2'" atau "90+1'".
  String get clockText {
    final (minute, extra) = _clockLabel();
    return extra > 0 ? "$minute+$extra'" : "$minute'";
  }

  int get homeGoals => _homeGoals;
  int get awayGoals => _awayGoals;
  List<MatchEvent> get events => List.unmodifiable(_events);
  MatchStats get stats =>
      MatchStats(home: _counters[0].freeze(), away: _counters[1].freeze());
  int subsUsed(bool isHome) => _subsUsed[isHome ? 0 : 1];
  int subsLeft(bool isHome) => maxSubs - subsUsed(isHome);
  Mentality mentality(bool isHome) => _mentality[isHome ? 0 : 1];

  /// Pemain yang sedang di lapangan (tanpa yang diusir).
  List<Player> onPitch(bool isHome) => [
    for (final s in _pitch)
      if (s.isHome == isHome && s.active) s.player,
  ];

  /// Bangku cadangan yang belum dipakai.
  List<Player> benchPlayers(bool isHome) {
    final ids = _benchLeft[isHome ? 0 : 1];
    final source = isHome ? home.bench : away.bench;
    return [
      for (final p in source)
        if (ids.contains(p.id)) p,
    ];
  }

  /// Posisi terkini semua pemain di lapangan (untuk tampilan awal).
  List<PlayerDot> currentDots() => [
    for (var i = 0; i < _pitch.length; i++)
      if (_pitch[i].active)
        PlayerDot(
          index: i,
          playerId: _pitch[i].player.id,
          isHome: _pitch[i].isHome,
          shirt: _pitch[i].shirt,
          x: _pitch[i].x,
          y: _pitch[i].y,
        ),
  ];

  /// Indeks pemain yang sedang menguasai bola (untuk sorotan di tampilan).
  int get carrierIndex => _carrier;
  double get ballX => _ballX;
  double get ballY => _ballY;

  // --- Intervensi pemain -----------------------------------------------------

  void setMentality(bool isHome, Mentality value) {
    _mentality[isHome ? 0 : 1] = value;
    _emit(
      MatchEventType.mentality,
      tr('ev.mentality', {
        'team': isHome ? home.name : away.name,
        'mentality': value.label,
      }),
      isHome: isHome,
    );
  }

  /// Membuka kesempatan berhenti untuk pergantian. Setiap tim punya
  /// [MatchRules.maxSubWindows] kesempatan; jeda babak tidak memakai kuota.
  void openSubWindow(bool isHome) {
    if (finished) throw StateError(tr('err.matchFinished'));
    final side = isHome ? 0 : 1;
    if (_windowOwner == side) return;
    if (!_halfTimeBreak) {
      if (_windowsUsed[side] >= MatchRules.maxSubWindows) {
        throw StateError(
          tr('err.subWindowsUsed', {'n': MatchRules.maxSubWindows}),
        );
      }
      _windowsUsed[side]++;
    }
    _windowOwner = side;
  }

  /// Menutup kesempatan pergantian. Pertandingan lanjut.
  void closeSubWindow() => _windowOwner = -1;

  /// Pergantian pemain: [outId] keluar dari lapangan, [inId] dari bangku.
  /// Hanya bisa dilakukan saat kesempatan pergantian terbuka atau jeda babak.
  void substitute(bool isHome, int outId, int inId) {
    final side = isHome ? 0 : 1;
    if (finished) throw StateError(tr('err.matchFinished'));
    if (_windowOwner != side && !_halfTimeBreak) {
      throw StateError(tr('err.openSubWindow'));
    }
    if (_subsUsed[side] >= maxSubs) {
      throw StateError(tr('err.subsUsed', {'n': maxSubs}));
    }
    final idx = _pitch.indexWhere(
      (s) => s.isHome == isHome && s.active && s.player.id == outId,
    );
    if (idx < 0) throw StateError(tr('err.subOutNotOnPitch'));
    final bench = _benchLeft[side];
    if (!bench.contains(inId)) {
      throw StateError(tr('err.subInNotOnBench'));
    }
    final incoming = benchPlayers(isHome).firstWhere((p) => p.id == inId);

    final out = _pitch[idx];
    _closeMinutes(out);
    final replacement =
        _Slot.fromPlayer(
            incoming,
            isHome,
            out.slotIndex,
            isHome ? home.formation : away.formation,
          )
          ..x = out.x
          ..y = out.y
          ..since = _minute;
    _pitch[idx] = replacement;
    bench.remove(inId);
    _subsUsed[side]++;
    if (!_halfTimeBreak) _addStoppage(MatchRules.stoppageTicksPerSubstitution);

    _emit(
      MatchEventType.substitution,
      tr('ev.substitution', {
        'team': isHome ? home.name : away.name,
        'in': incoming.lastName,
        'out': out.player.lastName,
      }),
      isHome: isHome,
      playerId: inId,
      assistId: outId,
    );
  }

  // --- Simulasi --------------------------------------------------------------

  /// Jumlah tick simulasi per menit permainan. Tick adalah langkah logika
  /// tetap; tampilan dan jam permainan tidak terikat pada tick ini.
  static const int ticksPerMinute = 6;
  static const int totalTicks = fullMinutes * ticksPerMinute;

  /// Jumlah tick yang sudah diselesaikan (0 sampai [totalTicks]).
  int get tick => _tick;

  /// Memajukan satu tick simulasi (1/6 menit) dan mengembalikan frame-nya.
  TickFrame stepTick() {
    if (finished) throw StateError(tr('err.matchFinished'));
    final from = currentDots();
    final fromBallX = _ballX;
    final fromBallY = _ballY;
    _minuteEvents = [];
    _offsideX = null;
    _halfTimeBreak = false;
    _ballPath
      ..clear()
      ..add(BallWaypoint(fromBallX, fromBallY));

    // Jumlah aksi per menit diundi sekali di awal menit (urutan acak tetap).
    if (_tick % ticksPerMinute == 0) {
      final carrierHome = _carrier < 11;
      final bias = _mentality[carrierHome ? 0 : 1].attackBias;
      _minuteActions = math.min(
        4,
        math.max(1, (1 + _rng.nextDouble() * 2.4 * bias).round()),
      );
    }

    // Aksi dibagi rata ke setiap tick dalam menit.
    _inStep = true;
    _actionBudget += _minuteActions / ticksPerMinute;
    while (_actionBudget >= 1) {
      _actionBudget -= 1;
      if (!_pitch[_carrier].active) {
        _carrier = _nearestActive(_carrier < 11, _ballX, _ballY);
      }
      _runAction();
    }

    _ballX = _pitch[_carrier].x;
    _ballY = _pitch[_carrier].y;
    _moveAll();
    _tick++;
    _minute = _tick ~/ ticksPerMinute;
    _checkPeriodEnds();
    _inStep = false;
    return TickFrame(
      tick: _tick,
      minute: (_tick - 1) ~/ ticksPerMinute + 1,
      from: from,
      to: currentDots(),
      ballFromX: fromBallX,
      ballFromY: fromBallY,
      ballToX: _ballX,
      ballToY: _ballY,
      ballPath: List.unmodifiable(_ballPath),
      carrierIndex: _carrier,
      events: List.unmodifiable(_minuteEvents),
      offsideX: _offsideX,
    );
  }

  /// Memajukan satu menit penuh (beberapa tick) dan menggabungkan frame-nya.
  MinuteFrame step() {
    final frames = <TickFrame>[];
    for (var i = 0; i < ticksPerMinute && !finished; i++) {
      frames.add(stepTick());
    }
    final path = <BallWaypoint>[];
    for (var i = 0; i < frames.length; i++) {
      // Titik awal tiap tick sama dengan titik akhir tick sebelumnya.
      path.addAll(frames[i].ballPath.skip(i == 0 ? 0 : 1));
    }
    return MinuteFrame(
      minute: frames.first.minute,
      from: frames.first.from,
      to: frames.last.to,
      ballFromX: frames.first.ballFromX,
      ballFromY: frames.first.ballFromY,
      ballToX: frames.last.ballToX,
      ballToY: frames.last.ballToY,
      ballPath: List.unmodifiable(path),
      carrierIndex: frames.last.carrierIndex,
      events: [for (final f in frames) ...f.events],
    );
  }

  /// Hasil akhir untuk disimpan. Hanya valid setelah [finished].
  MatchResultData result({required int fixtureId}) {
    if (!finished) throw StateError(tr('err.matchNotFinished'));
    final endMinute = _tick ~/ ticksPerMinute;
    final minutes = Map<int, int>.from(_minutesPlayed);
    for (final s in _pitch) {
      if (s.active) {
        minutes[s.player.id] =
            (minutes[s.player.id] ?? 0) + endMinute - s.since;
      }
    }
    return MatchResultData(
      fixtureId: fixtureId,
      homeClubId: home.clubId,
      awayClubId: away.clubId,
      homeGoals: _homeGoals,
      awayGoals: _awayGoals,
      events: List.unmodifiable(_events),
      stats: MatchStats(
        home: _counters[0].freeze(),
        away: _counters[1].freeze(),
      ),
      minutesPlayed: minutes,
      homeScorerNames: List.unmodifiable(_homeScorers),
      awayScorerNames: List.unmodifiable(_awayScorers),
      matchMinutes: endMinute,
    );
  }

  // --- Aksi bola -------------------------------------------------------------

  /// Satu aksi (umpan/dribel/tembakan/...). Hanya mencatat lintasan bola untuk
  /// animasi; tidak mengubah state atau urutan angka acak.
  void _runAction() {
    _recordBall(_pitch[_carrier].x, _pitch[_carrier].y, owner: _carrier);
    _doAction();
    _recordBall(_pitch[_carrier].x, _pitch[_carrier].y, owner: _carrier);
  }

  void _recordBall(double x, double y, {int owner = -1}) {
    if (!_inStep) return;
    final last = _ballPath.last;
    if (last.x == x && last.y == y && last.owner == owner) return;
    _ballPath.add(BallWaypoint(x, y, owner: owner));
  }

  /// Sentuhan-sentuhan kecil saat menggiring: bola bergoyang ringan di kiri
  /// dan kanan jalur pemain, lalu berhenti tepat di posisi pemain.
  void _recordDribble(int c, double x0, double y0, double x1, double y1) {
    const touches = 3;
    for (var k = 1; k <= touches; k++) {
      final t = k / touches;
      final wobble = k == touches ? 0.0 : (k.isOdd ? 0.006 : -0.006);
      _recordBall(
        x0 + (x1 - x0) * t,
        _clamp(y0 + (y1 - y0) * t + wobble, 0.02, 0.98),
        owner: c,
      );
    }
  }

  /// Umpan melengkung ringan (lintasan visual; tidak mengubah state).
  void _recordPass(int from, double x1, double y1) {
    final x0 = _pitch[from].x;
    final y0 = _pitch[from].y;
    final dx = x1 - x0;
    final dy = y1 - y0;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-6) return;
    final px = -dy / len;
    final py = dx / len;
    final bulge = math.min(0.02, len * 0.12);
    for (var k = 1; k <= 3; k++) {
      final t = k / 4;
      final lift = math.sin(math.pi * t) * bulge;
      _recordBall(x0 + dx * t + px * lift, y0 + dy * t + py * lift, owner: -1);
    }
  }

  void _doAction() {
    final c = _carrier;
    final s = _pitch[c];
    final home = s.isHome;
    _counters[home ? 0 : 1].possessionActions++;
    _ballX = s.x;
    _ballY = s.y;

    final goalX = home ? 1.0 : 0.0;
    final dist = (goalX - s.x).abs();
    final inBox = dist <= 0.17 && s.y > 0.2 && s.y < 0.8;
    final inFinal = dist <= 0.34;
    final pressure = _pressure(c);

    final bias = _mentality[home ? 0 : 1].attackBias;
    if (inBox && _rng.chance(0.65 * bias)) {
      _shot(c);
      return;
    }
    if (inFinal && _rng.chance(0.2 * bias)) {
      _shot(c);
      return;
    }
    final wide = (s.y - 0.5).abs() > 0.28;
    // Di kotak penalti, pembawa bola sering mencoba melewati bek (dribel),
    // sehingga tantangan dan penalti juga mungkin terjadi.
    if (inBox && _rng.chance(0.3)) {
      _dribble(c, pressure);
      return;
    }
    if (inFinal && wide && _rng.chance(0.3)) {
      _cross(c, pressure);
      return;
    }
    if (_rng.chance(0.16)) {
      _dribble(c, pressure);
      return;
    }
    _pass(c, pressure);
  }

  void _pass(int c, double pressure) {
    final mates = _teammates(c);
    if (mates.isEmpty) {
      _turnover(c);
      return;
    }
    final s = _pitch[c];
    final dir = s.isHome ? 1.0 : -1.0;
    final weights = [
      for (final j in mates)
        math.max(0.05, 0.6 + (_pitch[j].x - s.x) * dir * 4) * (0.5 + _skill(j)),
    ];
    final j = _weightedPick(mates, weights);

    final passing = _norm(s.player, Attribute.passing, Attribute.vision);
    final success = _clamp(
      0.7 + 0.3 * (passing - 0.5) + (_skill(c) - pressure) * 0.6,
      0.35,
      0.97,
    );
    if (_rng.chance(success)) {
      final line = _offsideLine(c, j);
      if (line != null) {
        _offside(j, line);
        return;
      }
      _lastPasser = c;
      _recordPass(c, _pitch[j].x, _pitch[j].y);
      if (_rng.chance(0.12) && (_pitch[j].x - s.x) * dir > 0.12) {
        _emitChance(
          s.isHome,
          tr('ev.throughBall', {
            'from': s.player.lastName,
            'to': _pitch[j].player.lastName,
          }),
          s.player.id,
        );
      }
      _carrier = j;
      _ballX = _pitch[j].x;
      _ballY = _pitch[j].y;
    } else {
      _turnover(c);
    }
  }

  void _cross(int c, double pressure) {
    final s = _pitch[c];
    final home = s.isHome;
    final targets = _teammates(c)
      ..retainWhere((j) => (_pitch[j].x - (home ? 1.0 : 0.0)).abs() < 0.3);
    if (targets.isEmpty) {
      _pass(c, pressure);
      return;
    }
    targets.sort(
      (a, b) => _pitch[b].player.attributes[Attribute.heading].compareTo(
        _pitch[a].player.attributes[Attribute.heading],
      ),
    );
    final j = targets[_rng.nextInt(math.min(3, targets.length))];
    final crossing = _norm(s.player, Attribute.crossing, Attribute.passing);
    final success = _clamp(0.3 + crossing * 0.4 - pressure * 0.5, 0.1, 0.7);
    if (_rng.chance(success)) {
      final line = _offsideLine(c, j);
      if (line != null) {
        _offside(j, line);
        return;
      }
      _lastPasser = c;
      _recordPass(c, _pitch[j].x, _pitch[j].y);
      _emitChance(
        home,
        tr('ev.cross', {
          'from': s.player.lastName,
          'to': _pitch[j].player.lastName,
        }),
        s.player.id,
      );
      _carrier = j;
      _ballX = _pitch[j].x;
      _ballY = _pitch[j].y;
    } else {
      _turnover(c);
    }
  }

  void _dribble(int c, double pressure) {
    final s = _pitch[c];
    final dribble = _norm(s.player, Attribute.dribbling, Attribute.pace);
    final success = _clamp(0.45 + 0.4 * (dribble - pressure), 0.2, 0.9);
    if (_rng.chance(success)) {
      final dir = s.isHome ? 1.0 : -1.0;
      final x0 = s.x;
      final y0 = s.y;
      s.x = _clamp(s.x + dir * (0.05 + _rng.nextDouble() * 0.04), 0.02, 0.98);
      _recordDribble(c, x0, y0, s.x, s.y);
      _ballX = s.x;
      _ballY = s.y;
    } else if (_inBoxFor(c) && _opponents(c).isNotEmpty) {
      // Dribel gagal di kotak: bek menjatuhkan penyerang (penalti), atau
      // penyerang yang menjatuhkan diri (diving).
      if (_rng.chance(0.35)) {
        _foul(_nearest(_opponents(c), s.x, s.y), c);
      } else if (_rng.chance(MatchRules.diveChance)) {
        _dive(c);
      } else {
        _turnover(c);
      }
    } else {
      _turnover(c);
    }
  }

  void _shot(int c) {
    final s = _pitch[c];
    final home = s.isHome;
    _counters[home ? 0 : 1].shots++;
    // Lintasan visual: bola melesat ke garis gawang lawan.
    _recordBall(home ? 1.0 : 0.0, _clamp(s.y, 0.42, 0.58));

    final fin = s.player.attributes[Attribute.finishing] / 20;
    final comp = s.player.attributes[Attribute.composure] / 20;
    final gkIdx = _keeperIndex(!home);
    final gk = _pitch[gkIdx];
    final gkRate = _norm(gk.player, Attribute.reflexes, Attribute.handling);

    final onTargetP = _clamp(0.38 + 0.28 * fin + 0.1 * comp, 0.2, 0.85);
    if (!_rng.chance(onTargetP)) {
      _emit(
        MatchEventType.shotOff,
        tr(_pick(_missKeys), {'p': s.player.lastName}),
        isHome: home,
        playerId: s.player.id,
      );
      _carrier = gkIdx;
      return;
    }

    _counters[home ? 0 : 1].onTarget++;

    // Bola membentur mistar/tiang: Goal-Line Technology memastikan apakah
    // bola sudah melewati garis gawang sepenuhnya.
    if (_rng.chance(MatchRules.postHitChance)) {
      _emit(
        MatchEventType.shotOff,
        tr('ev.hitBar', {'p': s.player.lastName}),
        isHome: home,
        playerId: s.player.id,
      );
      final crossed = _rng.chance(0.5);
      _emit(
        MatchEventType.goalLineTech,
        crossed ? tr('ev.gltGoal') : tr('ev.gltNoGoal'),
        isHome: home,
      );
      if (crossed) {
        _goal(c);
      } else {
        _save(c, gkIdx, tr('ev.reboundCaught', {'gk': gk.player.lastName}));
      }
      return;
    }

    final goalP = _clamp(
      0.16 + 0.25 * fin + 0.1 * comp - 0.25 * gkRate,
      0.04,
      0.55,
    );
    if (_rng.chance(goalP)) {
      _goal(c);
    } else {
      _save(
        c,
        gkIdx,
        tr('ev.save', {'gk': gk.player.lastName, 'p': s.player.lastName}),
      );
    }
  }

  /// Gol untuk tim pemilik [c]. Kick-off dilakukan tim yang kebobolan.
  void _goal(int c) {
    final s = _pitch[c];
    final home = s.isHome;
    if (home) {
      _homeGoals++;
      _homeScorers.add(s.player.lastName);
    } else {
      _awayGoals++;
      _awayScorers.add(s.player.lastName);
    }
    final assistIdx = _lastPasser;
    final assistId =
        (assistIdx != null &&
                assistIdx != c &&
                _pitch[assistIdx].isHome == home)
            ? _pitch[assistIdx].player.id
            : null;
    _emit(
      MatchEventType.goal,
      assistId == null
          ? tr('ev.goal', {
            'p': s.player.fullName,
            'score': '$_homeGoals-$_awayGoals',
          })
          : tr('ev.goalAssist', {
            'p': s.player.fullName,
            'a': _nameOf(assistId),
            'score': '$_homeGoals-$_awayGoals',
          }),
      isHome: home,
      playerId: s.player.id,
      assistId: assistId,
    );
    _addStoppage(MatchRules.stoppageTicksPerGoal);
    _carrier = home ? 17 : 6;
    _lastPasser = null;
  }

  /// Tembakan ditepis oleh penjaga gawang [gkIdx]; bola dikuasai penjaga.
  void _save(int c, int gkIdx, String text) {
    final home = _pitch[c].isHome;
    final gk = _pitch[gkIdx];
    _counters[home ? 1 : 0].saves++;
    _emit(MatchEventType.save, text, isHome: !home, playerId: gk.player.id);
    _carrier = gkIdx;
    _lastPasser = null;
  }

  /// Penalti untuk tim [attacker]. VAR dapat meninjau keputusan ini.
  void _penalty(int attacker) {
    final a = _pitch[attacker];
    final home = a.isHome;
    if (!_varReview(tr('ev.varPenalty', {'p': a.player.lastName}))) return;

    _emit(
      MatchEventType.penalty,
      tr('ev.penalty', {'p': a.player.lastName}),
      isHome: home,
      playerId: a.player.id,
    );
    _counters[home ? 0 : 1].shots++;
    _counters[home ? 0 : 1].onTarget++;
    final gkIdx = _keeperIndex(!home);
    final gk = _pitch[gkIdx];
    final taker =
        (a.player.attributes[Attribute.finishing] +
            a.player.attributes[Attribute.composure] +
            a.player.attributes[Attribute.technique]) /
        60;
    final keeper = _norm(gk.player, Attribute.reflexes, Attribute.oneOnOnes);
    final goalP = _clamp(0.72 + 0.18 * taker - 0.15 * keeper, 0.55, 0.92);
    if (_rng.chance(goalP)) {
      _goal(attacker);
    } else {
      _save(attacker, gkIdx, tr('ev.penaltySaved', {'gk': gk.player.lastName}));
    }
  }

  /// Bola berpindah ke lawan terdekat. Kadang terjadi pelanggaran.
  void _turnover(int c) {
    final s = _pitch[c];
    final defenders = _opponents(c);
    if (defenders.isEmpty) return;
    // Pelanggaran lebih sering terjadi saat lawan merebut bola di kotak penalti.
    final foulChance = _inBoxFor(c) ? 0.3 : 0.07;
    if (_rng.chance(foulChance)) {
      final defender = _nearest(defenders, s.x, s.y);
      _foul(defender, c);
      return;
    }
    _carrier = _nearest(defenders, s.x, s.y);
    _lastPasser = null;
  }

  /// Pelanggaran oleh [defender] terhadap penyerang [attacker]. Di kotak
  /// penalti menjadi penalti; pada peluang emas juga kartu merah langsung.
  /// Di luar kotak, penguasa bola tetap (tendangan bebas).
  void _foul(int defender, int attacker) {
    final d = _pitch[defender];
    final home = d.isHome;
    _counters[home ? 0 : 1].fouls++;
    _emit(
      MatchEventType.foul,
      tr('ev.foul', {'p': d.player.lastName}),
      isHome: home,
      playerId: d.player.id,
    );

    final attackerGoalX = _pitch[attacker].isHome ? 1.0 : 0.0;
    final oneOnOne = (attackerGoalX - _pitch[attacker].x).abs() < 0.1;
    if (_inBoxFor(attacker) &&
        oneOnOne &&
        _rng.chance(MatchRules.dogsoChance)) {
      // DOGSO: menggagalkan peluang emas → kartu merah langsung + penalti.
      if (_varReview(tr('ev.varStraightRed', {'p': d.player.lastName}))) {
        _sendOff(defender, tr('ev.straightRed', {'p': d.player.lastName}));
      } else {
        _card(defender);
      }
      _penalty(attacker);
      return;
    }
    if (_inBoxFor(attacker)) {
      _penalty(attacker);
    }

    final yellowP = 0.18 + d.player.attributes[Attribute.aggression] / 50;
    if (!_rng.chance(yellowP)) return;
    _card(defender);
  }

  /// Kartu untuk pemain [idx]: kuning, atau merah bila sudah kuning.
  void _card(int idx) {
    final p = _pitch[idx];
    final home = p.isHome;
    final prior = _yellows[p.player.id] ?? 0;
    if (prior == 0) {
      _yellows[p.player.id] = 1;
      _counters[home ? 0 : 1].yellow++;
      _emit(
        MatchEventType.yellow,
        tr('ev.yellow', {'p': p.player.lastName}),
        isHome: home,
        playerId: p.player.id,
      );
      return;
    }
    if (!_varReview(tr('ev.varRed', {'p': p.player.lastName}))) return;
    _sendOff(idx, tr('ev.secondYellow', {'p': p.player.lastName}));
  }

  /// Mengeluarkan pemain [idx] dari lapangan.
  void _sendOff(int idx, String text) {
    final p = _pitch[idx];
    final home = p.isHome;
    _counters[home ? 0 : 1].red++;
    _emit(MatchEventType.red, text, isHome: home, playerId: p.player.id);
    _closeMinutes(p);
    p.active = false;
    if (_carrier == idx) {
      _carrier = _nearestActive(!home, p.x, p.y);
    }
  }

  /// Pemain menjatuhkan diri di kotak penalti: kartu kuning untuk pelakunya
  /// dan bola diberikan ke lawan (tanpa penalti).
  void _dive(int c) {
    final s = _pitch[c];
    _emit(
      MatchEventType.dive,
      tr('ev.dive', {'p': s.player.lastName}),
      isHome: s.isHome,
      playerId: s.player.id,
    );
    final defenders = _opponents(c);
    _card(c);
    if (defenders.isNotEmpty) {
      _carrier = _nearest(defenders, s.x, s.y);
      _lastPasser = null;
    }
  }

  /// Offside saat umpan dilepaskan dari [c] ke penerima [j]. Garis offside
  /// adalah pemain bertahan kedua terakhir. Null bila onside.
  double? _offsideLine(int c, int j) {
    final s = _pitch[c];
    final dirA = s.isHome ? 1.0 : -1.0;
    final recv = _pitch[j];
    // Pemain bertahan lawan, diurutkan dari yang terdekat gawangnya sendiri.
    final defenderX = [
      for (var k = 0; k < _pitch.length; k++)
        if (_pitch[k].active && _pitch[k].isHome != s.isHome) _pitch[k].x,
    ]..sort((a, b) => (b * dirA).compareTo(a * dirA));
    if (defenderX.isEmpty) return null;
    final line = defenderX.length > 1 ? defenderX[1] : defenderX[0];
    final beyondLine = (recv.x - line) * dirA > 0;
    final beyondBall = (recv.x - s.x) * dirA > 0;
    final inOpponentHalf = (recv.x - 0.5) * dirA > 0;
    return beyondLine && beyondBall && inOpponentHalf ? line : null;
  }

  /// Penerima umpan berada offside: tendangan bebas tidak langsung untuk
  /// tim bertahan, dan garis offside ditampilkan pada tick ini.
  void _offside(int j, double line) {
    final recv = _pitch[j];
    _emit(
      MatchEventType.offside,
      tr('ev.offside', {'p': recv.player.lastName}),
      isHome: recv.isHome,
      playerId: recv.player.id,
    );
    _offsideX = line;
    final defenders = _opponents(j);
    if (defenders.isNotEmpty) {
      _carrier = _nearest(defenders, recv.x, recv.y);
    }
    _lastPasser = null;
  }

  /// Peninjauan VAR untuk penalti atau kartu merah. Mengembalikan true bila
  /// keputusan wasit dipertahankan (atau tidak ditinjau sama sekali).
  bool _varReview(String subject) {
    if (!_rng.chance(MatchRules.varReviewChance)) return true;
    _emit(MatchEventType.varReview, tr('ev.varReview', {'subject': subject}));
    _addStoppage(MatchRules.stoppageTicksPerVarReview);
    final overturned = _rng.chance(MatchRules.varOverturnChance);
    _emit(
      MatchEventType.varResult,
      overturned ? tr('ev.varOverturned') : tr('ev.varStands'),
    );
    return !overturned;
  }

  bool _inBoxFor(int c) {
    final s = _pitch[c];
    final goalX = s.isHome ? 1.0 : 0.0;
    return (goalX - s.x).abs() <= 0.17 && s.y > 0.2 && s.y < 0.8;
  }

  // --- Waktu tambahan & babak -------------------------------------------------

  /// Menambah waktu tambahan pada babak yang sedang berjalan.
  void _addStoppage(int ticks) {
    _extraTicks[_halfTimeTick == null ? 0 : 1] += ticks;
  }

  /// Label menit untuk tick saat ini: (menit, menit tambahan).
  (int, int) _clockLabel() {
    final t = _tick;
    final h = _halfTimeTick;
    if (h == null) {
      if (t < _halfTicks) return (t ~/ ticksPerMinute + 1, 0);
      return (45, (t - _halfTicks) ~/ ticksPerMinute + 1);
    }
    final s = t - h;
    if (s < _halfTicks) return (46 + s ~/ ticksPerMinute, 0);
    return (90, (s - _halfTicks) ~/ ticksPerMinute + 1);
  }

  /// Mengatur akhir babak. Jika waktu tambahan habis, babak pertama berakhir
  /// dengan jeda; babak kedua berakhir dengan peluit akhir.
  void _checkPeriodEnds() {
    if (_halfTimeTick == null) {
      if (_tick < _halfTicks + _extraTicks[0]) return;
      if (_advantageAvailable(0)) return;
      _halfTimeTick = _tick;
      _halfTimeBreak = true;
      _emitAt(
        45,
        MatchEventType.halfTime,
        tr('ev.halfTime', {'score': '$_homeGoals-$_awayGoals'}),
        extra: (_extraTicks[0] + ticksPerMinute - 1) ~/ ticksPerMinute,
      );
      return;
    }
    if (_tick < _halfTimeTick! + _halfTicks + _extraTicks[1]) return;
    if (_advantageAvailable(1)) return;
    _finished = true;
    _emitAt(
      fullMinutes,
      MatchEventType.fullTime,
      tr('ev.fullTime', {'score': '$_homeGoals-$_awayGoals'}),
      extra: (_extraTicks[1] + ticksPerMinute - 1) ~/ ticksPerMinute,
    );
  }

  /// Keunggulan: bila bola sedang di kotak penalti saat babak hendak
  /// berakhir, wasit menambah satu waktu singkat (sekali per babak).
  bool _advantageAvailable(int half) {
    if (_advantageGiven[half] || !_inBoxFor(_carrier)) return false;
    _advantageGiven[half] = true;
    _extraTicks[half] += MatchRules.advantageTicks;
    return true;
  }

  // --- Posisi ----------------------------------------------------------------

  static const double _maxTickMove = 0.017; // ~0.10 per menit
  static const double _maxRoleTickMove = 0.008; // ~0.05 per menit

  /// Posisi semua pemain untuk menit ini. Setiap pemain bergerak dari
  /// formasinya: garis naik saat tim menyerang, turun saat bertahan, bergeser
  /// ke sisi bola, lalu peran taktis (tekan, tutup ruang, dukung, lari ke
  /// ruang kosong). Tiap menit hanya bisa bergerak terbatas.
  void _moveAll() {
    final carrierHome = _carrier < 11;
    // Fase mengikuti posisi bola di lapangan (sisi mana yang menguasai area),
    // bukan siapa yang memegang bola saat ini. Dengan begitu garis tim tidak
    // ikut berbalik setiap kali bola berpindah tangan.
    for (final side in [0, 1]) {
      final dir = side == 0 ? 1.0 : -1.0;
      final field = math.max(-1.0, math.min(1.0, (_ballX - 0.5) * 2 * dir));
      final possession = (carrierHome == (side == 0)) ? 0.3 : -0.3;
      final target = math.max(-1.0, math.min(1.0, field + possession));
      _phase[side] += (target - _phase[side]) * 0.037;
    }
    final roles = _assignRoles();
    if (!_refReady) {
      for (var i = 0; i < _pitch.length; i++) {
        _refX[i] = _pitch[i].x;
        _refY[i] = _pitch[i].y;
      }
      _refReady = true;
    }

    for (var i = 0; i < _pitch.length; i++) {
      final s = _pitch[i];
      if (!s.active) continue;
      if (i == _carrier) {
        s.x = _ballX;
        s.y = _ballY;
        _refX[i] = _ballX;
        _refY[i] = _ballY;
        continue;
      }
      final side = s.isHome ? 0 : 1;
      final dir = s.isHome ? 1.0 : -1.0;
      final mentality = _mentality[side];
      final wideness = (s.baseY - 0.5).abs();
      final lateralShare = math.min(1.0, math.max(0.4, 1 - wideness * 1.2));

      // Bentuk dasar: garis tim ikut fase serangan dan sedikit ke sisi bola.
      var tx = s.baseX + dir * _phase[side] * (0.04 + mentality.pushShift);
      var ty = s.baseY + (_ballY - 0.5) * 0.3 * lateralShare;
      // Variasi kecil deterministik agar formasi tidak terlihat kaku.
      tx += math.sin(i * 12.9898) * 0.006;
      ty += math.cos(i * 78.233) * 0.006;

      final role = _roleTarget(i, roles[i]);
      if (role != null) {
        tx = role.x;
        ty = role.y;
      }
      // Posisi acuan dihaluskan dulu (inersia seperti pemain sungguhan), lalu
      // pemain mengejar acuan itu dengan batas gerak per menit.
      _refX[i] += (_clamp(tx, 0.03, 0.97) - _refX[i]) * _refSmoothing;
      _refY[i] += (_clamp(ty, 0.03, 0.97) - _refY[i]) * _refSmoothing;
      final cap = role != null ? _maxRoleTickMove : _maxTickMove;
      s.x = _approach(s.x, _refX[i], cap);
      s.y = _approach(s.y, _refY[i], cap);
    }
  }

  /// Peran taktis tiap pemain untuk satu menit, berdasarkan posisi bola.
  List<_Role> _assignRoles() {
    final roles = List.filled(_pitch.length, _Role.none);
    final ci = _carrier;
    final c = _pitch[ci];
    if (!c.active) return roles;
    final dirA = c.isHome ? 1.0 : -1.0;

    double dist(int j) {
      final dx = _pitch[j].x - c.x;
      final dy = _pitch[j].y - c.y;
      return dx * dx + dy * dy;
    }

    // Tekanan: dua pemain bertahan dari pembawa bola (bukan kiper). Peran
    // yang sudah dipegang tetap dipegang selama masih cukup dekat (histeresis),
    // supaya penekan tidak berganti setiap kali bola bergeser.
    final defenders = [
      for (var j = 0; j < _pitch.length; j++)
        if (_pitch[j].isHome != c.isHome && _pitch[j].active && !_isKeeper(j))
          j,
    ]..sort((a, b) => dist(a).compareTo(dist(b)));
    final presser = _keepOrPick(
      defenders,
      _Role.presser,
      roles,
      keepDist: 0.28,
      pickDist: 0.2,
      dist: dist,
    );
    if (presser != null) roles[presser] = _Role.presser;
    final cover = _keepOrPick(
      defenders.where((j) => j != presser).toList(),
      _Role.cover,
      roles,
      keepDist: 0.34,
      pickDist: 0.26,
      dist: dist,
    );
    if (cover != null) roles[cover] = _Role.cover;

    // Dukungan: rekan di depan bola yang paling dekat.
    final mates = [
      for (var j = 0; j < _pitch.length; j++)
        if (j != ci &&
            _pitch[j].isHome == c.isHome &&
            _pitch[j].active &&
            !_isKeeper(j))
          j,
    ];
    final ahead = [
      for (final j in mates)
        if ((_pitch[j].x - c.x) * dirA > 0.02) j,
    ]..sort((a, b) => dist(a).compareTo(dist(b)));
    final support = _keepOrPick(
      ahead,
      _Role.supportAhead,
      roles,
      keepDist: 0.4,
      pickDist: 1.0,
      dist: dist,
    );
    if (support != null) roles[support] = _Role.supportAhead;

    // Dukungan di sayap berlawanan sisi bola.
    final wide = [
      for (final j in mates)
        if (roles[j] == _Role.none && (_pitch[j].y - c.y).abs() > 0.25) j,
    ]..sort((a, b) => dist(a).compareTo(dist(b)));
    final wing = _keepOrPick(
      wide,
      _Role.supportWide,
      roles,
      keepDist: 0.5,
      pickDist: 1.0,
      dist: dist,
    );
    if (wing != null) roles[wing] = _Role.supportWide;

    // Penyerang lain selalu mencari ruang (lari), tanpa ambang yang berbalik.
    for (final j in mates) {
      if (roles[j] == _Role.none && _roleOf(j) == SlotRole.fwd) {
        roles[j] = _Role.runner;
      }
    }
    _lastRole = roles;
    return roles;
  }

  /// Pemain yang sudah memegang [role] di menit sebelumnya tetap dipilih bila
  /// masih dalam [keepDist]; jika tidak, pemain terdekat dalam [pickDist].
  int? _keepOrPick(
    List<int> candidates,
    _Role role,
    List<_Role> roles, {
    required double keepDist,
    required double pickDist,
    required double Function(int) dist,
  }) {
    for (final j in candidates) {
      if (roles[j] == _Role.none &&
          _lastRole[j] == role &&
          dist(j) < keepDist * keepDist) {
        return j;
      }
    }
    for (final j in candidates) {
      if (roles[j] == _Role.none && dist(j) < pickDist * pickDist) return j;
    }
    return null;
  }

  /// Titik tujuan untuk peran tertentu; null bila pemain mengikuti formasi.
  ({double x, double y})? _roleTarget(int i, _Role role) {
    if (role == _Role.none) return null;
    final s = _pitch[i];
    final c = _pitch[_carrier];
    final dirA = c.isHome ? 1.0 : -1.0;
    switch (role) {
      case _Role.presser:
        final dx = s.x - c.x;
        final dy = s.y - c.y;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d < 1e-6) return (x: c.x, y: c.y);
        return (x: c.x + dx / d * 0.035, y: c.y + dy / d * 0.035);
      case _Role.cover:
        // Di antara bola dan gawang sendiri, sedikit ke arah tengah.
        return (x: c.x - dirA * 0.09, y: 0.5 + (c.y - 0.5) * 0.5);
      case _Role.supportAhead:
        // Menawarkan opsi umpan di depan pembawa bola, menjauh dari garis.
        return (x: c.x + dirA * 0.13, y: 0.5 + (c.y - 0.5) * 0.4);
      case _Role.supportWide:
        // Sayap berlawanan sisi bola: membuka lapangan.
        return (x: c.x + dirA * 0.06, y: c.y < 0.5 ? 0.85 : 0.15);
      case _Role.runner:
        // Lari ke depan sebanding dengan fase serangan (kontinu, tanpa ambang).
        final side = s.isHome ? 0 : 1;
        return (
          x: s.baseX + (s.isHome ? 1 : -1) * 0.10 * math.max(0, _phase[side]),
          y: s.y,
        );
      case _Role.none:
        return null;
    }
  }

  bool _isKeeper(int j) => _roleOf(j) == SlotRole.gk;

  SlotRole _roleOf(int j) {
    final formation = (j < 11 ? home : away).formation;
    return formation.slots[_pitch[j].slotIndex].role;
  }

  /// Bergerak menuju [target] dengan batas [maxStep] per menit.
  static double _approach(double cur, double target, double maxStep) {
    final d = target - cur;
    final step = d.abs() > maxStep ? maxStep * d.sign : d;
    return cur + step;
  }

  // --- Utilitas --------------------------------------------------------------

  void _closeMinutes(_Slot s) {
    _minutesPlayed[s.player.id] =
        (_minutesPlayed[s.player.id] ?? 0) + _minute - s.since;
    s.since = _minute;
  }

  int _keeperIndex(bool home) {
    final base = home ? 0 : 11;
    for (var i = base; i < base + 11; i++) {
      if (_pitch[i].active && _pitch[i].slotIndex == 0) return i;
    }
    for (var i = base; i < base + 11; i++) {
      if (_pitch[i].active) return i;
    }
    return base;
  }

  List<int> _teammates(int c) => [
    for (var i = 0; i < _pitch.length; i++)
      if (i != c && _pitch[i].isHome == _pitch[c].isHome && _pitch[i].active) i,
  ];

  List<int> _opponents(int c) => [
    for (var i = 0; i < _pitch.length; i++)
      if (_pitch[i].isHome != _pitch[c].isHome && _pitch[i].active) i,
  ];

  int _nearest(List<int> idxs, double x, double y) {
    var best = idxs.first;
    var bestD = double.infinity;
    for (final i in idxs) {
      final dx = _pitch[i].x - x;
      final dy = _pitch[i].y - y;
      final d = dx * dx + dy * dy;
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }

  int _nearestActive(bool home, double x, double y) {
    final idxs = [
      for (var i = 0; i < _pitch.length; i++)
        if (_pitch[i].isHome == home && _pitch[i].active) i,
    ];
    return idxs.isEmpty ? _carrier : _nearest(idxs, x, y);
  }

  /// Tekanan dari lawan terdekat (rata-rata kemampuan bertahan 3 pemain).
  double _pressure(int c) {
    final opp = _opponents(c)..sort(
      (a, b) => _distTo(
        a,
        _pitch[c].x,
        _pitch[c].y,
      ).compareTo(_distTo(b, _pitch[c].x, _pitch[c].y)),
    );
    final near = opp.take(3).toList();
    if (near.isEmpty) return 0.5;
    var total = 0.0;
    for (final j in near) {
      total +=
          _skill(j) *
          (0.6 +
              0.4 *
                  _norm(
                    _pitch[j].player,
                    Attribute.tackling,
                    Attribute.positioning,
                  ));
    }
    return total / near.length;
  }

  double _distTo(int i, double x, double y) {
    final dx = _pitch[i].x - x;
    final dy = _pitch[i].y - y;
    return dx * dx + dy * dy;
  }

  /// Kemampuan efektif pemain: CA × kebugaran × kecocokan posisi.
  double _skill(int i) {
    final s = _pitch[i];
    final energy = _clamp(
      (s.player.condition - (_minute - s.since) * 0.12) / 100,
      0.25,
      1.0,
    );
    return s.player.currentAbility / 200 * (0.7 + 0.3 * energy) * s.slotFit;
  }

  double _norm(Player p, Attribute a, Attribute b) =>
      (p.attributes[a] + p.attributes[b]) / 40;

  int _weightedPick(List<int> items, List<double> weights) {
    final total = weights.fold<double>(0, (a, b) => a + b);
    var r = _rng.nextDouble() * total;
    for (var i = 0; i < items.length; i++) {
      r -= weights[i];
      if (r <= 0) return items[i];
    }
    return items.last;
  }

  String _nameOf(int playerId) {
    for (final s in _pitch) {
      if (s.player.id == playerId) return s.player.lastName;
    }
    return '-';
  }

  String _pick(List<String> items) => items[_rng.nextInt(items.length)];

  static double _clamp(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);

  void _emit(
    MatchEventType type,
    String text, {
    bool? isHome,
    int? playerId,
    int? assistId,
  }) {
    final (minute, extra) = _clockLabel();
    _emitAt(
      minute,
      type,
      text,
      isHome: isHome,
      playerId: playerId,
      assistId: assistId,
      extra: extra,
    );
  }

  void _emitAt(
    int minute,
    MatchEventType type,
    String text, {
    bool? isHome,
    int? playerId,
    int? assistId,
    int extra = 0,
  }) {
    final e = MatchEvent(
      minute: minute,
      type: type,
      text: text,
      isHome: isHome,
      playerId: playerId,
      assistId: assistId,
      extra: extra,
    );
    _events.add(e);
    _minuteEvents.add(e);
  }

  void _emitChance(bool isHome, String text, int playerId) {
    if (_rng.chance(0.5)) {
      _emit(MatchEventType.chance, text, isHome: isHome, playerId: playerId);
    }
  }

  static const List<String> _missKeys = ['ev.miss1', 'ev.miss2', 'ev.miss3'];
}

class _Slot {
  _Slot({
    required this.player,
    required this.isHome,
    required this.slotIndex,
    required this.shirt,
    required this.baseX,
    required this.baseY,
    required this.slotFit,
    required this.since,
  }) : x = baseX,
       y = baseY;

  factory _Slot.fromPlayer(
    Player player,
    bool isHome,
    int slotIndex,
    Formation formation,
  ) {
    final slot = formation.slots[slotIndex];
    final depth = slot.depth;
    final lateral = slot.lateral;
    return _Slot(
      player: player,
      isHome: isHome,
      slotIndex: slotIndex,
      shirt: slotIndex + 1,
      baseX: isHome ? depth : 1 - depth,
      baseY: isHome ? lateral : 1 - lateral,
      slotFit: LineupBuilder.slotFit(player.position.group, slot.role),
      since: 0,
    );
  }

  final Player player;
  final bool isHome;
  final int slotIndex;
  final int shirt;
  final double baseX;
  final double baseY;
  final double slotFit;
  double x;
  double y;
  int since;
  bool active = true;
}

/// Peran taktis pemain di satu menit (lihat [_assignRoles]).
enum _Role { none, presser, cover, supportAhead, supportWide, runner }

class _Counters {
  int possessionActions = 0;
  int shots = 0;
  int onTarget = 0;
  int saves = 0;
  int fouls = 0;
  int yellow = 0;
  int red = 0;

  TeamMatchStats freeze() => TeamMatchStats(
    possessionActions: possessionActions,
    shots: shots,
    onTarget: onTarget,
    saves: saves,
    fouls: fouls,
    yellow: yellow,
    red: red,
  );
}
