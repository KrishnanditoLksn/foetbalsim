import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/enums/inbox.dart';
import '../../app/router.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_models.dart';
import '../../l10n/l10n.dart';
import '../transfer/transfer_flow.dart';

enum _InboxFilter { all, action, unread }

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  _InboxFilter _filter = _InboxFilter.all;

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(inboxProvider);
    return Scaffold(
      appBar: AppBar(title: Text(tr('nav.inbox'))),
      body: inbox.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) =>
                Center(child: Text(tr('inbox.loadFailed', {'error': '$e'}))),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(tr('inbox.empty')));
          }
          final action = list.where((m) => m.needsAction).length;
          final unread = list.where((m) => !m.isRead).length;
          final shown = switch (_filter) {
            _InboxFilter.all => list,
            _InboxFilter.action => list.where((m) => m.needsAction).toList(),
            _InboxFilter.unread => list.where((m) => !m.isRead).toList(),
          };
          Widget chip(_InboxFilter f, String label, {Color? color}) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(label),
              selected: _filter == f,
              showCheckmark: false,
              selectedColor: color?.withValues(alpha: 0.22),
              onSelected: (_) => setState(() => _filter = f),
            ),
          );
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    chip(
                      _InboxFilter.all,
                      '${tr('searchStatus.all')} (${list.length})',
                    ),
                    chip(
                      _InboxFilter.action,
                      tr('inbox.filterAction', {'n': action}),
                      color: Chalk.red,
                    ),
                    chip(
                      _InboxFilter.unread,
                      tr('inbox.filterUnread', {'n': unread}),
                      color: Chalk.blue,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child:
                    shown.isEmpty
                        ? Center(
                          child: Text(
                            _filter == _InboxFilter.action
                                ? tr('inbox.noneAction')
                                : tr('inbox.allRead'),
                            style: const TextStyle(color: Chalk.dim),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: shown.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder:
                              (_, i) => _MessageCard(
                                message: shown[i],
                                onTap: () => _open(context, ref, shown[i]),
                              ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    InboxMessage m,
  ) async {
    if (!m.isRead) await GameActions.markRead(ref, m.id);
    if (!context.mounted) return;

    Future<void> submit(String choice) => GameActions.resolve(ref, m, choice);

    // Tombol dibangun di dalam builder dialog agar Navigator.pop menutup
    // dialog, bukan layar Inbox. Ruang Negosiasi dibuka memakai context
    // layar setelah dialog ini tertutup.
    final next = await showDialog<_Next>(
      context: context,
      builder: (ctx) {
        void go(_Next n) => Navigator.pop(ctx, n);
        void choose(String choice) => go(_Next.choice(choice));

        final close = TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(tr('common.close')),
        );
        final List<Widget> actions;
        if (!m.needsAction) {
          final playerId = _playerIdOf(m.payload);
          actions = [
            if (playerId != null)
              TextButton(
                onPressed: () => go(_Next.player(playerId)),
                child: Text(tr('inbox.viewPlayer')),
              ),
            close,
          ];
        } else {
          switch (m.actionType) {
            case InboxActionType.acceptTarget:
              actions = [
                FilledButton(
                  onPressed: () => choose('accept'),
                  child: Text(tr('inbox.acceptTarget')),
                ),
              ];
            case InboxActionType.contractDecision:
              actions = [
                TextButton(
                  onPressed: () => choose('leave'),
                  child: Text(tr('inbox.letGo')),
                ),
                FilledButton(
                  onPressed: () => choose('renew'),
                  child: Text(tr('inbox.renew')),
                ),
              ];
            case InboxActionType.incomingTransferOffer:
              actions = [
                TextButton(
                  onPressed: () => choose('reject'),
                  child: Text(tr('inbox.reject')),
                ),
                TextButton(
                  onPressed: () => choose('accept'),
                  child: Text(tr('inbox.accept')),
                ),
                FilledButton(
                  onPressed: () => go(const _Next.room()),
                  child: Text(tr('inbox.enterRoom')),
                ),
              ];
            case InboxActionType.counterOffer ||
                InboxActionType.contractNegotiation:
              actions = [
                TextButton(
                  onPressed: () => choose('cancel'),
                  child: Text(tr('inbox.cancelNegotiation')),
                ),
                FilledButton(
                  onPressed: () => go(const _Next.room()),
                  child: Text(tr('inbox.enterRoom')),
                ),
              ];
            case InboxActionType.none:
              actions = [close];
          }
        }

        return AlertDialog(
          title: Text(trText(m.title)),
          content: SingleChildScrollView(child: Text(trText(m.body))),
          actions: actions,
        );
      },
    );
    if (next == null || !context.mounted) return;

    switch (next.kind) {
      case _NextKind.choice:
        await TransferFlow.run(context, () => submit(next.choice!));
      case _NextKind.player:
        await Navigator.of(
          context,
        ).pushNamed(AppRoutes.player, arguments: next.playerId);
      case _NextKind.room:
        final offer = await _offerOf(ref, m);
        if (!context.mounted) return;
        if (offer == null || !offer.isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('err.negotiationInactive'))),
          );
          return;
        }
        await TransferFlow.openRoom(context, offer.id);
    }
  }

  static Future<TransferOffer?> _offerOf(WidgetRef ref, InboxMessage m) async {
    final head = m.payload?.split('|').first;
    if (head == null || !head.startsWith('offer:')) return null;
    final id = int.tryParse(head.substring('offer:'.length));
    if (id == null) return null;
    return ref.read(transferRepositoryProvider).offerById(id);
  }

  static int? _playerIdOf(String? payload) {
    if (payload == null || !payload.startsWith('player:')) return null;
    return int.tryParse(payload.substring('player:'.length));
  }
}

/// Satu pesan sebagai baris: kategori berwarna, judul, tanggal, titik
/// belum dibaca, dan garis merah di kiri bila menunggu keputusan.
class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.onTap});

  final InboxMessage message;
  final VoidCallback onTap;

  static Color colorOf(InboxCategory c) => switch (c) {
    InboxCategory.board => Chalk.pink,
    InboxCategory.match => Chalk.green,
    InboxCategory.scouting => Chalk.blue,
    InboxCategory.finance => Chalk.yellow,
    InboxCategory.contract => Chalk.pink,
    InboxCategory.season => Chalk.yellow,
    InboxCategory.transfer => Chalk.blue,
  };

  @override
  Widget build(BuildContext context) {
    final m = message;
    final color = colorOf(m.category);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: m.needsAction ? Chalk.red : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: m.category.label,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ', ${formatDate(m.date)}'),
                      ],
                    ),
                    style: const TextStyle(fontSize: 13, color: Chalk.dim),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    trText(m.title),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: m.isRead ? FontWeight.w400 : FontWeight.w700,
                    ),
                  ),
                  if (m.needsAction) ...[
                    const SizedBox(height: 4),
                    Text(
                      tr('dash.awaitingDecision'),
                      style: const TextStyle(
                        color: Chalk.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!m.isRead)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(left: 10, top: 24),
                decoration: const BoxDecoration(
                  color: Chalk.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _NextKind { choice, player, room }

/// Langkah setelah dialog pesan ditutup.
class _Next {
  const _Next.choice(String this.choice)
    : kind = _NextKind.choice,
      playerId = null;
  const _Next.player(int this.playerId)
    : kind = _NextKind.player,
      choice = null;
  const _Next.room() : kind = _NextKind.room, choice = null, playerId = null;

  final _NextKind kind;
  final String? choice;
  final int? playerId;
}
