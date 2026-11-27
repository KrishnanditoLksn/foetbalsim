import '../../l10n/l10n.dart';

enum AttributeGroup {
  technical,
  mental,
  physical,
  goalkeeping;

  String get label => tr('attrGroup.$name');
}

/// Atribut pemain, skala 1–20 (gaya Football Manager).
enum Attribute {
  // Teknik
  finishing(AttributeGroup.technical),
  passing(AttributeGroup.technical),
  dribbling(AttributeGroup.technical),
  firstTouch(AttributeGroup.technical),
  crossing(AttributeGroup.technical),
  tackling(AttributeGroup.technical),
  heading(AttributeGroup.technical),
  technique(AttributeGroup.technical),

  // Mental
  decisions(AttributeGroup.mental),
  positioning(AttributeGroup.mental),
  vision(AttributeGroup.mental),
  composure(AttributeGroup.mental),
  workRate(AttributeGroup.mental),
  aggression(AttributeGroup.mental),

  // Fisik
  pace(AttributeGroup.physical),
  acceleration(AttributeGroup.physical),
  stamina(AttributeGroup.physical),
  strength(AttributeGroup.physical),
  agility(AttributeGroup.physical),

  // Kiper
  handling(AttributeGroup.goalkeeping),
  reflexes(AttributeGroup.goalkeeping),
  oneOnOnes(AttributeGroup.goalkeeping),
  aerialReach(AttributeGroup.goalkeeping);

  const Attribute(this.group);

  final AttributeGroup group;
  String get label => tr('attr.$name');
}
