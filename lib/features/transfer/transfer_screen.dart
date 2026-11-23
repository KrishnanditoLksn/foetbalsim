import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/utils/date_format.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/transfer_window.dart';
import '../player_search/player_search_view.dart';

/// Pasar transfer: jendela Eropa, cari pemain, shortlist, tawaran, dan
/// aktivitas bursa liga.
class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final now = state?.currentDate ?? DateTime.utc(2025, 7, 1);
    final window = TransferWindow.status(now);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pasar Transfer'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Cari Pemain'),
              Tab(text: 'Shortlist'),
              Tab(text: 'Tawaran'),
              Tab(text: 'Aktivitas Bursa'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Layar penuh',
              icon: const Icon(Icons.open_in_new),
              onPressed:
                  () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.playerSearch),
            ),
          ],
        ),
        body: Column(
          children: [
            _WindowBanner(status: window, now: now),
            const Expanded(
              child: TabBarView(
                children: [
                  PlayerSearchView(),
                  _ShortlistTab(),
                  _OffersTab(),
                  _HistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowBanner extends StatelessWidget {
  const _WindowBanner({required this.status, required this.now});

  final TransferWindowStatus status;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final open = status.isOpen;
    final text =
        open
            ? 'Bursa BUKA · sisa ${status.closesOn!.difference(now).inDays} hari '
                '(tutup ${formatDate(status.closesOn!)})'
            : 'Bursa TUTUP · dibuka kembali ${formatDate(status.nextOpensOn!)}';
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      color:
          open
              ? theme.colorScheme.tertiaryContainer
              : theme.colorScheme.surfaceContainerHighest,
      child: ListTile(
        dense: true,
        leading: Icon(open ? Icons.lock_open : Icons.lock_clock),
        title: Text(text),
        subtitle: const Text(
          'Jendela Eropa: 1 Juli – 31 Agustus dan 1–31 Januari.',
        ),
      ),
    );
  }
}

class _ShortlistTab extends ConsumerWidget {
  const _ShortlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(shortlistProvider);
    final rows = ref.watch(playerSearchRowsProvider);
    return ids.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (set) {
        final list = (rows.valueOrNull ?? const <PlayerSearchRow>[])
            .where((r) => set.contains(r.player.id))
            .toList();
        if (list.isEmpty) {
          return const Center(
            child: Text(
              'Shortlist kosong. Tambahkan pemain dari Cari Pemain.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView(
          children: [
            for (final r in list)
              ListTile(
                onTap:
                    () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.player, arguments: r.player.id),
                title: Text(r.player.fullName),
                subtitle: Text(
                  '${r.player.position.label} · ${r.clubName} · '
                  'CA ${r.player.currentAbility}',
                ),
                trailing: IconButton(
                  tooltip: 'Hapus dari shortlist',
                  icon: const Icon(Icons.bookmark_remove),
                  onPressed:
                      () => GameActions.run(
                        ref,
                        (e) => e.setShortlisted(r.player.id, false),
                      ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OffersTab extends ConsumerWidget {
  const _OffersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(clubOffersProvider);
    final rows = ref.watch(playerSearchRowsProvider).valueOrNull ?? const [];
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final state = ref.watch(gameStateProvider).valueOrNull;
    final ourId = state?.clubId;

    return offers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('Belum ada tawaran.'));
        }
        String nameOf(int playerId) {
          for (final r in rows) {
            if (r.player.id == playerId) return r.player.fullName;
          }
          return 'Pemain #$playerId';
        }

        return ListView(
          children: [
            for (final o in list)
              ListTile(
                title: Text(
                  o.fromClubId == ourId
                      ? 'Tawaran untuk ${nameOf(o.playerId)}'
                      : 'Tawaran masuk: ${nameOf(o.playerId)}',
                ),
                subtitle: Text(
                  '${moneyLabel(o.fee)} · '
                  '${clubs[o.fromClubId == ourId ? o.toClubId : o.fromClubId]?.name ?? '-'} · '
                  '${formatDate(o.createdDate)}',
                ),
                trailing: Chip(
                  label: Text(o.status.label),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(transferHistoryProvider);
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    return history.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Text('Belum ada transfer di liga. Tunggu jendela dibuka.'),
          );
        }
        return ListView(
          children: [
            for (final r in list)
              ListTile(
                title: Text(r.playerName),
                subtitle: Text(
                  '${clubs[r.fromClubId]?.name ?? r.fromClubId} → '
                  '${clubs[r.toClubId]?.name ?? r.toClubId}\n'
                  '${formatDate(r.date)} · ${r.type.label}',
                ),
                isThreeLine: true,
                trailing: Text(moneyLabel(r.fee)),
              ),
          ],
        );
      },
    );
  }
}
