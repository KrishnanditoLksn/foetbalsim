import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../data/database/app_database.dart' show NegotiationSessionRow;
import '../../domain/finance/money_label.dart';
import '../../domain/generators/world_generator.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/agent_negotiator.dart';
import '../../domain/transfer/transfer_rules.dart';
import '../../domain/transfer/transfer_window.dart';
import '../player_search/player_search_view.dart';
import 'transfer_flow.dart';

/// Pasar transfer (README_FASE3 bagian D): Bursa Hari Ini, Cari Pemain,
/// Shortlist, Negosiasi, dan Riwayat.
class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key, this.initialTab = 0});

  /// Indeks tab awal (3 = Negosiasi).
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final now = state?.currentDate ?? WorldGenerator.seasonStart;
    final window = TransferWindow.status(now);
    final offers = ref.watch(clubOffersProvider).valueOrNull ?? const [];
    final active = offers.where((o) => o.isActive).length;

    return DefaultTabController(
      length: 5,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pasar Transfer'),
          bottom: TabBar(
            isScrollable: true,
            // Tanpa celah awal bawaan Material 3 untuk tab yang bisa digeser.
            tabAlignment: TabAlignment.start,
            tabs: [
              const Tab(text: 'Bursa Hari Ini'),
              const Tab(text: 'Cari Pemain'),
              const Tab(text: 'Shortlist'),
              Tab(text: active == 0 ? 'Negosiasi' : 'Negosiasi ($active)'),
              const Tab(text: 'Riwayat'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Cari pemain layar penuh',
              icon: const Icon(Icons.open_in_new),
              onPressed:
                  () => Navigator.of(context).pushNamed(AppRoutes.playerSearch),
            ),
          ],
        ),
        body: Column(
          children: [
            _WindowBanner(status: window, now: now),
            const Expanded(
              child: TabBarView(
                children: [
                  _MarketTab(),
                  PlayerSearchView(),
                  _ShortlistTab(),
                  _NegotiationTab(),
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

  static const _rules =
      'Jendela Eropa: 1 Juli – 31 Agustus dan 1–31 Januari.\n'
      'Maks ${TransferRules.maxMovesPerWindow} masuk & '
      '${TransferRules.maxMovesPerWindow} keluar per jendela.\n'
      'Skuad ${TransferRules.minSquad}–${TransferRules.maxSquad} pemain.\n'
      'Tawar-menawar dengan agen pemain di Ruang Negosiasi. Bila agen '
      'walk-out, pemain baru bisa ditawar lagi seminggu kemudian.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final open = status.isOpen;
    final deadline = TransferWindow.isDeadlineDay(now);
    final color =
        deadline
            ? Chalk.red
            : open
            ? Chalk.green
            : theme.colorScheme.onSurfaceVariant;
    final daysLeft = open ? status.closesOn!.difference(now).inDays : 0;
    final title =
        deadline
            ? 'Hari terakhir bursa transfer'
            : open
            ? 'Bursa buka, $daysLeft hari lagi'
            : 'Bursa transfer tutup';
    final detail =
        open
            ? 'Tutup ${formatDate(status.closesOn!)}'
            : 'Buka lagi ${formatDate(status.nextOpensOn!)}';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                Text(detail, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ketentuan transfer',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.info_outline, size: 18),
            onPressed:
                () => showDialog<void>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Ketentuan transfer'),
                        content: const Text(_rules),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                ),
          ),
        ],
      ),
    );
  }
}

/// Berita bursa: rumor, transfer AI, tawaran pemain, dan info deadline.
class _MarketTab extends ConsumerWidget {
  const _MarketTab();

  static IconData _iconOf(String kind) => switch (kind) {
    'deal' => Icons.swap_horiz,
    'rumour' => Icons.record_voice_over,
    'offer' => Icons.local_offer,
    'deadline' => Icons.alarm,
    _ => Icons.article,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(transferNewsProvider);
    final now = ref.watch(gameStateProvider).valueOrNull?.currentDate;
    return news.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada berita bursa. Rumor dan transfer muncul setiap hari '
                'selama jendela transfer buka.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final items = <Widget>[];
        DateTime? day;
        for (final n in list) {
          if (n.date != day) {
            day = n.date;
            items.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  n.date == now ? 'Hari ini' : formatDate(n.date),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            );
          }
          items.add(
            ListTile(
              dense: true,
              leading: Icon(_iconOf(n.kind)),
              title: Text(n.body),
            ),
          );
        }
        return ListView(children: items);
      },
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
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (set) {
        final list =
            (rows.valueOrNull ?? const <PlayerSearchRow>[])
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
                  'CA ${r.player.currentAbility} · '
                  '${moneyLabel(r.player.marketValue)}',
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

/// Semua negosiasi klub kita: yang berjalan (dengan tombol aksi sesuai
/// ronde) dan yang sudah selesai (dengan alasan bila gagal).
class _NegotiationTab extends ConsumerWidget {
  const _NegotiationTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(clubOffersProvider);
    final rows = ref.watch(playerSearchRowsProvider).valueOrNull ?? const [];
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final ourId = ref.watch(gameStateProvider).valueOrNull?.clubId;
    final sessions =
        ref.watch(activeNegotiationsProvider).valueOrNull ?? const {};
    final names = {for (final r in rows) r.player.id: r.player.fullName};

    return offers.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty || ourId == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada negosiasi. Ajukan tawaran dari detail pemain saat '
                'jendela transfer buka.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final active = list.where((o) => o.isActive).toList();
        final done = list.where((o) => !o.isActive).take(30).toList();

        Widget card(TransferOffer o) {
          final incoming = o.toClubId == ourId;
          final other =
              clubs[incoming ? o.fromClubId : o.toClubId]?.name ?? '-';
          final name = names[o.playerId] ?? 'Pemain #${o.playerId}';
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        incoming ? Icons.call_received : Icons.call_made,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap:
                              () => Navigator.of(context).pushNamed(
                                AppRoutes.player,
                                arguments: o.playerId,
                              ),
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                      StatusBadge(
                        offerStatusLabel(o, ourId),
                        color: offerStatusColor(o.status),
                      ),
                    ],
                  ),
                  Text(
                    '${incoming ? 'Tawaran dari' : 'Ke'} $other · '
                    '${formatDate(o.createdDate)}',
                  ),
                  Text(offerSummary(o)),
                  if (o.reason != null)
                    Text(
                      o.reason!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (o.isActive && sessions[o.id] != null)
                    _SessionLine(session: sessions[o.id]!),
                  if (o.isActive) ...[
                    const SizedBox(height: 4),
                    OfferActions(
                      offer: o,
                      ourClubId: ourId,
                      playerName: name,
                      session: sessions[o.id],
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            _SectionTitle('Berjalan (${active.length})'),
            if (active.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Tidak ada negosiasi berjalan.'),
              ),
            for (final o in active) card(o),
            if (done.isNotEmpty) _SectionTitle('Selesai (${done.length})'),
            for (final o in done) card(o),
          ],
        );
      },
    );
  }
}

/// Status sesi Ruang Negosiasi yang ditinggal: apa yang dirundingkan dan
/// sisa kesabaran agen.
class _SessionLine extends StatelessWidget {
  const _SessionLine({required this.session});

  final NegotiationSessionRow session;

  @override
  Widget build(BuildContext context) {
    final patience = session.patience;
    final color = switch (AgentNegotiator.levelOf(patience)) {
      PatienceLevel.open => Chalk.green,
      PatienceLevel.impatient => Chalk.yellow,
      _ => Chalk.red,
    };
    final subject =
        session.mode == NegotiationMode.contract.name ? 'kontrak' : 'harga';
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Tawar-menawar $subject berjalan, kesabaran agen $patience%',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(transferHistoryProvider);
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    return history.when(
      skipLoadingOnReload: true,
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
