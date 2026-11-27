import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/widgets/club_badge.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../l10n/l10n.dart';

/// Tiga tab: Klub (jadwal tim kita), Klasemen, dan Pekan.
class FixturesScreen extends ConsumerStatefulWidget {
  const FixturesScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends ConsumerState<FixturesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 3,
    vsync: this,
    initialIndex: widget.initialTab,
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(gameStatusProvider).valueOrNull;
    final clubId = status?.clubId;
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('fixtures.title')),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: tr('fixtures.tabClub')),
            Tab(text: tr('fixtures.tabTable')),
            Tab(text: tr('fixtures.tabRound')),
          ],
        ),
      ),
      body:
          clubId == null
              ? Center(child: Text(tr('common.noClub')))
              : TabBarView(
                controller: _tabs,
                children: [
                  _ClubFixtures(clubId: clubId, clubs: clubs),
                  _TableTab(clubId: clubId, clubs: clubs),
                  _RoundTab(clubId: clubId, clubs: clubs),
                ],
              ),
    );
  }
}

String _nameOf(Map<String, Club> clubs, String id) => clubs[id]?.name ?? id;

/// Lencana kecil, atau ruang kosong selama data klub belum termuat.
Widget _badge(Map<String, Club> clubs, String id, double size) {
  final club = clubs[id];
  return club == null
      ? SizedBox(width: size, height: size)
      : ClubBadge(club: club, size: size);
}

class _ClubFixtures extends ConsumerWidget {
  const _ClubFixtures({required this.clubId, required this.clubs});

  final String clubId;
  final Map<String, Club> clubs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtures = ref.watch(clubFixturesProvider(clubId));
    final theme = Theme.of(context);
    return fixtures.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) =>
              Center(child: Text(tr('fixtures.loadFailed', {'error': '$e'}))),
      data:
          (list) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) {
              final f = list[i];
              final home = f.homeClubId == clubId;
              final oppId = home ? f.awayClubId : f.homeClubId;
              final String? result;
              if (f.played) {
                final ours = home ? f.homeGoals! : f.awayGoals!;
                final theirs = home ? f.awayGoals! : f.homeGoals!;
                result =
                    ours > theirs
                        ? 'W'
                        : ours == theirs
                        ? 'D'
                        : 'L';
              } else {
                result = null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${f.round}',
                        style: scoreStyle(size: 18, color: Chalk.dim),
                      ),
                    ),
                    _badge(clubs, oppId, 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameOf(clubs, oppId),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${home ? tr('fixtures.atHome') : tr('fixtures.away')}, '
                            '${formatDateWithDay(f.date)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (result != null) ...[
                      Text(
                        '${f.homeGoals}–${f.awayGoals}',
                        style: scoreStyle(size: 22),
                      ),
                      const SizedBox(width: 10),
                      FormDots([result], size: 20),
                    ],
                  ],
                ),
              );
            },
          ),
    );
  }
}

class _TableTab extends ConsumerWidget {
  const _TableTab({required this.clubId, required this.clubs});

  final String clubId;
  final Map<String, Club> clubs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagueId = clubs[clubId]?.leagueId;
    if (leagueId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final table = ref.watch(leagueTableProvider(leagueId));
    return table.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) =>
              Center(child: Text(tr('fixtures.loadFailed', {'error': '$e'}))),
      data: (rows) {
        final teams = rows.length;
        final tier = leagueId == 'laliga' ? 1 : 2;
        return Column(
          children: [
            const _TableHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: rows.length + 1,
                itemBuilder: (context, i) {
                  if (i == rows.length) return _ZoneLegend(tier: tier);
                  return _TableRowView(
                    pos: i + 1,
                    row: rows[i],
                    club: clubs[rows[i].clubId],
                    ours: rows[i].clubId == clubId,
                    zone: zoneColor(i + 1, teams, tier),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Zona warna: LaLiga (1–4 UCL cyan, 5–6 Eropa amber, 3 terbawah merah);
  /// Hypermotion (1–2 promosi hijau, 3–6 playoff hijau pudar, 4 terbawah
  /// merah).
  static Color? zoneColor(int pos, int teams, int tier) {
    if (tier == 1) {
      if (pos <= 4) return FutbolColors.cyan;
      if (pos <= 6) return FutbolColors.amber;
      if (pos > teams - 3) return FutbolColors.coral;
    } else {
      if (pos <= 2) return FutbolColors.emerald;
      if (pos <= 6) return FutbolColors.emerald.withValues(alpha: 0.5);
      if (pos > teams - 4) return FutbolColors.coral;
    }
    return null;
  }
}

/// Lebar kolom klasemen (dipakai header dan baris agar sejajar).
const double _colNum = 26;
const double _colPts = 34;
const double _colPos = 22;

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Chalk.dim,
    );
    Widget num(String t, double w) => SizedBox(
      width: w,
      child: Text(t, textAlign: TextAlign.center, style: style),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 12, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: _colPos, child: Text('#', style: style)),
          const SizedBox(width: 30),
          Expanded(child: Text(tr('fixtures.club'), style: style)),
          Tooltip(
            message: tr('fixtures.played'),
            child: num(tr('fixtures.playedShort'), _colNum + 6),
          ),
          Tooltip(
            message: tr('fixtures.won'),
            child: num(tr('fixtures.wonShort'), _colNum),
          ),
          Tooltip(
            message: tr('fixtures.drawn'),
            child: num(tr('fixtures.drawnShort'), _colNum),
          ),
          Tooltip(
            message: tr('fixtures.lost'),
            child: num(tr('fixtures.lostShort'), _colNum),
          ),
          Tooltip(
            message: tr('fixtures.goalDiff'),
            child: num(tr('fixtures.goalDiffShort'), _colNum + 4),
          ),
          Tooltip(
            message: tr('fixtures.points'),
            child: num(tr('fixtures.pointsShort'), _colPts),
          ),
        ],
      ),
    );
  }
}

class _TableRowView extends StatelessWidget {
  const _TableRowView({
    required this.pos,
    required this.row,
    required this.club,
    required this.ours,
    required this.zone,
  });

  final int pos;
  final LeagueTableRow row;
  final Club? club;
  final bool ours;
  final Color? zone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numStyle = scoreStyle(size: 17, weight: FontWeight.w500);
    Widget num(String t, double w, {TextStyle? style}) => SizedBox(
      width: w,
      child: Text(t, textAlign: TextAlign.center, style: style ?? numStyle),
    );
    final sg = row.goalDiff > 0 ? '+${row.goalDiff}' : '${row.goalDiff}';

    return Container(
      decoration: BoxDecoration(
        color: ours ? theme.colorScheme.primary.withValues(alpha: 0.14) : null,
        border: Border(
          left: BorderSide(color: zone ?? Colors.transparent, width: 3),
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
      child: Row(
        children: [
          SizedBox(
            width: _colPos,
            child: Text(
              '$pos',
              style: scoreStyle(size: 17, color: zone ?? Chalk.dim),
            ),
          ),
          SizedBox(
            width: 30,
            child: Align(
              alignment: Alignment.centerLeft,
              child:
                  club == null
                      ? const SizedBox(width: 22)
                      : ClubBadge(club: club!, size: 22),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club?.name ?? row.clubId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: ours ? FontWeight.w700 : FontWeight.w500,
                    color: ours ? theme.colorScheme.primary : null,
                  ),
                ),
                if (row.form.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  FormDots(row.form, size: 9),
                ],
              ],
            ),
          ),
          num('${row.played}', _colNum + 6),
          num('${row.won}', _colNum),
          num('${row.drawn}', _colNum),
          num('${row.lost}', _colNum),
          num(sg, _colNum + 4),
          num('${row.points}', _colPts, style: scoreStyle(size: 19)),
        ],
      ),
    );
  }
}

class _ZoneLegend extends StatelessWidget {
  const _ZoneLegend({required this.tier});

  final int tier;

  @override
  Widget build(BuildContext context) {
    final items =
        tier == 1
            ? [
              (FutbolColors.cyan, tr('fixtures.ucl')),
              (FutbolColors.amber, tr('fixtures.uel')),
              (FutbolColors.coral, tr('fixtures.relegation')),
            ]
            : [
              (FutbolColors.emerald, tr('fixtures.promotion')),
              (
                FutbolColors.emerald.withValues(alpha: 0.5),
                tr('fixtures.playoff'),
              ),
              (FutbolColors.coral, tr('fixtures.relegation')),
            ];
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          for (final (color, label) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, color: color),
                const SizedBox(width: 6),
                Text(label, style: style),
              ],
            ),
          Text(tr('fixtures.legend'), style: style),
        ],
      ),
    );
  }
}

class _RoundTab extends ConsumerStatefulWidget {
  const _RoundTab({required this.clubId, required this.clubs});

  final String clubId;
  final Map<String, Club> clubs;

  @override
  ConsumerState<_RoundTab> createState() => _RoundTabState();
}

class _RoundTabState extends ConsumerState<_RoundTab> {
  int? _round; // null = pekan terdekat yang belum selesai

  @override
  Widget build(BuildContext context) {
    final leagueId = widget.clubs[widget.clubId]?.leagueId;
    if (leagueId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);
    final fixtures = ref.watch(leagueFixturesProvider(leagueId));
    return fixtures.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) =>
              Center(child: Text(tr('fixtures.loadFailed', {'error': '$e'}))),
      data: (list) {
        final maxRound = list.isEmpty ? 1 : list.last.round;
        final current =
            list.where((f) => !f.played).firstOrNull?.round ?? maxRound;
        final round = (_round ?? current).clamp(1, maxRound);
        final roundFixtures = list.where((f) => f.round == round).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        round > 1
                            ? () => setState(() => _round = round - 1)
                            : null,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          tr('fixtures.roundOf', {'n': round, 'max': maxRound}),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (roundFixtures.isNotEmpty)
                          Text(
                            formatDateWithDay(roundFixtures.first.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        round < maxRound
                            ? () => setState(() => _round = round + 1)
                            : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  const Divider(),
                  for (final f in roundFixtures) ...[
                    _RoundMatch(
                      fixture: f,
                      clubs: widget.clubs,
                      ours: f.involves(widget.clubId),
                    ),
                    const Divider(),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RoundMatch extends StatelessWidget {
  const _RoundMatch({
    required this.fixture,
    required this.clubs,
    required this.ours,
  });

  final Fixture fixture;
  final Map<String, Club> clubs;
  final bool ours;

  @override
  Widget build(BuildContext context) {
    final f = fixture;
    final nameStyle = TextStyle(
      fontWeight: ours ? FontWeight.w700 : FontWeight.w500,
      fontSize: 14,
      color: ours ? Theme.of(context).colorScheme.primary : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    _nameOf(clubs, f.homeClubId),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: nameStyle,
                  ),
                ),
                const SizedBox(width: 8),
                _badge(clubs, f.homeClubId, 24),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              f.played ? '${f.homeGoals}–${f.awayGoals}' : '–',
              textAlign: TextAlign.center,
              style: scoreStyle(
                size: 22,
                color: f.played ? Chalk.white : Chalk.dim,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _badge(clubs, f.awayClubId, 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _nameOf(clubs, f.awayClubId),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: nameStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lencana kecil untuk klub (dipakai bila layar membutuhkan logo ringkas).
class SmallClubBadge extends StatelessWidget {
  const SmallClubBadge({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) => ClubBadge(club: club, size: 28);
}
