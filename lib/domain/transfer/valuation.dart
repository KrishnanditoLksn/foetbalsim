import '../enums/squad_status.dart';
import '../models/game_models.dart';
import 'club_ai_profile.dart';

/// Valuasi harga minta dinamis (README_FASE3 B.4):
///
/// Harga = NilaiPasar × faktorUsia × faktorKontrak × faktorPeran
///         × faktorMarketHeat × faktorPenjual
abstract final class DynamicValuation {
  /// Harga minta klub penjual (€K). Pemain di daftar jual lebih murah (×1,0
  /// vs ×1,2). Pemain bintang lebih mahal, cadangan lebih murah.
  static int askingFee({
    required Player player,
    required Contract? contract,
    required DateTime now,
    double marketHeat = 1.0,
    ClubPersonality? sellerPersonality,
  }) {
    final listed = player.isTransferListed;
    var fee = player.marketValue * (listed ? 1.0 : 1.2);
    fee *= ageFactor(player.age);
    fee *= contractFactor(contract, now);
    fee *= roleFactor(contract?.squadStatus);
    fee *= marketHeat;
    fee *= sellerFactor(sellerPersonality);
    return _round(fee);
  }

  /// Puncak 24–28; turun setelah 30.
  static double ageFactor(int age) {
    if (age < 24) return 1.1;
    if (age <= 28) return 1.0;
    if (age <= 30) return 0.9;
    return 0.7;
  }

  /// Sisa ≤ 1 tahun → 0,6 · ≥ 4 tahun → 1,3 · di antaranya linear.
  ///
  /// Linear (bukan anak tangga) agar harga tidak melompat dalam semalam:
  /// dengan anak tangga, kontrak yang tersisa tepat 4 tahun turun dari ×1,3
  /// ke ×1,0 keesokan harinya, sehingga harga yang dilihat user saat menawar
  /// jauh berbeda dari harga yang dipakai penjual 1–2 hari kemudian.
  static double contractFactor(Contract? contract, DateTime now) {
    if (contract == null) return 1.0;
    final years = contract.endDate.difference(now).inDays / 365;
    if (years <= 1) return 0.6;
    if (years >= 4) return 1.3;
    return 0.6 + (years - 1) / 3 * 0.7;
  }

  /// Inti 1,4 · rotasi 1,0 · cadangan 0,7.
  static double roleFactor(SquadStatus? status) => switch (status) {
    SquadStatus.keyPlayer || SquadStatus.starter => 1.4,
    SquadStatus.rotation || null => 1.0,
    SquadStatus.backup || SquadStatus.youth => 0.7,
  };

  static double sellerFactor(ClubPersonality? p) => switch (p) {
    ClubPersonality.sellingClub => 0.9,
    ClubPersonality.bigSpender => 1.5,
    _ => 1.0,
  };

  /// Gaji per tahun yang diharapkan pemain (€K): dari CA dan usia.
  static int expectedWage(Player p) {
    final ca = p.currentAbility / 100;
    final ageFactor = p.age < 23 ? 0.6 : 1.0;
    final raw = ca * ca * 400 * ageFactor;
    return ((raw / 5).round() * 5).clamp(5, 1000000).toInt();
  }

  static int _round(double v) => (v / 10).round() * 10;
}
