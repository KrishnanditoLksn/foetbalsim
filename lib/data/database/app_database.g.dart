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
          ..write('marketValue: $marketValue')
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
          other.marketValue == this.marketValue);
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
          ..write('marketValue: $marketValue')
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentDate,
    managerName,
    clubId,
    seed,
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
  const GameStateRow({
    required this.id,
    required this.currentDate,
    required this.managerName,
    this.clubId,
    required this.seed,
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
    };
  }

  GameStateRow copyWith({
    int? id,
    DateTime? currentDate,
    String? managerName,
    Value<String?> clubId = const Value.absent(),
    int? seed,
  }) => GameStateRow(
    id: id ?? this.id,
    currentDate: currentDate ?? this.currentDate,
    managerName: managerName ?? this.managerName,
    clubId: clubId.present ? clubId.value : this.clubId,
    seed: seed ?? this.seed,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameStateRow(')
          ..write('id: $id, ')
          ..write('currentDate: $currentDate, ')
          ..write('managerName: $managerName, ')
          ..write('clubId: $clubId, ')
          ..write('seed: $seed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, currentDate, managerName, clubId, seed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameStateRow &&
          other.id == this.id &&
          other.currentDate == this.currentDate &&
          other.managerName == this.managerName &&
          other.clubId == this.clubId &&
          other.seed == this.seed);
}

class GameStatesCompanion extends UpdateCompanion<GameStateRow> {
  final Value<int> id;
  final Value<DateTime> currentDate;
  final Value<String> managerName;
  final Value<String?> clubId;
  final Value<int> seed;
  const GameStatesCompanion({
    this.id = const Value.absent(),
    this.currentDate = const Value.absent(),
    this.managerName = const Value.absent(),
    this.clubId = const Value.absent(),
    this.seed = const Value.absent(),
  });
  GameStatesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime currentDate,
    required String managerName,
    this.clubId = const Value.absent(),
    required int seed,
  }) : currentDate = Value(currentDate),
       managerName = Value(managerName),
       seed = Value(seed);
  static Insertable<GameStateRow> custom({
    Expression<int>? id,
    Expression<DateTime>? currentDate,
    Expression<String>? managerName,
    Expression<String>? clubId,
    Expression<int>? seed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentDate != null) 'current_date': currentDate,
      if (managerName != null) 'manager_name': managerName,
      if (clubId != null) 'club_id': clubId,
      if (seed != null) 'seed': seed,
    });
  }

  GameStatesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? currentDate,
    Value<String>? managerName,
    Value<String?>? clubId,
    Value<int>? seed,
  }) {
    return GameStatesCompanion(
      id: id ?? this.id,
      currentDate: currentDate ?? this.currentDate,
      managerName: managerName ?? this.managerName,
      clubId: clubId ?? this.clubId,
      seed: seed ?? this.seed,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameStatesCompanion(')
          ..write('id: $id, ')
          ..write('currentDate: $currentDate, ')
          ..write('managerName: $managerName, ')
          ..write('clubId: $clubId, ')
          ..write('seed: $seed')
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
    });
typedef $$GameStatesTableUpdateCompanionBuilder =
    GameStatesCompanion Function({
      Value<int> id,
      Value<DateTime> currentDate,
      Value<String> managerName,
      Value<String?> clubId,
      Value<int> seed,
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
              }) => GameStatesCompanion(
                id: id,
                currentDate: currentDate,
                managerName: managerName,
                clubId: clubId,
                seed: seed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime currentDate,
                required String managerName,
                Value<String?> clubId = const Value.absent(),
                required int seed,
              }) => GameStatesCompanion.insert(
                id: id,
                currentDate: currentDate,
                managerName: managerName,
                clubId: clubId,
                seed: seed,
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
}
