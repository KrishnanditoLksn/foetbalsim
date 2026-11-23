/// Mentalitas tim. [attackBias] mengalikan frekuensi serangan, [pushShift]
/// menggeser garis tim ke depan (+) atau ke belakang (−) sebagai fraksi lapangan.
enum Mentality {
  defensive('Bertahan', 0.8, -0.05),
  balanced('Seimbang', 1.0, 0.0),
  attacking('Menyerang', 1.25, 0.05);

  const Mentality(this.label, this.attackBias, this.pushShift);

  final String label;
  final double attackBias;
  final double pushShift;
}

/// Kelompok posisi dalam slot formasi (kedalaman dari gawang sendiri).
enum SlotRole { gk, def, mid, fwd }

/// Satu slot di formasi. [depth] 0 = gawang sendiri, 1 = gawang lawan;
/// [lateral] 0 = sisi kiri, 1 = sisi kanan (pandangan tim kandang).
class FormationSlot {
  const FormationSlot(this.role, this.depth, this.lateral, this.label);

  final SlotRole role;
  final double depth;
  final double lateral;
  final String label;
}

/// Formasi yang tersedia. Urutan [slots] = urutan starter di [ClubTactic].
enum Formation {
  f442('4-4-2', [
    FormationSlot(SlotRole.gk, 0.04, 0.5, 'GK'),
    FormationSlot(SlotRole.def, 0.22, 0.15, 'DL'),
    FormationSlot(SlotRole.def, 0.20, 0.38, 'DC'),
    FormationSlot(SlotRole.def, 0.20, 0.62, 'DC'),
    FormationSlot(SlotRole.def, 0.22, 0.85, 'DR'),
    FormationSlot(SlotRole.mid, 0.46, 0.15, 'ML'),
    FormationSlot(SlotRole.mid, 0.42, 0.38, 'MC'),
    FormationSlot(SlotRole.mid, 0.42, 0.62, 'MC'),
    FormationSlot(SlotRole.mid, 0.46, 0.85, 'MR'),
    FormationSlot(SlotRole.fwd, 0.72, 0.38, 'ST'),
    FormationSlot(SlotRole.fwd, 0.72, 0.62, 'ST'),
  ]),
  f433('4-3-3', [
    FormationSlot(SlotRole.gk, 0.04, 0.5, 'GK'),
    FormationSlot(SlotRole.def, 0.22, 0.15, 'DL'),
    FormationSlot(SlotRole.def, 0.20, 0.38, 'DC'),
    FormationSlot(SlotRole.def, 0.20, 0.62, 'DC'),
    FormationSlot(SlotRole.def, 0.22, 0.85, 'DR'),
    FormationSlot(SlotRole.mid, 0.42, 0.30, 'MC'),
    FormationSlot(SlotRole.mid, 0.46, 0.50, 'DMC'),
    FormationSlot(SlotRole.mid, 0.42, 0.70, 'MC'),
    FormationSlot(SlotRole.fwd, 0.72, 0.18, 'AML'),
    FormationSlot(SlotRole.fwd, 0.76, 0.50, 'ST'),
    FormationSlot(SlotRole.fwd, 0.72, 0.82, 'AMR'),
  ]),
  f4231('4-2-3-1', [
    FormationSlot(SlotRole.gk, 0.04, 0.5, 'GK'),
    FormationSlot(SlotRole.def, 0.22, 0.15, 'DL'),
    FormationSlot(SlotRole.def, 0.20, 0.38, 'DC'),
    FormationSlot(SlotRole.def, 0.20, 0.62, 'DC'),
    FormationSlot(SlotRole.def, 0.22, 0.85, 'DR'),
    FormationSlot(SlotRole.mid, 0.36, 0.38, 'DMC'),
    FormationSlot(SlotRole.mid, 0.36, 0.62, 'DMC'),
    FormationSlot(SlotRole.mid, 0.56, 0.18, 'AML'),
    FormationSlot(SlotRole.mid, 0.60, 0.50, 'AMC'),
    FormationSlot(SlotRole.mid, 0.56, 0.82, 'AMR'),
    FormationSlot(SlotRole.fwd, 0.76, 0.50, 'ST'),
  ]),
  f352('3-5-2', [
    FormationSlot(SlotRole.gk, 0.04, 0.5, 'GK'),
    FormationSlot(SlotRole.def, 0.20, 0.28, 'DC'),
    FormationSlot(SlotRole.def, 0.18, 0.50, 'DC'),
    FormationSlot(SlotRole.def, 0.20, 0.72, 'DC'),
    FormationSlot(SlotRole.mid, 0.44, 0.10, 'MR'),
    FormationSlot(SlotRole.mid, 0.40, 0.32, 'MC'),
    FormationSlot(SlotRole.mid, 0.46, 0.50, 'DMC'),
    FormationSlot(SlotRole.mid, 0.40, 0.68, 'MC'),
    FormationSlot(SlotRole.mid, 0.44, 0.90, 'ML'),
    FormationSlot(SlotRole.fwd, 0.72, 0.38, 'ST'),
    FormationSlot(SlotRole.fwd, 0.72, 0.62, 'ST'),
  ]),
  f532('5-3-2', [
    FormationSlot(SlotRole.gk, 0.04, 0.5, 'GK'),
    FormationSlot(SlotRole.def, 0.22, 0.08, 'DL'),
    FormationSlot(SlotRole.def, 0.18, 0.28, 'DC'),
    FormationSlot(SlotRole.def, 0.18, 0.50, 'DC'),
    FormationSlot(SlotRole.def, 0.18, 0.72, 'DC'),
    FormationSlot(SlotRole.def, 0.22, 0.92, 'DR'),
    FormationSlot(SlotRole.mid, 0.42, 0.30, 'MC'),
    FormationSlot(SlotRole.mid, 0.46, 0.50, 'DMC'),
    FormationSlot(SlotRole.mid, 0.42, 0.70, 'MC'),
    FormationSlot(SlotRole.fwd, 0.72, 0.38, 'ST'),
    FormationSlot(SlotRole.fwd, 0.72, 0.62, 'ST'),
  ]);

  const Formation(this.label, this.slots);

  final String label;
  final List<FormationSlot> slots;
}
