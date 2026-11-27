import '../../l10n/l10n.dart';

/// Kelompok besar posisi, dipakai untuk filter di layar skuad.
enum PositionGroup {
  goalkeeper,
  defender,
  midfielder,
  forward;

  String get label => tr('posGroup.$name');
}

enum Position {
  gk('GK', PositionGroup.goalkeeper),
  dr('DR', PositionGroup.defender),
  dc('DC', PositionGroup.defender),
  dl('DL', PositionGroup.defender),
  dmc('DMC', PositionGroup.midfielder),
  mr('MR', PositionGroup.midfielder),
  mc('MC', PositionGroup.midfielder),
  ml('ML', PositionGroup.midfielder),
  amr('AMR', PositionGroup.forward),
  amc('AMC', PositionGroup.midfielder),
  aml('AML', PositionGroup.forward),
  st('ST', PositionGroup.forward);

  const Position(this.label, this.group);

  final String label;
  final PositionGroup group;
}
