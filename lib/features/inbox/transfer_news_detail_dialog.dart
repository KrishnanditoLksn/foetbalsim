import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/widgets/club_badge.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/player_avatar.dart';
import '../../data/services/transfer_service.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/season_models.dart';
import '../../domain/models/transfer_news_payload.dart';
import '../../l10n/l10n.dart';

/// Bingkai kartu pesan Inbox: penanda + tanggal di atas, isi yang bisa
/// digulir, lalu tombol aksi. Dipakai kartu berita transfer dan kartu pesan
/// biasa agar semua pesan tampil sama.
class InboxCard extends StatelessWidget {
  const InboxCard({
    super.key,
    required this.badge,
    required this.date,
    required this.children,
    required this.actions,
  });

  final Widget badge;
  final DateTime date;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: badge),
                        const SizedBox(width: 12),
                        Text(
                          formatDate(date),
                          style: TextStyle(fontSize: 13, color: Chalk.dim),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...children,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                runSpacing: 4,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Teks pesan dengan garis kapur di kiri.
class InboxCardQuote extends StatelessWidget {
  const InboxCardQuote(this.text, {super.key, this.muted = true});

  final String text;

  /// Redup untuk narasi pendamping; terang bila teks ini isi utama pesan.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Chalk.line, width: 3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: muted ? Chalk.dim : Chalk.white,
          height: 1.45,
          fontSize: muted ? 14 : 15,
        ),
      ),
    );
  }
}

/// Warna kapur untuk status berita transfer.
Color transferNewsColor(TransferNewsStatus s) => switch (s) {
  TransferNewsStatus.completed => Chalk.green,
  TransferNewsStatus.incomingOffer => Chalk.yellow,
  TransferNewsStatus.pendingBid ||
  TransferNewsStatus.counterOffer ||
  TransferNewsStatus.contractTalks => Chalk.blue,
  TransferNewsStatus.offered => Chalk.pink,
  TransferNewsStatus.rejected || TransferNewsStatus.failed => Chalk.red,
  TransferNewsStatus.cancelled => Chalk.dim,
};

/// Detail berita transfer: status, pemain, klub asal → tujuan, biaya,
/// kontrak, narasi, dan [actions] dari Inbox (Terima/Tolak/Ruang Negosiasi,
/// Lihat pemain, Tutup).
class TransferNewsDetailDialog extends ConsumerWidget {
  const TransferNewsDetailDialog({
    super.key,
    required this.message,
    required this.news,
    required this.actions,
  });

  final InboxMessage message;
  final TransferNewsPayload news;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player =
        ref.watch(playerDetailProvider(news.playerId)).valueOrNull?.player;
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final from = clubs[news.fromClubId];
    final to = clubs[news.toClubId];
    final color = transferNewsColor(news.status);

    return InboxCard(
      badge: StatusBadge(news.status.label, color: color),
      date: message.date,
      actions: actions,
      children: [
        _PlayerHeader(
          news: news,
          player: player,
          // Kaus = klub pemain saat berita dibuat.
          shirtClub: news.status.isDone ? to : from,
          color: color,
        ),
        SectionHeader(
          tr('txDetail.move'),
          padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
        ),
        _ClubMove(news: news, from: from, to: to, color: color),
        SectionHeader(
          tr('txDetail.details'),
          padding: const EdgeInsets.fromLTRB(0, 18, 0, 2),
        ),
        ..._detailRows(news),
        const SizedBox(height: 14),
        InboxCardQuote(trText(message.body)),
      ],
    );
  }

  static List<Widget> _detailRows(TransferNewsPayload n) {
    final feeLabel = switch (n.status) {
      TransferNewsStatus.completed ||
      TransferNewsStatus.contractTalks => tr('txDetail.fee'),
      TransferNewsStatus.offered => tr('txDetail.askingPrice'),
      _ => tr('txDetail.offer'),
    };
    final extras = [
      if (n.installmentYears > 1)
        Msg('terms.installments', {'n': n.installmentYears}).resolve(),
      if (n.sellOnPct > 0) Msg('terms.sellOn', {'pct': n.sellOnPct}).resolve(),
    ];
    final until =
        n.contractEndDate == null
            ? null
            : tr('txDetail.until', {'date': formatDate(n.contractEndDate!)});
    final wage =
        n.wage == null
            ? null
            : tr('common.perYear', {'amount': formatMoney(n.wage!)});

    return [
      _DetailRow(
        label: feeLabel,
        value: formatMoney(n.fee),
        note:
            extras.isNotEmpty
                ? extras.join(' · ')
                : n.status == TransferNewsStatus.offered
                ? null
                : tr('txDetail.paidUpfront'),
      ),
      if (n.status.isDone) ...[
        if (n.contractYears != null)
          _DetailRow(
            label: tr('txDetail.contractLength'),
            value: tr('common.years', {'n': n.contractYears}),
            note: until,
          ),
        if (wage != null)
          _DetailRow(label: tr('txDetail.annualWage'), value: wage),
        if (n.squadStatus != null)
          _DetailRow(
            label: tr('txDetail.squadRole'),
            value: n.squadStatus!.label,
          ),
      ] else if (!n.status.isDead) ...[
        if (until != null)
          _DetailRow(
            label: tr('txDetail.currentContract'),
            value: until,
            note: wage,
          ),
        if (n.minWage != null)
          _DetailRow(
            label: tr('txDetail.minWage'),
            value: tr('common.perYear', {'amount': formatMoney(n.minWage!)}),
          ),
      ],
    ];
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.news,
    required this.player,
    required this.shirtClub,
    required this.color,
  });

  final TransferNewsPayload news;
  final Player? player;
  final Club? shirtClub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = player;
    return Row(
      children: [
        PlayerAvatar(
          look:
              p == null
                  ? AvatarLook.from('${news.playerId}|${news.playerName}')
                  : AvatarLook.forPlayer(p),
          club: shirtClub,
          size: 68,
          borderColor: color.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p?.fullName ?? news.playerName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: Fonts.condensed,
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: Chalk.white,
                ),
              ),
              const SizedBox(height: 6),
              if (p == null)
                Text(
                  tr('txDetail.unknownPlayer'),
                  style: TextStyle(fontSize: 13, color: Chalk.dim),
                )
              else ...[
                Row(
                  children: [
                    PositionBadge(p.position, width: 38),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        tr('player.ageNation', {
                          'age': p.age,
                          'nation': p.nationality,
                        }),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Chalk.dim),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'CA ${p.currentAbility}',
                      style: scoreStyle(
                        size: 17,
                        color: ratingColor(p.currentAbility),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StarRow(stars: caToStars(p.currentAbility)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Klub asal ──▶ klub tujuan. Panah utuh bila transfer sudah terjadi,
/// putus-putus bila belum, dan dicoret bila batal.
class _ClubMove extends StatelessWidget {
  const _ClubMove({
    required this.news,
    required this.from,
    required this.to,
    required this.color,
  });

  final TransferNewsPayload news;
  final Club? from;
  final Club? to;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget side(Club? club, String fallbackId, String caption) => Expanded(
      child: Column(
        children: [
          if (club != null)
            ClubBadge(club: club, size: 46)
          else
            const SizedBox(height: 46),
          const SizedBox(height: 6),
          Text(
            club?.name ?? fallbackId,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Fonts.condensed,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Chalk.white,
            ),
          ),
          Text(caption, style: TextStyle(fontSize: 12, color: Chalk.dim)),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        side(from, news.fromClubId, tr('txDetail.fromClub')),
        SizedBox(
          width: 64,
          height: 46,
          child: CustomPaint(
            painter: _ArrowPainter(
              color: news.status.isDead ? Chalk.dim : color,
              dashed: !news.status.isDone,
              crossed: news.status.isDead,
            ),
          ),
        ),
        side(to, news.toClubId, tr('txDetail.toClub')),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.color,
    required this.dashed,
    required this.crossed,
  });

  final Color color;
  final bool dashed;
  final bool crossed;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round;
    final end = size.width - 4;
    if (dashed) {
      for (var x = 4.0; x < end - 8; x += 9) {
        canvas.drawLine(Offset(x, y), Offset(x + 4.5, y), paint);
      }
    } else {
      canvas.drawLine(Offset(4, y), Offset(end - 2, y), paint);
    }
    canvas.drawPath(
      Path()
        ..moveTo(end - 9, y - 6)
        ..lineTo(end, y)
        ..lineTo(end - 9, y + 6),
      paint
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    if (crossed) {
      final c = Offset(size.width / 2, y);
      canvas.drawLine(c + const Offset(-6, -6), c + const Offset(6, 6), paint);
      canvas.drawLine(c + const Offset(-6, 6), c + const Offset(6, -6), paint);
    }
  }

  @override
  bool shouldRepaint(_ArrowPainter old) =>
      old.color != color || old.dashed != dashed || old.crossed != crossed;
}

/// Satu baris label–nilai dipisah garis kapur.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Chalk.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Chalk.dim),
            ),
          ),
          const SizedBox(width: 12),
          // Rapat: nilai selalu rata kanan.
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Chalk.white,
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 12, color: Chalk.dim),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pratinjau berita transfer di daftar Inbox: avatar mini.
class TransferNewsThumb extends ConsumerWidget {
  const TransferNewsThumb({super.key, required this.news, this.size = 40});

  final TransferNewsPayload news;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player =
        ref.watch(playerDetailProvider(news.playerId)).valueOrNull?.player;
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    return PlayerAvatar(
      look:
          player == null
              ? AvatarLook.from('${news.playerId}|${news.playerName}')
              : AvatarLook.forPlayer(player),
      club: clubs[news.status.isDone ? news.toClubId : news.fromClubId],
      size: size,
      borderColor: transferNewsColor(news.status).withValues(alpha: 0.6),
    );
  }
}

/// Baris ringkas "Asal → Tujuan · biaya" untuk daftar Inbox.
class TransferNewsRoute extends ConsumerWidget {
  const TransferNewsRoute({super.key, required this.news});

  final TransferNewsPayload news;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(allClubsMapProvider).valueOrNull ?? const {};
    final from = clubs[news.fromClubId]?.name ?? news.fromClubId;
    final to = clubs[news.toClubId]?.name ?? news.toClubId;
    final fee = TransferService.termsLabel(
      news.fee,
      news.installmentYears,
      news.sellOnPct,
    );
    // Barlow tidak punya glyph panah, jadi panah memakai ikon.
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: from),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.arrow_forward, size: 13, color: Chalk.dim),
            ),
          ),
          TextSpan(text: '$to · $fee'),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 13, color: Chalk.dim),
    );
  }
}
