import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/club_badge.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../data/database/app_database.dart' show NegotiationSessionRow;
import '../../data/repositories/player_repository.dart';
import '../../data/services/transfer_service.dart' show TransferQuote;
import '../../domain/enums/attribute.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/player_attributes.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/generators/world_generator.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/agent_negotiator.dart';
import '../../domain/transfer/transfer_window.dart';
import '../../l10n/l10n.dart';
import '../transfer/transfer_flow.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(playerDetailProvider(playerId));
    return Scaffold(
      appBar: AppBar(title: Text(tr('player.title'))),
      body: detail.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) =>
                Center(child: Text(tr('player.loadFailed', {'error': '$e'}))),
        data:
            (d) =>
                d == null
                    ? Center(child: Text(tr('err.playerNotFound')))
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
        SectionHeader(tr('inboxCat.transfer')),
        _TransferActions(detail: detail),
        if (c != null) ...[
          SectionHeader(tr('inboxCat.contract')),
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
                  style: TextStyle(color: Chalk.dim, fontSize: 16),
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
                    Text(
                      tr('player.ageNation', {
                        'age': p.age,
                        'nation': p.nationality,
                      }),
                    ),
                    if (p.isTransferListed)
                      StatusBadge(tr('player.forSale'), color: Chalk.yellow),
                  ],
                ),
                const SizedBox(height: 6),
                Text(detail.clubName, style: TextStyle(color: Chalk.dim)),
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
            _Ability(label: tr('player.ca'), value: p.currentAbility),
            _Ability(label: tr('player.pa'), value: p.potentialAbility),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        StatStrip(
          children: [
            StatFigure(
              label: tr('player.condition'),
              child: ConditionBar(p.condition, width: 44),
            ),
            StatFigure(
              label: tr('player.morale'),
              value: '${p.morale}',
              color: moraleColor,
            ),
            StatFigure(
              label: tr('player.marketValue'),
              value: formatMoney(p.marketValue),
            ),
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
        Text(label, style: TextStyle(color: Chalk.dim, fontSize: 13)),
      ],
    );
  }
}

/// Panel transfer di detail pemain, mengikuti alur Ruang Negosiasi:
/// - semua pemain: agen pemain (nama & gaya) dan negosiasi yang sedang
///   berjalan beserta sisa kesabaran agen, dengan tombol ke Ruang Negosiasi;
/// - pemain klub lain: harga minta, gaji yang diharapkan, alasan bila tidak
///   bisa ditawar (termasuk jeda 1 minggu setelah agen walk-out), tombol tawar;
/// - pemain kita: daftar jual dan klub yang berminat.
class _TransferActions extends ConsumerWidget {
  const _TransferActions({required this.detail});

  final PlayerDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final sessions =
        ref.watch(activeNegotiationsProvider).valueOrNull ?? const {};
    final active = [
      for (final o in offers)
        if (o.playerId == p.id && o.isActive) o,
    ];
    final agent =
        state == null
            ? null
            : AgentProfile.forPlayer(seed: state.seed, playerId: p.id);

    final children = <Widget>[];

    // Harga dan gaji (pemain klub lain).
    TransferQuote? quote;
    if (!isOurs) {
      quote = ref.watch(transferQuoteProvider(p.id)).valueOrNull;
      if (quote != null) {
        children.add(
          StatStrip(
            children: [
              StatFigure(
                label:
                    quote.isRival
                        ? tr('player.askingRival')
                        : tr('player.asking'),
                value: moneyLabel(quote.askingFee),
                labelLines: 2,
              ),
              StatFigure(
                label: tr('player.expectedWage'),
                value: moneyLabel(quote.expectedWage),
                labelLines: 2,
              ),
            ],
          ),
        );
        children.add(const SizedBox(height: 14));
      }
    }

    // Agen pemain.
    if (agent != null) {
      // Satu kalimat: "Agen Luis Ferreira, gaya keras kepala".
      children.add(
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: tr('player.agentPrefix')),
              TextSpan(
                text: agent.name,
                style: TextStyle(
                  color: Chalk.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: tr('player.agentStyle', {
                  'style': agent.style.label.toLowerCase(),
                }),
              ),
            ],
          ),
          style: TextStyle(color: Chalk.dim),
        ),
      );
    }

    // Negosiasi yang sedang berjalan.
    if (ourId != null) {
      for (final o in active) {
        children.add(
          _ActiveNegotiation(
            offer: o,
            incoming: o.isIncomingFor(ourId),
            session: sessions[o.id],
            ourClubId: ourId,
            playerName: p.fullName,
          ),
        );
      }
    }

    // Alasan tidak bisa ditawar (mis. jeda walk-out agen).
    final blocked = active.isEmpty ? quote?.blockedReason : null;
    if (blocked != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            blocked,
            style: TextStyle(
              color: Chalk.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Klub yang berminat (pemain kita).
    if (isOurs) {
      final interests =
          ref.watch(playerInterestsProvider(p.id)).valueOrNull ?? const [];
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            interests.isEmpty
                ? tr('player.noInterest')
                : tr('player.interestedClubs'),
            style: TextStyle(color: Chalk.dim),
          ),
        ),
      );
      for (final i in interests.take(6)) {
        children.add(
          _InfoRow(
            label: i.clubName,
            labelColor: Chalk.white,
            child: Text(
              tr('player.interestScore', {
                'level': i.levelLabel,
                'score': i.score,
              }),
              textAlign: TextAlign.end,
              style: TextStyle(color: Chalk.dim),
            ),
          ),
        );
      }
    }

    // Tombol.
    final buttons = <Widget>[
      if (!isOurs)
        OutlinedButton.icon(
          onPressed:
              () => GameActions.run(
                ref,
                (e) => e.setShortlisted(p.id, !shortlisted),
              ),
          icon: Icon(shortlisted ? Icons.bookmark : Icons.bookmark_border),
          label: Text(
            shortlisted ? tr('player.shortlisted') : tr('player.shortlist'),
          ),
        ),
      if (isOurs)
        FilledButton.tonalIcon(
          onPressed:
              () => GameActions.run(
                ref,
                (e) => e.setListed(p.id, !p.isTransferListed),
              ),
          icon: const Icon(Icons.sell_outlined),
          label: Text(
            p.isTransferListed ? tr('player.unlist') : tr('player.list'),
          ),
        )
      else if (active.isEmpty)
        FilledButton.icon(
          onPressed:
              (quote == null || blocked != null)
                  ? null
                  : () => TransferFlow.bid(context, ref, p),
          icon: const Icon(Icons.gavel),
          label: Text(tr('player.makeOffer')),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...children,
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: buttons),
        const SizedBox(height: 8),
        Text(
          window.isOpen
              ? tr('player.windowOpen', {'date': formatDate(window.closesOn!)})
              : tr('player.windowClosed', {
                'date': formatDate(window.nextOpensOn!),
              }),
          style: TextStyle(color: Chalk.dim, fontSize: 13),
        ),
      ],
    );
  }
}

/// Satu baris label–isi yang dipisah garis kapur.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.child,
    this.labelColor,
  });

  final String label;
  final Widget child;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Chalk.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: labelColor ?? Chalk.dim)),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: child),
        ],
      ),
    );
  }
}

/// Negosiasi yang berjalan untuk pemain ini: dengan siapa, nominal, status,
/// sisa kesabaran agen bila sesi Ruang Negosiasi sudah dibuka, lalu tombol.
class _ActiveNegotiation extends ConsumerWidget {
  const _ActiveNegotiation({
    required this.offer,
    required this.incoming,
    required this.session,
    required this.ourClubId,
    required this.playerName,
  });

  final TransferOffer offer;
  final bool incoming;
  final NegotiationSessionRow? session;
  final String ourClubId;
  final String playerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherId = incoming ? offer.fromClubId : offer.toClubId;
    final other = ref.watch(clubByIdProvider(otherId)).valueOrNull?.name ?? '';
    final title =
        incoming
            ? tr('player.offerFrom', {'club': other})
            : offer.status == TransferOfferStatus.awaitingContract
            ? tr('player.feeAgreedWith', {'club': other})
            : tr('player.negotiatingWith', {'club': other});
    final s = session;
    final patienceColor =
        s == null
            ? Chalk.dim
            : switch (AgentNegotiator.levelOf(s.patience)) {
              PatienceLevel.open => Chalk.green,
              PatienceLevel.impatient => Chalk.yellow,
              _ => Chalk.red,
            };
    final statusColor = offerStatusColor(offer.status);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Chalk.boardDeep,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                offerStatusLabel(offer, ourClubId),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(offerSummary(offer), style: scoreStyle(size: 20)),
          if (s != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tr('player.bargaining', {'n': s.patience}),
                style: TextStyle(
                  color: patienceColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 6),
          OfferActions(
            offer: offer,
            ourClubId: ourClubId,
            playerName: playerName,
            session: s,
          ),
        ],
      ),
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
        StatFigure(
          label: tr('player.wagePerYear'),
          value: formatMoney(contract.wage),
        ),
        StatFigure(
          label: tr('player.expires'),
          value: '${end.month}/${end.year}',
        ),
        StatFigure(label: tr('player.role'), value: contract.squadStatus.label),
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
