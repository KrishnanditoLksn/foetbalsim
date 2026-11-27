import 'package:flutter/material.dart';

import '../../domain/finance/money_label.dart';
import '../../domain/transfer/transfer_rules.dart';
import '../../l10n/l10n.dart';

/// Syarat tawaran: biaya (€K), cicilan (tahun), dan sell-on clause (%).
typedef BidTerms = ({int fee, int installmentYears, int sellOnPct});

// Setiap dialog memiliki TextEditingController sendiri dan membuangnya di
// dispose(), yaitu setelah animasi tutup dialog selesai. Membuang controller
// tepat setelah `showDialog` kembali membuat aplikasi error saat dialog
// masih dianimasikan.

/// Dialog tawaran pertama: biaya, cicilan, dan sell-on clause, dengan
/// perkiraan respons penjual sesuai ketentuan negosiasi.
class BidDialog extends StatefulWidget {
  const BidDialog({
    super.key,
    required this.playerName,
    required this.askingFee,
    required this.transferBudget,
    required this.balance,
    this.isRival = false,
  });

  final String playerName;
  final int askingFee; // €K
  final int transferBudget; // €K
  final int balance; // €K
  final bool isRival;

  @override
  State<BidDialog> createState() => _BidDialogState();
}

class _BidDialogState extends State<BidDialog> {
  late final TextEditingController _fee = TextEditingController(
    text: '${widget.askingFee}',
  );
  int _installments = 1;
  int _sellOn = 0;

  @override
  void dispose() {
    _fee.dispose();
    super.dispose();
  }

  int get _feeValue => int.tryParse(_fee.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fee = _feeValue;
    final value = TransferRules.offerValue(
      fee: fee,
      installmentYears: _installments,
      sellOnPct: _sellOn,
    );
    final ratio = widget.askingFee == 0 ? 0.0 : value / widget.askingFee;
    final upfront = fee <= 0 ? 0 : TransferRules.upfront(fee, _installments);
    final overBudget = fee > widget.transferBudget;
    final overBalance = upfront > widget.balance;
    final canSend = fee > 0 && !overBudget && !overBalance;

    final (verdict, color) = switch (ratio) {
      < TransferRules.rejectBelow => (
        tr('bid.tooLow'),
        theme.colorScheme.error,
      ),
      < 1.0 => (tr('bid.belowAsking'), theme.colorScheme.tertiary),
      _ => (tr('bid.atAsking'), theme.colorScheme.primary),
    };

    return AlertDialog(
      title: Text(tr('player.makeOffer')),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.playerName, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(tr('bid.asking', {'fee': moneyLabel(widget.askingFee)})),
          if (widget.isRival)
            Text(tr('bid.rivalPremium'), style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _fee,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: tr('bid.feeLabel', {'unit': moneyUnitThousands()}),
              helperText: tr('bid.feeHelper'),
            ),
          ),
          const SizedBox(height: 12),
          Text(tr('bid.payment'), style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 1, label: Text(tr('bid.upfront'))),
              ButtonSegment(
                value: 2,
                label: Text(tr('common.years', {'n': 2})),
              ),
              ButtonSegment(
                value: 3,
                label: Text(tr('common.years', {'n': 3})),
              ),
            ],
            selected: {_installments},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _installments = s.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _sellOn,
            decoration: InputDecoration(labelText: tr('bid.sellOnLabel')),
            items: [
              for (final pct in TransferRules.sellOnOptions)
                DropdownMenuItem(
                  value: pct,
                  child: Text(
                    pct == 0
                        ? tr('bid.sellOnNone')
                        : tr('bid.sellOnPct', {'pct': pct}),
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _sellOn = v ?? 0),
          ),
          const Divider(height: 24),
          Text(
            tr('bid.valueToSeller', {
              'value': moneyLabel(value),
              'pct': (ratio * 100).round(),
            }),
          ),
          Text(verdict, style: TextStyle(color: color)),
          const SizedBox(height: 8),
          Text(
            _installments == 1
                ? tr('bid.paidUpfront', {'amount': moneyLabel(upfront)})
                : tr('bid.paidInstallments', {'amount': moneyLabel(upfront)}),
            style: theme.textTheme.bodySmall,
          ),
          Text(
            tr('bid.budgetLine', {
              'budget': moneyLabel(widget.transferBudget),
              'balance': moneyLabel(widget.balance),
            }),
            style: theme.textTheme.bodySmall,
          ),
          if (overBudget)
            Text(
              tr('bid.overBudget'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          if (overBalance)
            Text(
              tr('bid.overBalance'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          const SizedBox(height: 8),
          Text(tr('bid.note'), style: theme.textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr('common.cancel')),
        ),
        FilledButton(
          onPressed:
              canSend
                  ? () => Navigator.pop<BidTerms>(context, (
                    fee: fee,
                    installmentYears: _installments,
                    sellOnPct: _sellOn,
                  ))
                  : null,
          child: Text(tr('bid.send')),
        ),
      ],
    );
  }
}
