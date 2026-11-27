import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../core/widgets/player_avatar.dart';
import '../../domain/enums/inbox.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_news_payload.dart';
import '../../l10n/l10n.dart';
import 'transfer_news_detail_dialog.dart';

/// Warna kapur kategori pesan.
Color inboxCategoryColor(InboxCategory c) => switch (c) {
  InboxCategory.board => Chalk.pink,
  InboxCategory.match => Chalk.green,
  InboxCategory.scouting => Chalk.blue,
  InboxCategory.finance => Chalk.yellow,
  InboxCategory.contract => Chalk.pink,
  InboxCategory.season => Chalk.yellow,
  InboxCategory.transfer => Chalk.blue,
};

/// Kartu pesan Inbox yang bukan berita transfer (dewan, laga, kontrak,
/// musim, …): gaya sama dengan [TransferNewsDetailDialog].
class InboxMessageDialog extends ConsumerWidget {
  const InboxMessageDialog({
    super.key,
    required this.message,
    required this.actions,
  });

  final InboxMessage message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = message;
    final color = inboxCategoryColor(m.category);
    final playerId = TransferNewsPayload.playerIdOf(m.payload);
    final detail =
        playerId == null
            ? null
            : ref.watch(playerDetailProvider(playerId)).valueOrNull;
    final club =
        detail == null
            ? null
            : ref.watch(clubByIdProvider(detail.player.clubId)).valueOrNull;

    return InboxCard(
      badge: StatusBadge(m.category.label, color: color),
      date: m.date,
      actions: actions,
      children: [
        Text(
          trText(m.title),
          style: TextStyle(
            fontFamily: Fonts.condensed,
            fontSize: 25,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: Chalk.white,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              PlayerAvatar.of(detail.player, club: club, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.player.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        PositionBadge(detail.player.position, width: 38),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            tr('player.ageNation', {
                              'age': detail.player.age,
                              'nation': detail.player.nationality,
                            }),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: Chalk.dim),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        InboxCardQuote(trText(m.body), muted: false),
        if (m.needsAction) ...[
          const SizedBox(height: 14),
          Text(
            tr('dash.awaitingDecision'),
            style: TextStyle(
              color: Chalk.red,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
