import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/utils/date_format.dart';
import '../../domain/season/season_calendar.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/club_badge.dart';
import '../../data/services/game_engine.dart';
import '../../domain/models/game_models.dart';
import '../match/match_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(gameStatusProvider);
    final busy = ref.watch(engineBusyProvider);

    return statusAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (s) {
        final clubId = s.clubId;
        final club =
            clubId == null
                ? null
                : ref.watch(clubByIdProvider(clubId)).valueOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(club?.name ?? 'Dashboard'),
            actions: [
              if (club != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClubBadge(club: club, size: 36),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    title: Text(
                      '${formatDateWithDay(s.date)} · Musim ${SeasonCalendar.label(SeasonCalendar.firstSeasonYear)}',
                    ),
                    subtitle: Text(
                      club == null
                          ? '-'
                          : 'Saldo ${formatMoney(club.balance)} · '
                              'Posisi liga: ${_leaguePosition(ref, club)}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const _DayCard(),
                const SizedBox(height: 12),
                _NextMatchCard(status: s, clubId: clubId),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      _MenuTile(
                        label: 'Inbox',
                        icon: Icons.inbox,
                        badge: s.pendingActions.length,
                        onTap:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.inbox),
                      ),
                      _MenuTile(
                        label: 'Skuad',
                        icon: Icons.groups,
                        onTap:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.squad),
                      ),
                      _MenuTile(
                        label: 'Jadwal',
                        icon: Icons.calendar_month,
                        onTap:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.fixtures),
                      ),
                      _MenuTile(
                        label: 'Klasemen',
                        icon: Icons.emoji_events,
                        onTap:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.fixtures),
                      ),
                      _MenuTile(
                        label: 'Taktik',
                        icon: Icons.tune,
                        onTap:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.tactics),
                      ),
                      _MenuTile(
                        label: 'Transfer',
                        icon: Icons.swap_horiz,
                        onTap:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.transfer),
                      ),
                      for (final label in const ['Latihan', 'Klub'])
                        _MenuTile(
                          label: label,
                          icon: Icons.construction,
                          onTap:
                              () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$label akan hadir di fase berikutnya.',
                                  ),
                                ),
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ActionButton(status: s, busy: busy),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _leaguePosition(WidgetRef ref, Club club) {
    final table = ref.watch(leagueTableProvider(club.leagueId)).valueOrNull;
    if (table == null) return '-';
    final idx = table.indexWhere((r) => r.clubId == club.id);
    return idx < 0 ? '-' : '${idx + 1}';
  }
}

/// Kartu "Hari Ini": ringkasan hari terakhir yang dilewati LANJUTKAN.
class _DayCard extends ConsumerWidget {
  const _DayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(lastDayReportProvider);
    if (report == null) return const SizedBox.shrink();
    final notes = report.notes.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.advanced
                  ? 'Hari Ini · ${formatDate(report.date)}'
                  : 'Tidak ada hari baru',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            if (notes.isEmpty)
              const Text('Tidak ada kejadian penting.')
            else
              for (final n in notes) Text('• $n'),
          ],
        ),
      ),
    );
  }
}

class _NextMatchCard extends ConsumerWidget {
  const _NextMatchCard({required this.status, required this.clubId});

  final GameStatus status;
  final String? clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = status.todayFixture ?? status.nextFixture;
    if (f == null || clubId == null) {
      return Card(
        child: ListTile(
          title: Text(
            status.seasonOver ? 'Musim selesai' : 'Tidak ada laga terdekat',
          ),
        ),
      );
    }
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final home = f.homeClubId == clubId;
    final oppId = home ? f.awayClubId : f.homeClubId;
    final opp = clubs[oppId]?.name ?? oppId;
    final isToday = status.todayFixture != null;

    return Card(
      color: isToday ? Theme.of(context).colorScheme.tertiaryContainer : null,
      child: ListTile(
        leading: Icon(isToday ? Icons.sports_soccer : Icons.event),
        title: Text(isToday ? 'HARI INI: vs $opp' : 'Laga berikutnya: vs $opp'),
        subtitle: Text(
          '${home ? 'Kandang' : 'Tandang'} · ${formatDateWithDay(f.date)} · Pekan ${f.round}',
        ),
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({required this.status, required this.busy});

  final GameStatus status;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = status.pendingActions.length;

    if (pending > 0) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.inbox),
        child: Text('TINDAKAN DIPERLUKAN ($pending)'),
      );
    }
    if (status.todayFixture != null) {
      return FilledButton(
        onPressed: busy ? null : () => _playMatch(context, ref),
        child: const Text('MAINKAN LAGA'),
      );
    }
    if (status.seasonOver) {
      return const FilledButton(onPressed: null, child: Text('MUSIM SELESAI'));
    }
    return FilledButton(
      onPressed: busy ? null : () => _continue(context, ref),
      child: const Text('LANJUTKAN'),
    );
  }

  /// LANJUTKAN = tepat satu hari. Alasan berhenti ditampilkan bila tanggal
  /// tidak berubah; ringkasan hari ditampilkan di kartu "Hari Ini".
  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final report = await GameActions.advanceDay(ref);
    if (report == null || !context.mounted) return;
    if (report.advanced) return;
    final reason = switch (report.stop) {
      ContinueStop.blockingAction => 'Ada keputusan yang perlu Anda ambil.',
      ContinueStop.matchDay => 'Hari pertandingan tim Anda.',
      ContinueStop.seasonOver => 'Musim selesai.',
      ContinueStop.dayLimit || null => '',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reason)));
  }

  Future<void> _playMatch(BuildContext context, WidgetRef ref) async {
    final res = await Navigator.of(context).push<MatchDayResult>(
      MaterialPageRoute(builder: (_) => const MatchScreen()),
    );
    if (res == null || !context.mounted) return;
    final ours = res.ours;
    await showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hasil Laga'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${ours.homeName}  ${ours.homeGoals} - ${ours.awayGoals}  ${ours.awayName}',
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const Divider(height: 24),
                  Text(
                    'Laga lain hari ini',
                    style: Theme.of(ctx).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (res.others.isEmpty) const Text('Tidak ada laga lain.'),
                  for (final o in res.others)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${o.homeName} ${o.homeGoals}-${o.awayGoals} ${o.awayName}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Lanjut'),
              ),
            ],
          ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badge > 0,
                label: Text('$badge'),
                child: Icon(icon, size: 28),
              ),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
