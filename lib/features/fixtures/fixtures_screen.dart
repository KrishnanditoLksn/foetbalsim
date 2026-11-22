import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/club_badge.dart';
import '../../domain/models/game_models.dart';

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
        title: const Text('Jadwal & Klasemen'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Klub'),
            Tab(text: 'Klasemen'),
            Tab(text: 'Pekan'),
          ],
        ),
      ),
      body:
          clubId == null
              ? const Center(child: Text('Belum ada klub.'))
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

class _ClubFixtures extends ConsumerWidget {
  const _ClubFixtures({required this.clubId, required this.clubs});

  final String clubId;
  final Map<String, Club> clubs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtures = ref.watch(clubFixturesProvider(clubId));
    return fixtures.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat jadwal: $e')),
      data:
          (list) => ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final f = list[i];
              final home = f.homeClubId == clubId;
              final opp = _nameOf(clubs, home ? f.awayClubId : f.homeClubId);
              final score =
                  f.played
                      ? '${f.homeGoals} - ${f.awayGoals}'
                      : formatDate(f.date);
              return ListTile(
                leading: Text('P${f.round}'),
                title: Text('${home ? 'vs' : '@'} $opp'),
                subtitle: Text(
                  '${home ? 'Kandang' : 'Tandang'} · ${formatDate(f.date)}',
                ),
                trailing: Text(
                  score,
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat klasemen: $e')),
      data: (rows) {
        final teams = rows.length;
        final tier = clubs[clubId]!.leagueId == 'laliga' ? 1 : 2;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 14,
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Klub')),
                DataColumn(label: Text('M'), numeric: true),
                DataColumn(label: Text('M'), numeric: true),
                DataColumn(label: Text('S'), numeric: true),
                DataColumn(label: Text('K'), numeric: true),
                DataColumn(label: Text('GM'), numeric: true),
                DataColumn(label: Text('GK'), numeric: true),
                DataColumn(label: Text('SG'), numeric: true),
                DataColumn(label: Text('Poin'), numeric: true),
                DataColumn(label: Text('Form')),
              ],
              rows: [
                for (var i = 0; i < rows.length; i++)
                  DataRow(
                    color: WidgetStatePropertyAll(
                      _zoneColor(
                        context,
                        i + 1,
                        teams,
                        tier,
                        rows[i].clubId == clubId,
                      ),
                    ),
                    cells: [
                      DataCell(Text('${i + 1}')),
                      DataCell(
                        Text(
                          _nameOf(clubs, rows[i].clubId),
                          style: TextStyle(
                            fontWeight:
                                rows[i].clubId == clubId
                                    ? FontWeight.w800
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                      DataCell(Text('${rows[i].played}')),
                      DataCell(Text('${rows[i].won}')),
                      DataCell(Text('${rows[i].drawn}')),
                      DataCell(Text('${rows[i].lost}')),
                      DataCell(Text('${rows[i].goalsFor}')),
                      DataCell(Text('${rows[i].goalsAgainst}')),
                      DataCell(Text('${rows[i].goalDiff}')),
                      DataCell(Text('${rows[i].points}')),
                      DataCell(Text(rows[i].form.join(' '))),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Zona warna: LaLiga (1–4 UCL biru, 5–6 Eropa oranye, 3 terbawah merah);
  /// Hypermotion (1–2 promosi hijau, 3–6 playoff hijau muda, 4 terbawah merah).
  static Color? _zoneColor(
    BuildContext context,
    int pos,
    int teams,
    int tier,
    bool isOurClub,
  ) {
    final scheme = Theme.of(context).colorScheme;
    if (isOurClub) return scheme.primaryContainer;
    if (tier == 1) {
      if (pos <= 4) return Colors.blue.withValues(alpha: 0.12);
      if (pos <= 6) return Colors.orange.withValues(alpha: 0.12);
      if (pos > teams - 3) return Colors.red.withValues(alpha: 0.12);
    } else {
      if (pos <= 2) return Colors.green.withValues(alpha: 0.18);
      if (pos <= 6) return Colors.lightGreen.withValues(alpha: 0.15);
      if (pos > teams - 4) return Colors.red.withValues(alpha: 0.12);
    }
    return null;
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
  int _round = 1;

  @override
  Widget build(BuildContext context) {
    final leagueId = widget.clubs[widget.clubId]?.leagueId;
    if (leagueId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final fixtures = ref.watch(leagueFixturesProvider(leagueId));
    return fixtures.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat pekan: $e')),
      data: (list) {
        final maxRound = list.isEmpty ? 1 : list.last.round;
        final roundFixtures = list.where((f) => f.round == _round).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        _round > 1 ? () => setState(() => _round--) : null,
                  ),
                  Expanded(
                    child: Text(
                      'Pekan $_round dari $maxRound',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        _round < maxRound
                            ? () => setState(() => _round++)
                            : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final f in roundFixtures)
                    ListTile(
                      dense: true,
                      title: Text(
                        '${_nameOf(widget.clubs, f.homeClubId)}  '
                        '${f.played ? '${f.homeGoals} - ${f.awayGoals}' : 'vs'}  '
                        '${_nameOf(widget.clubs, f.awayClubId)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight:
                              f.involves(widget.clubId)
                                  ? FontWeight.w800
                                  : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        formatDate(f.date),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
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
