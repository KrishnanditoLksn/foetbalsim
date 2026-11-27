import '../../l10n/l10n.dart';

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
  pending,
  awaitingContract,
  countered,
  completed,
  rejected,
  failed,
  withdrawn;

  String get label => tr('offerStatus.$name');
}

/// Jenis catatan di riwayat transfer.
enum TransferType {
  buy,
  sell,
  aiDeal;

  String get label => tr('transferType.$name');
}

/// Status yang ditampilkan pada berita transfer di Inbox (snapshot saat
/// berita dibuat, bukan status tawaran saat ini).
enum TransferNewsStatus {
  completed,
  incomingOffer,
  pendingBid,
  counterOffer,
  contractTalks,
  offered,
  rejected,
  failed,
  cancelled;

  String get label => tr('txStatus.$name');

  /// Transfer sudah terjadi: kontrak di payload adalah kontrak baru.
  bool get isDone => this == completed;

  /// Transfer tidak terjadi: kontrak baru tidak ditampilkan.
  bool get isDead => this == rejected || this == failed || this == cancelled;
}
