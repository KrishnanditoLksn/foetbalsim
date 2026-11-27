import '../../l10n/l10n.dart';

enum InboxCategory {
  board,
  match,
  scouting,
  finance,
  contract,
  season,
  transfer;

  String get label => tr('inboxCat.$name');
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
