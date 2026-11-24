import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/club_badge.dart';
import '../../core/widgets/futbol_ui.dart';
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
      appBar: AppBar(title: const Text('Profil pemain')),
      body: detail.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Pemain gagal dimuat: $e')),
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
    final club = ref.watch(clubByIdProvider(p.clubId)).valueOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        _Identity(detail: detail, club: club),
        const SizedBox(height: 20),
        _Numbers(player: p),
        const SectionHeader('Transfer'),
        _TransferActions(detail: detail),
        if (c != null) ...[
          const SectionHeader('Kontrak'),
          _ContractRow(contract: c),
        ],
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

/// Identitas pemain: nama besar seperti di punggung kaus, garis warna klub
/// di kiri, lalu posisi, usia, negara, dan klub.
class _Identity extends StatelessWidget {
  const _Identity({required this.detail, required this.club});

  final PlayerDetail detail;
  final Club? club;

  @override
  Widget build(BuildContext context) {
    final p = detail.player;
    final stripe = club == null ? Chalk.line : colorFromHex(club!.primaryColor);
    return Container(
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: stripe, width: 5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.firstName,
                  style: const TextStyle(color: Chalk.dim, fontSize: 16),
                ),
                Text(
                  p.lastName,
                  style: const TextStyle(
                    fontFamily: Fonts.condensed,
                    fontSize: 42,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PositionBadge(p.position),
                    Text('${p.age} tahun, ${p.nationality}'),
                    if (p.isTransferListed)
                      const StatusBadge('Dijual', color: Chalk.yellow),
                  ],
                ),
                const SizedBox(height: 6),
                Text(detail.clubName, style: const TextStyle(color: Chalk.dim)),
              ],
            ),
          ),
          if (club != null) ClubBadge(club: club!, size: 48),
        ],
      ),
    );
  }
}

/// Kemampuan sekarang (CA), potensi (PA), kondisi, moral, nilai pasar.
class _Numbers extends StatelessWidget {
  const _Numbers({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final p = player;
    final moraleColor =
        p.morale >= 70
            ? Chalk.green
            : p.morale >= 45
            ? Chalk.yellow
            : Chalk.red;
    return Column(
      children: [
        StatStrip(
          children: [
            _Ability(label: 'Kemampuan (CA)', value: p.currentAbility),
            _Ability(label: 'Potensi (PA)', value: p.potentialAbility),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        StatStrip(
          children: [
            StatFigure(
              label: 'Kondisi',
              child: ConditionBar(p.condition, width: 44),
            ),
            StatFigure(
              label: 'Moral',
              value: '${p.morale}',
              color: moraleColor,
            ),
            StatFigure(label: 'Nilai pasar', value: formatMoney(p.marketValue)),
          ],
        ),
      ],
    );
  }
}

class _Ability extends StatelessWidget {
  const _Ability({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              '$value',
              style: scoreStyle(size: 46, color: ratingColor(value)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: StarRow(stars: caToStars(value), size: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Chalk.dim, fontSize: 13)),
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
    final shortlisted = (ref.watch(shortlistProvider).valueOrNull ??
            const <int>{})
        .contains(p.id);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...lines,
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: buttons),
        const SizedBox(height: 8),
        Text(
          window.isOpen
              ? 'Bursa buka sampai ${formatDate(window.closesOn!)}.'
              : 'Bursa tutup, buka lagi ${formatDate(window.nextOpensOn!)}.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Gaji, akhir kontrak, dan peran dalam satu baris angka.
class _ContractRow extends StatelessWidget {
  const _ContractRow({required this.contract});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final end = contract.endDate;
    return StatStrip(
      children: [
        StatFigure(label: 'Gaji per tahun', value: formatMoney(contract.wage)),
        StatFigure(label: 'Berakhir', value: '${end.month}/${end.year}'),
        StatFigure(label: 'Peran', value: contract.squadStatus.label),
      ],
    );
  }
}

/// Atribut satu kategori dalam grid 2 kolom: nama di kiri, angka berkode
/// warna di kanan (gaya Football Manager).
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
    Widget cell(Attribute a) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              a.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 6),
          AttributeBox(values[a]),
        ],
      ),
    );

    final rows = <Widget>[];
    for (var i = 0; i < attributes.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: cell(attributes[i])),
            const SizedBox(width: 20),
            Expanded(
              child:
                  i + 1 < attributes.length
                      ? cell(attributes[i + 1])
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [SectionHeader(title), ...rows],
    );
  }
}
