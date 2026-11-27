import '../../l10n/l10n.dart';

enum SquadStatus {
  keyPlayer,
  starter,
  rotation,
  backup,
  youth;

  String get label => tr('squadStatus.$name');
}
