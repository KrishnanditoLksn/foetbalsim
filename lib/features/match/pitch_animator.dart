import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../domain/models/match_models.dart';

/// Posisi tampil satu pemain beserta data dotnya.
class PlayerPose {
  const PlayerPose({required this.dot, required this.x, required this.y});

  final PlayerDot dot;
  final double x;
  final double y;
}

/// Satu bagian lintasan bola yang punya waktu mulai dan durasi sendiri.
///
/// - Run udara (umpan/tembakan) memakai easing ease-in-out di seluruh
///   penerbangan: bola mulai pelan saat ditendang, cepat di tengah, lalu
///   melambat saat diterima.
/// - Run menggiring (owner ≥ 0) bergulir linier mengikuti pemain.
class _BallRun {
  _BallRun({
    required this.start,
    required this.duration,
    required this.owner,
    required this.points,
    required this.cum,
  });

  final double start;
  final double duration;
  final int owner;
  final List<BallWaypoint> points;
  final List<double> cum; // panjang kumulatif per titik

  double get end => start + duration;
  double get length => cum.last;
  bool get eased => owner < 0;
}

/// Penampil laga berbasis timeline.
///
/// Pemain berinterpolasi antara dua tick simulasi. Bola mengikuti timeline
/// [_BallRun] yang dijadwalkan dari lintasan setiap tick. Waktu dinyatakan
/// dalam satuan tick simulasi, dan dikendalikan oleh jam permainan lewat
/// [update]; frame rate layar tidak memengaruhi logika.
class PitchAnimator extends ChangeNotifier {
  // Durasi run dalam satuan tick (1 tick = 1/6 menit permainan).
  static const double _minAirTicks = 1.2;
  static const double _maxAirTicks = 2.4;
  static const double _minDribbleTicks = 0.6;
  static const double _maxDribbleTicks = 1.4;
  static const double _maxBacklogTicks = 1.5;

  List<PlayerDot> _from = const [];
  List<PlayerDot> _to = const [];
  double _tickStart = 0;
  double _clock = 0;
  final List<_BallRun> _runs = [];
  double _endTime = double.negativeInfinity;

  double ballX = 0.5;
  double ballY = 0.5;
  int carrier = -1;

  /// Garis offside pada tick ini (null bila tidak ada offside).
  double? offsideX;
  List<PlayerPose> _poses = const [];

  /// Semua pemain di lapangan, diurutkan per indeks (stabil).
  List<PlayerPose> get poses => _poses;

  /// Selisih antara jadwal bola dan jam permainan (dalam tick). Dipakai untuk
  /// memastikan bola tidak tertinggal jauh dari simulasi.
  double get ballLag => _runs.isEmpty ? 0 : _endTime - _clock;

  /// Menempatkan pemain dan bola langsung, tanpa lintasan (awal laga, setelah
  /// Skip). Timeline bola dikosongkan.
  void snap(
    List<PlayerDot> dots, {
    required double ballX,
    required double ballY,
    required int carrier,
  }) {
    _from = dots;
    _to = dots;
    _runs.clear();
    _endTime = double.negativeInfinity;
    this.ballX = ballX;
    this.ballY = ballY;
    this.carrier = carrier;
    _poses = _buildPoses(dots, dots, 1, owner: -1);
    notifyListeners();
  }

  /// Menetapkan tick baru: pemain dari [from] ke [to] selama tick yang mulai
  /// pada waktu [tickStart] (dalam satuan tick), dan lintasan bola [path].
  void setTick({
    required List<PlayerDot> from,
    required List<PlayerDot> to,
    required List<BallWaypoint> path,
    required int carrier,
    required double tickStart,
    double? offsideX,
  }) {
    _from = from;
    _to = to;
    _tickStart = tickStart;
    this.carrier = carrier;
    this.offsideX = offsideX;
    _enqueue(path, tickStart);
  }

  /// Memajukan tampilan ke waktu jam [clock] (dalam satuan tick).
  void update(double clock) {
    _clock = clock;
    final alpha = math.max(0.0, math.min(1.0, clock - _tickStart));
    final ball = _ballAt(clock);
    final owner = ball.owner;

    final changed =
        ball.x != ballX ||
        ball.y != ballY ||
        alpha != _alpha ||
        owner != carrier;
    ballX = ball.x;
    ballY = ball.y;
    _alpha = alpha;
    _poses = _buildPoses(_from, _to, alpha, owner: owner);
    _pruneRuns(clock);
    if (changed) notifyListeners();
  }

  /// Memperbarui data pemain setelah pergantian atau kartu merah. Posisi yang
  /// sudah ada tidak diubah, dan timeline bola tetap berjalan.
  void retarget(List<PlayerDot> dots, {required int carrier}) {
    final present = {for (final d in dots) d.index};
    _to = dots;
    _from = [
      for (final d in _from)
        if (present.contains(d.index)) d,
    ];
    final known = {for (final d in _from) d.index};
    _from = [
      ..._from,
      for (final d in dots)
        if (!known.contains(d.index)) d,
    ];
    this.carrier = carrier;
    _poses = _buildPoses(_from, _to, _alpha, owner: _ballAt(_clock).owner);
    notifyListeners();
  }

  double _alpha = 1;

  // --- internal ----------------------------------------------------------------

  /// Membagi lintasan menjadi run dan menjadwalkannya setelah run terakhir.
  void _enqueue(List<BallWaypoint> path, double tickStart) {
    if (path.length < 2) return;
    final groups = _groupRuns(path);

    // Jika timeline sudah tertinggal, durasi run dimampatkan agar bola
    // tidak tertinggal jauh dari simulasi.
    final backlog = _endTime - tickStart;
    final scale =
        backlog > _maxBacklogTicks
            ? math.max(0.3, _maxBacklogTicks / backlog)
            : 1.0;

    var t = math.max(_endTime.isFinite ? _endTime : tickStart, tickStart);
    for (final g in groups) {
      final cum = <double>[0];
      for (var i = 1; i < g.points.length; i++) {
        final a = g.points[i - 1];
        final b = g.points[i];
        cum.add(cum.last + math.sqrt(_sq(b.x - a.x) + _sq(b.y - a.y)));
      }
      if (cum.last < 1e-9) continue;
      final base =
          g.owner >= 0
              ? math.min(
                _maxDribbleTicks,
                math.max(_minDribbleTicks, cum.last * 9),
              )
              : math.min(
                _maxAirTicks,
                math.max(_minAirTicks, 1.2 + cum.last * 4.0),
              );
      final duration = base * scale;
      _runs.add(
        _BallRun(
          start: t,
          duration: duration,
          owner: g.owner,
          points: g.points,
          cum: cum,
        ),
      );
      t += duration;
    }
    _endTime = t;
  }

  /// Mengelompokkan segmen lintasan berurutan dengan pemilik yang sama.
  List<({int owner, List<BallWaypoint> points})> _groupRuns(
    List<BallWaypoint> path,
  ) {
    final groups = <({int owner, List<BallWaypoint> points})>[];
    int segOwner(int i) =>
        path[i - 1].owner == path[i].owner ? path[i].owner : -1;

    var start = 1;
    while (start < path.length) {
      final owner = segOwner(start);
      var end = start;
      while (end + 1 < path.length && segOwner(end + 1) == owner) {
        end++;
      }
      groups.add((owner: owner, points: path.sublist(start - 1, end + 1)));
      start = end + 1;
    }
    return groups;
  }

  /// Posisi bola dan pemilik pada waktu [t] (dalam satuan tick).
  BallWaypoint _ballAt(double t) {
    if (_runs.isEmpty) return BallWaypoint(ballX, ballY, owner: carrier);
    _BallRun run = _runs.first;
    if (t <= run.start) return run.points.first.withOwner(run.owner);
    for (final r in _runs) {
      if (t >= r.start) run = r;
    }
    if (t >= run.end) {
      return run.points.last.withOwner(run.owner);
    }
    final s = (t - run.start) / run.duration;
    // Udara: ease-in-out penuh (tendang pelan, cepat di tengah, pelan saat
    // diterima). Menggiring: setengah linier agar sentuhan menggelinding.
    final smooth = s * s * (3 - 2 * s);
    final e = run.eased ? smooth : 0.5 * s + 0.5 * smooth;
    final target = e * run.length;
    for (var i = 1; i < run.points.length; i++) {
      if (target <= run.cum[i] || i == run.points.length - 1) {
        final seg = run.cum[i] - run.cum[i - 1];
        final k = seg <= 0 ? 1.0 : (target - run.cum[i - 1]) / seg;
        final a = run.points[i - 1];
        final b = run.points[i];
        return BallWaypoint(
          a.x + (b.x - a.x) * k,
          a.y + (b.y - a.y) * k,
          owner: run.owner,
        );
      }
    }
    return run.points.last.withOwner(run.owner);
  }

  void _pruneRuns(double clock) {
    while (_runs.length > 1 && _runs.first.end < clock - 2) {
      _runs.removeAt(0);
    }
  }

  List<PlayerPose> _buildPoses(
    List<PlayerDot> from,
    List<PlayerDot> to,
    double alpha, {
    required int owner,
  }) {
    final fromByIndex = {for (final d in from) d.index: d};
    final list = <PlayerPose>[];
    for (final d in to) {
      final f = fromByIndex[d.index] ?? d;
      var x = f.x + (d.x - f.x) * alpha;
      var y = f.y + (d.y - f.y) * alpha;
      // Pemain yang sedang menggiring menempel pada bola.
      if (d.index == owner) {
        x = ballX;
        y = ballY;
      }
      list.add(PlayerPose(dot: d, x: x, y: y));
    }
    list.sort((a, b) => a.dot.index.compareTo(b.dot.index));
    return list;
  }

  static double _sq(double v) => v * v;
}

extension on BallWaypoint {
  BallWaypoint withOwner(int owner) => BallWaypoint(x, y, owner: owner);
}
