import 'package:flutter/material.dart';

import '../../domain/finance/money_label.dart';
import '../../domain/transfer/transfer_rules.dart';

/// Syarat tawaran: biaya (€K), cicilan (tahun), dan sell-on clause (%).
typedef BidTerms = ({int fee, int installmentYears, int sellOnPct});

// Setiap dialog memiliki TextEditingController sendiri dan membuangnya di
// dispose(), yaitu setelah animasi tutup dialog selesai. Membuang controller
// tepat setelah `showDialog` kembali membuat aplikasi error saat dialog
// masih dianimasikan.

/// Dialog tawaran ronde 1: biaya, cicilan, dan sell-on clause, dengan
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
        'Terlalu rendah: kemungkinan besar ditolak.',
        theme.colorScheme.error,
      ),
      < 1.0 => (
        'Di bawah harga minta: kemungkinan dibalas kontra-tawaran.',
        theme.colorScheme.tertiary,
      ),
      _ => ('Sesuai harga minta: kemungkinan diterima.', theme.colorScheme.primary),
    };

    return AlertDialog(
      title: const Text('Ajukan tawaran'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.playerName, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Harga minta klub: ${moneyLabel(widget.askingFee)}'),
          if (widget.isRival)
            Text(
              'Termasuk premi rival lokal +30%.',
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _fee,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Biaya transfer (€ ribu)',
              helperText: '1.000 = €1 juta',
            ),
          ),
          const SizedBox(height: 12),
          Text('Pembayaran', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('Langsung')),
              ButtonSegment(value: 2, label: Text('2 tahun')),
              ButtonSegment(value: 3, label: Text('3 tahun')),
            ],
            selected: {_installments},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _installments = s.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _sellOn,
            decoration: const InputDecoration(
              labelText: 'Sell-on clause untuk penjual',
            ),
            items: [
              for (final pct in TransferRules.sellOnOptions)
                DropdownMenuItem(
                  value: pct,
                  child: Text(pct == 0 ? 'Tanpa' : '$pct% penjualan berikutnya'),
                ),
            ],
            onChanged: (v) => setState(() => _sellOn = v ?? 0),
          ),
          const Divider(height: 24),
          Text(
            'Nilai bagi penjual: ${moneyLabel(value)} '
            '(${(ratio * 100).round()}% dari harga minta)',
          ),
          Text(verdict, style: TextStyle(color: color)),
          const SizedBox(height: 8),
          Text(
            _installments == 1
                ? 'Dibayar langsung: ${moneyLabel(upfront)}.'
                : 'Di muka ${moneyLabel(upfront)}, sisanya dicicil tiap 1 Juli.',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Anggaran transfer ${moneyLabel(widget.transferBudget)} · '
            'saldo ${moneyLabel(widget.balance)}',
            style: theme.textTheme.bodySmall,
          ),
          if (overBudget)
            Text(
              'Biaya melebihi anggaran transfer.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          if (overBalance)
            Text(
              'Saldo tidak cukup untuk pembayaran di muka.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          const SizedBox(height: 8),
          Text(
            'Negosiasi maksimal ${TransferRules.maxRounds} ronde: tawaran → '
            'kontra-tawaran → tawaran final. Respons dalam 1–2 hari.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
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
          child: const Text('Kirim'),
        ),
      ],
    );
  }
}

/// Dialog satu nominal (€K): kontra untuk tawaran masuk atau tawaran final.
class FeeDialog extends StatefulWidget {
  const FeeDialog({
    super.key,
    required this.title,
    required this.message,
    required this.initialFee,
    this.helper,
    this.confirmLabel = 'Kirim',
  });

  final String title;
  final String message;
  final int initialFee;
  final String? helper;
  final String confirmLabel;

  @override
  State<FeeDialog> createState() => _FeeDialogState();
}

class _FeeDialogState extends State<FeeDialog> {
  late final TextEditingController _fee = TextEditingController(
    text: '${widget.initialFee}',
  );

  @override
  void dispose() {
    _fee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fee = int.tryParse(_fee.text.trim()) ?? 0;
    return AlertDialog(
      title: Text(widget.title),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.message),
          const SizedBox(height: 12),
          TextField(
            controller: _fee,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Nominal (€ ribu)',
              helperText: widget.helper,
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(fee > 0 ? '= ${moneyLabel(fee)}' : ''),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: fee > 0 ? () => Navigator.pop<int>(context, fee) : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Dialog kontrak pemain: gaji per tahun (€K) dan durasi 1–5 tahun.
class ContractDialog extends StatefulWidget {
  const ContractDialog({
    super.key,
    required this.playerName,
    required this.minWage,
  });

  final String playerName;
  final int minWage; // €K per tahun

  @override
  State<ContractDialog> createState() => _ContractDialogState();
}

class _ContractDialogState extends State<ContractDialog> {
  late final TextEditingController _wage = TextEditingController(
    text: '${widget.minWage}',
  );
  int _years = 3;

  @override
  void dispose() {
    _wage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wage = int.tryParse(_wage.text.trim()) ?? 0;
    return AlertDialog(
      title: const Text('Negosiasi kontrak'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.playerName, style: theme.textTheme.titleMedium),
          Text('Gaji yang diharapkan minimal ${moneyLabel(widget.minWage)}/tahun.'),
          const SizedBox(height: 12),
          TextField(
            controller: _wage,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Gaji per tahun (€ ribu)'),
          ),
          if (wage > 0 && wage < widget.minWage)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Di bawah ekspektasi: pemain akan menolak.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          Text('Durasi kontrak', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          SegmentedButton<int>(
            segments: [
              for (var y = 1; y <= 5; y++)
                ButtonSegment(value: y, label: Text('$y th')),
            ],
            selected: {_years},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _years = s.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kembali'),
        ),
        FilledButton(
          onPressed:
              wage > 0
                  ? () => Navigator.pop<String>(context, 'wage:$wage|years:$_years')
                  : null,
          child: const Text('Ajukan kontrak'),
        ),
      ],
    );
  }
}
