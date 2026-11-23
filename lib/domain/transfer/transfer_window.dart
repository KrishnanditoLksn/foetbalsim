import 'dart:math' as math;

import '../models/game_models.dart';

/// Status jendela transfer pada tanggal tertentu.
class TransferWindowStatus {
  const TransferWindowStatus({
    required this.isOpen,
    required this.closesOn,
    required this.nextOpensOn,
  });

  final bool isOpen;
  final DateTime? closesOn; // ada bila [isOpen]
  final DateTime? nextOpensOn; // ada bila tidak [isOpen]
}

/// Aturan jendela transfer Eropa:
/// - Musim panas: 1 Juli – 31 Agustus
/// - Musim dingin: 1 Januari – 31 Januari
abstract final class TransferWindow {
  static bool isOpen(DateTime d) =>
      (d.month == 7 || d.month == 8) || d.month == 1;

  static TransferWindowStatus status(DateTime d) {
    final utc = DateTime.utc(d.year, d.month, d.day);
    if (isOpen(utc)) {
      final closes =
          utc.month == 1
              ? DateTime.utc(utc.year, 1, 31)
              : DateTime.utc(utc.year, 8, 31);
      return TransferWindowStatus(
        isOpen: true,
        closesOn: closes,
        nextOpensOn: null,
      );
    }
    final next =
        utc.month >= 9
            ? DateTime.utc(utc.year + 1, 1, 1)
            : DateTime.utc(utc.year, 7, 1);
    return TransferWindowStatus(
      isOpen: false,
      closesOn: null,
      nextOpensOn: next,
    );
  }
}

/// Valuasi harga dan ekspektasi gaji sebuah pemain.
abstract final class TransferValuation {
  /// Harga minimum yang diterima klub penjual (€K).
  /// Pemain di daftar jual lebih murah; kontrak panjang menaikkan harga.
  static int askingFee({
    required Player player,
    required Contract? contract,
    required DateTime now,
  }) {
    final listed = player.isTransferListed;
    var fee = player.marketValue * (listed ? 1.0 : 1.2);
    if (contract != null) {
      final yearsLeft = contract.endDate.difference(now).inDays / 365;
      if (yearsLeft < 1) fee *= 0.8;
      if (yearsLeft >= 3) fee *= 1.05;
    }
    return _round(fee);
  }

  /// Gaji per tahun yang diharapkan pemain (€K), mengikuti rumus generator
  /// gaji sehingga konsisten dengan kontrak awal.
  static int expectedWage(Player p) {
    final ageFactor = p.age < 23 ? 0.6 : 1.0;
    final raw = (p.currentAbility / 100) * (p.currentAbility / 100) *
        400 *
        ageFactor;
    return math.max(5, (raw / 5).round() * 5);
  }

  /// Tawaran dianggap wajar bila tidak kurang dari ask × 0,95.
  static bool fairFee(int offered, int asking) => offered * 100 >= asking * 95;

  static int _round(double v) => (v / 10).round() * 10;
}
