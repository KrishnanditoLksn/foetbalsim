import '../models/game_models.dart';
import 'valuation.dart';

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

/// Aturan jendela transfer Eropa (README_SEASON_CALENDAR §2):
/// - Musim panas: 1 Juli – 31 Agustus
/// - Musim dingin: 1 Januari – 31 Januari
abstract final class TransferWindow {
  static bool isOpen(DateTime d) =>
      (d.month == 7 || d.month == 8) || d.month == 1;

  /// Tiga hari terakhir jendela (Deadline Day, README_FASE3 B.8).
  static bool isDeadlineDay(DateTime d) {
    if (!isOpen(d)) return false;
    final closes = status(d).closesOn;
    if (closes == null) return false;
    final left = closes.difference(DateTime.utc(d.year, d.month, d.day)).inDays;
    return left >= 0 && left <= 2;
  }

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

/// Valuasi harga dan ekspektasi gaji (kompatibilitas; logika di
/// [DynamicValuation]).
abstract final class TransferValuation {
  /// Harga minta klub penjual (€K) pada kondisi normal.
  static int askingFee({
    required Player player,
    required Contract? contract,
    required DateTime now,
  }) =>
      DynamicValuation.askingFee(player: player, contract: contract, now: now);

  /// Gaji per tahun yang diharapkan pemain (€K).
  static int expectedWage(Player p) => DynamicValuation.expectedWage(p);

  /// Tawaran dianggap wajar bila tidak kurang dari ask × 0,95.
  static bool fairFee(int offered, int asking) => offered * 100 >= asking * 95;
}
