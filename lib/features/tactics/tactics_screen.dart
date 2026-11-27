import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../domain/enums/tactics.dart';
import '../../domain/match/lineup_builder.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/match_models.dart';
import '../../l10n/l10n.dart';
import '../match/pitch_2d_painter.dart';
import '../squad/squad_screen.dart';

/// Layar Taktik mandiri (rute `/tactics`). Isinya sama dengan tab Taktik
/// di layar Skuad.
class TacticsScreen extends StatelessWidget {
  const TacticsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('tactics.title'))),
    body: const TacticsView(),
  );
}

/// Mengatur formasi, mentalitas, 11 starter, dan 7 cadangan. Perubahan
/// langsung disimpan ke save.
class TacticsView extends ConsumerStatefulWidget {
  const TacticsView({super.key});

  @override
  ConsumerState<TacticsView> createState() => _TacticsViewState();
}

class _TacticsViewState extends ConsumerState<TacticsView> {
  /// Indeks starter yang sedang dipilih untuk ditukar. Null = tidak ada.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final lineup = ref.watch(lineupProvider);
    final tactic = ref.watch(clubTacticProvider).valueOrNull;
    final state = ref.watch(gameStateProvider).valueOrNull;
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final club = state?.clubId == null ? null : clubs[state!.clubId!];

    return lineup.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) =>
              Center(child: Text(tr('squad.loadFailed', {'error': '$e'}))),
      data: (l) {
        final formation = tactic?.formation ?? Formation.f442;
        final mentality = tactic?.mentality ?? Mentality.balanced;
        const pad = EdgeInsets.symmetric(horizontal: 20);
        return ListView(
          padding: const EdgeInsets.only(top: 14, bottom: 24),
          children: [
            Padding(
              padding: pad,
              child: _Controls(
                formation: formation,
                mentality: mentality,
                onFormation: (f) => _changeFormation(f),
                onMentality:
                    (m) => _save(
                      formation: formation,
                      mentality: m,
                      starters: l.starters,
                      bench: l.bench,
                    ),
                onAuto: () => _auto(formation, mentality),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: pad,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AspectRatio(
                  aspectRatio: 105 / 68,
                  child: CustomPaint(
                    painter: Pitch2DPainter(
                      dots: [
                        for (var i = 0; i < l.starters.length; i++)
                          PitchDot(
                            x: formation.slots[i].depth,
                            y: formation.slots[i].lateral,
                            fill:
                                club != null
                                    ? colorFromHex(club.primaryColor)
                                    : Colors.blue,
                            stroke:
                                _selected == i
                                    ? Chalk.yellow
                                    : club != null
                                    ? colorFromHex(club.secondaryColor)
                                    : Colors.white,
                            label: '${i + 1}',
                            name: _shortName(l.starters[i]),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: pad,
              child: _SwapHint(
                active: _selected != null,
                selectedName:
                    _selected == null ? null : l.starters[_selected!].fullName,
                onCancel: () => setState(() => _selected = null),
              ),
            ),
            Padding(
              padding: pad,
              child: SectionHeader(tr('tactics.startingXI')),
            ),
            for (var i = 0; i < l.starters.length; i++)
              PlayerListCard(
                player: l.starters[i],
                leading: _SlotLabel(formation.slots[i].label),
                selected: _selected == i,
                onTap: () => _tapStarter(i, formation, mentality, l),
              ),
            Padding(
              padding: pad,
              child: SectionHeader(
                tr('tactics.bench', {
                  'n': l.bench.length,
                  'max': LineupBuilder.benchCount,
                }),
              ),
            ),
            for (var i = 0; i < l.bench.length; i++)
              PlayerListCard(
                player: l.bench[i],
                leading: _SlotLabel('${i + 12}', muted: true),
                onTap: () => _tapBench(i, formation, mentality, l),
              ),
          ],
        );
      },
    );
  }

  static String _shortName(Player p) =>
      p.lastName.length > 9 ? p.lastName.substring(0, 9) : p.lastName;

  void _tapStarter(
    int i,
    Formation formation,
    Mentality mentality,
    ({List<Player> starters, List<Player> bench}) l,
  ) {
    if (_selected == null) {
      setState(() => _selected = i);
      return;
    }
    if (_selected == i) {
      setState(() => _selected = null);
      return;
    }
    final starters = [...l.starters];
    final a = _selected!;
    final tmp = starters[a];
    starters[a] = starters[i];
    starters[i] = tmp;
    setState(() => _selected = null);
    _save(
      formation: formation,
      mentality: mentality,
      starters: starters,
      bench: l.bench,
    );
  }

  void _tapBench(
    int i,
    Formation formation,
    Mentality mentality,
    ({List<Player> starters, List<Player> bench}) l,
  ) {
    final sel = _selected;
    if (sel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('tactics.pickStarterFirst'))));
      return;
    }
    final starters = [...l.starters];
    final bench = [...l.bench];
    final out = starters[sel];
    starters[sel] = bench[i];
    bench[i] = out;
    setState(() => _selected = null);
    _save(
      formation: formation,
      mentality: mentality,
      starters: starters,
      bench: bench,
    );
  }

  Future<void> _changeFormation(Formation f) async {
    final state = await ref.read(gameStateProvider.future);
    final clubId = state?.clubId;
    if (clubId == null) return;
    final squad = await ref.read(squadProvider(clubId).future);
    final tactic = ref.read(clubTacticProvider).valueOrNull;
    final auto = LineupBuilder.auto(squad, f);
    await _save(
      formation: f,
      mentality: tactic?.mentality ?? Mentality.balanced,
      starters: auto.starters,
      bench: auto.bench,
    );
  }

  Future<void> _auto(Formation formation, Mentality mentality) async {
    final state = await ref.read(gameStateProvider.future);
    final clubId = state?.clubId;
    if (clubId == null) return;
    final squad = await ref.read(squadProvider(clubId).future);
    final auto = LineupBuilder.auto(squad, formation);
    await _save(
      formation: formation,
      mentality: mentality,
      starters: auto.starters,
      bench: auto.bench,
    );
  }

  Future<void> _save({
    required Formation formation,
    required Mentality mentality,
    required List<Player> starters,
    required List<Player> bench,
  }) async {
    final state = await ref.read(gameStateProvider.future);
    final clubId = state?.clubId;
    if (clubId == null) return;
    await GameActions.run(
      ref,
      (engine) => engine.saveTactics(
        ClubTactic(
          clubId: clubId,
          formation: formation,
          mentality: mentality,
          starterIds: [for (final p in starters) p.id],
          subIds: [for (final p in bench) p.id],
        ),
      ),
    );
  }
}

/// Kontrol formasi, pilih otomatis, dan mentalitas, langsung di papan.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.formation,
    required this.mentality,
    required this.onFormation,
    required this.onMentality,
    required this.onAuto,
  });

  final Formation formation;
  final Mentality mentality;
  final ValueChanged<Formation> onFormation;
  final ValueChanged<Mentality> onMentality;
  final VoidCallback onAuto;

  @override
  Widget build(BuildContext context) {
    final label = TextStyle(color: Chalk.dim, fontSize: 13);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('tactics.formation'), style: label),
                  DropdownButton<Formation>(
                    value: formation,
                    isExpanded: true,
                    underline: Divider(color: Chalk.dim),
                    style: TextStyle(
                      fontFamily: Fonts.condensed,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Chalk.white,
                      fontFeatures: tabular,
                    ),
                    items: [
                      for (final f in Formation.values)
                        DropdownMenuItem(value: f, child: Text(f.label)),
                    ],
                    onChanged: (f) {
                      if (f != null) onFormation(f);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(onPressed: onAuto, child: Text(tr('tactics.auto'))),
          ],
        ),
        const SizedBox(height: 14),
        Text(tr('tactics.mentality'), style: label),
        const SizedBox(height: 6),
        SegmentedButton<Mentality>(
          segments: [
            for (final m in Mentality.values)
              ButtonSegment(value: m, label: Text(m.label)),
          ],
          selected: {mentality},
          onSelectionChanged: (s) => onMentality(s.first),
          showSelectedIcon: false,
        ),
      ],
    );
  }
}

/// Petunjuk tukar pemain; berubah menjadi kapur kuning saat mode tukar aktif.
class _SwapHint extends StatelessWidget {
  const _SwapHint({
    required this.active,
    required this.selectedName,
    required this.onCancel,
  });

  final bool active;
  final String? selectedName;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Text(
        tr('tactics.swapHint'),
        style: TextStyle(color: Chalk.dim, fontSize: 14),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: Chalk.yellow.withValues(alpha: 0.14),
        border: Border(left: BorderSide(color: Chalk.yellow, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tr('tactics.swapping', {'name': selectedName}),
              style: TextStyle(
                color: Chalk.yellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(foregroundColor: Chalk.yellow),
            child: Text(tr('common.cancel')),
          ),
        ],
      ),
    );
  }
}

/// Label slot formasi (mis. `DC`) atau nomor cadangan.
class _SlotLabel extends StatelessWidget {
  const _SlotLabel(this.text, {this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: Fonts.condensed,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: muted ? Chalk.dim : Chalk.white,
        ),
      ),
    );
  }
}
