import 'transfer_window.dart';

/// Ketentuan bursa transfer (README_FASE3 B.5, B.9, B.10.7) dalam satu tempat.
/// Dipakai oleh layanan transfer (validasi & evaluasi) dan UI (opsi & teks).
abstract final class TransferRules {
  /// Ukuran skuad yang dijaga untuk semua klub.
  static const int minSquad = 22;
  static const int maxSquad = 30;

  /// Maksimal pemain masuk dan keluar per klub dalam satu jendela.
  static const int maxMovesPerWindow = 6;

  /// Cicilan: 1 = dibayar langsung, 2 atau 3 = dibagi rata per tahun.
  static const List<int> installmentOptions = [1, 2, 3];

  /// Sell-on clause: 0 (tanpa) atau 10–30% dari penjualan berikutnya.
  static const List<int> sellOnOptions = [0, 10, 15, 20, 25, 30];

  /// Tawaran di bawah ini (rasio nilai / harga minta) langsung ditolak.
  static const double rejectBelow = 0.70;

  // --- Ruang Negosiasi (README_NEGOTIATION_ROOM) ----------------------------

  /// Setelah agen walk-out, pemain baru bisa ditawar lagi setelah jeda ini.
  static const Duration walkOutCooldown = Duration(days: 7);

  /// Batas bawah penjual dibanding harga minta: 88% (negosiator lemah) s/d
  /// 96% (negosiator ulung), digeser gaya agen.
  static double sellerFloorRatio(int negotiationSkill, double agentShift) =>
      (0.88 + 0.08 * negotiationSkill / 100 + agentShift).clamp(0.86, 0.98);

  /// Pemain inti tanpa pengganti: penjual tidak turun di bawah ini.
  static const double indispensableFloor = 1.10;

  /// Batas atas pembeli dibanding tawaran pembukanya (1,05–1,25).
  static const double minBuyerCeiling = 1.05;
  static const double maxBuyerCeiling = 1.25;

  /// Premi harga untuk transfer antar-rival lokal.
  static const double rivalPremium = 1.30;

  static const Set<(String, String)> _rivals = {
    ('real-madrid', 'atletico-madrid'),
    ('real-madrid', 'barcelona'),
    ('barcelona', 'espanyol'),
    ('real-betis', 'sevilla'),
    ('athletic-club', 'real-sociedad'),
    ('valencia', 'levante'),
    ('real-oviedo', 'sporting-gijon'),
    ('celta', 'deportivo'),
  };

  static bool areRivals(String a, String b) =>
      _rivals.contains((a, b)) || _rivals.contains((b, a));

  static bool validInstallments(int years) =>
      installmentOptions.contains(years);

  static bool validSellOn(int pct) => sellOnOptions.contains(pct);

  /// Bobot syarat pembayaran bagi penjual: cicilan mengurangi nilai,
  /// sell-on clause menambah nilai (penjual dapat bagian penjualan berikutnya).
  static double termsFactor({required int installmentYears, required int sellOnPct}) {
    final installment = switch (installmentYears) {
      2 => 0.95,
      3 => 0.92,
      _ => 1.0,
    };
    return installment * (1 + sellOnPct * 0.003);
  }

  /// Nilai tawaran di mata penjual (€K), dipakai untuk evaluasi negosiasi.
  static int offerValue({
    required int fee,
    required int installmentYears,
    required int sellOnPct,
  }) =>
      (fee * termsFactor(installmentYears: installmentYears, sellOnPct: sellOnPct))
          .round();

  /// Pembayaran di muka (€K): cicilan pertama, sisanya tiap 1 Juli.
  static int upfront(int fee, int installmentYears) =>
      (fee / installmentYears).ceil();

  /// Awal jendela transfer yang memuat [date] (null bila jendela tutup).
  static DateTime? windowStart(DateTime date) {
    if (!TransferWindow.isOpen(date)) return null;
    return date.month == 1
        ? DateTime.utc(date.year, 1, 1)
        : DateTime.utc(date.year, 7, 1);
  }
}
