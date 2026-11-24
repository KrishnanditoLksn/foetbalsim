import 'transfer_window.dart';

/// Ketentuan bursa transfer (README_FASE3 B.5, B.9, B.10.7) dalam satu tempat.
/// Dipakai oleh layanan transfer (validasi & evaluasi) dan UI (opsi & teks).
abstract final class TransferRules {
  /// Ukuran skuad yang dijaga untuk semua klub.
  static const int minSquad = 22;
  static const int maxSquad = 30;

  /// Maksimal pemain masuk dan keluar per klub dalam satu jendela.
  static const int maxMovesPerWindow = 6;

  /// Maksimal ronde negosiasi: tawaran → kontra-tawaran → tawaran final.
  static const int maxRounds = 3;

  /// Cicilan: 1 = dibayar langsung, 2 atau 3 = dibagi rata per tahun.
  static const List<int> installmentOptions = [1, 2, 3];

  /// Sell-on clause: 0 (tanpa) atau 10–30% dari penjualan berikutnya.
  static const List<int> sellOnOptions = [0, 10, 15, 20, 25, 30];

  /// Tawaran di bawah ini (rasio nilai / harga minta) langsung ditolak.
  static const double rejectBelow = 0.70;

  /// Tawaran final diterima bila nilainya ≥ rasio ini dari kontra penjual.
  static const double finalAcceptAt = 0.97;

  /// Nominal minimum tawaran final yang diterima untuk kontra [counterFee].
  static int finalMinimum(int counterFee) =>
      (counterFee * finalAcceptAt / 10).ceil() * 10;

  /// Klausul balik untuk tawaran masuk: klub pembeli menerima kontra kita
  /// bila tidak lebih dari 5% di atas tawarannya.
  static const double counterTolerance = 1.05;

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
