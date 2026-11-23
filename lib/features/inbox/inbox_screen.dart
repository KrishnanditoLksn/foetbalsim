import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../core/utils/date_format.dart';
import '../../domain/enums/inbox.dart';
import '../../domain/finance/money_label.dart';
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
    InboxCategory.transfer => Icons.swap_horiz,
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
            case InboxActionType.incomingTransferOffer:
              actions = [
                TextButton(
                  onPressed: () => choose('reject'),
                  child: const Text('Tolak'),
                ),
                FilledButton(
                  onPressed: () => choose('accept'),
                  child: const Text('Terima'),
                ),
              ];
            case InboxActionType.contractNegotiation:
              actions = [
                TextButton(
                  onPressed: () => choose('cancel'),
                  child: const Text('Batalkan'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _negotiate(context, ref, m);
                  },
                  child: const Text('Ajukan kontrak'),
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

  /// Dialog negosiasi kontrak: gaji per tahun (€ ribu) dan durasi 1–5 tahun.
  Future<void> _negotiate(
    BuildContext context,
    WidgetRef ref,
    InboxMessage m,
  ) async {
    final minWage = _minWageOf(m.payload);
    final wageCtl = TextEditingController(text: '${minWage ?? 0}');
    var years = 3;
    final choice = await showDialog<String>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: const Text('Negosiasi kontrak'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: wageCtl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Gaji per tahun (€ ribu)',
                          helperText:
                              minWage == null
                                  ? null
                                  : 'Minimal ${moneyLabel(minWage)}',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Durasi'),
                          const SizedBox(width: 12),
                          DropdownButton<int>(
                            value: years,
                            items: [
                              for (var y = 1; y <= 5; y++)
                                DropdownMenuItem(
                                  value: y,
                                  child: Text('$y tahun'),
                                ),
                            ],
                            onChanged:
                                (v) => setState(() => years = v ?? years),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Kembali'),
                    ),
                    FilledButton(
                      onPressed:
                          () => Navigator.pop(
                            ctx,
                            'wage:${int.tryParse(wageCtl.text.trim()) ?? 0}|years:$years',
                          ),
                      child: const Text('Ajukan'),
                    ),
                  ],
                ),
          ),
    );
    wageCtl.dispose();
    if (choice != null) GameActions.resolve(ref, m, choice);
  }

  /// Membaca bagian min: dari payload pesan negosiasi.
  static int? _minWageOf(String? payload) {
    if (payload == null) return null;
    for (final part in payload.split('|')) {
      if (part.startsWith('min:')) return int.tryParse(part.substring(4));
    }
    return null;
  }
}
