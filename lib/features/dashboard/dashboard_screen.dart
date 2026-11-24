import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/club_badge.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../data/services/game_engine.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/season/season_calendar.dart';
import '../match/match_screen.dart';
import '../shell/main_shell_screen.dart';

const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

/// Beranda: kepala berwarna klub, angka penting, laga berikutnya, kabar
/// terbaru, dan satu tombol aksi di bawah.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(gameStatusProvider);
    final busy = ref.watch(engineBusyProvider);

    return statusAsync.when(
      skipLoadingOnReload: true,
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
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _ClubHeader(club: club, date: s.date),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (club != null) _Numbers(club: club),
                    const _DayNotes(),
                    _NextMatch(status: s, clubId: clubId),
                    const _LatestNews(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _ActionBar(status: s, busy: busy),
        );
      },
    );
  }
}

/// Kepala Beranda dalam warna utama klub, dengan garis warna kedua di
/// bawahnya seperti kerah kaus.
class _ClubHeader extends StatelessWidget {
  const _ClubHeader({required this.club, required this.date});

  final Club? club;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final primary =
        club == null ? Chalk.boardRaised : colorFromHex(club!.primaryColor);
    final secondary =
        club == null ? Chalk.line : colorFromHex(club!.secondaryColor);
    final ink = AppTheme.onColor(primary);
    final top = MediaQuery.paddingOf(context).top;

    // Ikon status bar mengikuti terang/gelapnya warna klub.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          ink == Chalk.white
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
      child: Column(
        children: [
          Container(
            color: primary,
            padding: EdgeInsets.fromLTRB(20, top + 8, 8, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_days[date.weekday - 1]}, ${formatDate(date)}',
                        style: TextStyle(
                          color: ink.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        club?.name ?? 'Karier',
                        style: TextStyle(
                          fontFamily: Fonts.condensed,
                          fontSize: 40,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Musim ${SeasonCalendar.label(SeasonCalendar.firstSeasonYear)}',
                        style: TextStyle(color: ink.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Kembali ke menu awal',
                  color: ink,
                  icon: const Icon(Icons.logout_rounded),
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(AppRoutes.start, (_) => false),
                ),
              ],
            ),
          ),
          Container(height: 5, color: secondary),
        ],
      ),
    );
  }
}

/// Posisi liga, saldo, dan lima hasil terakhir.
class _Numbers extends ConsumerWidget {
  const _Numbers({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final table = ref.watch(leagueTableProvider(club.leagueId)).valueOrNull;
    final idx = table?.indexWhere((r) => r.clubId == club.id) ?? -1;
    final row = idx < 0 ? null : table![idx];
    final started = (row?.played ?? 0) > 0;

    return StatStrip(
      children: [
        StatFigure(
          label: table == null ? 'Posisi liga' : 'dari ${table.length} tim',
          value: started ? '${idx + 1}' : '–',
          color: Theme.of(context).colorScheme.primary,
        ),
        StatFigure(label: 'Saldo klub', value: formatMoney(club.balance)),
        StatFigure(
          label: '5 laga terakhir',
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: FormDots(row?.form ?? const [], showEmpty: 5),
          ),
        ),
      ],
    );
  }
}

/// Catatan hari terakhir yang dilewati LANJUTKAN.
class _DayNotes extends ConsumerWidget {
  const _DayNotes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(lastDayReportProvider);
    if (report == null || !report.advanced) return const SizedBox.shrink();
    final notes = report.notes.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('Kemarin di klub (${formatDate(report.date)})'),
        if (notes.isEmpty)
          const Text(
            'Hari yang tenang, tidak ada kejadian penting.',
            style: TextStyle(color: Chalk.dim),
          )
        else
          for (final n in notes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 9, right: 10),
                    child: SizedBox(
                      width: 8,
                      height: 2,
                      child: ColoredBox(color: Chalk.dim),
                    ),
                  ),
                  Expanded(child: Text(n)),
                ],
              ),
            ),
      ],
    );
  }
}

/// Papan laga berikutnya: dua klub ditulis bersusun seperti di papan
/// pertandingan, tanggal dan jarak hari di kanan.
class _NextMatch extends ConsumerWidget {
  const _NextMatch({required this.status, required this.clubId});

  final GameStatus status;
  final String? clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = status.todayFixture ?? status.nextFixture;
    if (f == null || clubId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader('Laga berikutnya'),
          Text(
            status.seasonOver
                ? 'Musim sudah selesai.'
                : 'Belum ada laga terjadwal.',
            style: const TextStyle(color: Chalk.dim),
          ),
        ],
      );
    }

    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final isToday = status.todayFixture != null;
    final days = f.date.difference(status.date).inDays;
    final when =
        isToday
            ? 'Hari ini'
            : days == 1
            ? 'Besok'
            : '$days hari lagi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(isToday ? 'Hari ini ada laga' : 'Laga berikutnya'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Chalk.boardRaised,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: isToday ? Chalk.yellow : Chalk.line,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TeamLine(
                      club: clubs[f.homeClubId],
                      fallback: f.homeClubId,
                      ours: f.homeClubId == clubId,
                      note: 'kandang',
                    ),
                    const SizedBox(height: 10),
                    _TeamLine(
                      club: clubs[f.awayClubId],
                      fallback: f.awayClubId,
                      ours: f.awayClubId == clubId,
                      note: 'tandang',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Kolom kanan dibatasi agar nama klub tetap punya ruang.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 104),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        when,
                        style: scoreStyle(
                          size: 24,
                          color: isToday ? Chalk.yellow : Chalk.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatDateWithDay(f.date),
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Chalk.dim, fontSize: 13),
                    ),
                    Text(
                      'Pekan ${f.round}',
                      style: const TextStyle(color: Chalk.dim, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamLine extends StatelessWidget {
  const _TeamLine({
    required this.club,
    required this.fallback,
    required this.ours,
    required this.note,
  });

  final Club? club;
  final String fallback;
  final bool ours;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (club != null)
          ClubBadge(club: club!, size: 30)
        else
          const SizedBox(width: 26),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            club?.name ?? fallback,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Fonts.condensed,
              fontSize: 24,
              height: 1,
              fontWeight: ours ? FontWeight.w700 : FontWeight.w500,
              color: ours ? Chalk.white : Chalk.dim,
            ),
          ),
        ),
        if (ours) ...[
          const SizedBox(width: 8),
          Text(note, style: const TextStyle(color: Chalk.dim, fontSize: 13)),
        ],
      ],
    );
  }
}

/// Tiga kabar terbaru; yang menunggu keputusan didahulukan.
class _LatestNews extends ConsumerWidget {
  const _LatestNews();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(inboxProvider).valueOrNull;
    if (list == null || list.isEmpty) return const SizedBox.shrink();
    final sorted = [...list]..sort((a, b) {
      final c = (b.needsAction ? 1 : 0).compareTo(a.needsAction ? 1 : 0);
      if (c != 0) return c;
      return b.date.compareTo(a.date);
    });
    void openInbox() =>
        ref.read(shellTabProvider.notifier).state = ShellTab.inbox;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          'Kabar terbaru',
          trailing: TextButton(
            onPressed: openInbox,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Buka inbox'),
          ),
        ),
        for (final m in sorted.take(3)) ...[
          _NewsRow(message: m, onTap: openInbox),
          const Divider(),
        ],
      ],
    );
  }
}

class _NewsRow extends StatelessWidget {
  const _NewsRow({required this.message, required this.onTap});

  final InboxMessage message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = message;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: TextStyle(
                      fontWeight: m.isRead ? FontWeight.w400 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.needsAction
                        ? 'Menunggu keputusan Anda'
                        : '${m.category.label}, ${formatDate(m.date)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: m.needsAction ? Chalk.red : Chalk.dim,
                      fontWeight:
                          m.needsAction ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (!m.isRead)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 8),
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Chalk.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tombol aksi utama, selalu terlihat di bawah layar.
class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.status, required this.busy});

  final GameStatus status;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = status.pendingActions.length;

    final Widget button;
    if (pending > 0) {
      button = FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Chalk.red,
          foregroundColor: Chalk.boardDeep,
        ),
        onPressed:
            () => ref.read(shellTabProvider.notifier).state = ShellTab.inbox,
        child: Text(
          pending == 1
              ? 'Ambil 1 keputusan di inbox'
              : 'Ambil $pending keputusan di inbox',
        ),
      );
    } else if (status.todayFixture != null) {
      button = FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Chalk.yellow,
          foregroundColor: Chalk.boardDeep,
        ),
        onPressed: busy ? null : () => _playMatch(context, ref),
        child: const Text('Mainkan laga'),
      );
    } else if (status.seasonOver) {
      button = const FilledButton(
        onPressed: null,
        child: Text('Musim selesai'),
      );
    } else {
      button = FilledButton(
        onPressed: busy ? null : () => _continue(context, ref),
        child:
            busy
                ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text('Lanjutkan ke hari berikutnya'),
      );
    }

    return Container(
      color: Chalk.board,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: SizedBox(height: 50, width: double.infinity, child: button),
    );
  }

  /// LANJUTKAN = tepat satu hari. Alasan berhenti ditampilkan bila tanggal
  /// tidak berubah; ringkasan hari muncul di bagian "Kemarin di klub".
  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final report = await GameActions.advanceDay(ref);
    if (report == null || !context.mounted) return;
    if (report.advanced) return;
    final reason = switch (report.stop) {
      ContinueStop.blockingAction => 'Ada keputusan yang perlu Anda ambil.',
      ContinueStop.matchDay => 'Hari ini tim Anda bertanding.',
      ContinueStop.seasonOver => 'Musim sudah selesai.',
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
            title: const Text('Hasil laga'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ours.homeName,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${ours.homeGoals}–${ours.awayGoals}',
                          style: scoreStyle(size: 34),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          ours.awayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Laga lain hari ini',
                    style: TextStyle(
                      fontFamily: Fonts.condensed,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(color: Chalk.dim),
                  if (res.others.isEmpty)
                    const Text(
                      'Tidak ada laga lain.',
                      style: TextStyle(color: Chalk.dim),
                    ),
                  for (final o in res.others)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              o.homeName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          SizedBox(
                            width: 52,
                            child: Text(
                              '${o.homeGoals}–${o.awayGoals}',
                              textAlign: TextAlign.center,
                              style: scoreStyle(size: 18),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              o.awayName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
    );
  }
}
