import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../core/utils/date_format.dart';
import '../../domain/enums/inbox.dart';
import '../../domain/models/season_models.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: inbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat inbox: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Inbox kosong.'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = list[i];
              return ListTile(
                leading: Icon(
                  _iconOf(m.category),
                  color:
                      m.needsAction
                          ? Theme.of(context).colorScheme.error
                          : null,
                ),
                title: Text(
                  m.title,
                  style: TextStyle(
                    fontWeight: m.isRead ? FontWeight.normal : FontWeight.w700,
                  ),
                ),
                subtitle: Text('${m.category.label} · ${formatDate(m.date)}'),
                trailing:
                    m.needsAction
                        ? const Chip(label: Text('Perlu tindakan'))
                        : null,
                onTap: () => _open(context, ref, m),
              );
            },
          );
        },
      ),
    );
  }

  static IconData _iconOf(InboxCategory c) => switch (c) {
    InboxCategory.board => Icons.business,
    InboxCategory.match => Icons.sports_soccer,
    InboxCategory.scouting => Icons.visibility,
    InboxCategory.finance => Icons.payments,
    InboxCategory.contract => Icons.description,
    InboxCategory.season => Icons.emoji_events,
  };

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    InboxMessage m,
  ) async {
    if (!m.isRead) await GameActions.markRead(ref, m.id);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        // Tombol dibangun di dalam builder dialog agar Navigator.pop
        // menutup dialog, bukan layar Inbox.
        void choose(String choice) {
          Navigator.pop(ctx);
          GameActions.resolve(ref, m, choice);
        }

        final List<Widget> actions;
        if (!m.needsAction) {
          actions = [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ];
        } else {
          switch (m.actionType) {
            case InboxActionType.acceptTarget:
              actions = [
                FilledButton(
                  onPressed: () => choose('accept'),
                  child: const Text('Terima target'),
                ),
              ];
            case InboxActionType.contractDecision:
              actions = [
                TextButton(
                  onPressed: () => choose('leave'),
                  child: const Text('Biarkan pergi'),
                ),
                FilledButton(
                  onPressed: () => choose('renew'),
                  child: const Text('Perpanjang'),
                ),
              ];
            case InboxActionType.none:
              actions = [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup'),
                ),
              ];
          }
        }

        return AlertDialog(
          title: Text(m.title),
          content: Text(m.body),
          actions: actions,
        );
      },
    );
  }
}
