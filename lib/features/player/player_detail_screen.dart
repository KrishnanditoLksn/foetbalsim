import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/format_utils.dart';
import '../../data/repositories/player_repository.dart';
import '../../domain/enums/attribute.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/player_attributes.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/generators/world_generator.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/transfer_window.dart';
import '../transfer/transfer_flow.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(playerDetailProvider(playerId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pemain')),
      body: detail.when(
      skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat pemain: $e')),
        data:
            (d) =>
                d == null
                    ? const Center(child: Text('Pemain tidak ditemukan.'))
                    : _PlayerBody(detail: d),
      ),
    );
  }
}

class _PlayerBody extends ConsumerWidget {
  const _PlayerBody({required this.detail});

  final PlayerDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = detail.player;
    final c = detail.contract;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(p.fullName, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('${p.position.label} · ${p.age} tahun · ${p.nationality}'),
        Text('Klub: ${detail.clubName}'),
        if (p.isTransferListed)
          Text(
            'Status: Daftar jual',
            style: TextStyle(
              color: theme.colorScheme.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 12),
        _TransferActions(detail: detail),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoChip(
              label: 'CA',
              value: '${caToStars(p.currentAbility)} ★ (${p.currentAbility})',
            ),
            _InfoChip(
              label: 'PA',
              value:
                  '${caToStars(p.potentialAbility)} ★ (${p.potentialAbility})',
            ),
            _InfoChip(label: 'Kondisi', value: '${p.condition}%'),
            _InfoChip(label: 'Moral', value: '${p.morale}'),
            _InfoChip(label: 'Nilai', value: formatMoney(p.marketValue)),
          ],
        ),
        const SizedBox(height: 16),
        if (c != null) _ContractCard(contract: c),
        const SizedBox(height: 16),
        for (final entry in p.attributes.byGroup.entries)
          _AttributeSection(
            title: entry.key.label,
            attributes: entry.value,
            values: p.attributes,
          ),
      ],
    );
  }
}

/// Panel transfer di detail pemain (README_FASE3 B.5, B.10.6):
/// - pemain klub lain: harga minta, gaji yang diharapkan, alasan bila tidak
///   bisa ditawar, tombol tawar, dan negosiasi yang sedang berjalan;
/// - pemain kita: daftar jual dan klub yang berminat.
class _TransferActions extends ConsumerWidget {
  const _TransferActions({required this.detail});

  final PlayerDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(gameStateProvider).valueOrNull;
    final ourId = state?.clubId;
    final now = state?.currentDate ?? WorldGenerator.seasonStart;
    final p = detail.player;
    final isOurs = p.clubId == ourId;
    final window = TransferWindow.status(now);
    final shortlisted =
        (ref.watch(shortlistProvider).valueOrNull ?? const <int>{}).contains(
          p.id,
        );
    final offers = ref.watch(clubOffersProvider).valueOrNull ?? const [];
    TransferOffer? active;
    for (final o in offers) {
      if (o.playerId == p.id && o.isActive) {
        active = o;
        break;
      }
    }

    final lines = <Widget>[];
    final buttons = <Widget>[
      OutlinedButton.icon(
        onPressed:
            () => GameActions.run(
              ref,
              (e) => e.setShortlisted(p.id, !shortlisted),
            ),
        icon: Icon(shortlisted ? Icons.bookmark : Icons.bookmark_border),
        label: Text(shortlisted ? 'Di Shortlist' : 'Shortlist'),
      ),
    ];

    if (isOurs) {
      buttons.add(
        FilledButton.tonalIcon(
          onPressed:
              () => GameActions.run(
                ref,
                (e) => e.setListed(p.id, !p.isTransferListed),
              ),
          icon: const Icon(Icons.sell_outlined),
          label: Text(p.isTransferListed ? 'Batal Daftar Jual' : 'Daftar Jual'),
        ),
      );
      final interests =
          ref.watch(playerInterestsProvider(p.id)).valueOrNull ?? const [];
      lines.add(
        Text(
          interests.isEmpty
              ? 'Belum ada klub yang berminat.'
              : 'Klub yang berminat:',
          style: theme.textTheme.labelLarge,
        ),
      );
      for (final i in interests.take(6)) {
        lines.add(Text('• ${i.clubName} — ${i.levelLabel} (${i.score})'));
      }
    } else {
      final quote = ref.watch(transferQuoteProvider(p.id)).valueOrNull;
      if (quote != null) {
        lines.add(
          Text(
            'Harga minta: ${moneyLabel(quote.askingFee)}'
            '${quote.isRival ? ' (premi rival +30%)' : ''} · '
            'gaji diharapkan ${moneyLabel(quote.expectedWage)}/thn',
          ),
        );
      }
      final blocked = active == null ? quote?.blockedReason : null;
      buttons.add(
        FilledButton.icon(
          onPressed:
              (active != null || quote == null || blocked != null)
                  ? null
                  : () => TransferFlow.bid(context, ref, p),
          icon: const Icon(Icons.gavel),
          label: Text(
            active == null
                ? 'Ajukan Tawaran'
                : active.status == TransferOfferStatus.pending
                ? 'Tawaran Diajukan'
                : 'Negosiasi Berjalan',
          ),
        ),
      );
      if (blocked != null) {
        lines.add(
          Text(blocked, style: TextStyle(color: theme.colorScheme.error)),
        );
      }
    }

    if (active != null && ourId != null) {
      lines.add(const SizedBox(height: 4));
      lines.add(
        Text(
          '${active.toClubId == ourId ? 'Tawaran masuk' : 'Negosiasi'}: '
          '${active.status.label} · ${offerSummary(active)}',
          style: theme.textTheme.labelLarge,
        ),
      );
      lines.add(
        OfferActions(offer: active, ourClubId: ourId, playerName: p.fullName),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: buttons),
            const SizedBox(height: 8),
            ...lines,
            const SizedBox(height: 6),
            Text(
              window.isOpen
                  ? 'Jendela transfer buka (tutup ${formatDate(window.closesOn!)}).'
                  : 'Jendela transfer tutup. Dibuka kembali '
                      '${formatDate(window.nextOpensOn!)}.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.contract});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final end = contract.endDate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kontrak', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Gaji: ${formatMoney(contract.wage)} / tahun'),
            Text('Berakhir: ${end.day}/${end.month}/${end.year}'),
            Text('Peran: ${contract.squadStatus.label}'),
          ],
        ),
      ),
    );
  }
}

class _AttributeSection extends StatelessWidget {
  const _AttributeSection({
    required this.title,
    required this.attributes,
    required this.values,
  });

  final String title;
  final List<Attribute> attributes;
  final PlayerAttributes values;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final a in attributes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(width: 140, child: Text(a.label)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: values[a] / 20,
                        minHeight: 8,
                        color: attributeColor(values[a]),
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${values[a]}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: attributeColor(values[a]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
