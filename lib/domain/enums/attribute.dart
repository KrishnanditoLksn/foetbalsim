enum AttributeGroup {
  technical('Teknik'),
  mental('Mental'),
  physical('Fisik'),
  goalkeeping('Kiper');

  const AttributeGroup(this.label);
  final String label;
}

/// Atribut pemain, skala 1–20 (gaya Football Manager).
enum Attribute {
  // Teknik
  finishing(AttributeGroup.technical, 'Penyelesaian'),
  passing(AttributeGroup.technical, 'Operan'),
  dribbling(AttributeGroup.technical, 'Dribel'),
  firstTouch(AttributeGroup.technical, 'Sentuhan Pertama'),
  crossing(AttributeGroup.technical, 'Umpan Silang'),
  tackling(AttributeGroup.technical, 'Tekel'),
  heading(AttributeGroup.technical, 'Sundulan'),
  technique(AttributeGroup.technical, 'Teknik'),

  // Mental
  decisions(AttributeGroup.mental, 'Keputusan'),
  positioning(AttributeGroup.mental, 'Posisi'),
  vision(AttributeGroup.mental, 'Visi'),
  composure(AttributeGroup.mental, 'Ketenangan'),
  workRate(AttributeGroup.mental, 'Etos Kerja'),
  aggression(AttributeGroup.mental, 'Agresi'),

  // Fisik
  pace(AttributeGroup.physical, 'Kecepatan'),
  acceleration(AttributeGroup.physical, 'Akselerasi'),
  stamina(AttributeGroup.physical, 'Stamina'),
  strength(AttributeGroup.physical, 'Kekuatan'),
  agility(AttributeGroup.physical, 'Kelincahan'),

  // Kiper
  handling(AttributeGroup.goalkeeping, 'Penanganan Bola'),
  reflexes(AttributeGroup.goalkeeping, 'Refleks'),
  oneOnOnes(AttributeGroup.goalkeeping, 'Satu Lawan Satu'),
  aerialReach(AttributeGroup.goalkeeping, 'Jangkauan Udara');

  const Attribute(this.group, this.label);

  final AttributeGroup group;
  final String label;
}
