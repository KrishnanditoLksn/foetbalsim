import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../core/utils/format_utils.dart';
import '../../domain/enums/tactics.dart';
import '../../domain/match/lineup_builder.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/match_models.dart';
import '../match/pitch_2d_painter.dart';

/// Mengatur formasi, mentalitas, 11 starter, dan 7 cadangan. Perubahan
/// langsung disimpan ke save.
class TacticsScreen extends ConsumerStatefulWidget {
  const TacticsScreen({super.key});

  @override
  ConsumerState<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends ConsumerState<TacticsScreen> {
  /// Indeks starter yang sedang dipilih untuk ditukar. Null = tidak ada.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final lineup = ref.watch(lineupProvider);
    final tactic = ref.watch(clubTacticProvider).valueOrNull;
    final state = ref.watch(gameStateProvider).valueOrNull;
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final club = state?.clubId == null ? null : clubs[state!.clubId!];

    return Scaffold(
      appBar: AppBar(title: const Text('Taktik & Lineup')),
      body: lineup.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat skuad: $e')),
        data: (l) {
          final formation = tactic?.formation ?? Formation.f442;
          final mentality = tactic?.mentality ?? Mentality.balanced;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Controls(
                formation: formation,
                mentality: mentality,
                onFormation: (f) => _changeFormation(f),
                onMentality: (m) => _save(
                  formation: formation,
                  mentality: m,
                  starters: l.starters,
                  bench: l.bench,
                ),
                onAuto: () => _auto(formation, mentality),
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 105 / 68,
                child: CustomPaint(
                  painter: Pitch2DPainter(
                    dots: [
                      for (var i = 0; i < l.starters.length; i++)
                        PitchDot(
                          x: formation.slots[i].depth,
                          y: formation.slots[i].lateral,
                          fill: club != null
                              ? colorFromHex(club.primaryColor)
                              : Colors.blue,
                          stroke: club != null
                              ? colorFromHex(club.secondaryColor)
                              : Colors.white,
                          label: '${i + 1}',
                          name: _shortName(l.starters[i]),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selected == null
                    ? 'Ketuk pemain untuk memilih, lalu ketuk pemain lain untuk menukar.'
                    : 'Pilih pemain lain (starter atau cadangan) untuk menukar.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text('Starter', style: Theme.of(context).textTheme.titleMedium),
              for (var i = 0; i < l.starters.length; i++)
                _PlayerRow(
                  leading: formation.slots[i].label,
                  player: l.starters[i],
                  selected: _selected == i,
                  onTap: () => _tapStarter(i, formation, mentality, l),
                ),
              const SizedBox(height: 12),
              Text(
                'Cadangan (${l.bench.length}/${LineupBuilder.benchCount})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (var i = 0; i < l.bench.length; i++)
                _PlayerRow(
                  leading: '${i + 1}',
                  player: l.bench[i],
                  selected: false,
                  onTap: () => _tapBench(i, formation, mentality, l),
                ),
            ],
          );
        },
      ),
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
    if (sel == null) return;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            const Text('Formasi'),
            DropdownButton<Formation>(
              value: formation,
              items: [
                for (final f in Formation.values)
                  DropdownMenuItem(value: f, child: Text(f.label)),
              ],
              onChanged: (f) {
                if (f != null) onFormation(f);
              },
            ),
            FilledButton.tonal(
              onPressed: onAuto,
              child: const Text('Pilih Otomatis (Terbaik)'),
            ),
          ],
        ),
        const SizedBox(height: 8),
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

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.leading,
    required this.player,
    required this.selected,
    required this.onTap,
  });

  final String leading;
  final Player player;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        dense: true,
        onTap: onTap,
        leading: SizedBox(
          width: 40,
          child: Text(leading, textAlign: TextAlign.center),
        ),
        title: Text(player.fullName),
        subtitle: Text(
          '${player.position.label} · Usia ${player.age} · '
          'Kondisi ${player.condition}%',
        ),
        trailing: Text('CA ${player.currentAbility}'),
      ),
    );
  }
}
