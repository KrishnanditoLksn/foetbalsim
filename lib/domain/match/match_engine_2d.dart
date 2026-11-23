import 'dart:math' as math;

import '../../core/rng/seeded_random.dart';
import '../enums/attribute.dart';
import '../enums/tactics.dart';
import '../models/game_models.dart';
import '../models/match_models.dart';
import '../season/quick_match_simulator.dart';
import 'lineup_builder.dart';

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
    _emitAt(0, MatchEventType.kickOff, 'Pertandingan dimulai.');
  }

  static const int fullMinutes = 90;
  static const int maxSubs = 5;

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
  int _carrier = 0;
  int? _lastPasser;
  double _ballX = 0.5;
  double _ballY = 0.5;
  List<MatchEvent> _minuteEvents = [];
  bool _inStep = false;

  int get minute => _minute;
  bool get finished => _minute >= fullMinutes;
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
      '${isHome ? home.name : away.name} mengubah mentalitas menjadi '
      '${value.label}.',
      isHome: isHome,
    );
  }

  /// Pergantian pemain: [outId] keluar dari lapangan, [inId] dari bangku.
  void substitute(bool isHome, int outId, int inId) {
    final side = isHome ? 0 : 1;
    if (finished) throw StateError('Laga sudah selesai.');
    if (_subsUsed[side] >= maxSubs) {
      throw StateError('Batas $maxSubs pergantian sudah habis.');
    }
    final idx = _pitch.indexWhere(
      (s) => s.isHome == isHome && s.active && s.player.id == outId,
    );
    if (idx < 0) throw StateError('Pemain keluar tidak di lapangan.');
    final bench = _benchLeft[side];
    if (!bench.contains(inId)) {
      throw StateError('Pemain masuk tidak ada di bangku cadangan.');
    }
    final incoming = benchPlayers(isHome).firstWhere((p) => p.id == inId);

    final out = _pitch[idx];
    _closeMinutes(out);
    final replacement = _Slot.fromPlayer(
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

    _emit(
      MatchEventType.substitution,
      'Pergantian ${isHome ? home.name : away.name}: '
      'masuk ${incoming.lastName}, keluar ${out.player.lastName}.',
      isHome: isHome,
      playerId: inId,
      assistId: outId,
    );
  }

  // --- Simulasi --------------------------------------------------------------

  /// Memajukan satu menit dan mengembalikan frame untuk animasi.
  MinuteFrame step() {
    if (finished) throw StateError('Laga sudah selesai.');
    final m = _minute + 1;
    final from = currentDots();
    final fromBallX = _ballX;
    final fromBallY = _ballY;
    _minuteEvents = [];

    final carrierHome = _carrier < 11;
    final bias = _mentality[carrierHome ? 0 : 1].attackBias;
    final actions = math.min(4, math.max(1, (1 + _rng.nextDouble() * 2.4 * bias).round()));
    _inStep = true;
    for (var i = 0; i < actions; i++) {
      if (!_pitch[_carrier].active) {
        _carrier = _nearestActive(_carrier < 11, _ballX, _ballY);
      }
      _runAction();
    }

    _ballX = _pitch[_carrier].x;
    _ballY = _pitch[_carrier].y;
    _moveAll();
    _minute = m;

    if (m == 45) _emit(MatchEventType.halfTime, 'Turun minum. Skor $_homeGoals-$_awayGoals.');
    if (m == 90) {
      _emit(
        MatchEventType.fullTime,
        'Peluit akhir. Skor akhir $_homeGoals-$_awayGoals.',
      );
    }
    _inStep = false;
    final to = currentDots();
    return MinuteFrame(
      minute: m,
      from: from,
      to: to,
      ballFromX: fromBallX,
      ballFromY: fromBallY,
      ballToX: _ballX,
      ballToY: _ballY,
      carrierIndex: _carrier,
      events: List.unmodifiable(_minuteEvents),
    );
  }

  /// Hasil akhir untuk disimpan. Hanya valid setelah [finished].
  MatchResultData result({required int fixtureId}) {
    if (!finished) throw StateError('Laga belum selesai.');
    final minutes = Map<int, int>.from(_minutesPlayed);
    for (final s in _pitch) {
      if (s.active) {
        minutes[s.player.id] = (minutes[s.player.id] ?? 0) + fullMinutes - s.since;
      }
    }
    return MatchResultData(
      fixtureId: fixtureId,
      homeClubId: home.clubId,
      awayClubId: away.clubId,
      homeGoals: _homeGoals,
      awayGoals: _awayGoals,
      events: List.unmodifiable(_events),
      stats: MatchStats(home: _counters[0].freeze(), away: _counters[1].freeze()),
      minutesPlayed: minutes,
      homeScorerNames: List.unmodifiable(_homeScorers),
      awayScorerNames: List.unmodifiable(_awayScorers),
    );
  }

  // --- Aksi bola -------------------------------------------------------------

  void _runAction() {
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
        math.max(0.05, 0.6 + (_pitch[j].x - s.x) * dir * 4) *
            (0.5 + _skill(j)),
    ];
    final j = _weightedPick(mates, weights);

    final passing = _norm(s.player, Attribute.passing, Attribute.vision);
    final success = _clamp(
      0.7 + 0.3 * (passing - 0.5) + (_skill(c) - pressure) * 0.6,
      0.35,
      0.97,
    );
    if (_rng.chance(success)) {
      _lastPasser = c;
      if (_rng.chance(0.12) && (_pitch[j].x - s.x) * dir > 0.12) {
        _emitChance(s.isHome, 'Umpan terobosan dari ${s.player.lastName} '
            'ke ${_pitch[j].player.lastName}!', s.player.id);
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
      _lastPasser = c;
      _emitChance(home, 'Umpan silang ${s.player.lastName} ke '
          '${_pitch[j].player.lastName} di kotak penalti.', s.player.id);
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
      s.x = _clamp(s.x + dir * (0.05 + _rng.nextDouble() * 0.04), 0.02, 0.98);
      _ballX = s.x;
      _ballY = s.y;
    } else {
      _turnover(c);
    }
  }

  void _shot(int c) {
    final s = _pitch[c];
    final home = s.isHome;
    _counters[home ? 0 : 1].shots++;

    final fin = s.player.attributes[Attribute.finishing] / 20;
    final comp = s.player.attributes[Attribute.composure] / 20;
    final gkIdx = _keeperIndex(!home);
    final gk = _pitch[gkIdx];
    final gkRate = _norm(gk.player, Attribute.reflexes, Attribute.handling);

    final onTargetP = _clamp(0.38 + 0.28 * fin + 0.1 * comp, 0.2, 0.85);
    if (!_rng.chance(onTargetP)) {
      _emit(
        MatchEventType.shotOff,
        _pick(_missTexts).replaceAll('{p}', s.player.lastName),
        isHome: home,
        playerId: s.player.id,
      );
      _carrier = gkIdx;
      return;
    }

    _counters[home ? 0 : 1].onTarget++;
    final goalP = _clamp(0.16 + 0.25 * fin + 0.1 * comp - 0.25 * gkRate, 0.04, 0.55);
    if (_rng.chance(goalP)) {
      if (home) {
        _homeGoals++;
        _homeScorers.add(s.player.lastName);
      } else {
        _awayGoals++;
        _awayScorers.add(s.player.lastName);
      }
      final assistIdx = _lastPasser;
      final assistId =
          (assistIdx != null && assistIdx != c &&
                  _pitch[assistIdx].isHome == home)
              ? _pitch[assistIdx].player.id
              : null;
      _emit(
        MatchEventType.goal,
        'GOOL! ${s.player.fullName}'
        '${assistId == null ? '' : ' (assist: ${_nameOf(assistId)})'} — '
        '$_homeGoals-$_awayGoals.',
        isHome: home,
        playerId: s.player.id,
        assistId: assistId,
      );
      // Kick-off oleh tim yang kebobolan.
      _carrier = home ? 17 : 6;
      _lastPasser = null;
      return;
    }

    _counters[home ? 1 : 0].saves++;
    _emit(
      MatchEventType.save,
      'Penyelamatan ${gk.player.lastName}! Tembakan ${s.player.lastName} '
      'ditepis.',
      isHome: !home,
      playerId: gk.player.id,
    );
    _carrier = gkIdx;
    _lastPasser = null;
  }

  /// Bola berpindah ke lawan terdekat. Kadang terjadi pelanggaran.
  void _turnover(int c) {
    final s = _pitch[c];
    final defenders = _opponents(c);
    if (defenders.isEmpty) return;
    if (_rng.chance(0.07)) {
      final defender = _nearest(defenders, s.x, s.y);
      _foul(defender);
      return; // tendangan bebas: penguasa bola tetap
    }
    _carrier = _nearest(defenders, s.x, s.y);
    _lastPasser = null;
  }

  void _foul(int defender) {
    final d = _pitch[defender];
    final home = d.isHome;
    _counters[home ? 0 : 1].fouls++;
    _emit(
      MatchEventType.foul,
      'Pelanggaran oleh ${d.player.lastName}.',
      isHome: home,
      playerId: d.player.id,
    );
    final yellowP = 0.18 + d.player.attributes[Attribute.aggression] / 50;
    if (!_rng.chance(yellowP)) return;

    final prior = _yellows[d.player.id] ?? 0;
    if (prior == 0) {
      _yellows[d.player.id] = 1;
      _counters[home ? 0 : 1].yellow++;
      _emit(
        MatchEventType.yellow,
        'Kartu kuning untuk ${d.player.lastName}.',
        isHome: home,
        playerId: d.player.id,
      );
    } else {
      _counters[home ? 0 : 1].red++;
      _emit(
        MatchEventType.red,
        'Kartu merah! ${d.player.lastName} diusir dari lapangan.',
        isHome: home,
        playerId: d.player.id,
      );
      _closeMinutes(d);
      d.active = false;
      if (_carrier == defender) {
        _carrier = _nearestActive(!home, d.x, d.y);
      }
    }
  }

  // --- Posisi ----------------------------------------------------------------

  void _moveAll() {
    final carrierHome = _carrier < 11;
    final chasers = _chasers();
    for (var i = 0; i < _pitch.length; i++) {
      final s = _pitch[i];
      if (!s.active) continue;
      final hasBall = s.isHome == carrierHome;
      final dir = s.isHome ? 1.0 : -1.0;
      final mentality = _mentality[s.isHome ? 0 : 1];
      final push = (hasBall ? 1.0 : -1.0) * (0.03 + mentality.pushShift) * dir;

      var tx = s.baseX + push;
      var ty = s.baseY;
      if (chasers.contains(i)) {
        tx = tx + (_ballX - tx) * 0.35;
        ty = ty + (_ballY - ty) * 0.35;
      }
      tx += (_rng.nextDouble() - 0.5) * 0.02;
      ty += (_rng.nextDouble() - 0.5) * 0.02;
      if (i == _carrier) {
        tx = _ballX;
        ty = _ballY;
      }
      s.x = _clamp(tx, 0.03, 0.97);
      s.y = _clamp(ty, 0.03, 0.97);
    }
  }

  /// Dua pemain terdekat bola dari tiap tim ikut mengejar.
  Set<int> _chasers() {
    final result = <int>{};
    for (final home in [true, false]) {
      final idxs = [
        for (var i = 0; i < _pitch.length; i++)
          if (_pitch[i].isHome == home && _pitch[i].active) i,
      ]..sort((a, b) => _dist2(a).compareTo(_dist2(b)));
      result.addAll(idxs.take(2));
    }
    return result;
  }

  double _dist2(int i) {
    final dx = _pitch[i].x - _ballX;
    final dy = _pitch[i].y - _ballY;
    return dx * dx + dy * dy;
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
    final opp = _opponents(c)
      ..sort(
        (a, b) => _distTo(a, _pitch[c].x, _pitch[c].y).compareTo(
          _distTo(b, _pitch[c].x, _pitch[c].y),
        ),
      );
    final near = opp.take(3).toList();
    if (near.isEmpty) return 0.5;
    var total = 0.0;
    for (final j in near) {
      total += _skill(j) *
          (0.6 + 0.4 * _norm(_pitch[j].player, Attribute.tackling, Attribute.positioning));
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
  }) => _emitAt(_inStep ? _minute + 1 : _minute, type, text,
      isHome: isHome, playerId: playerId, assistId: assistId);

  void _emitAt(
    int minute,
    MatchEventType type,
    String text, {
    bool? isHome,
    int? playerId,
    int? assistId,
  }) {
    final e = MatchEvent(
      minute: minute,
      type: type,
      text: text,
      isHome: isHome,
      playerId: playerId,
      assistId: assistId,
    );
    _events.add(e);
    _minuteEvents.add(e);
  }

  void _emitChance(bool isHome, String text, int playerId) {
    if (_rng.chance(0.5)) {
      _emit(MatchEventType.chance, text, isHome: isHome, playerId: playerId);
    }
  }

  static const List<String> _missTexts = [
    'Tembakan {p} melebar.',
    'Tembakan {p} melambung di atas mistar.',
    'Sepakan {p} meleset tipis di samping gawang.',
  ];
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
