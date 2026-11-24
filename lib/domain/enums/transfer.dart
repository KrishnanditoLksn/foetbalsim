/// Status tawaran transfer.
/// - pending: menunggu respons klub penjual (1–2 hari).
/// - awaitingContract: menunggu keputusan kita (tawaran masuk) atau
///   kesepakatan kontrak pemain (tawaran keluar yang diterima klub penjual).
/// - countered: penjual memberi kontra-tawaran, menunggu jawaban kita.
/// - completed: transfer selesai dan pemain pindah klub.
/// - rejected: ditolak klub penjual.
/// - failed: pemain menolak kontrak yang diajukan.
/// - withdrawn: dibatalkan atau kedaluwarsa karena pemain sudah pindah.
enum TransferOfferStatus {
  pending('Menunggu'),
  awaitingContract('Negosiasi kontrak'),
  countered('Kontra-tawaran'),
  completed('Selesai'),
  rejected('Ditolak'),
  failed('Gagal'),
  withdrawn('Dibatalkan');

  const TransferOfferStatus(this.label);
  final String label;
}

/// Jenis catatan di riwayat transfer.
enum TransferType {
  buy('Pembelian'),
  sell('Penjualan'),
  aiDeal('Transfer AI');

  const TransferType(this.label);
  final String label;
}
