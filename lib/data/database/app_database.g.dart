// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NationsTable extends Nations with TableInfo<$NationsTable, NationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, code];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nations';
  @override
  VerificationContext validateIntegrity(
    Insertable<NationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NationRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      code:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}code'],
          )!,
    );
  }

  @override
  $NationsTable createAlias(String alias) {
    return $NationsTable(attachedDatabase, alias);
  }
}

class NationRow extends DataClass implements Insertable<NationRow> {
  final String id;
  final String name;
  final String code;
  const NationRow({required this.id, required this.name, required this.code});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    return map;
  }

  NationsCompanion toCompanion(bool nullToAbsent) {
    return NationsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
    );
  }

  factory NationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NationRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
    };
  }

  NationRow copyWith({String? id, String? name, String? code}) => NationRow(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
  );
  NationRow copyWithCompanion(NationsCompanion data) {
    return NationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code);
}

class NationsCompanion extends UpdateCompanion<NationRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<int> rowid;
  const NationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NationsCompanion.insert({
    required String id,
    required String name,
    required String code,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       code = Value(code);
  static Insertable<NationRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? code,
    Value<int>? rowid,
  }) {
    return NationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeaguesTable extends Leagues with TableInfo<$LeaguesTable, LeagueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaguesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nationIdMeta = const VerificationMeta(
    'nationId',
  );
  @override
  late final GeneratedColumn<String> nationId = GeneratedColumn<String>(
    'nation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jumlahTimMeta = const VerificationMeta(
    'jumlahTim',
  );
  @override
  late final GeneratedColumn<int> jumlahTim = GeneratedColumn<int>(
    'jumlah_tim',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotPromosiMeta = const VerificationMeta(
    'slotPromosi',
  );
  @override
  late final GeneratedColumn<int> slotPromosi = GeneratedColumn<int>(
    'slot_promosi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotDegradasiMeta = const VerificationMeta(
    'slotDegradasi',
  );
  @override
  late final GeneratedColumn<int> slotDegradasi = GeneratedColumn<int>(
    'slot_degradasi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotPlayoffMeta = const VerificationMeta(
    'slotPlayoff',
  );
  @override
  late final GeneratedColumn<int> slotPlayoff = GeneratedColumn<int>(
    'slot_playoff',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nationId,
    name,
    tier,
    jumlahTim,
    slotPromosi,
    slotDegradasi,
    slotPlayoff,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leagues';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeagueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nation_id')) {
      context.handle(
        _nationIdMeta,
        nationId.isAcceptableOrUnknown(data['nation_id']!, _nationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('jumlah_tim')) {
      context.handle(
        _jumlahTimMeta,
        jumlahTim.isAcceptableOrUnknown(data['jumlah_tim']!, _jumlahTimMeta),
      );
    } else if (isInserting) {
      context.missing(_jumlahTimMeta);
    }
    if (data.containsKey('slot_promosi')) {
      context.handle(
        _slotPromosiMeta,
        slotPromosi.isAcceptableOrUnknown(
          data['slot_promosi']!,
          _slotPromosiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_slotPromosiMeta);
    }
    if (data.containsKey('slot_degradasi')) {
      context.handle(
        _slotDegradasiMeta,
        slotDegradasi.isAcceptableOrUnknown(
          data['slot_degradasi']!,
          _slotDegradasiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_slotDegradasiMeta);
    }
    if (data.containsKey('slot_playoff')) {
      context.handle(
        _slotPlayoffMeta,
        slotPlayoff.isAcceptableOrUnknown(
          data['slot_playoff']!,
          _slotPlayoffMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeagueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeagueRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      nationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nation_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      tier:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}tier'],
          )!,
      jumlahTim:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}jumlah_tim'],
          )!,
      slotPromosi:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}slot_promosi'],
          )!,
      slotDegradasi:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}slot_degradasi'],
          )!,
      slotPlayoff:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}slot_playoff'],
          )!,
    );
  }

  @override
  $LeaguesTable createAlias(String alias) {
    return $LeaguesTable(attachedDatabase, alias);
  }
}

class LeagueRow extends DataClass implements Insertable<LeagueRow> {
  final String id;
  final String nationId;
  final String name;
  final int tier;
  final int jumlahTim;
  final int slotPromosi;
  final int slotDegradasi;
  final int slotPlayoff;
  const LeagueRow({
    required this.id,
    required this.nationId,
    required this.name,
    required this.tier,
    required this.jumlahTim,
    required this.slotPromosi,
    required this.slotDegradasi,
    required this.slotPlayoff,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nation_id'] = Variable<String>(nationId);
    map['name'] = Variable<String>(name);
    map['tier'] = Variable<int>(tier);
    map['jumlah_tim'] = Variable<int>(jumlahTim);
    map['slot_promosi'] = Variable<int>(slotPromosi);
    map['slot_degradasi'] = Variable<int>(slotDegradasi);
    map['slot_playoff'] = Variable<int>(slotPlayoff);
    return map;
  }

  LeaguesCompanion toCompanion(bool nullToAbsent) {
    return LeaguesCompanion(
      id: Value(id),
      nationId: Value(nationId),
      name: Value(name),
      tier: Value(tier),
      jumlahTim: Value(jumlahTim),
      slotPromosi: Value(slotPromosi),
      slotDegradasi: Value(slotDegradasi),
      slotPlayoff: Value(slotPlayoff),
    );
  }

  factory LeagueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeagueRow(
      id: serializer.fromJson<String>(json['id']),
      nationId: serializer.fromJson<String>(json['nationId']),
      name: serializer.fromJson<String>(json['name']),
      tier: serializer.fromJson<int>(json['tier']),
      jumlahTim: serializer.fromJson<int>(json['jumlahTim']),
      slotPromosi: serializer.fromJson<int>(json['slotPromosi']),
      slotDegradasi: serializer.fromJson<int>(json['slotDegradasi']),
      slotPlayoff: serializer.fromJson<int>(json['slotPlayoff']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nationId': serializer.toJson<String>(nationId),
      'name': serializer.toJson<String>(name),
      'tier': serializer.toJson<int>(tier),
      'jumlahTim': serializer.toJson<int>(jumlahTim),
      'slotPromosi': serializer.toJson<int>(slotPromosi),
      'slotDegradasi': serializer.toJson<int>(slotDegradasi),
      'slotPlayoff': serializer.toJson<int>(slotPlayoff),
    };
  }

  LeagueRow copyWith({
    String? id,
    String? nationId,
    String? name,
    int? tier,
    int? jumlahTim,
    int? slotPromosi,
    int? slotDegradasi,
    int? slotPlayoff,
  }) => LeagueRow(
    id: id ?? this.id,
    nationId: nationId ?? this.nationId,
    name: name ?? this.name,
    tier: tier ?? this.tier,
    jumlahTim: jumlahTim ?? this.jumlahTim,
    slotPromosi: slotPromosi ?? this.slotPromosi,
    slotDegradasi: slotDegradasi ?? this.slotDegradasi,
    slotPlayoff: slotPlayoff ?? this.slotPlayoff,
  );
  LeagueRow copyWithCompanion(LeaguesCompanion data) {
    return LeagueRow(
      id: data.id.present ? data.id.value : this.id,
      nationId: data.nationId.present ? data.nationId.value : this.nationId,
      name: data.name.present ? data.name.value : this.name,
      tier: data.tier.present ? data.tier.value : this.tier,
      jumlahTim: data.jumlahTim.present ? data.jumlahTim.value : this.jumlahTim,
      slotPromosi:
          data.slotPromosi.present ? data.slotPromosi.value : this.slotPromosi,
      slotDegradasi:
          data.slotDegradasi.present
              ? data.slotDegradasi.value
              : this.slotDegradasi,
      slotPlayoff:
          data.slotPlayoff.present ? data.slotPlayoff.value : this.slotPlayoff,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeagueRow(')
          ..write('id: $id, ')
          ..write('nationId: $nationId, ')
          ..write('name: $name, ')
          ..write('tier: $tier, ')
          ..write('jumlahTim: $jumlahTim, ')
          ..write('slotPromosi: $slotPromosi, ')
          ..write('slotDegradasi: $slotDegradasi, ')
          ..write('slotPlayoff: $slotPlayoff')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nationId,
    name,
    tier,
    jumlahTim,
    slotPromosi,
    slotDegradasi,
    slotPlayoff,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeagueRow &&
          other.id == this.id &&
          other.nationId == this.nationId &&
          other.name == this.name &&
          other.tier == this.tier &&
          other.jumlahTim == this.jumlahTim &&
          other.slotPromosi == this.slotPromosi &&
          other.slotDegradasi == this.slotDegradasi &&
          other.slotPlayoff == this.slotPlayoff);
}

class LeaguesCompanion extends UpdateCompanion<LeagueRow> {
  final Value<String> id;
  final Value<String> nationId;
  final Value<String> name;
  final Value<int> tier;
  final Value<int> jumlahTim;
  final Value<int> slotPromosi;
  final Value<int> slotDegradasi;
  final Value<int> slotPlayoff;
  final Value<int> rowid;
  const LeaguesCompanion({
    this.id = const Value.absent(),
    this.nationId = const Value.absent(),
    this.name = const Value.absent(),
    this.tier = const Value.absent(),
    this.jumlahTim = const Value.absent(),
    this.slotPromosi = const Value.absent(),
    this.slotDegradasi = const Value.absent(),
    this.slotPlayoff = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaguesCompanion.insert({
    required String id,
    required String nationId,
    required String name,
    required int tier,
    required int jumlahTim,
    required int slotPromosi,
    required int slotDegradasi,
    this.slotPlayoff = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nationId = Value(nationId),
       name = Value(name),
       tier = Value(tier),
       jumlahTim = Value(jumlahTim),
       slotPromosi = Value(slotPromosi),
       slotDegradasi = Value(slotDegradasi);
  static Insertable<LeagueRow> custom({
    Expression<String>? id,
    Expression<String>? nationId,
    Expression<String>? name,
    Expression<int>? tier,
    Expression<int>? jumlahTim,
    Expression<int>? slotPromosi,
    Expression<int>? slotDegradasi,
    Expression<int>? slotPlayoff,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nationId != null) 'nation_id': nationId,
      if (name != null) 'name': name,
      if (tier != null) 'tier': tier,
      if (jumlahTim != null) 'jumlah_tim': jumlahTim,
      if (slotPromosi != null) 'slot_promosi': slotPromosi,
      if (slotDegradasi != null) 'slot_degradasi': slotDegradasi,
      if (slotPlayoff != null) 'slot_playoff': slotPlayoff,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaguesCompanion copyWith({
    Value<String>? id,
    Value<String>? nationId,
    Value<String>? name,
    Value<int>? tier,
    Value<int>? jumlahTim,
    Value<int>? slotPromosi,
    Value<int>? slotDegradasi,
    Value<int>? slotPlayoff,
    Value<int>? rowid,
  }) {
    return LeaguesCompanion(
      id: id ?? this.id,
      nationId: nationId ?? this.nationId,
      name: name ?? this.name,
      tier: tier ?? this.tier,
      jumlahTim: jumlahTim ?? this.jumlahTim,
      slotPromosi: slotPromosi ?? this.slotPromosi,
      slotDegradasi: slotDegradasi ?? this.slotDegradasi,
      slotPlayoff: slotPlayoff ?? this.slotPlayoff,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nationId.present) {
      map['nation_id'] = Variable<String>(nationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (jumlahTim.present) {
      map['jumlah_tim'] = Variable<int>(jumlahTim.value);
    }
    if (slotPromosi.present) {
      map['slot_promosi'] = Variable<int>(slotPromosi.value);
    }
    if (slotDegradasi.present) {
      map['slot_degradasi'] = Variable<int>(slotDegradasi.value);
    }
    if (slotPlayoff.present) {
      map['slot_playoff'] = Variable<int>(slotPlayoff.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaguesCompanion(')
          ..write('id: $id, ')
          ..write('nationId: $nationId, ')
          ..write('name: $name, ')
          ..write('tier: $tier, ')
          ..write('jumlahTim: $jumlahTim, ')
          ..write('slotPromosi: $slotPromosi, ')
          ..write('slotDegradasi: $slotDegradasi, ')
          ..write('slotPlayoff: $slotPlayoff, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClubsTable extends Clubs with TableInfo<$ClubsTable, ClubRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClubsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leagueIdMeta = const VerificationMeta(
    'leagueId',
  );
  @override
  late final GeneratedColumn<String> leagueId = GeneratedColumn<String>(
    'league_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryColorMeta = const VerificationMeta(
    'primaryColor',
  );
  @override
  late final GeneratedColumn<String> primaryColor = GeneratedColumn<String>(
    'primary_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryColorMeta = const VerificationMeta(
    'secondaryColor',
  );
  @override
  late final GeneratedColumn<String> secondaryColor = GeneratedColumn<String>(
    'secondary_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reputationMeta = const VerificationMeta(
    'reputation',
  );
  @override
  late final GeneratedColumn<int> reputation = GeneratedColumn<int>(
    'reputation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stadiumNameMeta = const VerificationMeta(
    'stadiumName',
  );
  @override
  late final GeneratedColumn<String> stadiumName = GeneratedColumn<String>(
    'stadium_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferBudgetMeta = const VerificationMeta(
    'transferBudget',
  );
  @override
  late final GeneratedColumn<int> transferBudget = GeneratedColumn<int>(
    'transfer_budget',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wageBudgetMeta = const VerificationMeta(
    'wageBudget',
  );
  @override
  late final GeneratedColumn<int> wageBudget = GeneratedColumn<int>(
    'wage_budget',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    leagueId,
    name,
    shortName,
    primaryColor,
    secondaryColor,
    reputation,
    stadiumName,
    capacity,
    balance,
    transferBudget,
    wageBudget,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clubs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClubRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('league_id')) {
      context.handle(
        _leagueIdMeta,
        leagueId.isAcceptableOrUnknown(data['league_id']!, _leagueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leagueIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('primary_color')) {
      context.handle(
        _primaryColorMeta,
        primaryColor.isAcceptableOrUnknown(
          data['primary_color']!,
          _primaryColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryColorMeta);
    }
    if (data.containsKey('secondary_color')) {
      context.handle(
        _secondaryColorMeta,
        secondaryColor.isAcceptableOrUnknown(
          data['secondary_color']!,
          _secondaryColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondaryColorMeta);
    }
    if (data.containsKey('reputation')) {
      context.handle(
        _reputationMeta,
        reputation.isAcceptableOrUnknown(data['reputation']!, _reputationMeta),
      );
    } else if (isInserting) {
      context.missing(_reputationMeta);
    }
    if (data.containsKey('stadium_name')) {
      context.handle(
        _stadiumNameMeta,
        stadiumName.isAcceptableOrUnknown(
          data['stadium_name']!,
          _stadiumNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stadiumNameMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    } else if (isInserting) {
      context.missing(_capacityMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('transfer_budget')) {
      context.handle(
        _transferBudgetMeta,
        transferBudget.isAcceptableOrUnknown(
          data['transfer_budget']!,
          _transferBudgetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transferBudgetMeta);
    }
    if (data.containsKey('wage_budget')) {
      context.handle(
        _wageBudgetMeta,
        wageBudget.isAcceptableOrUnknown(data['wage_budget']!, _wageBudgetMeta),
      );
    } else if (isInserting) {
      context.missing(_wageBudgetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClubRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClubRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      leagueId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}league_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      shortName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}short_name'],
          )!,
      primaryColor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}primary_color'],
          )!,
      secondaryColor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}secondary_color'],
          )!,
      reputation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}reputation'],
          )!,
      stadiumName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}stadium_name'],
          )!,
      capacity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}capacity'],
          )!,
      balance:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}balance'],
          )!,
      transferBudget:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}transfer_budget'],
          )!,
      wageBudget:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}wage_budget'],
          )!,
    );
  }

  @override
  $ClubsTable createAlias(String alias) {
    return $ClubsTable(attachedDatabase, alias);
  }
}

class ClubRow extends DataClass implements Insertable<ClubRow> {
  final String id;
  final String leagueId;
  final String name;
  final String shortName;
  final String primaryColor;
  final String secondaryColor;
  final int reputation;
  final String stadiumName;
  final int capacity;
  final int balance;
  final int transferBudget;
  final int wageBudget;
  const ClubRow({
    required this.id,
    required this.leagueId,
    required this.name,
    required this.shortName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.reputation,
    required this.stadiumName,
    required this.capacity,
    required this.balance,
    required this.transferBudget,
    required this.wageBudget,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['league_id'] = Variable<String>(leagueId);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    map['primary_color'] = Variable<String>(primaryColor);
    map['secondary_color'] = Variable<String>(secondaryColor);
    map['reputation'] = Variable<int>(reputation);
    map['stadium_name'] = Variable<String>(stadiumName);
    map['capacity'] = Variable<int>(capacity);
    map['balance'] = Variable<int>(balance);
    map['transfer_budget'] = Variable<int>(transferBudget);
    map['wage_budget'] = Variable<int>(wageBudget);
    return map;
  }

  ClubsCompanion toCompanion(bool nullToAbsent) {
    return ClubsCompanion(
      id: Value(id),
      leagueId: Value(leagueId),
      name: Value(name),
      shortName: Value(shortName),
      primaryColor: Value(primaryColor),
      secondaryColor: Value(secondaryColor),
      reputation: Value(reputation),
      stadiumName: Value(stadiumName),
      capacity: Value(capacity),
      balance: Value(balance),
      transferBudget: Value(transferBudget),
      wageBudget: Value(wageBudget),
    );
  }

  factory ClubRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClubRow(
      id: serializer.fromJson<String>(json['id']),
      leagueId: serializer.fromJson<String>(json['leagueId']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String>(json['shortName']),
      primaryColor: serializer.fromJson<String>(json['primaryColor']),
      secondaryColor: serializer.fromJson<String>(json['secondaryColor']),
      reputation: serializer.fromJson<int>(json['reputation']),
      stadiumName: serializer.fromJson<String>(json['stadiumName']),
      capacity: serializer.fromJson<int>(json['capacity']),
      balance: serializer.fromJson<int>(json['balance']),
      transferBudget: serializer.fromJson<int>(json['transferBudget']),
      wageBudget: serializer.fromJson<int>(json['wageBudget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'leagueId': serializer.toJson<String>(leagueId),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String>(shortName),
      'primaryColor': serializer.toJson<String>(primaryColor),
      'secondaryColor': serializer.toJson<String>(secondaryColor),
      'reputation': serializer.toJson<int>(reputation),
      'stadiumName': serializer.toJson<String>(stadiumName),
      'capacity': serializer.toJson<int>(capacity),
      'balance': serializer.toJson<int>(balance),
      'transferBudget': serializer.toJson<int>(transferBudget),
      'wageBudget': serializer.toJson<int>(wageBudget),
    };
  }

  ClubRow copyWith({
    String? id,
    String? leagueId,
    String? name,
    String? shortName,
    String? primaryColor,
    String? secondaryColor,
    int? reputation,
    String? stadiumName,
    int? capacity,
    int? balance,
    int? transferBudget,
    int? wageBudget,
  }) => ClubRow(
    id: id ?? this.id,
    leagueId: leagueId ?? this.leagueId,
    name: name ?? this.name,
    shortName: shortName ?? this.shortName,
    primaryColor: primaryColor ?? this.primaryColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    reputation: reputation ?? this.reputation,
    stadiumName: stadiumName ?? this.stadiumName,
    capacity: capacity ?? this.capacity,
    balance: balance ?? this.balance,
    transferBudget: transferBudget ?? this.transferBudget,
    wageBudget: wageBudget ?? this.wageBudget,
  );
  ClubRow copyWithCompanion(ClubsCompanion data) {
    return ClubRow(
      id: data.id.present ? data.id.value : this.id,
      leagueId: data.leagueId.present ? data.leagueId.value : this.leagueId,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      primaryColor:
          data.primaryColor.present
              ? data.primaryColor.value
              : this.primaryColor,
      secondaryColor:
          data.secondaryColor.present
              ? data.secondaryColor.value
              : this.secondaryColor,
      reputation:
          data.reputation.present ? data.reputation.value : this.reputation,
      stadiumName:
          data.stadiumName.present ? data.stadiumName.value : this.stadiumName,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      balance: data.balance.present ? data.balance.value : this.balance,
      transferBudget:
          data.transferBudget.present
              ? data.transferBudget.value
              : this.transferBudget,
      wageBudget:
          data.wageBudget.present ? data.wageBudget.value : this.wageBudget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClubRow(')
          ..write('id: $id, ')
          ..write('leagueId: $leagueId, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('primaryColor: $primaryColor, ')
          ..write('secondaryColor: $secondaryColor, ')
          ..write('reputation: $reputation, ')
          ..write('stadiumName: $stadiumName, ')
          ..write('capacity: $capacity, ')
          ..write('balance: $balance, ')
          ..write('transferBudget: $transferBudget, ')
          ..write('wageBudget: $wageBudget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    leagueId,
    name,
    shortName,
    primaryColor,
    secondaryColor,
    reputation,
    stadiumName,
    capacity,
    balance,
    transferBudget,
    wageBudget,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClubRow &&
          other.id == this.id &&
          other.leagueId == this.leagueId &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.primaryColor == this.primaryColor &&
          other.secondaryColor == this.secondaryColor &&
          other.reputation == this.reputation &&
          other.stadiumName == this.stadiumName &&
          other.capacity == this.capacity &&
          other.balance == this.balance &&
          other.transferBudget == this.transferBudget &&
          other.wageBudget == this.wageBudget);
}

class ClubsCompanion extends UpdateCompanion<ClubRow> {
  final Value<String> id;
  final Value<String> leagueId;
  final Value<String> name;
  final Value<String> shortName;
  final Value<String> primaryColor;
  final Value<String> secondaryColor;
  final Value<int> reputation;
  final Value<String> stadiumName;
  final Value<int> capacity;
  final Value<int> balance;
  final Value<int> transferBudget;
  final Value<int> wageBudget;
  final Value<int> rowid;
  const ClubsCompanion({
    this.id = const Value.absent(),
    this.leagueId = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.primaryColor = const Value.absent(),
    this.secondaryColor = const Value.absent(),
    this.reputation = const Value.absent(),
    this.stadiumName = const Value.absent(),
    this.capacity = const Value.absent(),
    this.balance = const Value.absent(),
    this.transferBudget = const Value.absent(),
    this.wageBudget = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClubsCompanion.insert({
    required String id,
    required String leagueId,
    required String name,
    required String shortName,
    required String primaryColor,
    required String secondaryColor,
    required int reputation,
    required String stadiumName,
    required int capacity,
    required int balance,
    required int transferBudget,
    required int wageBudget,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       leagueId = Value(leagueId),
       name = Value(name),
       shortName = Value(shortName),
       primaryColor = Value(primaryColor),
       secondaryColor = Value(secondaryColor),
       reputation = Value(reputation),
       stadiumName = Value(stadiumName),
       capacity = Value(capacity),
       balance = Value(balance),
       transferBudget = Value(transferBudget),
       wageBudget = Value(wageBudget);
  static Insertable<ClubRow> custom({
    Expression<String>? id,
    Expression<String>? leagueId,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<String>? primaryColor,
    Expression<String>? secondaryColor,
    Expression<int>? reputation,
    Expression<String>? stadiumName,
    Expression<int>? capacity,
    Expression<int>? balance,
    Expression<int>? transferBudget,
    Expression<int>? wageBudget,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leagueId != null) 'league_id': leagueId,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (primaryColor != null) 'primary_color': primaryColor,
      if (secondaryColor != null) 'secondary_color': secondaryColor,
      if (reputation != null) 'reputation': reputation,
      if (stadiumName != null) 'stadium_name': stadiumName,
      if (capacity != null) 'capacity': capacity,
      if (balance != null) 'balance': balance,
      if (transferBudget != null) 'transfer_budget': transferBudget,
      if (wageBudget != null) 'wage_budget': wageBudget,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClubsCompanion copyWith({
    Value<String>? id,
    Value<String>? leagueId,
    Value<String>? name,
    Value<String>? shortName,
    Value<String>? primaryColor,
    Value<String>? secondaryColor,
    Value<int>? reputation,
    Value<String>? stadiumName,
    Value<int>? capacity,
    Value<int>? balance,
    Value<int>? transferBudget,
    Value<int>? wageBudget,
    Value<int>? rowid,
  }) {
    return ClubsCompanion(
      id: id ?? this.id,
      leagueId: leagueId ?? this.leagueId,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      reputation: reputation ?? this.reputation,
      stadiumName: stadiumName ?? this.stadiumName,
      capacity: capacity ?? this.capacity,
      balance: balance ?? this.balance,
      transferBudget: transferBudget ?? this.transferBudget,
      wageBudget: wageBudget ?? this.wageBudget,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (leagueId.present) {
      map['league_id'] = Variable<String>(leagueId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (primaryColor.present) {
      map['primary_color'] = Variable<String>(primaryColor.value);
    }
    if (secondaryColor.present) {
      map['secondary_color'] = Variable<String>(secondaryColor.value);
    }
    if (reputation.present) {
      map['reputation'] = Variable<int>(reputation.value);
    }
    if (stadiumName.present) {
      map['stadium_name'] = Variable<String>(stadiumName.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (transferBudget.present) {
      map['transfer_budget'] = Variable<int>(transferBudget.value);
    }
    if (wageBudget.present) {
      map['wage_budget'] = Variable<int>(wageBudget.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClubsCompanion(')
          ..write('id: $id, ')
          ..write('leagueId: $leagueId, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('primaryColor: $primaryColor, ')
          ..write('secondaryColor: $secondaryColor, ')
          ..write('reputation: $reputation, ')
          ..write('stadiumName: $stadiumName, ')
          ..write('capacity: $capacity, ')
          ..write('balance: $balance, ')
          ..write('transferBudget: $transferBudget, ')
          ..write('wageBudget: $wageBudget, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, PlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clubIdMeta = const VerificationMeta('clubId');
  @override
  late final GeneratedColumn<String> clubId = GeneratedColumn<String>(
    'club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nationalityMeta = const VerificationMeta(
    'nationality',
  );
  @override
  late final GeneratedColumn<String> nationality = GeneratedColumn<String>(
    'nationality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumnWithTypeConverter<Position, String> position =
      GeneratedColumn<String>(
        'position',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Position>($PlayersTable.$converterposition);
  static const VerificationMeta _finishingMeta = const VerificationMeta(
    'finishing',
  );
  @override
  late final GeneratedColumn<int> finishing = GeneratedColumn<int>(
    'finishing',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passingMeta = const VerificationMeta(
    'passing',
  );
  @override
  late final GeneratedColumn<int> passing = GeneratedColumn<int>(
    'passing',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dribblingMeta = const VerificationMeta(
    'dribbling',
  );
  @override
  late final GeneratedColumn<int> dribbling = GeneratedColumn<int>(
    'dribbling',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstTouchMeta = const VerificationMeta(
    'firstTouch',
  );
  @override
  late final GeneratedColumn<int> firstTouch = GeneratedColumn<int>(
    'first_touch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _crossingMeta = const VerificationMeta(
    'crossing',
  );
  @override
  late final GeneratedColumn<int> crossing = GeneratedColumn<int>(
    'crossing',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tacklingMeta = const VerificationMeta(
    'tackling',
  );
  @override
  late final GeneratedColumn<int> tackling = GeneratedColumn<int>(
    'tackling',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headingMeta = const VerificationMeta(
    'heading',
  );
  @override
  late final GeneratedColumn<int> heading = GeneratedColumn<int>(
    'heading',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _techniqueMeta = const VerificationMeta(
    'technique',
  );
  @override
  late final GeneratedColumn<int> technique = GeneratedColumn<int>(
    'technique',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionsMeta = const VerificationMeta(
    'decisions',
  );
  @override
  late final GeneratedColumn<int> decisions = GeneratedColumn<int>(
    'decisions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positioningMeta = const VerificationMeta(
    'positioning',
  );
  @override
  late final GeneratedColumn<int> positioning = GeneratedColumn<int>(
    'positioning',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visionMeta = const VerificationMeta('vision');
  @override
  late final GeneratedColumn<int> vision = GeneratedColumn<int>(
    'vision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _composureMeta = const VerificationMeta(
    'composure',
  );
  @override
  late final GeneratedColumn<int> composure = GeneratedColumn<int>(
    'composure',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workRateMeta = const VerificationMeta(
    'workRate',
  );
  @override
  late final GeneratedColumn<int> workRate = GeneratedColumn<int>(
    'work_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggressionMeta = const VerificationMeta(
    'aggression',
  );
  @override
  late final GeneratedColumn<int> aggression = GeneratedColumn<int>(
    'aggression',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paceMeta = const VerificationMeta('pace');
  @override
  late final GeneratedColumn<int> pace = GeneratedColumn<int>(
    'pace',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelerationMeta = const VerificationMeta(
    'acceleration',
  );
  @override
  late final GeneratedColumn<int> acceleration = GeneratedColumn<int>(
    'acceleration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staminaMeta = const VerificationMeta(
    'stamina',
  );
  @override
  late final GeneratedColumn<int> stamina = GeneratedColumn<int>(
    'stamina',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<int> strength = GeneratedColumn<int>(
    'strength',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agilityMeta = const VerificationMeta(
    'agility',
  );
  @override
  late final GeneratedColumn<int> agility = GeneratedColumn<int>(
    'agility',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handlingMeta = const VerificationMeta(
    'handling',
  );
  @override
  late final GeneratedColumn<int> handling = GeneratedColumn<int>(
    'handling',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reflexesMeta = const VerificationMeta(
    'reflexes',
  );
  @override
  late final GeneratedColumn<int> reflexes = GeneratedColumn<int>(
    'reflexes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oneOnOnesMeta = const VerificationMeta(
    'oneOnOnes',
  );
  @override
  late final GeneratedColumn<int> oneOnOnes = GeneratedColumn<int>(
    'one_on_ones',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aerialReachMeta = const VerificationMeta(
    'aerialReach',
  );
  @override
  late final GeneratedColumn<int> aerialReach = GeneratedColumn<int>(
    'aerial_reach',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _potentialAbilityMeta = const VerificationMeta(
    'potentialAbility',
  );
  @override
  late final GeneratedColumn<int> potentialAbility = GeneratedColumn<int>(
    'potential_ability',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAbilityMeta = const VerificationMeta(
    'currentAbility',
  );
  @override
  late final GeneratedColumn<int> currentAbility = GeneratedColumn<int>(
    'current_ability',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<int> condition = GeneratedColumn<int>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moraleMeta = const VerificationMeta('morale');
  @override
  late final GeneratedColumn<int> morale = GeneratedColumn<int>(
    'morale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketValueMeta = const VerificationMeta(
    'marketValue',
  );
  @override
  late final GeneratedColumn<int> marketValue = GeneratedColumn<int>(
    'market_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedUntilMeta = const VerificationMeta(
    'lockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
    'locked_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTransferListedMeta = const VerificationMeta(
    'isTransferListed',
  );
  @override
  late final GeneratedColumn<bool> isTransferListed = GeneratedColumn<bool>(
    'is_transfer_listed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_transfer_listed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clubId,
    firstName,
    lastName,
    age,
    nationality,
    position,
    finishing,
    passing,
    dribbling,
    firstTouch,
    crossing,
    tackling,
    heading,
    technique,
    decisions,
    positioning,
    vision,
    composure,
    workRate,
    aggression,
    pace,
    acceleration,
    stamina,
    strength,
    agility,
    handling,
    reflexes,
    oneOnOnes,
    aerialReach,
    potentialAbility,
    currentAbility,
    condition,
    morale,
    marketValue,
    lockedUntil,
    isTransferListed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('club_id')) {
      context.handle(
        _clubIdMeta,
        clubId.isAcceptableOrUnknown(data['club_id']!, _clubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clubIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('nationality')) {
      context.handle(
        _nationalityMeta,
        nationality.isAcceptableOrUnknown(
          data['nationality']!,
          _nationalityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nationalityMeta);
    }
    context.handle(_positionMeta, const VerificationResult.success());
    if (data.containsKey('finishing')) {
      context.handle(
        _finishingMeta,
        finishing.isAcceptableOrUnknown(data['finishing']!, _finishingMeta),
      );
    } else if (isInserting) {
      context.missing(_finishingMeta);
    }
    if (data.containsKey('passing')) {
      context.handle(
        _passingMeta,
        passing.isAcceptableOrUnknown(data['passing']!, _passingMeta),
      );
    } else if (isInserting) {
      context.missing(_passingMeta);
    }
    if (data.containsKey('dribbling')) {
      context.handle(
        _dribblingMeta,
        dribbling.isAcceptableOrUnknown(data['dribbling']!, _dribblingMeta),
      );
    } else if (isInserting) {
      context.missing(_dribblingMeta);
    }
    if (data.containsKey('first_touch')) {
      context.handle(
        _firstTouchMeta,
        firstTouch.isAcceptableOrUnknown(data['first_touch']!, _firstTouchMeta),
      );
    } else if (isInserting) {
      context.missing(_firstTouchMeta);
    }
    if (data.containsKey('crossing')) {
      context.handle(
        _crossingMeta,
        crossing.isAcceptableOrUnknown(data['crossing']!, _crossingMeta),
      );
    } else if (isInserting) {
      context.missing(_crossingMeta);
    }
    if (data.containsKey('tackling')) {
      context.handle(
        _tacklingMeta,
        tackling.isAcceptableOrUnknown(data['tackling']!, _tacklingMeta),
      );
    } else if (isInserting) {
      context.missing(_tacklingMeta);
    }
    if (data.containsKey('heading')) {
      context.handle(
        _headingMeta,
        heading.isAcceptableOrUnknown(data['heading']!, _headingMeta),
      );
    } else if (isInserting) {
      context.missing(_headingMeta);
    }
    if (data.containsKey('technique')) {
      context.handle(
        _techniqueMeta,
        technique.isAcceptableOrUnknown(data['technique']!, _techniqueMeta),
      );
    } else if (isInserting) {
      context.missing(_techniqueMeta);
    }
    if (data.containsKey('decisions')) {
      context.handle(
        _decisionsMeta,
        decisions.isAcceptableOrUnknown(data['decisions']!, _decisionsMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionsMeta);
    }
    if (data.containsKey('positioning')) {
      context.handle(
        _positioningMeta,
        positioning.isAcceptableOrUnknown(
          data['positioning']!,
          _positioningMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positioningMeta);
    }
    if (data.containsKey('vision')) {
      context.handle(
        _visionMeta,
        vision.isAcceptableOrUnknown(data['vision']!, _visionMeta),
      );
    } else if (isInserting) {
      context.missing(_visionMeta);
    }
    if (data.containsKey('composure')) {
      context.handle(
        _composureMeta,
        composure.isAcceptableOrUnknown(data['composure']!, _composureMeta),
      );
    } else if (isInserting) {
      context.missing(_composureMeta);
    }
    if (data.containsKey('work_rate')) {
      context.handle(
        _workRateMeta,
        workRate.isAcceptableOrUnknown(data['work_rate']!, _workRateMeta),
      );
    } else if (isInserting) {
      context.missing(_workRateMeta);
    }
    if (data.containsKey('aggression')) {
      context.handle(
        _aggressionMeta,
        aggression.isAcceptableOrUnknown(data['aggression']!, _aggressionMeta),
      );
    } else if (isInserting) {
      context.missing(_aggressionMeta);
    }
    if (data.containsKey('pace')) {
      context.handle(
        _paceMeta,
        pace.isAcceptableOrUnknown(data['pace']!, _paceMeta),
      );
    } else if (isInserting) {
      context.missing(_paceMeta);
    }
    if (data.containsKey('acceleration')) {
      context.handle(
        _accelerationMeta,
        acceleration.isAcceptableOrUnknown(
          data['acceleration']!,
          _accelerationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accelerationMeta);
    }
    if (data.containsKey('stamina')) {
      context.handle(
        _staminaMeta,
        stamina.isAcceptableOrUnknown(data['stamina']!, _staminaMeta),
      );
    } else if (isInserting) {
      context.missing(_staminaMeta);
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    } else if (isInserting) {
      context.missing(_strengthMeta);
    }
    if (data.containsKey('agility')) {
      context.handle(
        _agilityMeta,
        agility.isAcceptableOrUnknown(data['agility']!, _agilityMeta),
      );
    } else if (isInserting) {
      context.missing(_agilityMeta);
    }
    if (data.containsKey('handling')) {
      context.handle(
        _handlingMeta,
        handling.isAcceptableOrUnknown(data['handling']!, _handlingMeta),
      );
    } else if (isInserting) {
      context.missing(_handlingMeta);
    }
    if (data.containsKey('reflexes')) {
      context.handle(
        _reflexesMeta,
        reflexes.isAcceptableOrUnknown(data['reflexes']!, _reflexesMeta),
      );
    } else if (isInserting) {
      context.missing(_reflexesMeta);
    }
    if (data.containsKey('one_on_ones')) {
      context.handle(
        _oneOnOnesMeta,
        oneOnOnes.isAcceptableOrUnknown(data['one_on_ones']!, _oneOnOnesMeta),
      );
    } else if (isInserting) {
      context.missing(_oneOnOnesMeta);
    }
    if (data.containsKey('aerial_reach')) {
      context.handle(
        _aerialReachMeta,
        aerialReach.isAcceptableOrUnknown(
          data['aerial_reach']!,
          _aerialReachMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aerialReachMeta);
    }
    if (data.containsKey('potential_ability')) {
      context.handle(
        _potentialAbilityMeta,
        potentialAbility.isAcceptableOrUnknown(
          data['potential_ability']!,
          _potentialAbilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_potentialAbilityMeta);
    }
    if (data.containsKey('current_ability')) {
      context.handle(
        _currentAbilityMeta,
        currentAbility.isAcceptableOrUnknown(
          data['current_ability']!,
          _currentAbilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentAbilityMeta);
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    } else if (isInserting) {
      context.missing(_conditionMeta);
    }
    if (data.containsKey('morale')) {
      context.handle(
        _moraleMeta,
        morale.isAcceptableOrUnknown(data['morale']!, _moraleMeta),
      );
    } else if (isInserting) {
      context.missing(_moraleMeta);
    }
    if (data.containsKey('market_value')) {
      context.handle(
        _marketValueMeta,
        marketValue.isAcceptableOrUnknown(
          data['market_value']!,
          _marketValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_marketValueMeta);
    }
    if (data.containsKey('locked_until')) {
      context.handle(
        _lockedUntilMeta,
        lockedUntil.isAcceptableOrUnknown(
          data['locked_until']!,
          _lockedUntilMeta,
        ),
      );
    }
    if (data.containsKey('is_transfer_listed')) {
      context.handle(
        _isTransferListedMeta,
        isTransferListed.isAcceptableOrUnknown(
          data['is_transfer_listed']!,
          _isTransferListedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      clubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}club_id'],
          )!,
      firstName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}first_name'],
          )!,
      lastName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}last_name'],
          )!,
      age:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}age'],
          )!,
      nationality:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nationality'],
          )!,
      position: $PlayersTable.$converterposition.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}position'],
        )!,
      ),
      finishing:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}finishing'],
          )!,
      passing:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}passing'],
          )!,
      dribbling:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}dribbling'],
          )!,
      firstTouch:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}first_touch'],
          )!,
      crossing:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}crossing'],
          )!,
      tackling:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}tackling'],
          )!,
      heading:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}heading'],
          )!,
      technique:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}technique'],
          )!,
      decisions:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}decisions'],
          )!,
      positioning:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}positioning'],
          )!,
      vision:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}vision'],
          )!,
      composure:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}composure'],
          )!,
      workRate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}work_rate'],
          )!,
      aggression:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}aggression'],
          )!,
      pace:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}pace'],
          )!,
      acceleration:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}acceleration'],
          )!,
      stamina:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}stamina'],
          )!,
      strength:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}strength'],
          )!,
      agility:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}agility'],
          )!,
      handling:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}handling'],
          )!,
      reflexes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}reflexes'],
          )!,
      oneOnOnes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}one_on_ones'],
          )!,
      aerialReach:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}aerial_reach'],
          )!,
      potentialAbility:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}potential_ability'],
          )!,
      currentAbility:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}current_ability'],
          )!,
      condition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}condition'],
          )!,
      morale:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}morale'],
          )!,
      marketValue:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}market_value'],
          )!,
      lockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_until'],
      ),
      isTransferListed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_transfer_listed'],
          )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Position, String, String> $converterposition =
      const EnumNameConverter<Position>(Position.values);
}

class PlayerRow extends DataClass implements Insertable<PlayerRow> {
  final int id;
  final String clubId;
  final String firstName;
  final String lastName;
  final int age;
  final String nationality;
  final Position position;
  final int finishing;
  final int passing;
  final int dribbling;
  final int firstTouch;
  final int crossing;
  final int tackling;
  final int heading;
  final int technique;
  final int decisions;
  final int positioning;
  final int vision;
  final int composure;
  final int workRate;
  final int aggression;
  final int pace;
  final int acceleration;
  final int stamina;
  final int strength;
  final int agility;
  final int handling;
  final int reflexes;
  final int oneOnOnes;
  final int aerialReach;
  final int potentialAbility;
  final int currentAbility;
  final int condition;
  final int morale;
  final int marketValue;
  final DateTime? lockedUntil;
  final bool isTransferListed;
  const PlayerRow({
    required this.id,
    required this.clubId,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.nationality,
    required this.position,
    required this.finishing,
    required this.passing,
    required this.dribbling,
    required this.firstTouch,
    required this.crossing,
    required this.tackling,
    required this.heading,
    required this.technique,
    required this.decisions,
    required this.positioning,
    required this.vision,
    required this.composure,
    required this.workRate,
    required this.aggression,
    required this.pace,
    required this.acceleration,
    required this.stamina,
    required this.strength,
    required this.agility,
    required this.handling,
    required this.reflexes,
    required this.oneOnOnes,
    required this.aerialReach,
    required this.potentialAbility,
    required this.currentAbility,
    required this.condition,
    required this.morale,
    required this.marketValue,
    this.lockedUntil,
    required this.isTransferListed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['club_id'] = Variable<String>(clubId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['age'] = Variable<int>(age);
    map['nationality'] = Variable<String>(nationality);
    {
      map['position'] = Variable<String>(
        $PlayersTable.$converterposition.toSql(position),
      );
    }
    map['finishing'] = Variable<int>(finishing);
    map['passing'] = Variable<int>(passing);
    map['dribbling'] = Variable<int>(dribbling);
    map['first_touch'] = Variable<int>(firstTouch);
    map['crossing'] = Variable<int>(crossing);
    map['tackling'] = Variable<int>(tackling);
    map['heading'] = Variable<int>(heading);
    map['technique'] = Variable<int>(technique);
    map['decisions'] = Variable<int>(decisions);
    map['positioning'] = Variable<int>(positioning);
    map['vision'] = Variable<int>(vision);
    map['composure'] = Variable<int>(composure);
    map['work_rate'] = Variable<int>(workRate);
    map['aggression'] = Variable<int>(aggression);
    map['pace'] = Variable<int>(pace);
    map['acceleration'] = Variable<int>(acceleration);
    map['stamina'] = Variable<int>(stamina);
    map['strength'] = Variable<int>(strength);
    map['agility'] = Variable<int>(agility);
    map['handling'] = Variable<int>(handling);
    map['reflexes'] = Variable<int>(reflexes);
    map['one_on_ones'] = Variable<int>(oneOnOnes);
    map['aerial_reach'] = Variable<int>(aerialReach);
    map['potential_ability'] = Variable<int>(potentialAbility);
    map['current_ability'] = Variable<int>(currentAbility);
    map['condition'] = Variable<int>(condition);
    map['morale'] = Variable<int>(morale);
    map['market_value'] = Variable<int>(marketValue);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    map['is_transfer_listed'] = Variable<bool>(isTransferListed);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      clubId: Value(clubId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      age: Value(age),
      nationality: Value(nationality),
      position: Value(position),
      finishing: Value(finishing),
      passing: Value(passing),
      dribbling: Value(dribbling),
      firstTouch: Value(firstTouch),
      crossing: Value(crossing),
      tackling: Value(tackling),
      heading: Value(heading),
      technique: Value(technique),
      decisions: Value(decisions),
      positioning: Value(positioning),
      vision: Value(vision),
      composure: Value(composure),
      workRate: Value(workRate),
      aggression: Value(aggression),
      pace: Value(pace),
      acceleration: Value(acceleration),
      stamina: Value(stamina),
      strength: Value(strength),
      agility: Value(agility),
      handling: Value(handling),
      reflexes: Value(reflexes),
      oneOnOnes: Value(oneOnOnes),
      aerialReach: Value(aerialReach),
      potentialAbility: Value(potentialAbility),
      currentAbility: Value(currentAbility),
      condition: Value(condition),
      morale: Value(morale),
      marketValue: Value(marketValue),
      lockedUntil:
          lockedUntil == null && nullToAbsent
              ? const Value.absent()
              : Value(lockedUntil),
      isTransferListed: Value(isTransferListed),
    );
  }

  factory PlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerRow(
      id: serializer.fromJson<int>(json['id']),
      clubId: serializer.fromJson<String>(json['clubId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      age: serializer.fromJson<int>(json['age']),
      nationality: serializer.fromJson<String>(json['nationality']),
      position: $PlayersTable.$converterposition.fromJson(
        serializer.fromJson<String>(json['position']),
      ),
      finishing: serializer.fromJson<int>(json['finishing']),
      passing: serializer.fromJson<int>(json['passing']),
      dribbling: serializer.fromJson<int>(json['dribbling']),
      firstTouch: serializer.fromJson<int>(json['firstTouch']),
      crossing: serializer.fromJson<int>(json['crossing']),
      tackling: serializer.fromJson<int>(json['tackling']),
      heading: serializer.fromJson<int>(json['heading']),
      technique: serializer.fromJson<int>(json['technique']),
      decisions: serializer.fromJson<int>(json['decisions']),
      positioning: serializer.fromJson<int>(json['positioning']),
      vision: serializer.fromJson<int>(json['vision']),
      composure: serializer.fromJson<int>(json['composure']),
      workRate: serializer.fromJson<int>(json['workRate']),
      aggression: serializer.fromJson<int>(json['aggression']),
      pace: serializer.fromJson<int>(json['pace']),
      acceleration: serializer.fromJson<int>(json['acceleration']),
      stamina: serializer.fromJson<int>(json['stamina']),
      strength: serializer.fromJson<int>(json['strength']),
      agility: serializer.fromJson<int>(json['agility']),
      handling: serializer.fromJson<int>(json['handling']),
      reflexes: serializer.fromJson<int>(json['reflexes']),
      oneOnOnes: serializer.fromJson<int>(json['oneOnOnes']),
      aerialReach: serializer.fromJson<int>(json['aerialReach']),
      potentialAbility: serializer.fromJson<int>(json['potentialAbility']),
      currentAbility: serializer.fromJson<int>(json['currentAbility']),
      condition: serializer.fromJson<int>(json['condition']),
      morale: serializer.fromJson<int>(json['morale']),
      marketValue: serializer.fromJson<int>(json['marketValue']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
      isTransferListed: serializer.fromJson<bool>(json['isTransferListed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clubId': serializer.toJson<String>(clubId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'age': serializer.toJson<int>(age),
      'nationality': serializer.toJson<String>(nationality),
      'position': serializer.toJson<String>(
        $PlayersTable.$converterposition.toJson(position),
      ),
      'finishing': serializer.toJson<int>(finishing),
      'passing': serializer.toJson<int>(passing),
      'dribbling': serializer.toJson<int>(dribbling),
      'firstTouch': serializer.toJson<int>(firstTouch),
      'crossing': serializer.toJson<int>(crossing),
      'tackling': serializer.toJson<int>(tackling),
      'heading': serializer.toJson<int>(heading),
      'technique': serializer.toJson<int>(technique),
      'decisions': serializer.toJson<int>(decisions),
      'positioning': serializer.toJson<int>(positioning),
      'vision': serializer.toJson<int>(vision),
      'composure': serializer.toJson<int>(composure),
      'workRate': serializer.toJson<int>(workRate),
      'aggression': serializer.toJson<int>(aggression),
      'pace': serializer.toJson<int>(pace),
      'acceleration': serializer.toJson<int>(acceleration),
      'stamina': serializer.toJson<int>(stamina),
      'strength': serializer.toJson<int>(strength),
      'agility': serializer.toJson<int>(agility),
      'handling': serializer.toJson<int>(handling),
      'reflexes': serializer.toJson<int>(reflexes),
      'oneOnOnes': serializer.toJson<int>(oneOnOnes),
      'aerialReach': serializer.toJson<int>(aerialReach),
      'potentialAbility': serializer.toJson<int>(potentialAbility),
      'currentAbility': serializer.toJson<int>(currentAbility),
      'condition': serializer.toJson<int>(condition),
      'morale': serializer.toJson<int>(morale),
      'marketValue': serializer.toJson<int>(marketValue),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
      'isTransferListed': serializer.toJson<bool>(isTransferListed),
    };
  }

  PlayerRow copyWith({
    int? id,
    String? clubId,
    String? firstName,
    String? lastName,
    int? age,
    String? nationality,
    Position? position,
    int? finishing,
    int? passing,
    int? dribbling,
    int? firstTouch,
    int? crossing,
    int? tackling,
    int? heading,
    int? technique,
    int? decisions,
    int? positioning,
    int? vision,
    int? composure,
    int? workRate,
    int? aggression,
    int? pace,
    int? acceleration,
    int? stamina,
    int? strength,
    int? agility,
    int? handling,
    int? reflexes,
    int? oneOnOnes,
    int? aerialReach,
    int? potentialAbility,
    int? currentAbility,
    int? condition,
    int? morale,
    int? marketValue,
    Value<DateTime?> lockedUntil = const Value.absent(),
    bool? isTransferListed,
  }) => PlayerRow(
    id: id ?? this.id,
    clubId: clubId ?? this.clubId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    age: age ?? this.age,
    nationality: nationality ?? this.nationality,
    position: position ?? this.position,
    finishing: finishing ?? this.finishing,
    passing: passing ?? this.passing,
    dribbling: dribbling ?? this.dribbling,
    firstTouch: firstTouch ?? this.firstTouch,
    crossing: crossing ?? this.crossing,
    tackling: tackling ?? this.tackling,
    heading: heading ?? this.heading,
    technique: technique ?? this.technique,
    decisions: decisions ?? this.decisions,
    positioning: positioning ?? this.positioning,
    vision: vision ?? this.vision,
    composure: composure ?? this.composure,
    workRate: workRate ?? this.workRate,
    aggression: aggression ?? this.aggression,
    pace: pace ?? this.pace,
    acceleration: acceleration ?? this.acceleration,
    stamina: stamina ?? this.stamina,
    strength: strength ?? this.strength,
    agility: agility ?? this.agility,
    handling: handling ?? this.handling,
    reflexes: reflexes ?? this.reflexes,
    oneOnOnes: oneOnOnes ?? this.oneOnOnes,
    aerialReach: aerialReach ?? this.aerialReach,
    potentialAbility: potentialAbility ?? this.potentialAbility,
    currentAbility: currentAbility ?? this.currentAbility,
    condition: condition ?? this.condition,
    morale: morale ?? this.morale,
    marketValue: marketValue ?? this.marketValue,
    lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
    isTransferListed: isTransferListed ?? this.isTransferListed,
  );
  PlayerRow copyWithCompanion(PlayersCompanion data) {
    return PlayerRow(
      id: data.id.present ? data.id.value : this.id,
      clubId: data.clubId.present ? data.clubId.value : this.clubId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      age: data.age.present ? data.age.value : this.age,
      nationality:
          data.nationality.present ? data.nationality.value : this.nationality,
      position: data.position.present ? data.position.value : this.position,
      finishing: data.finishing.present ? data.finishing.value : this.finishing,
      passing: data.passing.present ? data.passing.value : this.passing,
      dribbling: data.dribbling.present ? data.dribbling.value : this.dribbling,
      firstTouch:
          data.firstTouch.present ? data.firstTouch.value : this.firstTouch,
      crossing: data.crossing.present ? data.crossing.value : this.crossing,
      tackling: data.tackling.present ? data.tackling.value : this.tackling,
      heading: data.heading.present ? data.heading.value : this.heading,
      technique: data.technique.present ? data.technique.value : this.technique,
      decisions: data.decisions.present ? data.decisions.value : this.decisions,
      positioning:
          data.positioning.present ? data.positioning.value : this.positioning,
      vision: data.vision.present ? data.vision.value : this.vision,
      composure: data.composure.present ? data.composure.value : this.composure,
      workRate: data.workRate.present ? data.workRate.value : this.workRate,
      aggression:
          data.aggression.present ? data.aggression.value : this.aggression,
      pace: data.pace.present ? data.pace.value : this.pace,
      acceleration:
          data.acceleration.present
              ? data.acceleration.value
              : this.acceleration,
      stamina: data.stamina.present ? data.stamina.value : this.stamina,
      strength: data.strength.present ? data.strength.value : this.strength,
      agility: data.agility.present ? data.agility.value : this.agility,
      handling: data.handling.present ? data.handling.value : this.handling,
      reflexes: data.reflexes.present ? data.reflexes.value : this.reflexes,
      oneOnOnes: data.oneOnOnes.present ? data.oneOnOnes.value : this.oneOnOnes,
      aerialReach:
          data.aerialReach.present ? data.aerialReach.value : this.aerialReach,
      potentialAbility:
          data.potentialAbility.present
              ? data.potentialAbility.value
              : this.potentialAbility,
      currentAbility:
          data.currentAbility.present
              ? data.currentAbility.value
              : this.currentAbility,
      condition: data.condition.present ? data.condition.value : this.condition,
      morale: data.morale.present ? data.morale.value : this.morale,
      marketValue:
          data.marketValue.present ? data.marketValue.value : this.marketValue,
      lockedUntil:
          data.lockedUntil.present ? data.lockedUntil.value : this.lockedUntil,
      isTransferListed:
          data.isTransferListed.present
              ? data.isTransferListed.value
              : this.isTransferListed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerRow(')
          ..write('id: $id, ')
          ..write('clubId: $clubId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('age: $age, ')
          ..write('nationality: $nationality, ')
          ..write('position: $position, ')
          ..write('finishing: $finishing, ')
          ..write('passing: $passing, ')
          ..write('dribbling: $dribbling, ')
          ..write('firstTouch: $firstTouch, ')
          ..write('crossing: $crossing, ')
          ..write('tackling: $tackling, ')
          ..write('heading: $heading, ')
          ..write('technique: $technique, ')
          ..write('decisions: $decisions, ')
          ..write('positioning: $positioning, ')
          ..write('vision: $vision, ')
          ..write('composure: $composure, ')
          ..write('workRate: $workRate, ')
          ..write('aggression: $aggression, ')
          ..write('pace: $pace, ')
          ..write('acceleration: $acceleration, ')
          ..write('stamina: $stamina, ')
          ..write('strength: $strength, ')
          ..write('agility: $agility, ')
          ..write('handling: $handling, ')
          ..write('reflexes: $reflexes, ')
          ..write('oneOnOnes: $oneOnOnes, ')
          ..write('aerialReach: $aerialReach, ')
          ..write('potentialAbility: $potentialAbility, ')
          ..write('currentAbility: $currentAbility, ')
          ..write('condition: $condition, ')
          ..write('morale: $morale, ')
          ..write('marketValue: $marketValue, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('isTransferListed: $isTransferListed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    clubId,
    firstName,
    lastName,
    age,
    nationality,
    position,
    finishing,
    passing,
    dribbling,
    firstTouch,
    crossing,
    tackling,
    heading,
    technique,
    decisions,
    positioning,
    vision,
    composure,
    workRate,
    aggression,
    pace,
    acceleration,
    stamina,
    strength,
    agility,
    handling,
    reflexes,
    oneOnOnes,
    aerialReach,
    potentialAbility,
    currentAbility,
    condition,
    morale,
    marketValue,
    lockedUntil,
    isTransferListed,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerRow &&
          other.id == this.id &&
          other.clubId == this.clubId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.age == this.age &&
          other.nationality == this.nationality &&
          other.position == this.position &&
          other.finishing == this.finishing &&
          other.passing == this.passing &&
          other.dribbling == this.dribbling &&
          other.firstTouch == this.firstTouch &&
          other.crossing == this.crossing &&
          other.tackling == this.tackling &&
          other.heading == this.heading &&
          other.technique == this.technique &&
          other.decisions == this.decisions &&
          other.positioning == this.positioning &&
          other.vision == this.vision &&
          other.composure == this.composure &&
          other.workRate == this.workRate &&
          other.aggression == this.aggression &&
          other.pace == this.pace &&
          other.acceleration == this.acceleration &&
          other.stamina == this.stamina &&
          other.strength == this.strength &&
          other.agility == this.agility &&
          other.handling == this.handling &&
          other.reflexes == this.reflexes &&
          other.oneOnOnes == this.oneOnOnes &&
          other.aerialReach == this.aerialReach &&
          other.potentialAbility == this.potentialAbility &&
          other.currentAbility == this.currentAbility &&
          other.condition == this.condition &&
          other.morale == this.morale &&
          other.marketValue == this.marketValue &&
          other.lockedUntil == this.lockedUntil &&
          other.isTransferListed == this.isTransferListed);
}

class PlayersCompanion extends UpdateCompanion<PlayerRow> {
  final Value<int> id;
  final Value<String> clubId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<int> age;
  final Value<String> nationality;
  final Value<Position> position;
  final Value<int> finishing;
  final Value<int> passing;
  final Value<int> dribbling;
  final Value<int> firstTouch;
  final Value<int> crossing;
  final Value<int> tackling;
  final Value<int> heading;
  final Value<int> technique;
  final Value<int> decisions;
  final Value<int> positioning;
  final Value<int> vision;
  final Value<int> composure;
  final Value<int> workRate;
  final Value<int> aggression;
  final Value<int> pace;
  final Value<int> acceleration;
  final Value<int> stamina;
  final Value<int> strength;
  final Value<int> agility;
  final Value<int> handling;
  final Value<int> reflexes;
  final Value<int> oneOnOnes;
  final Value<int> aerialReach;
  final Value<int> potentialAbility;
  final Value<int> currentAbility;
  final Value<int> condition;
  final Value<int> morale;
  final Value<int> marketValue;
  final Value<DateTime?> lockedUntil;
  final Value<bool> isTransferListed;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.clubId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.age = const Value.absent(),
    this.nationality = const Value.absent(),
    this.position = const Value.absent(),
    this.finishing = const Value.absent(),
    this.passing = const Value.absent(),
    this.dribbling = const Value.absent(),
    this.firstTouch = const Value.absent(),
    this.crossing = const Value.absent(),
    this.tackling = const Value.absent(),
    this.heading = const Value.absent(),
    this.technique = const Value.absent(),
    this.decisions = const Value.absent(),
    this.positioning = const Value.absent(),
    this.vision = const Value.absent(),
    this.composure = const Value.absent(),
    this.workRate = const Value.absent(),
    this.aggression = const Value.absent(),
    this.pace = const Value.absent(),
    this.acceleration = const Value.absent(),
    this.stamina = const Value.absent(),
    this.strength = const Value.absent(),
    this.agility = const Value.absent(),
    this.handling = const Value.absent(),
    this.reflexes = const Value.absent(),
    this.oneOnOnes = const Value.absent(),
    this.aerialReach = const Value.absent(),
    this.potentialAbility = const Value.absent(),
    this.currentAbility = const Value.absent(),
    this.condition = const Value.absent(),
    this.morale = const Value.absent(),
    this.marketValue = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.isTransferListed = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    required String clubId,
    required String firstName,
    required String lastName,
    required int age,
    required String nationality,
    required Position position,
    required int finishing,
    required int passing,
    required int dribbling,
    required int firstTouch,
    required int crossing,
    required int tackling,
    required int heading,
    required int technique,
    required int decisions,
    required int positioning,
    required int vision,
    required int composure,
    required int workRate,
    required int aggression,
    required int pace,
    required int acceleration,
    required int stamina,
    required int strength,
    required int agility,
    required int handling,
    required int reflexes,
    required int oneOnOnes,
    required int aerialReach,
    required int potentialAbility,
    required int currentAbility,
    required int condition,
    required int morale,
    required int marketValue,
    this.lockedUntil = const Value.absent(),
    this.isTransferListed = const Value.absent(),
  }) : clubId = Value(clubId),
       firstName = Value(firstName),
       lastName = Value(lastName),
       age = Value(age),
       nationality = Value(nationality),
       position = Value(position),
       finishing = Value(finishing),
       passing = Value(passing),
       dribbling = Value(dribbling),
       firstTouch = Value(firstTouch),
       crossing = Value(crossing),
       tackling = Value(tackling),
       heading = Value(heading),
       technique = Value(technique),
       decisions = Value(decisions),
       positioning = Value(positioning),
       vision = Value(vision),
       composure = Value(composure),
       workRate = Value(workRate),
       aggression = Value(aggression),
       pace = Value(pace),
       acceleration = Value(acceleration),
       stamina = Value(stamina),
       strength = Value(strength),
       agility = Value(agility),
       handling = Value(handling),
       reflexes = Value(reflexes),
       oneOnOnes = Value(oneOnOnes),
       aerialReach = Value(aerialReach),
       potentialAbility = Value(potentialAbility),
       currentAbility = Value(currentAbility),
       condition = Value(condition),
       morale = Value(morale),
       marketValue = Value(marketValue);
  static Insertable<PlayerRow> custom({
    Expression<int>? id,
    Expression<String>? clubId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<int>? age,
    Expression<String>? nationality,
    Expression<String>? position,
    Expression<int>? finishing,
    Expression<int>? passing,
    Expression<int>? dribbling,
    Expression<int>? firstTouch,
    Expression<int>? crossing,
    Expression<int>? tackling,
    Expression<int>? heading,
    Expression<int>? technique,
    Expression<int>? decisions,
    Expression<int>? positioning,
    Expression<int>? vision,
    Expression<int>? composure,
    Expression<int>? workRate,
    Expression<int>? aggression,
    Expression<int>? pace,
    Expression<int>? acceleration,
    Expression<int>? stamina,
    Expression<int>? strength,
    Expression<int>? agility,
    Expression<int>? handling,
    Expression<int>? reflexes,
    Expression<int>? oneOnOnes,
    Expression<int>? aerialReach,
    Expression<int>? potentialAbility,
    Expression<int>? currentAbility,
    Expression<int>? condition,
    Expression<int>? morale,
    Expression<int>? marketValue,
    Expression<DateTime>? lockedUntil,
    Expression<bool>? isTransferListed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clubId != null) 'club_id': clubId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (age != null) 'age': age,
      if (nationality != null) 'nationality': nationality,
      if (position != null) 'position': position,
      if (finishing != null) 'finishing': finishing,
      if (passing != null) 'passing': passing,
      if (dribbling != null) 'dribbling': dribbling,
      if (firstTouch != null) 'first_touch': firstTouch,
      if (crossing != null) 'crossing': crossing,
      if (tackling != null) 'tackling': tackling,
      if (heading != null) 'heading': heading,
      if (technique != null) 'technique': technique,
      if (decisions != null) 'decisions': decisions,
      if (positioning != null) 'positioning': positioning,
      if (vision != null) 'vision': vision,
      if (composure != null) 'composure': composure,
      if (workRate != null) 'work_rate': workRate,
      if (aggression != null) 'aggression': aggression,
      if (pace != null) 'pace': pace,
      if (acceleration != null) 'acceleration': acceleration,
      if (stamina != null) 'stamina': stamina,
      if (strength != null) 'strength': strength,
      if (agility != null) 'agility': agility,
      if (handling != null) 'handling': handling,
      if (reflexes != null) 'reflexes': reflexes,
      if (oneOnOnes != null) 'one_on_ones': oneOnOnes,
      if (aerialReach != null) 'aerial_reach': aerialReach,
      if (potentialAbility != null) 'potential_ability': potentialAbility,
      if (currentAbility != null) 'current_ability': currentAbility,
      if (condition != null) 'condition': condition,
      if (morale != null) 'morale': morale,
      if (marketValue != null) 'market_value': marketValue,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (isTransferListed != null) 'is_transfer_listed': isTransferListed,
    });
  }

  PlayersCompanion copyWith({
    Value<int>? id,
    Value<String>? clubId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<int>? age,
    Value<String>? nationality,
    Value<Position>? position,
    Value<int>? finishing,
    Value<int>? passing,
    Value<int>? dribbling,
    Value<int>? firstTouch,
    Value<int>? crossing,
    Value<int>? tackling,
    Value<int>? heading,
    Value<int>? technique,
    Value<int>? decisions,
    Value<int>? positioning,
    Value<int>? vision,
    Value<int>? composure,
    Value<int>? workRate,
    Value<int>? aggression,
    Value<int>? pace,
    Value<int>? acceleration,
    Value<int>? stamina,
    Value<int>? strength,
    Value<int>? agility,
    Value<int>? handling,
    Value<int>? reflexes,
    Value<int>? oneOnOnes,
    Value<int>? aerialReach,
    Value<int>? potentialAbility,
    Value<int>? currentAbility,
    Value<int>? condition,
    Value<int>? morale,
    Value<int>? marketValue,
    Value<DateTime?>? lockedUntil,
    Value<bool>? isTransferListed,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      position: position ?? this.position,
      finishing: finishing ?? this.finishing,
      passing: passing ?? this.passing,
      dribbling: dribbling ?? this.dribbling,
      firstTouch: firstTouch ?? this.firstTouch,
      crossing: crossing ?? this.crossing,
      tackling: tackling ?? this.tackling,
      heading: heading ?? this.heading,
      technique: technique ?? this.technique,
      decisions: decisions ?? this.decisions,
      positioning: positioning ?? this.positioning,
      vision: vision ?? this.vision,
      composure: composure ?? this.composure,
      workRate: workRate ?? this.workRate,
      aggression: aggression ?? this.aggression,
      pace: pace ?? this.pace,
      acceleration: acceleration ?? this.acceleration,
      stamina: stamina ?? this.stamina,
      strength: strength ?? this.strength,
      agility: agility ?? this.agility,
      handling: handling ?? this.handling,
      reflexes: reflexes ?? this.reflexes,
      oneOnOnes: oneOnOnes ?? this.oneOnOnes,
      aerialReach: aerialReach ?? this.aerialReach,
      potentialAbility: potentialAbility ?? this.potentialAbility,
      currentAbility: currentAbility ?? this.currentAbility,
      condition: condition ?? this.condition,
      morale: morale ?? this.morale,
      marketValue: marketValue ?? this.marketValue,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      isTransferListed: isTransferListed ?? this.isTransferListed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clubId.present) {
      map['club_id'] = Variable<String>(clubId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (nationality.present) {
      map['nationality'] = Variable<String>(nationality.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(
        $PlayersTable.$converterposition.toSql(position.value),
      );
    }
    if (finishing.present) {
      map['finishing'] = Variable<int>(finishing.value);
    }
    if (passing.present) {
      map['passing'] = Variable<int>(passing.value);
    }
    if (dribbling.present) {
      map['dribbling'] = Variable<int>(dribbling.value);
    }
    if (firstTouch.present) {
      map['first_touch'] = Variable<int>(firstTouch.value);
    }
    if (crossing.present) {
      map['crossing'] = Variable<int>(crossing.value);
    }
    if (tackling.present) {
      map['tackling'] = Variable<int>(tackling.value);
    }
    if (heading.present) {
      map['heading'] = Variable<int>(heading.value);
    }
    if (technique.present) {
      map['technique'] = Variable<int>(technique.value);
    }
    if (decisions.present) {
      map['decisions'] = Variable<int>(decisions.value);
    }
    if (positioning.present) {
      map['positioning'] = Variable<int>(positioning.value);
    }
    if (vision.present) {
      map['vision'] = Variable<int>(vision.value);
    }
    if (composure.present) {
      map['composure'] = Variable<int>(composure.value);
    }
    if (workRate.present) {
      map['work_rate'] = Variable<int>(workRate.value);
    }
    if (aggression.present) {
      map['aggression'] = Variable<int>(aggression.value);
    }
    if (pace.present) {
      map['pace'] = Variable<int>(pace.value);
    }
    if (acceleration.present) {
      map['acceleration'] = Variable<int>(acceleration.value);
    }
    if (stamina.present) {
      map['stamina'] = Variable<int>(stamina.value);
    }
    if (strength.present) {
      map['strength'] = Variable<int>(strength.value);
    }
    if (agility.present) {
      map['agility'] = Variable<int>(agility.value);
    }
    if (handling.present) {
      map['handling'] = Variable<int>(handling.value);
    }
    if (reflexes.present) {
      map['reflexes'] = Variable<int>(reflexes.value);
    }
    if (oneOnOnes.present) {
      map['one_on_ones'] = Variable<int>(oneOnOnes.value);
    }
    if (aerialReach.present) {
      map['aerial_reach'] = Variable<int>(aerialReach.value);
    }
    if (potentialAbility.present) {
      map['potential_ability'] = Variable<int>(potentialAbility.value);
    }
    if (currentAbility.present) {
      map['current_ability'] = Variable<int>(currentAbility.value);
    }
    if (condition.present) {
      map['condition'] = Variable<int>(condition.value);
    }
    if (morale.present) {
      map['morale'] = Variable<int>(morale.value);
    }
    if (marketValue.present) {
      map['market_value'] = Variable<int>(marketValue.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (isTransferListed.present) {
      map['is_transfer_listed'] = Variable<bool>(isTransferListed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('clubId: $clubId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('age: $age, ')
          ..write('nationality: $nationality, ')
          ..write('position: $position, ')
          ..write('finishing: $finishing, ')
          ..write('passing: $passing, ')
          ..write('dribbling: $dribbling, ')
          ..write('firstTouch: $firstTouch, ')
          ..write('crossing: $crossing, ')
          ..write('tackling: $tackling, ')
          ..write('heading: $heading, ')
          ..write('technique: $technique, ')
          ..write('decisions: $decisions, ')
          ..write('positioning: $positioning, ')
          ..write('vision: $vision, ')
          ..write('composure: $composure, ')
          ..write('workRate: $workRate, ')
          ..write('aggression: $aggression, ')
          ..write('pace: $pace, ')
          ..write('acceleration: $acceleration, ')
          ..write('stamina: $stamina, ')
          ..write('strength: $strength, ')
          ..write('agility: $agility, ')
          ..write('handling: $handling, ')
          ..write('reflexes: $reflexes, ')
          ..write('oneOnOnes: $oneOnOnes, ')
          ..write('aerialReach: $aerialReach, ')
          ..write('potentialAbility: $potentialAbility, ')
          ..write('currentAbility: $currentAbility, ')
          ..write('condition: $condition, ')
          ..write('morale: $morale, ')
          ..write('marketValue: $marketValue, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('isTransferListed: $isTransferListed')
          ..write(')'))
        .toString();
  }
}

class $ContractsTable extends Contracts
    with TableInfo<$ContractsTable, ContractRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clubIdMeta = const VerificationMeta('clubId');
  @override
  late final GeneratedColumn<String> clubId = GeneratedColumn<String>(
    'club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wageMeta = const VerificationMeta('wage');
  @override
  late final GeneratedColumn<int> wage = GeneratedColumn<int>(
    'wage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _squadStatusMeta = const VerificationMeta(
    'squadStatus',
  );
  @override
  late final GeneratedColumnWithTypeConverter<SquadStatus, String> squadStatus =
      GeneratedColumn<String>(
        'squad_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SquadStatus>($ContractsTable.$convertersquadStatus);
  @override
  List<GeneratedColumn> get $columns => [
    playerId,
    clubId,
    wage,
    endDate,
    squadStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contracts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContractRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    }
    if (data.containsKey('club_id')) {
      context.handle(
        _clubIdMeta,
        clubId.isAcceptableOrUnknown(data['club_id']!, _clubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clubIdMeta);
    }
    if (data.containsKey('wage')) {
      context.handle(
        _wageMeta,
        wage.isAcceptableOrUnknown(data['wage']!, _wageMeta),
      );
    } else if (isInserting) {
      context.missing(_wageMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    context.handle(_squadStatusMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId};
  @override
  ContractRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractRow(
      playerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}player_id'],
          )!,
      clubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}club_id'],
          )!,
      wage:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}wage'],
          )!,
      endDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}end_date'],
          )!,
      squadStatus: $ContractsTable.$convertersquadStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}squad_status'],
        )!,
      ),
    );
  }

  @override
  $ContractsTable createAlias(String alias) {
    return $ContractsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SquadStatus, String, String> $convertersquadStatus =
      const EnumNameConverter<SquadStatus>(SquadStatus.values);
}

class ContractRow extends DataClass implements Insertable<ContractRow> {
  final int playerId;
  final String clubId;
  final int wage;
  final DateTime endDate;
  final SquadStatus squadStatus;
  const ContractRow({
    required this.playerId,
    required this.clubId,
    required this.wage,
    required this.endDate,
    required this.squadStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<int>(playerId);
    map['club_id'] = Variable<String>(clubId);
    map['wage'] = Variable<int>(wage);
    map['end_date'] = Variable<DateTime>(endDate);
    {
      map['squad_status'] = Variable<String>(
        $ContractsTable.$convertersquadStatus.toSql(squadStatus),
      );
    }
    return map;
  }

  ContractsCompanion toCompanion(bool nullToAbsent) {
    return ContractsCompanion(
      playerId: Value(playerId),
      clubId: Value(clubId),
      wage: Value(wage),
      endDate: Value(endDate),
      squadStatus: Value(squadStatus),
    );
  }

  factory ContractRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractRow(
      playerId: serializer.fromJson<int>(json['playerId']),
      clubId: serializer.fromJson<String>(json['clubId']),
      wage: serializer.fromJson<int>(json['wage']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      squadStatus: $ContractsTable.$convertersquadStatus.fromJson(
        serializer.fromJson<String>(json['squadStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<int>(playerId),
      'clubId': serializer.toJson<String>(clubId),
      'wage': serializer.toJson<int>(wage),
      'endDate': serializer.toJson<DateTime>(endDate),
      'squadStatus': serializer.toJson<String>(
        $ContractsTable.$convertersquadStatus.toJson(squadStatus),
      ),
    };
  }

  ContractRow copyWith({
    int? playerId,
    String? clubId,
    int? wage,
    DateTime? endDate,
    SquadStatus? squadStatus,
  }) => ContractRow(
    playerId: playerId ?? this.playerId,
    clubId: clubId ?? this.clubId,
    wage: wage ?? this.wage,
    endDate: endDate ?? this.endDate,
    squadStatus: squadStatus ?? this.squadStatus,
  );
  ContractRow copyWithCompanion(ContractsCompanion data) {
    return ContractRow(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      clubId: data.clubId.present ? data.clubId.value : this.clubId,
      wage: data.wage.present ? data.wage.value : this.wage,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      squadStatus:
          data.squadStatus.present ? data.squadStatus.value : this.squadStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContractRow(')
          ..write('playerId: $playerId, ')
          ..write('clubId: $clubId, ')
          ..write('wage: $wage, ')
          ..write('endDate: $endDate, ')
          ..write('squadStatus: $squadStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, clubId, wage, endDate, squadStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractRow &&
          other.playerId == this.playerId &&
          other.clubId == this.clubId &&
          other.wage == this.wage &&
          other.endDate == this.endDate &&
          other.squadStatus == this.squadStatus);
}

class ContractsCompanion extends UpdateCompanion<ContractRow> {
  final Value<int> playerId;
  final Value<String> clubId;
  final Value<int> wage;
  final Value<DateTime> endDate;
  final Value<SquadStatus> squadStatus;
  const ContractsCompanion({
    this.playerId = const Value.absent(),
    this.clubId = const Value.absent(),
    this.wage = const Value.absent(),
    this.endDate = const Value.absent(),
    this.squadStatus = const Value.absent(),
  });
  ContractsCompanion.insert({
    this.playerId = const Value.absent(),
    required String clubId,
    required int wage,
    required DateTime endDate,
    required SquadStatus squadStatus,
  }) : clubId = Value(clubId),
       wage = Value(wage),
       endDate = Value(endDate),
       squadStatus = Value(squadStatus);
  static Insertable<ContractRow> custom({
    Expression<int>? playerId,
    Expression<String>? clubId,
    Expression<int>? wage,
    Expression<DateTime>? endDate,
    Expression<String>? squadStatus,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (clubId != null) 'club_id': clubId,
      if (wage != null) 'wage': wage,
      if (endDate != null) 'end_date': endDate,
      if (squadStatus != null) 'squad_status': squadStatus,
    });
  }

  ContractsCompanion copyWith({
    Value<int>? playerId,
    Value<String>? clubId,
    Value<int>? wage,
    Value<DateTime>? endDate,
    Value<SquadStatus>? squadStatus,
  }) {
    return ContractsCompanion(
      playerId: playerId ?? this.playerId,
      clubId: clubId ?? this.clubId,
      wage: wage ?? this.wage,
      endDate: endDate ?? this.endDate,
      squadStatus: squadStatus ?? this.squadStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (clubId.present) {
      map['club_id'] = Variable<String>(clubId.value);
    }
    if (wage.present) {
      map['wage'] = Variable<int>(wage.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (squadStatus.present) {
      map['squad_status'] = Variable<String>(
        $ContractsTable.$convertersquadStatus.toSql(squadStatus.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractsCompanion(')
          ..write('playerId: $playerId, ')
          ..write('clubId: $clubId, ')
          ..write('wage: $wage, ')
          ..write('endDate: $endDate, ')
          ..write('squadStatus: $squadStatus')
          ..write(')'))
        .toString();
  }
}

class $GameStatesTable extends GameStates
    with TableInfo<$GameStatesTable, GameStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentDateMeta = const VerificationMeta(
    'currentDate',
  );
  @override
  late final GeneratedColumn<DateTime> currentDate = GeneratedColumn<DateTime>(
    'current_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _managerNameMeta = const VerificationMeta(
    'managerName',
  );
  @override
  late final GeneratedColumn<String> managerName = GeneratedColumn<String>(
    'manager_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clubIdMeta = const VerificationMeta('clubId');
  @override
  late final GeneratedColumn<String> clubId = GeneratedColumn<String>(
    'club_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonStartYearMeta = const VerificationMeta(
    'seasonStartYear',
  );
  @override
  late final GeneratedColumn<int> seasonStartYear = GeneratedColumn<int>(
    'season_start_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2026),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentDate,
    managerName,
    clubId,
    seed,
    seasonStartYear,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_date')) {
      context.handle(
        _currentDateMeta,
        currentDate.isAcceptableOrUnknown(
          data['current_date']!,
          _currentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentDateMeta);
    }
    if (data.containsKey('manager_name')) {
      context.handle(
        _managerNameMeta,
        managerName.isAcceptableOrUnknown(
          data['manager_name']!,
          _managerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_managerNameMeta);
    }
    if (data.containsKey('club_id')) {
      context.handle(
        _clubIdMeta,
        clubId.isAcceptableOrUnknown(data['club_id']!, _clubIdMeta),
      );
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('season_start_year')) {
      context.handle(
        _seasonStartYearMeta,
        seasonStartYear.isAcceptableOrUnknown(
          data['season_start_year']!,
          _seasonStartYearMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameStateRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      currentDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}current_date'],
          )!,
      managerName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}manager_name'],
          )!,
      clubId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}club_id'],
      ),
      seed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}seed'],
          )!,
      seasonStartYear:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}season_start_year'],
          )!,
    );
  }

  @override
  $GameStatesTable createAlias(String alias) {
    return $GameStatesTable(attachedDatabase, alias);
  }
}

class GameStateRow extends DataClass implements Insertable<GameStateRow> {
  final int id;
  final DateTime currentDate;
  final String managerName;
  final String? clubId;
  final int seed;
  final int seasonStartYear;
  const GameStateRow({
    required this.id,
    required this.currentDate,
    required this.managerName,
    this.clubId,
    required this.seed,
    required this.seasonStartYear,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_date'] = Variable<DateTime>(currentDate);
    map['manager_name'] = Variable<String>(managerName);
    if (!nullToAbsent || clubId != null) {
      map['club_id'] = Variable<String>(clubId);
    }
    map['seed'] = Variable<int>(seed);
    map['season_start_year'] = Variable<int>(seasonStartYear);
    return map;
  }

  GameStatesCompanion toCompanion(bool nullToAbsent) {
    return GameStatesCompanion(
      id: Value(id),
      currentDate: Value(currentDate),
      managerName: Value(managerName),
      clubId:
          clubId == null && nullToAbsent ? const Value.absent() : Value(clubId),
      seed: Value(seed),
      seasonStartYear: Value(seasonStartYear),
    );
  }

  factory GameStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameStateRow(
      id: serializer.fromJson<int>(json['id']),
      currentDate: serializer.fromJson<DateTime>(json['currentDate']),
      managerName: serializer.fromJson<String>(json['managerName']),
      clubId: serializer.fromJson<String?>(json['clubId']),
      seed: serializer.fromJson<int>(json['seed']),
      seasonStartYear: serializer.fromJson<int>(json['seasonStartYear']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentDate': serializer.toJson<DateTime>(currentDate),
      'managerName': serializer.toJson<String>(managerName),
      'clubId': serializer.toJson<String?>(clubId),
      'seed': serializer.toJson<int>(seed),
      'seasonStartYear': serializer.toJson<int>(seasonStartYear),
    };
  }

  GameStateRow copyWith({
    int? id,
    DateTime? currentDate,
    String? managerName,
    Value<String?> clubId = const Value.absent(),
    int? seed,
    int? seasonStartYear,
  }) => GameStateRow(
    id: id ?? this.id,
    currentDate: currentDate ?? this.currentDate,
    managerName: managerName ?? this.managerName,
    clubId: clubId.present ? clubId.value : this.clubId,
    seed: seed ?? this.seed,
    seasonStartYear: seasonStartYear ?? this.seasonStartYear,
  );
  GameStateRow copyWithCompanion(GameStatesCompanion data) {
    return GameStateRow(
      id: data.id.present ? data.id.value : this.id,
      currentDate:
          data.currentDate.present ? data.currentDate.value : this.currentDate,
      managerName:
          data.managerName.present ? data.managerName.value : this.managerName,
      clubId: data.clubId.present ? data.clubId.value : this.clubId,
      seed: data.seed.present ? data.seed.value : this.seed,
      seasonStartYear:
          data.seasonStartYear.present
              ? data.seasonStartYear.value
              : this.seasonStartYear,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameStateRow(')
          ..write('id: $id, ')
          ..write('currentDate: $currentDate, ')
          ..write('managerName: $managerName, ')
          ..write('clubId: $clubId, ')
          ..write('seed: $seed, ')
          ..write('seasonStartYear: $seasonStartYear')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, currentDate, managerName, clubId, seed, seasonStartYear);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameStateRow &&
          other.id == this.id &&
          other.currentDate == this.currentDate &&
          other.managerName == this.managerName &&
          other.clubId == this.clubId &&
          other.seed == this.seed &&
          other.seasonStartYear == this.seasonStartYear);
}

class GameStatesCompanion extends UpdateCompanion<GameStateRow> {
  final Value<int> id;
  final Value<DateTime> currentDate;
  final Value<String> managerName;
  final Value<String?> clubId;
  final Value<int> seed;
  final Value<int> seasonStartYear;
  const GameStatesCompanion({
    this.id = const Value.absent(),
    this.currentDate = const Value.absent(),
    this.managerName = const Value.absent(),
    this.clubId = const Value.absent(),
    this.seed = const Value.absent(),
    this.seasonStartYear = const Value.absent(),
  });
  GameStatesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime currentDate,
    required String managerName,
    this.clubId = const Value.absent(),
    required int seed,
    this.seasonStartYear = const Value.absent(),
  }) : currentDate = Value(currentDate),
       managerName = Value(managerName),
       seed = Value(seed);
  static Insertable<GameStateRow> custom({
    Expression<int>? id,
    Expression<DateTime>? currentDate,
    Expression<String>? managerName,
    Expression<String>? clubId,
    Expression<int>? seed,
    Expression<int>? seasonStartYear,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentDate != null) 'current_date': currentDate,
      if (managerName != null) 'manager_name': managerName,
      if (clubId != null) 'club_id': clubId,
      if (seed != null) 'seed': seed,
      if (seasonStartYear != null) 'season_start_year': seasonStartYear,
    });
  }

  GameStatesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? currentDate,
    Value<String>? managerName,
    Value<String?>? clubId,
    Value<int>? seed,
    Value<int>? seasonStartYear,
  }) {
    return GameStatesCompanion(
      id: id ?? this.id,
      currentDate: currentDate ?? this.currentDate,
      managerName: managerName ?? this.managerName,
      clubId: clubId ?? this.clubId,
      seed: seed ?? this.seed,
      seasonStartYear: seasonStartYear ?? this.seasonStartYear,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentDate.present) {
      map['current_date'] = Variable<DateTime>(currentDate.value);
    }
    if (managerName.present) {
      map['manager_name'] = Variable<String>(managerName.value);
    }
    if (clubId.present) {
      map['club_id'] = Variable<String>(clubId.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (seasonStartYear.present) {
      map['season_start_year'] = Variable<int>(seasonStartYear.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameStatesCompanion(')
          ..write('id: $id, ')
          ..write('currentDate: $currentDate, ')
          ..write('managerName: $managerName, ')
          ..write('clubId: $clubId, ')
          ..write('seed: $seed, ')
          ..write('seasonStartYear: $seasonStartYear')
          ..write(')'))
        .toString();
  }
}

class $FixturesTable extends Fixtures
    with TableInfo<$FixturesTable, FixtureRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leagueIdMeta = const VerificationMeta(
    'leagueId',
  );
  @override
  late final GeneratedColumn<String> leagueId = GeneratedColumn<String>(
    'league_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
    'round',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeClubIdMeta = const VerificationMeta(
    'homeClubId',
  );
  @override
  late final GeneratedColumn<String> homeClubId = GeneratedColumn<String>(
    'home_club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _awayClubIdMeta = const VerificationMeta(
    'awayClubId',
  );
  @override
  late final GeneratedColumn<String> awayClubId = GeneratedColumn<String>(
    'away_club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeGoalsMeta = const VerificationMeta(
    'homeGoals',
  );
  @override
  late final GeneratedColumn<int> homeGoals = GeneratedColumn<int>(
    'home_goals',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonStartYearMeta = const VerificationMeta(
    'seasonStartYear',
  );
  @override
  late final GeneratedColumn<int> seasonStartYear = GeneratedColumn<int>(
    'season_start_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2026),
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('league'),
  );
  static const VerificationMeta _legMeta = const VerificationMeta('leg');
  @override
  late final GeneratedColumn<int> leg = GeneratedColumn<int>(
    'leg',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awayGoalsMeta = const VerificationMeta(
    'awayGoals',
  );
  @override
  late final GeneratedColumn<int> awayGoals = GeneratedColumn<int>(
    'away_goals',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    leagueId,
    round,
    date,
    homeClubId,
    awayClubId,
    homeGoals,
    seasonStartYear,
    stage,
    leg,
    awayGoals,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixtures';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixtureRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('league_id')) {
      context.handle(
        _leagueIdMeta,
        leagueId.isAcceptableOrUnknown(data['league_id']!, _leagueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leagueIdMeta);
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    } else if (isInserting) {
      context.missing(_roundMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('home_club_id')) {
      context.handle(
        _homeClubIdMeta,
        homeClubId.isAcceptableOrUnknown(
          data['home_club_id']!,
          _homeClubIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_homeClubIdMeta);
    }
    if (data.containsKey('away_club_id')) {
      context.handle(
        _awayClubIdMeta,
        awayClubId.isAcceptableOrUnknown(
          data['away_club_id']!,
          _awayClubIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_awayClubIdMeta);
    }
    if (data.containsKey('home_goals')) {
      context.handle(
        _homeGoalsMeta,
        homeGoals.isAcceptableOrUnknown(data['home_goals']!, _homeGoalsMeta),
      );
    }
    if (data.containsKey('season_start_year')) {
      context.handle(
        _seasonStartYearMeta,
        seasonStartYear.isAcceptableOrUnknown(
          data['season_start_year']!,
          _seasonStartYearMeta,
        ),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('leg')) {
      context.handle(
        _legMeta,
        leg.isAcceptableOrUnknown(data['leg']!, _legMeta),
      );
    }
    if (data.containsKey('away_goals')) {
      context.handle(
        _awayGoalsMeta,
        awayGoals.isAcceptableOrUnknown(data['away_goals']!, _awayGoalsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixtureRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixtureRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      leagueId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}league_id'],
          )!,
      round:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}round'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      homeClubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}home_club_id'],
          )!,
      awayClubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}away_club_id'],
          )!,
      homeGoals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_goals'],
      ),
      seasonStartYear:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}season_start_year'],
          )!,
      stage:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}stage'],
          )!,
      leg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leg'],
      ),
      awayGoals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}away_goals'],
      ),
    );
  }

  @override
  $FixturesTable createAlias(String alias) {
    return $FixturesTable(attachedDatabase, alias);
  }
}

class FixtureRow extends DataClass implements Insertable<FixtureRow> {
  final int id;
  final String leagueId;
  final int round;
  final DateTime date;
  final String homeClubId;
  final String awayClubId;
  final int? homeGoals;
  final int seasonStartYear;
  final String stage;
  final int? leg;
  final int? awayGoals;
  const FixtureRow({
    required this.id,
    required this.leagueId,
    required this.round,
    required this.date,
    required this.homeClubId,
    required this.awayClubId,
    this.homeGoals,
    required this.seasonStartYear,
    required this.stage,
    this.leg,
    this.awayGoals,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['league_id'] = Variable<String>(leagueId);
    map['round'] = Variable<int>(round);
    map['date'] = Variable<DateTime>(date);
    map['home_club_id'] = Variable<String>(homeClubId);
    map['away_club_id'] = Variable<String>(awayClubId);
    if (!nullToAbsent || homeGoals != null) {
      map['home_goals'] = Variable<int>(homeGoals);
    }
    map['season_start_year'] = Variable<int>(seasonStartYear);
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || leg != null) {
      map['leg'] = Variable<int>(leg);
    }
    if (!nullToAbsent || awayGoals != null) {
      map['away_goals'] = Variable<int>(awayGoals);
    }
    return map;
  }

  FixturesCompanion toCompanion(bool nullToAbsent) {
    return FixturesCompanion(
      id: Value(id),
      leagueId: Value(leagueId),
      round: Value(round),
      date: Value(date),
      homeClubId: Value(homeClubId),
      awayClubId: Value(awayClubId),
      homeGoals:
          homeGoals == null && nullToAbsent
              ? const Value.absent()
              : Value(homeGoals),
      seasonStartYear: Value(seasonStartYear),
      stage: Value(stage),
      leg: leg == null && nullToAbsent ? const Value.absent() : Value(leg),
      awayGoals:
          awayGoals == null && nullToAbsent
              ? const Value.absent()
              : Value(awayGoals),
    );
  }

  factory FixtureRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixtureRow(
      id: serializer.fromJson<int>(json['id']),
      leagueId: serializer.fromJson<String>(json['leagueId']),
      round: serializer.fromJson<int>(json['round']),
      date: serializer.fromJson<DateTime>(json['date']),
      homeClubId: serializer.fromJson<String>(json['homeClubId']),
      awayClubId: serializer.fromJson<String>(json['awayClubId']),
      homeGoals: serializer.fromJson<int?>(json['homeGoals']),
      seasonStartYear: serializer.fromJson<int>(json['seasonStartYear']),
      stage: serializer.fromJson<String>(json['stage']),
      leg: serializer.fromJson<int?>(json['leg']),
      awayGoals: serializer.fromJson<int?>(json['awayGoals']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'leagueId': serializer.toJson<String>(leagueId),
      'round': serializer.toJson<int>(round),
      'date': serializer.toJson<DateTime>(date),
      'homeClubId': serializer.toJson<String>(homeClubId),
      'awayClubId': serializer.toJson<String>(awayClubId),
      'homeGoals': serializer.toJson<int?>(homeGoals),
      'seasonStartYear': serializer.toJson<int>(seasonStartYear),
      'stage': serializer.toJson<String>(stage),
      'leg': serializer.toJson<int?>(leg),
      'awayGoals': serializer.toJson<int?>(awayGoals),
    };
  }

  FixtureRow copyWith({
    int? id,
    String? leagueId,
    int? round,
    DateTime? date,
    String? homeClubId,
    String? awayClubId,
    Value<int?> homeGoals = const Value.absent(),
    int? seasonStartYear,
    String? stage,
    Value<int?> leg = const Value.absent(),
    Value<int?> awayGoals = const Value.absent(),
  }) => FixtureRow(
    id: id ?? this.id,
    leagueId: leagueId ?? this.leagueId,
    round: round ?? this.round,
    date: date ?? this.date,
    homeClubId: homeClubId ?? this.homeClubId,
    awayClubId: awayClubId ?? this.awayClubId,
    homeGoals: homeGoals.present ? homeGoals.value : this.homeGoals,
    seasonStartYear: seasonStartYear ?? this.seasonStartYear,
    stage: stage ?? this.stage,
    leg: leg.present ? leg.value : this.leg,
    awayGoals: awayGoals.present ? awayGoals.value : this.awayGoals,
  );
  FixtureRow copyWithCompanion(FixturesCompanion data) {
    return FixtureRow(
      id: data.id.present ? data.id.value : this.id,
      leagueId: data.leagueId.present ? data.leagueId.value : this.leagueId,
      round: data.round.present ? data.round.value : this.round,
      date: data.date.present ? data.date.value : this.date,
      homeClubId:
          data.homeClubId.present ? data.homeClubId.value : this.homeClubId,
      awayClubId:
          data.awayClubId.present ? data.awayClubId.value : this.awayClubId,
      homeGoals: data.homeGoals.present ? data.homeGoals.value : this.homeGoals,
      seasonStartYear:
          data.seasonStartYear.present
              ? data.seasonStartYear.value
              : this.seasonStartYear,
      stage: data.stage.present ? data.stage.value : this.stage,
      leg: data.leg.present ? data.leg.value : this.leg,
      awayGoals: data.awayGoals.present ? data.awayGoals.value : this.awayGoals,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixtureRow(')
          ..write('id: $id, ')
          ..write('leagueId: $leagueId, ')
          ..write('round: $round, ')
          ..write('date: $date, ')
          ..write('homeClubId: $homeClubId, ')
          ..write('awayClubId: $awayClubId, ')
          ..write('homeGoals: $homeGoals, ')
          ..write('seasonStartYear: $seasonStartYear, ')
          ..write('stage: $stage, ')
          ..write('leg: $leg, ')
          ..write('awayGoals: $awayGoals')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    leagueId,
    round,
    date,
    homeClubId,
    awayClubId,
    homeGoals,
    seasonStartYear,
    stage,
    leg,
    awayGoals,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixtureRow &&
          other.id == this.id &&
          other.leagueId == this.leagueId &&
          other.round == this.round &&
          other.date == this.date &&
          other.homeClubId == this.homeClubId &&
          other.awayClubId == this.awayClubId &&
          other.homeGoals == this.homeGoals &&
          other.seasonStartYear == this.seasonStartYear &&
          other.stage == this.stage &&
          other.leg == this.leg &&
          other.awayGoals == this.awayGoals);
}

class FixturesCompanion extends UpdateCompanion<FixtureRow> {
  final Value<int> id;
  final Value<String> leagueId;
  final Value<int> round;
  final Value<DateTime> date;
  final Value<String> homeClubId;
  final Value<String> awayClubId;
  final Value<int?> homeGoals;
  final Value<int> seasonStartYear;
  final Value<String> stage;
  final Value<int?> leg;
  final Value<int?> awayGoals;
  const FixturesCompanion({
    this.id = const Value.absent(),
    this.leagueId = const Value.absent(),
    this.round = const Value.absent(),
    this.date = const Value.absent(),
    this.homeClubId = const Value.absent(),
    this.awayClubId = const Value.absent(),
    this.homeGoals = const Value.absent(),
    this.seasonStartYear = const Value.absent(),
    this.stage = const Value.absent(),
    this.leg = const Value.absent(),
    this.awayGoals = const Value.absent(),
  });
  FixturesCompanion.insert({
    this.id = const Value.absent(),
    required String leagueId,
    required int round,
    required DateTime date,
    required String homeClubId,
    required String awayClubId,
    this.homeGoals = const Value.absent(),
    this.seasonStartYear = const Value.absent(),
    this.stage = const Value.absent(),
    this.leg = const Value.absent(),
    this.awayGoals = const Value.absent(),
  }) : leagueId = Value(leagueId),
       round = Value(round),
       date = Value(date),
       homeClubId = Value(homeClubId),
       awayClubId = Value(awayClubId);
  static Insertable<FixtureRow> custom({
    Expression<int>? id,
    Expression<String>? leagueId,
    Expression<int>? round,
    Expression<DateTime>? date,
    Expression<String>? homeClubId,
    Expression<String>? awayClubId,
    Expression<int>? homeGoals,
    Expression<int>? seasonStartYear,
    Expression<String>? stage,
    Expression<int>? leg,
    Expression<int>? awayGoals,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leagueId != null) 'league_id': leagueId,
      if (round != null) 'round': round,
      if (date != null) 'date': date,
      if (homeClubId != null) 'home_club_id': homeClubId,
      if (awayClubId != null) 'away_club_id': awayClubId,
      if (homeGoals != null) 'home_goals': homeGoals,
      if (seasonStartYear != null) 'season_start_year': seasonStartYear,
      if (stage != null) 'stage': stage,
      if (leg != null) 'leg': leg,
      if (awayGoals != null) 'away_goals': awayGoals,
    });
  }

  FixturesCompanion copyWith({
    Value<int>? id,
    Value<String>? leagueId,
    Value<int>? round,
    Value<DateTime>? date,
    Value<String>? homeClubId,
    Value<String>? awayClubId,
    Value<int?>? homeGoals,
    Value<int>? seasonStartYear,
    Value<String>? stage,
    Value<int?>? leg,
    Value<int?>? awayGoals,
  }) {
    return FixturesCompanion(
      id: id ?? this.id,
      leagueId: leagueId ?? this.leagueId,
      round: round ?? this.round,
      date: date ?? this.date,
      homeClubId: homeClubId ?? this.homeClubId,
      awayClubId: awayClubId ?? this.awayClubId,
      homeGoals: homeGoals ?? this.homeGoals,
      seasonStartYear: seasonStartYear ?? this.seasonStartYear,
      stage: stage ?? this.stage,
      leg: leg ?? this.leg,
      awayGoals: awayGoals ?? this.awayGoals,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (leagueId.present) {
      map['league_id'] = Variable<String>(leagueId.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (homeClubId.present) {
      map['home_club_id'] = Variable<String>(homeClubId.value);
    }
    if (awayClubId.present) {
      map['away_club_id'] = Variable<String>(awayClubId.value);
    }
    if (homeGoals.present) {
      map['home_goals'] = Variable<int>(homeGoals.value);
    }
    if (seasonStartYear.present) {
      map['season_start_year'] = Variable<int>(seasonStartYear.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (leg.present) {
      map['leg'] = Variable<int>(leg.value);
    }
    if (awayGoals.present) {
      map['away_goals'] = Variable<int>(awayGoals.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixturesCompanion(')
          ..write('id: $id, ')
          ..write('leagueId: $leagueId, ')
          ..write('round: $round, ')
          ..write('date: $date, ')
          ..write('homeClubId: $homeClubId, ')
          ..write('awayClubId: $awayClubId, ')
          ..write('homeGoals: $homeGoals, ')
          ..write('seasonStartYear: $seasonStartYear, ')
          ..write('stage: $stage, ')
          ..write('leg: $leg, ')
          ..write('awayGoals: $awayGoals')
          ..write(')'))
        .toString();
  }
}

class $InboxMessagesTable extends InboxMessages
    with TableInfo<$InboxMessagesTable, InboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumnWithTypeConverter<InboxCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<InboxCategory>($InboxMessagesTable.$convertercategory);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumnWithTypeConverter<InboxActionType, String>
  actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<InboxActionType>($InboxMessagesTable.$converteractionType);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<bool> resolved = GeneratedColumn<bool>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _choiceMeta = const VerificationMeta('choice');
  @override
  late final GeneratedColumn<String> choice = GeneratedColumn<String>(
    'choice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    category,
    title,
    body,
    isRead,
    actionType,
    payload,
    resolved,
    choice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    context.handle(_categoryMeta, const VerificationResult.success());
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    context.handle(_actionTypeMeta, const VerificationResult.success());
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    if (data.containsKey('choice')) {
      context.handle(
        _choiceMeta,
        choice.isAcceptableOrUnknown(data['choice']!, _choiceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      category: $InboxMessagesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      body:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}body'],
          )!,
      isRead:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_read'],
          )!,
      actionType: $InboxMessagesTable.$converteractionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action_type'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      resolved:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}resolved'],
          )!,
      choice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}choice'],
      ),
    );
  }

  @override
  $InboxMessagesTable createAlias(String alias) {
    return $InboxMessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<InboxCategory, String, String> $convertercategory =
      const EnumNameConverter<InboxCategory>(InboxCategory.values);
  static JsonTypeConverter2<InboxActionType, String, String>
  $converteractionType = const EnumNameConverter<InboxActionType>(
    InboxActionType.values,
  );
}

class InboxRow extends DataClass implements Insertable<InboxRow> {
  final int id;
  final DateTime date;
  final InboxCategory category;
  final String title;
  final String body;
  final bool isRead;
  final InboxActionType actionType;
  final String? payload;
  final bool resolved;
  final String? choice;
  const InboxRow({
    required this.id,
    required this.date,
    required this.category,
    required this.title,
    required this.body,
    required this.isRead,
    required this.actionType,
    this.payload,
    required this.resolved,
    this.choice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['category'] = Variable<String>(
        $InboxMessagesTable.$convertercategory.toSql(category),
      );
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['is_read'] = Variable<bool>(isRead);
    {
      map['action_type'] = Variable<String>(
        $InboxMessagesTable.$converteractionType.toSql(actionType),
      );
    }
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['resolved'] = Variable<bool>(resolved);
    if (!nullToAbsent || choice != null) {
      map['choice'] = Variable<String>(choice);
    }
    return map;
  }

  InboxMessagesCompanion toCompanion(bool nullToAbsent) {
    return InboxMessagesCompanion(
      id: Value(id),
      date: Value(date),
      category: Value(category),
      title: Value(title),
      body: Value(body),
      isRead: Value(isRead),
      actionType: Value(actionType),
      payload:
          payload == null && nullToAbsent
              ? const Value.absent()
              : Value(payload),
      resolved: Value(resolved),
      choice:
          choice == null && nullToAbsent ? const Value.absent() : Value(choice),
    );
  }

  factory InboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: $InboxMessagesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      actionType: $InboxMessagesTable.$converteractionType.fromJson(
        serializer.fromJson<String>(json['actionType']),
      ),
      payload: serializer.fromJson<String?>(json['payload']),
      resolved: serializer.fromJson<bool>(json['resolved']),
      choice: serializer.fromJson<String?>(json['choice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(
        $InboxMessagesTable.$convertercategory.toJson(category),
      ),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'isRead': serializer.toJson<bool>(isRead),
      'actionType': serializer.toJson<String>(
        $InboxMessagesTable.$converteractionType.toJson(actionType),
      ),
      'payload': serializer.toJson<String?>(payload),
      'resolved': serializer.toJson<bool>(resolved),
      'choice': serializer.toJson<String?>(choice),
    };
  }

  InboxRow copyWith({
    int? id,
    DateTime? date,
    InboxCategory? category,
    String? title,
    String? body,
    bool? isRead,
    InboxActionType? actionType,
    Value<String?> payload = const Value.absent(),
    bool? resolved,
    Value<String?> choice = const Value.absent(),
  }) => InboxRow(
    id: id ?? this.id,
    date: date ?? this.date,
    category: category ?? this.category,
    title: title ?? this.title,
    body: body ?? this.body,
    isRead: isRead ?? this.isRead,
    actionType: actionType ?? this.actionType,
    payload: payload.present ? payload.value : this.payload,
    resolved: resolved ?? this.resolved,
    choice: choice.present ? choice.value : this.choice,
  );
  InboxRow copyWithCompanion(InboxMessagesCompanion data) {
    return InboxRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      payload: data.payload.present ? data.payload.value : this.payload,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
      choice: data.choice.present ? data.choice.value : this.choice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('isRead: $isRead, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('resolved: $resolved, ')
          ..write('choice: $choice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    category,
    title,
    body,
    isRead,
    actionType,
    payload,
    resolved,
    choice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.category == this.category &&
          other.title == this.title &&
          other.body == this.body &&
          other.isRead == this.isRead &&
          other.actionType == this.actionType &&
          other.payload == this.payload &&
          other.resolved == this.resolved &&
          other.choice == this.choice);
}

class InboxMessagesCompanion extends UpdateCompanion<InboxRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<InboxCategory> category;
  final Value<String> title;
  final Value<String> body;
  final Value<bool> isRead;
  final Value<InboxActionType> actionType;
  final Value<String?> payload;
  final Value<bool> resolved;
  final Value<String?> choice;
  const InboxMessagesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.isRead = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payload = const Value.absent(),
    this.resolved = const Value.absent(),
    this.choice = const Value.absent(),
  });
  InboxMessagesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required InboxCategory category,
    required String title,
    required String body,
    this.isRead = const Value.absent(),
    required InboxActionType actionType,
    this.payload = const Value.absent(),
    this.resolved = const Value.absent(),
    this.choice = const Value.absent(),
  }) : date = Value(date),
       category = Value(category),
       title = Value(title),
       body = Value(body),
       actionType = Value(actionType);
  static Insertable<InboxRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? body,
    Expression<bool>? isRead,
    Expression<String>? actionType,
    Expression<String>? payload,
    Expression<bool>? resolved,
    Expression<String>? choice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (isRead != null) 'is_read': isRead,
      if (actionType != null) 'action_type': actionType,
      if (payload != null) 'payload': payload,
      if (resolved != null) 'resolved': resolved,
      if (choice != null) 'choice': choice,
    });
  }

  InboxMessagesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<InboxCategory>? category,
    Value<String>? title,
    Value<String>? body,
    Value<bool>? isRead,
    Value<InboxActionType>? actionType,
    Value<String?>? payload,
    Value<bool>? resolved,
    Value<String?>? choice,
  }) {
    return InboxMessagesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      category: category ?? this.category,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      resolved: resolved ?? this.resolved,
      choice: choice ?? this.choice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $InboxMessagesTable.$convertercategory.toSql(category.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(
        $InboxMessagesTable.$converteractionType.toSql(actionType.value),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<bool>(resolved.value);
    }
    if (choice.present) {
      map['choice'] = Variable<String>(choice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxMessagesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('isRead: $isRead, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('resolved: $resolved, ')
          ..write('choice: $choice')
          ..write(')'))
        .toString();
  }
}

class $ClubTacticsTable extends ClubTactics
    with TableInfo<$ClubTacticsTable, ClubTacticRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClubTacticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clubIdMeta = const VerificationMeta('clubId');
  @override
  late final GeneratedColumn<String> clubId = GeneratedColumn<String>(
    'club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formationMeta = const VerificationMeta(
    'formation',
  );
  @override
  late final GeneratedColumnWithTypeConverter<Formation, String> formation =
      GeneratedColumn<String>(
        'formation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Formation>($ClubTacticsTable.$converterformation);
  static const VerificationMeta _mentalityMeta = const VerificationMeta(
    'mentality',
  );
  @override
  late final GeneratedColumnWithTypeConverter<Mentality, String> mentality =
      GeneratedColumn<String>(
        'mentality',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Mentality>($ClubTacticsTable.$convertermentality);
  static const VerificationMeta _starterIdsMeta = const VerificationMeta(
    'starterIds',
  );
  @override
  late final GeneratedColumn<String> starterIds = GeneratedColumn<String>(
    'starter_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subIdsMeta = const VerificationMeta('subIds');
  @override
  late final GeneratedColumn<String> subIds = GeneratedColumn<String>(
    'sub_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clubId,
    formation,
    mentality,
    starterIds,
    subIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'club_tactics';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClubTacticRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('club_id')) {
      context.handle(
        _clubIdMeta,
        clubId.isAcceptableOrUnknown(data['club_id']!, _clubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clubIdMeta);
    }
    context.handle(_formationMeta, const VerificationResult.success());
    context.handle(_mentalityMeta, const VerificationResult.success());
    if (data.containsKey('starter_ids')) {
      context.handle(
        _starterIdsMeta,
        starterIds.isAcceptableOrUnknown(data['starter_ids']!, _starterIdsMeta),
      );
    }
    if (data.containsKey('sub_ids')) {
      context.handle(
        _subIdsMeta,
        subIds.isAcceptableOrUnknown(data['sub_ids']!, _subIdsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clubId};
  @override
  ClubTacticRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClubTacticRow(
      clubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}club_id'],
          )!,
      formation: $ClubTacticsTable.$converterformation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}formation'],
        )!,
      ),
      mentality: $ClubTacticsTable.$convertermentality.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mentality'],
        )!,
      ),
      starterIds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}starter_ids'],
          )!,
      subIds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sub_ids'],
          )!,
    );
  }

  @override
  $ClubTacticsTable createAlias(String alias) {
    return $ClubTacticsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Formation, String, String> $converterformation =
      const EnumNameConverter<Formation>(Formation.values);
  static JsonTypeConverter2<Mentality, String, String> $convertermentality =
      const EnumNameConverter<Mentality>(Mentality.values);
}

class ClubTacticRow extends DataClass implements Insertable<ClubTacticRow> {
  final String clubId;
  final Formation formation;
  final Mentality mentality;
  final String starterIds;
  final String subIds;
  const ClubTacticRow({
    required this.clubId,
    required this.formation,
    required this.mentality,
    required this.starterIds,
    required this.subIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['club_id'] = Variable<String>(clubId);
    {
      map['formation'] = Variable<String>(
        $ClubTacticsTable.$converterformation.toSql(formation),
      );
    }
    {
      map['mentality'] = Variable<String>(
        $ClubTacticsTable.$convertermentality.toSql(mentality),
      );
    }
    map['starter_ids'] = Variable<String>(starterIds);
    map['sub_ids'] = Variable<String>(subIds);
    return map;
  }

  ClubTacticsCompanion toCompanion(bool nullToAbsent) {
    return ClubTacticsCompanion(
      clubId: Value(clubId),
      formation: Value(formation),
      mentality: Value(mentality),
      starterIds: Value(starterIds),
      subIds: Value(subIds),
    );
  }

  factory ClubTacticRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClubTacticRow(
      clubId: serializer.fromJson<String>(json['clubId']),
      formation: $ClubTacticsTable.$converterformation.fromJson(
        serializer.fromJson<String>(json['formation']),
      ),
      mentality: $ClubTacticsTable.$convertermentality.fromJson(
        serializer.fromJson<String>(json['mentality']),
      ),
      starterIds: serializer.fromJson<String>(json['starterIds']),
      subIds: serializer.fromJson<String>(json['subIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clubId': serializer.toJson<String>(clubId),
      'formation': serializer.toJson<String>(
        $ClubTacticsTable.$converterformation.toJson(formation),
      ),
      'mentality': serializer.toJson<String>(
        $ClubTacticsTable.$convertermentality.toJson(mentality),
      ),
      'starterIds': serializer.toJson<String>(starterIds),
      'subIds': serializer.toJson<String>(subIds),
    };
  }

  ClubTacticRow copyWith({
    String? clubId,
    Formation? formation,
    Mentality? mentality,
    String? starterIds,
    String? subIds,
  }) => ClubTacticRow(
    clubId: clubId ?? this.clubId,
    formation: formation ?? this.formation,
    mentality: mentality ?? this.mentality,
    starterIds: starterIds ?? this.starterIds,
    subIds: subIds ?? this.subIds,
  );
  ClubTacticRow copyWithCompanion(ClubTacticsCompanion data) {
    return ClubTacticRow(
      clubId: data.clubId.present ? data.clubId.value : this.clubId,
      formation: data.formation.present ? data.formation.value : this.formation,
      mentality: data.mentality.present ? data.mentality.value : this.mentality,
      starterIds:
          data.starterIds.present ? data.starterIds.value : this.starterIds,
      subIds: data.subIds.present ? data.subIds.value : this.subIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClubTacticRow(')
          ..write('clubId: $clubId, ')
          ..write('formation: $formation, ')
          ..write('mentality: $mentality, ')
          ..write('starterIds: $starterIds, ')
          ..write('subIds: $subIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(clubId, formation, mentality, starterIds, subIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClubTacticRow &&
          other.clubId == this.clubId &&
          other.formation == this.formation &&
          other.mentality == this.mentality &&
          other.starterIds == this.starterIds &&
          other.subIds == this.subIds);
}

class ClubTacticsCompanion extends UpdateCompanion<ClubTacticRow> {
  final Value<String> clubId;
  final Value<Formation> formation;
  final Value<Mentality> mentality;
  final Value<String> starterIds;
  final Value<String> subIds;
  final Value<int> rowid;
  const ClubTacticsCompanion({
    this.clubId = const Value.absent(),
    this.formation = const Value.absent(),
    this.mentality = const Value.absent(),
    this.starterIds = const Value.absent(),
    this.subIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClubTacticsCompanion.insert({
    required String clubId,
    required Formation formation,
    required Mentality mentality,
    this.starterIds = const Value.absent(),
    this.subIds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clubId = Value(clubId),
       formation = Value(formation),
       mentality = Value(mentality);
  static Insertable<ClubTacticRow> custom({
    Expression<String>? clubId,
    Expression<String>? formation,
    Expression<String>? mentality,
    Expression<String>? starterIds,
    Expression<String>? subIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clubId != null) 'club_id': clubId,
      if (formation != null) 'formation': formation,
      if (mentality != null) 'mentality': mentality,
      if (starterIds != null) 'starter_ids': starterIds,
      if (subIds != null) 'sub_ids': subIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClubTacticsCompanion copyWith({
    Value<String>? clubId,
    Value<Formation>? formation,
    Value<Mentality>? mentality,
    Value<String>? starterIds,
    Value<String>? subIds,
    Value<int>? rowid,
  }) {
    return ClubTacticsCompanion(
      clubId: clubId ?? this.clubId,
      formation: formation ?? this.formation,
      mentality: mentality ?? this.mentality,
      starterIds: starterIds ?? this.starterIds,
      subIds: subIds ?? this.subIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clubId.present) {
      map['club_id'] = Variable<String>(clubId.value);
    }
    if (formation.present) {
      map['formation'] = Variable<String>(
        $ClubTacticsTable.$converterformation.toSql(formation.value),
      );
    }
    if (mentality.present) {
      map['mentality'] = Variable<String>(
        $ClubTacticsTable.$convertermentality.toSql(mentality.value),
      );
    }
    if (starterIds.present) {
      map['starter_ids'] = Variable<String>(starterIds.value);
    }
    if (subIds.present) {
      map['sub_ids'] = Variable<String>(subIds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClubTacticsCompanion(')
          ..write('clubId: $clubId, ')
          ..write('formation: $formation, ')
          ..write('mentality: $mentality, ')
          ..write('starterIds: $starterIds, ')
          ..write('subIds: $subIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransferOffersTable extends TransferOffers
    with TableInfo<$TransferOffersTable, TransferOfferRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransferOffersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromClubIdMeta = const VerificationMeta(
    'fromClubId',
  );
  @override
  late final GeneratedColumn<String> fromClubId = GeneratedColumn<String>(
    'from_club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toClubIdMeta = const VerificationMeta(
    'toClubId',
  );
  @override
  late final GeneratedColumn<String> toClubId = GeneratedColumn<String>(
    'to_club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<int> fee = GeneratedColumn<int>(
    'fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumnWithTypeConverter<TransferOfferStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TransferOfferStatus>($TransferOffersTable.$converterstatus);
  static const VerificationMeta _createdDateMeta = const VerificationMeta(
    'createdDate',
  );
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
    'created_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseDateMeta = const VerificationMeta(
    'responseDate',
  );
  @override
  late final GeneratedColumn<DateTime> responseDate = GeneratedColumn<DateTime>(
    'response_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentYearsMeta = const VerificationMeta(
    'installmentYears',
  );
  @override
  late final GeneratedColumn<int> installmentYears = GeneratedColumn<int>(
    'installment_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _sellOnPctMeta = const VerificationMeta(
    'sellOnPct',
  );
  @override
  late final GeneratedColumn<int> sellOnPct = GeneratedColumn<int>(
    'sell_on_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
    'round',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _expiresDateMeta = const VerificationMeta(
    'expiresDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiresDate = GeneratedColumn<DateTime>(
    'expires_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("permanent"),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playerId,
    fromClubId,
    toClubId,
    fee,
    status,
    createdDate,
    responseDate,
    installmentYears,
    sellOnPct,
    round,
    expiresDate,
    reason,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfer_offers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransferOfferRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('from_club_id')) {
      context.handle(
        _fromClubIdMeta,
        fromClubId.isAcceptableOrUnknown(
          data['from_club_id']!,
          _fromClubIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromClubIdMeta);
    }
    if (data.containsKey('to_club_id')) {
      context.handle(
        _toClubIdMeta,
        toClubId.isAcceptableOrUnknown(data['to_club_id']!, _toClubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toClubIdMeta);
    }
    if (data.containsKey('fee')) {
      context.handle(
        _feeMeta,
        fee.isAcceptableOrUnknown(data['fee']!, _feeMeta),
      );
    } else if (isInserting) {
      context.missing(_feeMeta);
    }
    context.handle(_statusMeta, const VerificationResult.success());
    if (data.containsKey('created_date')) {
      context.handle(
        _createdDateMeta,
        createdDate.isAcceptableOrUnknown(
          data['created_date']!,
          _createdDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdDateMeta);
    }
    if (data.containsKey('response_date')) {
      context.handle(
        _responseDateMeta,
        responseDate.isAcceptableOrUnknown(
          data['response_date']!,
          _responseDateMeta,
        ),
      );
    }
    if (data.containsKey('installment_years')) {
      context.handle(
        _installmentYearsMeta,
        installmentYears.isAcceptableOrUnknown(
          data['installment_years']!,
          _installmentYearsMeta,
        ),
      );
    }
    if (data.containsKey('sell_on_pct')) {
      context.handle(
        _sellOnPctMeta,
        sellOnPct.isAcceptableOrUnknown(data['sell_on_pct']!, _sellOnPctMeta),
      );
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    }
    if (data.containsKey('expires_date')) {
      context.handle(
        _expiresDateMeta,
        expiresDate.isAcceptableOrUnknown(
          data['expires_date']!,
          _expiresDateMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransferOfferRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransferOfferRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      playerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}player_id'],
          )!,
      fromClubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}from_club_id'],
          )!,
      toClubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}to_club_id'],
          )!,
      fee:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}fee'],
          )!,
      status: $TransferOffersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_date'],
          )!,
      responseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}response_date'],
      ),
      installmentYears:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}installment_years'],
          )!,
      sellOnPct:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sell_on_pct'],
          )!,
      round:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}round'],
          )!,
      expiresDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_date'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      kind:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}kind'],
          )!,
    );
  }

  @override
  $TransferOffersTable createAlias(String alias) {
    return $TransferOffersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransferOfferStatus, String, String>
  $converterstatus = const EnumNameConverter<TransferOfferStatus>(
    TransferOfferStatus.values,
  );
}

class TransferOfferRow extends DataClass
    implements Insertable<TransferOfferRow> {
  final int id;
  final int playerId;
  final String fromClubId;
  final String toClubId;
  final int fee;
  final TransferOfferStatus status;
  final DateTime createdDate;
  final DateTime? responseDate;
  final int installmentYears;
  final int sellOnPct;
  final int round;
  final DateTime? expiresDate;
  final String? reason;
  final String kind;
  const TransferOfferRow({
    required this.id,
    required this.playerId,
    required this.fromClubId,
    required this.toClubId,
    required this.fee,
    required this.status,
    required this.createdDate,
    this.responseDate,
    required this.installmentYears,
    required this.sellOnPct,
    required this.round,
    this.expiresDate,
    this.reason,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['player_id'] = Variable<int>(playerId);
    map['from_club_id'] = Variable<String>(fromClubId);
    map['to_club_id'] = Variable<String>(toClubId);
    map['fee'] = Variable<int>(fee);
    {
      map['status'] = Variable<String>(
        $TransferOffersTable.$converterstatus.toSql(status),
      );
    }
    map['created_date'] = Variable<DateTime>(createdDate);
    if (!nullToAbsent || responseDate != null) {
      map['response_date'] = Variable<DateTime>(responseDate);
    }
    map['installment_years'] = Variable<int>(installmentYears);
    map['sell_on_pct'] = Variable<int>(sellOnPct);
    map['round'] = Variable<int>(round);
    if (!nullToAbsent || expiresDate != null) {
      map['expires_date'] = Variable<DateTime>(expiresDate);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['kind'] = Variable<String>(kind);
    return map;
  }

  TransferOffersCompanion toCompanion(bool nullToAbsent) {
    return TransferOffersCompanion(
      id: Value(id),
      playerId: Value(playerId),
      fromClubId: Value(fromClubId),
      toClubId: Value(toClubId),
      fee: Value(fee),
      status: Value(status),
      createdDate: Value(createdDate),
      responseDate:
          responseDate == null && nullToAbsent
              ? const Value.absent()
              : Value(responseDate),
      installmentYears: Value(installmentYears),
      sellOnPct: Value(sellOnPct),
      round: Value(round),
      expiresDate:
          expiresDate == null && nullToAbsent
              ? const Value.absent()
              : Value(expiresDate),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      kind: Value(kind),
    );
  }

  factory TransferOfferRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransferOfferRow(
      id: serializer.fromJson<int>(json['id']),
      playerId: serializer.fromJson<int>(json['playerId']),
      fromClubId: serializer.fromJson<String>(json['fromClubId']),
      toClubId: serializer.fromJson<String>(json['toClubId']),
      fee: serializer.fromJson<int>(json['fee']),
      status: $TransferOffersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdDate: serializer.fromJson<DateTime>(json['createdDate']),
      responseDate: serializer.fromJson<DateTime?>(json['responseDate']),
      installmentYears: serializer.fromJson<int>(json['installmentYears']),
      sellOnPct: serializer.fromJson<int>(json['sellOnPct']),
      round: serializer.fromJson<int>(json['round']),
      expiresDate: serializer.fromJson<DateTime?>(json['expiresDate']),
      reason: serializer.fromJson<String?>(json['reason']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playerId': serializer.toJson<int>(playerId),
      'fromClubId': serializer.toJson<String>(fromClubId),
      'toClubId': serializer.toJson<String>(toClubId),
      'fee': serializer.toJson<int>(fee),
      'status': serializer.toJson<String>(
        $TransferOffersTable.$converterstatus.toJson(status),
      ),
      'createdDate': serializer.toJson<DateTime>(createdDate),
      'responseDate': serializer.toJson<DateTime?>(responseDate),
      'installmentYears': serializer.toJson<int>(installmentYears),
      'sellOnPct': serializer.toJson<int>(sellOnPct),
      'round': serializer.toJson<int>(round),
      'expiresDate': serializer.toJson<DateTime?>(expiresDate),
      'reason': serializer.toJson<String?>(reason),
      'kind': serializer.toJson<String>(kind),
    };
  }

  TransferOfferRow copyWith({
    int? id,
    int? playerId,
    String? fromClubId,
    String? toClubId,
    int? fee,
    TransferOfferStatus? status,
    DateTime? createdDate,
    Value<DateTime?> responseDate = const Value.absent(),
    int? installmentYears,
    int? sellOnPct,
    int? round,
    Value<DateTime?> expiresDate = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    String? kind,
  }) => TransferOfferRow(
    id: id ?? this.id,
    playerId: playerId ?? this.playerId,
    fromClubId: fromClubId ?? this.fromClubId,
    toClubId: toClubId ?? this.toClubId,
    fee: fee ?? this.fee,
    status: status ?? this.status,
    createdDate: createdDate ?? this.createdDate,
    responseDate: responseDate.present ? responseDate.value : this.responseDate,
    installmentYears: installmentYears ?? this.installmentYears,
    sellOnPct: sellOnPct ?? this.sellOnPct,
    round: round ?? this.round,
    expiresDate: expiresDate.present ? expiresDate.value : this.expiresDate,
    reason: reason.present ? reason.value : this.reason,
    kind: kind ?? this.kind,
  );
  TransferOfferRow copyWithCompanion(TransferOffersCompanion data) {
    return TransferOfferRow(
      id: data.id.present ? data.id.value : this.id,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      fromClubId:
          data.fromClubId.present ? data.fromClubId.value : this.fromClubId,
      toClubId: data.toClubId.present ? data.toClubId.value : this.toClubId,
      fee: data.fee.present ? data.fee.value : this.fee,
      status: data.status.present ? data.status.value : this.status,
      createdDate:
          data.createdDate.present ? data.createdDate.value : this.createdDate,
      responseDate:
          data.responseDate.present
              ? data.responseDate.value
              : this.responseDate,
      installmentYears:
          data.installmentYears.present
              ? data.installmentYears.value
              : this.installmentYears,
      sellOnPct: data.sellOnPct.present ? data.sellOnPct.value : this.sellOnPct,
      round: data.round.present ? data.round.value : this.round,
      expiresDate:
          data.expiresDate.present ? data.expiresDate.value : this.expiresDate,
      reason: data.reason.present ? data.reason.value : this.reason,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransferOfferRow(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('fromClubId: $fromClubId, ')
          ..write('toClubId: $toClubId, ')
          ..write('fee: $fee, ')
          ..write('status: $status, ')
          ..write('createdDate: $createdDate, ')
          ..write('responseDate: $responseDate, ')
          ..write('installmentYears: $installmentYears, ')
          ..write('sellOnPct: $sellOnPct, ')
          ..write('round: $round, ')
          ..write('expiresDate: $expiresDate, ')
          ..write('reason: $reason, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    playerId,
    fromClubId,
    toClubId,
    fee,
    status,
    createdDate,
    responseDate,
    installmentYears,
    sellOnPct,
    round,
    expiresDate,
    reason,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransferOfferRow &&
          other.id == this.id &&
          other.playerId == this.playerId &&
          other.fromClubId == this.fromClubId &&
          other.toClubId == this.toClubId &&
          other.fee == this.fee &&
          other.status == this.status &&
          other.createdDate == this.createdDate &&
          other.responseDate == this.responseDate &&
          other.installmentYears == this.installmentYears &&
          other.sellOnPct == this.sellOnPct &&
          other.round == this.round &&
          other.expiresDate == this.expiresDate &&
          other.reason == this.reason &&
          other.kind == this.kind);
}

class TransferOffersCompanion extends UpdateCompanion<TransferOfferRow> {
  final Value<int> id;
  final Value<int> playerId;
  final Value<String> fromClubId;
  final Value<String> toClubId;
  final Value<int> fee;
  final Value<TransferOfferStatus> status;
  final Value<DateTime> createdDate;
  final Value<DateTime?> responseDate;
  final Value<int> installmentYears;
  final Value<int> sellOnPct;
  final Value<int> round;
  final Value<DateTime?> expiresDate;
  final Value<String?> reason;
  final Value<String> kind;
  const TransferOffersCompanion({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    this.fromClubId = const Value.absent(),
    this.toClubId = const Value.absent(),
    this.fee = const Value.absent(),
    this.status = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.responseDate = const Value.absent(),
    this.installmentYears = const Value.absent(),
    this.sellOnPct = const Value.absent(),
    this.round = const Value.absent(),
    this.expiresDate = const Value.absent(),
    this.reason = const Value.absent(),
    this.kind = const Value.absent(),
  });
  TransferOffersCompanion.insert({
    this.id = const Value.absent(),
    required int playerId,
    required String fromClubId,
    required String toClubId,
    required int fee,
    required TransferOfferStatus status,
    required DateTime createdDate,
    this.responseDate = const Value.absent(),
    this.installmentYears = const Value.absent(),
    this.sellOnPct = const Value.absent(),
    this.round = const Value.absent(),
    this.expiresDate = const Value.absent(),
    this.reason = const Value.absent(),
    this.kind = const Value.absent(),
  }) : playerId = Value(playerId),
       fromClubId = Value(fromClubId),
       toClubId = Value(toClubId),
       fee = Value(fee),
       status = Value(status),
       createdDate = Value(createdDate);
  static Insertable<TransferOfferRow> custom({
    Expression<int>? id,
    Expression<int>? playerId,
    Expression<String>? fromClubId,
    Expression<String>? toClubId,
    Expression<int>? fee,
    Expression<String>? status,
    Expression<DateTime>? createdDate,
    Expression<DateTime>? responseDate,
    Expression<int>? installmentYears,
    Expression<int>? sellOnPct,
    Expression<int>? round,
    Expression<DateTime>? expiresDate,
    Expression<String>? reason,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerId != null) 'player_id': playerId,
      if (fromClubId != null) 'from_club_id': fromClubId,
      if (toClubId != null) 'to_club_id': toClubId,
      if (fee != null) 'fee': fee,
      if (status != null) 'status': status,
      if (createdDate != null) 'created_date': createdDate,
      if (responseDate != null) 'response_date': responseDate,
      if (installmentYears != null) 'installment_years': installmentYears,
      if (sellOnPct != null) 'sell_on_pct': sellOnPct,
      if (round != null) 'round': round,
      if (expiresDate != null) 'expires_date': expiresDate,
      if (reason != null) 'reason': reason,
      if (kind != null) 'kind': kind,
    });
  }

  TransferOffersCompanion copyWith({
    Value<int>? id,
    Value<int>? playerId,
    Value<String>? fromClubId,
    Value<String>? toClubId,
    Value<int>? fee,
    Value<TransferOfferStatus>? status,
    Value<DateTime>? createdDate,
    Value<DateTime?>? responseDate,
    Value<int>? installmentYears,
    Value<int>? sellOnPct,
    Value<int>? round,
    Value<DateTime?>? expiresDate,
    Value<String?>? reason,
    Value<String>? kind,
  }) {
    return TransferOffersCompanion(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      fromClubId: fromClubId ?? this.fromClubId,
      toClubId: toClubId ?? this.toClubId,
      fee: fee ?? this.fee,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      responseDate: responseDate ?? this.responseDate,
      installmentYears: installmentYears ?? this.installmentYears,
      sellOnPct: sellOnPct ?? this.sellOnPct,
      round: round ?? this.round,
      expiresDate: expiresDate ?? this.expiresDate,
      reason: reason ?? this.reason,
      kind: kind ?? this.kind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (fromClubId.present) {
      map['from_club_id'] = Variable<String>(fromClubId.value);
    }
    if (toClubId.present) {
      map['to_club_id'] = Variable<String>(toClubId.value);
    }
    if (fee.present) {
      map['fee'] = Variable<int>(fee.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TransferOffersTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdDate.present) {
      map['created_date'] = Variable<DateTime>(createdDate.value);
    }
    if (responseDate.present) {
      map['response_date'] = Variable<DateTime>(responseDate.value);
    }
    if (installmentYears.present) {
      map['installment_years'] = Variable<int>(installmentYears.value);
    }
    if (sellOnPct.present) {
      map['sell_on_pct'] = Variable<int>(sellOnPct.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (expiresDate.present) {
      map['expires_date'] = Variable<DateTime>(expiresDate.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferOffersCompanion(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('fromClubId: $fromClubId, ')
          ..write('toClubId: $toClubId, ')
          ..write('fee: $fee, ')
          ..write('status: $status, ')
          ..write('createdDate: $createdDate, ')
          ..write('responseDate: $responseDate, ')
          ..write('installmentYears: $installmentYears, ')
          ..write('sellOnPct: $sellOnPct, ')
          ..write('round: $round, ')
          ..write('expiresDate: $expiresDate, ')
          ..write('reason: $reason, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

class $TransferHistoryTable extends TransferHistory
    with TableInfo<$TransferHistoryTable, TransferHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransferHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerNameMeta = const VerificationMeta(
    'playerName',
  );
  @override
  late final GeneratedColumn<String> playerName = GeneratedColumn<String>(
    'player_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromClubIdMeta = const VerificationMeta(
    'fromClubId',
  );
  @override
  late final GeneratedColumn<String> fromClubId = GeneratedColumn<String>(
    'from_club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toClubIdMeta = const VerificationMeta(
    'toClubId',
  );
  @override
  late final GeneratedColumn<String> toClubId = GeneratedColumn<String>(
    'to_club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<int> fee = GeneratedColumn<int>(
    'fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<TransferType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransferType>($TransferHistoryTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    playerId,
    playerName,
    fromClubId,
    toClubId,
    fee,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfer_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransferHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('player_name')) {
      context.handle(
        _playerNameMeta,
        playerName.isAcceptableOrUnknown(data['player_name']!, _playerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_playerNameMeta);
    }
    if (data.containsKey('from_club_id')) {
      context.handle(
        _fromClubIdMeta,
        fromClubId.isAcceptableOrUnknown(
          data['from_club_id']!,
          _fromClubIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromClubIdMeta);
    }
    if (data.containsKey('to_club_id')) {
      context.handle(
        _toClubIdMeta,
        toClubId.isAcceptableOrUnknown(data['to_club_id']!, _toClubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toClubIdMeta);
    }
    if (data.containsKey('fee')) {
      context.handle(
        _feeMeta,
        fee.isAcceptableOrUnknown(data['fee']!, _feeMeta),
      );
    } else if (isInserting) {
      context.missing(_feeMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransferHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransferHistoryRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      playerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}player_id'],
          )!,
      playerName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}player_name'],
          )!,
      fromClubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}from_club_id'],
          )!,
      toClubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}to_club_id'],
          )!,
      fee:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}fee'],
          )!,
      type: $TransferHistoryTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
    );
  }

  @override
  $TransferHistoryTable createAlias(String alias) {
    return $TransferHistoryTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransferType, String, String> $convertertype =
      const EnumNameConverter<TransferType>(TransferType.values);
}

class TransferHistoryRow extends DataClass
    implements Insertable<TransferHistoryRow> {
  final int id;
  final DateTime date;
  final int playerId;
  final String playerName;
  final String fromClubId;
  final String toClubId;
  final int fee;
  final TransferType type;
  const TransferHistoryRow({
    required this.id,
    required this.date,
    required this.playerId,
    required this.playerName,
    required this.fromClubId,
    required this.toClubId,
    required this.fee,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['player_id'] = Variable<int>(playerId);
    map['player_name'] = Variable<String>(playerName);
    map['from_club_id'] = Variable<String>(fromClubId);
    map['to_club_id'] = Variable<String>(toClubId);
    map['fee'] = Variable<int>(fee);
    {
      map['type'] = Variable<String>(
        $TransferHistoryTable.$convertertype.toSql(type),
      );
    }
    return map;
  }

  TransferHistoryCompanion toCompanion(bool nullToAbsent) {
    return TransferHistoryCompanion(
      id: Value(id),
      date: Value(date),
      playerId: Value(playerId),
      playerName: Value(playerName),
      fromClubId: Value(fromClubId),
      toClubId: Value(toClubId),
      fee: Value(fee),
      type: Value(type),
    );
  }

  factory TransferHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransferHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      playerId: serializer.fromJson<int>(json['playerId']),
      playerName: serializer.fromJson<String>(json['playerName']),
      fromClubId: serializer.fromJson<String>(json['fromClubId']),
      toClubId: serializer.fromJson<String>(json['toClubId']),
      fee: serializer.fromJson<int>(json['fee']),
      type: $TransferHistoryTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'playerId': serializer.toJson<int>(playerId),
      'playerName': serializer.toJson<String>(playerName),
      'fromClubId': serializer.toJson<String>(fromClubId),
      'toClubId': serializer.toJson<String>(toClubId),
      'fee': serializer.toJson<int>(fee),
      'type': serializer.toJson<String>(
        $TransferHistoryTable.$convertertype.toJson(type),
      ),
    };
  }

  TransferHistoryRow copyWith({
    int? id,
    DateTime? date,
    int? playerId,
    String? playerName,
    String? fromClubId,
    String? toClubId,
    int? fee,
    TransferType? type,
  }) => TransferHistoryRow(
    id: id ?? this.id,
    date: date ?? this.date,
    playerId: playerId ?? this.playerId,
    playerName: playerName ?? this.playerName,
    fromClubId: fromClubId ?? this.fromClubId,
    toClubId: toClubId ?? this.toClubId,
    fee: fee ?? this.fee,
    type: type ?? this.type,
  );
  TransferHistoryRow copyWithCompanion(TransferHistoryCompanion data) {
    return TransferHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      playerName:
          data.playerName.present ? data.playerName.value : this.playerName,
      fromClubId:
          data.fromClubId.present ? data.fromClubId.value : this.fromClubId,
      toClubId: data.toClubId.present ? data.toClubId.value : this.toClubId,
      fee: data.fee.present ? data.fee.value : this.fee,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransferHistoryRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('playerId: $playerId, ')
          ..write('playerName: $playerName, ')
          ..write('fromClubId: $fromClubId, ')
          ..write('toClubId: $toClubId, ')
          ..write('fee: $fee, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    playerId,
    playerName,
    fromClubId,
    toClubId,
    fee,
    type,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransferHistoryRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.playerId == this.playerId &&
          other.playerName == this.playerName &&
          other.fromClubId == this.fromClubId &&
          other.toClubId == this.toClubId &&
          other.fee == this.fee &&
          other.type == this.type);
}

class TransferHistoryCompanion extends UpdateCompanion<TransferHistoryRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> playerId;
  final Value<String> playerName;
  final Value<String> fromClubId;
  final Value<String> toClubId;
  final Value<int> fee;
  final Value<TransferType> type;
  const TransferHistoryCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.playerId = const Value.absent(),
    this.playerName = const Value.absent(),
    this.fromClubId = const Value.absent(),
    this.toClubId = const Value.absent(),
    this.fee = const Value.absent(),
    this.type = const Value.absent(),
  });
  TransferHistoryCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int playerId,
    required String playerName,
    required String fromClubId,
    required String toClubId,
    required int fee,
    required TransferType type,
  }) : date = Value(date),
       playerId = Value(playerId),
       playerName = Value(playerName),
       fromClubId = Value(fromClubId),
       toClubId = Value(toClubId),
       fee = Value(fee),
       type = Value(type);
  static Insertable<TransferHistoryRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? playerId,
    Expression<String>? playerName,
    Expression<String>? fromClubId,
    Expression<String>? toClubId,
    Expression<int>? fee,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (playerId != null) 'player_id': playerId,
      if (playerName != null) 'player_name': playerName,
      if (fromClubId != null) 'from_club_id': fromClubId,
      if (toClubId != null) 'to_club_id': toClubId,
      if (fee != null) 'fee': fee,
      if (type != null) 'type': type,
    });
  }

  TransferHistoryCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? playerId,
    Value<String>? playerName,
    Value<String>? fromClubId,
    Value<String>? toClubId,
    Value<int>? fee,
    Value<TransferType>? type,
  }) {
    return TransferHistoryCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      fromClubId: fromClubId ?? this.fromClubId,
      toClubId: toClubId ?? this.toClubId,
      fee: fee ?? this.fee,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (playerName.present) {
      map['player_name'] = Variable<String>(playerName.value);
    }
    if (fromClubId.present) {
      map['from_club_id'] = Variable<String>(fromClubId.value);
    }
    if (toClubId.present) {
      map['to_club_id'] = Variable<String>(toClubId.value);
    }
    if (fee.present) {
      map['fee'] = Variable<int>(fee.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TransferHistoryTable.$convertertype.toSql(type.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferHistoryCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('playerId: $playerId, ')
          ..write('playerName: $playerName, ')
          ..write('fromClubId: $fromClubId, ')
          ..write('toClubId: $toClubId, ')
          ..write('fee: $fee, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $ShortlistTable extends Shortlist
    with TableInfo<$ShortlistTable, ShortlistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShortlistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedDateMeta = const VerificationMeta(
    'addedDate',
  );
  @override
  late final GeneratedColumn<DateTime> addedDate = GeneratedColumn<DateTime>(
    'added_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playerId, addedDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shortlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShortlistRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    }
    if (data.containsKey('added_date')) {
      context.handle(
        _addedDateMeta,
        addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_addedDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId};
  @override
  ShortlistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShortlistRow(
      playerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}player_id'],
          )!,
      addedDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}added_date'],
          )!,
    );
  }

  @override
  $ShortlistTable createAlias(String alias) {
    return $ShortlistTable(attachedDatabase, alias);
  }
}

class ShortlistRow extends DataClass implements Insertable<ShortlistRow> {
  final int playerId;
  final DateTime addedDate;
  const ShortlistRow({required this.playerId, required this.addedDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<int>(playerId);
    map['added_date'] = Variable<DateTime>(addedDate);
    return map;
  }

  ShortlistCompanion toCompanion(bool nullToAbsent) {
    return ShortlistCompanion(
      playerId: Value(playerId),
      addedDate: Value(addedDate),
    );
  }

  factory ShortlistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShortlistRow(
      playerId: serializer.fromJson<int>(json['playerId']),
      addedDate: serializer.fromJson<DateTime>(json['addedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<int>(playerId),
      'addedDate': serializer.toJson<DateTime>(addedDate),
    };
  }

  ShortlistRow copyWith({int? playerId, DateTime? addedDate}) => ShortlistRow(
    playerId: playerId ?? this.playerId,
    addedDate: addedDate ?? this.addedDate,
  );
  ShortlistRow copyWithCompanion(ShortlistCompanion data) {
    return ShortlistRow(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShortlistRow(')
          ..write('playerId: $playerId, ')
          ..write('addedDate: $addedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, addedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShortlistRow &&
          other.playerId == this.playerId &&
          other.addedDate == this.addedDate);
}

class ShortlistCompanion extends UpdateCompanion<ShortlistRow> {
  final Value<int> playerId;
  final Value<DateTime> addedDate;
  const ShortlistCompanion({
    this.playerId = const Value.absent(),
    this.addedDate = const Value.absent(),
  });
  ShortlistCompanion.insert({
    this.playerId = const Value.absent(),
    required DateTime addedDate,
  }) : addedDate = Value(addedDate);
  static Insertable<ShortlistRow> custom({
    Expression<int>? playerId,
    Expression<DateTime>? addedDate,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (addedDate != null) 'added_date': addedDate,
    });
  }

  ShortlistCompanion copyWith({
    Value<int>? playerId,
    Value<DateTime>? addedDate,
  }) {
    return ShortlistCompanion(
      playerId: playerId ?? this.playerId,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShortlistCompanion(')
          ..write('playerId: $playerId, ')
          ..write('addedDate: $addedDate')
          ..write(')'))
        .toString();
  }
}

class $ClubAiProfilesTable extends ClubAiProfiles
    with TableInfo<$ClubAiProfilesTable, ClubAiProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClubAiProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clubIdMeta = const VerificationMeta('clubId');
  @override
  late final GeneratedColumn<String> clubId = GeneratedColumn<String>(
    'club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personalityMeta = const VerificationMeta(
    'personality',
  );
  @override
  late final GeneratedColumn<String> personality = GeneratedColumn<String>(
    'personality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ambitionMeta = const VerificationMeta(
    'ambition',
  );
  @override
  late final GeneratedColumn<int> ambition = GeneratedColumn<int>(
    'ambition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riskToleranceMeta = const VerificationMeta(
    'riskTolerance',
  );
  @override
  late final GeneratedColumn<int> riskTolerance = GeneratedColumn<int>(
    'risk_tolerance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _negotiationSkillMeta = const VerificationMeta(
    'negotiationSkill',
  );
  @override
  late final GeneratedColumn<int> negotiationSkill = GeneratedColumn<int>(
    'negotiation_skill',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingWillingnessMeta =
      const VerificationMeta('sellingWillingness');
  @override
  late final GeneratedColumn<int> sellingWillingness = GeneratedColumn<int>(
    'selling_willingness',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _youthFocusMeta = const VerificationMeta(
    'youthFocus',
  );
  @override
  late final GeneratedColumn<int> youthFocus = GeneratedColumn<int>(
    'youth_focus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clubId,
    personality,
    ambition,
    riskTolerance,
    negotiationSkill,
    sellingWillingness,
    youthFocus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'club_ai_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClubAiProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('club_id')) {
      context.handle(
        _clubIdMeta,
        clubId.isAcceptableOrUnknown(data['club_id']!, _clubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clubIdMeta);
    }
    if (data.containsKey('personality')) {
      context.handle(
        _personalityMeta,
        personality.isAcceptableOrUnknown(
          data['personality']!,
          _personalityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personalityMeta);
    }
    if (data.containsKey('ambition')) {
      context.handle(
        _ambitionMeta,
        ambition.isAcceptableOrUnknown(data['ambition']!, _ambitionMeta),
      );
    } else if (isInserting) {
      context.missing(_ambitionMeta);
    }
    if (data.containsKey('risk_tolerance')) {
      context.handle(
        _riskToleranceMeta,
        riskTolerance.isAcceptableOrUnknown(
          data['risk_tolerance']!,
          _riskToleranceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_riskToleranceMeta);
    }
    if (data.containsKey('negotiation_skill')) {
      context.handle(
        _negotiationSkillMeta,
        negotiationSkill.isAcceptableOrUnknown(
          data['negotiation_skill']!,
          _negotiationSkillMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_negotiationSkillMeta);
    }
    if (data.containsKey('selling_willingness')) {
      context.handle(
        _sellingWillingnessMeta,
        sellingWillingness.isAcceptableOrUnknown(
          data['selling_willingness']!,
          _sellingWillingnessMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingWillingnessMeta);
    }
    if (data.containsKey('youth_focus')) {
      context.handle(
        _youthFocusMeta,
        youthFocus.isAcceptableOrUnknown(data['youth_focus']!, _youthFocusMeta),
      );
    } else if (isInserting) {
      context.missing(_youthFocusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clubId};
  @override
  ClubAiProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClubAiProfileRow(
      clubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}club_id'],
          )!,
      personality:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}personality'],
          )!,
      ambition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}ambition'],
          )!,
      riskTolerance:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}risk_tolerance'],
          )!,
      negotiationSkill:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}negotiation_skill'],
          )!,
      sellingWillingness:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}selling_willingness'],
          )!,
      youthFocus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}youth_focus'],
          )!,
    );
  }

  @override
  $ClubAiProfilesTable createAlias(String alias) {
    return $ClubAiProfilesTable(attachedDatabase, alias);
  }
}

class ClubAiProfileRow extends DataClass
    implements Insertable<ClubAiProfileRow> {
  final String clubId;
  final String personality;
  final int ambition;
  final int riskTolerance;
  final int negotiationSkill;
  final int sellingWillingness;
  final int youthFocus;
  const ClubAiProfileRow({
    required this.clubId,
    required this.personality,
    required this.ambition,
    required this.riskTolerance,
    required this.negotiationSkill,
    required this.sellingWillingness,
    required this.youthFocus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['club_id'] = Variable<String>(clubId);
    map['personality'] = Variable<String>(personality);
    map['ambition'] = Variable<int>(ambition);
    map['risk_tolerance'] = Variable<int>(riskTolerance);
    map['negotiation_skill'] = Variable<int>(negotiationSkill);
    map['selling_willingness'] = Variable<int>(sellingWillingness);
    map['youth_focus'] = Variable<int>(youthFocus);
    return map;
  }

  ClubAiProfilesCompanion toCompanion(bool nullToAbsent) {
    return ClubAiProfilesCompanion(
      clubId: Value(clubId),
      personality: Value(personality),
      ambition: Value(ambition),
      riskTolerance: Value(riskTolerance),
      negotiationSkill: Value(negotiationSkill),
      sellingWillingness: Value(sellingWillingness),
      youthFocus: Value(youthFocus),
    );
  }

  factory ClubAiProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClubAiProfileRow(
      clubId: serializer.fromJson<String>(json['clubId']),
      personality: serializer.fromJson<String>(json['personality']),
      ambition: serializer.fromJson<int>(json['ambition']),
      riskTolerance: serializer.fromJson<int>(json['riskTolerance']),
      negotiationSkill: serializer.fromJson<int>(json['negotiationSkill']),
      sellingWillingness: serializer.fromJson<int>(json['sellingWillingness']),
      youthFocus: serializer.fromJson<int>(json['youthFocus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clubId': serializer.toJson<String>(clubId),
      'personality': serializer.toJson<String>(personality),
      'ambition': serializer.toJson<int>(ambition),
      'riskTolerance': serializer.toJson<int>(riskTolerance),
      'negotiationSkill': serializer.toJson<int>(negotiationSkill),
      'sellingWillingness': serializer.toJson<int>(sellingWillingness),
      'youthFocus': serializer.toJson<int>(youthFocus),
    };
  }

  ClubAiProfileRow copyWith({
    String? clubId,
    String? personality,
    int? ambition,
    int? riskTolerance,
    int? negotiationSkill,
    int? sellingWillingness,
    int? youthFocus,
  }) => ClubAiProfileRow(
    clubId: clubId ?? this.clubId,
    personality: personality ?? this.personality,
    ambition: ambition ?? this.ambition,
    riskTolerance: riskTolerance ?? this.riskTolerance,
    negotiationSkill: negotiationSkill ?? this.negotiationSkill,
    sellingWillingness: sellingWillingness ?? this.sellingWillingness,
    youthFocus: youthFocus ?? this.youthFocus,
  );
  ClubAiProfileRow copyWithCompanion(ClubAiProfilesCompanion data) {
    return ClubAiProfileRow(
      clubId: data.clubId.present ? data.clubId.value : this.clubId,
      personality:
          data.personality.present ? data.personality.value : this.personality,
      ambition: data.ambition.present ? data.ambition.value : this.ambition,
      riskTolerance:
          data.riskTolerance.present
              ? data.riskTolerance.value
              : this.riskTolerance,
      negotiationSkill:
          data.negotiationSkill.present
              ? data.negotiationSkill.value
              : this.negotiationSkill,
      sellingWillingness:
          data.sellingWillingness.present
              ? data.sellingWillingness.value
              : this.sellingWillingness,
      youthFocus:
          data.youthFocus.present ? data.youthFocus.value : this.youthFocus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClubAiProfileRow(')
          ..write('clubId: $clubId, ')
          ..write('personality: $personality, ')
          ..write('ambition: $ambition, ')
          ..write('riskTolerance: $riskTolerance, ')
          ..write('negotiationSkill: $negotiationSkill, ')
          ..write('sellingWillingness: $sellingWillingness, ')
          ..write('youthFocus: $youthFocus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clubId,
    personality,
    ambition,
    riskTolerance,
    negotiationSkill,
    sellingWillingness,
    youthFocus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClubAiProfileRow &&
          other.clubId == this.clubId &&
          other.personality == this.personality &&
          other.ambition == this.ambition &&
          other.riskTolerance == this.riskTolerance &&
          other.negotiationSkill == this.negotiationSkill &&
          other.sellingWillingness == this.sellingWillingness &&
          other.youthFocus == this.youthFocus);
}

class ClubAiProfilesCompanion extends UpdateCompanion<ClubAiProfileRow> {
  final Value<String> clubId;
  final Value<String> personality;
  final Value<int> ambition;
  final Value<int> riskTolerance;
  final Value<int> negotiationSkill;
  final Value<int> sellingWillingness;
  final Value<int> youthFocus;
  final Value<int> rowid;
  const ClubAiProfilesCompanion({
    this.clubId = const Value.absent(),
    this.personality = const Value.absent(),
    this.ambition = const Value.absent(),
    this.riskTolerance = const Value.absent(),
    this.negotiationSkill = const Value.absent(),
    this.sellingWillingness = const Value.absent(),
    this.youthFocus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClubAiProfilesCompanion.insert({
    required String clubId,
    required String personality,
    required int ambition,
    required int riskTolerance,
    required int negotiationSkill,
    required int sellingWillingness,
    required int youthFocus,
    this.rowid = const Value.absent(),
  }) : clubId = Value(clubId),
       personality = Value(personality),
       ambition = Value(ambition),
       riskTolerance = Value(riskTolerance),
       negotiationSkill = Value(negotiationSkill),
       sellingWillingness = Value(sellingWillingness),
       youthFocus = Value(youthFocus);
  static Insertable<ClubAiProfileRow> custom({
    Expression<String>? clubId,
    Expression<String>? personality,
    Expression<int>? ambition,
    Expression<int>? riskTolerance,
    Expression<int>? negotiationSkill,
    Expression<int>? sellingWillingness,
    Expression<int>? youthFocus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clubId != null) 'club_id': clubId,
      if (personality != null) 'personality': personality,
      if (ambition != null) 'ambition': ambition,
      if (riskTolerance != null) 'risk_tolerance': riskTolerance,
      if (negotiationSkill != null) 'negotiation_skill': negotiationSkill,
      if (sellingWillingness != null) 'selling_willingness': sellingWillingness,
      if (youthFocus != null) 'youth_focus': youthFocus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClubAiProfilesCompanion copyWith({
    Value<String>? clubId,
    Value<String>? personality,
    Value<int>? ambition,
    Value<int>? riskTolerance,
    Value<int>? negotiationSkill,
    Value<int>? sellingWillingness,
    Value<int>? youthFocus,
    Value<int>? rowid,
  }) {
    return ClubAiProfilesCompanion(
      clubId: clubId ?? this.clubId,
      personality: personality ?? this.personality,
      ambition: ambition ?? this.ambition,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      negotiationSkill: negotiationSkill ?? this.negotiationSkill,
      sellingWillingness: sellingWillingness ?? this.sellingWillingness,
      youthFocus: youthFocus ?? this.youthFocus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clubId.present) {
      map['club_id'] = Variable<String>(clubId.value);
    }
    if (personality.present) {
      map['personality'] = Variable<String>(personality.value);
    }
    if (ambition.present) {
      map['ambition'] = Variable<int>(ambition.value);
    }
    if (riskTolerance.present) {
      map['risk_tolerance'] = Variable<int>(riskTolerance.value);
    }
    if (negotiationSkill.present) {
      map['negotiation_skill'] = Variable<int>(negotiationSkill.value);
    }
    if (sellingWillingness.present) {
      map['selling_willingness'] = Variable<int>(sellingWillingness.value);
    }
    if (youthFocus.present) {
      map['youth_focus'] = Variable<int>(youthFocus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClubAiProfilesCompanion(')
          ..write('clubId: $clubId, ')
          ..write('personality: $personality, ')
          ..write('ambition: $ambition, ')
          ..write('riskTolerance: $riskTolerance, ')
          ..write('negotiationSkill: $negotiationSkill, ')
          ..write('sellingWillingness: $sellingWillingness, ')
          ..write('youthFocus: $youthFocus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransferInterestsTable extends TransferInterests
    with TableInfo<$TransferInterestsTable, TransferInterestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransferInterestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clubIdMeta = const VerificationMeta('clubId');
  @override
  late final GeneratedColumn<String> clubId = GeneratedColumn<String>(
    'club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedDateMeta = const VerificationMeta(
    'updatedDate',
  );
  @override
  late final GeneratedColumn<DateTime> updatedDate = GeneratedColumn<DateTime>(
    'updated_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clubId,
    playerId,
    score,
    level,
    updatedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfer_interests';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransferInterestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('club_id')) {
      context.handle(
        _clubIdMeta,
        clubId.isAcceptableOrUnknown(data['club_id']!, _clubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clubIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('updated_date')) {
      context.handle(
        _updatedDateMeta,
        updatedDate.isAcceptableOrUnknown(
          data['updated_date']!,
          _updatedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clubId, playerId};
  @override
  TransferInterestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransferInterestRow(
      clubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}club_id'],
          )!,
      playerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}player_id'],
          )!,
      score:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}score'],
          )!,
      level:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}level'],
          )!,
      updatedDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_date'],
          )!,
    );
  }

  @override
  $TransferInterestsTable createAlias(String alias) {
    return $TransferInterestsTable(attachedDatabase, alias);
  }
}

class TransferInterestRow extends DataClass
    implements Insertable<TransferInterestRow> {
  final String clubId;
  final int playerId;
  final int score;
  final String level;
  final DateTime updatedDate;
  const TransferInterestRow({
    required this.clubId,
    required this.playerId,
    required this.score,
    required this.level,
    required this.updatedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['club_id'] = Variable<String>(clubId);
    map['player_id'] = Variable<int>(playerId);
    map['score'] = Variable<int>(score);
    map['level'] = Variable<String>(level);
    map['updated_date'] = Variable<DateTime>(updatedDate);
    return map;
  }

  TransferInterestsCompanion toCompanion(bool nullToAbsent) {
    return TransferInterestsCompanion(
      clubId: Value(clubId),
      playerId: Value(playerId),
      score: Value(score),
      level: Value(level),
      updatedDate: Value(updatedDate),
    );
  }

  factory TransferInterestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransferInterestRow(
      clubId: serializer.fromJson<String>(json['clubId']),
      playerId: serializer.fromJson<int>(json['playerId']),
      score: serializer.fromJson<int>(json['score']),
      level: serializer.fromJson<String>(json['level']),
      updatedDate: serializer.fromJson<DateTime>(json['updatedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clubId': serializer.toJson<String>(clubId),
      'playerId': serializer.toJson<int>(playerId),
      'score': serializer.toJson<int>(score),
      'level': serializer.toJson<String>(level),
      'updatedDate': serializer.toJson<DateTime>(updatedDate),
    };
  }

  TransferInterestRow copyWith({
    String? clubId,
    int? playerId,
    int? score,
    String? level,
    DateTime? updatedDate,
  }) => TransferInterestRow(
    clubId: clubId ?? this.clubId,
    playerId: playerId ?? this.playerId,
    score: score ?? this.score,
    level: level ?? this.level,
    updatedDate: updatedDate ?? this.updatedDate,
  );
  TransferInterestRow copyWithCompanion(TransferInterestsCompanion data) {
    return TransferInterestRow(
      clubId: data.clubId.present ? data.clubId.value : this.clubId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      score: data.score.present ? data.score.value : this.score,
      level: data.level.present ? data.level.value : this.level,
      updatedDate:
          data.updatedDate.present ? data.updatedDate.value : this.updatedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransferInterestRow(')
          ..write('clubId: $clubId, ')
          ..write('playerId: $playerId, ')
          ..write('score: $score, ')
          ..write('level: $level, ')
          ..write('updatedDate: $updatedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clubId, playerId, score, level, updatedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransferInterestRow &&
          other.clubId == this.clubId &&
          other.playerId == this.playerId &&
          other.score == this.score &&
          other.level == this.level &&
          other.updatedDate == this.updatedDate);
}

class TransferInterestsCompanion extends UpdateCompanion<TransferInterestRow> {
  final Value<String> clubId;
  final Value<int> playerId;
  final Value<int> score;
  final Value<String> level;
  final Value<DateTime> updatedDate;
  final Value<int> rowid;
  const TransferInterestsCompanion({
    this.clubId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.score = const Value.absent(),
    this.level = const Value.absent(),
    this.updatedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransferInterestsCompanion.insert({
    required String clubId,
    required int playerId,
    required int score,
    required String level,
    required DateTime updatedDate,
    this.rowid = const Value.absent(),
  }) : clubId = Value(clubId),
       playerId = Value(playerId),
       score = Value(score),
       level = Value(level),
       updatedDate = Value(updatedDate);
  static Insertable<TransferInterestRow> custom({
    Expression<String>? clubId,
    Expression<int>? playerId,
    Expression<int>? score,
    Expression<String>? level,
    Expression<DateTime>? updatedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clubId != null) 'club_id': clubId,
      if (playerId != null) 'player_id': playerId,
      if (score != null) 'score': score,
      if (level != null) 'level': level,
      if (updatedDate != null) 'updated_date': updatedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransferInterestsCompanion copyWith({
    Value<String>? clubId,
    Value<int>? playerId,
    Value<int>? score,
    Value<String>? level,
    Value<DateTime>? updatedDate,
    Value<int>? rowid,
  }) {
    return TransferInterestsCompanion(
      clubId: clubId ?? this.clubId,
      playerId: playerId ?? this.playerId,
      score: score ?? this.score,
      level: level ?? this.level,
      updatedDate: updatedDate ?? this.updatedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clubId.present) {
      map['club_id'] = Variable<String>(clubId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (updatedDate.present) {
      map['updated_date'] = Variable<DateTime>(updatedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferInterestsCompanion(')
          ..write('clubId: $clubId, ')
          ..write('playerId: $playerId, ')
          ..write('score: $score, ')
          ..write('level: $level, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransferNewsTable extends TransferNews
    with TableInfo<$TransferNewsTable, TransferNewsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransferNewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clubIdsMeta = const VerificationMeta(
    'clubIds',
  );
  @override
  late final GeneratedColumn<String> clubIds = GeneratedColumn<String>(
    'club_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, kind, body, clubIds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfer_news';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransferNewsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('club_ids')) {
      context.handle(
        _clubIdsMeta,
        clubIds.isAcceptableOrUnknown(data['club_ids']!, _clubIdsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransferNewsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransferNewsRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      kind:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}kind'],
          )!,
      body:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}body'],
          )!,
      clubIds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}club_ids'],
          )!,
    );
  }

  @override
  $TransferNewsTable createAlias(String alias) {
    return $TransferNewsTable(attachedDatabase, alias);
  }
}

class TransferNewsRow extends DataClass implements Insertable<TransferNewsRow> {
  final int id;
  final DateTime date;
  final String kind;
  final String body;
  final String clubIds;
  const TransferNewsRow({
    required this.id,
    required this.date,
    required this.kind,
    required this.body,
    required this.clubIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['kind'] = Variable<String>(kind);
    map['body'] = Variable<String>(body);
    map['club_ids'] = Variable<String>(clubIds);
    return map;
  }

  TransferNewsCompanion toCompanion(bool nullToAbsent) {
    return TransferNewsCompanion(
      id: Value(id),
      date: Value(date),
      kind: Value(kind),
      body: Value(body),
      clubIds: Value(clubIds),
    );
  }

  factory TransferNewsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransferNewsRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      kind: serializer.fromJson<String>(json['kind']),
      body: serializer.fromJson<String>(json['body']),
      clubIds: serializer.fromJson<String>(json['clubIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'kind': serializer.toJson<String>(kind),
      'body': serializer.toJson<String>(body),
      'clubIds': serializer.toJson<String>(clubIds),
    };
  }

  TransferNewsRow copyWith({
    int? id,
    DateTime? date,
    String? kind,
    String? body,
    String? clubIds,
  }) => TransferNewsRow(
    id: id ?? this.id,
    date: date ?? this.date,
    kind: kind ?? this.kind,
    body: body ?? this.body,
    clubIds: clubIds ?? this.clubIds,
  );
  TransferNewsRow copyWithCompanion(TransferNewsCompanion data) {
    return TransferNewsRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      clubIds: data.clubIds.present ? data.clubIds.value : this.clubIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransferNewsRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('clubIds: $clubIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, kind, body, clubIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransferNewsRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.clubIds == this.clubIds);
}

class TransferNewsCompanion extends UpdateCompanion<TransferNewsRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> kind;
  final Value<String> body;
  final Value<String> clubIds;
  const TransferNewsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.clubIds = const Value.absent(),
  });
  TransferNewsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String kind,
    required String body,
    this.clubIds = const Value.absent(),
  }) : date = Value(date),
       kind = Value(kind),
       body = Value(body);
  static Insertable<TransferNewsRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? kind,
    Expression<String>? body,
    Expression<String>? clubIds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (body != null) 'body': body,
      if (clubIds != null) 'club_ids': clubIds,
    });
  }

  TransferNewsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? kind,
    Value<String>? body,
    Value<String>? clubIds,
  }) {
    return TransferNewsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      clubIds: clubIds ?? this.clubIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (clubIds.present) {
      map['club_ids'] = Variable<String>(clubIds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferNewsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('clubIds: $clubIds')
          ..write(')'))
        .toString();
  }
}

class $MarketMemoryTable extends MarketMemory
    with TableInfo<$MarketMemoryTable, MarketMemoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketMemoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'market_memory';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketMemoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MarketMemoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketMemoryRow(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $MarketMemoryTable createAlias(String alias) {
    return $MarketMemoryTable(attachedDatabase, alias);
  }
}

class MarketMemoryRow extends DataClass implements Insertable<MarketMemoryRow> {
  final String key;
  final int value;
  const MarketMemoryRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<int>(value);
    return map;
  }

  MarketMemoryCompanion toCompanion(bool nullToAbsent) {
    return MarketMemoryCompanion(key: Value(key), value: Value(value));
  }

  factory MarketMemoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketMemoryRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<int>(value),
    };
  }

  MarketMemoryRow copyWith({String? key, int? value}) =>
      MarketMemoryRow(key: key ?? this.key, value: value ?? this.value);
  MarketMemoryRow copyWithCompanion(MarketMemoryCompanion data) {
    return MarketMemoryRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketMemoryRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketMemoryRow &&
          other.key == this.key &&
          other.value == this.value);
}

class MarketMemoryCompanion extends UpdateCompanion<MarketMemoryRow> {
  final Value<String> key;
  final Value<int> value;
  final Value<int> rowid;
  const MarketMemoryCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketMemoryCompanion.insert({
    required String key,
    required int value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MarketMemoryRow> custom({
    Expression<String>? key,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketMemoryCompanion copyWith({
    Value<String>? key,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return MarketMemoryCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketMemoryCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeasonsTable extends Seasons with TableInfo<$SeasonsTable, SeasonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeasonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _startYearMeta = const VerificationMeta(
    'startYear',
  );
  @override
  late final GeneratedColumn<int> startYear = GeneratedColumn<int>(
    'start_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    startYear,
    label,
    startDate,
    endDate,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seasons';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeasonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('start_year')) {
      context.handle(
        _startYearMeta,
        startYear.isAcceptableOrUnknown(data['start_year']!, _startYearMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {startYear};
  @override
  SeasonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeasonRow(
      startYear:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}start_year'],
          )!,
      label:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}label'],
          )!,
      startDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}start_date'],
          )!,
      endDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}end_date'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
    );
  }

  @override
  $SeasonsTable createAlias(String alias) {
    return $SeasonsTable(attachedDatabase, alias);
  }
}

class SeasonRow extends DataClass implements Insertable<SeasonRow> {
  final int startYear;
  final String label;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  const SeasonRow({
    required this.startYear,
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['start_year'] = Variable<int>(startYear);
    map['label'] = Variable<String>(label);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['status'] = Variable<String>(status);
    return map;
  }

  SeasonsCompanion toCompanion(bool nullToAbsent) {
    return SeasonsCompanion(
      startYear: Value(startYear),
      label: Value(label),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
    );
  }

  factory SeasonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeasonRow(
      startYear: serializer.fromJson<int>(json['startYear']),
      label: serializer.fromJson<String>(json['label']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'startYear': serializer.toJson<int>(startYear),
      'label': serializer.toJson<String>(label),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(status),
    };
  }

  SeasonRow copyWith({
    int? startYear,
    String? label,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) => SeasonRow(
    startYear: startYear ?? this.startYear,
    label: label ?? this.label,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    status: status ?? this.status,
  );
  SeasonRow copyWithCompanion(SeasonsCompanion data) {
    return SeasonRow(
      startYear: data.startYear.present ? data.startYear.value : this.startYear,
      label: data.label.present ? data.label.value : this.label,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeasonRow(')
          ..write('startYear: $startYear, ')
          ..write('label: $label, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(startYear, label, startDate, endDate, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeasonRow &&
          other.startYear == this.startYear &&
          other.label == this.label &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status);
}

class SeasonsCompanion extends UpdateCompanion<SeasonRow> {
  final Value<int> startYear;
  final Value<String> label;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> status;
  const SeasonsCompanion({
    this.startYear = const Value.absent(),
    this.label = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
  });
  SeasonsCompanion.insert({
    this.startYear = const Value.absent(),
    required String label,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
  }) : label = Value(label),
       startDate = Value(startDate),
       endDate = Value(endDate),
       status = Value(status);
  static Insertable<SeasonRow> custom({
    Expression<int>? startYear,
    Expression<String>? label,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (startYear != null) 'start_year': startYear,
      if (label != null) 'label': label,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
    });
  }

  SeasonsCompanion copyWith({
    Value<int>? startYear,
    Value<String>? label,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String>? status,
  }) {
    return SeasonsCompanion(
      startYear: startYear ?? this.startYear,
      label: label ?? this.label,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (startYear.present) {
      map['start_year'] = Variable<int>(startYear.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeasonsCompanion(')
          ..write('startYear: $startYear, ')
          ..write('label: $label, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $SeasonArchiveTable extends SeasonArchive
    with TableInfo<$SeasonArchiveTable, SeasonArchiveRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeasonArchiveTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seasonStartYearMeta = const VerificationMeta(
    'seasonStartYear',
  );
  @override
  late final GeneratedColumn<int> seasonStartYear = GeneratedColumn<int>(
    'season_start_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leagueIdMeta = const VerificationMeta(
    'leagueId',
  );
  @override
  late final GeneratedColumn<String> leagueId = GeneratedColumn<String>(
    'league_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clubIdMeta = const VerificationMeta('clubId');
  @override
  late final GeneratedColumn<String> clubId = GeneratedColumn<String>(
    'club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedMeta = const VerificationMeta('played');
  @override
  late final GeneratedColumn<int> played = GeneratedColumn<int>(
    'played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wonMeta = const VerificationMeta('won');
  @override
  late final GeneratedColumn<int> won = GeneratedColumn<int>(
    'won',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drawnMeta = const VerificationMeta('drawn');
  @override
  late final GeneratedColumn<int> drawn = GeneratedColumn<int>(
    'drawn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lostMeta = const VerificationMeta('lost');
  @override
  late final GeneratedColumn<int> lost = GeneratedColumn<int>(
    'lost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gfMeta = const VerificationMeta('gf');
  @override
  late final GeneratedColumn<int> gf = GeneratedColumn<int>(
    'gf',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gaMeta = const VerificationMeta('ga');
  @override
  late final GeneratedColumn<int> ga = GeneratedColumn<int>(
    'ga',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seasonStartYear,
    leagueId,
    clubId,
    position,
    played,
    won,
    drawn,
    lost,
    gf,
    ga,
    points,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'season_archive';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeasonArchiveRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('season_start_year')) {
      context.handle(
        _seasonStartYearMeta,
        seasonStartYear.isAcceptableOrUnknown(
          data['season_start_year']!,
          _seasonStartYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seasonStartYearMeta);
    }
    if (data.containsKey('league_id')) {
      context.handle(
        _leagueIdMeta,
        leagueId.isAcceptableOrUnknown(data['league_id']!, _leagueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leagueIdMeta);
    }
    if (data.containsKey('club_id')) {
      context.handle(
        _clubIdMeta,
        clubId.isAcceptableOrUnknown(data['club_id']!, _clubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clubIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('played')) {
      context.handle(
        _playedMeta,
        played.isAcceptableOrUnknown(data['played']!, _playedMeta),
      );
    } else if (isInserting) {
      context.missing(_playedMeta);
    }
    if (data.containsKey('won')) {
      context.handle(
        _wonMeta,
        won.isAcceptableOrUnknown(data['won']!, _wonMeta),
      );
    } else if (isInserting) {
      context.missing(_wonMeta);
    }
    if (data.containsKey('drawn')) {
      context.handle(
        _drawnMeta,
        drawn.isAcceptableOrUnknown(data['drawn']!, _drawnMeta),
      );
    } else if (isInserting) {
      context.missing(_drawnMeta);
    }
    if (data.containsKey('lost')) {
      context.handle(
        _lostMeta,
        lost.isAcceptableOrUnknown(data['lost']!, _lostMeta),
      );
    } else if (isInserting) {
      context.missing(_lostMeta);
    }
    if (data.containsKey('gf')) {
      context.handle(_gfMeta, gf.isAcceptableOrUnknown(data['gf']!, _gfMeta));
    } else if (isInserting) {
      context.missing(_gfMeta);
    }
    if (data.containsKey('ga')) {
      context.handle(_gaMeta, ga.isAcceptableOrUnknown(data['ga']!, _gaMeta));
    } else if (isInserting) {
      context.missing(_gaMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seasonStartYear, clubId};
  @override
  SeasonArchiveRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeasonArchiveRow(
      seasonStartYear:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}season_start_year'],
          )!,
      leagueId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}league_id'],
          )!,
      clubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}club_id'],
          )!,
      position:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}position'],
          )!,
      played:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}played'],
          )!,
      won:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}won'],
          )!,
      drawn:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}drawn'],
          )!,
      lost:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lost'],
          )!,
      gf:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}gf'],
          )!,
      ga:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}ga'],
          )!,
      points:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}points'],
          )!,
    );
  }

  @override
  $SeasonArchiveTable createAlias(String alias) {
    return $SeasonArchiveTable(attachedDatabase, alias);
  }
}

class SeasonArchiveRow extends DataClass
    implements Insertable<SeasonArchiveRow> {
  final int seasonStartYear;
  final String leagueId;
  final String clubId;
  final int position;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int gf;
  final int ga;
  final int points;
  const SeasonArchiveRow({
    required this.seasonStartYear,
    required this.leagueId,
    required this.clubId,
    required this.position,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.gf,
    required this.ga,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['season_start_year'] = Variable<int>(seasonStartYear);
    map['league_id'] = Variable<String>(leagueId);
    map['club_id'] = Variable<String>(clubId);
    map['position'] = Variable<int>(position);
    map['played'] = Variable<int>(played);
    map['won'] = Variable<int>(won);
    map['drawn'] = Variable<int>(drawn);
    map['lost'] = Variable<int>(lost);
    map['gf'] = Variable<int>(gf);
    map['ga'] = Variable<int>(ga);
    map['points'] = Variable<int>(points);
    return map;
  }

  SeasonArchiveCompanion toCompanion(bool nullToAbsent) {
    return SeasonArchiveCompanion(
      seasonStartYear: Value(seasonStartYear),
      leagueId: Value(leagueId),
      clubId: Value(clubId),
      position: Value(position),
      played: Value(played),
      won: Value(won),
      drawn: Value(drawn),
      lost: Value(lost),
      gf: Value(gf),
      ga: Value(ga),
      points: Value(points),
    );
  }

  factory SeasonArchiveRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeasonArchiveRow(
      seasonStartYear: serializer.fromJson<int>(json['seasonStartYear']),
      leagueId: serializer.fromJson<String>(json['leagueId']),
      clubId: serializer.fromJson<String>(json['clubId']),
      position: serializer.fromJson<int>(json['position']),
      played: serializer.fromJson<int>(json['played']),
      won: serializer.fromJson<int>(json['won']),
      drawn: serializer.fromJson<int>(json['drawn']),
      lost: serializer.fromJson<int>(json['lost']),
      gf: serializer.fromJson<int>(json['gf']),
      ga: serializer.fromJson<int>(json['ga']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seasonStartYear': serializer.toJson<int>(seasonStartYear),
      'leagueId': serializer.toJson<String>(leagueId),
      'clubId': serializer.toJson<String>(clubId),
      'position': serializer.toJson<int>(position),
      'played': serializer.toJson<int>(played),
      'won': serializer.toJson<int>(won),
      'drawn': serializer.toJson<int>(drawn),
      'lost': serializer.toJson<int>(lost),
      'gf': serializer.toJson<int>(gf),
      'ga': serializer.toJson<int>(ga),
      'points': serializer.toJson<int>(points),
    };
  }

  SeasonArchiveRow copyWith({
    int? seasonStartYear,
    String? leagueId,
    String? clubId,
    int? position,
    int? played,
    int? won,
    int? drawn,
    int? lost,
    int? gf,
    int? ga,
    int? points,
  }) => SeasonArchiveRow(
    seasonStartYear: seasonStartYear ?? this.seasonStartYear,
    leagueId: leagueId ?? this.leagueId,
    clubId: clubId ?? this.clubId,
    position: position ?? this.position,
    played: played ?? this.played,
    won: won ?? this.won,
    drawn: drawn ?? this.drawn,
    lost: lost ?? this.lost,
    gf: gf ?? this.gf,
    ga: ga ?? this.ga,
    points: points ?? this.points,
  );
  SeasonArchiveRow copyWithCompanion(SeasonArchiveCompanion data) {
    return SeasonArchiveRow(
      seasonStartYear:
          data.seasonStartYear.present
              ? data.seasonStartYear.value
              : this.seasonStartYear,
      leagueId: data.leagueId.present ? data.leagueId.value : this.leagueId,
      clubId: data.clubId.present ? data.clubId.value : this.clubId,
      position: data.position.present ? data.position.value : this.position,
      played: data.played.present ? data.played.value : this.played,
      won: data.won.present ? data.won.value : this.won,
      drawn: data.drawn.present ? data.drawn.value : this.drawn,
      lost: data.lost.present ? data.lost.value : this.lost,
      gf: data.gf.present ? data.gf.value : this.gf,
      ga: data.ga.present ? data.ga.value : this.ga,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeasonArchiveRow(')
          ..write('seasonStartYear: $seasonStartYear, ')
          ..write('leagueId: $leagueId, ')
          ..write('clubId: $clubId, ')
          ..write('position: $position, ')
          ..write('played: $played, ')
          ..write('won: $won, ')
          ..write('drawn: $drawn, ')
          ..write('lost: $lost, ')
          ..write('gf: $gf, ')
          ..write('ga: $ga, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seasonStartYear,
    leagueId,
    clubId,
    position,
    played,
    won,
    drawn,
    lost,
    gf,
    ga,
    points,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeasonArchiveRow &&
          other.seasonStartYear == this.seasonStartYear &&
          other.leagueId == this.leagueId &&
          other.clubId == this.clubId &&
          other.position == this.position &&
          other.played == this.played &&
          other.won == this.won &&
          other.drawn == this.drawn &&
          other.lost == this.lost &&
          other.gf == this.gf &&
          other.ga == this.ga &&
          other.points == this.points);
}

class SeasonArchiveCompanion extends UpdateCompanion<SeasonArchiveRow> {
  final Value<int> seasonStartYear;
  final Value<String> leagueId;
  final Value<String> clubId;
  final Value<int> position;
  final Value<int> played;
  final Value<int> won;
  final Value<int> drawn;
  final Value<int> lost;
  final Value<int> gf;
  final Value<int> ga;
  final Value<int> points;
  final Value<int> rowid;
  const SeasonArchiveCompanion({
    this.seasonStartYear = const Value.absent(),
    this.leagueId = const Value.absent(),
    this.clubId = const Value.absent(),
    this.position = const Value.absent(),
    this.played = const Value.absent(),
    this.won = const Value.absent(),
    this.drawn = const Value.absent(),
    this.lost = const Value.absent(),
    this.gf = const Value.absent(),
    this.ga = const Value.absent(),
    this.points = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeasonArchiveCompanion.insert({
    required int seasonStartYear,
    required String leagueId,
    required String clubId,
    required int position,
    required int played,
    required int won,
    required int drawn,
    required int lost,
    required int gf,
    required int ga,
    required int points,
    this.rowid = const Value.absent(),
  }) : seasonStartYear = Value(seasonStartYear),
       leagueId = Value(leagueId),
       clubId = Value(clubId),
       position = Value(position),
       played = Value(played),
       won = Value(won),
       drawn = Value(drawn),
       lost = Value(lost),
       gf = Value(gf),
       ga = Value(ga),
       points = Value(points);
  static Insertable<SeasonArchiveRow> custom({
    Expression<int>? seasonStartYear,
    Expression<String>? leagueId,
    Expression<String>? clubId,
    Expression<int>? position,
    Expression<int>? played,
    Expression<int>? won,
    Expression<int>? drawn,
    Expression<int>? lost,
    Expression<int>? gf,
    Expression<int>? ga,
    Expression<int>? points,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seasonStartYear != null) 'season_start_year': seasonStartYear,
      if (leagueId != null) 'league_id': leagueId,
      if (clubId != null) 'club_id': clubId,
      if (position != null) 'position': position,
      if (played != null) 'played': played,
      if (won != null) 'won': won,
      if (drawn != null) 'drawn': drawn,
      if (lost != null) 'lost': lost,
      if (gf != null) 'gf': gf,
      if (ga != null) 'ga': ga,
      if (points != null) 'points': points,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeasonArchiveCompanion copyWith({
    Value<int>? seasonStartYear,
    Value<String>? leagueId,
    Value<String>? clubId,
    Value<int>? position,
    Value<int>? played,
    Value<int>? won,
    Value<int>? drawn,
    Value<int>? lost,
    Value<int>? gf,
    Value<int>? ga,
    Value<int>? points,
    Value<int>? rowid,
  }) {
    return SeasonArchiveCompanion(
      seasonStartYear: seasonStartYear ?? this.seasonStartYear,
      leagueId: leagueId ?? this.leagueId,
      clubId: clubId ?? this.clubId,
      position: position ?? this.position,
      played: played ?? this.played,
      won: won ?? this.won,
      drawn: drawn ?? this.drawn,
      lost: lost ?? this.lost,
      gf: gf ?? this.gf,
      ga: ga ?? this.ga,
      points: points ?? this.points,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seasonStartYear.present) {
      map['season_start_year'] = Variable<int>(seasonStartYear.value);
    }
    if (leagueId.present) {
      map['league_id'] = Variable<String>(leagueId.value);
    }
    if (clubId.present) {
      map['club_id'] = Variable<String>(clubId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (played.present) {
      map['played'] = Variable<int>(played.value);
    }
    if (won.present) {
      map['won'] = Variable<int>(won.value);
    }
    if (drawn.present) {
      map['drawn'] = Variable<int>(drawn.value);
    }
    if (lost.present) {
      map['lost'] = Variable<int>(lost.value);
    }
    if (gf.present) {
      map['gf'] = Variable<int>(gf.value);
    }
    if (ga.present) {
      map['ga'] = Variable<int>(ga.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeasonArchiveCompanion(')
          ..write('seasonStartYear: $seasonStartYear, ')
          ..write('leagueId: $leagueId, ')
          ..write('clubId: $clubId, ')
          ..write('position: $position, ')
          ..write('played: $played, ')
          ..write('won: $won, ')
          ..write('drawn: $drawn, ')
          ..write('lost: $lost, ')
          ..write('gf: $gf, ')
          ..write('ga: $ga, ')
          ..write('points: $points, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HonoursTable extends Honours with TableInfo<$HonoursTable, HonourRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HonoursTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _seasonStartYearMeta = const VerificationMeta(
    'seasonStartYear',
  );
  @override
  late final GeneratedColumn<int> seasonStartYear = GeneratedColumn<int>(
    'season_start_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leagueIdMeta = const VerificationMeta(
    'leagueId',
  );
  @override
  late final GeneratedColumn<String> leagueId = GeneratedColumn<String>(
    'league_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clubIdMeta = const VerificationMeta('clubId');
  @override
  late final GeneratedColumn<String> clubId = GeneratedColumn<String>(
    'club_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seasonStartYear,
    leagueId,
    type,
    clubId,
    playerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'honours';
  @override
  VerificationContext validateIntegrity(
    Insertable<HonourRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('season_start_year')) {
      context.handle(
        _seasonStartYearMeta,
        seasonStartYear.isAcceptableOrUnknown(
          data['season_start_year']!,
          _seasonStartYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seasonStartYearMeta);
    }
    if (data.containsKey('league_id')) {
      context.handle(
        _leagueIdMeta,
        leagueId.isAcceptableOrUnknown(data['league_id']!, _leagueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leagueIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('club_id')) {
      context.handle(
        _clubIdMeta,
        clubId.isAcceptableOrUnknown(data['club_id']!, _clubIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clubIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HonourRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HonourRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      seasonStartYear:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}season_start_year'],
          )!,
      leagueId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}league_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      clubId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}club_id'],
          )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      ),
    );
  }

  @override
  $HonoursTable createAlias(String alias) {
    return $HonoursTable(attachedDatabase, alias);
  }
}

class HonourRow extends DataClass implements Insertable<HonourRow> {
  final int id;
  final int seasonStartYear;
  final String leagueId;
  final String type;
  final String clubId;
  final int? playerId;
  const HonourRow({
    required this.id,
    required this.seasonStartYear,
    required this.leagueId,
    required this.type,
    required this.clubId,
    this.playerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['season_start_year'] = Variable<int>(seasonStartYear);
    map['league_id'] = Variable<String>(leagueId);
    map['type'] = Variable<String>(type);
    map['club_id'] = Variable<String>(clubId);
    if (!nullToAbsent || playerId != null) {
      map['player_id'] = Variable<int>(playerId);
    }
    return map;
  }

  HonoursCompanion toCompanion(bool nullToAbsent) {
    return HonoursCompanion(
      id: Value(id),
      seasonStartYear: Value(seasonStartYear),
      leagueId: Value(leagueId),
      type: Value(type),
      clubId: Value(clubId),
      playerId:
          playerId == null && nullToAbsent
              ? const Value.absent()
              : Value(playerId),
    );
  }

  factory HonourRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HonourRow(
      id: serializer.fromJson<int>(json['id']),
      seasonStartYear: serializer.fromJson<int>(json['seasonStartYear']),
      leagueId: serializer.fromJson<String>(json['leagueId']),
      type: serializer.fromJson<String>(json['type']),
      clubId: serializer.fromJson<String>(json['clubId']),
      playerId: serializer.fromJson<int?>(json['playerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seasonStartYear': serializer.toJson<int>(seasonStartYear),
      'leagueId': serializer.toJson<String>(leagueId),
      'type': serializer.toJson<String>(type),
      'clubId': serializer.toJson<String>(clubId),
      'playerId': serializer.toJson<int?>(playerId),
    };
  }

  HonourRow copyWith({
    int? id,
    int? seasonStartYear,
    String? leagueId,
    String? type,
    String? clubId,
    Value<int?> playerId = const Value.absent(),
  }) => HonourRow(
    id: id ?? this.id,
    seasonStartYear: seasonStartYear ?? this.seasonStartYear,
    leagueId: leagueId ?? this.leagueId,
    type: type ?? this.type,
    clubId: clubId ?? this.clubId,
    playerId: playerId.present ? playerId.value : this.playerId,
  );
  HonourRow copyWithCompanion(HonoursCompanion data) {
    return HonourRow(
      id: data.id.present ? data.id.value : this.id,
      seasonStartYear:
          data.seasonStartYear.present
              ? data.seasonStartYear.value
              : this.seasonStartYear,
      leagueId: data.leagueId.present ? data.leagueId.value : this.leagueId,
      type: data.type.present ? data.type.value : this.type,
      clubId: data.clubId.present ? data.clubId.value : this.clubId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HonourRow(')
          ..write('id: $id, ')
          ..write('seasonStartYear: $seasonStartYear, ')
          ..write('leagueId: $leagueId, ')
          ..write('type: $type, ')
          ..write('clubId: $clubId, ')
          ..write('playerId: $playerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, seasonStartYear, leagueId, type, clubId, playerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HonourRow &&
          other.id == this.id &&
          other.seasonStartYear == this.seasonStartYear &&
          other.leagueId == this.leagueId &&
          other.type == this.type &&
          other.clubId == this.clubId &&
          other.playerId == this.playerId);
}

class HonoursCompanion extends UpdateCompanion<HonourRow> {
  final Value<int> id;
  final Value<int> seasonStartYear;
  final Value<String> leagueId;
  final Value<String> type;
  final Value<String> clubId;
  final Value<int?> playerId;
  const HonoursCompanion({
    this.id = const Value.absent(),
    this.seasonStartYear = const Value.absent(),
    this.leagueId = const Value.absent(),
    this.type = const Value.absent(),
    this.clubId = const Value.absent(),
    this.playerId = const Value.absent(),
  });
  HonoursCompanion.insert({
    this.id = const Value.absent(),
    required int seasonStartYear,
    required String leagueId,
    required String type,
    required String clubId,
    this.playerId = const Value.absent(),
  }) : seasonStartYear = Value(seasonStartYear),
       leagueId = Value(leagueId),
       type = Value(type),
       clubId = Value(clubId);
  static Insertable<HonourRow> custom({
    Expression<int>? id,
    Expression<int>? seasonStartYear,
    Expression<String>? leagueId,
    Expression<String>? type,
    Expression<String>? clubId,
    Expression<int>? playerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seasonStartYear != null) 'season_start_year': seasonStartYear,
      if (leagueId != null) 'league_id': leagueId,
      if (type != null) 'type': type,
      if (clubId != null) 'club_id': clubId,
      if (playerId != null) 'player_id': playerId,
    });
  }

  HonoursCompanion copyWith({
    Value<int>? id,
    Value<int>? seasonStartYear,
    Value<String>? leagueId,
    Value<String>? type,
    Value<String>? clubId,
    Value<int?>? playerId,
  }) {
    return HonoursCompanion(
      id: id ?? this.id,
      seasonStartYear: seasonStartYear ?? this.seasonStartYear,
      leagueId: leagueId ?? this.leagueId,
      type: type ?? this.type,
      clubId: clubId ?? this.clubId,
      playerId: playerId ?? this.playerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seasonStartYear.present) {
      map['season_start_year'] = Variable<int>(seasonStartYear.value);
    }
    if (leagueId.present) {
      map['league_id'] = Variable<String>(leagueId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (clubId.present) {
      map['club_id'] = Variable<String>(clubId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HonoursCompanion(')
          ..write('id: $id, ')
          ..write('seasonStartYear: $seasonStartYear, ')
          ..write('leagueId: $leagueId, ')
          ..write('type: $type, ')
          ..write('clubId: $clubId, ')
          ..write('playerId: $playerId')
          ..write(')'))
        .toString();
  }
}

class $NegotiationSessionsTable extends NegotiationSessions
    with TableInfo<$NegotiationSessionsTable, NegotiationSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NegotiationSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _offerIdMeta = const VerificationMeta(
    'offerId',
  );
  @override
  late final GeneratedColumn<int> offerId = GeneratedColumn<int>(
    'offer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patienceMeta = const VerificationMeta(
    'patience',
  );
  @override
  late final GeneratedColumn<int> patience = GeneratedColumn<int>(
    'patience',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorValueMeta = const VerificationMeta(
    'anchorValue',
  );
  @override
  late final GeneratedColumn<int> anchorValue = GeneratedColumn<int>(
    'anchor_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitValueMeta = const VerificationMeta(
    'limitValue',
  );
  @override
  late final GeneratedColumn<int> limitValue = GeneratedColumn<int>(
    'limit_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extrasMeta = const VerificationMeta('extras');
  @override
  late final GeneratedColumn<String> extras = GeneratedColumn<String>(
    'extras',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedDateMeta = const VerificationMeta(
    'updatedDate',
  );
  @override
  late final GeneratedColumn<DateTime> updatedDate = GeneratedColumn<DateTime>(
    'updated_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cooldownUntilMeta = const VerificationMeta(
    'cooldownUntil',
  );
  @override
  late final GeneratedColumn<DateTime> cooldownUntil =
      GeneratedColumn<DateTime>(
        'cooldown_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    offerId,
    mode,
    playerId,
    status,
    patience,
    anchorValue,
    limitValue,
    extras,
    updatedDate,
    cooldownUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'negotiation_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<NegotiationSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('offer_id')) {
      context.handle(
        _offerIdMeta,
        offerId.isAcceptableOrUnknown(data['offer_id']!, _offerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_offerIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('patience')) {
      context.handle(
        _patienceMeta,
        patience.isAcceptableOrUnknown(data['patience']!, _patienceMeta),
      );
    } else if (isInserting) {
      context.missing(_patienceMeta);
    }
    if (data.containsKey('anchor_value')) {
      context.handle(
        _anchorValueMeta,
        anchorValue.isAcceptableOrUnknown(
          data['anchor_value']!,
          _anchorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anchorValueMeta);
    }
    if (data.containsKey('limit_value')) {
      context.handle(
        _limitValueMeta,
        limitValue.isAcceptableOrUnknown(data['limit_value']!, _limitValueMeta),
      );
    } else if (isInserting) {
      context.missing(_limitValueMeta);
    }
    if (data.containsKey('extras')) {
      context.handle(
        _extrasMeta,
        extras.isAcceptableOrUnknown(data['extras']!, _extrasMeta),
      );
    } else if (isInserting) {
      context.missing(_extrasMeta);
    }
    if (data.containsKey('updated_date')) {
      context.handle(
        _updatedDateMeta,
        updatedDate.isAcceptableOrUnknown(
          data['updated_date']!,
          _updatedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedDateMeta);
    }
    if (data.containsKey('cooldown_until')) {
      context.handle(
        _cooldownUntilMeta,
        cooldownUntil.isAcceptableOrUnknown(
          data['cooldown_until']!,
          _cooldownUntilMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {offerId, mode};
  @override
  NegotiationSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NegotiationSessionRow(
      offerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}offer_id'],
          )!,
      mode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}mode'],
          )!,
      playerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}player_id'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      patience:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}patience'],
          )!,
      anchorValue:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}anchor_value'],
          )!,
      limitValue:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}limit_value'],
          )!,
      extras:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}extras'],
          )!,
      updatedDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_date'],
          )!,
      cooldownUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cooldown_until'],
      ),
    );
  }

  @override
  $NegotiationSessionsTable createAlias(String alias) {
    return $NegotiationSessionsTable(attachedDatabase, alias);
  }
}

class NegotiationSessionRow extends DataClass
    implements Insertable<NegotiationSessionRow> {
  final int offerId;
  final String mode;
  final int playerId;
  final String status;
  final int patience;
  final int anchorValue;
  final int limitValue;
  final String extras;
  final DateTime updatedDate;
  final DateTime? cooldownUntil;
  const NegotiationSessionRow({
    required this.offerId,
    required this.mode,
    required this.playerId,
    required this.status,
    required this.patience,
    required this.anchorValue,
    required this.limitValue,
    required this.extras,
    required this.updatedDate,
    this.cooldownUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['offer_id'] = Variable<int>(offerId);
    map['mode'] = Variable<String>(mode);
    map['player_id'] = Variable<int>(playerId);
    map['status'] = Variable<String>(status);
    map['patience'] = Variable<int>(patience);
    map['anchor_value'] = Variable<int>(anchorValue);
    map['limit_value'] = Variable<int>(limitValue);
    map['extras'] = Variable<String>(extras);
    map['updated_date'] = Variable<DateTime>(updatedDate);
    if (!nullToAbsent || cooldownUntil != null) {
      map['cooldown_until'] = Variable<DateTime>(cooldownUntil);
    }
    return map;
  }

  NegotiationSessionsCompanion toCompanion(bool nullToAbsent) {
    return NegotiationSessionsCompanion(
      offerId: Value(offerId),
      mode: Value(mode),
      playerId: Value(playerId),
      status: Value(status),
      patience: Value(patience),
      anchorValue: Value(anchorValue),
      limitValue: Value(limitValue),
      extras: Value(extras),
      updatedDate: Value(updatedDate),
      cooldownUntil:
          cooldownUntil == null && nullToAbsent
              ? const Value.absent()
              : Value(cooldownUntil),
    );
  }

  factory NegotiationSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NegotiationSessionRow(
      offerId: serializer.fromJson<int>(json['offerId']),
      mode: serializer.fromJson<String>(json['mode']),
      playerId: serializer.fromJson<int>(json['playerId']),
      status: serializer.fromJson<String>(json['status']),
      patience: serializer.fromJson<int>(json['patience']),
      anchorValue: serializer.fromJson<int>(json['anchorValue']),
      limitValue: serializer.fromJson<int>(json['limitValue']),
      extras: serializer.fromJson<String>(json['extras']),
      updatedDate: serializer.fromJson<DateTime>(json['updatedDate']),
      cooldownUntil: serializer.fromJson<DateTime?>(json['cooldownUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'offerId': serializer.toJson<int>(offerId),
      'mode': serializer.toJson<String>(mode),
      'playerId': serializer.toJson<int>(playerId),
      'status': serializer.toJson<String>(status),
      'patience': serializer.toJson<int>(patience),
      'anchorValue': serializer.toJson<int>(anchorValue),
      'limitValue': serializer.toJson<int>(limitValue),
      'extras': serializer.toJson<String>(extras),
      'updatedDate': serializer.toJson<DateTime>(updatedDate),
      'cooldownUntil': serializer.toJson<DateTime?>(cooldownUntil),
    };
  }

  NegotiationSessionRow copyWith({
    int? offerId,
    String? mode,
    int? playerId,
    String? status,
    int? patience,
    int? anchorValue,
    int? limitValue,
    String? extras,
    DateTime? updatedDate,
    Value<DateTime?> cooldownUntil = const Value.absent(),
  }) => NegotiationSessionRow(
    offerId: offerId ?? this.offerId,
    mode: mode ?? this.mode,
    playerId: playerId ?? this.playerId,
    status: status ?? this.status,
    patience: patience ?? this.patience,
    anchorValue: anchorValue ?? this.anchorValue,
    limitValue: limitValue ?? this.limitValue,
    extras: extras ?? this.extras,
    updatedDate: updatedDate ?? this.updatedDate,
    cooldownUntil:
        cooldownUntil.present ? cooldownUntil.value : this.cooldownUntil,
  );
  NegotiationSessionRow copyWithCompanion(NegotiationSessionsCompanion data) {
    return NegotiationSessionRow(
      offerId: data.offerId.present ? data.offerId.value : this.offerId,
      mode: data.mode.present ? data.mode.value : this.mode,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      status: data.status.present ? data.status.value : this.status,
      patience: data.patience.present ? data.patience.value : this.patience,
      anchorValue:
          data.anchorValue.present ? data.anchorValue.value : this.anchorValue,
      limitValue:
          data.limitValue.present ? data.limitValue.value : this.limitValue,
      extras: data.extras.present ? data.extras.value : this.extras,
      updatedDate:
          data.updatedDate.present ? data.updatedDate.value : this.updatedDate,
      cooldownUntil:
          data.cooldownUntil.present
              ? data.cooldownUntil.value
              : this.cooldownUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NegotiationSessionRow(')
          ..write('offerId: $offerId, ')
          ..write('mode: $mode, ')
          ..write('playerId: $playerId, ')
          ..write('status: $status, ')
          ..write('patience: $patience, ')
          ..write('anchorValue: $anchorValue, ')
          ..write('limitValue: $limitValue, ')
          ..write('extras: $extras, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('cooldownUntil: $cooldownUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    offerId,
    mode,
    playerId,
    status,
    patience,
    anchorValue,
    limitValue,
    extras,
    updatedDate,
    cooldownUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NegotiationSessionRow &&
          other.offerId == this.offerId &&
          other.mode == this.mode &&
          other.playerId == this.playerId &&
          other.status == this.status &&
          other.patience == this.patience &&
          other.anchorValue == this.anchorValue &&
          other.limitValue == this.limitValue &&
          other.extras == this.extras &&
          other.updatedDate == this.updatedDate &&
          other.cooldownUntil == this.cooldownUntil);
}

class NegotiationSessionsCompanion
    extends UpdateCompanion<NegotiationSessionRow> {
  final Value<int> offerId;
  final Value<String> mode;
  final Value<int> playerId;
  final Value<String> status;
  final Value<int> patience;
  final Value<int> anchorValue;
  final Value<int> limitValue;
  final Value<String> extras;
  final Value<DateTime> updatedDate;
  final Value<DateTime?> cooldownUntil;
  final Value<int> rowid;
  const NegotiationSessionsCompanion({
    this.offerId = const Value.absent(),
    this.mode = const Value.absent(),
    this.playerId = const Value.absent(),
    this.status = const Value.absent(),
    this.patience = const Value.absent(),
    this.anchorValue = const Value.absent(),
    this.limitValue = const Value.absent(),
    this.extras = const Value.absent(),
    this.updatedDate = const Value.absent(),
    this.cooldownUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NegotiationSessionsCompanion.insert({
    required int offerId,
    required String mode,
    required int playerId,
    required String status,
    required int patience,
    required int anchorValue,
    required int limitValue,
    required String extras,
    required DateTime updatedDate,
    this.cooldownUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : offerId = Value(offerId),
       mode = Value(mode),
       playerId = Value(playerId),
       status = Value(status),
       patience = Value(patience),
       anchorValue = Value(anchorValue),
       limitValue = Value(limitValue),
       extras = Value(extras),
       updatedDate = Value(updatedDate);
  static Insertable<NegotiationSessionRow> custom({
    Expression<int>? offerId,
    Expression<String>? mode,
    Expression<int>? playerId,
    Expression<String>? status,
    Expression<int>? patience,
    Expression<int>? anchorValue,
    Expression<int>? limitValue,
    Expression<String>? extras,
    Expression<DateTime>? updatedDate,
    Expression<DateTime>? cooldownUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (offerId != null) 'offer_id': offerId,
      if (mode != null) 'mode': mode,
      if (playerId != null) 'player_id': playerId,
      if (status != null) 'status': status,
      if (patience != null) 'patience': patience,
      if (anchorValue != null) 'anchor_value': anchorValue,
      if (limitValue != null) 'limit_value': limitValue,
      if (extras != null) 'extras': extras,
      if (updatedDate != null) 'updated_date': updatedDate,
      if (cooldownUntil != null) 'cooldown_until': cooldownUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NegotiationSessionsCompanion copyWith({
    Value<int>? offerId,
    Value<String>? mode,
    Value<int>? playerId,
    Value<String>? status,
    Value<int>? patience,
    Value<int>? anchorValue,
    Value<int>? limitValue,
    Value<String>? extras,
    Value<DateTime>? updatedDate,
    Value<DateTime?>? cooldownUntil,
    Value<int>? rowid,
  }) {
    return NegotiationSessionsCompanion(
      offerId: offerId ?? this.offerId,
      mode: mode ?? this.mode,
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
      patience: patience ?? this.patience,
      anchorValue: anchorValue ?? this.anchorValue,
      limitValue: limitValue ?? this.limitValue,
      extras: extras ?? this.extras,
      updatedDate: updatedDate ?? this.updatedDate,
      cooldownUntil: cooldownUntil ?? this.cooldownUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (offerId.present) {
      map['offer_id'] = Variable<int>(offerId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (patience.present) {
      map['patience'] = Variable<int>(patience.value);
    }
    if (anchorValue.present) {
      map['anchor_value'] = Variable<int>(anchorValue.value);
    }
    if (limitValue.present) {
      map['limit_value'] = Variable<int>(limitValue.value);
    }
    if (extras.present) {
      map['extras'] = Variable<String>(extras.value);
    }
    if (updatedDate.present) {
      map['updated_date'] = Variable<DateTime>(updatedDate.value);
    }
    if (cooldownUntil.present) {
      map['cooldown_until'] = Variable<DateTime>(cooldownUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NegotiationSessionsCompanion(')
          ..write('offerId: $offerId, ')
          ..write('mode: $mode, ')
          ..write('playerId: $playerId, ')
          ..write('status: $status, ')
          ..write('patience: $patience, ')
          ..write('anchorValue: $anchorValue, ')
          ..write('limitValue: $limitValue, ')
          ..write('extras: $extras, ')
          ..write('updatedDate: $updatedDate, ')
          ..write('cooldownUntil: $cooldownUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NationsTable nations = $NationsTable(this);
  late final $LeaguesTable leagues = $LeaguesTable(this);
  late final $ClubsTable clubs = $ClubsTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $ContractsTable contracts = $ContractsTable(this);
  late final $GameStatesTable gameStates = $GameStatesTable(this);
  late final $FixturesTable fixtures = $FixturesTable(this);
  late final $InboxMessagesTable inboxMessages = $InboxMessagesTable(this);
  late final $ClubTacticsTable clubTactics = $ClubTacticsTable(this);
  late final $TransferOffersTable transferOffers = $TransferOffersTable(this);
  late final $TransferHistoryTable transferHistory = $TransferHistoryTable(
    this,
  );
  late final $ShortlistTable shortlist = $ShortlistTable(this);
  late final $ClubAiProfilesTable clubAiProfiles = $ClubAiProfilesTable(this);
  late final $TransferInterestsTable transferInterests =
      $TransferInterestsTable(this);
  late final $TransferNewsTable transferNews = $TransferNewsTable(this);
  late final $MarketMemoryTable marketMemory = $MarketMemoryTable(this);
  late final $SeasonsTable seasons = $SeasonsTable(this);
  late final $SeasonArchiveTable seasonArchive = $SeasonArchiveTable(this);
  late final $HonoursTable honours = $HonoursTable(this);
  late final $NegotiationSessionsTable negotiationSessions =
      $NegotiationSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    nations,
    leagues,
    clubs,
    players,
    contracts,
    gameStates,
    fixtures,
    inboxMessages,
    clubTactics,
    transferOffers,
    transferHistory,
    shortlist,
    clubAiProfiles,
    transferInterests,
    transferNews,
    marketMemory,
    seasons,
    seasonArchive,
    honours,
    negotiationSessions,
  ];
}

typedef $$NationsTableCreateCompanionBuilder =
    NationsCompanion Function({
      required String id,
      required String name,
      required String code,
      Value<int> rowid,
    });
typedef $$NationsTableUpdateCompanionBuilder =
    NationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> code,
      Value<int> rowid,
    });

class $$NationsTableFilterComposer
    extends Composer<_$AppDatabase, $NationsTable> {
  $$NationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NationsTable> {
  $$NationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NationsTable> {
  $$NationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);
}

class $$NationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NationsTable,
          NationRow,
          $$NationsTableFilterComposer,
          $$NationsTableOrderingComposer,
          $$NationsTableAnnotationComposer,
          $$NationsTableCreateCompanionBuilder,
          $$NationsTableUpdateCompanionBuilder,
          (NationRow, BaseReferences<_$AppDatabase, $NationsTable, NationRow>),
          NationRow,
          PrefetchHooks Function()
        > {
  $$NationsTableTableManager(_$AppDatabase db, $NationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$NationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$NationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$NationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NationsCompanion(
                id: id,
                name: name,
                code: code,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String code,
                Value<int> rowid = const Value.absent(),
              }) => NationsCompanion.insert(
                id: id,
                name: name,
                code: code,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NationsTable,
      NationRow,
      $$NationsTableFilterComposer,
      $$NationsTableOrderingComposer,
      $$NationsTableAnnotationComposer,
      $$NationsTableCreateCompanionBuilder,
      $$NationsTableUpdateCompanionBuilder,
      (NationRow, BaseReferences<_$AppDatabase, $NationsTable, NationRow>),
      NationRow,
      PrefetchHooks Function()
    >;
typedef $$LeaguesTableCreateCompanionBuilder =
    LeaguesCompanion Function({
      required String id,
      required String nationId,
      required String name,
      required int tier,
      required int jumlahTim,
      required int slotPromosi,
      required int slotDegradasi,
      Value<int> slotPlayoff,
      Value<int> rowid,
    });
typedef $$LeaguesTableUpdateCompanionBuilder =
    LeaguesCompanion Function({
      Value<String> id,
      Value<String> nationId,
      Value<String> name,
      Value<int> tier,
      Value<int> jumlahTim,
      Value<int> slotPromosi,
      Value<int> slotDegradasi,
      Value<int> slotPlayoff,
      Value<int> rowid,
    });

class $$LeaguesTableFilterComposer
    extends Composer<_$AppDatabase, $LeaguesTable> {
  $$LeaguesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationId => $composableBuilder(
    column: $table.nationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jumlahTim => $composableBuilder(
    column: $table.jumlahTim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotPromosi => $composableBuilder(
    column: $table.slotPromosi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotDegradasi => $composableBuilder(
    column: $table.slotDegradasi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotPlayoff => $composableBuilder(
    column: $table.slotPlayoff,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeaguesTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaguesTable> {
  $$LeaguesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationId => $composableBuilder(
    column: $table.nationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jumlahTim => $composableBuilder(
    column: $table.jumlahTim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotPromosi => $composableBuilder(
    column: $table.slotPromosi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotDegradasi => $composableBuilder(
    column: $table.slotDegradasi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotPlayoff => $composableBuilder(
    column: $table.slotPlayoff,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeaguesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaguesTable> {
  $$LeaguesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nationId =>
      $composableBuilder(column: $table.nationId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<int> get jumlahTim =>
      $composableBuilder(column: $table.jumlahTim, builder: (column) => column);

  GeneratedColumn<int> get slotPromosi => $composableBuilder(
    column: $table.slotPromosi,
    builder: (column) => column,
  );

  GeneratedColumn<int> get slotDegradasi => $composableBuilder(
    column: $table.slotDegradasi,
    builder: (column) => column,
  );

  GeneratedColumn<int> get slotPlayoff => $composableBuilder(
    column: $table.slotPlayoff,
    builder: (column) => column,
  );
}

class $$LeaguesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeaguesTable,
          LeagueRow,
          $$LeaguesTableFilterComposer,
          $$LeaguesTableOrderingComposer,
          $$LeaguesTableAnnotationComposer,
          $$LeaguesTableCreateCompanionBuilder,
          $$LeaguesTableUpdateCompanionBuilder,
          (LeagueRow, BaseReferences<_$AppDatabase, $LeaguesTable, LeagueRow>),
          LeagueRow,
          PrefetchHooks Function()
        > {
  $$LeaguesTableTableManager(_$AppDatabase db, $LeaguesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LeaguesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LeaguesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LeaguesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<int> jumlahTim = const Value.absent(),
                Value<int> slotPromosi = const Value.absent(),
                Value<int> slotDegradasi = const Value.absent(),
                Value<int> slotPlayoff = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaguesCompanion(
                id: id,
                nationId: nationId,
                name: name,
                tier: tier,
                jumlahTim: jumlahTim,
                slotPromosi: slotPromosi,
                slotDegradasi: slotDegradasi,
                slotPlayoff: slotPlayoff,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nationId,
                required String name,
                required int tier,
                required int jumlahTim,
                required int slotPromosi,
                required int slotDegradasi,
                Value<int> slotPlayoff = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaguesCompanion.insert(
                id: id,
                nationId: nationId,
                name: name,
                tier: tier,
                jumlahTim: jumlahTim,
                slotPromosi: slotPromosi,
                slotDegradasi: slotDegradasi,
                slotPlayoff: slotPlayoff,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeaguesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeaguesTable,
      LeagueRow,
      $$LeaguesTableFilterComposer,
      $$LeaguesTableOrderingComposer,
      $$LeaguesTableAnnotationComposer,
      $$LeaguesTableCreateCompanionBuilder,
      $$LeaguesTableUpdateCompanionBuilder,
      (LeagueRow, BaseReferences<_$AppDatabase, $LeaguesTable, LeagueRow>),
      LeagueRow,
      PrefetchHooks Function()
    >;
typedef $$ClubsTableCreateCompanionBuilder =
    ClubsCompanion Function({
      required String id,
      required String leagueId,
      required String name,
      required String shortName,
      required String primaryColor,
      required String secondaryColor,
      required int reputation,
      required String stadiumName,
      required int capacity,
      required int balance,
      required int transferBudget,
      required int wageBudget,
      Value<int> rowid,
    });
typedef $$ClubsTableUpdateCompanionBuilder =
    ClubsCompanion Function({
      Value<String> id,
      Value<String> leagueId,
      Value<String> name,
      Value<String> shortName,
      Value<String> primaryColor,
      Value<String> secondaryColor,
      Value<int> reputation,
      Value<String> stadiumName,
      Value<int> capacity,
      Value<int> balance,
      Value<int> transferBudget,
      Value<int> wageBudget,
      Value<int> rowid,
    });

class $$ClubsTableFilterComposer extends Composer<_$AppDatabase, $ClubsTable> {
  $$ClubsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leagueId => $composableBuilder(
    column: $table.leagueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryColor => $composableBuilder(
    column: $table.primaryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryColor => $composableBuilder(
    column: $table.secondaryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stadiumName => $composableBuilder(
    column: $table.stadiumName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transferBudget => $composableBuilder(
    column: $table.transferBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wageBudget => $composableBuilder(
    column: $table.wageBudget,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClubsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClubsTable> {
  $$ClubsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leagueId => $composableBuilder(
    column: $table.leagueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryColor => $composableBuilder(
    column: $table.primaryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryColor => $composableBuilder(
    column: $table.secondaryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stadiumName => $composableBuilder(
    column: $table.stadiumName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transferBudget => $composableBuilder(
    column: $table.transferBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wageBudget => $composableBuilder(
    column: $table.wageBudget,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClubsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClubsTable> {
  $$ClubsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get leagueId =>
      $composableBuilder(column: $table.leagueId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get primaryColor => $composableBuilder(
    column: $table.primaryColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryColor => $composableBuilder(
    column: $table.secondaryColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reputation => $composableBuilder(
    column: $table.reputation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stadiumName => $composableBuilder(
    column: $table.stadiumName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<int> get transferBudget => $composableBuilder(
    column: $table.transferBudget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wageBudget => $composableBuilder(
    column: $table.wageBudget,
    builder: (column) => column,
  );
}

class $$ClubsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClubsTable,
          ClubRow,
          $$ClubsTableFilterComposer,
          $$ClubsTableOrderingComposer,
          $$ClubsTableAnnotationComposer,
          $$ClubsTableCreateCompanionBuilder,
          $$ClubsTableUpdateCompanionBuilder,
          (ClubRow, BaseReferences<_$AppDatabase, $ClubsTable, ClubRow>),
          ClubRow,
          PrefetchHooks Function()
        > {
  $$ClubsTableTableManager(_$AppDatabase db, $ClubsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ClubsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ClubsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ClubsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> leagueId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<String> primaryColor = const Value.absent(),
                Value<String> secondaryColor = const Value.absent(),
                Value<int> reputation = const Value.absent(),
                Value<String> stadiumName = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<int> transferBudget = const Value.absent(),
                Value<int> wageBudget = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClubsCompanion(
                id: id,
                leagueId: leagueId,
                name: name,
                shortName: shortName,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                reputation: reputation,
                stadiumName: stadiumName,
                capacity: capacity,
                balance: balance,
                transferBudget: transferBudget,
                wageBudget: wageBudget,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String leagueId,
                required String name,
                required String shortName,
                required String primaryColor,
                required String secondaryColor,
                required int reputation,
                required String stadiumName,
                required int capacity,
                required int balance,
                required int transferBudget,
                required int wageBudget,
                Value<int> rowid = const Value.absent(),
              }) => ClubsCompanion.insert(
                id: id,
                leagueId: leagueId,
                name: name,
                shortName: shortName,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                reputation: reputation,
                stadiumName: stadiumName,
                capacity: capacity,
                balance: balance,
                transferBudget: transferBudget,
                wageBudget: wageBudget,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClubsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClubsTable,
      ClubRow,
      $$ClubsTableFilterComposer,
      $$ClubsTableOrderingComposer,
      $$ClubsTableAnnotationComposer,
      $$ClubsTableCreateCompanionBuilder,
      $$ClubsTableUpdateCompanionBuilder,
      (ClubRow, BaseReferences<_$AppDatabase, $ClubsTable, ClubRow>),
      ClubRow,
      PrefetchHooks Function()
    >;
typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      required String clubId,
      required String firstName,
      required String lastName,
      required int age,
      required String nationality,
      required Position position,
      required int finishing,
      required int passing,
      required int dribbling,
      required int firstTouch,
      required int crossing,
      required int tackling,
      required int heading,
      required int technique,
      required int decisions,
      required int positioning,
      required int vision,
      required int composure,
      required int workRate,
      required int aggression,
      required int pace,
      required int acceleration,
      required int stamina,
      required int strength,
      required int agility,
      required int handling,
      required int reflexes,
      required int oneOnOnes,
      required int aerialReach,
      required int potentialAbility,
      required int currentAbility,
      required int condition,
      required int morale,
      required int marketValue,
      Value<DateTime?> lockedUntil,
      Value<bool> isTransferListed,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<int> id,
      Value<String> clubId,
      Value<String> firstName,
      Value<String> lastName,
      Value<int> age,
      Value<String> nationality,
      Value<Position> position,
      Value<int> finishing,
      Value<int> passing,
      Value<int> dribbling,
      Value<int> firstTouch,
      Value<int> crossing,
      Value<int> tackling,
      Value<int> heading,
      Value<int> technique,
      Value<int> decisions,
      Value<int> positioning,
      Value<int> vision,
      Value<int> composure,
      Value<int> workRate,
      Value<int> aggression,
      Value<int> pace,
      Value<int> acceleration,
      Value<int> stamina,
      Value<int> strength,
      Value<int> agility,
      Value<int> handling,
      Value<int> reflexes,
      Value<int> oneOnOnes,
      Value<int> aerialReach,
      Value<int> potentialAbility,
      Value<int> currentAbility,
      Value<int> condition,
      Value<int> morale,
      Value<int> marketValue,
      Value<DateTime?> lockedUntil,
      Value<bool> isTransferListed,
    });

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationality => $composableBuilder(
    column: $table.nationality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Position, Position, String> get position =>
      $composableBuilder(
        column: $table.position,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get finishing => $composableBuilder(
    column: $table.finishing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passing => $composableBuilder(
    column: $table.passing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dribbling => $composableBuilder(
    column: $table.dribbling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstTouch => $composableBuilder(
    column: $table.firstTouch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get crossing => $composableBuilder(
    column: $table.crossing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tackling => $composableBuilder(
    column: $table.tackling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get technique => $composableBuilder(
    column: $table.technique,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decisions => $composableBuilder(
    column: $table.decisions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positioning => $composableBuilder(
    column: $table.positioning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vision => $composableBuilder(
    column: $table.vision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get composure => $composableBuilder(
    column: $table.composure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workRate => $composableBuilder(
    column: $table.workRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aggression => $composableBuilder(
    column: $table.aggression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pace => $composableBuilder(
    column: $table.pace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acceleration => $composableBuilder(
    column: $table.acceleration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stamina => $composableBuilder(
    column: $table.stamina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get agility => $composableBuilder(
    column: $table.agility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handling => $composableBuilder(
    column: $table.handling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reflexes => $composableBuilder(
    column: $table.reflexes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oneOnOnes => $composableBuilder(
    column: $table.oneOnOnes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aerialReach => $composableBuilder(
    column: $table.aerialReach,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get potentialAbility => $composableBuilder(
    column: $table.potentialAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentAbility => $composableBuilder(
    column: $table.currentAbility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get morale => $composableBuilder(
    column: $table.morale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get marketValue => $composableBuilder(
    column: $table.marketValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTransferListed => $composableBuilder(
    column: $table.isTransferListed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationality => $composableBuilder(
    column: $table.nationality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishing => $composableBuilder(
    column: $table.finishing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passing => $composableBuilder(
    column: $table.passing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dribbling => $composableBuilder(
    column: $table.dribbling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstTouch => $composableBuilder(
    column: $table.firstTouch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get crossing => $composableBuilder(
    column: $table.crossing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tackling => $composableBuilder(
    column: $table.tackling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get technique => $composableBuilder(
    column: $table.technique,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decisions => $composableBuilder(
    column: $table.decisions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positioning => $composableBuilder(
    column: $table.positioning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vision => $composableBuilder(
    column: $table.vision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get composure => $composableBuilder(
    column: $table.composure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workRate => $composableBuilder(
    column: $table.workRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aggression => $composableBuilder(
    column: $table.aggression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pace => $composableBuilder(
    column: $table.pace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acceleration => $composableBuilder(
    column: $table.acceleration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stamina => $composableBuilder(
    column: $table.stamina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get agility => $composableBuilder(
    column: $table.agility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handling => $composableBuilder(
    column: $table.handling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reflexes => $composableBuilder(
    column: $table.reflexes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oneOnOnes => $composableBuilder(
    column: $table.oneOnOnes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aerialReach => $composableBuilder(
    column: $table.aerialReach,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get potentialAbility => $composableBuilder(
    column: $table.potentialAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentAbility => $composableBuilder(
    column: $table.currentAbility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get morale => $composableBuilder(
    column: $table.morale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marketValue => $composableBuilder(
    column: $table.marketValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTransferListed => $composableBuilder(
    column: $table.isTransferListed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clubId =>
      $composableBuilder(column: $table.clubId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get nationality => $composableBuilder(
    column: $table.nationality,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Position, String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get finishing =>
      $composableBuilder(column: $table.finishing, builder: (column) => column);

  GeneratedColumn<int> get passing =>
      $composableBuilder(column: $table.passing, builder: (column) => column);

  GeneratedColumn<int> get dribbling =>
      $composableBuilder(column: $table.dribbling, builder: (column) => column);

  GeneratedColumn<int> get firstTouch => $composableBuilder(
    column: $table.firstTouch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get crossing =>
      $composableBuilder(column: $table.crossing, builder: (column) => column);

  GeneratedColumn<int> get tackling =>
      $composableBuilder(column: $table.tackling, builder: (column) => column);

  GeneratedColumn<int> get heading =>
      $composableBuilder(column: $table.heading, builder: (column) => column);

  GeneratedColumn<int> get technique =>
      $composableBuilder(column: $table.technique, builder: (column) => column);

  GeneratedColumn<int> get decisions =>
      $composableBuilder(column: $table.decisions, builder: (column) => column);

  GeneratedColumn<int> get positioning => $composableBuilder(
    column: $table.positioning,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vision =>
      $composableBuilder(column: $table.vision, builder: (column) => column);

  GeneratedColumn<int> get composure =>
      $composableBuilder(column: $table.composure, builder: (column) => column);

  GeneratedColumn<int> get workRate =>
      $composableBuilder(column: $table.workRate, builder: (column) => column);

  GeneratedColumn<int> get aggression => $composableBuilder(
    column: $table.aggression,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pace =>
      $composableBuilder(column: $table.pace, builder: (column) => column);

  GeneratedColumn<int> get acceleration => $composableBuilder(
    column: $table.acceleration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stamina =>
      $composableBuilder(column: $table.stamina, builder: (column) => column);

  GeneratedColumn<int> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<int> get agility =>
      $composableBuilder(column: $table.agility, builder: (column) => column);

  GeneratedColumn<int> get handling =>
      $composableBuilder(column: $table.handling, builder: (column) => column);

  GeneratedColumn<int> get reflexes =>
      $composableBuilder(column: $table.reflexes, builder: (column) => column);

  GeneratedColumn<int> get oneOnOnes =>
      $composableBuilder(column: $table.oneOnOnes, builder: (column) => column);

  GeneratedColumn<int> get aerialReach => $composableBuilder(
    column: $table.aerialReach,
    builder: (column) => column,
  );

  GeneratedColumn<int> get potentialAbility => $composableBuilder(
    column: $table.potentialAbility,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentAbility => $composableBuilder(
    column: $table.currentAbility,
    builder: (column) => column,
  );

  GeneratedColumn<int> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<int> get morale =>
      $composableBuilder(column: $table.morale, builder: (column) => column);

  GeneratedColumn<int> get marketValue => $composableBuilder(
    column: $table.marketValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTransferListed => $composableBuilder(
    column: $table.isTransferListed,
    builder: (column) => column,
  );
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          PlayerRow,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (PlayerRow, BaseReferences<_$AppDatabase, $PlayersTable, PlayerRow>),
          PlayerRow,
          PrefetchHooks Function()
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clubId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> nationality = const Value.absent(),
                Value<Position> position = const Value.absent(),
                Value<int> finishing = const Value.absent(),
                Value<int> passing = const Value.absent(),
                Value<int> dribbling = const Value.absent(),
                Value<int> firstTouch = const Value.absent(),
                Value<int> crossing = const Value.absent(),
                Value<int> tackling = const Value.absent(),
                Value<int> heading = const Value.absent(),
                Value<int> technique = const Value.absent(),
                Value<int> decisions = const Value.absent(),
                Value<int> positioning = const Value.absent(),
                Value<int> vision = const Value.absent(),
                Value<int> composure = const Value.absent(),
                Value<int> workRate = const Value.absent(),
                Value<int> aggression = const Value.absent(),
                Value<int> pace = const Value.absent(),
                Value<int> acceleration = const Value.absent(),
                Value<int> stamina = const Value.absent(),
                Value<int> strength = const Value.absent(),
                Value<int> agility = const Value.absent(),
                Value<int> handling = const Value.absent(),
                Value<int> reflexes = const Value.absent(),
                Value<int> oneOnOnes = const Value.absent(),
                Value<int> aerialReach = const Value.absent(),
                Value<int> potentialAbility = const Value.absent(),
                Value<int> currentAbility = const Value.absent(),
                Value<int> condition = const Value.absent(),
                Value<int> morale = const Value.absent(),
                Value<int> marketValue = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<bool> isTransferListed = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                clubId: clubId,
                firstName: firstName,
                lastName: lastName,
                age: age,
                nationality: nationality,
                position: position,
                finishing: finishing,
                passing: passing,
                dribbling: dribbling,
                firstTouch: firstTouch,
                crossing: crossing,
                tackling: tackling,
                heading: heading,
                technique: technique,
                decisions: decisions,
                positioning: positioning,
                vision: vision,
                composure: composure,
                workRate: workRate,
                aggression: aggression,
                pace: pace,
                acceleration: acceleration,
                stamina: stamina,
                strength: strength,
                agility: agility,
                handling: handling,
                reflexes: reflexes,
                oneOnOnes: oneOnOnes,
                aerialReach: aerialReach,
                potentialAbility: potentialAbility,
                currentAbility: currentAbility,
                condition: condition,
                morale: morale,
                marketValue: marketValue,
                lockedUntil: lockedUntil,
                isTransferListed: isTransferListed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clubId,
                required String firstName,
                required String lastName,
                required int age,
                required String nationality,
                required Position position,
                required int finishing,
                required int passing,
                required int dribbling,
                required int firstTouch,
                required int crossing,
                required int tackling,
                required int heading,
                required int technique,
                required int decisions,
                required int positioning,
                required int vision,
                required int composure,
                required int workRate,
                required int aggression,
                required int pace,
                required int acceleration,
                required int stamina,
                required int strength,
                required int agility,
                required int handling,
                required int reflexes,
                required int oneOnOnes,
                required int aerialReach,
                required int potentialAbility,
                required int currentAbility,
                required int condition,
                required int morale,
                required int marketValue,
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<bool> isTransferListed = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                clubId: clubId,
                firstName: firstName,
                lastName: lastName,
                age: age,
                nationality: nationality,
                position: position,
                finishing: finishing,
                passing: passing,
                dribbling: dribbling,
                firstTouch: firstTouch,
                crossing: crossing,
                tackling: tackling,
                heading: heading,
                technique: technique,
                decisions: decisions,
                positioning: positioning,
                vision: vision,
                composure: composure,
                workRate: workRate,
                aggression: aggression,
                pace: pace,
                acceleration: acceleration,
                stamina: stamina,
                strength: strength,
                agility: agility,
                handling: handling,
                reflexes: reflexes,
                oneOnOnes: oneOnOnes,
                aerialReach: aerialReach,
                potentialAbility: potentialAbility,
                currentAbility: currentAbility,
                condition: condition,
                morale: morale,
                marketValue: marketValue,
                lockedUntil: lockedUntil,
                isTransferListed: isTransferListed,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      PlayerRow,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (PlayerRow, BaseReferences<_$AppDatabase, $PlayersTable, PlayerRow>),
      PlayerRow,
      PrefetchHooks Function()
    >;
typedef $$ContractsTableCreateCompanionBuilder =
    ContractsCompanion Function({
      Value<int> playerId,
      required String clubId,
      required int wage,
      required DateTime endDate,
      required SquadStatus squadStatus,
    });
typedef $$ContractsTableUpdateCompanionBuilder =
    ContractsCompanion Function({
      Value<int> playerId,
      Value<String> clubId,
      Value<int> wage,
      Value<DateTime> endDate,
      Value<SquadStatus> squadStatus,
    });

class $$ContractsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wage => $composableBuilder(
    column: $table.wage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SquadStatus, SquadStatus, String>
  get squadStatus => $composableBuilder(
    column: $table.squadStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ContractsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wage => $composableBuilder(
    column: $table.wage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get squadStatus => $composableBuilder(
    column: $table.squadStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContractsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get clubId =>
      $composableBuilder(column: $table.clubId, builder: (column) => column);

  GeneratedColumn<int> get wage =>
      $composableBuilder(column: $table.wage, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SquadStatus, String> get squadStatus =>
      $composableBuilder(
        column: $table.squadStatus,
        builder: (column) => column,
      );
}

class $$ContractsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContractsTable,
          ContractRow,
          $$ContractsTableFilterComposer,
          $$ContractsTableOrderingComposer,
          $$ContractsTableAnnotationComposer,
          $$ContractsTableCreateCompanionBuilder,
          $$ContractsTableUpdateCompanionBuilder,
          (
            ContractRow,
            BaseReferences<_$AppDatabase, $ContractsTable, ContractRow>,
          ),
          ContractRow,
          PrefetchHooks Function()
        > {
  $$ContractsTableTableManager(_$AppDatabase db, $ContractsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ContractsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ContractsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ContractsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> playerId = const Value.absent(),
                Value<String> clubId = const Value.absent(),
                Value<int> wage = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<SquadStatus> squadStatus = const Value.absent(),
              }) => ContractsCompanion(
                playerId: playerId,
                clubId: clubId,
                wage: wage,
                endDate: endDate,
                squadStatus: squadStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> playerId = const Value.absent(),
                required String clubId,
                required int wage,
                required DateTime endDate,
                required SquadStatus squadStatus,
              }) => ContractsCompanion.insert(
                playerId: playerId,
                clubId: clubId,
                wage: wage,
                endDate: endDate,
                squadStatus: squadStatus,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContractsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContractsTable,
      ContractRow,
      $$ContractsTableFilterComposer,
      $$ContractsTableOrderingComposer,
      $$ContractsTableAnnotationComposer,
      $$ContractsTableCreateCompanionBuilder,
      $$ContractsTableUpdateCompanionBuilder,
      (
        ContractRow,
        BaseReferences<_$AppDatabase, $ContractsTable, ContractRow>,
      ),
      ContractRow,
      PrefetchHooks Function()
    >;
typedef $$GameStatesTableCreateCompanionBuilder =
    GameStatesCompanion Function({
      Value<int> id,
      required DateTime currentDate,
      required String managerName,
      Value<String?> clubId,
      required int seed,
      Value<int> seasonStartYear,
    });
typedef $$GameStatesTableUpdateCompanionBuilder =
    GameStatesCompanion Function({
      Value<int> id,
      Value<DateTime> currentDate,
      Value<String> managerName,
      Value<String?> clubId,
      Value<int> seed,
      Value<int> seasonStartYear,
    });

class $$GameStatesTableFilterComposer
    extends Composer<_$AppDatabase, $GameStatesTable> {
  $$GameStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get currentDate => $composableBuilder(
    column: $table.currentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameStatesTable> {
  $$GameStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get currentDate => $composableBuilder(
    column: $table.currentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameStatesTable> {
  $$GameStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get currentDate => $composableBuilder(
    column: $table.currentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clubId =>
      $composableBuilder(column: $table.clubId, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => column,
  );
}

class $$GameStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameStatesTable,
          GameStateRow,
          $$GameStatesTableFilterComposer,
          $$GameStatesTableOrderingComposer,
          $$GameStatesTableAnnotationComposer,
          $$GameStatesTableCreateCompanionBuilder,
          $$GameStatesTableUpdateCompanionBuilder,
          (
            GameStateRow,
            BaseReferences<_$AppDatabase, $GameStatesTable, GameStateRow>,
          ),
          GameStateRow,
          PrefetchHooks Function()
        > {
  $$GameStatesTableTableManager(_$AppDatabase db, $GameStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GameStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GameStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$GameStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> currentDate = const Value.absent(),
                Value<String> managerName = const Value.absent(),
                Value<String?> clubId = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<int> seasonStartYear = const Value.absent(),
              }) => GameStatesCompanion(
                id: id,
                currentDate: currentDate,
                managerName: managerName,
                clubId: clubId,
                seed: seed,
                seasonStartYear: seasonStartYear,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime currentDate,
                required String managerName,
                Value<String?> clubId = const Value.absent(),
                required int seed,
                Value<int> seasonStartYear = const Value.absent(),
              }) => GameStatesCompanion.insert(
                id: id,
                currentDate: currentDate,
                managerName: managerName,
                clubId: clubId,
                seed: seed,
                seasonStartYear: seasonStartYear,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameStatesTable,
      GameStateRow,
      $$GameStatesTableFilterComposer,
      $$GameStatesTableOrderingComposer,
      $$GameStatesTableAnnotationComposer,
      $$GameStatesTableCreateCompanionBuilder,
      $$GameStatesTableUpdateCompanionBuilder,
      (
        GameStateRow,
        BaseReferences<_$AppDatabase, $GameStatesTable, GameStateRow>,
      ),
      GameStateRow,
      PrefetchHooks Function()
    >;
typedef $$FixturesTableCreateCompanionBuilder =
    FixturesCompanion Function({
      Value<int> id,
      required String leagueId,
      required int round,
      required DateTime date,
      required String homeClubId,
      required String awayClubId,
      Value<int?> homeGoals,
      Value<int> seasonStartYear,
      Value<String> stage,
      Value<int?> leg,
      Value<int?> awayGoals,
    });
typedef $$FixturesTableUpdateCompanionBuilder =
    FixturesCompanion Function({
      Value<int> id,
      Value<String> leagueId,
      Value<int> round,
      Value<DateTime> date,
      Value<String> homeClubId,
      Value<String> awayClubId,
      Value<int?> homeGoals,
      Value<int> seasonStartYear,
      Value<String> stage,
      Value<int?> leg,
      Value<int?> awayGoals,
    });

class $$FixturesTableFilterComposer
    extends Composer<_$AppDatabase, $FixturesTable> {
  $$FixturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leagueId => $composableBuilder(
    column: $table.leagueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeClubId => $composableBuilder(
    column: $table.homeClubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awayClubId => $composableBuilder(
    column: $table.awayClubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get homeGoals => $composableBuilder(
    column: $table.homeGoals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leg => $composableBuilder(
    column: $table.leg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awayGoals => $composableBuilder(
    column: $table.awayGoals,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FixturesTableOrderingComposer
    extends Composer<_$AppDatabase, $FixturesTable> {
  $$FixturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leagueId => $composableBuilder(
    column: $table.leagueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeClubId => $composableBuilder(
    column: $table.homeClubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awayClubId => $composableBuilder(
    column: $table.awayClubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get homeGoals => $composableBuilder(
    column: $table.homeGoals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leg => $composableBuilder(
    column: $table.leg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awayGoals => $composableBuilder(
    column: $table.awayGoals,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FixturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FixturesTable> {
  $$FixturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get leagueId =>
      $composableBuilder(column: $table.leagueId, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get homeClubId => $composableBuilder(
    column: $table.homeClubId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get awayClubId => $composableBuilder(
    column: $table.awayClubId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get homeGoals =>
      $composableBuilder(column: $table.homeGoals, builder: (column) => column);

  GeneratedColumn<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<int> get leg =>
      $composableBuilder(column: $table.leg, builder: (column) => column);

  GeneratedColumn<int> get awayGoals =>
      $composableBuilder(column: $table.awayGoals, builder: (column) => column);
}

class $$FixturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FixturesTable,
          FixtureRow,
          $$FixturesTableFilterComposer,
          $$FixturesTableOrderingComposer,
          $$FixturesTableAnnotationComposer,
          $$FixturesTableCreateCompanionBuilder,
          $$FixturesTableUpdateCompanionBuilder,
          (
            FixtureRow,
            BaseReferences<_$AppDatabase, $FixturesTable, FixtureRow>,
          ),
          FixtureRow,
          PrefetchHooks Function()
        > {
  $$FixturesTableTableManager(_$AppDatabase db, $FixturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FixturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FixturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FixturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> leagueId = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> homeClubId = const Value.absent(),
                Value<String> awayClubId = const Value.absent(),
                Value<int?> homeGoals = const Value.absent(),
                Value<int> seasonStartYear = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<int?> leg = const Value.absent(),
                Value<int?> awayGoals = const Value.absent(),
              }) => FixturesCompanion(
                id: id,
                leagueId: leagueId,
                round: round,
                date: date,
                homeClubId: homeClubId,
                awayClubId: awayClubId,
                homeGoals: homeGoals,
                seasonStartYear: seasonStartYear,
                stage: stage,
                leg: leg,
                awayGoals: awayGoals,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String leagueId,
                required int round,
                required DateTime date,
                required String homeClubId,
                required String awayClubId,
                Value<int?> homeGoals = const Value.absent(),
                Value<int> seasonStartYear = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<int?> leg = const Value.absent(),
                Value<int?> awayGoals = const Value.absent(),
              }) => FixturesCompanion.insert(
                id: id,
                leagueId: leagueId,
                round: round,
                date: date,
                homeClubId: homeClubId,
                awayClubId: awayClubId,
                homeGoals: homeGoals,
                seasonStartYear: seasonStartYear,
                stage: stage,
                leg: leg,
                awayGoals: awayGoals,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FixturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FixturesTable,
      FixtureRow,
      $$FixturesTableFilterComposer,
      $$FixturesTableOrderingComposer,
      $$FixturesTableAnnotationComposer,
      $$FixturesTableCreateCompanionBuilder,
      $$FixturesTableUpdateCompanionBuilder,
      (FixtureRow, BaseReferences<_$AppDatabase, $FixturesTable, FixtureRow>),
      FixtureRow,
      PrefetchHooks Function()
    >;
typedef $$InboxMessagesTableCreateCompanionBuilder =
    InboxMessagesCompanion Function({
      Value<int> id,
      required DateTime date,
      required InboxCategory category,
      required String title,
      required String body,
      Value<bool> isRead,
      required InboxActionType actionType,
      Value<String?> payload,
      Value<bool> resolved,
      Value<String?> choice,
    });
typedef $$InboxMessagesTableUpdateCompanionBuilder =
    InboxMessagesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<InboxCategory> category,
      Value<String> title,
      Value<String> body,
      Value<bool> isRead,
      Value<InboxActionType> actionType,
      Value<String?> payload,
      Value<bool> resolved,
      Value<String?> choice,
    });

class $$InboxMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $InboxMessagesTable> {
  $$InboxMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<InboxCategory, InboxCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<InboxActionType, InboxActionType, String>
  get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get choice => $composableBuilder(
    column: $table.choice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InboxMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $InboxMessagesTable> {
  $$InboxMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get choice => $composableBuilder(
    column: $table.choice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InboxMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InboxMessagesTable> {
  $$InboxMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InboxCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InboxActionType, String> get actionType =>
      $composableBuilder(
        column: $table.actionType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<bool> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);

  GeneratedColumn<String> get choice =>
      $composableBuilder(column: $table.choice, builder: (column) => column);
}

class $$InboxMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InboxMessagesTable,
          InboxRow,
          $$InboxMessagesTableFilterComposer,
          $$InboxMessagesTableOrderingComposer,
          $$InboxMessagesTableAnnotationComposer,
          $$InboxMessagesTableCreateCompanionBuilder,
          $$InboxMessagesTableUpdateCompanionBuilder,
          (
            InboxRow,
            BaseReferences<_$AppDatabase, $InboxMessagesTable, InboxRow>,
          ),
          InboxRow,
          PrefetchHooks Function()
        > {
  $$InboxMessagesTableTableManager(_$AppDatabase db, $InboxMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$InboxMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$InboxMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$InboxMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<InboxCategory> category = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<InboxActionType> actionType = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<String?> choice = const Value.absent(),
              }) => InboxMessagesCompanion(
                id: id,
                date: date,
                category: category,
                title: title,
                body: body,
                isRead: isRead,
                actionType: actionType,
                payload: payload,
                resolved: resolved,
                choice: choice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required InboxCategory category,
                required String title,
                required String body,
                Value<bool> isRead = const Value.absent(),
                required InboxActionType actionType,
                Value<String?> payload = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<String?> choice = const Value.absent(),
              }) => InboxMessagesCompanion.insert(
                id: id,
                date: date,
                category: category,
                title: title,
                body: body,
                isRead: isRead,
                actionType: actionType,
                payload: payload,
                resolved: resolved,
                choice: choice,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InboxMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InboxMessagesTable,
      InboxRow,
      $$InboxMessagesTableFilterComposer,
      $$InboxMessagesTableOrderingComposer,
      $$InboxMessagesTableAnnotationComposer,
      $$InboxMessagesTableCreateCompanionBuilder,
      $$InboxMessagesTableUpdateCompanionBuilder,
      (InboxRow, BaseReferences<_$AppDatabase, $InboxMessagesTable, InboxRow>),
      InboxRow,
      PrefetchHooks Function()
    >;
typedef $$ClubTacticsTableCreateCompanionBuilder =
    ClubTacticsCompanion Function({
      required String clubId,
      required Formation formation,
      required Mentality mentality,
      Value<String> starterIds,
      Value<String> subIds,
      Value<int> rowid,
    });
typedef $$ClubTacticsTableUpdateCompanionBuilder =
    ClubTacticsCompanion Function({
      Value<String> clubId,
      Value<Formation> formation,
      Value<Mentality> mentality,
      Value<String> starterIds,
      Value<String> subIds,
      Value<int> rowid,
    });

class $$ClubTacticsTableFilterComposer
    extends Composer<_$AppDatabase, $ClubTacticsTable> {
  $$ClubTacticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Formation, Formation, String> get formation =>
      $composableBuilder(
        column: $table.formation,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Mentality, Mentality, String> get mentality =>
      $composableBuilder(
        column: $table.mentality,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get starterIds => $composableBuilder(
    column: $table.starterIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subIds => $composableBuilder(
    column: $table.subIds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClubTacticsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClubTacticsTable> {
  $$ClubTacticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formation => $composableBuilder(
    column: $table.formation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mentality => $composableBuilder(
    column: $table.mentality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get starterIds => $composableBuilder(
    column: $table.starterIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subIds => $composableBuilder(
    column: $table.subIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClubTacticsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClubTacticsTable> {
  $$ClubTacticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clubId =>
      $composableBuilder(column: $table.clubId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Formation, String> get formation =>
      $composableBuilder(column: $table.formation, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Mentality, String> get mentality =>
      $composableBuilder(column: $table.mentality, builder: (column) => column);

  GeneratedColumn<String> get starterIds => $composableBuilder(
    column: $table.starterIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subIds =>
      $composableBuilder(column: $table.subIds, builder: (column) => column);
}

class $$ClubTacticsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClubTacticsTable,
          ClubTacticRow,
          $$ClubTacticsTableFilterComposer,
          $$ClubTacticsTableOrderingComposer,
          $$ClubTacticsTableAnnotationComposer,
          $$ClubTacticsTableCreateCompanionBuilder,
          $$ClubTacticsTableUpdateCompanionBuilder,
          (
            ClubTacticRow,
            BaseReferences<_$AppDatabase, $ClubTacticsTable, ClubTacticRow>,
          ),
          ClubTacticRow,
          PrefetchHooks Function()
        > {
  $$ClubTacticsTableTableManager(_$AppDatabase db, $ClubTacticsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ClubTacticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ClubTacticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ClubTacticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clubId = const Value.absent(),
                Value<Formation> formation = const Value.absent(),
                Value<Mentality> mentality = const Value.absent(),
                Value<String> starterIds = const Value.absent(),
                Value<String> subIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClubTacticsCompanion(
                clubId: clubId,
                formation: formation,
                mentality: mentality,
                starterIds: starterIds,
                subIds: subIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clubId,
                required Formation formation,
                required Mentality mentality,
                Value<String> starterIds = const Value.absent(),
                Value<String> subIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClubTacticsCompanion.insert(
                clubId: clubId,
                formation: formation,
                mentality: mentality,
                starterIds: starterIds,
                subIds: subIds,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClubTacticsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClubTacticsTable,
      ClubTacticRow,
      $$ClubTacticsTableFilterComposer,
      $$ClubTacticsTableOrderingComposer,
      $$ClubTacticsTableAnnotationComposer,
      $$ClubTacticsTableCreateCompanionBuilder,
      $$ClubTacticsTableUpdateCompanionBuilder,
      (
        ClubTacticRow,
        BaseReferences<_$AppDatabase, $ClubTacticsTable, ClubTacticRow>,
      ),
      ClubTacticRow,
      PrefetchHooks Function()
    >;
typedef $$TransferOffersTableCreateCompanionBuilder =
    TransferOffersCompanion Function({
      Value<int> id,
      required int playerId,
      required String fromClubId,
      required String toClubId,
      required int fee,
      required TransferOfferStatus status,
      required DateTime createdDate,
      Value<DateTime?> responseDate,
      Value<int> installmentYears,
      Value<int> sellOnPct,
      Value<int> round,
      Value<DateTime?> expiresDate,
      Value<String?> reason,
      Value<String> kind,
    });
typedef $$TransferOffersTableUpdateCompanionBuilder =
    TransferOffersCompanion Function({
      Value<int> id,
      Value<int> playerId,
      Value<String> fromClubId,
      Value<String> toClubId,
      Value<int> fee,
      Value<TransferOfferStatus> status,
      Value<DateTime> createdDate,
      Value<DateTime?> responseDate,
      Value<int> installmentYears,
      Value<int> sellOnPct,
      Value<int> round,
      Value<DateTime?> expiresDate,
      Value<String?> reason,
      Value<String> kind,
    });

class $$TransferOffersTableFilterComposer
    extends Composer<_$AppDatabase, $TransferOffersTable> {
  $$TransferOffersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromClubId => $composableBuilder(
    column: $table.fromClubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toClubId => $composableBuilder(
    column: $table.toClubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TransferOfferStatus,
    TransferOfferStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get responseDate => $composableBuilder(
    column: $table.responseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentYears => $composableBuilder(
    column: $table.installmentYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellOnPct => $composableBuilder(
    column: $table.sellOnPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresDate => $composableBuilder(
    column: $table.expiresDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransferOffersTableOrderingComposer
    extends Composer<_$AppDatabase, $TransferOffersTable> {
  $$TransferOffersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromClubId => $composableBuilder(
    column: $table.fromClubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toClubId => $composableBuilder(
    column: $table.toClubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get responseDate => $composableBuilder(
    column: $table.responseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentYears => $composableBuilder(
    column: $table.installmentYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellOnPct => $composableBuilder(
    column: $table.sellOnPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresDate => $composableBuilder(
    column: $table.expiresDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransferOffersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransferOffersTable> {
  $$TransferOffersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get fromClubId => $composableBuilder(
    column: $table.fromClubId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toClubId =>
      $composableBuilder(column: $table.toClubId, builder: (column) => column);

  GeneratedColumn<int> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransferOfferStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
    column: $table.createdDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get responseDate => $composableBuilder(
    column: $table.responseDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentYears => $composableBuilder(
    column: $table.installmentYears,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellOnPct =>
      $composableBuilder(column: $table.sellOnPct, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresDate => $composableBuilder(
    column: $table.expiresDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);
}

class $$TransferOffersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransferOffersTable,
          TransferOfferRow,
          $$TransferOffersTableFilterComposer,
          $$TransferOffersTableOrderingComposer,
          $$TransferOffersTableAnnotationComposer,
          $$TransferOffersTableCreateCompanionBuilder,
          $$TransferOffersTableUpdateCompanionBuilder,
          (
            TransferOfferRow,
            BaseReferences<
              _$AppDatabase,
              $TransferOffersTable,
              TransferOfferRow
            >,
          ),
          TransferOfferRow,
          PrefetchHooks Function()
        > {
  $$TransferOffersTableTableManager(
    _$AppDatabase db,
    $TransferOffersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TransferOffersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$TransferOffersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TransferOffersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<String> fromClubId = const Value.absent(),
                Value<String> toClubId = const Value.absent(),
                Value<int> fee = const Value.absent(),
                Value<TransferOfferStatus> status = const Value.absent(),
                Value<DateTime> createdDate = const Value.absent(),
                Value<DateTime?> responseDate = const Value.absent(),
                Value<int> installmentYears = const Value.absent(),
                Value<int> sellOnPct = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<DateTime?> expiresDate = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => TransferOffersCompanion(
                id: id,
                playerId: playerId,
                fromClubId: fromClubId,
                toClubId: toClubId,
                fee: fee,
                status: status,
                createdDate: createdDate,
                responseDate: responseDate,
                installmentYears: installmentYears,
                sellOnPct: sellOnPct,
                round: round,
                expiresDate: expiresDate,
                reason: reason,
                kind: kind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playerId,
                required String fromClubId,
                required String toClubId,
                required int fee,
                required TransferOfferStatus status,
                required DateTime createdDate,
                Value<DateTime?> responseDate = const Value.absent(),
                Value<int> installmentYears = const Value.absent(),
                Value<int> sellOnPct = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<DateTime?> expiresDate = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => TransferOffersCompanion.insert(
                id: id,
                playerId: playerId,
                fromClubId: fromClubId,
                toClubId: toClubId,
                fee: fee,
                status: status,
                createdDate: createdDate,
                responseDate: responseDate,
                installmentYears: installmentYears,
                sellOnPct: sellOnPct,
                round: round,
                expiresDate: expiresDate,
                reason: reason,
                kind: kind,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransferOffersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransferOffersTable,
      TransferOfferRow,
      $$TransferOffersTableFilterComposer,
      $$TransferOffersTableOrderingComposer,
      $$TransferOffersTableAnnotationComposer,
      $$TransferOffersTableCreateCompanionBuilder,
      $$TransferOffersTableUpdateCompanionBuilder,
      (
        TransferOfferRow,
        BaseReferences<_$AppDatabase, $TransferOffersTable, TransferOfferRow>,
      ),
      TransferOfferRow,
      PrefetchHooks Function()
    >;
typedef $$TransferHistoryTableCreateCompanionBuilder =
    TransferHistoryCompanion Function({
      Value<int> id,
      required DateTime date,
      required int playerId,
      required String playerName,
      required String fromClubId,
      required String toClubId,
      required int fee,
      required TransferType type,
    });
typedef $$TransferHistoryTableUpdateCompanionBuilder =
    TransferHistoryCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> playerId,
      Value<String> playerName,
      Value<String> fromClubId,
      Value<String> toClubId,
      Value<int> fee,
      Value<TransferType> type,
    });

class $$TransferHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $TransferHistoryTable> {
  $$TransferHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromClubId => $composableBuilder(
    column: $table.fromClubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toClubId => $composableBuilder(
    column: $table.toClubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransferType, TransferType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$TransferHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $TransferHistoryTable> {
  $$TransferHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromClubId => $composableBuilder(
    column: $table.fromClubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toClubId => $composableBuilder(
    column: $table.toClubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransferHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransferHistoryTable> {
  $$TransferHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromClubId => $composableBuilder(
    column: $table.fromClubId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toClubId =>
      $composableBuilder(column: $table.toClubId, builder: (column) => column);

  GeneratedColumn<int> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransferType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$TransferHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransferHistoryTable,
          TransferHistoryRow,
          $$TransferHistoryTableFilterComposer,
          $$TransferHistoryTableOrderingComposer,
          $$TransferHistoryTableAnnotationComposer,
          $$TransferHistoryTableCreateCompanionBuilder,
          $$TransferHistoryTableUpdateCompanionBuilder,
          (
            TransferHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $TransferHistoryTable,
              TransferHistoryRow
            >,
          ),
          TransferHistoryRow,
          PrefetchHooks Function()
        > {
  $$TransferHistoryTableTableManager(
    _$AppDatabase db,
    $TransferHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$TransferHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TransferHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$TransferHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<String> playerName = const Value.absent(),
                Value<String> fromClubId = const Value.absent(),
                Value<String> toClubId = const Value.absent(),
                Value<int> fee = const Value.absent(),
                Value<TransferType> type = const Value.absent(),
              }) => TransferHistoryCompanion(
                id: id,
                date: date,
                playerId: playerId,
                playerName: playerName,
                fromClubId: fromClubId,
                toClubId: toClubId,
                fee: fee,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int playerId,
                required String playerName,
                required String fromClubId,
                required String toClubId,
                required int fee,
                required TransferType type,
              }) => TransferHistoryCompanion.insert(
                id: id,
                date: date,
                playerId: playerId,
                playerName: playerName,
                fromClubId: fromClubId,
                toClubId: toClubId,
                fee: fee,
                type: type,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransferHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransferHistoryTable,
      TransferHistoryRow,
      $$TransferHistoryTableFilterComposer,
      $$TransferHistoryTableOrderingComposer,
      $$TransferHistoryTableAnnotationComposer,
      $$TransferHistoryTableCreateCompanionBuilder,
      $$TransferHistoryTableUpdateCompanionBuilder,
      (
        TransferHistoryRow,
        BaseReferences<
          _$AppDatabase,
          $TransferHistoryTable,
          TransferHistoryRow
        >,
      ),
      TransferHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$ShortlistTableCreateCompanionBuilder =
    ShortlistCompanion Function({
      Value<int> playerId,
      required DateTime addedDate,
    });
typedef $$ShortlistTableUpdateCompanionBuilder =
    ShortlistCompanion Function({
      Value<int> playerId,
      Value<DateTime> addedDate,
    });

class $$ShortlistTableFilterComposer
    extends Composer<_$AppDatabase, $ShortlistTable> {
  $$ShortlistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShortlistTableOrderingComposer
    extends Composer<_$AppDatabase, $ShortlistTable> {
  $$ShortlistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShortlistTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShortlistTable> {
  $$ShortlistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);
}

class $$ShortlistTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShortlistTable,
          ShortlistRow,
          $$ShortlistTableFilterComposer,
          $$ShortlistTableOrderingComposer,
          $$ShortlistTableAnnotationComposer,
          $$ShortlistTableCreateCompanionBuilder,
          $$ShortlistTableUpdateCompanionBuilder,
          (
            ShortlistRow,
            BaseReferences<_$AppDatabase, $ShortlistTable, ShortlistRow>,
          ),
          ShortlistRow,
          PrefetchHooks Function()
        > {
  $$ShortlistTableTableManager(_$AppDatabase db, $ShortlistTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ShortlistTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ShortlistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ShortlistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> playerId = const Value.absent(),
                Value<DateTime> addedDate = const Value.absent(),
              }) =>
                  ShortlistCompanion(playerId: playerId, addedDate: addedDate),
          createCompanionCallback:
              ({
                Value<int> playerId = const Value.absent(),
                required DateTime addedDate,
              }) => ShortlistCompanion.insert(
                playerId: playerId,
                addedDate: addedDate,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShortlistTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShortlistTable,
      ShortlistRow,
      $$ShortlistTableFilterComposer,
      $$ShortlistTableOrderingComposer,
      $$ShortlistTableAnnotationComposer,
      $$ShortlistTableCreateCompanionBuilder,
      $$ShortlistTableUpdateCompanionBuilder,
      (
        ShortlistRow,
        BaseReferences<_$AppDatabase, $ShortlistTable, ShortlistRow>,
      ),
      ShortlistRow,
      PrefetchHooks Function()
    >;
typedef $$ClubAiProfilesTableCreateCompanionBuilder =
    ClubAiProfilesCompanion Function({
      required String clubId,
      required String personality,
      required int ambition,
      required int riskTolerance,
      required int negotiationSkill,
      required int sellingWillingness,
      required int youthFocus,
      Value<int> rowid,
    });
typedef $$ClubAiProfilesTableUpdateCompanionBuilder =
    ClubAiProfilesCompanion Function({
      Value<String> clubId,
      Value<String> personality,
      Value<int> ambition,
      Value<int> riskTolerance,
      Value<int> negotiationSkill,
      Value<int> sellingWillingness,
      Value<int> youthFocus,
      Value<int> rowid,
    });

class $$ClubAiProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ClubAiProfilesTable> {
  $$ClubAiProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ambition => $composableBuilder(
    column: $table.ambition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get riskTolerance => $composableBuilder(
    column: $table.riskTolerance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get negotiationSkill => $composableBuilder(
    column: $table.negotiationSkill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellingWillingness => $composableBuilder(
    column: $table.sellingWillingness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get youthFocus => $composableBuilder(
    column: $table.youthFocus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClubAiProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClubAiProfilesTable> {
  $$ClubAiProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ambition => $composableBuilder(
    column: $table.ambition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get riskTolerance => $composableBuilder(
    column: $table.riskTolerance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get negotiationSkill => $composableBuilder(
    column: $table.negotiationSkill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellingWillingness => $composableBuilder(
    column: $table.sellingWillingness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get youthFocus => $composableBuilder(
    column: $table.youthFocus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClubAiProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClubAiProfilesTable> {
  $$ClubAiProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clubId =>
      $composableBuilder(column: $table.clubId, builder: (column) => column);

  GeneratedColumn<String> get personality => $composableBuilder(
    column: $table.personality,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ambition =>
      $composableBuilder(column: $table.ambition, builder: (column) => column);

  GeneratedColumn<int> get riskTolerance => $composableBuilder(
    column: $table.riskTolerance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get negotiationSkill => $composableBuilder(
    column: $table.negotiationSkill,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellingWillingness => $composableBuilder(
    column: $table.sellingWillingness,
    builder: (column) => column,
  );

  GeneratedColumn<int> get youthFocus => $composableBuilder(
    column: $table.youthFocus,
    builder: (column) => column,
  );
}

class $$ClubAiProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClubAiProfilesTable,
          ClubAiProfileRow,
          $$ClubAiProfilesTableFilterComposer,
          $$ClubAiProfilesTableOrderingComposer,
          $$ClubAiProfilesTableAnnotationComposer,
          $$ClubAiProfilesTableCreateCompanionBuilder,
          $$ClubAiProfilesTableUpdateCompanionBuilder,
          (
            ClubAiProfileRow,
            BaseReferences<
              _$AppDatabase,
              $ClubAiProfilesTable,
              ClubAiProfileRow
            >,
          ),
          ClubAiProfileRow,
          PrefetchHooks Function()
        > {
  $$ClubAiProfilesTableTableManager(
    _$AppDatabase db,
    $ClubAiProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ClubAiProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ClubAiProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ClubAiProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clubId = const Value.absent(),
                Value<String> personality = const Value.absent(),
                Value<int> ambition = const Value.absent(),
                Value<int> riskTolerance = const Value.absent(),
                Value<int> negotiationSkill = const Value.absent(),
                Value<int> sellingWillingness = const Value.absent(),
                Value<int> youthFocus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClubAiProfilesCompanion(
                clubId: clubId,
                personality: personality,
                ambition: ambition,
                riskTolerance: riskTolerance,
                negotiationSkill: negotiationSkill,
                sellingWillingness: sellingWillingness,
                youthFocus: youthFocus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clubId,
                required String personality,
                required int ambition,
                required int riskTolerance,
                required int negotiationSkill,
                required int sellingWillingness,
                required int youthFocus,
                Value<int> rowid = const Value.absent(),
              }) => ClubAiProfilesCompanion.insert(
                clubId: clubId,
                personality: personality,
                ambition: ambition,
                riskTolerance: riskTolerance,
                negotiationSkill: negotiationSkill,
                sellingWillingness: sellingWillingness,
                youthFocus: youthFocus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClubAiProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClubAiProfilesTable,
      ClubAiProfileRow,
      $$ClubAiProfilesTableFilterComposer,
      $$ClubAiProfilesTableOrderingComposer,
      $$ClubAiProfilesTableAnnotationComposer,
      $$ClubAiProfilesTableCreateCompanionBuilder,
      $$ClubAiProfilesTableUpdateCompanionBuilder,
      (
        ClubAiProfileRow,
        BaseReferences<_$AppDatabase, $ClubAiProfilesTable, ClubAiProfileRow>,
      ),
      ClubAiProfileRow,
      PrefetchHooks Function()
    >;
typedef $$TransferInterestsTableCreateCompanionBuilder =
    TransferInterestsCompanion Function({
      required String clubId,
      required int playerId,
      required int score,
      required String level,
      required DateTime updatedDate,
      Value<int> rowid,
    });
typedef $$TransferInterestsTableUpdateCompanionBuilder =
    TransferInterestsCompanion Function({
      Value<String> clubId,
      Value<int> playerId,
      Value<int> score,
      Value<String> level,
      Value<DateTime> updatedDate,
      Value<int> rowid,
    });

class $$TransferInterestsTableFilterComposer
    extends Composer<_$AppDatabase, $TransferInterestsTable> {
  $$TransferInterestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransferInterestsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransferInterestsTable> {
  $$TransferInterestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransferInterestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransferInterestsTable> {
  $$TransferInterestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clubId =>
      $composableBuilder(column: $table.clubId, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => column,
  );
}

class $$TransferInterestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransferInterestsTable,
          TransferInterestRow,
          $$TransferInterestsTableFilterComposer,
          $$TransferInterestsTableOrderingComposer,
          $$TransferInterestsTableAnnotationComposer,
          $$TransferInterestsTableCreateCompanionBuilder,
          $$TransferInterestsTableUpdateCompanionBuilder,
          (
            TransferInterestRow,
            BaseReferences<
              _$AppDatabase,
              $TransferInterestsTable,
              TransferInterestRow
            >,
          ),
          TransferInterestRow,
          PrefetchHooks Function()
        > {
  $$TransferInterestsTableTableManager(
    _$AppDatabase db,
    $TransferInterestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TransferInterestsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$TransferInterestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$TransferInterestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clubId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<DateTime> updatedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransferInterestsCompanion(
                clubId: clubId,
                playerId: playerId,
                score: score,
                level: level,
                updatedDate: updatedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clubId,
                required int playerId,
                required int score,
                required String level,
                required DateTime updatedDate,
                Value<int> rowid = const Value.absent(),
              }) => TransferInterestsCompanion.insert(
                clubId: clubId,
                playerId: playerId,
                score: score,
                level: level,
                updatedDate: updatedDate,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransferInterestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransferInterestsTable,
      TransferInterestRow,
      $$TransferInterestsTableFilterComposer,
      $$TransferInterestsTableOrderingComposer,
      $$TransferInterestsTableAnnotationComposer,
      $$TransferInterestsTableCreateCompanionBuilder,
      $$TransferInterestsTableUpdateCompanionBuilder,
      (
        TransferInterestRow,
        BaseReferences<
          _$AppDatabase,
          $TransferInterestsTable,
          TransferInterestRow
        >,
      ),
      TransferInterestRow,
      PrefetchHooks Function()
    >;
typedef $$TransferNewsTableCreateCompanionBuilder =
    TransferNewsCompanion Function({
      Value<int> id,
      required DateTime date,
      required String kind,
      required String body,
      Value<String> clubIds,
    });
typedef $$TransferNewsTableUpdateCompanionBuilder =
    TransferNewsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> kind,
      Value<String> body,
      Value<String> clubIds,
    });

class $$TransferNewsTableFilterComposer
    extends Composer<_$AppDatabase, $TransferNewsTable> {
  $$TransferNewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubIds => $composableBuilder(
    column: $table.clubIds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransferNewsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransferNewsTable> {
  $$TransferNewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubIds => $composableBuilder(
    column: $table.clubIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransferNewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransferNewsTable> {
  $$TransferNewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get clubIds =>
      $composableBuilder(column: $table.clubIds, builder: (column) => column);
}

class $$TransferNewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransferNewsTable,
          TransferNewsRow,
          $$TransferNewsTableFilterComposer,
          $$TransferNewsTableOrderingComposer,
          $$TransferNewsTableAnnotationComposer,
          $$TransferNewsTableCreateCompanionBuilder,
          $$TransferNewsTableUpdateCompanionBuilder,
          (
            TransferNewsRow,
            BaseReferences<_$AppDatabase, $TransferNewsTable, TransferNewsRow>,
          ),
          TransferNewsRow,
          PrefetchHooks Function()
        > {
  $$TransferNewsTableTableManager(_$AppDatabase db, $TransferNewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TransferNewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TransferNewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$TransferNewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> clubIds = const Value.absent(),
              }) => TransferNewsCompanion(
                id: id,
                date: date,
                kind: kind,
                body: body,
                clubIds: clubIds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String kind,
                required String body,
                Value<String> clubIds = const Value.absent(),
              }) => TransferNewsCompanion.insert(
                id: id,
                date: date,
                kind: kind,
                body: body,
                clubIds: clubIds,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransferNewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransferNewsTable,
      TransferNewsRow,
      $$TransferNewsTableFilterComposer,
      $$TransferNewsTableOrderingComposer,
      $$TransferNewsTableAnnotationComposer,
      $$TransferNewsTableCreateCompanionBuilder,
      $$TransferNewsTableUpdateCompanionBuilder,
      (
        TransferNewsRow,
        BaseReferences<_$AppDatabase, $TransferNewsTable, TransferNewsRow>,
      ),
      TransferNewsRow,
      PrefetchHooks Function()
    >;
typedef $$MarketMemoryTableCreateCompanionBuilder =
    MarketMemoryCompanion Function({
      required String key,
      required int value,
      Value<int> rowid,
    });
typedef $$MarketMemoryTableUpdateCompanionBuilder =
    MarketMemoryCompanion Function({
      Value<String> key,
      Value<int> value,
      Value<int> rowid,
    });

class $$MarketMemoryTableFilterComposer
    extends Composer<_$AppDatabase, $MarketMemoryTable> {
  $$MarketMemoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarketMemoryTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketMemoryTable> {
  $$MarketMemoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarketMemoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketMemoryTable> {
  $$MarketMemoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MarketMemoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarketMemoryTable,
          MarketMemoryRow,
          $$MarketMemoryTableFilterComposer,
          $$MarketMemoryTableOrderingComposer,
          $$MarketMemoryTableAnnotationComposer,
          $$MarketMemoryTableCreateCompanionBuilder,
          $$MarketMemoryTableUpdateCompanionBuilder,
          (
            MarketMemoryRow,
            BaseReferences<_$AppDatabase, $MarketMemoryTable, MarketMemoryRow>,
          ),
          MarketMemoryRow,
          PrefetchHooks Function()
        > {
  $$MarketMemoryTableTableManager(_$AppDatabase db, $MarketMemoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MarketMemoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MarketMemoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$MarketMemoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketMemoryCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => MarketMemoryCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarketMemoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarketMemoryTable,
      MarketMemoryRow,
      $$MarketMemoryTableFilterComposer,
      $$MarketMemoryTableOrderingComposer,
      $$MarketMemoryTableAnnotationComposer,
      $$MarketMemoryTableCreateCompanionBuilder,
      $$MarketMemoryTableUpdateCompanionBuilder,
      (
        MarketMemoryRow,
        BaseReferences<_$AppDatabase, $MarketMemoryTable, MarketMemoryRow>,
      ),
      MarketMemoryRow,
      PrefetchHooks Function()
    >;
typedef $$SeasonsTableCreateCompanionBuilder =
    SeasonsCompanion Function({
      Value<int> startYear,
      required String label,
      required DateTime startDate,
      required DateTime endDate,
      required String status,
    });
typedef $$SeasonsTableUpdateCompanionBuilder =
    SeasonsCompanion Function({
      Value<int> startYear,
      Value<String> label,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String> status,
    });

class $$SeasonsTableFilterComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get startYear => $composableBuilder(
    column: $table.startYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeasonsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get startYear => $composableBuilder(
    column: $table.startYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeasonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeasonsTable> {
  $$SeasonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get startYear =>
      $composableBuilder(column: $table.startYear, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SeasonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeasonsTable,
          SeasonRow,
          $$SeasonsTableFilterComposer,
          $$SeasonsTableOrderingComposer,
          $$SeasonsTableAnnotationComposer,
          $$SeasonsTableCreateCompanionBuilder,
          $$SeasonsTableUpdateCompanionBuilder,
          (SeasonRow, BaseReferences<_$AppDatabase, $SeasonsTable, SeasonRow>),
          SeasonRow,
          PrefetchHooks Function()
        > {
  $$SeasonsTableTableManager(_$AppDatabase db, $SeasonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SeasonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SeasonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SeasonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> startYear = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SeasonsCompanion(
                startYear: startYear,
                label: label,
                startDate: startDate,
                endDate: endDate,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> startYear = const Value.absent(),
                required String label,
                required DateTime startDate,
                required DateTime endDate,
                required String status,
              }) => SeasonsCompanion.insert(
                startYear: startYear,
                label: label,
                startDate: startDate,
                endDate: endDate,
                status: status,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeasonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeasonsTable,
      SeasonRow,
      $$SeasonsTableFilterComposer,
      $$SeasonsTableOrderingComposer,
      $$SeasonsTableAnnotationComposer,
      $$SeasonsTableCreateCompanionBuilder,
      $$SeasonsTableUpdateCompanionBuilder,
      (SeasonRow, BaseReferences<_$AppDatabase, $SeasonsTable, SeasonRow>),
      SeasonRow,
      PrefetchHooks Function()
    >;
typedef $$SeasonArchiveTableCreateCompanionBuilder =
    SeasonArchiveCompanion Function({
      required int seasonStartYear,
      required String leagueId,
      required String clubId,
      required int position,
      required int played,
      required int won,
      required int drawn,
      required int lost,
      required int gf,
      required int ga,
      required int points,
      Value<int> rowid,
    });
typedef $$SeasonArchiveTableUpdateCompanionBuilder =
    SeasonArchiveCompanion Function({
      Value<int> seasonStartYear,
      Value<String> leagueId,
      Value<String> clubId,
      Value<int> position,
      Value<int> played,
      Value<int> won,
      Value<int> drawn,
      Value<int> lost,
      Value<int> gf,
      Value<int> ga,
      Value<int> points,
      Value<int> rowid,
    });

class $$SeasonArchiveTableFilterComposer
    extends Composer<_$AppDatabase, $SeasonArchiveTable> {
  $$SeasonArchiveTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leagueId => $composableBuilder(
    column: $table.leagueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get played => $composableBuilder(
    column: $table.played,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get won => $composableBuilder(
    column: $table.won,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get drawn => $composableBuilder(
    column: $table.drawn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lost => $composableBuilder(
    column: $table.lost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gf => $composableBuilder(
    column: $table.gf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ga => $composableBuilder(
    column: $table.ga,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeasonArchiveTableOrderingComposer
    extends Composer<_$AppDatabase, $SeasonArchiveTable> {
  $$SeasonArchiveTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leagueId => $composableBuilder(
    column: $table.leagueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get played => $composableBuilder(
    column: $table.played,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get won => $composableBuilder(
    column: $table.won,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get drawn => $composableBuilder(
    column: $table.drawn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lost => $composableBuilder(
    column: $table.lost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gf => $composableBuilder(
    column: $table.gf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ga => $composableBuilder(
    column: $table.ga,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeasonArchiveTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeasonArchiveTable> {
  $$SeasonArchiveTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leagueId =>
      $composableBuilder(column: $table.leagueId, builder: (column) => column);

  GeneratedColumn<String> get clubId =>
      $composableBuilder(column: $table.clubId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get played =>
      $composableBuilder(column: $table.played, builder: (column) => column);

  GeneratedColumn<int> get won =>
      $composableBuilder(column: $table.won, builder: (column) => column);

  GeneratedColumn<int> get drawn =>
      $composableBuilder(column: $table.drawn, builder: (column) => column);

  GeneratedColumn<int> get lost =>
      $composableBuilder(column: $table.lost, builder: (column) => column);

  GeneratedColumn<int> get gf =>
      $composableBuilder(column: $table.gf, builder: (column) => column);

  GeneratedColumn<int> get ga =>
      $composableBuilder(column: $table.ga, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);
}

class $$SeasonArchiveTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeasonArchiveTable,
          SeasonArchiveRow,
          $$SeasonArchiveTableFilterComposer,
          $$SeasonArchiveTableOrderingComposer,
          $$SeasonArchiveTableAnnotationComposer,
          $$SeasonArchiveTableCreateCompanionBuilder,
          $$SeasonArchiveTableUpdateCompanionBuilder,
          (
            SeasonArchiveRow,
            BaseReferences<
              _$AppDatabase,
              $SeasonArchiveTable,
              SeasonArchiveRow
            >,
          ),
          SeasonArchiveRow,
          PrefetchHooks Function()
        > {
  $$SeasonArchiveTableTableManager(_$AppDatabase db, $SeasonArchiveTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SeasonArchiveTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SeasonArchiveTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SeasonArchiveTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> seasonStartYear = const Value.absent(),
                Value<String> leagueId = const Value.absent(),
                Value<String> clubId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> played = const Value.absent(),
                Value<int> won = const Value.absent(),
                Value<int> drawn = const Value.absent(),
                Value<int> lost = const Value.absent(),
                Value<int> gf = const Value.absent(),
                Value<int> ga = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeasonArchiveCompanion(
                seasonStartYear: seasonStartYear,
                leagueId: leagueId,
                clubId: clubId,
                position: position,
                played: played,
                won: won,
                drawn: drawn,
                lost: lost,
                gf: gf,
                ga: ga,
                points: points,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int seasonStartYear,
                required String leagueId,
                required String clubId,
                required int position,
                required int played,
                required int won,
                required int drawn,
                required int lost,
                required int gf,
                required int ga,
                required int points,
                Value<int> rowid = const Value.absent(),
              }) => SeasonArchiveCompanion.insert(
                seasonStartYear: seasonStartYear,
                leagueId: leagueId,
                clubId: clubId,
                position: position,
                played: played,
                won: won,
                drawn: drawn,
                lost: lost,
                gf: gf,
                ga: ga,
                points: points,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeasonArchiveTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeasonArchiveTable,
      SeasonArchiveRow,
      $$SeasonArchiveTableFilterComposer,
      $$SeasonArchiveTableOrderingComposer,
      $$SeasonArchiveTableAnnotationComposer,
      $$SeasonArchiveTableCreateCompanionBuilder,
      $$SeasonArchiveTableUpdateCompanionBuilder,
      (
        SeasonArchiveRow,
        BaseReferences<_$AppDatabase, $SeasonArchiveTable, SeasonArchiveRow>,
      ),
      SeasonArchiveRow,
      PrefetchHooks Function()
    >;
typedef $$HonoursTableCreateCompanionBuilder =
    HonoursCompanion Function({
      Value<int> id,
      required int seasonStartYear,
      required String leagueId,
      required String type,
      required String clubId,
      Value<int?> playerId,
    });
typedef $$HonoursTableUpdateCompanionBuilder =
    HonoursCompanion Function({
      Value<int> id,
      Value<int> seasonStartYear,
      Value<String> leagueId,
      Value<String> type,
      Value<String> clubId,
      Value<int?> playerId,
    });

class $$HonoursTableFilterComposer
    extends Composer<_$AppDatabase, $HonoursTable> {
  $$HonoursTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leagueId => $composableBuilder(
    column: $table.leagueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HonoursTableOrderingComposer
    extends Composer<_$AppDatabase, $HonoursTable> {
  $$HonoursTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leagueId => $composableBuilder(
    column: $table.leagueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clubId => $composableBuilder(
    column: $table.clubId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HonoursTableAnnotationComposer
    extends Composer<_$AppDatabase, $HonoursTable> {
  $$HonoursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seasonStartYear => $composableBuilder(
    column: $table.seasonStartYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leagueId =>
      $composableBuilder(column: $table.leagueId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get clubId =>
      $composableBuilder(column: $table.clubId, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);
}

class $$HonoursTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HonoursTable,
          HonourRow,
          $$HonoursTableFilterComposer,
          $$HonoursTableOrderingComposer,
          $$HonoursTableAnnotationComposer,
          $$HonoursTableCreateCompanionBuilder,
          $$HonoursTableUpdateCompanionBuilder,
          (HonourRow, BaseReferences<_$AppDatabase, $HonoursTable, HonourRow>),
          HonourRow,
          PrefetchHooks Function()
        > {
  $$HonoursTableTableManager(_$AppDatabase db, $HonoursTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$HonoursTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$HonoursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$HonoursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> seasonStartYear = const Value.absent(),
                Value<String> leagueId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> clubId = const Value.absent(),
                Value<int?> playerId = const Value.absent(),
              }) => HonoursCompanion(
                id: id,
                seasonStartYear: seasonStartYear,
                leagueId: leagueId,
                type: type,
                clubId: clubId,
                playerId: playerId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int seasonStartYear,
                required String leagueId,
                required String type,
                required String clubId,
                Value<int?> playerId = const Value.absent(),
              }) => HonoursCompanion.insert(
                id: id,
                seasonStartYear: seasonStartYear,
                leagueId: leagueId,
                type: type,
                clubId: clubId,
                playerId: playerId,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HonoursTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HonoursTable,
      HonourRow,
      $$HonoursTableFilterComposer,
      $$HonoursTableOrderingComposer,
      $$HonoursTableAnnotationComposer,
      $$HonoursTableCreateCompanionBuilder,
      $$HonoursTableUpdateCompanionBuilder,
      (HonourRow, BaseReferences<_$AppDatabase, $HonoursTable, HonourRow>),
      HonourRow,
      PrefetchHooks Function()
    >;
typedef $$NegotiationSessionsTableCreateCompanionBuilder =
    NegotiationSessionsCompanion Function({
      required int offerId,
      required String mode,
      required int playerId,
      required String status,
      required int patience,
      required int anchorValue,
      required int limitValue,
      required String extras,
      required DateTime updatedDate,
      Value<DateTime?> cooldownUntil,
      Value<int> rowid,
    });
typedef $$NegotiationSessionsTableUpdateCompanionBuilder =
    NegotiationSessionsCompanion Function({
      Value<int> offerId,
      Value<String> mode,
      Value<int> playerId,
      Value<String> status,
      Value<int> patience,
      Value<int> anchorValue,
      Value<int> limitValue,
      Value<String> extras,
      Value<DateTime> updatedDate,
      Value<DateTime?> cooldownUntil,
      Value<int> rowid,
    });

class $$NegotiationSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $NegotiationSessionsTable> {
  $$NegotiationSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get offerId => $composableBuilder(
    column: $table.offerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get patience => $composableBuilder(
    column: $table.patience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorValue => $composableBuilder(
    column: $table.anchorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitValue => $composableBuilder(
    column: $table.limitValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extras => $composableBuilder(
    column: $table.extras,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cooldownUntil => $composableBuilder(
    column: $table.cooldownUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NegotiationSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $NegotiationSessionsTable> {
  $$NegotiationSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get offerId => $composableBuilder(
    column: $table.offerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get patience => $composableBuilder(
    column: $table.patience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorValue => $composableBuilder(
    column: $table.anchorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitValue => $composableBuilder(
    column: $table.limitValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extras => $composableBuilder(
    column: $table.extras,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cooldownUntil => $composableBuilder(
    column: $table.cooldownUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NegotiationSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NegotiationSessionsTable> {
  $$NegotiationSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get offerId =>
      $composableBuilder(column: $table.offerId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get patience =>
      $composableBuilder(column: $table.patience, builder: (column) => column);

  GeneratedColumn<int> get anchorValue => $composableBuilder(
    column: $table.anchorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limitValue => $composableBuilder(
    column: $table.limitValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extras =>
      $composableBuilder(column: $table.extras, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedDate => $composableBuilder(
    column: $table.updatedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cooldownUntil => $composableBuilder(
    column: $table.cooldownUntil,
    builder: (column) => column,
  );
}

class $$NegotiationSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NegotiationSessionsTable,
          NegotiationSessionRow,
          $$NegotiationSessionsTableFilterComposer,
          $$NegotiationSessionsTableOrderingComposer,
          $$NegotiationSessionsTableAnnotationComposer,
          $$NegotiationSessionsTableCreateCompanionBuilder,
          $$NegotiationSessionsTableUpdateCompanionBuilder,
          (
            NegotiationSessionRow,
            BaseReferences<
              _$AppDatabase,
              $NegotiationSessionsTable,
              NegotiationSessionRow
            >,
          ),
          NegotiationSessionRow,
          PrefetchHooks Function()
        > {
  $$NegotiationSessionsTableTableManager(
    _$AppDatabase db,
    $NegotiationSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$NegotiationSessionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$NegotiationSessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$NegotiationSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> offerId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> patience = const Value.absent(),
                Value<int> anchorValue = const Value.absent(),
                Value<int> limitValue = const Value.absent(),
                Value<String> extras = const Value.absent(),
                Value<DateTime> updatedDate = const Value.absent(),
                Value<DateTime?> cooldownUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NegotiationSessionsCompanion(
                offerId: offerId,
                mode: mode,
                playerId: playerId,
                status: status,
                patience: patience,
                anchorValue: anchorValue,
                limitValue: limitValue,
                extras: extras,
                updatedDate: updatedDate,
                cooldownUntil: cooldownUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int offerId,
                required String mode,
                required int playerId,
                required String status,
                required int patience,
                required int anchorValue,
                required int limitValue,
                required String extras,
                required DateTime updatedDate,
                Value<DateTime?> cooldownUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NegotiationSessionsCompanion.insert(
                offerId: offerId,
                mode: mode,
                playerId: playerId,
                status: status,
                patience: patience,
                anchorValue: anchorValue,
                limitValue: limitValue,
                extras: extras,
                updatedDate: updatedDate,
                cooldownUntil: cooldownUntil,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NegotiationSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NegotiationSessionsTable,
      NegotiationSessionRow,
      $$NegotiationSessionsTableFilterComposer,
      $$NegotiationSessionsTableOrderingComposer,
      $$NegotiationSessionsTableAnnotationComposer,
      $$NegotiationSessionsTableCreateCompanionBuilder,
      $$NegotiationSessionsTableUpdateCompanionBuilder,
      (
        NegotiationSessionRow,
        BaseReferences<
          _$AppDatabase,
          $NegotiationSessionsTable,
          NegotiationSessionRow
        >,
      ),
      NegotiationSessionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NationsTableTableManager get nations =>
      $$NationsTableTableManager(_db, _db.nations);
  $$LeaguesTableTableManager get leagues =>
      $$LeaguesTableTableManager(_db, _db.leagues);
  $$ClubsTableTableManager get clubs =>
      $$ClubsTableTableManager(_db, _db.clubs);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db, _db.contracts);
  $$GameStatesTableTableManager get gameStates =>
      $$GameStatesTableTableManager(_db, _db.gameStates);
  $$FixturesTableTableManager get fixtures =>
      $$FixturesTableTableManager(_db, _db.fixtures);
  $$InboxMessagesTableTableManager get inboxMessages =>
      $$InboxMessagesTableTableManager(_db, _db.inboxMessages);
  $$ClubTacticsTableTableManager get clubTactics =>
      $$ClubTacticsTableTableManager(_db, _db.clubTactics);
  $$TransferOffersTableTableManager get transferOffers =>
      $$TransferOffersTableTableManager(_db, _db.transferOffers);
  $$TransferHistoryTableTableManager get transferHistory =>
      $$TransferHistoryTableTableManager(_db, _db.transferHistory);
  $$ShortlistTableTableManager get shortlist =>
      $$ShortlistTableTableManager(_db, _db.shortlist);
  $$ClubAiProfilesTableTableManager get clubAiProfiles =>
      $$ClubAiProfilesTableTableManager(_db, _db.clubAiProfiles);
  $$TransferInterestsTableTableManager get transferInterests =>
      $$TransferInterestsTableTableManager(_db, _db.transferInterests);
  $$TransferNewsTableTableManager get transferNews =>
      $$TransferNewsTableTableManager(_db, _db.transferNews);
  $$MarketMemoryTableTableManager get marketMemory =>
      $$MarketMemoryTableTableManager(_db, _db.marketMemory);
  $$SeasonsTableTableManager get seasons =>
      $$SeasonsTableTableManager(_db, _db.seasons);
  $$SeasonArchiveTableTableManager get seasonArchive =>
      $$SeasonArchiveTableTableManager(_db, _db.seasonArchive);
  $$HonoursTableTableManager get honours =>
      $$HonoursTableTableManager(_db, _db.honours);
  $$NegotiationSessionsTableTableManager get negotiationSessions =>
      $$NegotiationSessionsTableTableManager(_db, _db.negotiationSessions);
}
