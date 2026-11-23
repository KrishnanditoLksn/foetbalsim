import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../core/utils/format_utils.dart';
import '../../data/services/game_engine.dart';
import '../../domain/enums/tactics.dart';
import '../../domain/match/match_engine_2d.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/match_models.dart';
import 'pitch_2d_painter.dart';

/// Laga tim kita secara live di lapangan 2D. Kecepatan maksimal 2x.
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..addStatusListener(_onAnimStatus);

  MatchSession? _session;
  MatchSetup? _setup;
  Map<int, Player> _players = {};
  MinuteFrame? _frame;
  String? _error;
  bool _playing = false;
  bool _ourHome = true;
  int _speed = 1;
  bool _committed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final engine = ref.read(gameEngineProvider);
      final setup = await engine.prepareMatch();
      final state = await ref.read(gameStateProvider.future);
      final players = <int, Player>{
        for (final p in [...setup.home.starters, ...setup.home.bench]) p.id: p,
        for (final p in [...setup.away.starters, ...setup.away.bench]) p.id: p,
      };
      if (!mounted) return;
      setState(() {
        _setup = setup;
        _players = players;
        _ourHome = setup.fixture.homeClubId == state?.clubId;
        _session = MatchSession(
          seed: setup.seed,
          fixtureId: setup.fixture.id,
          home: setup.home,
          away: setup.away,
        );
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  // --- Pemutaran -------------------------------------------------------------

  void _onAnimStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_playing) return;
    final session = _session;
    if (session == null) return;
    if (session.finished) {
      setState(() => _playing = false);
      return;
    }
    _stepMinute();
  }

  void _stepMinute() {
    final session = _session!;
    final frame = session.step();
    _anim.duration = Duration(milliseconds: (1000 / _speed).round());
    setState(() => _frame = frame);
    _anim.forward(from: 0);
  }

  void _togglePlay() {
    final session = _session;
    if (session == null || session.finished) return;
    if (_playing) {
      _anim.stop();
      setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    if (_frame != null && _anim.value < 1) {
      _anim.duration = Duration(milliseconds: (1000 / _speed).round());
      _anim.forward();
    } else {
      _stepMinute();
    }
  }

  void _skipToEnd() {
    final session = _session;
    if (session == null) return;
    _anim.stop();
    MinuteFrame? last;
    while (!session.finished) {
      last = session.step();
    }
    setState(() {
      _playing = false;
      _frame = last ?? _frame;
    });
    _anim.value = 1;
  }

  void _setSpeed(int speed) {
    setState(() => _speed = speed);
    _anim.duration = Duration(milliseconds: (1000 / speed).round());
  }

  // --- Intervensi ------------------------------------------------------------

  void _setMentality(Mentality m) {
    final session = _session;
    if (session == null) return;
    session.setMentality(_ourHome, m);
    setState(() {});
  }

  /// Mengembalikan pesan kesalahan bila pergantian ditolak.
  String? _substitute(int outId, int inId) {
    final session = _session;
    if (session == null) return 'Laga belum siap.';
    try {
      session.substitute(_ourHome, outId, inId);
    } on StateError catch (e) {
      return e.message;
    }
    setState(() {});
    return null;
  }

  Future<void> _openSubs() async {
    final session = _session;
    if (session == null || session.finished) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) => _SubsSheet(
            onPitch: session.onPitch(_ourHome),
            bench: session.benchPlayers(_ourHome),
            subsLeft: session.subsLeft(_ourHome),
            onSubstitute: _substitute,
          ),
    );
  }

  Future<void> _finish() async {
    final setup = _setup;
    final session = _session;
    if (setup == null || session == null || !session.finished) return;
    setState(() => _saving = true);
    try {
      final result = await GameActions.commitMatch(
        ref,
        session.result(fixtureId: setup.fixture.id),
      );
      if (!mounted) return;
      _committed = true;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  Future<bool> _confirmLeave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Keluar dari laga?'),
            content: const Text(
              'Laga belum selesai dan belum disimpan. Jika keluar sekarang, '
              'laga akan dimulai ulang dari menit 0 saat dibuka lagi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Lanjutkan'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
    return ok ?? false;
  }

  // --- Tampilan --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final session = _session;
    final setup = _setup;

    final canLeave =
        _committed || session == null || session.minute == 0;

    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmLeave()) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            setup == null
                ? 'Laga'
                : '${setup.home.name} vs ${setup.away.name}',
          ),
        ),
        body:
            _error != null
                ? Center(child: Text('Gagal memuat laga: $_error'))
                : session == null || setup == null
                ? const Center(child: CircularProgressIndicator())
                : _body(context, session, setup, clubs),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    MatchSession session,
    MatchSetup setup,
    Map<String, Club> clubs,
  ) {
    final theme = Theme.of(context);
    final homeClub = clubs[setup.home.clubId];
    final awayClub = clubs[setup.away.clubId];
    final st = session.stats;
    final mentality = session.mentality(_ourHome);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  setup.home.name,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${session.homeGoals} - ${session.awayGoals}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  setup.away.name,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        Text(
          session.minute == 0 ? 'Belum mulai' : "${session.minute}'",
          style: theme.textTheme.labelLarge,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: AspectRatio(
            aspectRatio: 105 / 68,
            child: CustomPaint(
              painter: Pitch2DPainter(
                dots: _dotsFor(session, homeClub, awayClub),
                ballX: _ballX(session),
                ballY: session.ballY,
              ),
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            IconButton.filledTonal(
              tooltip: _playing ? 'Jeda' : 'Mainkan',
              onPressed:
                  session.finished ? null : _togglePlay,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            ),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1x')),
                ButtonSegment(value: 2, label: Text('2x')),
              ],
              selected: {_speed},
              onSelectionChanged: (s) => _setSpeed(s.first),
              showSelectedIcon: false,
            ),
            IconButton.outlined(
              tooltip: 'Skip ke akhir',
              onPressed: session.finished ? null : _skipToEnd,
              icon: const Icon(Icons.fast_forward),
            ),
            OutlinedButton.icon(
              onPressed: session.finished ? null : _openSubs,
              icon: const Icon(Icons.swap_horiz),
              label: Text('Ganti (${session.subsLeft(_ourHome)})'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SegmentedButton<Mentality>(
            segments: [
              for (final m in Mentality.values)
                ButtonSegment(value: m, label: Text(m.label)),
            ],
            selected: {mentality},
            onSelectionChanged:
                session.finished ? null : (s) => _setMentality(s.first),
            showSelectedIcon: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              _StatChip('Penguasaan', '${st.homePossession}% - ${st.awayPossession}%'),
              _StatChip('Tembakan', '${st.home.shots} - ${st.away.shots}'),
              _StatChip(
                'Tepat sasaran',
                '${st.home.onTarget} - ${st.away.onTarget}',
              ),
              _StatChip('Penyelamatan', '${st.home.saves} - ${st.away.saves}'),
              _StatChip('Pelanggaran', '${st.home.fouls} - ${st.away.fouls}'),
              _StatChip(
                'Kartu',
                '${st.home.yellow + st.home.red} - ${st.away.yellow + st.away.red}',
              ),
            ],
          ),
        ),
        if (session.finished)
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _finish,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'Menyimpan...' : 'Simpan & Kembali'),
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: session.events.length,
            itemBuilder: (context, i) {
              final e = session.events[session.events.length - 1 - i];
              return _EventTile(event: e, players: _players);
            },
          ),
        ),
      ],
    );
  }

  double _ballX(MatchSession session) {
    final f = _frame;
    if (f == null || _anim.value >= 1) return session.ballX;
    return f.ballFromX + (session.ballX - f.ballFromX) * _anim.value;
  }

  /// Posisi pemain: interpolasi dari posisi awal menit ke posisi akhir.
  List<PitchDot> _dotsFor(MatchSession session, Club? home, Club? away) {
    final frame = _frame;
    final from = {for (final d in frame?.from ?? const <PlayerDot>[]) d.index: d};
    final t = _anim.value;
    final carrier = session.carrierIndex;
    final result = <PitchDot>[];
    for (final d in session.currentDots()) {
      final f = from[d.index];
      final x = f == null ? d.x : f.x + (d.x - f.x) * t;
      final y = f == null ? d.y : f.y + (d.y - f.y) * t;
      final club = d.isHome ? home : away;
      final fill = club != null
          ? colorFromHex(club.primaryColor)
          : (d.isHome ? Colors.blue : Colors.red);
      final stroke = club != null
          ? colorFromHex(club.secondaryColor)
          : Colors.white;
      final player = _players[d.playerId];
      result.add(
        PitchDot(
          x: x,
          y: y,
          fill: fill,
          stroke: stroke,
          label: '${d.shirt}',
          name: d.index == carrier ? player?.lastName : null,
        ),
      );
    }
    return result;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text('$label $value'),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.players});

  final MatchEvent event;
  final Map<int, Player> players;

  @override
  Widget build(BuildContext context) {
    final style = switch (event.type) {
      MatchEventType.goal => const TextStyle(fontWeight: FontWeight.w800),
      MatchEventType.red || MatchEventType.yellow =>
        const TextStyle(color: Colors.orange),
      _ => null,
    };
    final icon = switch (event.type) {
      MatchEventType.goal => Icons.sports_soccer,
      MatchEventType.yellow => Icons.square,
      MatchEventType.red => Icons.square,
      MatchEventType.substitution => Icons.swap_horiz,
      MatchEventType.halfTime || MatchEventType.fullTime => Icons.flag,
      MatchEventType.save => Icons.back_hand,
      MatchEventType.shotOff || MatchEventType.chance => Icons.gps_fixed,
      MatchEventType.mentality => Icons.tune,
      _ => Icons.circle_outlined,
    };
    return ListTile(
      dense: true,
      leading: Text(
        "${event.minute}'",
        style: Theme.of(context).textTheme.labelLarge,
      ),
      title: Text(event.text, style: style),
      trailing: Icon(
        icon,
        size: 18,
        color: event.type == MatchEventType.red
            ? Colors.red
            : event.type == MatchEventType.yellow
            ? Colors.amber
            : null,
      ),
    );
  }
}

class _SubsSheet extends StatefulWidget {
  const _SubsSheet({
    required this.onPitch,
    required this.bench,
    required this.subsLeft,
    required this.onSubstitute,
  });

  final List<Player> onPitch;
  final List<Player> bench;
  final int subsLeft;
  final String? Function(int outId, int inId) onSubstitute;

  @override
  State<_SubsSheet> createState() => _SubsSheetState();
}

class _SubsSheetState extends State<_SubsSheet> {
  int? _out;
  int? _in;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pergantian (sisa ${widget.subsLeft})',
                style: theme.textTheme.titleMedium,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text('Keluar (di lapangan)', style: theme.textTheme.labelLarge),
                    for (final p in widget.onPitch)
                      RadioListTile<int>(
                        dense: true,
                        value: p.id,
                        groupValue: _out,
                        title: Text(p.fullName),
                        subtitle: Text('${p.position.label} · CA ${p.currentAbility}'),
                        onChanged: (v) => setState(() => _out = v),
                      ),
                    const SizedBox(height: 8),
                    Text('Masuk (bangku)', style: theme.textTheme.labelLarge),
                    for (final p in widget.bench)
                      RadioListTile<int>(
                        dense: true,
                        value: p.id,
                        groupValue: _in,
                        title: Text(p.fullName),
                        subtitle: Text('${p.position.label} · CA ${p.currentAbility}'),
                        onChanged: (v) => setState(() => _in = v),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed:
                    widget.subsLeft <= 0 || _out == null || _in == null
                        ? null
                        : () {
                          final err = widget.onSubstitute(_out!, _in!);
                          if (err != null) {
                            setState(() => _error = err);
                          } else if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                child: const Text('Ganti pemain'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
