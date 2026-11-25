import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/database/app_database.dart' show NegotiationSessionRow;
import '../../data/services/transfer_service.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/transfer_models.dart';
import 'transfer_dialogs.dart';

/// Alur UI transfer yang dipakai bersama oleh detail pemain, tab Negosiasi,
/// dan Inbox, sehingga aturan dan teksnya sama di semua tempat.
abstract final class TransferFlow {
  /// Menjalankan aksi lalu menampilkan hasilnya. Pelanggaran ketentuan
  /// (StateError dari layanan) ditampilkan sebagai pesan, bukan crash.
  static Future<bool> run(
    BuildContext context,
    Future<void> Function() action, {
    String? success,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await action();
      if (success != null) {
        messenger?.showSnackBar(SnackBar(content: Text(success)));
      }
      return true;
    } on StateError catch (e) {
      messenger?.showSnackBar(SnackBar(content: Text(e.message)));
      return false;
    }
  }

  /// Ronde 1: menampilkan harga minta dan dialog tawaran, lalu mengirimnya.
  static Future<void> bid(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final engine = ref.read(gameEngineProvider);
    final TransferQuote quote;
    final Club? club;
    try {
      quote = await engine.transferQuote(player.id);
      final state = await ref.read(gameStateProvider.future);
      club = await ref.read(clubByIdProvider(state!.clubId!).future);
    } on StateError catch (e) {
      messenger?.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (quote.blockedReason != null) {
      messenger?.showSnackBar(SnackBar(content: Text(quote.blockedReason!)));
      return;
    }
    if (club == null || !context.mounted) return;
    final terms = await showDialog<BidTerms>(
      context: context,
      builder:
          (_) => BidDialog(
            playerName: player.fullName,
            askingFee: quote.askingFee,
            transferBudget: club!.transferBudget,
            balance: club.balance,
            isRival: quote.isRival,
          ),
    );
    if (terms == null || !context.mounted) return;
    await run(
      context,
      () => GameActions.run(
        ref,
        (e) => e.placeBid(
          player.id,
          terms.fee,
          installmentYears: terms.installmentYears,
          sellOnPct: terms.sellOnPct,
        ),
      ),
      success: 'Tawaran dikirim. Respons klub dalam 1–2 hari.',
    );
  }

  /// Membuka Ruang Negosiasi untuk satu tawaran (kontra-tawaran, tawaran
  /// masuk, atau kontrak).
  static Future<void> openRoom(BuildContext context, int offerId) =>
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.negotiationRoom, arguments: offerId);
}

/// Tombol aksi untuk satu negosiasi, sesuai status dan arah tawaran.
class OfferActions extends ConsumerWidget {
  const OfferActions({
    super.key,
    required this.offer,
    required this.ourClubId,
    required this.playerName,
    this.session,
  });

  final TransferOffer offer;
  final String ourClubId;
  final String playerName;

  /// Sesi tawar-menawar yang sedang berjalan (bila ada), untuk label tombol.
  final NegotiationSessionRow? session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> simple(String choice, String success) => TransferFlow.run(
      context,
      () => GameActions.run(ref, (e) => e.respondToOffer(offer.id, choice)),
      success: success,
    );
    final roomLabel = session == null ? 'Negosiasi' : 'Lanjutkan negosiasi';
    final room = FilledButton(
      onPressed: () => TransferFlow.openRoom(context, offer.id),
      child: Text(roomLabel),
    );

    final incoming = offer.isIncomingFor(ourClubId);
    final List<Widget> buttons;
    if (incoming) {
      buttons = [
        TextButton(
          onPressed: () => simple('reject', 'Tawaran ditolak.'),
          child: const Text('Tolak'),
        ),
        OutlinedButton(
          onPressed: () => simple('accept', 'Pemain dijual.'),
          child: const Text('Terima'),
        ),
        room,
      ];
    } else if (offer.status == TransferOfferStatus.countered ||
        offer.status == TransferOfferStatus.awaitingContract) {
      buttons = [
        TextButton(
          onPressed: () => simple('cancel', 'Negosiasi dibatalkan.'),
          child: const Text('Batalkan'),
        ),
        room,
      ];
    } else if (offer.status == TransferOfferStatus.pending) {
      final when = offer.responseDate;
      return Text(
        when == null
            ? 'Menunggu respons klub penjual.'
            : 'Menunggu respons klub penjual '
                '(${when.day}/${when.month}).',
        style: Theme.of(context).textTheme.bodySmall,
      );
    } else {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: buttons,
    );
  }
}

/// Warna badge status negosiasi.
Color offerStatusColor(TransferOfferStatus s) => switch (s) {
  TransferOfferStatus.pending => FutbolColors.cyan,
  TransferOfferStatus.countered => FutbolColors.amber,
  TransferOfferStatus.awaitingContract => FutbolColors.amber,
  TransferOfferStatus.completed => FutbolColors.emerald,
  TransferOfferStatus.rejected ||
  TransferOfferStatus.failed => FutbolColors.coral,
  TransferOfferStatus.withdrawn => FutbolColors.textSecondary,
};

/// Teks ringkas satu tawaran: nominal dan syarat pembayarannya.
String offerSummary(TransferOffer o) =>
    TransferService.termsLabel(o.fee, o.installmentYears, o.sellOnPct);

/// Label status tawaran dari sudut pandang klub kita. Tawaran masuk yang
/// masih berjalan disimpan sebagai `awaitingContract`, tetapi bagi user itu
/// adalah tawaran yang menunggu jawaban, bukan negosiasi kontrak.
String offerStatusLabel(TransferOffer o, String ourClubId) =>
    o.isActive && o.isIncomingFor(ourClubId) ? 'Tawaran masuk' : o.status.label;
