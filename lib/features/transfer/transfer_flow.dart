import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/game_actions.dart';
import '../../app/providers.dart';
import '../../data/services/transfer_service.dart';
import '../../domain/enums/transfer.dart';
import '../../domain/finance/money_label.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/transfer_rules.dart';
import 'transfer_dialogs.dart';

/// Mengirim pilihan negosiasi (mis. `accept`, `final:12000`) ke engine.
typedef OfferSubmit = Future<void> Function(String choice);

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

  /// Kontra untuk tawaran masuk: pembeli menerima bila ≤ 5% di atas tawarannya.
  static Future<void> counterIncoming(
    BuildContext context,
    TransferOffer offer,
    OfferSubmit submit,
  ) async {
    final max = (offer.fee * TransferRules.counterTolerance).round();
    final fee = await showDialog<int>(
      context: context,
      builder:
          (_) => FeeDialog(
            title: 'Ajukan harga',
            message: 'Tawaran pembeli: ${moneyLabel(offer.fee)}.',
            initialFee: max,
            helper:
                'Pembeli menerima sampai ${moneyLabel(max)}. Lebih dari itu, '
                'pembeli mundur.',
          ),
    );
    if (fee == null || !context.mounted) return;
    await run(context, () => submit('counter:$fee'));
  }

  /// Ronde 3: satu tawaran final setelah kontra-tawaran penjual.
  static Future<void> finalOffer(
    BuildContext context,
    TransferOffer offer,
    OfferSubmit submit,
  ) async {
    final fee = await showDialog<int>(
      context: context,
      builder:
          (_) => FeeDialog(
            title: 'Tawaran final',
            message:
                'Penjual meminta ${moneyLabel(offer.fee)}. Ini ronde terakhir: '
                'penjual hanya menerima atau menolak.',
            initialFee: TransferRules.finalMinimum(offer.fee),
            helper:
                'Diterima bila ≥ '
                '${moneyLabel(TransferRules.finalMinimum(offer.fee))} '
                '(${(TransferRules.finalAcceptAt * 100).round()}% dari kontra). '
                'Nominal ≥ kontra berarti menerima kontra.',
            confirmLabel: 'Kirim tawaran final',
          ),
    );
    if (fee == null || !context.mounted) return;
    await run(
      context,
      () => submit('final:$fee'),
      success: 'Tawaran final dikirim.',
    );
  }

  /// Kontrak pemain setelah harga disepakati.
  static Future<void> contract(
    BuildContext context,
    WidgetRef ref,
    TransferOffer offer,
    String playerName,
    OfferSubmit submit, {
    int? minWage,
  }) async {
    var wage = minWage;
    if (wage == null) {
      try {
        wage = (await ref.read(gameEngineProvider).transferQuote(offer.playerId))
            .expectedWage;
      } on StateError {
        wage = 0;
      }
    }
    if (!context.mounted) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (_) => ContractDialog(playerName: playerName, minWage: wage!),
    );
    if (choice == null || !context.mounted) return;
    await run(context, () => submit(choice));
  }
}

/// Tombol aksi untuk satu negosiasi, sesuai status dan arah tawaran.
class OfferActions extends ConsumerWidget {
  const OfferActions({
    super.key,
    required this.offer,
    required this.ourClubId,
    required this.playerName,
  });

  final TransferOffer offer;
  final String ourClubId;
  final String playerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> submit(String choice) =>
        GameActions.run(ref, (e) => e.respondToOffer(offer.id, choice));
    Future<void> simple(String choice, String success) =>
        TransferFlow.run(context, () => submit(choice), success: success);

    final incoming = offer.toClubId == ourClubId;
    final List<Widget> buttons;
    if (incoming && offer.status == TransferOfferStatus.awaitingContract) {
      buttons = [
        TextButton(
          onPressed: () => simple('reject', 'Tawaran ditolak.'),
          child: const Text('Tolak'),
        ),
        OutlinedButton(
          onPressed: () => TransferFlow.counterIncoming(context, offer, submit),
          child: const Text('Kontra'),
        ),
        FilledButton(
          onPressed: () => simple('accept', 'Pemain dijual.'),
          child: const Text('Terima'),
        ),
      ];
    } else if (offer.status == TransferOfferStatus.countered) {
      buttons = [
        TextButton(
          onPressed: () => simple('cancel', 'Negosiasi dibatalkan.'),
          child: const Text('Batalkan'),
        ),
        OutlinedButton(
          onPressed: () => TransferFlow.finalOffer(context, offer, submit),
          child: const Text('Tawaran final'),
        ),
        FilledButton(
          onPressed: () => simple('accept', 'Harga disepakati. Ajukan kontrak.'),
          child: const Text('Terima harga'),
        ),
      ];
    } else if (offer.status == TransferOfferStatus.awaitingContract) {
      buttons = [
        TextButton(
          onPressed: () => simple('cancel', 'Negosiasi dibatalkan.'),
          child: const Text('Batalkan'),
        ),
        FilledButton(
          onPressed:
              () => TransferFlow.contract(context, ref, offer, playerName, submit),
          child: const Text('Ajukan kontrak'),
        ),
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

/// Teks ringkas satu tawaran: syarat, ronde, dan alasan bila ditolak.
String offerSummary(TransferOffer o) {
  final parts = [
    TransferService.termsLabel(o.fee, o.installmentYears, o.sellOnPct),
    'Ronde ${o.round}/${TransferRules.maxRounds}',
  ];
  return parts.join(' · ');
}
