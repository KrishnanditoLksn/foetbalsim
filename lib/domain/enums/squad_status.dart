enum SquadStatus {
  keyPlayer('Pilar'),
  starter('Starter'),
  rotation('Rotasi'),
  backup('Cadangan'),
  youth('Muda');

  const SquadStatus(this.label);
  final String label;
}
