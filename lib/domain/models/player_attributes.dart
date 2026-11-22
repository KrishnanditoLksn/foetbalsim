import '../enums/attribute.dart';

/// Kumpulan atribut satu pemain (immutable).
class PlayerAttributes {
  PlayerAttributes(Map<Attribute, int> values)
    : _values = Map.unmodifiable(values);

  final Map<Attribute, int> _values;

  /// Nilai atribut 1–20. Atribut yang belum diisi dianggap 1.
  int operator [](Attribute attribute) => _values[attribute] ?? 1;

  Map<Attribute, int> get values => _values;

  /// Atribut dikelompokkan per [AttributeGroup] untuk ditampilkan di UI.
  Map<AttributeGroup, List<Attribute>> get byGroup {
    final result = <AttributeGroup, List<Attribute>>{};
    for (final group in AttributeGroup.values) {
      result[group] = [
        for (final a in Attribute.values)
          if (a.group == group) a,
      ];
    }
    return result;
  }
}
