import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../core/utils/date_format.dart';
import '../../domain/enums/inbox.dart';
import '../../app/router.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_models.dart';
import '../transfer/transfer_flow.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: inbox.when(
      skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat inbox: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Inbox kosong.'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
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

    Future<void> submit(String choice) => GameActions.resolve(ref, m, choice);

    // Tombol dibangun di dalam builder dialog agar Navigator.pop menutup
    // dialog, bukan layar Inbox. Dialog lanjutan (kontra, tawaran final,
    // kontrak) dibuka memakai context layar setelah dialog ini tertutup.
    final next = await showDialog<_Next>(
      context: context,
      builder: (ctx) {
        void go(_Next n) => Navigator.pop(ctx, n);
        void choose(String choice) => go(_Next.choice(choice));

        final close = TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Tutup'),
        );
        final List<Widget> actions;
        if (!m.needsAction) {
          final playerId = _playerIdOf(m.payload);
          actions = [
            if (playerId != null)
              TextButton(
                onPressed: () => go(_Next.player(playerId)),
                child: const Text('Lihat pemain'),
              ),
            close,
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
                TextButton(
                  onPressed: () => go(const _Next.counter()),
                  child: const Text('Kontra'),
                ),
                FilledButton(
                  onPressed: () => choose('accept'),
                  child: const Text('Terima'),
                ),
              ];
            case InboxActionType.counterOffer:
              actions = [
                TextButton(
                  onPressed: () => choose('cancel'),
                  child: const Text('Batalkan'),
                ),
                TextButton(
                  onPressed: () => go(const _Next.finalOffer()),
                  child: const Text('Tawaran final'),
                ),
                FilledButton(
                  onPressed: () => choose('accept'),
                  child: const Text('Terima harga'),
                ),
              ];
            case InboxActionType.contractNegotiation:
              actions = [
                TextButton(
                  onPressed: () => choose('cancel'),
                  child: const Text('Batalkan'),
                ),
                FilledButton(
                  onPressed: () => go(const _Next.contract()),
                  child: const Text('Ajukan kontrak'),
                ),
              ];
            case InboxActionType.none:
              actions = [close];
          }
        }

        return AlertDialog(
          title: Text(m.title),
          content: SingleChildScrollView(child: Text(m.body)),
          actions: actions,
        );
      },
    );
    if (next == null || !context.mounted) return;

    switch (next.kind) {
      case _NextKind.choice:
        await TransferFlow.run(context, () => submit(next.choice!));
      case _NextKind.player:
        await Navigator.of(context).pushNamed(
          AppRoutes.player,
          arguments: next.playerId,
        );
      case _NextKind.counter:
      case _NextKind.finalOffer:
      case _NextKind.contract:
        final offer = await _offerOf(ref, m);
        if (!context.mounted) return;
        if (offer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Negosiasi ini sudah tidak berjalan.')),
          );
          return;
        }
        if (next.kind == _NextKind.counter) {
          await TransferFlow.counterIncoming(context, offer, submit);
        } else if (next.kind == _NextKind.finalOffer) {
          await TransferFlow.finalOffer(context, offer, submit);
        } else {
          final name =
              (await ref.read(playerDetailProvider(offer.playerId).future))
                  ?.player
                  .fullName ??
              'Pemain';
          if (!context.mounted) return;
          await TransferFlow.contract(
            context,
            ref,
            offer,
            name,
            submit,
            minWage: _minWageOf(m.payload),
          );
        }
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

  /// Membaca bagian min: dari payload pesan negosiasi.
  static int? _minWageOf(String? payload) {
    if (payload == null) return null;
    for (final part in payload.split('|')) {
      if (part.startsWith('min:')) return int.tryParse(part.substring(4));
    }
    return null;
  }
}

enum _NextKind { choice, player, counter, finalOffer, contract }

/// Langkah setelah dialog pesan ditutup.
class _Next {
  const _Next.choice(String this.choice)
    : kind = _NextKind.choice,
      playerId = null;
  const _Next.player(int this.playerId)
    : kind = _NextKind.player,
      choice = null;
  const _Next.counter() : kind = _NextKind.counter, choice = null, playerId = null;
  const _Next.finalOffer()
    : kind = _NextKind.finalOffer,
      choice = null,
      playerId = null;
  const _Next.contract()
    : kind = _NextKind.contract,
      choice = null,
      playerId = null;

  final _NextKind kind;
  final String? choice;
  final int? playerId;
}
