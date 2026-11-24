import '../models/game_models.dart';

/// Kemauan pemain untuk pindah (README_FASE3 B.10.4).
class PlayerWillingness {
  /// Keputusan pemain. [fromRep] & [toRep] adalah reputasi klub asal dan
  /// tujuan (1–100). [wageOffer] dibanding [expectedWage] menentukan bujukan.
  static ({bool willing, String? reason}) decide({
    required Player player,
    required int fromRep,
    required int toRep,
    required int wageOffer,
    required int expectedWage,
    required bool isBenchPlayer,
    required bool shortContractInJanuary,
  }) {
    if (shortContractInJanuary) {
      return (
        willing: false,
        reason: 'Kontrak tinggal ≤ 6 bulan: menunggu bebas transfer.',
      );
    }
    final movingUp = toRep >= fromRep + 10;
    final movingDown = toRep <= fromRep - 10;
    final richer = wageOffer >= expectedWage * 1.15;
    final lowMorale = player.morale < 40;

    if (movingUp) return (willing: true, reason: null);
    if (movingDown) {
      if (richer || player.age >= 31 || lowMorale) {
        return (willing: true, reason: null);
      }
      return (
        willing: false,
        reason: '${player.lastName} tidak mau turun kelas tanpa kenaikan gaji.',
      );
    }
    // Pindah sekelas: cadangan mau demi menit bermain; inti butuh gaji wajar.
    if (isBenchPlayer || wageOffer >= expectedWage || lowMorale) {
      return (willing: true, reason: null);
    }
    return (
      willing: false,
      reason: '${player.lastName} menolak gaji yang ditawarkan.',
    );
  }
}
