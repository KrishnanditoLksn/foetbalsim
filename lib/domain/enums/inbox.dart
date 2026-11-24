enum InboxCategory {
  board('Dewan'),
  match('Pertandingan'),
  scouting('Scouting'),
  finance('Keuangan'),
  contract('Kontrak'),
  season('Musim'),
  transfer('Transfer');

  const InboxCategory(this.label);
  final String label;
}

/// Jenis tindakan yang diminta dari pemain. Pesan dengan tindakan selain
/// [none] yang belum diselesaikan menghentikan CONTINUE.
enum InboxActionType {
  none,
  acceptTarget,
  contractDecision,
  incomingTransferOffer,
  contractNegotiation,
  counterOffer,
}
