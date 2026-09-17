// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    moduleId,
    entityId,
    operation,
    payload,
    createdAt,
    attempts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String id;
  final String moduleId;
  final String entityId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  const SyncOutboxData({
    required this.id,
    required this.moduleId,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.attempts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['module_id'] = Variable<String>(moduleId);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      moduleId: Value(moduleId),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'moduleId': serializer.toJson<String>(moduleId),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
    };
  }

  SyncOutboxData copyWith({
    String? id,
    String? moduleId,
    String? entityId,
    String? operation,
    String? payload,
    DateTime? createdAt,
    int? attempts,
  }) => SyncOutboxData(
    id: id ?? this.id,
    moduleId: moduleId ?? this.moduleId,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    moduleId,
    entityId,
    operation,
    payload,
    createdAt,
    attempts,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.moduleId == this.moduleId &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> moduleId;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String moduleId,
    required String entityId,
    required String operation,
    required String payload,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       moduleId = Value(moduleId),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? moduleId,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? moduleId,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkforceDepartmentsTable extends WorkforceDepartments
    with TableInfo<$WorkforceDepartmentsTable, WorkforceDepartment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkforceDepartmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
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
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, companyId, name, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workforce_departments';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkforceDepartment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkforceDepartment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkforceDepartment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $WorkforceDepartmentsTable createAlias(String alias) {
    return $WorkforceDepartmentsTable(attachedDatabase, alias);
  }
}

class WorkforceDepartment extends DataClass
    implements Insertable<WorkforceDepartment> {
  final String id;
  final String companyId;
  final String name;
  final bool active;
  const WorkforceDepartment({
    required this.id,
    required this.companyId,
    required this.name,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['active'] = Variable<bool>(active);
    return map;
  }

  WorkforceDepartmentsCompanion toCompanion(bool nullToAbsent) {
    return WorkforceDepartmentsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      active: Value(active),
    );
  }

  factory WorkforceDepartment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkforceDepartment(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'active': serializer.toJson<bool>(active),
    };
  }

  WorkforceDepartment copyWith({
    String? id,
    String? companyId,
    String? name,
    bool? active,
  }) => WorkforceDepartment(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    active: active ?? this.active,
  );
  WorkforceDepartment copyWithCompanion(WorkforceDepartmentsCompanion data) {
    return WorkforceDepartment(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceDepartment(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, companyId, name, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkforceDepartment &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.active == this.active);
}

class WorkforceDepartmentsCompanion
    extends UpdateCompanion<WorkforceDepartment> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<bool> active;
  final Value<int> rowid;
  const WorkforceDepartmentsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkforceDepartmentsCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name);
  static Insertable<WorkforceDepartment> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkforceDepartmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return WorkforceDepartmentsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceDepartmentsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkforceDesignationsTable extends WorkforceDesignations
    with TableInfo<$WorkforceDesignationsTable, WorkforceDesignation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkforceDesignationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
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
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, companyId, name, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workforce_designations';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkforceDesignation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkforceDesignation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkforceDesignation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $WorkforceDesignationsTable createAlias(String alias) {
    return $WorkforceDesignationsTable(attachedDatabase, alias);
  }
}

class WorkforceDesignation extends DataClass
    implements Insertable<WorkforceDesignation> {
  final String id;
  final String companyId;
  final String name;
  final bool active;
  const WorkforceDesignation({
    required this.id,
    required this.companyId,
    required this.name,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['active'] = Variable<bool>(active);
    return map;
  }

  WorkforceDesignationsCompanion toCompanion(bool nullToAbsent) {
    return WorkforceDesignationsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      active: Value(active),
    );
  }

  factory WorkforceDesignation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkforceDesignation(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'active': serializer.toJson<bool>(active),
    };
  }

  WorkforceDesignation copyWith({
    String? id,
    String? companyId,
    String? name,
    bool? active,
  }) => WorkforceDesignation(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    active: active ?? this.active,
  );
  WorkforceDesignation copyWithCompanion(WorkforceDesignationsCompanion data) {
    return WorkforceDesignation(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceDesignation(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, companyId, name, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkforceDesignation &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.active == this.active);
}

class WorkforceDesignationsCompanion
    extends UpdateCompanion<WorkforceDesignation> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<bool> active;
  final Value<int> rowid;
  const WorkforceDesignationsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkforceDesignationsCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name);
  static Insertable<WorkforceDesignation> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkforceDesignationsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return WorkforceDesignationsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceDesignationsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkforceAccountsTable extends WorkforceAccounts
    with TableInfo<$WorkforceAccountsTable, WorkforceAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkforceAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grantsMeta = const VerificationMeta('grants');
  @override
  late final GeneratedColumn<String> grants = GeneratedColumn<String>(
    'grants',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _credentialPendingMeta = const VerificationMeta(
    'credentialPending',
  );
  @override
  late final GeneratedColumn<bool> credentialPending = GeneratedColumn<bool>(
    'credential_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("credential_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    displayName,
    email,
    phone,
    role,
    grants,
    status,
    credentialPending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workforce_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkforceAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('grants')) {
      context.handle(
        _grantsMeta,
        grants.isAcceptableOrUnknown(data['grants']!, _grantsMeta),
      );
    } else if (isInserting) {
      context.missing(_grantsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('credential_pending')) {
      context.handle(
        _credentialPendingMeta,
        credentialPending.isAcceptableOrUnknown(
          data['credential_pending']!,
          _credentialPendingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, email},
    {companyId, phone},
  ];
  @override
  WorkforceAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkforceAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      grants: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grants'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      credentialPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}credential_pending'],
      )!,
    );
  }

  @override
  $WorkforceAccountsTable createAlias(String alias) {
    return $WorkforceAccountsTable(attachedDatabase, alias);
  }
}

class WorkforceAccount extends DataClass
    implements Insertable<WorkforceAccount> {
  final String id;
  final String companyId;
  final String displayName;
  final String email;
  final String phone;
  final String role;
  final String grants;
  final String status;
  final bool credentialPending;
  const WorkforceAccount({
    required this.id,
    required this.companyId,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.role,
    required this.grants,
    required this.status,
    required this.credentialPending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['display_name'] = Variable<String>(displayName);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    map['role'] = Variable<String>(role);
    map['grants'] = Variable<String>(grants);
    map['status'] = Variable<String>(status);
    map['credential_pending'] = Variable<bool>(credentialPending);
    return map;
  }

  WorkforceAccountsCompanion toCompanion(bool nullToAbsent) {
    return WorkforceAccountsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      displayName: Value(displayName),
      email: Value(email),
      phone: Value(phone),
      role: Value(role),
      grants: Value(grants),
      status: Value(status),
      credentialPending: Value(credentialPending),
    );
  }

  factory WorkforceAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkforceAccount(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      role: serializer.fromJson<String>(json['role']),
      grants: serializer.fromJson<String>(json['grants']),
      status: serializer.fromJson<String>(json['status']),
      credentialPending: serializer.fromJson<bool>(json['credentialPending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'role': serializer.toJson<String>(role),
      'grants': serializer.toJson<String>(grants),
      'status': serializer.toJson<String>(status),
      'credentialPending': serializer.toJson<bool>(credentialPending),
    };
  }

  WorkforceAccount copyWith({
    String? id,
    String? companyId,
    String? displayName,
    String? email,
    String? phone,
    String? role,
    String? grants,
    String? status,
    bool? credentialPending,
  }) => WorkforceAccount(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    grants: grants ?? this.grants,
    status: status ?? this.status,
    credentialPending: credentialPending ?? this.credentialPending,
  );
  WorkforceAccount copyWithCompanion(WorkforceAccountsCompanion data) {
    return WorkforceAccount(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      role: data.role.present ? data.role.value : this.role,
      grants: data.grants.present ? data.grants.value : this.grants,
      status: data.status.present ? data.status.value : this.status,
      credentialPending: data.credentialPending.present
          ? data.credentialPending.value
          : this.credentialPending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceAccount(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('grants: $grants, ')
          ..write('status: $status, ')
          ..write('credentialPending: $credentialPending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    displayName,
    email,
    phone,
    role,
    grants,
    status,
    credentialPending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkforceAccount &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.role == this.role &&
          other.grants == this.grants &&
          other.status == this.status &&
          other.credentialPending == this.credentialPending);
}

class WorkforceAccountsCompanion extends UpdateCompanion<WorkforceAccount> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> displayName;
  final Value<String> email;
  final Value<String> phone;
  final Value<String> role;
  final Value<String> grants;
  final Value<String> status;
  final Value<bool> credentialPending;
  final Value<int> rowid;
  const WorkforceAccountsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.grants = const Value.absent(),
    this.status = const Value.absent(),
    this.credentialPending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkforceAccountsCompanion.insert({
    required String id,
    required String companyId,
    required String displayName,
    required String email,
    required String phone,
    required String role,
    required String grants,
    required String status,
    this.credentialPending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       displayName = Value(displayName),
       email = Value(email),
       phone = Value(phone),
       role = Value(role),
       grants = Value(grants),
       status = Value(status);
  static Insertable<WorkforceAccount> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? role,
    Expression<String>? grants,
    Expression<String>? status,
    Expression<bool>? credentialPending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (grants != null) 'grants': grants,
      if (status != null) 'status': status,
      if (credentialPending != null) 'credential_pending': credentialPending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkforceAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? displayName,
    Value<String>? email,
    Value<String>? phone,
    Value<String>? role,
    Value<String>? grants,
    Value<String>? status,
    Value<bool>? credentialPending,
    Value<int>? rowid,
  }) {
    return WorkforceAccountsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      grants: grants ?? this.grants,
      status: status ?? this.status,
      credentialPending: credentialPending ?? this.credentialPending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (grants.present) {
      map['grants'] = Variable<String>(grants.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (credentialPending.present) {
      map['credential_pending'] = Variable<bool>(credentialPending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceAccountsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('grants: $grants, ')
          ..write('status: $status, ')
          ..write('credentialPending: $credentialPending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkforceEmployeesTable extends WorkforceEmployees
    with TableInfo<$WorkforceEmployeesTable, EmployeeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkforceEmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeCodeMeta = const VerificationMeta(
    'employeeCode',
  );
  @override
  late final GeneratedColumn<String> employeeCode = GeneratedColumn<String>(
    'employee_code',
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
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<String> departmentId = GeneratedColumn<String>(
    'department_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workforce_departments (id)',
    ),
  );
  static const VerificationMeta _designationIdMeta = const VerificationMeta(
    'designationId',
  );
  @override
  late final GeneratedColumn<String> designationId = GeneratedColumn<String>(
    'designation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workforce_designations (id)',
    ),
  );
  static const VerificationMeta _managerIdMeta = const VerificationMeta(
    'managerId',
  );
  @override
  late final GeneratedColumn<String> managerId = GeneratedColumn<String>(
    'manager_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workforce_employees (id)',
    ),
  );
  static const VerificationMeta _joiningDateMeta = const VerificationMeta(
    'joiningDate',
  );
  @override
  late final GeneratedColumn<DateTime> joiningDate = GeneratedColumn<DateTime>(
    'joining_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employmentTypeMeta = const VerificationMeta(
    'employmentType',
  );
  @override
  late final GeneratedColumn<String> employmentType = GeneratedColumn<String>(
    'employment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workLocationIdMeta = const VerificationMeta(
    'workLocationId',
  );
  @override
  late final GeneratedColumn<String> workLocationId = GeneratedColumn<String>(
    'work_location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attendancePolicyIdMeta =
      const VerificationMeta('attendancePolicyId');
  @override
  late final GeneratedColumn<String> attendancePolicyId =
      GeneratedColumn<String>(
        'attendance_policy_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _linkedUserIdMeta = const VerificationMeta(
    'linkedUserId',
  );
  @override
  late final GeneratedColumn<String> linkedUserId = GeneratedColumn<String>(
    'linked_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workforce_accounts (id)',
    ),
  );
  static const VerificationMeta _loginEnabledMeta = const VerificationMeta(
    'loginEnabled',
  );
  @override
  late final GeneratedColumn<bool> loginEnabled = GeneratedColumn<bool>(
    'login_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("login_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    employeeCode,
    firstName,
    middleName,
    lastName,
    email,
    phone,
    departmentId,
    designationId,
    managerId,
    joiningDate,
    employmentType,
    status,
    avatarUrl,
    shiftId,
    workLocationId,
    attendancePolicyId,
    linkedUserId,
    loginEnabled,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workforce_employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmployeeRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('employee_code')) {
      context.handle(
        _employeeCodeMeta,
        employeeCode.isAcceptableOrUnknown(
          data['employee_code']!,
          _employeeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeCodeMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departmentIdMeta);
    }
    if (data.containsKey('designation_id')) {
      context.handle(
        _designationIdMeta,
        designationId.isAcceptableOrUnknown(
          data['designation_id']!,
          _designationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_designationIdMeta);
    }
    if (data.containsKey('manager_id')) {
      context.handle(
        _managerIdMeta,
        managerId.isAcceptableOrUnknown(data['manager_id']!, _managerIdMeta),
      );
    }
    if (data.containsKey('joining_date')) {
      context.handle(
        _joiningDateMeta,
        joiningDate.isAcceptableOrUnknown(
          data['joining_date']!,
          _joiningDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_joiningDateMeta);
    }
    if (data.containsKey('employment_type')) {
      context.handle(
        _employmentTypeMeta,
        employmentType.isAcceptableOrUnknown(
          data['employment_type']!,
          _employmentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employmentTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    }
    if (data.containsKey('work_location_id')) {
      context.handle(
        _workLocationIdMeta,
        workLocationId.isAcceptableOrUnknown(
          data['work_location_id']!,
          _workLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('attendance_policy_id')) {
      context.handle(
        _attendancePolicyIdMeta,
        attendancePolicyId.isAcceptableOrUnknown(
          data['attendance_policy_id']!,
          _attendancePolicyIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_user_id')) {
      context.handle(
        _linkedUserIdMeta,
        linkedUserId.isAcceptableOrUnknown(
          data['linked_user_id']!,
          _linkedUserIdMeta,
        ),
      );
    }
    if (data.containsKey('login_enabled')) {
      context.handle(
        _loginEnabledMeta,
        loginEnabled.isAcceptableOrUnknown(
          data['login_enabled']!,
          _loginEnabledMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, employeeCode},
    {companyId, email},
    {companyId, phone},
    {linkedUserId},
  ];
  @override
  EmployeeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      employeeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_code'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}department_id'],
      )!,
      designationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designation_id'],
      )!,
      managerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manager_id'],
      ),
      joiningDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joining_date'],
      )!,
      employmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employment_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      ),
      workLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_location_id'],
      ),
      attendancePolicyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_policy_id'],
      ),
      linkedUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_user_id'],
      ),
      loginEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}login_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $WorkforceEmployeesTable createAlias(String alias) {
    return $WorkforceEmployeesTable(attachedDatabase, alias);
  }
}

class EmployeeRecord extends DataClass implements Insertable<EmployeeRecord> {
  final String id;
  final String companyId;
  final String employeeCode;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final String departmentId;
  final String designationId;
  final String? managerId;
  final DateTime joiningDate;
  final String employmentType;
  final String status;
  final String? avatarUrl;
  final String? shiftId;
  final String? workLocationId;
  final String? attendancePolicyId;
  final String? linkedUserId;
  final bool loginEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const EmployeeRecord({
    required this.id,
    required this.companyId,
    required this.employeeCode,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.departmentId,
    required this.designationId,
    this.managerId,
    required this.joiningDate,
    required this.employmentType,
    required this.status,
    this.avatarUrl,
    this.shiftId,
    this.workLocationId,
    this.attendancePolicyId,
    this.linkedUserId,
    required this.loginEnabled,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['employee_code'] = Variable<String>(employeeCode);
    map['first_name'] = Variable<String>(firstName);
    map['middle_name'] = Variable<String>(middleName);
    map['last_name'] = Variable<String>(lastName);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    map['department_id'] = Variable<String>(departmentId);
    map['designation_id'] = Variable<String>(designationId);
    if (!nullToAbsent || managerId != null) {
      map['manager_id'] = Variable<String>(managerId);
    }
    map['joining_date'] = Variable<DateTime>(joiningDate);
    map['employment_type'] = Variable<String>(employmentType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    if (!nullToAbsent || workLocationId != null) {
      map['work_location_id'] = Variable<String>(workLocationId);
    }
    if (!nullToAbsent || attendancePolicyId != null) {
      map['attendance_policy_id'] = Variable<String>(attendancePolicyId);
    }
    if (!nullToAbsent || linkedUserId != null) {
      map['linked_user_id'] = Variable<String>(linkedUserId);
    }
    map['login_enabled'] = Variable<bool>(loginEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  WorkforceEmployeesCompanion toCompanion(bool nullToAbsent) {
    return WorkforceEmployeesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      employeeCode: Value(employeeCode),
      firstName: Value(firstName),
      middleName: Value(middleName),
      lastName: Value(lastName),
      email: Value(email),
      phone: Value(phone),
      departmentId: Value(departmentId),
      designationId: Value(designationId),
      managerId: managerId == null && nullToAbsent
          ? const Value.absent()
          : Value(managerId),
      joiningDate: Value(joiningDate),
      employmentType: Value(employmentType),
      status: Value(status),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      workLocationId: workLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(workLocationId),
      attendancePolicyId: attendancePolicyId == null && nullToAbsent
          ? const Value.absent()
          : Value(attendancePolicyId),
      linkedUserId: linkedUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedUserId),
      loginEnabled: Value(loginEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory EmployeeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeRecord(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      employeeCode: serializer.fromJson<String>(json['employeeCode']),
      firstName: serializer.fromJson<String>(json['firstName']),
      middleName: serializer.fromJson<String>(json['middleName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      departmentId: serializer.fromJson<String>(json['departmentId']),
      designationId: serializer.fromJson<String>(json['designationId']),
      managerId: serializer.fromJson<String?>(json['managerId']),
      joiningDate: serializer.fromJson<DateTime>(json['joiningDate']),
      employmentType: serializer.fromJson<String>(json['employmentType']),
      status: serializer.fromJson<String>(json['status']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      workLocationId: serializer.fromJson<String?>(json['workLocationId']),
      attendancePolicyId: serializer.fromJson<String?>(
        json['attendancePolicyId'],
      ),
      linkedUserId: serializer.fromJson<String?>(json['linkedUserId']),
      loginEnabled: serializer.fromJson<bool>(json['loginEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'employeeCode': serializer.toJson<String>(employeeCode),
      'firstName': serializer.toJson<String>(firstName),
      'middleName': serializer.toJson<String>(middleName),
      'lastName': serializer.toJson<String>(lastName),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'departmentId': serializer.toJson<String>(departmentId),
      'designationId': serializer.toJson<String>(designationId),
      'managerId': serializer.toJson<String?>(managerId),
      'joiningDate': serializer.toJson<DateTime>(joiningDate),
      'employmentType': serializer.toJson<String>(employmentType),
      'status': serializer.toJson<String>(status),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'shiftId': serializer.toJson<String?>(shiftId),
      'workLocationId': serializer.toJson<String?>(workLocationId),
      'attendancePolicyId': serializer.toJson<String?>(attendancePolicyId),
      'linkedUserId': serializer.toJson<String?>(linkedUserId),
      'loginEnabled': serializer.toJson<bool>(loginEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  EmployeeRecord copyWith({
    String? id,
    String? companyId,
    String? employeeCode,
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? phone,
    String? departmentId,
    String? designationId,
    Value<String?> managerId = const Value.absent(),
    DateTime? joiningDate,
    String? employmentType,
    String? status,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> shiftId = const Value.absent(),
    Value<String?> workLocationId = const Value.absent(),
    Value<String?> attendancePolicyId = const Value.absent(),
    Value<String?> linkedUserId = const Value.absent(),
    bool? loginEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => EmployeeRecord(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    employeeCode: employeeCode ?? this.employeeCode,
    firstName: firstName ?? this.firstName,
    middleName: middleName ?? this.middleName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    departmentId: departmentId ?? this.departmentId,
    designationId: designationId ?? this.designationId,
    managerId: managerId.present ? managerId.value : this.managerId,
    joiningDate: joiningDate ?? this.joiningDate,
    employmentType: employmentType ?? this.employmentType,
    status: status ?? this.status,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    workLocationId: workLocationId.present
        ? workLocationId.value
        : this.workLocationId,
    attendancePolicyId: attendancePolicyId.present
        ? attendancePolicyId.value
        : this.attendancePolicyId,
    linkedUserId: linkedUserId.present ? linkedUserId.value : this.linkedUserId,
    loginEnabled: loginEnabled ?? this.loginEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  EmployeeRecord copyWithCompanion(WorkforceEmployeesCompanion data) {
    return EmployeeRecord(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      employeeCode: data.employeeCode.present
          ? data.employeeCode.value
          : this.employeeCode,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
      designationId: data.designationId.present
          ? data.designationId.value
          : this.designationId,
      managerId: data.managerId.present ? data.managerId.value : this.managerId,
      joiningDate: data.joiningDate.present
          ? data.joiningDate.value
          : this.joiningDate,
      employmentType: data.employmentType.present
          ? data.employmentType.value
          : this.employmentType,
      status: data.status.present ? data.status.value : this.status,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      workLocationId: data.workLocationId.present
          ? data.workLocationId.value
          : this.workLocationId,
      attendancePolicyId: data.attendancePolicyId.present
          ? data.attendancePolicyId.value
          : this.attendancePolicyId,
      linkedUserId: data.linkedUserId.present
          ? data.linkedUserId.value
          : this.linkedUserId,
      loginEnabled: data.loginEnabled.present
          ? data.loginEnabled.value
          : this.loginEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeRecord(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('departmentId: $departmentId, ')
          ..write('designationId: $designationId, ')
          ..write('managerId: $managerId, ')
          ..write('joiningDate: $joiningDate, ')
          ..write('employmentType: $employmentType, ')
          ..write('status: $status, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('shiftId: $shiftId, ')
          ..write('workLocationId: $workLocationId, ')
          ..write('attendancePolicyId: $attendancePolicyId, ')
          ..write('linkedUserId: $linkedUserId, ')
          ..write('loginEnabled: $loginEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    employeeCode,
    firstName,
    middleName,
    lastName,
    email,
    phone,
    departmentId,
    designationId,
    managerId,
    joiningDate,
    employmentType,
    status,
    avatarUrl,
    shiftId,
    workLocationId,
    attendancePolicyId,
    linkedUserId,
    loginEnabled,
    createdAt,
    updatedAt,
    syncStatus,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeRecord &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.employeeCode == this.employeeCode &&
          other.firstName == this.firstName &&
          other.middleName == this.middleName &&
          other.lastName == this.lastName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.departmentId == this.departmentId &&
          other.designationId == this.designationId &&
          other.managerId == this.managerId &&
          other.joiningDate == this.joiningDate &&
          other.employmentType == this.employmentType &&
          other.status == this.status &&
          other.avatarUrl == this.avatarUrl &&
          other.shiftId == this.shiftId &&
          other.workLocationId == this.workLocationId &&
          other.attendancePolicyId == this.attendancePolicyId &&
          other.linkedUserId == this.linkedUserId &&
          other.loginEnabled == this.loginEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class WorkforceEmployeesCompanion extends UpdateCompanion<EmployeeRecord> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> employeeCode;
  final Value<String> firstName;
  final Value<String> middleName;
  final Value<String> lastName;
  final Value<String> email;
  final Value<String> phone;
  final Value<String> departmentId;
  final Value<String> designationId;
  final Value<String?> managerId;
  final Value<DateTime> joiningDate;
  final Value<String> employmentType;
  final Value<String> status;
  final Value<String?> avatarUrl;
  final Value<String?> shiftId;
  final Value<String?> workLocationId;
  final Value<String?> attendancePolicyId;
  final Value<String?> linkedUserId;
  final Value<bool> loginEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const WorkforceEmployeesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.employeeCode = const Value.absent(),
    this.firstName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.designationId = const Value.absent(),
    this.managerId = const Value.absent(),
    this.joiningDate = const Value.absent(),
    this.employmentType = const Value.absent(),
    this.status = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.workLocationId = const Value.absent(),
    this.attendancePolicyId = const Value.absent(),
    this.linkedUserId = const Value.absent(),
    this.loginEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkforceEmployeesCompanion.insert({
    required String id,
    required String companyId,
    required String employeeCode,
    required String firstName,
    this.middleName = const Value.absent(),
    this.lastName = const Value.absent(),
    required String email,
    required String phone,
    required String departmentId,
    required String designationId,
    this.managerId = const Value.absent(),
    required DateTime joiningDate,
    required String employmentType,
    required String status,
    this.avatarUrl = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.workLocationId = const Value.absent(),
    this.attendancePolicyId = const Value.absent(),
    this.linkedUserId = const Value.absent(),
    this.loginEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       employeeCode = Value(employeeCode),
       firstName = Value(firstName),
       email = Value(email),
       phone = Value(phone),
       departmentId = Value(departmentId),
       designationId = Value(designationId),
       joiningDate = Value(joiningDate),
       employmentType = Value(employmentType),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<EmployeeRecord> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? employeeCode,
    Expression<String>? firstName,
    Expression<String>? middleName,
    Expression<String>? lastName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? departmentId,
    Expression<String>? designationId,
    Expression<String>? managerId,
    Expression<DateTime>? joiningDate,
    Expression<String>? employmentType,
    Expression<String>? status,
    Expression<String>? avatarUrl,
    Expression<String>? shiftId,
    Expression<String>? workLocationId,
    Expression<String>? attendancePolicyId,
    Expression<String>? linkedUserId,
    Expression<bool>? loginEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (employeeCode != null) 'employee_code': employeeCode,
      if (firstName != null) 'first_name': firstName,
      if (middleName != null) 'middle_name': middleName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (departmentId != null) 'department_id': departmentId,
      if (designationId != null) 'designation_id': designationId,
      if (managerId != null) 'manager_id': managerId,
      if (joiningDate != null) 'joining_date': joiningDate,
      if (employmentType != null) 'employment_type': employmentType,
      if (status != null) 'status': status,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (shiftId != null) 'shift_id': shiftId,
      if (workLocationId != null) 'work_location_id': workLocationId,
      if (attendancePolicyId != null)
        'attendance_policy_id': attendancePolicyId,
      if (linkedUserId != null) 'linked_user_id': linkedUserId,
      if (loginEnabled != null) 'login_enabled': loginEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkforceEmployeesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? employeeCode,
    Value<String>? firstName,
    Value<String>? middleName,
    Value<String>? lastName,
    Value<String>? email,
    Value<String>? phone,
    Value<String>? departmentId,
    Value<String>? designationId,
    Value<String?>? managerId,
    Value<DateTime>? joiningDate,
    Value<String>? employmentType,
    Value<String>? status,
    Value<String?>? avatarUrl,
    Value<String?>? shiftId,
    Value<String?>? workLocationId,
    Value<String?>? attendancePolicyId,
    Value<String?>? linkedUserId,
    Value<bool>? loginEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return WorkforceEmployeesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      employeeCode: employeeCode ?? this.employeeCode,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      departmentId: departmentId ?? this.departmentId,
      designationId: designationId ?? this.designationId,
      managerId: managerId ?? this.managerId,
      joiningDate: joiningDate ?? this.joiningDate,
      employmentType: employmentType ?? this.employmentType,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      shiftId: shiftId ?? this.shiftId,
      workLocationId: workLocationId ?? this.workLocationId,
      attendancePolicyId: attendancePolicyId ?? this.attendancePolicyId,
      linkedUserId: linkedUserId ?? this.linkedUserId,
      loginEnabled: loginEnabled ?? this.loginEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (employeeCode.present) {
      map['employee_code'] = Variable<String>(employeeCode.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<String>(departmentId.value);
    }
    if (designationId.present) {
      map['designation_id'] = Variable<String>(designationId.value);
    }
    if (managerId.present) {
      map['manager_id'] = Variable<String>(managerId.value);
    }
    if (joiningDate.present) {
      map['joining_date'] = Variable<DateTime>(joiningDate.value);
    }
    if (employmentType.present) {
      map['employment_type'] = Variable<String>(employmentType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (workLocationId.present) {
      map['work_location_id'] = Variable<String>(workLocationId.value);
    }
    if (attendancePolicyId.present) {
      map['attendance_policy_id'] = Variable<String>(attendancePolicyId.value);
    }
    if (linkedUserId.present) {
      map['linked_user_id'] = Variable<String>(linkedUserId.value);
    }
    if (loginEnabled.present) {
      map['login_enabled'] = Variable<bool>(loginEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceEmployeesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('employeeCode: $employeeCode, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('departmentId: $departmentId, ')
          ..write('designationId: $designationId, ')
          ..write('managerId: $managerId, ')
          ..write('joiningDate: $joiningDate, ')
          ..write('employmentType: $employmentType, ')
          ..write('status: $status, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('shiftId: $shiftId, ')
          ..write('workLocationId: $workLocationId, ')
          ..write('attendancePolicyId: $attendancePolicyId, ')
          ..write('linkedUserId: $linkedUserId, ')
          ..write('loginEnabled: $loginEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkforceSeedsTable extends WorkforceSeeds
    with TableInfo<$WorkforceSeedsTable, WorkforceSeed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkforceSeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [companyId, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workforce_seeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkforceSeed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {companyId};
  @override
  WorkforceSeed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkforceSeed(
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $WorkforceSeedsTable createAlias(String alias) {
    return $WorkforceSeedsTable(attachedDatabase, alias);
  }
}

class WorkforceSeed extends DataClass implements Insertable<WorkforceSeed> {
  final String companyId;
  final int version;
  const WorkforceSeed({required this.companyId, required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['company_id'] = Variable<String>(companyId);
    map['version'] = Variable<int>(version);
    return map;
  }

  WorkforceSeedsCompanion toCompanion(bool nullToAbsent) {
    return WorkforceSeedsCompanion(
      companyId: Value(companyId),
      version: Value(version),
    );
  }

  factory WorkforceSeed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkforceSeed(
      companyId: serializer.fromJson<String>(json['companyId']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'companyId': serializer.toJson<String>(companyId),
      'version': serializer.toJson<int>(version),
    };
  }

  WorkforceSeed copyWith({String? companyId, int? version}) => WorkforceSeed(
    companyId: companyId ?? this.companyId,
    version: version ?? this.version,
  );
  WorkforceSeed copyWithCompanion(WorkforceSeedsCompanion data) {
    return WorkforceSeed(
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceSeed(')
          ..write('companyId: $companyId, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(companyId, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkforceSeed &&
          other.companyId == this.companyId &&
          other.version == this.version);
}

class WorkforceSeedsCompanion extends UpdateCompanion<WorkforceSeed> {
  final Value<String> companyId;
  final Value<int> version;
  final Value<int> rowid;
  const WorkforceSeedsCompanion({
    this.companyId = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkforceSeedsCompanion.insert({
    required String companyId,
    required int version,
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       version = Value(version);
  static Insertable<WorkforceSeed> custom({
    Expression<String>? companyId,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (companyId != null) 'company_id': companyId,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkforceSeedsCompanion copyWith({
    Value<String>? companyId,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return WorkforceSeedsCompanion(
      companyId: companyId ?? this.companyId,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkforceSeedsCompanion(')
          ..write('companyId: $companyId, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $WorkforceDepartmentsTable workforceDepartments =
      $WorkforceDepartmentsTable(this);
  late final $WorkforceDesignationsTable workforceDesignations =
      $WorkforceDesignationsTable(this);
  late final $WorkforceAccountsTable workforceAccounts =
      $WorkforceAccountsTable(this);
  late final $WorkforceEmployeesTable workforceEmployees =
      $WorkforceEmployeesTable(this);
  late final $WorkforceSeedsTable workforceSeeds = $WorkforceSeedsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncOutbox,
    workforceDepartments,
    workforceDesignations,
    workforceAccounts,
    workforceEmployees,
    workforceSeeds,
  ];
}

typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String id,
      required String moduleId,
      required String entityId,
      required String operation,
      required String payload,
      required DateTime createdAt,
      Value<int> attempts,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> id,
      Value<String> moduleId,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
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

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                moduleId: moduleId,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String moduleId,
                required String entityId,
                required String operation,
                required String payload,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                moduleId: moduleId,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$WorkforceDepartmentsTableCreateCompanionBuilder =
    WorkforceDepartmentsCompanion Function({
      required String id,
      required String companyId,
      required String name,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$WorkforceDepartmentsTableUpdateCompanionBuilder =
    WorkforceDepartmentsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<bool> active,
      Value<int> rowid,
    });

final class $$WorkforceDepartmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkforceDepartmentsTable,
          WorkforceDepartment
        > {
  $$WorkforceDepartmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WorkforceEmployeesTable, List<EmployeeRecord>>
  _workforceEmployeesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workforceEmployees,
        aliasName: $_aliasNameGenerator(
          db.workforceDepartments.id,
          db.workforceEmployees.departmentId,
        ),
      );

  $$WorkforceEmployeesTableProcessedTableManager get workforceEmployeesRefs {
    final manager = $$WorkforceEmployeesTableTableManager(
      $_db,
      $_db.workforceEmployees,
    ).filter((f) => f.departmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workforceEmployeesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkforceDepartmentsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkforceDepartmentsTable> {
  $$WorkforceDepartmentsTableFilterComposer({
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

  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workforceEmployeesRefs(
    Expression<bool> Function($$WorkforceEmployeesTableFilterComposer f) f,
  ) {
    final $$WorkforceEmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workforceEmployees,
      getReferencedColumn: (t) => t.departmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkforceEmployeesTableFilterComposer(
            $db: $db,
            $table: $db.workforceEmployees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkforceDepartmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkforceDepartmentsTable> {
  $$WorkforceDepartmentsTableOrderingComposer({
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

  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkforceDepartmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkforceDepartmentsTable> {
  $$WorkforceDepartmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> workforceEmployeesRefs<T extends Object>(
    Expression<T> Function($$WorkforceEmployeesTableAnnotationComposer a) f,
  ) {
    final $$WorkforceEmployeesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workforceEmployees,
          getReferencedColumn: (t) => t.departmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceEmployeesTableAnnotationComposer(
                $db: $db,
                $table: $db.workforceEmployees,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkforceDepartmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkforceDepartmentsTable,
          WorkforceDepartment,
          $$WorkforceDepartmentsTableFilterComposer,
          $$WorkforceDepartmentsTableOrderingComposer,
          $$WorkforceDepartmentsTableAnnotationComposer,
          $$WorkforceDepartmentsTableCreateCompanionBuilder,
          $$WorkforceDepartmentsTableUpdateCompanionBuilder,
          (WorkforceDepartment, $$WorkforceDepartmentsTableReferences),
          WorkforceDepartment,
          PrefetchHooks Function({bool workforceEmployeesRefs})
        > {
  $$WorkforceDepartmentsTableTableManager(
    _$AppDatabase db,
    $WorkforceDepartmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkforceDepartmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkforceDepartmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkforceDepartmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkforceDepartmentsCompanion(
                id: id,
                companyId: companyId,
                name: name,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkforceDepartmentsCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkforceDepartmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workforceEmployeesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workforceEmployeesRefs) db.workforceEmployees,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workforceEmployeesRefs)
                    await $_getPrefetchedData<
                      WorkforceDepartment,
                      $WorkforceDepartmentsTable,
                      EmployeeRecord
                    >(
                      currentTable: table,
                      referencedTable: $$WorkforceDepartmentsTableReferences
                          ._workforceEmployeesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkforceDepartmentsTableReferences(
                            db,
                            table,
                            p0,
                          ).workforceEmployeesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.departmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkforceDepartmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkforceDepartmentsTable,
      WorkforceDepartment,
      $$WorkforceDepartmentsTableFilterComposer,
      $$WorkforceDepartmentsTableOrderingComposer,
      $$WorkforceDepartmentsTableAnnotationComposer,
      $$WorkforceDepartmentsTableCreateCompanionBuilder,
      $$WorkforceDepartmentsTableUpdateCompanionBuilder,
      (WorkforceDepartment, $$WorkforceDepartmentsTableReferences),
      WorkforceDepartment,
      PrefetchHooks Function({bool workforceEmployeesRefs})
    >;
typedef $$WorkforceDesignationsTableCreateCompanionBuilder =
    WorkforceDesignationsCompanion Function({
      required String id,
      required String companyId,
      required String name,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$WorkforceDesignationsTableUpdateCompanionBuilder =
    WorkforceDesignationsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<bool> active,
      Value<int> rowid,
    });

final class $$WorkforceDesignationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkforceDesignationsTable,
          WorkforceDesignation
        > {
  $$WorkforceDesignationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WorkforceEmployeesTable, List<EmployeeRecord>>
  _workforceEmployeesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workforceEmployees,
        aliasName: $_aliasNameGenerator(
          db.workforceDesignations.id,
          db.workforceEmployees.designationId,
        ),
      );

  $$WorkforceEmployeesTableProcessedTableManager get workforceEmployeesRefs {
    final manager = $$WorkforceEmployeesTableTableManager(
      $_db,
      $_db.workforceEmployees,
    ).filter((f) => f.designationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workforceEmployeesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkforceDesignationsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkforceDesignationsTable> {
  $$WorkforceDesignationsTableFilterComposer({
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

  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workforceEmployeesRefs(
    Expression<bool> Function($$WorkforceEmployeesTableFilterComposer f) f,
  ) {
    final $$WorkforceEmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workforceEmployees,
      getReferencedColumn: (t) => t.designationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkforceEmployeesTableFilterComposer(
            $db: $db,
            $table: $db.workforceEmployees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkforceDesignationsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkforceDesignationsTable> {
  $$WorkforceDesignationsTableOrderingComposer({
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

  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkforceDesignationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkforceDesignationsTable> {
  $$WorkforceDesignationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> workforceEmployeesRefs<T extends Object>(
    Expression<T> Function($$WorkforceEmployeesTableAnnotationComposer a) f,
  ) {
    final $$WorkforceEmployeesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workforceEmployees,
          getReferencedColumn: (t) => t.designationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceEmployeesTableAnnotationComposer(
                $db: $db,
                $table: $db.workforceEmployees,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkforceDesignationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkforceDesignationsTable,
          WorkforceDesignation,
          $$WorkforceDesignationsTableFilterComposer,
          $$WorkforceDesignationsTableOrderingComposer,
          $$WorkforceDesignationsTableAnnotationComposer,
          $$WorkforceDesignationsTableCreateCompanionBuilder,
          $$WorkforceDesignationsTableUpdateCompanionBuilder,
          (WorkforceDesignation, $$WorkforceDesignationsTableReferences),
          WorkforceDesignation,
          PrefetchHooks Function({bool workforceEmployeesRefs})
        > {
  $$WorkforceDesignationsTableTableManager(
    _$AppDatabase db,
    $WorkforceDesignationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkforceDesignationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WorkforceDesignationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkforceDesignationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkforceDesignationsCompanion(
                id: id,
                companyId: companyId,
                name: name,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkforceDesignationsCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkforceDesignationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workforceEmployeesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workforceEmployeesRefs) db.workforceEmployees,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workforceEmployeesRefs)
                    await $_getPrefetchedData<
                      WorkforceDesignation,
                      $WorkforceDesignationsTable,
                      EmployeeRecord
                    >(
                      currentTable: table,
                      referencedTable: $$WorkforceDesignationsTableReferences
                          ._workforceEmployeesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkforceDesignationsTableReferences(
                            db,
                            table,
                            p0,
                          ).workforceEmployeesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.designationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkforceDesignationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkforceDesignationsTable,
      WorkforceDesignation,
      $$WorkforceDesignationsTableFilterComposer,
      $$WorkforceDesignationsTableOrderingComposer,
      $$WorkforceDesignationsTableAnnotationComposer,
      $$WorkforceDesignationsTableCreateCompanionBuilder,
      $$WorkforceDesignationsTableUpdateCompanionBuilder,
      (WorkforceDesignation, $$WorkforceDesignationsTableReferences),
      WorkforceDesignation,
      PrefetchHooks Function({bool workforceEmployeesRefs})
    >;
typedef $$WorkforceAccountsTableCreateCompanionBuilder =
    WorkforceAccountsCompanion Function({
      required String id,
      required String companyId,
      required String displayName,
      required String email,
      required String phone,
      required String role,
      required String grants,
      required String status,
      Value<bool> credentialPending,
      Value<int> rowid,
    });
typedef $$WorkforceAccountsTableUpdateCompanionBuilder =
    WorkforceAccountsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> displayName,
      Value<String> email,
      Value<String> phone,
      Value<String> role,
      Value<String> grants,
      Value<String> status,
      Value<bool> credentialPending,
      Value<int> rowid,
    });

final class $$WorkforceAccountsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkforceAccountsTable,
          WorkforceAccount
        > {
  $$WorkforceAccountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WorkforceEmployeesTable, List<EmployeeRecord>>
  _workforceEmployeesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workforceEmployees,
        aliasName: $_aliasNameGenerator(
          db.workforceAccounts.id,
          db.workforceEmployees.linkedUserId,
        ),
      );

  $$WorkforceEmployeesTableProcessedTableManager get workforceEmployeesRefs {
    final manager = $$WorkforceEmployeesTableTableManager(
      $_db,
      $_db.workforceEmployees,
    ).filter((f) => f.linkedUserId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workforceEmployeesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkforceAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkforceAccountsTable> {
  $$WorkforceAccountsTableFilterComposer({
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

  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grants => $composableBuilder(
    column: $table.grants,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get credentialPending => $composableBuilder(
    column: $table.credentialPending,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workforceEmployeesRefs(
    Expression<bool> Function($$WorkforceEmployeesTableFilterComposer f) f,
  ) {
    final $$WorkforceEmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workforceEmployees,
      getReferencedColumn: (t) => t.linkedUserId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkforceEmployeesTableFilterComposer(
            $db: $db,
            $table: $db.workforceEmployees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkforceAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkforceAccountsTable> {
  $$WorkforceAccountsTableOrderingComposer({
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

  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grants => $composableBuilder(
    column: $table.grants,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get credentialPending => $composableBuilder(
    column: $table.credentialPending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkforceAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkforceAccountsTable> {
  $$WorkforceAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get grants =>
      $composableBuilder(column: $table.grants, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get credentialPending => $composableBuilder(
    column: $table.credentialPending,
    builder: (column) => column,
  );

  Expression<T> workforceEmployeesRefs<T extends Object>(
    Expression<T> Function($$WorkforceEmployeesTableAnnotationComposer a) f,
  ) {
    final $$WorkforceEmployeesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workforceEmployees,
          getReferencedColumn: (t) => t.linkedUserId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceEmployeesTableAnnotationComposer(
                $db: $db,
                $table: $db.workforceEmployees,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkforceAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkforceAccountsTable,
          WorkforceAccount,
          $$WorkforceAccountsTableFilterComposer,
          $$WorkforceAccountsTableOrderingComposer,
          $$WorkforceAccountsTableAnnotationComposer,
          $$WorkforceAccountsTableCreateCompanionBuilder,
          $$WorkforceAccountsTableUpdateCompanionBuilder,
          (WorkforceAccount, $$WorkforceAccountsTableReferences),
          WorkforceAccount,
          PrefetchHooks Function({bool workforceEmployeesRefs})
        > {
  $$WorkforceAccountsTableTableManager(
    _$AppDatabase db,
    $WorkforceAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkforceAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkforceAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkforceAccountsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> grants = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> credentialPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkforceAccountsCompanion(
                id: id,
                companyId: companyId,
                displayName: displayName,
                email: email,
                phone: phone,
                role: role,
                grants: grants,
                status: status,
                credentialPending: credentialPending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String displayName,
                required String email,
                required String phone,
                required String role,
                required String grants,
                required String status,
                Value<bool> credentialPending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkforceAccountsCompanion.insert(
                id: id,
                companyId: companyId,
                displayName: displayName,
                email: email,
                phone: phone,
                role: role,
                grants: grants,
                status: status,
                credentialPending: credentialPending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkforceAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workforceEmployeesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workforceEmployeesRefs) db.workforceEmployees,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workforceEmployeesRefs)
                    await $_getPrefetchedData<
                      WorkforceAccount,
                      $WorkforceAccountsTable,
                      EmployeeRecord
                    >(
                      currentTable: table,
                      referencedTable: $$WorkforceAccountsTableReferences
                          ._workforceEmployeesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkforceAccountsTableReferences(
                            db,
                            table,
                            p0,
                          ).workforceEmployeesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.linkedUserId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkforceAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkforceAccountsTable,
      WorkforceAccount,
      $$WorkforceAccountsTableFilterComposer,
      $$WorkforceAccountsTableOrderingComposer,
      $$WorkforceAccountsTableAnnotationComposer,
      $$WorkforceAccountsTableCreateCompanionBuilder,
      $$WorkforceAccountsTableUpdateCompanionBuilder,
      (WorkforceAccount, $$WorkforceAccountsTableReferences),
      WorkforceAccount,
      PrefetchHooks Function({bool workforceEmployeesRefs})
    >;
typedef $$WorkforceEmployeesTableCreateCompanionBuilder =
    WorkforceEmployeesCompanion Function({
      required String id,
      required String companyId,
      required String employeeCode,
      required String firstName,
      Value<String> middleName,
      Value<String> lastName,
      required String email,
      required String phone,
      required String departmentId,
      required String designationId,
      Value<String?> managerId,
      required DateTime joiningDate,
      required String employmentType,
      required String status,
      Value<String?> avatarUrl,
      Value<String?> shiftId,
      Value<String?> workLocationId,
      Value<String?> attendancePolicyId,
      Value<String?> linkedUserId,
      Value<bool> loginEnabled,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String syncStatus,
      Value<int> rowid,
    });
typedef $$WorkforceEmployeesTableUpdateCompanionBuilder =
    WorkforceEmployeesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> employeeCode,
      Value<String> firstName,
      Value<String> middleName,
      Value<String> lastName,
      Value<String> email,
      Value<String> phone,
      Value<String> departmentId,
      Value<String> designationId,
      Value<String?> managerId,
      Value<DateTime> joiningDate,
      Value<String> employmentType,
      Value<String> status,
      Value<String?> avatarUrl,
      Value<String?> shiftId,
      Value<String?> workLocationId,
      Value<String?> attendancePolicyId,
      Value<String?> linkedUserId,
      Value<bool> loginEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$WorkforceEmployeesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkforceEmployeesTable,
          EmployeeRecord
        > {
  $$WorkforceEmployeesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkforceDepartmentsTable _departmentIdTable(_$AppDatabase db) =>
      db.workforceDepartments.createAlias(
        $_aliasNameGenerator(
          db.workforceEmployees.departmentId,
          db.workforceDepartments.id,
        ),
      );

  $$WorkforceDepartmentsTableProcessedTableManager get departmentId {
    final $_column = $_itemColumn<String>('department_id')!;

    final manager = $$WorkforceDepartmentsTableTableManager(
      $_db,
      $_db.workforceDepartments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_departmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkforceDesignationsTable _designationIdTable(_$AppDatabase db) =>
      db.workforceDesignations.createAlias(
        $_aliasNameGenerator(
          db.workforceEmployees.designationId,
          db.workforceDesignations.id,
        ),
      );

  $$WorkforceDesignationsTableProcessedTableManager get designationId {
    final $_column = $_itemColumn<String>('designation_id')!;

    final manager = $$WorkforceDesignationsTableTableManager(
      $_db,
      $_db.workforceDesignations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_designationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkforceEmployeesTable _managerIdTable(_$AppDatabase db) =>
      db.workforceEmployees.createAlias(
        $_aliasNameGenerator(
          db.workforceEmployees.managerId,
          db.workforceEmployees.id,
        ),
      );

  $$WorkforceEmployeesTableProcessedTableManager? get managerId {
    final $_column = $_itemColumn<String>('manager_id');
    if ($_column == null) return null;
    final manager = $$WorkforceEmployeesTableTableManager(
      $_db,
      $_db.workforceEmployees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_managerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkforceAccountsTable _linkedUserIdTable(_$AppDatabase db) =>
      db.workforceAccounts.createAlias(
        $_aliasNameGenerator(
          db.workforceEmployees.linkedUserId,
          db.workforceAccounts.id,
        ),
      );

  $$WorkforceAccountsTableProcessedTableManager? get linkedUserId {
    final $_column = $_itemColumn<String>('linked_user_id');
    if ($_column == null) return null;
    final manager = $$WorkforceAccountsTableTableManager(
      $_db,
      $_db.workforceAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkforceEmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkforceEmployeesTable> {
  $$WorkforceEmployeesTableFilterComposer({
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

  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendancePolicyId => $composableBuilder(
    column: $table.attendancePolicyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get loginEnabled => $composableBuilder(
    column: $table.loginEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkforceDepartmentsTableFilterComposer get departmentId {
    final $$WorkforceDepartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departmentId,
      referencedTable: $db.workforceDepartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkforceDepartmentsTableFilterComposer(
            $db: $db,
            $table: $db.workforceDepartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkforceDesignationsTableFilterComposer get designationId {
    final $$WorkforceDesignationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.designationId,
          referencedTable: $db.workforceDesignations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceDesignationsTableFilterComposer(
                $db: $db,
                $table: $db.workforceDesignations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkforceEmployeesTableFilterComposer get managerId {
    final $$WorkforceEmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.managerId,
      referencedTable: $db.workforceEmployees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkforceEmployeesTableFilterComposer(
            $db: $db,
            $table: $db.workforceEmployees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkforceAccountsTableFilterComposer get linkedUserId {
    final $$WorkforceAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedUserId,
      referencedTable: $db.workforceAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkforceAccountsTableFilterComposer(
            $db: $db,
            $table: $db.workforceAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkforceEmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkforceEmployeesTable> {
  $$WorkforceEmployeesTableOrderingComposer({
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

  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendancePolicyId => $composableBuilder(
    column: $table.attendancePolicyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get loginEnabled => $composableBuilder(
    column: $table.loginEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkforceDepartmentsTableOrderingComposer get departmentId {
    final $$WorkforceDepartmentsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.departmentId,
          referencedTable: $db.workforceDepartments,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceDepartmentsTableOrderingComposer(
                $db: $db,
                $table: $db.workforceDepartments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkforceDesignationsTableOrderingComposer get designationId {
    final $$WorkforceDesignationsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.designationId,
          referencedTable: $db.workforceDesignations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceDesignationsTableOrderingComposer(
                $db: $db,
                $table: $db.workforceDesignations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkforceEmployeesTableOrderingComposer get managerId {
    final $$WorkforceEmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.managerId,
      referencedTable: $db.workforceEmployees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkforceEmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.workforceEmployees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkforceAccountsTableOrderingComposer get linkedUserId {
    final $$WorkforceAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedUserId,
      referencedTable: $db.workforceAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkforceAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.workforceAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkforceEmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkforceEmployeesTable> {
  $$WorkforceEmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get employeeCode => $composableBuilder(
    column: $table.employeeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get joiningDate => $composableBuilder(
    column: $table.joiningDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employmentType => $composableBuilder(
    column: $table.employmentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attendancePolicyId => $composableBuilder(
    column: $table.attendancePolicyId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get loginEnabled => $composableBuilder(
    column: $table.loginEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$WorkforceDepartmentsTableAnnotationComposer get departmentId {
    final $$WorkforceDepartmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.departmentId,
          referencedTable: $db.workforceDepartments,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceDepartmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.workforceDepartments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkforceDesignationsTableAnnotationComposer get designationId {
    final $$WorkforceDesignationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.designationId,
          referencedTable: $db.workforceDesignations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceDesignationsTableAnnotationComposer(
                $db: $db,
                $table: $db.workforceDesignations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkforceEmployeesTableAnnotationComposer get managerId {
    final $$WorkforceEmployeesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.managerId,
          referencedTable: $db.workforceEmployees,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceEmployeesTableAnnotationComposer(
                $db: $db,
                $table: $db.workforceEmployees,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkforceAccountsTableAnnotationComposer get linkedUserId {
    final $$WorkforceAccountsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.linkedUserId,
          referencedTable: $db.workforceAccounts,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkforceAccountsTableAnnotationComposer(
                $db: $db,
                $table: $db.workforceAccounts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkforceEmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkforceEmployeesTable,
          EmployeeRecord,
          $$WorkforceEmployeesTableFilterComposer,
          $$WorkforceEmployeesTableOrderingComposer,
          $$WorkforceEmployeesTableAnnotationComposer,
          $$WorkforceEmployeesTableCreateCompanionBuilder,
          $$WorkforceEmployeesTableUpdateCompanionBuilder,
          (EmployeeRecord, $$WorkforceEmployeesTableReferences),
          EmployeeRecord,
          PrefetchHooks Function({
            bool departmentId,
            bool designationId,
            bool managerId,
            bool linkedUserId,
          })
        > {
  $$WorkforceEmployeesTableTableManager(
    _$AppDatabase db,
    $WorkforceEmployeesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkforceEmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkforceEmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkforceEmployeesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> employeeCode = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> middleName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> departmentId = const Value.absent(),
                Value<String> designationId = const Value.absent(),
                Value<String?> managerId = const Value.absent(),
                Value<DateTime> joiningDate = const Value.absent(),
                Value<String> employmentType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                Value<String?> workLocationId = const Value.absent(),
                Value<String?> attendancePolicyId = const Value.absent(),
                Value<String?> linkedUserId = const Value.absent(),
                Value<bool> loginEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkforceEmployeesCompanion(
                id: id,
                companyId: companyId,
                employeeCode: employeeCode,
                firstName: firstName,
                middleName: middleName,
                lastName: lastName,
                email: email,
                phone: phone,
                departmentId: departmentId,
                designationId: designationId,
                managerId: managerId,
                joiningDate: joiningDate,
                employmentType: employmentType,
                status: status,
                avatarUrl: avatarUrl,
                shiftId: shiftId,
                workLocationId: workLocationId,
                attendancePolicyId: attendancePolicyId,
                linkedUserId: linkedUserId,
                loginEnabled: loginEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String employeeCode,
                required String firstName,
                Value<String> middleName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                required String email,
                required String phone,
                required String departmentId,
                required String designationId,
                Value<String?> managerId = const Value.absent(),
                required DateTime joiningDate,
                required String employmentType,
                required String status,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                Value<String?> workLocationId = const Value.absent(),
                Value<String?> attendancePolicyId = const Value.absent(),
                Value<String?> linkedUserId = const Value.absent(),
                Value<bool> loginEnabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required String syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => WorkforceEmployeesCompanion.insert(
                id: id,
                companyId: companyId,
                employeeCode: employeeCode,
                firstName: firstName,
                middleName: middleName,
                lastName: lastName,
                email: email,
                phone: phone,
                departmentId: departmentId,
                designationId: designationId,
                managerId: managerId,
                joiningDate: joiningDate,
                employmentType: employmentType,
                status: status,
                avatarUrl: avatarUrl,
                shiftId: shiftId,
                workLocationId: workLocationId,
                attendancePolicyId: attendancePolicyId,
                linkedUserId: linkedUserId,
                loginEnabled: loginEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkforceEmployeesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                departmentId = false,
                designationId = false,
                managerId = false,
                linkedUserId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (departmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.departmentId,
                                    referencedTable:
                                        $$WorkforceEmployeesTableReferences
                                            ._departmentIdTable(db),
                                    referencedColumn:
                                        $$WorkforceEmployeesTableReferences
                                            ._departmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (designationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.designationId,
                                    referencedTable:
                                        $$WorkforceEmployeesTableReferences
                                            ._designationIdTable(db),
                                    referencedColumn:
                                        $$WorkforceEmployeesTableReferences
                                            ._designationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (managerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.managerId,
                                    referencedTable:
                                        $$WorkforceEmployeesTableReferences
                                            ._managerIdTable(db),
                                    referencedColumn:
                                        $$WorkforceEmployeesTableReferences
                                            ._managerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (linkedUserId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.linkedUserId,
                                    referencedTable:
                                        $$WorkforceEmployeesTableReferences
                                            ._linkedUserIdTable(db),
                                    referencedColumn:
                                        $$WorkforceEmployeesTableReferences
                                            ._linkedUserIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$WorkforceEmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkforceEmployeesTable,
      EmployeeRecord,
      $$WorkforceEmployeesTableFilterComposer,
      $$WorkforceEmployeesTableOrderingComposer,
      $$WorkforceEmployeesTableAnnotationComposer,
      $$WorkforceEmployeesTableCreateCompanionBuilder,
      $$WorkforceEmployeesTableUpdateCompanionBuilder,
      (EmployeeRecord, $$WorkforceEmployeesTableReferences),
      EmployeeRecord,
      PrefetchHooks Function({
        bool departmentId,
        bool designationId,
        bool managerId,
        bool linkedUserId,
      })
    >;
typedef $$WorkforceSeedsTableCreateCompanionBuilder =
    WorkforceSeedsCompanion Function({
      required String companyId,
      required int version,
      Value<int> rowid,
    });
typedef $$WorkforceSeedsTableUpdateCompanionBuilder =
    WorkforceSeedsCompanion Function({
      Value<String> companyId,
      Value<int> version,
      Value<int> rowid,
    });

class $$WorkforceSeedsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkforceSeedsTable> {
  $$WorkforceSeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkforceSeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkforceSeedsTable> {
  $$WorkforceSeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkforceSeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkforceSeedsTable> {
  $$WorkforceSeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$WorkforceSeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkforceSeedsTable,
          WorkforceSeed,
          $$WorkforceSeedsTableFilterComposer,
          $$WorkforceSeedsTableOrderingComposer,
          $$WorkforceSeedsTableAnnotationComposer,
          $$WorkforceSeedsTableCreateCompanionBuilder,
          $$WorkforceSeedsTableUpdateCompanionBuilder,
          (
            WorkforceSeed,
            BaseReferences<_$AppDatabase, $WorkforceSeedsTable, WorkforceSeed>,
          ),
          WorkforceSeed,
          PrefetchHooks Function()
        > {
  $$WorkforceSeedsTableTableManager(
    _$AppDatabase db,
    $WorkforceSeedsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkforceSeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkforceSeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkforceSeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> companyId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkforceSeedsCompanion(
                companyId: companyId,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String companyId,
                required int version,
                Value<int> rowid = const Value.absent(),
              }) => WorkforceSeedsCompanion.insert(
                companyId: companyId,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkforceSeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkforceSeedsTable,
      WorkforceSeed,
      $$WorkforceSeedsTableFilterComposer,
      $$WorkforceSeedsTableOrderingComposer,
      $$WorkforceSeedsTableAnnotationComposer,
      $$WorkforceSeedsTableCreateCompanionBuilder,
      $$WorkforceSeedsTableUpdateCompanionBuilder,
      (
        WorkforceSeed,
        BaseReferences<_$AppDatabase, $WorkforceSeedsTable, WorkforceSeed>,
      ),
      WorkforceSeed,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$WorkforceDepartmentsTableTableManager get workforceDepartments =>
      $$WorkforceDepartmentsTableTableManager(_db, _db.workforceDepartments);
  $$WorkforceDesignationsTableTableManager get workforceDesignations =>
      $$WorkforceDesignationsTableTableManager(_db, _db.workforceDesignations);
  $$WorkforceAccountsTableTableManager get workforceAccounts =>
      $$WorkforceAccountsTableTableManager(_db, _db.workforceAccounts);
  $$WorkforceEmployeesTableTableManager get workforceEmployees =>
      $$WorkforceEmployeesTableTableManager(_db, _db.workforceEmployees);
  $$WorkforceSeedsTableTableManager get workforceSeeds =>
      $$WorkforceSeedsTableTableManager(_db, _db.workforceSeeds);
}
