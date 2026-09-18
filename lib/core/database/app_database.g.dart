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
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _failureCodeMeta = const VerificationMeta(
    'failureCode',
  );
  @override
  late final GeneratedColumn<String> failureCode = GeneratedColumn<String>(
    'failure_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    companyId,
    requestId,
    status,
    lastAttemptAt,
    failureCode,
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
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('failure_code')) {
      context.handle(
        _failureCodeMeta,
        failureCode.isAcceptableOrUnknown(
          data['failure_code']!,
          _failureCodeMeta,
        ),
      );
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
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      ),
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      failureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_code'],
      ),
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
  final String? companyId;
  final String? requestId;
  final String status;
  final DateTime? lastAttemptAt;
  final String? failureCode;
  final int attempts;
  const SyncOutboxData({
    required this.id,
    required this.moduleId,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.companyId,
    this.requestId,
    required this.status,
    this.lastAttemptAt,
    this.failureCode,
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
    if (!nullToAbsent || companyId != null) {
      map['company_id'] = Variable<String>(companyId);
    }
    if (!nullToAbsent || requestId != null) {
      map['request_id'] = Variable<String>(requestId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || failureCode != null) {
      map['failure_code'] = Variable<String>(failureCode);
    }
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
      companyId: companyId == null && nullToAbsent
          ? const Value.absent()
          : Value(companyId),
      requestId: requestId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestId),
      status: Value(status),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      failureCode: failureCode == null && nullToAbsent
          ? const Value.absent()
          : Value(failureCode),
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
      companyId: serializer.fromJson<String?>(json['companyId']),
      requestId: serializer.fromJson<String?>(json['requestId']),
      status: serializer.fromJson<String>(json['status']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      failureCode: serializer.fromJson<String?>(json['failureCode']),
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
      'companyId': serializer.toJson<String?>(companyId),
      'requestId': serializer.toJson<String?>(requestId),
      'status': serializer.toJson<String>(status),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'failureCode': serializer.toJson<String?>(failureCode),
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
    Value<String?> companyId = const Value.absent(),
    Value<String?> requestId = const Value.absent(),
    String? status,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> failureCode = const Value.absent(),
    int? attempts,
  }) => SyncOutboxData(
    id: id ?? this.id,
    moduleId: moduleId ?? this.moduleId,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    companyId: companyId.present ? companyId.value : this.companyId,
    requestId: requestId.present ? requestId.value : this.requestId,
    status: status ?? this.status,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    failureCode: failureCode.present ? failureCode.value : this.failureCode,
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
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      status: data.status.present ? data.status.value : this.status,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      failureCode: data.failureCode.present
          ? data.failureCode.value
          : this.failureCode,
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
          ..write('companyId: $companyId, ')
          ..write('requestId: $requestId, ')
          ..write('status: $status, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('failureCode: $failureCode, ')
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
    companyId,
    requestId,
    status,
    lastAttemptAt,
    failureCode,
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
          other.companyId == this.companyId &&
          other.requestId == this.requestId &&
          other.status == this.status &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.failureCode == this.failureCode &&
          other.attempts == this.attempts);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> moduleId;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<String?> companyId;
  final Value<String?> requestId;
  final Value<String> status;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> failureCode;
  final Value<int> attempts;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.companyId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.status = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.failureCode = const Value.absent(),
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
    this.companyId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.status = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.failureCode = const Value.absent(),
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
    Expression<String>? companyId,
    Expression<String>? requestId,
    Expression<String>? status,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? failureCode,
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
      if (companyId != null) 'company_id': companyId,
      if (requestId != null) 'request_id': requestId,
      if (status != null) 'status': status,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (failureCode != null) 'failure_code': failureCode,
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
    Value<String?>? companyId,
    Value<String?>? requestId,
    Value<String>? status,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? failureCode,
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
      companyId: companyId ?? this.companyId,
      requestId: requestId ?? this.requestId,
      status: status ?? this.status,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      failureCode: failureCode ?? this.failureCode,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (failureCode.present) {
      map['failure_code'] = Variable<String>(failureCode.value);
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
          ..write('companyId: $companyId, ')
          ..write('requestId: $requestId, ')
          ..write('status: $status, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('failureCode: $failureCode, ')
          ..write('attempts: $attempts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceDaysTable extends AttendanceDays
    with TableInfo<$AttendanceDaysTable, AttendanceDayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceDaysTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendanceDateMeta = const VerificationMeta(
    'attendanceDate',
  );
  @override
  late final GeneratedColumn<String> attendanceDate = GeneratedColumn<String>(
    'attendance_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _policyIdMeta = const VerificationMeta(
    'policyId',
  );
  @override
  late final GeneratedColumn<String> policyId = GeneratedColumn<String>(
    'policy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _configurationSnapshotMeta =
      const VerificationMeta('configurationSnapshot');
  @override
  late final GeneratedColumn<String> configurationSnapshot =
      GeneratedColumn<String>(
        'configuration_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _punchInMillisecondsMeta =
      const VerificationMeta('punchInMilliseconds');
  @override
  late final GeneratedColumn<int> punchInMilliseconds = GeneratedColumn<int>(
    'punch_in_milliseconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _punchOutMillisecondsMeta =
      const VerificationMeta('punchOutMilliseconds');
  @override
  late final GeneratedColumn<int> punchOutMilliseconds = GeneratedColumn<int>(
    'punch_out_milliseconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedMillisecondsMeta =
      const VerificationMeta('elapsedMilliseconds');
  @override
  late final GeneratedColumn<int> elapsedMilliseconds = GeneratedColumn<int>(
    'elapsed_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _breakMillisecondsMeta = const VerificationMeta(
    'breakMilliseconds',
  );
  @override
  late final GeneratedColumn<int> breakMilliseconds = GeneratedColumn<int>(
    'break_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _workMillisecondsMeta = const VerificationMeta(
    'workMilliseconds',
  );
  @override
  late final GeneratedColumn<int> workMilliseconds = GeneratedColumn<int>(
    'work_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _createdMillisecondsMeta =
      const VerificationMeta('createdMilliseconds');
  @override
  late final GeneratedColumn<int> createdMilliseconds = GeneratedColumn<int>(
    'created_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedMillisecondsMeta =
      const VerificationMeta('updatedMilliseconds');
  @override
  late final GeneratedColumn<int> updatedMilliseconds = GeneratedColumn<int>(
    'updated_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    employeeId,
    attendanceDate,
    shiftId,
    policyId,
    workLocationId,
    configurationSnapshot,
    state,
    punchInMilliseconds,
    punchOutMilliseconds,
    elapsedMilliseconds,
    breakMilliseconds,
    workMilliseconds,
    status,
    syncStatus,
    createdMilliseconds,
    updatedMilliseconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceDayData> instance, {
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
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('attendance_date')) {
      context.handle(
        _attendanceDateMeta,
        attendanceDate.isAcceptableOrUnknown(
          data['attendance_date']!,
          _attendanceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceDateMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('policy_id')) {
      context.handle(
        _policyIdMeta,
        policyId.isAcceptableOrUnknown(data['policy_id']!, _policyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_policyIdMeta);
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
    if (data.containsKey('configuration_snapshot')) {
      context.handle(
        _configurationSnapshotMeta,
        configurationSnapshot.isAcceptableOrUnknown(
          data['configuration_snapshot']!,
          _configurationSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configurationSnapshotMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('punch_in_milliseconds')) {
      context.handle(
        _punchInMillisecondsMeta,
        punchInMilliseconds.isAcceptableOrUnknown(
          data['punch_in_milliseconds']!,
          _punchInMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('punch_out_milliseconds')) {
      context.handle(
        _punchOutMillisecondsMeta,
        punchOutMilliseconds.isAcceptableOrUnknown(
          data['punch_out_milliseconds']!,
          _punchOutMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_milliseconds')) {
      context.handle(
        _elapsedMillisecondsMeta,
        elapsedMilliseconds.isAcceptableOrUnknown(
          data['elapsed_milliseconds']!,
          _elapsedMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('break_milliseconds')) {
      context.handle(
        _breakMillisecondsMeta,
        breakMilliseconds.isAcceptableOrUnknown(
          data['break_milliseconds']!,
          _breakMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('work_milliseconds')) {
      context.handle(
        _workMillisecondsMeta,
        workMilliseconds.isAcceptableOrUnknown(
          data['work_milliseconds']!,
          _workMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('created_milliseconds')) {
      context.handle(
        _createdMillisecondsMeta,
        createdMilliseconds.isAcceptableOrUnknown(
          data['created_milliseconds']!,
          _createdMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdMillisecondsMeta);
    }
    if (data.containsKey('updated_milliseconds')) {
      context.handle(
        _updatedMillisecondsMeta,
        updatedMilliseconds.isAcceptableOrUnknown(
          data['updated_milliseconds']!,
          _updatedMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedMillisecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, employeeId, attendanceDate},
  ];
  @override
  AttendanceDayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceDayData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      attendanceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_date'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      policyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_id'],
      )!,
      workLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_location_id'],
      ),
      configurationSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}configuration_snapshot'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      punchInMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}punch_in_milliseconds'],
      ),
      punchOutMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}punch_out_milliseconds'],
      ),
      elapsedMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_milliseconds'],
      )!,
      breakMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_milliseconds'],
      )!,
      workMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_milliseconds'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_milliseconds'],
      )!,
      updatedMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_milliseconds'],
      )!,
    );
  }

  @override
  $AttendanceDaysTable createAlias(String alias) {
    return $AttendanceDaysTable(attachedDatabase, alias);
  }
}

class AttendanceDayData extends DataClass
    implements Insertable<AttendanceDayData> {
  final String id;
  final String companyId;
  final String employeeId;
  final String attendanceDate;
  final String shiftId;
  final String policyId;
  final String? workLocationId;
  final String configurationSnapshot;
  final String state;
  final int? punchInMilliseconds;
  final int? punchOutMilliseconds;
  final int elapsedMilliseconds;
  final int breakMilliseconds;
  final int workMilliseconds;
  final String status;
  final String syncStatus;
  final int createdMilliseconds;
  final int updatedMilliseconds;
  const AttendanceDayData({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.attendanceDate,
    required this.shiftId,
    required this.policyId,
    this.workLocationId,
    required this.configurationSnapshot,
    required this.state,
    this.punchInMilliseconds,
    this.punchOutMilliseconds,
    required this.elapsedMilliseconds,
    required this.breakMilliseconds,
    required this.workMilliseconds,
    required this.status,
    required this.syncStatus,
    required this.createdMilliseconds,
    required this.updatedMilliseconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['employee_id'] = Variable<String>(employeeId);
    map['attendance_date'] = Variable<String>(attendanceDate);
    map['shift_id'] = Variable<String>(shiftId);
    map['policy_id'] = Variable<String>(policyId);
    if (!nullToAbsent || workLocationId != null) {
      map['work_location_id'] = Variable<String>(workLocationId);
    }
    map['configuration_snapshot'] = Variable<String>(configurationSnapshot);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || punchInMilliseconds != null) {
      map['punch_in_milliseconds'] = Variable<int>(punchInMilliseconds);
    }
    if (!nullToAbsent || punchOutMilliseconds != null) {
      map['punch_out_milliseconds'] = Variable<int>(punchOutMilliseconds);
    }
    map['elapsed_milliseconds'] = Variable<int>(elapsedMilliseconds);
    map['break_milliseconds'] = Variable<int>(breakMilliseconds);
    map['work_milliseconds'] = Variable<int>(workMilliseconds);
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_milliseconds'] = Variable<int>(createdMilliseconds);
    map['updated_milliseconds'] = Variable<int>(updatedMilliseconds);
    return map;
  }

  AttendanceDaysCompanion toCompanion(bool nullToAbsent) {
    return AttendanceDaysCompanion(
      id: Value(id),
      companyId: Value(companyId),
      employeeId: Value(employeeId),
      attendanceDate: Value(attendanceDate),
      shiftId: Value(shiftId),
      policyId: Value(policyId),
      workLocationId: workLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(workLocationId),
      configurationSnapshot: Value(configurationSnapshot),
      state: Value(state),
      punchInMilliseconds: punchInMilliseconds == null && nullToAbsent
          ? const Value.absent()
          : Value(punchInMilliseconds),
      punchOutMilliseconds: punchOutMilliseconds == null && nullToAbsent
          ? const Value.absent()
          : Value(punchOutMilliseconds),
      elapsedMilliseconds: Value(elapsedMilliseconds),
      breakMilliseconds: Value(breakMilliseconds),
      workMilliseconds: Value(workMilliseconds),
      status: Value(status),
      syncStatus: Value(syncStatus),
      createdMilliseconds: Value(createdMilliseconds),
      updatedMilliseconds: Value(updatedMilliseconds),
    );
  }

  factory AttendanceDayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceDayData(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      attendanceDate: serializer.fromJson<String>(json['attendanceDate']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      policyId: serializer.fromJson<String>(json['policyId']),
      workLocationId: serializer.fromJson<String?>(json['workLocationId']),
      configurationSnapshot: serializer.fromJson<String>(
        json['configurationSnapshot'],
      ),
      state: serializer.fromJson<String>(json['state']),
      punchInMilliseconds: serializer.fromJson<int?>(
        json['punchInMilliseconds'],
      ),
      punchOutMilliseconds: serializer.fromJson<int?>(
        json['punchOutMilliseconds'],
      ),
      elapsedMilliseconds: serializer.fromJson<int>(
        json['elapsedMilliseconds'],
      ),
      breakMilliseconds: serializer.fromJson<int>(json['breakMilliseconds']),
      workMilliseconds: serializer.fromJson<int>(json['workMilliseconds']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdMilliseconds: serializer.fromJson<int>(
        json['createdMilliseconds'],
      ),
      updatedMilliseconds: serializer.fromJson<int>(
        json['updatedMilliseconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'employeeId': serializer.toJson<String>(employeeId),
      'attendanceDate': serializer.toJson<String>(attendanceDate),
      'shiftId': serializer.toJson<String>(shiftId),
      'policyId': serializer.toJson<String>(policyId),
      'workLocationId': serializer.toJson<String?>(workLocationId),
      'configurationSnapshot': serializer.toJson<String>(configurationSnapshot),
      'state': serializer.toJson<String>(state),
      'punchInMilliseconds': serializer.toJson<int?>(punchInMilliseconds),
      'punchOutMilliseconds': serializer.toJson<int?>(punchOutMilliseconds),
      'elapsedMilliseconds': serializer.toJson<int>(elapsedMilliseconds),
      'breakMilliseconds': serializer.toJson<int>(breakMilliseconds),
      'workMilliseconds': serializer.toJson<int>(workMilliseconds),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdMilliseconds': serializer.toJson<int>(createdMilliseconds),
      'updatedMilliseconds': serializer.toJson<int>(updatedMilliseconds),
    };
  }

  AttendanceDayData copyWith({
    String? id,
    String? companyId,
    String? employeeId,
    String? attendanceDate,
    String? shiftId,
    String? policyId,
    Value<String?> workLocationId = const Value.absent(),
    String? configurationSnapshot,
    String? state,
    Value<int?> punchInMilliseconds = const Value.absent(),
    Value<int?> punchOutMilliseconds = const Value.absent(),
    int? elapsedMilliseconds,
    int? breakMilliseconds,
    int? workMilliseconds,
    String? status,
    String? syncStatus,
    int? createdMilliseconds,
    int? updatedMilliseconds,
  }) => AttendanceDayData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    employeeId: employeeId ?? this.employeeId,
    attendanceDate: attendanceDate ?? this.attendanceDate,
    shiftId: shiftId ?? this.shiftId,
    policyId: policyId ?? this.policyId,
    workLocationId: workLocationId.present
        ? workLocationId.value
        : this.workLocationId,
    configurationSnapshot: configurationSnapshot ?? this.configurationSnapshot,
    state: state ?? this.state,
    punchInMilliseconds: punchInMilliseconds.present
        ? punchInMilliseconds.value
        : this.punchInMilliseconds,
    punchOutMilliseconds: punchOutMilliseconds.present
        ? punchOutMilliseconds.value
        : this.punchOutMilliseconds,
    elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
    breakMilliseconds: breakMilliseconds ?? this.breakMilliseconds,
    workMilliseconds: workMilliseconds ?? this.workMilliseconds,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    createdMilliseconds: createdMilliseconds ?? this.createdMilliseconds,
    updatedMilliseconds: updatedMilliseconds ?? this.updatedMilliseconds,
  );
  AttendanceDayData copyWithCompanion(AttendanceDaysCompanion data) {
    return AttendanceDayData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      attendanceDate: data.attendanceDate.present
          ? data.attendanceDate.value
          : this.attendanceDate,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      policyId: data.policyId.present ? data.policyId.value : this.policyId,
      workLocationId: data.workLocationId.present
          ? data.workLocationId.value
          : this.workLocationId,
      configurationSnapshot: data.configurationSnapshot.present
          ? data.configurationSnapshot.value
          : this.configurationSnapshot,
      state: data.state.present ? data.state.value : this.state,
      punchInMilliseconds: data.punchInMilliseconds.present
          ? data.punchInMilliseconds.value
          : this.punchInMilliseconds,
      punchOutMilliseconds: data.punchOutMilliseconds.present
          ? data.punchOutMilliseconds.value
          : this.punchOutMilliseconds,
      elapsedMilliseconds: data.elapsedMilliseconds.present
          ? data.elapsedMilliseconds.value
          : this.elapsedMilliseconds,
      breakMilliseconds: data.breakMilliseconds.present
          ? data.breakMilliseconds.value
          : this.breakMilliseconds,
      workMilliseconds: data.workMilliseconds.present
          ? data.workMilliseconds.value
          : this.workMilliseconds,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdMilliseconds: data.createdMilliseconds.present
          ? data.createdMilliseconds.value
          : this.createdMilliseconds,
      updatedMilliseconds: data.updatedMilliseconds.present
          ? data.updatedMilliseconds.value
          : this.updatedMilliseconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceDayData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('employeeId: $employeeId, ')
          ..write('attendanceDate: $attendanceDate, ')
          ..write('shiftId: $shiftId, ')
          ..write('policyId: $policyId, ')
          ..write('workLocationId: $workLocationId, ')
          ..write('configurationSnapshot: $configurationSnapshot, ')
          ..write('state: $state, ')
          ..write('punchInMilliseconds: $punchInMilliseconds, ')
          ..write('punchOutMilliseconds: $punchOutMilliseconds, ')
          ..write('elapsedMilliseconds: $elapsedMilliseconds, ')
          ..write('breakMilliseconds: $breakMilliseconds, ')
          ..write('workMilliseconds: $workMilliseconds, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdMilliseconds: $createdMilliseconds, ')
          ..write('updatedMilliseconds: $updatedMilliseconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    employeeId,
    attendanceDate,
    shiftId,
    policyId,
    workLocationId,
    configurationSnapshot,
    state,
    punchInMilliseconds,
    punchOutMilliseconds,
    elapsedMilliseconds,
    breakMilliseconds,
    workMilliseconds,
    status,
    syncStatus,
    createdMilliseconds,
    updatedMilliseconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceDayData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.employeeId == this.employeeId &&
          other.attendanceDate == this.attendanceDate &&
          other.shiftId == this.shiftId &&
          other.policyId == this.policyId &&
          other.workLocationId == this.workLocationId &&
          other.configurationSnapshot == this.configurationSnapshot &&
          other.state == this.state &&
          other.punchInMilliseconds == this.punchInMilliseconds &&
          other.punchOutMilliseconds == this.punchOutMilliseconds &&
          other.elapsedMilliseconds == this.elapsedMilliseconds &&
          other.breakMilliseconds == this.breakMilliseconds &&
          other.workMilliseconds == this.workMilliseconds &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.createdMilliseconds == this.createdMilliseconds &&
          other.updatedMilliseconds == this.updatedMilliseconds);
}

class AttendanceDaysCompanion extends UpdateCompanion<AttendanceDayData> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> employeeId;
  final Value<String> attendanceDate;
  final Value<String> shiftId;
  final Value<String> policyId;
  final Value<String?> workLocationId;
  final Value<String> configurationSnapshot;
  final Value<String> state;
  final Value<int?> punchInMilliseconds;
  final Value<int?> punchOutMilliseconds;
  final Value<int> elapsedMilliseconds;
  final Value<int> breakMilliseconds;
  final Value<int> workMilliseconds;
  final Value<String> status;
  final Value<String> syncStatus;
  final Value<int> createdMilliseconds;
  final Value<int> updatedMilliseconds;
  final Value<int> rowid;
  const AttendanceDaysCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.attendanceDate = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.policyId = const Value.absent(),
    this.workLocationId = const Value.absent(),
    this.configurationSnapshot = const Value.absent(),
    this.state = const Value.absent(),
    this.punchInMilliseconds = const Value.absent(),
    this.punchOutMilliseconds = const Value.absent(),
    this.elapsedMilliseconds = const Value.absent(),
    this.breakMilliseconds = const Value.absent(),
    this.workMilliseconds = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdMilliseconds = const Value.absent(),
    this.updatedMilliseconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceDaysCompanion.insert({
    required String id,
    required String companyId,
    required String employeeId,
    required String attendanceDate,
    required String shiftId,
    required String policyId,
    this.workLocationId = const Value.absent(),
    required String configurationSnapshot,
    required String state,
    this.punchInMilliseconds = const Value.absent(),
    this.punchOutMilliseconds = const Value.absent(),
    this.elapsedMilliseconds = const Value.absent(),
    this.breakMilliseconds = const Value.absent(),
    this.workMilliseconds = const Value.absent(),
    required String status,
    required String syncStatus,
    required int createdMilliseconds,
    required int updatedMilliseconds,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       employeeId = Value(employeeId),
       attendanceDate = Value(attendanceDate),
       shiftId = Value(shiftId),
       policyId = Value(policyId),
       configurationSnapshot = Value(configurationSnapshot),
       state = Value(state),
       status = Value(status),
       syncStatus = Value(syncStatus),
       createdMilliseconds = Value(createdMilliseconds),
       updatedMilliseconds = Value(updatedMilliseconds);
  static Insertable<AttendanceDayData> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? employeeId,
    Expression<String>? attendanceDate,
    Expression<String>? shiftId,
    Expression<String>? policyId,
    Expression<String>? workLocationId,
    Expression<String>? configurationSnapshot,
    Expression<String>? state,
    Expression<int>? punchInMilliseconds,
    Expression<int>? punchOutMilliseconds,
    Expression<int>? elapsedMilliseconds,
    Expression<int>? breakMilliseconds,
    Expression<int>? workMilliseconds,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<int>? createdMilliseconds,
    Expression<int>? updatedMilliseconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (employeeId != null) 'employee_id': employeeId,
      if (attendanceDate != null) 'attendance_date': attendanceDate,
      if (shiftId != null) 'shift_id': shiftId,
      if (policyId != null) 'policy_id': policyId,
      if (workLocationId != null) 'work_location_id': workLocationId,
      if (configurationSnapshot != null)
        'configuration_snapshot': configurationSnapshot,
      if (state != null) 'state': state,
      if (punchInMilliseconds != null)
        'punch_in_milliseconds': punchInMilliseconds,
      if (punchOutMilliseconds != null)
        'punch_out_milliseconds': punchOutMilliseconds,
      if (elapsedMilliseconds != null)
        'elapsed_milliseconds': elapsedMilliseconds,
      if (breakMilliseconds != null) 'break_milliseconds': breakMilliseconds,
      if (workMilliseconds != null) 'work_milliseconds': workMilliseconds,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdMilliseconds != null)
        'created_milliseconds': createdMilliseconds,
      if (updatedMilliseconds != null)
        'updated_milliseconds': updatedMilliseconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceDaysCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? employeeId,
    Value<String>? attendanceDate,
    Value<String>? shiftId,
    Value<String>? policyId,
    Value<String?>? workLocationId,
    Value<String>? configurationSnapshot,
    Value<String>? state,
    Value<int?>? punchInMilliseconds,
    Value<int?>? punchOutMilliseconds,
    Value<int>? elapsedMilliseconds,
    Value<int>? breakMilliseconds,
    Value<int>? workMilliseconds,
    Value<String>? status,
    Value<String>? syncStatus,
    Value<int>? createdMilliseconds,
    Value<int>? updatedMilliseconds,
    Value<int>? rowid,
  }) {
    return AttendanceDaysCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      employeeId: employeeId ?? this.employeeId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      shiftId: shiftId ?? this.shiftId,
      policyId: policyId ?? this.policyId,
      workLocationId: workLocationId ?? this.workLocationId,
      configurationSnapshot:
          configurationSnapshot ?? this.configurationSnapshot,
      state: state ?? this.state,
      punchInMilliseconds: punchInMilliseconds ?? this.punchInMilliseconds,
      punchOutMilliseconds: punchOutMilliseconds ?? this.punchOutMilliseconds,
      elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
      breakMilliseconds: breakMilliseconds ?? this.breakMilliseconds,
      workMilliseconds: workMilliseconds ?? this.workMilliseconds,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      createdMilliseconds: createdMilliseconds ?? this.createdMilliseconds,
      updatedMilliseconds: updatedMilliseconds ?? this.updatedMilliseconds,
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
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (attendanceDate.present) {
      map['attendance_date'] = Variable<String>(attendanceDate.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (policyId.present) {
      map['policy_id'] = Variable<String>(policyId.value);
    }
    if (workLocationId.present) {
      map['work_location_id'] = Variable<String>(workLocationId.value);
    }
    if (configurationSnapshot.present) {
      map['configuration_snapshot'] = Variable<String>(
        configurationSnapshot.value,
      );
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (punchInMilliseconds.present) {
      map['punch_in_milliseconds'] = Variable<int>(punchInMilliseconds.value);
    }
    if (punchOutMilliseconds.present) {
      map['punch_out_milliseconds'] = Variable<int>(punchOutMilliseconds.value);
    }
    if (elapsedMilliseconds.present) {
      map['elapsed_milliseconds'] = Variable<int>(elapsedMilliseconds.value);
    }
    if (breakMilliseconds.present) {
      map['break_milliseconds'] = Variable<int>(breakMilliseconds.value);
    }
    if (workMilliseconds.present) {
      map['work_milliseconds'] = Variable<int>(workMilliseconds.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdMilliseconds.present) {
      map['created_milliseconds'] = Variable<int>(createdMilliseconds.value);
    }
    if (updatedMilliseconds.present) {
      map['updated_milliseconds'] = Variable<int>(updatedMilliseconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceDaysCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('employeeId: $employeeId, ')
          ..write('attendanceDate: $attendanceDate, ')
          ..write('shiftId: $shiftId, ')
          ..write('policyId: $policyId, ')
          ..write('workLocationId: $workLocationId, ')
          ..write('configurationSnapshot: $configurationSnapshot, ')
          ..write('state: $state, ')
          ..write('punchInMilliseconds: $punchInMilliseconds, ')
          ..write('punchOutMilliseconds: $punchOutMilliseconds, ')
          ..write('elapsedMilliseconds: $elapsedMilliseconds, ')
          ..write('breakMilliseconds: $breakMilliseconds, ')
          ..write('workMilliseconds: $workMilliseconds, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdMilliseconds: $createdMilliseconds, ')
          ..write('updatedMilliseconds: $updatedMilliseconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceEventsTable extends AttendanceEvents
    with TableInfo<$AttendanceEventsTable, AttendanceEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendanceDayIdMeta = const VerificationMeta(
    'attendanceDayId',
  );
  @override
  late final GeneratedColumn<String> attendanceDayId = GeneratedColumn<String>(
    'attendance_day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attendance_days (id)',
    ),
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
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceMillisecondsMeta =
      const VerificationMeta('deviceMilliseconds');
  @override
  late final GeneratedColumn<int> deviceMilliseconds = GeneratedColumn<int>(
    'device_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverMillisecondsMeta =
      const VerificationMeta('serverMilliseconds');
  @override
  late final GeneratedColumn<int> serverMilliseconds = GeneratedColumn<int>(
    'server_milliseconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectiveMillisecondsMeta =
      const VerificationMeta('effectiveMilliseconds');
  @override
  late final GeneratedColumn<int> effectiveMilliseconds = GeneratedColumn<int>(
    'effective_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
    'accuracy_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedMillisecondsMeta =
      const VerificationMeta('capturedMilliseconds');
  @override
  late final GeneratedColumn<int> capturedMilliseconds = GeneratedColumn<int>(
    'captured_milliseconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _permissionStateMeta = const VerificationMeta(
    'permissionState',
  );
  @override
  late final GeneratedColumn<String> permissionState = GeneratedColumn<String>(
    'permission_state',
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
  static const VerificationMeta _locationValidationMeta =
      const VerificationMeta('locationValidation');
  @override
  late final GeneratedColumn<String> locationValidation =
      GeneratedColumn<String>(
        'location_validation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _createdMillisecondsMeta =
      const VerificationMeta('createdMilliseconds');
  @override
  late final GeneratedColumn<int> createdMilliseconds = GeneratedColumn<int>(
    'created_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attendanceDayId,
    companyId,
    employeeId,
    eventType,
    deviceMilliseconds,
    serverMilliseconds,
    effectiveMilliseconds,
    sequence,
    latitude,
    longitude,
    accuracyMeters,
    capturedMilliseconds,
    permissionState,
    workLocationId,
    locationValidation,
    requestId,
    source,
    syncStatus,
    createdMilliseconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceEventData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('attendance_day_id')) {
      context.handle(
        _attendanceDayIdMeta,
        attendanceDayId.isAcceptableOrUnknown(
          data['attendance_day_id']!,
          _attendanceDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceDayIdMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('device_milliseconds')) {
      context.handle(
        _deviceMillisecondsMeta,
        deviceMilliseconds.isAcceptableOrUnknown(
          data['device_milliseconds']!,
          _deviceMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceMillisecondsMeta);
    }
    if (data.containsKey('server_milliseconds')) {
      context.handle(
        _serverMillisecondsMeta,
        serverMilliseconds.isAcceptableOrUnknown(
          data['server_milliseconds']!,
          _serverMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('effective_milliseconds')) {
      context.handle(
        _effectiveMillisecondsMeta,
        effectiveMilliseconds.isAcceptableOrUnknown(
          data['effective_milliseconds']!,
          _effectiveMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveMillisecondsMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('captured_milliseconds')) {
      context.handle(
        _capturedMillisecondsMeta,
        capturedMilliseconds.isAcceptableOrUnknown(
          data['captured_milliseconds']!,
          _capturedMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('permission_state')) {
      context.handle(
        _permissionStateMeta,
        permissionState.isAcceptableOrUnknown(
          data['permission_state']!,
          _permissionStateMeta,
        ),
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
    if (data.containsKey('location_validation')) {
      context.handle(
        _locationValidationMeta,
        locationValidation.isAcceptableOrUnknown(
          data['location_validation']!,
          _locationValidationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationValidationMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('created_milliseconds')) {
      context.handle(
        _createdMillisecondsMeta,
        createdMilliseconds.isAcceptableOrUnknown(
          data['created_milliseconds']!,
          _createdMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdMillisecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {attendanceDayId, sequence},
  ];
  @override
  AttendanceEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceEventData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      attendanceDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_day_id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      deviceMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_milliseconds'],
      )!,
      serverMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_milliseconds'],
      ),
      effectiveMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_milliseconds'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_meters'],
      ),
      capturedMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_milliseconds'],
      ),
      permissionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_state'],
      ),
      workLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_location_id'],
      ),
      locationValidation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_validation'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_milliseconds'],
      )!,
    );
  }

  @override
  $AttendanceEventsTable createAlias(String alias) {
    return $AttendanceEventsTable(attachedDatabase, alias);
  }
}

class AttendanceEventData extends DataClass
    implements Insertable<AttendanceEventData> {
  final String id;
  final String attendanceDayId;
  final String companyId;
  final String employeeId;
  final String eventType;
  final int deviceMilliseconds;
  final int? serverMilliseconds;
  final int effectiveMilliseconds;
  final int sequence;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final int? capturedMilliseconds;
  final String? permissionState;
  final String? workLocationId;
  final String locationValidation;
  final String requestId;
  final String source;
  final String syncStatus;
  final int createdMilliseconds;
  const AttendanceEventData({
    required this.id,
    required this.attendanceDayId,
    required this.companyId,
    required this.employeeId,
    required this.eventType,
    required this.deviceMilliseconds,
    this.serverMilliseconds,
    required this.effectiveMilliseconds,
    required this.sequence,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.capturedMilliseconds,
    this.permissionState,
    this.workLocationId,
    required this.locationValidation,
    required this.requestId,
    required this.source,
    required this.syncStatus,
    required this.createdMilliseconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['attendance_day_id'] = Variable<String>(attendanceDayId);
    map['company_id'] = Variable<String>(companyId);
    map['employee_id'] = Variable<String>(employeeId);
    map['event_type'] = Variable<String>(eventType);
    map['device_milliseconds'] = Variable<int>(deviceMilliseconds);
    if (!nullToAbsent || serverMilliseconds != null) {
      map['server_milliseconds'] = Variable<int>(serverMilliseconds);
    }
    map['effective_milliseconds'] = Variable<int>(effectiveMilliseconds);
    map['sequence'] = Variable<int>(sequence);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters);
    }
    if (!nullToAbsent || capturedMilliseconds != null) {
      map['captured_milliseconds'] = Variable<int>(capturedMilliseconds);
    }
    if (!nullToAbsent || permissionState != null) {
      map['permission_state'] = Variable<String>(permissionState);
    }
    if (!nullToAbsent || workLocationId != null) {
      map['work_location_id'] = Variable<String>(workLocationId);
    }
    map['location_validation'] = Variable<String>(locationValidation);
    map['request_id'] = Variable<String>(requestId);
    map['source'] = Variable<String>(source);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_milliseconds'] = Variable<int>(createdMilliseconds);
    return map;
  }

  AttendanceEventsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceEventsCompanion(
      id: Value(id),
      attendanceDayId: Value(attendanceDayId),
      companyId: Value(companyId),
      employeeId: Value(employeeId),
      eventType: Value(eventType),
      deviceMilliseconds: Value(deviceMilliseconds),
      serverMilliseconds: serverMilliseconds == null && nullToAbsent
          ? const Value.absent()
          : Value(serverMilliseconds),
      effectiveMilliseconds: Value(effectiveMilliseconds),
      sequence: Value(sequence),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
      capturedMilliseconds: capturedMilliseconds == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedMilliseconds),
      permissionState: permissionState == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionState),
      workLocationId: workLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(workLocationId),
      locationValidation: Value(locationValidation),
      requestId: Value(requestId),
      source: Value(source),
      syncStatus: Value(syncStatus),
      createdMilliseconds: Value(createdMilliseconds),
    );
  }

  factory AttendanceEventData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceEventData(
      id: serializer.fromJson<String>(json['id']),
      attendanceDayId: serializer.fromJson<String>(json['attendanceDayId']),
      companyId: serializer.fromJson<String>(json['companyId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      deviceMilliseconds: serializer.fromJson<int>(json['deviceMilliseconds']),
      serverMilliseconds: serializer.fromJson<int?>(json['serverMilliseconds']),
      effectiveMilliseconds: serializer.fromJson<int>(
        json['effectiveMilliseconds'],
      ),
      sequence: serializer.fromJson<int>(json['sequence']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      accuracyMeters: serializer.fromJson<double?>(json['accuracyMeters']),
      capturedMilliseconds: serializer.fromJson<int?>(
        json['capturedMilliseconds'],
      ),
      permissionState: serializer.fromJson<String?>(json['permissionState']),
      workLocationId: serializer.fromJson<String?>(json['workLocationId']),
      locationValidation: serializer.fromJson<String>(
        json['locationValidation'],
      ),
      requestId: serializer.fromJson<String>(json['requestId']),
      source: serializer.fromJson<String>(json['source']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdMilliseconds: serializer.fromJson<int>(
        json['createdMilliseconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'attendanceDayId': serializer.toJson<String>(attendanceDayId),
      'companyId': serializer.toJson<String>(companyId),
      'employeeId': serializer.toJson<String>(employeeId),
      'eventType': serializer.toJson<String>(eventType),
      'deviceMilliseconds': serializer.toJson<int>(deviceMilliseconds),
      'serverMilliseconds': serializer.toJson<int?>(serverMilliseconds),
      'effectiveMilliseconds': serializer.toJson<int>(effectiveMilliseconds),
      'sequence': serializer.toJson<int>(sequence),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'accuracyMeters': serializer.toJson<double?>(accuracyMeters),
      'capturedMilliseconds': serializer.toJson<int?>(capturedMilliseconds),
      'permissionState': serializer.toJson<String?>(permissionState),
      'workLocationId': serializer.toJson<String?>(workLocationId),
      'locationValidation': serializer.toJson<String>(locationValidation),
      'requestId': serializer.toJson<String>(requestId),
      'source': serializer.toJson<String>(source),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdMilliseconds': serializer.toJson<int>(createdMilliseconds),
    };
  }

  AttendanceEventData copyWith({
    String? id,
    String? attendanceDayId,
    String? companyId,
    String? employeeId,
    String? eventType,
    int? deviceMilliseconds,
    Value<int?> serverMilliseconds = const Value.absent(),
    int? effectiveMilliseconds,
    int? sequence,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> accuracyMeters = const Value.absent(),
    Value<int?> capturedMilliseconds = const Value.absent(),
    Value<String?> permissionState = const Value.absent(),
    Value<String?> workLocationId = const Value.absent(),
    String? locationValidation,
    String? requestId,
    String? source,
    String? syncStatus,
    int? createdMilliseconds,
  }) => AttendanceEventData(
    id: id ?? this.id,
    attendanceDayId: attendanceDayId ?? this.attendanceDayId,
    companyId: companyId ?? this.companyId,
    employeeId: employeeId ?? this.employeeId,
    eventType: eventType ?? this.eventType,
    deviceMilliseconds: deviceMilliseconds ?? this.deviceMilliseconds,
    serverMilliseconds: serverMilliseconds.present
        ? serverMilliseconds.value
        : this.serverMilliseconds,
    effectiveMilliseconds: effectiveMilliseconds ?? this.effectiveMilliseconds,
    sequence: sequence ?? this.sequence,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    accuracyMeters: accuracyMeters.present
        ? accuracyMeters.value
        : this.accuracyMeters,
    capturedMilliseconds: capturedMilliseconds.present
        ? capturedMilliseconds.value
        : this.capturedMilliseconds,
    permissionState: permissionState.present
        ? permissionState.value
        : this.permissionState,
    workLocationId: workLocationId.present
        ? workLocationId.value
        : this.workLocationId,
    locationValidation: locationValidation ?? this.locationValidation,
    requestId: requestId ?? this.requestId,
    source: source ?? this.source,
    syncStatus: syncStatus ?? this.syncStatus,
    createdMilliseconds: createdMilliseconds ?? this.createdMilliseconds,
  );
  AttendanceEventData copyWithCompanion(AttendanceEventsCompanion data) {
    return AttendanceEventData(
      id: data.id.present ? data.id.value : this.id,
      attendanceDayId: data.attendanceDayId.present
          ? data.attendanceDayId.value
          : this.attendanceDayId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      deviceMilliseconds: data.deviceMilliseconds.present
          ? data.deviceMilliseconds.value
          : this.deviceMilliseconds,
      serverMilliseconds: data.serverMilliseconds.present
          ? data.serverMilliseconds.value
          : this.serverMilliseconds,
      effectiveMilliseconds: data.effectiveMilliseconds.present
          ? data.effectiveMilliseconds.value
          : this.effectiveMilliseconds,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
      capturedMilliseconds: data.capturedMilliseconds.present
          ? data.capturedMilliseconds.value
          : this.capturedMilliseconds,
      permissionState: data.permissionState.present
          ? data.permissionState.value
          : this.permissionState,
      workLocationId: data.workLocationId.present
          ? data.workLocationId.value
          : this.workLocationId,
      locationValidation: data.locationValidation.present
          ? data.locationValidation.value
          : this.locationValidation,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      source: data.source.present ? data.source.value : this.source,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdMilliseconds: data.createdMilliseconds.present
          ? data.createdMilliseconds.value
          : this.createdMilliseconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEventData(')
          ..write('id: $id, ')
          ..write('attendanceDayId: $attendanceDayId, ')
          ..write('companyId: $companyId, ')
          ..write('employeeId: $employeeId, ')
          ..write('eventType: $eventType, ')
          ..write('deviceMilliseconds: $deviceMilliseconds, ')
          ..write('serverMilliseconds: $serverMilliseconds, ')
          ..write('effectiveMilliseconds: $effectiveMilliseconds, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('capturedMilliseconds: $capturedMilliseconds, ')
          ..write('permissionState: $permissionState, ')
          ..write('workLocationId: $workLocationId, ')
          ..write('locationValidation: $locationValidation, ')
          ..write('requestId: $requestId, ')
          ..write('source: $source, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdMilliseconds: $createdMilliseconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attendanceDayId,
    companyId,
    employeeId,
    eventType,
    deviceMilliseconds,
    serverMilliseconds,
    effectiveMilliseconds,
    sequence,
    latitude,
    longitude,
    accuracyMeters,
    capturedMilliseconds,
    permissionState,
    workLocationId,
    locationValidation,
    requestId,
    source,
    syncStatus,
    createdMilliseconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceEventData &&
          other.id == this.id &&
          other.attendanceDayId == this.attendanceDayId &&
          other.companyId == this.companyId &&
          other.employeeId == this.employeeId &&
          other.eventType == this.eventType &&
          other.deviceMilliseconds == this.deviceMilliseconds &&
          other.serverMilliseconds == this.serverMilliseconds &&
          other.effectiveMilliseconds == this.effectiveMilliseconds &&
          other.sequence == this.sequence &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracyMeters == this.accuracyMeters &&
          other.capturedMilliseconds == this.capturedMilliseconds &&
          other.permissionState == this.permissionState &&
          other.workLocationId == this.workLocationId &&
          other.locationValidation == this.locationValidation &&
          other.requestId == this.requestId &&
          other.source == this.source &&
          other.syncStatus == this.syncStatus &&
          other.createdMilliseconds == this.createdMilliseconds);
}

class AttendanceEventsCompanion extends UpdateCompanion<AttendanceEventData> {
  final Value<String> id;
  final Value<String> attendanceDayId;
  final Value<String> companyId;
  final Value<String> employeeId;
  final Value<String> eventType;
  final Value<int> deviceMilliseconds;
  final Value<int?> serverMilliseconds;
  final Value<int> effectiveMilliseconds;
  final Value<int> sequence;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> accuracyMeters;
  final Value<int?> capturedMilliseconds;
  final Value<String?> permissionState;
  final Value<String?> workLocationId;
  final Value<String> locationValidation;
  final Value<String> requestId;
  final Value<String> source;
  final Value<String> syncStatus;
  final Value<int> createdMilliseconds;
  final Value<int> rowid;
  const AttendanceEventsCompanion({
    this.id = const Value.absent(),
    this.attendanceDayId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.deviceMilliseconds = const Value.absent(),
    this.serverMilliseconds = const Value.absent(),
    this.effectiveMilliseconds = const Value.absent(),
    this.sequence = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    this.capturedMilliseconds = const Value.absent(),
    this.permissionState = const Value.absent(),
    this.workLocationId = const Value.absent(),
    this.locationValidation = const Value.absent(),
    this.requestId = const Value.absent(),
    this.source = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdMilliseconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceEventsCompanion.insert({
    required String id,
    required String attendanceDayId,
    required String companyId,
    required String employeeId,
    required String eventType,
    required int deviceMilliseconds,
    this.serverMilliseconds = const Value.absent(),
    required int effectiveMilliseconds,
    required int sequence,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    this.capturedMilliseconds = const Value.absent(),
    this.permissionState = const Value.absent(),
    this.workLocationId = const Value.absent(),
    required String locationValidation,
    required String requestId,
    required String source,
    required String syncStatus,
    required int createdMilliseconds,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       attendanceDayId = Value(attendanceDayId),
       companyId = Value(companyId),
       employeeId = Value(employeeId),
       eventType = Value(eventType),
       deviceMilliseconds = Value(deviceMilliseconds),
       effectiveMilliseconds = Value(effectiveMilliseconds),
       sequence = Value(sequence),
       locationValidation = Value(locationValidation),
       requestId = Value(requestId),
       source = Value(source),
       syncStatus = Value(syncStatus),
       createdMilliseconds = Value(createdMilliseconds);
  static Insertable<AttendanceEventData> custom({
    Expression<String>? id,
    Expression<String>? attendanceDayId,
    Expression<String>? companyId,
    Expression<String>? employeeId,
    Expression<String>? eventType,
    Expression<int>? deviceMilliseconds,
    Expression<int>? serverMilliseconds,
    Expression<int>? effectiveMilliseconds,
    Expression<int>? sequence,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracyMeters,
    Expression<int>? capturedMilliseconds,
    Expression<String>? permissionState,
    Expression<String>? workLocationId,
    Expression<String>? locationValidation,
    Expression<String>? requestId,
    Expression<String>? source,
    Expression<String>? syncStatus,
    Expression<int>? createdMilliseconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attendanceDayId != null) 'attendance_day_id': attendanceDayId,
      if (companyId != null) 'company_id': companyId,
      if (employeeId != null) 'employee_id': employeeId,
      if (eventType != null) 'event_type': eventType,
      if (deviceMilliseconds != null) 'device_milliseconds': deviceMilliseconds,
      if (serverMilliseconds != null) 'server_milliseconds': serverMilliseconds,
      if (effectiveMilliseconds != null)
        'effective_milliseconds': effectiveMilliseconds,
      if (sequence != null) 'sequence': sequence,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (capturedMilliseconds != null)
        'captured_milliseconds': capturedMilliseconds,
      if (permissionState != null) 'permission_state': permissionState,
      if (workLocationId != null) 'work_location_id': workLocationId,
      if (locationValidation != null) 'location_validation': locationValidation,
      if (requestId != null) 'request_id': requestId,
      if (source != null) 'source': source,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdMilliseconds != null)
        'created_milliseconds': createdMilliseconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? attendanceDayId,
    Value<String>? companyId,
    Value<String>? employeeId,
    Value<String>? eventType,
    Value<int>? deviceMilliseconds,
    Value<int?>? serverMilliseconds,
    Value<int>? effectiveMilliseconds,
    Value<int>? sequence,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? accuracyMeters,
    Value<int?>? capturedMilliseconds,
    Value<String?>? permissionState,
    Value<String?>? workLocationId,
    Value<String>? locationValidation,
    Value<String>? requestId,
    Value<String>? source,
    Value<String>? syncStatus,
    Value<int>? createdMilliseconds,
    Value<int>? rowid,
  }) {
    return AttendanceEventsCompanion(
      id: id ?? this.id,
      attendanceDayId: attendanceDayId ?? this.attendanceDayId,
      companyId: companyId ?? this.companyId,
      employeeId: employeeId ?? this.employeeId,
      eventType: eventType ?? this.eventType,
      deviceMilliseconds: deviceMilliseconds ?? this.deviceMilliseconds,
      serverMilliseconds: serverMilliseconds ?? this.serverMilliseconds,
      effectiveMilliseconds:
          effectiveMilliseconds ?? this.effectiveMilliseconds,
      sequence: sequence ?? this.sequence,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      capturedMilliseconds: capturedMilliseconds ?? this.capturedMilliseconds,
      permissionState: permissionState ?? this.permissionState,
      workLocationId: workLocationId ?? this.workLocationId,
      locationValidation: locationValidation ?? this.locationValidation,
      requestId: requestId ?? this.requestId,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
      createdMilliseconds: createdMilliseconds ?? this.createdMilliseconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (attendanceDayId.present) {
      map['attendance_day_id'] = Variable<String>(attendanceDayId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (deviceMilliseconds.present) {
      map['device_milliseconds'] = Variable<int>(deviceMilliseconds.value);
    }
    if (serverMilliseconds.present) {
      map['server_milliseconds'] = Variable<int>(serverMilliseconds.value);
    }
    if (effectiveMilliseconds.present) {
      map['effective_milliseconds'] = Variable<int>(
        effectiveMilliseconds.value,
      );
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    if (capturedMilliseconds.present) {
      map['captured_milliseconds'] = Variable<int>(capturedMilliseconds.value);
    }
    if (permissionState.present) {
      map['permission_state'] = Variable<String>(permissionState.value);
    }
    if (workLocationId.present) {
      map['work_location_id'] = Variable<String>(workLocationId.value);
    }
    if (locationValidation.present) {
      map['location_validation'] = Variable<String>(locationValidation.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdMilliseconds.present) {
      map['created_milliseconds'] = Variable<int>(createdMilliseconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEventsCompanion(')
          ..write('id: $id, ')
          ..write('attendanceDayId: $attendanceDayId, ')
          ..write('companyId: $companyId, ')
          ..write('employeeId: $employeeId, ')
          ..write('eventType: $eventType, ')
          ..write('deviceMilliseconds: $deviceMilliseconds, ')
          ..write('serverMilliseconds: $serverMilliseconds, ')
          ..write('effectiveMilliseconds: $effectiveMilliseconds, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('capturedMilliseconds: $capturedMilliseconds, ')
          ..write('permissionState: $permissionState, ')
          ..write('workLocationId: $workLocationId, ')
          ..write('locationValidation: $locationValidation, ')
          ..write('requestId: $requestId, ')
          ..write('source: $source, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdMilliseconds: $createdMilliseconds, ')
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

class $ShiftRecordsTable extends ShiftRecords
    with TableInfo<$ShiftRecordsTable, ShiftRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workingDayMaskMeta = const VerificationMeta(
    'workingDayMask',
  );
  @override
  late final GeneratedColumn<int> workingDayMask = GeneratedColumn<int>(
    'working_day_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gracePeriodMinutesMeta =
      const VerificationMeta('gracePeriodMinutes');
  @override
  late final GeneratedColumn<int> gracePeriodMinutes = GeneratedColumn<int>(
    'grace_period_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breakModeMeta = const VerificationMeta(
    'breakMode',
  );
  @override
  late final GeneratedColumn<String> breakMode = GeneratedColumn<String>(
    'break_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultBreakMinutesMeta =
      const VerificationMeta('defaultBreakMinutes');
  @override
  late final GeneratedColumn<int> defaultBreakMinutes = GeneratedColumn<int>(
    'default_break_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minimumWorkMinutesMeta =
      const VerificationMeta('minimumWorkMinutes');
  @override
  late final GeneratedColumn<int> minimumWorkMinutes = GeneratedColumn<int>(
    'minimum_work_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    normalizedName,
    status,
    createdAt,
    updatedAt,
    syncStatus,
    code,
    startMinutes,
    endMinutes,
    workingDayMask,
    gracePeriodMinutes,
    breakMode,
    defaultBreakMinutes,
    minimumWorkMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shift_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftRecord> instance, {
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
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinutesMeta);
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinutesMeta);
    }
    if (data.containsKey('working_day_mask')) {
      context.handle(
        _workingDayMaskMeta,
        workingDayMask.isAcceptableOrUnknown(
          data['working_day_mask']!,
          _workingDayMaskMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workingDayMaskMeta);
    }
    if (data.containsKey('grace_period_minutes')) {
      context.handle(
        _gracePeriodMinutesMeta,
        gracePeriodMinutes.isAcceptableOrUnknown(
          data['grace_period_minutes']!,
          _gracePeriodMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gracePeriodMinutesMeta);
    }
    if (data.containsKey('break_mode')) {
      context.handle(
        _breakModeMeta,
        breakMode.isAcceptableOrUnknown(data['break_mode']!, _breakModeMeta),
      );
    } else if (isInserting) {
      context.missing(_breakModeMeta);
    }
    if (data.containsKey('default_break_minutes')) {
      context.handle(
        _defaultBreakMinutesMeta,
        defaultBreakMinutes.isAcceptableOrUnknown(
          data['default_break_minutes']!,
          _defaultBreakMinutesMeta,
        ),
      );
    }
    if (data.containsKey('minimum_work_minutes')) {
      context.handle(
        _minimumWorkMinutesMeta,
        minimumWorkMinutes.isAcceptableOrUnknown(
          data['minimum_work_minutes']!,
          _minimumWorkMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftRecord(
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
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      )!,
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      )!,
      workingDayMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}working_day_mask'],
      )!,
      gracePeriodMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grace_period_minutes'],
      )!,
      breakMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}break_mode'],
      )!,
      defaultBreakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_break_minutes'],
      ),
      minimumWorkMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_work_minutes'],
      ),
    );
  }

  @override
  $ShiftRecordsTable createAlias(String alias) {
    return $ShiftRecordsTable(attachedDatabase, alias);
  }
}

class ShiftRecord extends DataClass implements Insertable<ShiftRecord> {
  final String id;
  final String companyId;
  final String name;
  final String normalizedName;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final String? code;
  final int startMinutes;
  final int endMinutes;
  final int workingDayMask;
  final int gracePeriodMinutes;
  final String breakMode;
  final int? defaultBreakMinutes;
  final int? minimumWorkMinutes;
  const ShiftRecord({
    required this.id,
    required this.companyId,
    required this.name,
    required this.normalizedName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.code,
    required this.startMinutes,
    required this.endMinutes,
    required this.workingDayMask,
    required this.gracePeriodMinutes,
    required this.breakMode,
    this.defaultBreakMinutes,
    this.minimumWorkMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['start_minutes'] = Variable<int>(startMinutes);
    map['end_minutes'] = Variable<int>(endMinutes);
    map['working_day_mask'] = Variable<int>(workingDayMask);
    map['grace_period_minutes'] = Variable<int>(gracePeriodMinutes);
    map['break_mode'] = Variable<String>(breakMode);
    if (!nullToAbsent || defaultBreakMinutes != null) {
      map['default_break_minutes'] = Variable<int>(defaultBreakMinutes);
    }
    if (!nullToAbsent || minimumWorkMinutes != null) {
      map['minimum_work_minutes'] = Variable<int>(minimumWorkMinutes);
    }
    return map;
  }

  ShiftRecordsCompanion toCompanion(bool nullToAbsent) {
    return ShiftRecordsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      startMinutes: Value(startMinutes),
      endMinutes: Value(endMinutes),
      workingDayMask: Value(workingDayMask),
      gracePeriodMinutes: Value(gracePeriodMinutes),
      breakMode: Value(breakMode),
      defaultBreakMinutes: defaultBreakMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultBreakMinutes),
      minimumWorkMinutes: minimumWorkMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumWorkMinutes),
    );
  }

  factory ShiftRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftRecord(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      code: serializer.fromJson<String?>(json['code']),
      startMinutes: serializer.fromJson<int>(json['startMinutes']),
      endMinutes: serializer.fromJson<int>(json['endMinutes']),
      workingDayMask: serializer.fromJson<int>(json['workingDayMask']),
      gracePeriodMinutes: serializer.fromJson<int>(json['gracePeriodMinutes']),
      breakMode: serializer.fromJson<String>(json['breakMode']),
      defaultBreakMinutes: serializer.fromJson<int?>(
        json['defaultBreakMinutes'],
      ),
      minimumWorkMinutes: serializer.fromJson<int?>(json['minimumWorkMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'code': serializer.toJson<String?>(code),
      'startMinutes': serializer.toJson<int>(startMinutes),
      'endMinutes': serializer.toJson<int>(endMinutes),
      'workingDayMask': serializer.toJson<int>(workingDayMask),
      'gracePeriodMinutes': serializer.toJson<int>(gracePeriodMinutes),
      'breakMode': serializer.toJson<String>(breakMode),
      'defaultBreakMinutes': serializer.toJson<int?>(defaultBreakMinutes),
      'minimumWorkMinutes': serializer.toJson<int?>(minimumWorkMinutes),
    };
  }

  ShiftRecord copyWith({
    String? id,
    String? companyId,
    String? name,
    String? normalizedName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    Value<String?> code = const Value.absent(),
    int? startMinutes,
    int? endMinutes,
    int? workingDayMask,
    int? gracePeriodMinutes,
    String? breakMode,
    Value<int?> defaultBreakMinutes = const Value.absent(),
    Value<int?> minimumWorkMinutes = const Value.absent(),
  }) => ShiftRecord(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    code: code.present ? code.value : this.code,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    workingDayMask: workingDayMask ?? this.workingDayMask,
    gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
    breakMode: breakMode ?? this.breakMode,
    defaultBreakMinutes: defaultBreakMinutes.present
        ? defaultBreakMinutes.value
        : this.defaultBreakMinutes,
    minimumWorkMinutes: minimumWorkMinutes.present
        ? minimumWorkMinutes.value
        : this.minimumWorkMinutes,
  );
  ShiftRecord copyWithCompanion(ShiftRecordsCompanion data) {
    return ShiftRecord(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      code: data.code.present ? data.code.value : this.code,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      workingDayMask: data.workingDayMask.present
          ? data.workingDayMask.value
          : this.workingDayMask,
      gracePeriodMinutes: data.gracePeriodMinutes.present
          ? data.gracePeriodMinutes.value
          : this.gracePeriodMinutes,
      breakMode: data.breakMode.present ? data.breakMode.value : this.breakMode,
      defaultBreakMinutes: data.defaultBreakMinutes.present
          ? data.defaultBreakMinutes.value
          : this.defaultBreakMinutes,
      minimumWorkMinutes: data.minimumWorkMinutes.present
          ? data.minimumWorkMinutes.value
          : this.minimumWorkMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftRecord(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('code: $code, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('workingDayMask: $workingDayMask, ')
          ..write('gracePeriodMinutes: $gracePeriodMinutes, ')
          ..write('breakMode: $breakMode, ')
          ..write('defaultBreakMinutes: $defaultBreakMinutes, ')
          ..write('minimumWorkMinutes: $minimumWorkMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    normalizedName,
    status,
    createdAt,
    updatedAt,
    syncStatus,
    code,
    startMinutes,
    endMinutes,
    workingDayMask,
    gracePeriodMinutes,
    breakMode,
    defaultBreakMinutes,
    minimumWorkMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftRecord &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.code == this.code &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.workingDayMask == this.workingDayMask &&
          other.gracePeriodMinutes == this.gracePeriodMinutes &&
          other.breakMode == this.breakMode &&
          other.defaultBreakMinutes == this.defaultBreakMinutes &&
          other.minimumWorkMinutes == this.minimumWorkMinutes);
}

class ShiftRecordsCompanion extends UpdateCompanion<ShiftRecord> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<String?> code;
  final Value<int> startMinutes;
  final Value<int> endMinutes;
  final Value<int> workingDayMask;
  final Value<int> gracePeriodMinutes;
  final Value<String> breakMode;
  final Value<int?> defaultBreakMinutes;
  final Value<int?> minimumWorkMinutes;
  final Value<int> rowid;
  const ShiftRecordsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.code = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.workingDayMask = const Value.absent(),
    this.gracePeriodMinutes = const Value.absent(),
    this.breakMode = const Value.absent(),
    this.defaultBreakMinutes = const Value.absent(),
    this.minimumWorkMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftRecordsCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String normalizedName,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String syncStatus,
    this.code = const Value.absent(),
    required int startMinutes,
    required int endMinutes,
    required int workingDayMask,
    required int gracePeriodMinutes,
    required String breakMode,
    this.defaultBreakMinutes = const Value.absent(),
    this.minimumWorkMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus),
       startMinutes = Value(startMinutes),
       endMinutes = Value(endMinutes),
       workingDayMask = Value(workingDayMask),
       gracePeriodMinutes = Value(gracePeriodMinutes),
       breakMode = Value(breakMode);
  static Insertable<ShiftRecord> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<String>? code,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<int>? workingDayMask,
    Expression<int>? gracePeriodMinutes,
    Expression<String>? breakMode,
    Expression<int>? defaultBreakMinutes,
    Expression<int>? minimumWorkMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (code != null) 'code': code,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (workingDayMask != null) 'working_day_mask': workingDayMask,
      if (gracePeriodMinutes != null)
        'grace_period_minutes': gracePeriodMinutes,
      if (breakMode != null) 'break_mode': breakMode,
      if (defaultBreakMinutes != null)
        'default_break_minutes': defaultBreakMinutes,
      if (minimumWorkMinutes != null)
        'minimum_work_minutes': minimumWorkMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<String?>? code,
    Value<int>? startMinutes,
    Value<int>? endMinutes,
    Value<int>? workingDayMask,
    Value<int>? gracePeriodMinutes,
    Value<String>? breakMode,
    Value<int?>? defaultBreakMinutes,
    Value<int?>? minimumWorkMinutes,
    Value<int>? rowid,
  }) {
    return ShiftRecordsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      code: code ?? this.code,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      workingDayMask: workingDayMask ?? this.workingDayMask,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      breakMode: breakMode ?? this.breakMode,
      defaultBreakMinutes: defaultBreakMinutes ?? this.defaultBreakMinutes,
      minimumWorkMinutes: minimumWorkMinutes ?? this.minimumWorkMinutes,
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
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (workingDayMask.present) {
      map['working_day_mask'] = Variable<int>(workingDayMask.value);
    }
    if (gracePeriodMinutes.present) {
      map['grace_period_minutes'] = Variable<int>(gracePeriodMinutes.value);
    }
    if (breakMode.present) {
      map['break_mode'] = Variable<String>(breakMode.value);
    }
    if (defaultBreakMinutes.present) {
      map['default_break_minutes'] = Variable<int>(defaultBreakMinutes.value);
    }
    if (minimumWorkMinutes.present) {
      map['minimum_work_minutes'] = Variable<int>(minimumWorkMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftRecordsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('code: $code, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('workingDayMask: $workingDayMask, ')
          ..write('gracePeriodMinutes: $gracePeriodMinutes, ')
          ..write('breakMode: $breakMode, ')
          ..write('defaultBreakMinutes: $defaultBreakMinutes, ')
          ..write('minimumWorkMinutes: $minimumWorkMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkLocationRecordsTable extends WorkLocationRecords
    with TableInfo<$WorkLocationRecordsTable, WorkLocationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkLocationRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressLine1Meta = const VerificationMeta(
    'addressLine1',
  );
  @override
  late final GeneratedColumn<String> addressLine1 = GeneratedColumn<String>(
    'address_line1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressLine2Meta = const VerificationMeta(
    'addressLine2',
  );
  @override
  late final GeneratedColumn<String> addressLine2 = GeneratedColumn<String>(
    'address_line2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateRegionMeta = const VerificationMeta(
    'stateRegion',
  );
  @override
  late final GeneratedColumn<String> stateRegion = GeneratedColumn<String>(
    'state_region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _postalCodeMeta = const VerificationMeta(
    'postalCode',
  );
  @override
  late final GeneratedColumn<String> postalCode = GeneratedColumn<String>(
    'postal_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowedRadiusMetersMeta =
      const VerificationMeta('allowedRadiusMeters');
  @override
  late final GeneratedColumn<double> allowedRadiusMeters =
      GeneratedColumn<double>(
        'allowed_radius_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _maximumAccuracyMetersMeta =
      const VerificationMeta('maximumAccuracyMeters');
  @override
  late final GeneratedColumn<double> maximumAccuracyMeters =
      GeneratedColumn<double>(
        'maximum_accuracy_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _validationModeMeta = const VerificationMeta(
    'validationMode',
  );
  @override
  late final GeneratedColumn<String> validationMode = GeneratedColumn<String>(
    'validation_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    normalizedName,
    status,
    createdAt,
    updatedAt,
    syncStatus,
    code,
    addressLine1,
    addressLine2,
    city,
    stateRegion,
    postalCode,
    countryCode,
    latitude,
    longitude,
    allowedRadiusMeters,
    maximumAccuracyMeters,
    validationMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_location_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkLocationRecord> instance, {
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
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('address_line1')) {
      context.handle(
        _addressLine1Meta,
        addressLine1.isAcceptableOrUnknown(
          data['address_line1']!,
          _addressLine1Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addressLine1Meta);
    }
    if (data.containsKey('address_line2')) {
      context.handle(
        _addressLine2Meta,
        addressLine2.isAcceptableOrUnknown(
          data['address_line2']!,
          _addressLine2Meta,
        ),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('state_region')) {
      context.handle(
        _stateRegionMeta,
        stateRegion.isAcceptableOrUnknown(
          data['state_region']!,
          _stateRegionMeta,
        ),
      );
    }
    if (data.containsKey('postal_code')) {
      context.handle(
        _postalCodeMeta,
        postalCode.isAcceptableOrUnknown(data['postal_code']!, _postalCodeMeta),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('allowed_radius_meters')) {
      context.handle(
        _allowedRadiusMetersMeta,
        allowedRadiusMeters.isAcceptableOrUnknown(
          data['allowed_radius_meters']!,
          _allowedRadiusMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowedRadiusMetersMeta);
    }
    if (data.containsKey('maximum_accuracy_meters')) {
      context.handle(
        _maximumAccuracyMetersMeta,
        maximumAccuracyMeters.isAcceptableOrUnknown(
          data['maximum_accuracy_meters']!,
          _maximumAccuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('validation_mode')) {
      context.handle(
        _validationModeMeta,
        validationMode.isAcceptableOrUnknown(
          data['validation_mode']!,
          _validationModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_validationModeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkLocationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkLocationRecord(
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
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      addressLine1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_line1'],
      )!,
      addressLine2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_line2'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      stateRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_region'],
      )!,
      postalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postal_code'],
      )!,
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      allowedRadiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}allowed_radius_meters'],
      )!,
      maximumAccuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}maximum_accuracy_meters'],
      ),
      validationMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}validation_mode'],
      )!,
    );
  }

  @override
  $WorkLocationRecordsTable createAlias(String alias) {
    return $WorkLocationRecordsTable(attachedDatabase, alias);
  }
}

class WorkLocationRecord extends DataClass
    implements Insertable<WorkLocationRecord> {
  final String id;
  final String companyId;
  final String name;
  final String normalizedName;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final String? code;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String stateRegion;
  final String postalCode;
  final String countryCode;
  final double latitude;
  final double longitude;
  final double allowedRadiusMeters;
  final double? maximumAccuracyMeters;
  final String validationMode;
  const WorkLocationRecord({
    required this.id,
    required this.companyId,
    required this.name,
    required this.normalizedName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.code,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.stateRegion,
    required this.postalCode,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusMeters,
    this.maximumAccuracyMeters,
    required this.validationMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['address_line1'] = Variable<String>(addressLine1);
    map['address_line2'] = Variable<String>(addressLine2);
    map['city'] = Variable<String>(city);
    map['state_region'] = Variable<String>(stateRegion);
    map['postal_code'] = Variable<String>(postalCode);
    map['country_code'] = Variable<String>(countryCode);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['allowed_radius_meters'] = Variable<double>(allowedRadiusMeters);
    if (!nullToAbsent || maximumAccuracyMeters != null) {
      map['maximum_accuracy_meters'] = Variable<double>(maximumAccuracyMeters);
    }
    map['validation_mode'] = Variable<String>(validationMode);
    return map;
  }

  WorkLocationRecordsCompanion toCompanion(bool nullToAbsent) {
    return WorkLocationRecordsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      addressLine1: Value(addressLine1),
      addressLine2: Value(addressLine2),
      city: Value(city),
      stateRegion: Value(stateRegion),
      postalCode: Value(postalCode),
      countryCode: Value(countryCode),
      latitude: Value(latitude),
      longitude: Value(longitude),
      allowedRadiusMeters: Value(allowedRadiusMeters),
      maximumAccuracyMeters: maximumAccuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(maximumAccuracyMeters),
      validationMode: Value(validationMode),
    );
  }

  factory WorkLocationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkLocationRecord(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      code: serializer.fromJson<String?>(json['code']),
      addressLine1: serializer.fromJson<String>(json['addressLine1']),
      addressLine2: serializer.fromJson<String>(json['addressLine2']),
      city: serializer.fromJson<String>(json['city']),
      stateRegion: serializer.fromJson<String>(json['stateRegion']),
      postalCode: serializer.fromJson<String>(json['postalCode']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      allowedRadiusMeters: serializer.fromJson<double>(
        json['allowedRadiusMeters'],
      ),
      maximumAccuracyMeters: serializer.fromJson<double?>(
        json['maximumAccuracyMeters'],
      ),
      validationMode: serializer.fromJson<String>(json['validationMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'code': serializer.toJson<String?>(code),
      'addressLine1': serializer.toJson<String>(addressLine1),
      'addressLine2': serializer.toJson<String>(addressLine2),
      'city': serializer.toJson<String>(city),
      'stateRegion': serializer.toJson<String>(stateRegion),
      'postalCode': serializer.toJson<String>(postalCode),
      'countryCode': serializer.toJson<String>(countryCode),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'allowedRadiusMeters': serializer.toJson<double>(allowedRadiusMeters),
      'maximumAccuracyMeters': serializer.toJson<double?>(
        maximumAccuracyMeters,
      ),
      'validationMode': serializer.toJson<String>(validationMode),
    };
  }

  WorkLocationRecord copyWith({
    String? id,
    String? companyId,
    String? name,
    String? normalizedName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    Value<String?> code = const Value.absent(),
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? stateRegion,
    String? postalCode,
    String? countryCode,
    double? latitude,
    double? longitude,
    double? allowedRadiusMeters,
    Value<double?> maximumAccuracyMeters = const Value.absent(),
    String? validationMode,
  }) => WorkLocationRecord(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    code: code.present ? code.value : this.code,
    addressLine1: addressLine1 ?? this.addressLine1,
    addressLine2: addressLine2 ?? this.addressLine2,
    city: city ?? this.city,
    stateRegion: stateRegion ?? this.stateRegion,
    postalCode: postalCode ?? this.postalCode,
    countryCode: countryCode ?? this.countryCode,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
    maximumAccuracyMeters: maximumAccuracyMeters.present
        ? maximumAccuracyMeters.value
        : this.maximumAccuracyMeters,
    validationMode: validationMode ?? this.validationMode,
  );
  WorkLocationRecord copyWithCompanion(WorkLocationRecordsCompanion data) {
    return WorkLocationRecord(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      code: data.code.present ? data.code.value : this.code,
      addressLine1: data.addressLine1.present
          ? data.addressLine1.value
          : this.addressLine1,
      addressLine2: data.addressLine2.present
          ? data.addressLine2.value
          : this.addressLine2,
      city: data.city.present ? data.city.value : this.city,
      stateRegion: data.stateRegion.present
          ? data.stateRegion.value
          : this.stateRegion,
      postalCode: data.postalCode.present
          ? data.postalCode.value
          : this.postalCode,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      allowedRadiusMeters: data.allowedRadiusMeters.present
          ? data.allowedRadiusMeters.value
          : this.allowedRadiusMeters,
      maximumAccuracyMeters: data.maximumAccuracyMeters.present
          ? data.maximumAccuracyMeters.value
          : this.maximumAccuracyMeters,
      validationMode: data.validationMode.present
          ? data.validationMode.value
          : this.validationMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkLocationRecord(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('code: $code, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('city: $city, ')
          ..write('stateRegion: $stateRegion, ')
          ..write('postalCode: $postalCode, ')
          ..write('countryCode: $countryCode, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('allowedRadiusMeters: $allowedRadiusMeters, ')
          ..write('maximumAccuracyMeters: $maximumAccuracyMeters, ')
          ..write('validationMode: $validationMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    normalizedName,
    status,
    createdAt,
    updatedAt,
    syncStatus,
    code,
    addressLine1,
    addressLine2,
    city,
    stateRegion,
    postalCode,
    countryCode,
    latitude,
    longitude,
    allowedRadiusMeters,
    maximumAccuracyMeters,
    validationMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkLocationRecord &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.code == this.code &&
          other.addressLine1 == this.addressLine1 &&
          other.addressLine2 == this.addressLine2 &&
          other.city == this.city &&
          other.stateRegion == this.stateRegion &&
          other.postalCode == this.postalCode &&
          other.countryCode == this.countryCode &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.allowedRadiusMeters == this.allowedRadiusMeters &&
          other.maximumAccuracyMeters == this.maximumAccuracyMeters &&
          other.validationMode == this.validationMode);
}

class WorkLocationRecordsCompanion extends UpdateCompanion<WorkLocationRecord> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<String?> code;
  final Value<String> addressLine1;
  final Value<String> addressLine2;
  final Value<String> city;
  final Value<String> stateRegion;
  final Value<String> postalCode;
  final Value<String> countryCode;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> allowedRadiusMeters;
  final Value<double?> maximumAccuracyMeters;
  final Value<String> validationMode;
  final Value<int> rowid;
  const WorkLocationRecordsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.code = const Value.absent(),
    this.addressLine1 = const Value.absent(),
    this.addressLine2 = const Value.absent(),
    this.city = const Value.absent(),
    this.stateRegion = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.allowedRadiusMeters = const Value.absent(),
    this.maximumAccuracyMeters = const Value.absent(),
    this.validationMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkLocationRecordsCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String normalizedName,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String syncStatus,
    this.code = const Value.absent(),
    required String addressLine1,
    this.addressLine2 = const Value.absent(),
    required String city,
    this.stateRegion = const Value.absent(),
    this.postalCode = const Value.absent(),
    required String countryCode,
    required double latitude,
    required double longitude,
    required double allowedRadiusMeters,
    this.maximumAccuracyMeters = const Value.absent(),
    required String validationMode,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus),
       addressLine1 = Value(addressLine1),
       city = Value(city),
       countryCode = Value(countryCode),
       latitude = Value(latitude),
       longitude = Value(longitude),
       allowedRadiusMeters = Value(allowedRadiusMeters),
       validationMode = Value(validationMode);
  static Insertable<WorkLocationRecord> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<String>? code,
    Expression<String>? addressLine1,
    Expression<String>? addressLine2,
    Expression<String>? city,
    Expression<String>? stateRegion,
    Expression<String>? postalCode,
    Expression<String>? countryCode,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? allowedRadiusMeters,
    Expression<double>? maximumAccuracyMeters,
    Expression<String>? validationMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (code != null) 'code': code,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (city != null) 'city': city,
      if (stateRegion != null) 'state_region': stateRegion,
      if (postalCode != null) 'postal_code': postalCode,
      if (countryCode != null) 'country_code': countryCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (allowedRadiusMeters != null)
        'allowed_radius_meters': allowedRadiusMeters,
      if (maximumAccuracyMeters != null)
        'maximum_accuracy_meters': maximumAccuracyMeters,
      if (validationMode != null) 'validation_mode': validationMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkLocationRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<String?>? code,
    Value<String>? addressLine1,
    Value<String>? addressLine2,
    Value<String>? city,
    Value<String>? stateRegion,
    Value<String>? postalCode,
    Value<String>? countryCode,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? allowedRadiusMeters,
    Value<double?>? maximumAccuracyMeters,
    Value<String>? validationMode,
    Value<int>? rowid,
  }) {
    return WorkLocationRecordsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      code: code ?? this.code,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      stateRegion: stateRegion ?? this.stateRegion,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
      maximumAccuracyMeters:
          maximumAccuracyMeters ?? this.maximumAccuracyMeters,
      validationMode: validationMode ?? this.validationMode,
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
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (addressLine1.present) {
      map['address_line1'] = Variable<String>(addressLine1.value);
    }
    if (addressLine2.present) {
      map['address_line2'] = Variable<String>(addressLine2.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (stateRegion.present) {
      map['state_region'] = Variable<String>(stateRegion.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (allowedRadiusMeters.present) {
      map['allowed_radius_meters'] = Variable<double>(
        allowedRadiusMeters.value,
      );
    }
    if (maximumAccuracyMeters.present) {
      map['maximum_accuracy_meters'] = Variable<double>(
        maximumAccuracyMeters.value,
      );
    }
    if (validationMode.present) {
      map['validation_mode'] = Variable<String>(validationMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkLocationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('code: $code, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('city: $city, ')
          ..write('stateRegion: $stateRegion, ')
          ..write('postalCode: $postalCode, ')
          ..write('countryCode: $countryCode, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('allowedRadiusMeters: $allowedRadiusMeters, ')
          ..write('maximumAccuracyMeters: $maximumAccuracyMeters, ')
          ..write('validationMode: $validationMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendancePolicyRecordsTable extends AttendancePolicyRecords
    with TableInfo<$AttendancePolicyRecordsTable, AttendancePolicyRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancePolicyRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _requireLocationMeta = const VerificationMeta(
    'requireLocation',
  );
  @override
  late final GeneratedColumn<bool> requireLocation = GeneratedColumn<bool>(
    'require_location',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("require_location" IN (0, 1))',
    ),
  );
  static const VerificationMeta _allowOutsideLocationMeta =
      const VerificationMeta('allowOutsideLocation');
  @override
  late final GeneratedColumn<bool> allowOutsideLocation = GeneratedColumn<bool>(
    'allow_outside_location',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_outside_location" IN (0, 1))',
    ),
  );
  static const VerificationMeta _allowRemoteAttendanceMeta =
      const VerificationMeta('allowRemoteAttendance');
  @override
  late final GeneratedColumn<bool> allowRemoteAttendance =
      GeneratedColumn<bool>(
        'allow_remote_attendance',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_remote_attendance" IN (0, 1))',
        ),
      );
  static const VerificationMeta _requireLocationOnPunchInMeta =
      const VerificationMeta('requireLocationOnPunchIn');
  @override
  late final GeneratedColumn<bool> requireLocationOnPunchIn =
      GeneratedColumn<bool>(
        'require_location_on_punch_in',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("require_location_on_punch_in" IN (0, 1))',
        ),
      );
  static const VerificationMeta _requireLocationOnPunchOutMeta =
      const VerificationMeta('requireLocationOnPunchOut');
  @override
  late final GeneratedColumn<bool> requireLocationOnPunchOut =
      GeneratedColumn<bool>(
        'require_location_on_punch_out',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("require_location_on_punch_out" IN (0, 1))',
        ),
      );
  static const VerificationMeta _requireLocationOnBreakMeta =
      const VerificationMeta('requireLocationOnBreak');
  @override
  late final GeneratedColumn<bool> requireLocationOnBreak =
      GeneratedColumn<bool>(
        'require_location_on_break',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("require_location_on_break" IN (0, 1))',
        ),
      );
  static const VerificationMeta _requireLocationAccuracyMeta =
      const VerificationMeta('requireLocationAccuracy');
  @override
  late final GeneratedColumn<bool> requireLocationAccuracy =
      GeneratedColumn<bool>(
        'require_location_accuracy',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("require_location_accuracy" IN (0, 1))',
        ),
      );
  static const VerificationMeta _maximumAcceptedAccuracyMetersMeta =
      const VerificationMeta('maximumAcceptedAccuracyMeters');
  @override
  late final GeneratedColumn<double> maximumAcceptedAccuracyMeters =
      GeneratedColumn<double>(
        'maximum_accepted_accuracy_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _trackBreaksMeta = const VerificationMeta(
    'trackBreaks',
  );
  @override
  late final GeneratedColumn<bool> trackBreaks = GeneratedColumn<bool>(
    'track_breaks',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_breaks" IN (0, 1))',
    ),
  );
  static const VerificationMeta _allowMultipleBreaksMeta =
      const VerificationMeta('allowMultipleBreaks');
  @override
  late final GeneratedColumn<bool> allowMultipleBreaks = GeneratedColumn<bool>(
    'allow_multiple_breaks',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_multiple_breaks" IN (0, 1))',
    ),
  );
  static const VerificationMeta _allowPunchOutDuringBreakMeta =
      const VerificationMeta('allowPunchOutDuringBreak');
  @override
  late final GeneratedColumn<bool> allowPunchOutDuringBreak =
      GeneratedColumn<bool>(
        'allow_punch_out_during_break',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_punch_out_during_break" IN (0, 1))',
        ),
      );
  static const VerificationMeta _allowEmployeeCorrectionRequestMeta =
      const VerificationMeta('allowEmployeeCorrectionRequest');
  @override
  late final GeneratedColumn<bool> allowEmployeeCorrectionRequest =
      GeneratedColumn<bool>(
        'allow_employee_correction_request',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_employee_correction_request" IN (0, 1))',
        ),
      );
  static const VerificationMeta _allowEarlyPunchInMeta = const VerificationMeta(
    'allowEarlyPunchIn',
  );
  @override
  late final GeneratedColumn<bool> allowEarlyPunchIn = GeneratedColumn<bool>(
    'allow_early_punch_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_early_punch_in" IN (0, 1))',
    ),
  );
  static const VerificationMeta _earlyPunchInLimitMinutesMeta =
      const VerificationMeta('earlyPunchInLimitMinutes');
  @override
  late final GeneratedColumn<int> earlyPunchInLimitMinutes =
      GeneratedColumn<int>(
        'early_punch_in_limit_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _allowLatePunchInMeta = const VerificationMeta(
    'allowLatePunchIn',
  );
  @override
  late final GeneratedColumn<bool> allowLatePunchIn = GeneratedColumn<bool>(
    'allow_late_punch_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_late_punch_in" IN (0, 1))',
    ),
  );
  static const VerificationMeta _allowEarlyPunchOutMeta =
      const VerificationMeta('allowEarlyPunchOut');
  @override
  late final GeneratedColumn<bool> allowEarlyPunchOut = GeneratedColumn<bool>(
    'allow_early_punch_out',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_early_punch_out" IN (0, 1))',
    ),
  );
  static const VerificationMeta _offlineModeMeta = const VerificationMeta(
    'offlineMode',
  );
  @override
  late final GeneratedColumn<String> offlineMode = GeneratedColumn<String>(
    'offline_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    normalizedName,
    status,
    createdAt,
    updatedAt,
    syncStatus,
    description,
    requireLocation,
    allowOutsideLocation,
    allowRemoteAttendance,
    requireLocationOnPunchIn,
    requireLocationOnPunchOut,
    requireLocationOnBreak,
    requireLocationAccuracy,
    maximumAcceptedAccuracyMeters,
    trackBreaks,
    allowMultipleBreaks,
    allowPunchOutDuringBreak,
    allowEmployeeCorrectionRequest,
    allowEarlyPunchIn,
    earlyPunchInLimitMinutes,
    allowLatePunchIn,
    allowEarlyPunchOut,
    offlineMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_policy_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendancePolicyRecord> instance, {
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
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('require_location')) {
      context.handle(
        _requireLocationMeta,
        requireLocation.isAcceptableOrUnknown(
          data['require_location']!,
          _requireLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requireLocationMeta);
    }
    if (data.containsKey('allow_outside_location')) {
      context.handle(
        _allowOutsideLocationMeta,
        allowOutsideLocation.isAcceptableOrUnknown(
          data['allow_outside_location']!,
          _allowOutsideLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowOutsideLocationMeta);
    }
    if (data.containsKey('allow_remote_attendance')) {
      context.handle(
        _allowRemoteAttendanceMeta,
        allowRemoteAttendance.isAcceptableOrUnknown(
          data['allow_remote_attendance']!,
          _allowRemoteAttendanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowRemoteAttendanceMeta);
    }
    if (data.containsKey('require_location_on_punch_in')) {
      context.handle(
        _requireLocationOnPunchInMeta,
        requireLocationOnPunchIn.isAcceptableOrUnknown(
          data['require_location_on_punch_in']!,
          _requireLocationOnPunchInMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requireLocationOnPunchInMeta);
    }
    if (data.containsKey('require_location_on_punch_out')) {
      context.handle(
        _requireLocationOnPunchOutMeta,
        requireLocationOnPunchOut.isAcceptableOrUnknown(
          data['require_location_on_punch_out']!,
          _requireLocationOnPunchOutMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requireLocationOnPunchOutMeta);
    }
    if (data.containsKey('require_location_on_break')) {
      context.handle(
        _requireLocationOnBreakMeta,
        requireLocationOnBreak.isAcceptableOrUnknown(
          data['require_location_on_break']!,
          _requireLocationOnBreakMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requireLocationOnBreakMeta);
    }
    if (data.containsKey('require_location_accuracy')) {
      context.handle(
        _requireLocationAccuracyMeta,
        requireLocationAccuracy.isAcceptableOrUnknown(
          data['require_location_accuracy']!,
          _requireLocationAccuracyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requireLocationAccuracyMeta);
    }
    if (data.containsKey('maximum_accepted_accuracy_meters')) {
      context.handle(
        _maximumAcceptedAccuracyMetersMeta,
        maximumAcceptedAccuracyMeters.isAcceptableOrUnknown(
          data['maximum_accepted_accuracy_meters']!,
          _maximumAcceptedAccuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('track_breaks')) {
      context.handle(
        _trackBreaksMeta,
        trackBreaks.isAcceptableOrUnknown(
          data['track_breaks']!,
          _trackBreaksMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackBreaksMeta);
    }
    if (data.containsKey('allow_multiple_breaks')) {
      context.handle(
        _allowMultipleBreaksMeta,
        allowMultipleBreaks.isAcceptableOrUnknown(
          data['allow_multiple_breaks']!,
          _allowMultipleBreaksMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowMultipleBreaksMeta);
    }
    if (data.containsKey('allow_punch_out_during_break')) {
      context.handle(
        _allowPunchOutDuringBreakMeta,
        allowPunchOutDuringBreak.isAcceptableOrUnknown(
          data['allow_punch_out_during_break']!,
          _allowPunchOutDuringBreakMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowPunchOutDuringBreakMeta);
    }
    if (data.containsKey('allow_employee_correction_request')) {
      context.handle(
        _allowEmployeeCorrectionRequestMeta,
        allowEmployeeCorrectionRequest.isAcceptableOrUnknown(
          data['allow_employee_correction_request']!,
          _allowEmployeeCorrectionRequestMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowEmployeeCorrectionRequestMeta);
    }
    if (data.containsKey('allow_early_punch_in')) {
      context.handle(
        _allowEarlyPunchInMeta,
        allowEarlyPunchIn.isAcceptableOrUnknown(
          data['allow_early_punch_in']!,
          _allowEarlyPunchInMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowEarlyPunchInMeta);
    }
    if (data.containsKey('early_punch_in_limit_minutes')) {
      context.handle(
        _earlyPunchInLimitMinutesMeta,
        earlyPunchInLimitMinutes.isAcceptableOrUnknown(
          data['early_punch_in_limit_minutes']!,
          _earlyPunchInLimitMinutesMeta,
        ),
      );
    }
    if (data.containsKey('allow_late_punch_in')) {
      context.handle(
        _allowLatePunchInMeta,
        allowLatePunchIn.isAcceptableOrUnknown(
          data['allow_late_punch_in']!,
          _allowLatePunchInMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowLatePunchInMeta);
    }
    if (data.containsKey('allow_early_punch_out')) {
      context.handle(
        _allowEarlyPunchOutMeta,
        allowEarlyPunchOut.isAcceptableOrUnknown(
          data['allow_early_punch_out']!,
          _allowEarlyPunchOutMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowEarlyPunchOutMeta);
    }
    if (data.containsKey('offline_mode')) {
      context.handle(
        _offlineModeMeta,
        offlineMode.isAcceptableOrUnknown(
          data['offline_mode']!,
          _offlineModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_offlineModeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendancePolicyRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendancePolicyRecord(
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
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      requireLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_location'],
      )!,
      allowOutsideLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_outside_location'],
      )!,
      allowRemoteAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_remote_attendance'],
      )!,
      requireLocationOnPunchIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_location_on_punch_in'],
      )!,
      requireLocationOnPunchOut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_location_on_punch_out'],
      )!,
      requireLocationOnBreak: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_location_on_break'],
      )!,
      requireLocationAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_location_accuracy'],
      )!,
      maximumAcceptedAccuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}maximum_accepted_accuracy_meters'],
      ),
      trackBreaks: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}track_breaks'],
      )!,
      allowMultipleBreaks: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_multiple_breaks'],
      )!,
      allowPunchOutDuringBreak: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_punch_out_during_break'],
      )!,
      allowEmployeeCorrectionRequest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_employee_correction_request'],
      )!,
      allowEarlyPunchIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_early_punch_in'],
      )!,
      earlyPunchInLimitMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}early_punch_in_limit_minutes'],
      ),
      allowLatePunchIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_late_punch_in'],
      )!,
      allowEarlyPunchOut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_early_punch_out'],
      )!,
      offlineMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offline_mode'],
      )!,
    );
  }

  @override
  $AttendancePolicyRecordsTable createAlias(String alias) {
    return $AttendancePolicyRecordsTable(attachedDatabase, alias);
  }
}

class AttendancePolicyRecord extends DataClass
    implements Insertable<AttendancePolicyRecord> {
  final String id;
  final String companyId;
  final String name;
  final String normalizedName;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final String description;
  final bool requireLocation;
  final bool allowOutsideLocation;
  final bool allowRemoteAttendance;
  final bool requireLocationOnPunchIn;
  final bool requireLocationOnPunchOut;
  final bool requireLocationOnBreak;
  final bool requireLocationAccuracy;
  final double? maximumAcceptedAccuracyMeters;
  final bool trackBreaks;
  final bool allowMultipleBreaks;
  final bool allowPunchOutDuringBreak;
  final bool allowEmployeeCorrectionRequest;
  final bool allowEarlyPunchIn;
  final int? earlyPunchInLimitMinutes;
  final bool allowLatePunchIn;
  final bool allowEarlyPunchOut;
  final String offlineMode;
  const AttendancePolicyRecord({
    required this.id,
    required this.companyId,
    required this.name,
    required this.normalizedName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.description,
    required this.requireLocation,
    required this.allowOutsideLocation,
    required this.allowRemoteAttendance,
    required this.requireLocationOnPunchIn,
    required this.requireLocationOnPunchOut,
    required this.requireLocationOnBreak,
    required this.requireLocationAccuracy,
    this.maximumAcceptedAccuracyMeters,
    required this.trackBreaks,
    required this.allowMultipleBreaks,
    required this.allowPunchOutDuringBreak,
    required this.allowEmployeeCorrectionRequest,
    required this.allowEarlyPunchIn,
    this.earlyPunchInLimitMinutes,
    required this.allowLatePunchIn,
    required this.allowEarlyPunchOut,
    required this.offlineMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['description'] = Variable<String>(description);
    map['require_location'] = Variable<bool>(requireLocation);
    map['allow_outside_location'] = Variable<bool>(allowOutsideLocation);
    map['allow_remote_attendance'] = Variable<bool>(allowRemoteAttendance);
    map['require_location_on_punch_in'] = Variable<bool>(
      requireLocationOnPunchIn,
    );
    map['require_location_on_punch_out'] = Variable<bool>(
      requireLocationOnPunchOut,
    );
    map['require_location_on_break'] = Variable<bool>(requireLocationOnBreak);
    map['require_location_accuracy'] = Variable<bool>(requireLocationAccuracy);
    if (!nullToAbsent || maximumAcceptedAccuracyMeters != null) {
      map['maximum_accepted_accuracy_meters'] = Variable<double>(
        maximumAcceptedAccuracyMeters,
      );
    }
    map['track_breaks'] = Variable<bool>(trackBreaks);
    map['allow_multiple_breaks'] = Variable<bool>(allowMultipleBreaks);
    map['allow_punch_out_during_break'] = Variable<bool>(
      allowPunchOutDuringBreak,
    );
    map['allow_employee_correction_request'] = Variable<bool>(
      allowEmployeeCorrectionRequest,
    );
    map['allow_early_punch_in'] = Variable<bool>(allowEarlyPunchIn);
    if (!nullToAbsent || earlyPunchInLimitMinutes != null) {
      map['early_punch_in_limit_minutes'] = Variable<int>(
        earlyPunchInLimitMinutes,
      );
    }
    map['allow_late_punch_in'] = Variable<bool>(allowLatePunchIn);
    map['allow_early_punch_out'] = Variable<bool>(allowEarlyPunchOut);
    map['offline_mode'] = Variable<String>(offlineMode);
    return map;
  }

  AttendancePolicyRecordsCompanion toCompanion(bool nullToAbsent) {
    return AttendancePolicyRecordsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      description: Value(description),
      requireLocation: Value(requireLocation),
      allowOutsideLocation: Value(allowOutsideLocation),
      allowRemoteAttendance: Value(allowRemoteAttendance),
      requireLocationOnPunchIn: Value(requireLocationOnPunchIn),
      requireLocationOnPunchOut: Value(requireLocationOnPunchOut),
      requireLocationOnBreak: Value(requireLocationOnBreak),
      requireLocationAccuracy: Value(requireLocationAccuracy),
      maximumAcceptedAccuracyMeters:
          maximumAcceptedAccuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(maximumAcceptedAccuracyMeters),
      trackBreaks: Value(trackBreaks),
      allowMultipleBreaks: Value(allowMultipleBreaks),
      allowPunchOutDuringBreak: Value(allowPunchOutDuringBreak),
      allowEmployeeCorrectionRequest: Value(allowEmployeeCorrectionRequest),
      allowEarlyPunchIn: Value(allowEarlyPunchIn),
      earlyPunchInLimitMinutes: earlyPunchInLimitMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(earlyPunchInLimitMinutes),
      allowLatePunchIn: Value(allowLatePunchIn),
      allowEarlyPunchOut: Value(allowEarlyPunchOut),
      offlineMode: Value(offlineMode),
    );
  }

  factory AttendancePolicyRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendancePolicyRecord(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      description: serializer.fromJson<String>(json['description']),
      requireLocation: serializer.fromJson<bool>(json['requireLocation']),
      allowOutsideLocation: serializer.fromJson<bool>(
        json['allowOutsideLocation'],
      ),
      allowRemoteAttendance: serializer.fromJson<bool>(
        json['allowRemoteAttendance'],
      ),
      requireLocationOnPunchIn: serializer.fromJson<bool>(
        json['requireLocationOnPunchIn'],
      ),
      requireLocationOnPunchOut: serializer.fromJson<bool>(
        json['requireLocationOnPunchOut'],
      ),
      requireLocationOnBreak: serializer.fromJson<bool>(
        json['requireLocationOnBreak'],
      ),
      requireLocationAccuracy: serializer.fromJson<bool>(
        json['requireLocationAccuracy'],
      ),
      maximumAcceptedAccuracyMeters: serializer.fromJson<double?>(
        json['maximumAcceptedAccuracyMeters'],
      ),
      trackBreaks: serializer.fromJson<bool>(json['trackBreaks']),
      allowMultipleBreaks: serializer.fromJson<bool>(
        json['allowMultipleBreaks'],
      ),
      allowPunchOutDuringBreak: serializer.fromJson<bool>(
        json['allowPunchOutDuringBreak'],
      ),
      allowEmployeeCorrectionRequest: serializer.fromJson<bool>(
        json['allowEmployeeCorrectionRequest'],
      ),
      allowEarlyPunchIn: serializer.fromJson<bool>(json['allowEarlyPunchIn']),
      earlyPunchInLimitMinutes: serializer.fromJson<int?>(
        json['earlyPunchInLimitMinutes'],
      ),
      allowLatePunchIn: serializer.fromJson<bool>(json['allowLatePunchIn']),
      allowEarlyPunchOut: serializer.fromJson<bool>(json['allowEarlyPunchOut']),
      offlineMode: serializer.fromJson<String>(json['offlineMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'description': serializer.toJson<String>(description),
      'requireLocation': serializer.toJson<bool>(requireLocation),
      'allowOutsideLocation': serializer.toJson<bool>(allowOutsideLocation),
      'allowRemoteAttendance': serializer.toJson<bool>(allowRemoteAttendance),
      'requireLocationOnPunchIn': serializer.toJson<bool>(
        requireLocationOnPunchIn,
      ),
      'requireLocationOnPunchOut': serializer.toJson<bool>(
        requireLocationOnPunchOut,
      ),
      'requireLocationOnBreak': serializer.toJson<bool>(requireLocationOnBreak),
      'requireLocationAccuracy': serializer.toJson<bool>(
        requireLocationAccuracy,
      ),
      'maximumAcceptedAccuracyMeters': serializer.toJson<double?>(
        maximumAcceptedAccuracyMeters,
      ),
      'trackBreaks': serializer.toJson<bool>(trackBreaks),
      'allowMultipleBreaks': serializer.toJson<bool>(allowMultipleBreaks),
      'allowPunchOutDuringBreak': serializer.toJson<bool>(
        allowPunchOutDuringBreak,
      ),
      'allowEmployeeCorrectionRequest': serializer.toJson<bool>(
        allowEmployeeCorrectionRequest,
      ),
      'allowEarlyPunchIn': serializer.toJson<bool>(allowEarlyPunchIn),
      'earlyPunchInLimitMinutes': serializer.toJson<int?>(
        earlyPunchInLimitMinutes,
      ),
      'allowLatePunchIn': serializer.toJson<bool>(allowLatePunchIn),
      'allowEarlyPunchOut': serializer.toJson<bool>(allowEarlyPunchOut),
      'offlineMode': serializer.toJson<String>(offlineMode),
    };
  }

  AttendancePolicyRecord copyWith({
    String? id,
    String? companyId,
    String? name,
    String? normalizedName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    String? description,
    bool? requireLocation,
    bool? allowOutsideLocation,
    bool? allowRemoteAttendance,
    bool? requireLocationOnPunchIn,
    bool? requireLocationOnPunchOut,
    bool? requireLocationOnBreak,
    bool? requireLocationAccuracy,
    Value<double?> maximumAcceptedAccuracyMeters = const Value.absent(),
    bool? trackBreaks,
    bool? allowMultipleBreaks,
    bool? allowPunchOutDuringBreak,
    bool? allowEmployeeCorrectionRequest,
    bool? allowEarlyPunchIn,
    Value<int?> earlyPunchInLimitMinutes = const Value.absent(),
    bool? allowLatePunchIn,
    bool? allowEarlyPunchOut,
    String? offlineMode,
  }) => AttendancePolicyRecord(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    description: description ?? this.description,
    requireLocation: requireLocation ?? this.requireLocation,
    allowOutsideLocation: allowOutsideLocation ?? this.allowOutsideLocation,
    allowRemoteAttendance: allowRemoteAttendance ?? this.allowRemoteAttendance,
    requireLocationOnPunchIn:
        requireLocationOnPunchIn ?? this.requireLocationOnPunchIn,
    requireLocationOnPunchOut:
        requireLocationOnPunchOut ?? this.requireLocationOnPunchOut,
    requireLocationOnBreak:
        requireLocationOnBreak ?? this.requireLocationOnBreak,
    requireLocationAccuracy:
        requireLocationAccuracy ?? this.requireLocationAccuracy,
    maximumAcceptedAccuracyMeters: maximumAcceptedAccuracyMeters.present
        ? maximumAcceptedAccuracyMeters.value
        : this.maximumAcceptedAccuracyMeters,
    trackBreaks: trackBreaks ?? this.trackBreaks,
    allowMultipleBreaks: allowMultipleBreaks ?? this.allowMultipleBreaks,
    allowPunchOutDuringBreak:
        allowPunchOutDuringBreak ?? this.allowPunchOutDuringBreak,
    allowEmployeeCorrectionRequest:
        allowEmployeeCorrectionRequest ?? this.allowEmployeeCorrectionRequest,
    allowEarlyPunchIn: allowEarlyPunchIn ?? this.allowEarlyPunchIn,
    earlyPunchInLimitMinutes: earlyPunchInLimitMinutes.present
        ? earlyPunchInLimitMinutes.value
        : this.earlyPunchInLimitMinutes,
    allowLatePunchIn: allowLatePunchIn ?? this.allowLatePunchIn,
    allowEarlyPunchOut: allowEarlyPunchOut ?? this.allowEarlyPunchOut,
    offlineMode: offlineMode ?? this.offlineMode,
  );
  AttendancePolicyRecord copyWithCompanion(
    AttendancePolicyRecordsCompanion data,
  ) {
    return AttendancePolicyRecord(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      description: data.description.present
          ? data.description.value
          : this.description,
      requireLocation: data.requireLocation.present
          ? data.requireLocation.value
          : this.requireLocation,
      allowOutsideLocation: data.allowOutsideLocation.present
          ? data.allowOutsideLocation.value
          : this.allowOutsideLocation,
      allowRemoteAttendance: data.allowRemoteAttendance.present
          ? data.allowRemoteAttendance.value
          : this.allowRemoteAttendance,
      requireLocationOnPunchIn: data.requireLocationOnPunchIn.present
          ? data.requireLocationOnPunchIn.value
          : this.requireLocationOnPunchIn,
      requireLocationOnPunchOut: data.requireLocationOnPunchOut.present
          ? data.requireLocationOnPunchOut.value
          : this.requireLocationOnPunchOut,
      requireLocationOnBreak: data.requireLocationOnBreak.present
          ? data.requireLocationOnBreak.value
          : this.requireLocationOnBreak,
      requireLocationAccuracy: data.requireLocationAccuracy.present
          ? data.requireLocationAccuracy.value
          : this.requireLocationAccuracy,
      maximumAcceptedAccuracyMeters: data.maximumAcceptedAccuracyMeters.present
          ? data.maximumAcceptedAccuracyMeters.value
          : this.maximumAcceptedAccuracyMeters,
      trackBreaks: data.trackBreaks.present
          ? data.trackBreaks.value
          : this.trackBreaks,
      allowMultipleBreaks: data.allowMultipleBreaks.present
          ? data.allowMultipleBreaks.value
          : this.allowMultipleBreaks,
      allowPunchOutDuringBreak: data.allowPunchOutDuringBreak.present
          ? data.allowPunchOutDuringBreak.value
          : this.allowPunchOutDuringBreak,
      allowEmployeeCorrectionRequest:
          data.allowEmployeeCorrectionRequest.present
          ? data.allowEmployeeCorrectionRequest.value
          : this.allowEmployeeCorrectionRequest,
      allowEarlyPunchIn: data.allowEarlyPunchIn.present
          ? data.allowEarlyPunchIn.value
          : this.allowEarlyPunchIn,
      earlyPunchInLimitMinutes: data.earlyPunchInLimitMinutes.present
          ? data.earlyPunchInLimitMinutes.value
          : this.earlyPunchInLimitMinutes,
      allowLatePunchIn: data.allowLatePunchIn.present
          ? data.allowLatePunchIn.value
          : this.allowLatePunchIn,
      allowEarlyPunchOut: data.allowEarlyPunchOut.present
          ? data.allowEarlyPunchOut.value
          : this.allowEarlyPunchOut,
      offlineMode: data.offlineMode.present
          ? data.offlineMode.value
          : this.offlineMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendancePolicyRecord(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('description: $description, ')
          ..write('requireLocation: $requireLocation, ')
          ..write('allowOutsideLocation: $allowOutsideLocation, ')
          ..write('allowRemoteAttendance: $allowRemoteAttendance, ')
          ..write('requireLocationOnPunchIn: $requireLocationOnPunchIn, ')
          ..write('requireLocationOnPunchOut: $requireLocationOnPunchOut, ')
          ..write('requireLocationOnBreak: $requireLocationOnBreak, ')
          ..write('requireLocationAccuracy: $requireLocationAccuracy, ')
          ..write(
            'maximumAcceptedAccuracyMeters: $maximumAcceptedAccuracyMeters, ',
          )
          ..write('trackBreaks: $trackBreaks, ')
          ..write('allowMultipleBreaks: $allowMultipleBreaks, ')
          ..write('allowPunchOutDuringBreak: $allowPunchOutDuringBreak, ')
          ..write(
            'allowEmployeeCorrectionRequest: $allowEmployeeCorrectionRequest, ',
          )
          ..write('allowEarlyPunchIn: $allowEarlyPunchIn, ')
          ..write('earlyPunchInLimitMinutes: $earlyPunchInLimitMinutes, ')
          ..write('allowLatePunchIn: $allowLatePunchIn, ')
          ..write('allowEarlyPunchOut: $allowEarlyPunchOut, ')
          ..write('offlineMode: $offlineMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    name,
    normalizedName,
    status,
    createdAt,
    updatedAt,
    syncStatus,
    description,
    requireLocation,
    allowOutsideLocation,
    allowRemoteAttendance,
    requireLocationOnPunchIn,
    requireLocationOnPunchOut,
    requireLocationOnBreak,
    requireLocationAccuracy,
    maximumAcceptedAccuracyMeters,
    trackBreaks,
    allowMultipleBreaks,
    allowPunchOutDuringBreak,
    allowEmployeeCorrectionRequest,
    allowEarlyPunchIn,
    earlyPunchInLimitMinutes,
    allowLatePunchIn,
    allowEarlyPunchOut,
    offlineMode,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendancePolicyRecord &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.description == this.description &&
          other.requireLocation == this.requireLocation &&
          other.allowOutsideLocation == this.allowOutsideLocation &&
          other.allowRemoteAttendance == this.allowRemoteAttendance &&
          other.requireLocationOnPunchIn == this.requireLocationOnPunchIn &&
          other.requireLocationOnPunchOut == this.requireLocationOnPunchOut &&
          other.requireLocationOnBreak == this.requireLocationOnBreak &&
          other.requireLocationAccuracy == this.requireLocationAccuracy &&
          other.maximumAcceptedAccuracyMeters ==
              this.maximumAcceptedAccuracyMeters &&
          other.trackBreaks == this.trackBreaks &&
          other.allowMultipleBreaks == this.allowMultipleBreaks &&
          other.allowPunchOutDuringBreak == this.allowPunchOutDuringBreak &&
          other.allowEmployeeCorrectionRequest ==
              this.allowEmployeeCorrectionRequest &&
          other.allowEarlyPunchIn == this.allowEarlyPunchIn &&
          other.earlyPunchInLimitMinutes == this.earlyPunchInLimitMinutes &&
          other.allowLatePunchIn == this.allowLatePunchIn &&
          other.allowEarlyPunchOut == this.allowEarlyPunchOut &&
          other.offlineMode == this.offlineMode);
}

class AttendancePolicyRecordsCompanion
    extends UpdateCompanion<AttendancePolicyRecord> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<String> description;
  final Value<bool> requireLocation;
  final Value<bool> allowOutsideLocation;
  final Value<bool> allowRemoteAttendance;
  final Value<bool> requireLocationOnPunchIn;
  final Value<bool> requireLocationOnPunchOut;
  final Value<bool> requireLocationOnBreak;
  final Value<bool> requireLocationAccuracy;
  final Value<double?> maximumAcceptedAccuracyMeters;
  final Value<bool> trackBreaks;
  final Value<bool> allowMultipleBreaks;
  final Value<bool> allowPunchOutDuringBreak;
  final Value<bool> allowEmployeeCorrectionRequest;
  final Value<bool> allowEarlyPunchIn;
  final Value<int?> earlyPunchInLimitMinutes;
  final Value<bool> allowLatePunchIn;
  final Value<bool> allowEarlyPunchOut;
  final Value<String> offlineMode;
  final Value<int> rowid;
  const AttendancePolicyRecordsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.description = const Value.absent(),
    this.requireLocation = const Value.absent(),
    this.allowOutsideLocation = const Value.absent(),
    this.allowRemoteAttendance = const Value.absent(),
    this.requireLocationOnPunchIn = const Value.absent(),
    this.requireLocationOnPunchOut = const Value.absent(),
    this.requireLocationOnBreak = const Value.absent(),
    this.requireLocationAccuracy = const Value.absent(),
    this.maximumAcceptedAccuracyMeters = const Value.absent(),
    this.trackBreaks = const Value.absent(),
    this.allowMultipleBreaks = const Value.absent(),
    this.allowPunchOutDuringBreak = const Value.absent(),
    this.allowEmployeeCorrectionRequest = const Value.absent(),
    this.allowEarlyPunchIn = const Value.absent(),
    this.earlyPunchInLimitMinutes = const Value.absent(),
    this.allowLatePunchIn = const Value.absent(),
    this.allowEarlyPunchOut = const Value.absent(),
    this.offlineMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendancePolicyRecordsCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String normalizedName,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String syncStatus,
    this.description = const Value.absent(),
    required bool requireLocation,
    required bool allowOutsideLocation,
    required bool allowRemoteAttendance,
    required bool requireLocationOnPunchIn,
    required bool requireLocationOnPunchOut,
    required bool requireLocationOnBreak,
    required bool requireLocationAccuracy,
    this.maximumAcceptedAccuracyMeters = const Value.absent(),
    required bool trackBreaks,
    required bool allowMultipleBreaks,
    required bool allowPunchOutDuringBreak,
    required bool allowEmployeeCorrectionRequest,
    required bool allowEarlyPunchIn,
    this.earlyPunchInLimitMinutes = const Value.absent(),
    required bool allowLatePunchIn,
    required bool allowEarlyPunchOut,
    required String offlineMode,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus),
       requireLocation = Value(requireLocation),
       allowOutsideLocation = Value(allowOutsideLocation),
       allowRemoteAttendance = Value(allowRemoteAttendance),
       requireLocationOnPunchIn = Value(requireLocationOnPunchIn),
       requireLocationOnPunchOut = Value(requireLocationOnPunchOut),
       requireLocationOnBreak = Value(requireLocationOnBreak),
       requireLocationAccuracy = Value(requireLocationAccuracy),
       trackBreaks = Value(trackBreaks),
       allowMultipleBreaks = Value(allowMultipleBreaks),
       allowPunchOutDuringBreak = Value(allowPunchOutDuringBreak),
       allowEmployeeCorrectionRequest = Value(allowEmployeeCorrectionRequest),
       allowEarlyPunchIn = Value(allowEarlyPunchIn),
       allowLatePunchIn = Value(allowLatePunchIn),
       allowEarlyPunchOut = Value(allowEarlyPunchOut),
       offlineMode = Value(offlineMode);
  static Insertable<AttendancePolicyRecord> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<String>? description,
    Expression<bool>? requireLocation,
    Expression<bool>? allowOutsideLocation,
    Expression<bool>? allowRemoteAttendance,
    Expression<bool>? requireLocationOnPunchIn,
    Expression<bool>? requireLocationOnPunchOut,
    Expression<bool>? requireLocationOnBreak,
    Expression<bool>? requireLocationAccuracy,
    Expression<double>? maximumAcceptedAccuracyMeters,
    Expression<bool>? trackBreaks,
    Expression<bool>? allowMultipleBreaks,
    Expression<bool>? allowPunchOutDuringBreak,
    Expression<bool>? allowEmployeeCorrectionRequest,
    Expression<bool>? allowEarlyPunchIn,
    Expression<int>? earlyPunchInLimitMinutes,
    Expression<bool>? allowLatePunchIn,
    Expression<bool>? allowEarlyPunchOut,
    Expression<String>? offlineMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (description != null) 'description': description,
      if (requireLocation != null) 'require_location': requireLocation,
      if (allowOutsideLocation != null)
        'allow_outside_location': allowOutsideLocation,
      if (allowRemoteAttendance != null)
        'allow_remote_attendance': allowRemoteAttendance,
      if (requireLocationOnPunchIn != null)
        'require_location_on_punch_in': requireLocationOnPunchIn,
      if (requireLocationOnPunchOut != null)
        'require_location_on_punch_out': requireLocationOnPunchOut,
      if (requireLocationOnBreak != null)
        'require_location_on_break': requireLocationOnBreak,
      if (requireLocationAccuracy != null)
        'require_location_accuracy': requireLocationAccuracy,
      if (maximumAcceptedAccuracyMeters != null)
        'maximum_accepted_accuracy_meters': maximumAcceptedAccuracyMeters,
      if (trackBreaks != null) 'track_breaks': trackBreaks,
      if (allowMultipleBreaks != null)
        'allow_multiple_breaks': allowMultipleBreaks,
      if (allowPunchOutDuringBreak != null)
        'allow_punch_out_during_break': allowPunchOutDuringBreak,
      if (allowEmployeeCorrectionRequest != null)
        'allow_employee_correction_request': allowEmployeeCorrectionRequest,
      if (allowEarlyPunchIn != null) 'allow_early_punch_in': allowEarlyPunchIn,
      if (earlyPunchInLimitMinutes != null)
        'early_punch_in_limit_minutes': earlyPunchInLimitMinutes,
      if (allowLatePunchIn != null) 'allow_late_punch_in': allowLatePunchIn,
      if (allowEarlyPunchOut != null)
        'allow_early_punch_out': allowEarlyPunchOut,
      if (offlineMode != null) 'offline_mode': offlineMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendancePolicyRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<String>? description,
    Value<bool>? requireLocation,
    Value<bool>? allowOutsideLocation,
    Value<bool>? allowRemoteAttendance,
    Value<bool>? requireLocationOnPunchIn,
    Value<bool>? requireLocationOnPunchOut,
    Value<bool>? requireLocationOnBreak,
    Value<bool>? requireLocationAccuracy,
    Value<double?>? maximumAcceptedAccuracyMeters,
    Value<bool>? trackBreaks,
    Value<bool>? allowMultipleBreaks,
    Value<bool>? allowPunchOutDuringBreak,
    Value<bool>? allowEmployeeCorrectionRequest,
    Value<bool>? allowEarlyPunchIn,
    Value<int?>? earlyPunchInLimitMinutes,
    Value<bool>? allowLatePunchIn,
    Value<bool>? allowEarlyPunchOut,
    Value<String>? offlineMode,
    Value<int>? rowid,
  }) {
    return AttendancePolicyRecordsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      description: description ?? this.description,
      requireLocation: requireLocation ?? this.requireLocation,
      allowOutsideLocation: allowOutsideLocation ?? this.allowOutsideLocation,
      allowRemoteAttendance:
          allowRemoteAttendance ?? this.allowRemoteAttendance,
      requireLocationOnPunchIn:
          requireLocationOnPunchIn ?? this.requireLocationOnPunchIn,
      requireLocationOnPunchOut:
          requireLocationOnPunchOut ?? this.requireLocationOnPunchOut,
      requireLocationOnBreak:
          requireLocationOnBreak ?? this.requireLocationOnBreak,
      requireLocationAccuracy:
          requireLocationAccuracy ?? this.requireLocationAccuracy,
      maximumAcceptedAccuracyMeters:
          maximumAcceptedAccuracyMeters ?? this.maximumAcceptedAccuracyMeters,
      trackBreaks: trackBreaks ?? this.trackBreaks,
      allowMultipleBreaks: allowMultipleBreaks ?? this.allowMultipleBreaks,
      allowPunchOutDuringBreak:
          allowPunchOutDuringBreak ?? this.allowPunchOutDuringBreak,
      allowEmployeeCorrectionRequest:
          allowEmployeeCorrectionRequest ?? this.allowEmployeeCorrectionRequest,
      allowEarlyPunchIn: allowEarlyPunchIn ?? this.allowEarlyPunchIn,
      earlyPunchInLimitMinutes:
          earlyPunchInLimitMinutes ?? this.earlyPunchInLimitMinutes,
      allowLatePunchIn: allowLatePunchIn ?? this.allowLatePunchIn,
      allowEarlyPunchOut: allowEarlyPunchOut ?? this.allowEarlyPunchOut,
      offlineMode: offlineMode ?? this.offlineMode,
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
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (requireLocation.present) {
      map['require_location'] = Variable<bool>(requireLocation.value);
    }
    if (allowOutsideLocation.present) {
      map['allow_outside_location'] = Variable<bool>(
        allowOutsideLocation.value,
      );
    }
    if (allowRemoteAttendance.present) {
      map['allow_remote_attendance'] = Variable<bool>(
        allowRemoteAttendance.value,
      );
    }
    if (requireLocationOnPunchIn.present) {
      map['require_location_on_punch_in'] = Variable<bool>(
        requireLocationOnPunchIn.value,
      );
    }
    if (requireLocationOnPunchOut.present) {
      map['require_location_on_punch_out'] = Variable<bool>(
        requireLocationOnPunchOut.value,
      );
    }
    if (requireLocationOnBreak.present) {
      map['require_location_on_break'] = Variable<bool>(
        requireLocationOnBreak.value,
      );
    }
    if (requireLocationAccuracy.present) {
      map['require_location_accuracy'] = Variable<bool>(
        requireLocationAccuracy.value,
      );
    }
    if (maximumAcceptedAccuracyMeters.present) {
      map['maximum_accepted_accuracy_meters'] = Variable<double>(
        maximumAcceptedAccuracyMeters.value,
      );
    }
    if (trackBreaks.present) {
      map['track_breaks'] = Variable<bool>(trackBreaks.value);
    }
    if (allowMultipleBreaks.present) {
      map['allow_multiple_breaks'] = Variable<bool>(allowMultipleBreaks.value);
    }
    if (allowPunchOutDuringBreak.present) {
      map['allow_punch_out_during_break'] = Variable<bool>(
        allowPunchOutDuringBreak.value,
      );
    }
    if (allowEmployeeCorrectionRequest.present) {
      map['allow_employee_correction_request'] = Variable<bool>(
        allowEmployeeCorrectionRequest.value,
      );
    }
    if (allowEarlyPunchIn.present) {
      map['allow_early_punch_in'] = Variable<bool>(allowEarlyPunchIn.value);
    }
    if (earlyPunchInLimitMinutes.present) {
      map['early_punch_in_limit_minutes'] = Variable<int>(
        earlyPunchInLimitMinutes.value,
      );
    }
    if (allowLatePunchIn.present) {
      map['allow_late_punch_in'] = Variable<bool>(allowLatePunchIn.value);
    }
    if (allowEarlyPunchOut.present) {
      map['allow_early_punch_out'] = Variable<bool>(allowEarlyPunchOut.value);
    }
    if (offlineMode.present) {
      map['offline_mode'] = Variable<String>(offlineMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendancePolicyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('description: $description, ')
          ..write('requireLocation: $requireLocation, ')
          ..write('allowOutsideLocation: $allowOutsideLocation, ')
          ..write('allowRemoteAttendance: $allowRemoteAttendance, ')
          ..write('requireLocationOnPunchIn: $requireLocationOnPunchIn, ')
          ..write('requireLocationOnPunchOut: $requireLocationOnPunchOut, ')
          ..write('requireLocationOnBreak: $requireLocationOnBreak, ')
          ..write('requireLocationAccuracy: $requireLocationAccuracy, ')
          ..write(
            'maximumAcceptedAccuracyMeters: $maximumAcceptedAccuracyMeters, ',
          )
          ..write('trackBreaks: $trackBreaks, ')
          ..write('allowMultipleBreaks: $allowMultipleBreaks, ')
          ..write('allowPunchOutDuringBreak: $allowPunchOutDuringBreak, ')
          ..write(
            'allowEmployeeCorrectionRequest: $allowEmployeeCorrectionRequest, ',
          )
          ..write('allowEarlyPunchIn: $allowEarlyPunchIn, ')
          ..write('earlyPunchInLimitMinutes: $earlyPunchInLimitMinutes, ')
          ..write('allowLatePunchIn: $allowLatePunchIn, ')
          ..write('allowEarlyPunchOut: $allowEarlyPunchOut, ')
          ..write('offlineMode: $offlineMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $AttendanceDaysTable attendanceDays = $AttendanceDaysTable(this);
  late final $AttendanceEventsTable attendanceEvents = $AttendanceEventsTable(
    this,
  );
  late final $WorkforceDepartmentsTable workforceDepartments =
      $WorkforceDepartmentsTable(this);
  late final $WorkforceDesignationsTable workforceDesignations =
      $WorkforceDesignationsTable(this);
  late final $WorkforceAccountsTable workforceAccounts =
      $WorkforceAccountsTable(this);
  late final $WorkforceEmployeesTable workforceEmployees =
      $WorkforceEmployeesTable(this);
  late final $WorkforceSeedsTable workforceSeeds = $WorkforceSeedsTable(this);
  late final $ShiftRecordsTable shiftRecords = $ShiftRecordsTable(this);
  late final $WorkLocationRecordsTable workLocationRecords =
      $WorkLocationRecordsTable(this);
  late final $AttendancePolicyRecordsTable attendancePolicyRecords =
      $AttendancePolicyRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncOutbox,
    attendanceDays,
    attendanceEvents,
    workforceDepartments,
    workforceDesignations,
    workforceAccounts,
    workforceEmployees,
    workforceSeeds,
    shiftRecords,
    workLocationRecords,
    attendancePolicyRecords,
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
      Value<String?> companyId,
      Value<String?> requestId,
      Value<String> status,
      Value<DateTime?> lastAttemptAt,
      Value<String?> failureCode,
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
      Value<String?> companyId,
      Value<String?> requestId,
      Value<String> status,
      Value<DateTime?> lastAttemptAt,
      Value<String?> failureCode,
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

  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
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

  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
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

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => column,
  );

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
                Value<String?> companyId = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> failureCode = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                moduleId: moduleId,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                companyId: companyId,
                requestId: requestId,
                status: status,
                lastAttemptAt: lastAttemptAt,
                failureCode: failureCode,
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
                Value<String?> companyId = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> failureCode = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                moduleId: moduleId,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                companyId: companyId,
                requestId: requestId,
                status: status,
                lastAttemptAt: lastAttemptAt,
                failureCode: failureCode,
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
typedef $$AttendanceDaysTableCreateCompanionBuilder =
    AttendanceDaysCompanion Function({
      required String id,
      required String companyId,
      required String employeeId,
      required String attendanceDate,
      required String shiftId,
      required String policyId,
      Value<String?> workLocationId,
      required String configurationSnapshot,
      required String state,
      Value<int?> punchInMilliseconds,
      Value<int?> punchOutMilliseconds,
      Value<int> elapsedMilliseconds,
      Value<int> breakMilliseconds,
      Value<int> workMilliseconds,
      required String status,
      required String syncStatus,
      required int createdMilliseconds,
      required int updatedMilliseconds,
      Value<int> rowid,
    });
typedef $$AttendanceDaysTableUpdateCompanionBuilder =
    AttendanceDaysCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> employeeId,
      Value<String> attendanceDate,
      Value<String> shiftId,
      Value<String> policyId,
      Value<String?> workLocationId,
      Value<String> configurationSnapshot,
      Value<String> state,
      Value<int?> punchInMilliseconds,
      Value<int?> punchOutMilliseconds,
      Value<int> elapsedMilliseconds,
      Value<int> breakMilliseconds,
      Value<int> workMilliseconds,
      Value<String> status,
      Value<String> syncStatus,
      Value<int> createdMilliseconds,
      Value<int> updatedMilliseconds,
      Value<int> rowid,
    });

final class $$AttendanceDaysTableReferences
    extends
        BaseReferences<_$AppDatabase, $AttendanceDaysTable, AttendanceDayData> {
  $$AttendanceDaysTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AttendanceEventsTable, List<AttendanceEventData>>
  _attendanceEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendanceEvents,
    aliasName: $_aliasNameGenerator(
      db.attendanceDays.id,
      db.attendanceEvents.attendanceDayId,
    ),
  );

  $$AttendanceEventsTableProcessedTableManager get attendanceEventsRefs {
    final manager =
        $$AttendanceEventsTableTableManager($_db, $_db.attendanceEvents).filter(
          (f) => f.attendanceDayId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _attendanceEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttendanceDaysTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceDaysTable> {
  $$AttendanceDaysTableFilterComposer({
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

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policyId => $composableBuilder(
    column: $table.policyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configurationSnapshot => $composableBuilder(
    column: $table.configurationSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get punchInMilliseconds => $composableBuilder(
    column: $table.punchInMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get punchOutMilliseconds => $composableBuilder(
    column: $table.punchOutMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMilliseconds => $composableBuilder(
    column: $table.elapsedMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakMilliseconds => $composableBuilder(
    column: $table.breakMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workMilliseconds => $composableBuilder(
    column: $table.workMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdMilliseconds => $composableBuilder(
    column: $table.createdMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedMilliseconds => $composableBuilder(
    column: $table.updatedMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attendanceEventsRefs(
    Expression<bool> Function($$AttendanceEventsTableFilterComposer f) f,
  ) {
    final $$AttendanceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceEvents,
      getReferencedColumn: (t) => t.attendanceDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceEventsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttendanceDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceDaysTable> {
  $$AttendanceDaysTableOrderingComposer({
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

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policyId => $composableBuilder(
    column: $table.policyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configurationSnapshot => $composableBuilder(
    column: $table.configurationSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get punchInMilliseconds => $composableBuilder(
    column: $table.punchInMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get punchOutMilliseconds => $composableBuilder(
    column: $table.punchOutMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMilliseconds => $composableBuilder(
    column: $table.elapsedMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMilliseconds => $composableBuilder(
    column: $table.breakMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workMilliseconds => $composableBuilder(
    column: $table.workMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdMilliseconds => $composableBuilder(
    column: $table.createdMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedMilliseconds => $composableBuilder(
    column: $table.updatedMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceDaysTable> {
  $$AttendanceDaysTableAnnotationComposer({
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

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get policyId =>
      $composableBuilder(column: $table.policyId, builder: (column) => column);

  GeneratedColumn<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configurationSnapshot => $composableBuilder(
    column: $table.configurationSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get punchInMilliseconds => $composableBuilder(
    column: $table.punchInMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get punchOutMilliseconds => $composableBuilder(
    column: $table.punchOutMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedMilliseconds => $composableBuilder(
    column: $table.elapsedMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breakMilliseconds => $composableBuilder(
    column: $table.breakMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get workMilliseconds => $composableBuilder(
    column: $table.workMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdMilliseconds => $composableBuilder(
    column: $table.createdMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedMilliseconds => $composableBuilder(
    column: $table.updatedMilliseconds,
    builder: (column) => column,
  );

  Expression<T> attendanceEventsRefs<T extends Object>(
    Expression<T> Function($$AttendanceEventsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceEvents,
      getReferencedColumn: (t) => t.attendanceDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.attendanceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttendanceDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceDaysTable,
          AttendanceDayData,
          $$AttendanceDaysTableFilterComposer,
          $$AttendanceDaysTableOrderingComposer,
          $$AttendanceDaysTableAnnotationComposer,
          $$AttendanceDaysTableCreateCompanionBuilder,
          $$AttendanceDaysTableUpdateCompanionBuilder,
          (AttendanceDayData, $$AttendanceDaysTableReferences),
          AttendanceDayData,
          PrefetchHooks Function({bool attendanceEventsRefs})
        > {
  $$AttendanceDaysTableTableManager(
    _$AppDatabase db,
    $AttendanceDaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> attendanceDate = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<String> policyId = const Value.absent(),
                Value<String?> workLocationId = const Value.absent(),
                Value<String> configurationSnapshot = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int?> punchInMilliseconds = const Value.absent(),
                Value<int?> punchOutMilliseconds = const Value.absent(),
                Value<int> elapsedMilliseconds = const Value.absent(),
                Value<int> breakMilliseconds = const Value.absent(),
                Value<int> workMilliseconds = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> createdMilliseconds = const Value.absent(),
                Value<int> updatedMilliseconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceDaysCompanion(
                id: id,
                companyId: companyId,
                employeeId: employeeId,
                attendanceDate: attendanceDate,
                shiftId: shiftId,
                policyId: policyId,
                workLocationId: workLocationId,
                configurationSnapshot: configurationSnapshot,
                state: state,
                punchInMilliseconds: punchInMilliseconds,
                punchOutMilliseconds: punchOutMilliseconds,
                elapsedMilliseconds: elapsedMilliseconds,
                breakMilliseconds: breakMilliseconds,
                workMilliseconds: workMilliseconds,
                status: status,
                syncStatus: syncStatus,
                createdMilliseconds: createdMilliseconds,
                updatedMilliseconds: updatedMilliseconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String employeeId,
                required String attendanceDate,
                required String shiftId,
                required String policyId,
                Value<String?> workLocationId = const Value.absent(),
                required String configurationSnapshot,
                required String state,
                Value<int?> punchInMilliseconds = const Value.absent(),
                Value<int?> punchOutMilliseconds = const Value.absent(),
                Value<int> elapsedMilliseconds = const Value.absent(),
                Value<int> breakMilliseconds = const Value.absent(),
                Value<int> workMilliseconds = const Value.absent(),
                required String status,
                required String syncStatus,
                required int createdMilliseconds,
                required int updatedMilliseconds,
                Value<int> rowid = const Value.absent(),
              }) => AttendanceDaysCompanion.insert(
                id: id,
                companyId: companyId,
                employeeId: employeeId,
                attendanceDate: attendanceDate,
                shiftId: shiftId,
                policyId: policyId,
                workLocationId: workLocationId,
                configurationSnapshot: configurationSnapshot,
                state: state,
                punchInMilliseconds: punchInMilliseconds,
                punchOutMilliseconds: punchOutMilliseconds,
                elapsedMilliseconds: elapsedMilliseconds,
                breakMilliseconds: breakMilliseconds,
                workMilliseconds: workMilliseconds,
                status: status,
                syncStatus: syncStatus,
                createdMilliseconds: createdMilliseconds,
                updatedMilliseconds: updatedMilliseconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attendanceEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attendanceEventsRefs) db.attendanceEvents,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attendanceEventsRefs)
                    await $_getPrefetchedData<
                      AttendanceDayData,
                      $AttendanceDaysTable,
                      AttendanceEventData
                    >(
                      currentTable: table,
                      referencedTable: $$AttendanceDaysTableReferences
                          ._attendanceEventsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AttendanceDaysTableReferences(
                            db,
                            table,
                            p0,
                          ).attendanceEventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.attendanceDayId == item.id,
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

typedef $$AttendanceDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceDaysTable,
      AttendanceDayData,
      $$AttendanceDaysTableFilterComposer,
      $$AttendanceDaysTableOrderingComposer,
      $$AttendanceDaysTableAnnotationComposer,
      $$AttendanceDaysTableCreateCompanionBuilder,
      $$AttendanceDaysTableUpdateCompanionBuilder,
      (AttendanceDayData, $$AttendanceDaysTableReferences),
      AttendanceDayData,
      PrefetchHooks Function({bool attendanceEventsRefs})
    >;
typedef $$AttendanceEventsTableCreateCompanionBuilder =
    AttendanceEventsCompanion Function({
      required String id,
      required String attendanceDayId,
      required String companyId,
      required String employeeId,
      required String eventType,
      required int deviceMilliseconds,
      Value<int?> serverMilliseconds,
      required int effectiveMilliseconds,
      required int sequence,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> accuracyMeters,
      Value<int?> capturedMilliseconds,
      Value<String?> permissionState,
      Value<String?> workLocationId,
      required String locationValidation,
      required String requestId,
      required String source,
      required String syncStatus,
      required int createdMilliseconds,
      Value<int> rowid,
    });
typedef $$AttendanceEventsTableUpdateCompanionBuilder =
    AttendanceEventsCompanion Function({
      Value<String> id,
      Value<String> attendanceDayId,
      Value<String> companyId,
      Value<String> employeeId,
      Value<String> eventType,
      Value<int> deviceMilliseconds,
      Value<int?> serverMilliseconds,
      Value<int> effectiveMilliseconds,
      Value<int> sequence,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> accuracyMeters,
      Value<int?> capturedMilliseconds,
      Value<String?> permissionState,
      Value<String?> workLocationId,
      Value<String> locationValidation,
      Value<String> requestId,
      Value<String> source,
      Value<String> syncStatus,
      Value<int> createdMilliseconds,
      Value<int> rowid,
    });

final class $$AttendanceEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttendanceEventsTable,
          AttendanceEventData
        > {
  $$AttendanceEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttendanceDaysTable _attendanceDayIdTable(_$AppDatabase db) =>
      db.attendanceDays.createAlias(
        $_aliasNameGenerator(
          db.attendanceEvents.attendanceDayId,
          db.attendanceDays.id,
        ),
      );

  $$AttendanceDaysTableProcessedTableManager get attendanceDayId {
    final $_column = $_itemColumn<String>('attendance_day_id')!;

    final manager = $$AttendanceDaysTableTableManager(
      $_db,
      $_db.attendanceDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attendanceDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableFilterComposer({
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

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceMilliseconds => $composableBuilder(
    column: $table.deviceMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverMilliseconds => $composableBuilder(
    column: $table.serverMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveMilliseconds => $composableBuilder(
    column: $table.effectiveMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedMilliseconds => $composableBuilder(
    column: $table.capturedMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionState => $composableBuilder(
    column: $table.permissionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationValidation => $composableBuilder(
    column: $table.locationValidation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdMilliseconds => $composableBuilder(
    column: $table.createdMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  $$AttendanceDaysTableFilterComposer get attendanceDayId {
    final $$AttendanceDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attendanceDayId,
      referencedTable: $db.attendanceDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceDaysTableFilterComposer(
            $db: $db,
            $table: $db.attendanceDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableOrderingComposer({
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

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceMilliseconds => $composableBuilder(
    column: $table.deviceMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverMilliseconds => $composableBuilder(
    column: $table.serverMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveMilliseconds => $composableBuilder(
    column: $table.effectiveMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedMilliseconds => $composableBuilder(
    column: $table.capturedMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionState => $composableBuilder(
    column: $table.permissionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationValidation => $composableBuilder(
    column: $table.locationValidation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdMilliseconds => $composableBuilder(
    column: $table.createdMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttendanceDaysTableOrderingComposer get attendanceDayId {
    final $$AttendanceDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attendanceDayId,
      referencedTable: $db.attendanceDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceDaysTableOrderingComposer(
            $db: $db,
            $table: $db.attendanceDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get deviceMilliseconds => $composableBuilder(
    column: $table.deviceMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverMilliseconds => $composableBuilder(
    column: $table.serverMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveMilliseconds => $composableBuilder(
    column: $table.effectiveMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capturedMilliseconds => $composableBuilder(
    column: $table.capturedMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get permissionState => $composableBuilder(
    column: $table.permissionState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workLocationId => $composableBuilder(
    column: $table.workLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationValidation => $composableBuilder(
    column: $table.locationValidation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdMilliseconds => $composableBuilder(
    column: $table.createdMilliseconds,
    builder: (column) => column,
  );

  $$AttendanceDaysTableAnnotationComposer get attendanceDayId {
    final $$AttendanceDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attendanceDayId,
      referencedTable: $db.attendanceDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.attendanceDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceEventsTable,
          AttendanceEventData,
          $$AttendanceEventsTableFilterComposer,
          $$AttendanceEventsTableOrderingComposer,
          $$AttendanceEventsTableAnnotationComposer,
          $$AttendanceEventsTableCreateCompanionBuilder,
          $$AttendanceEventsTableUpdateCompanionBuilder,
          (AttendanceEventData, $$AttendanceEventsTableReferences),
          AttendanceEventData,
          PrefetchHooks Function({bool attendanceDayId})
        > {
  $$AttendanceEventsTableTableManager(
    _$AppDatabase db,
    $AttendanceEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> attendanceDayId = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int> deviceMilliseconds = const Value.absent(),
                Value<int?> serverMilliseconds = const Value.absent(),
                Value<int> effectiveMilliseconds = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
                Value<int?> capturedMilliseconds = const Value.absent(),
                Value<String?> permissionState = const Value.absent(),
                Value<String?> workLocationId = const Value.absent(),
                Value<String> locationValidation = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> createdMilliseconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceEventsCompanion(
                id: id,
                attendanceDayId: attendanceDayId,
                companyId: companyId,
                employeeId: employeeId,
                eventType: eventType,
                deviceMilliseconds: deviceMilliseconds,
                serverMilliseconds: serverMilliseconds,
                effectiveMilliseconds: effectiveMilliseconds,
                sequence: sequence,
                latitude: latitude,
                longitude: longitude,
                accuracyMeters: accuracyMeters,
                capturedMilliseconds: capturedMilliseconds,
                permissionState: permissionState,
                workLocationId: workLocationId,
                locationValidation: locationValidation,
                requestId: requestId,
                source: source,
                syncStatus: syncStatus,
                createdMilliseconds: createdMilliseconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String attendanceDayId,
                required String companyId,
                required String employeeId,
                required String eventType,
                required int deviceMilliseconds,
                Value<int?> serverMilliseconds = const Value.absent(),
                required int effectiveMilliseconds,
                required int sequence,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
                Value<int?> capturedMilliseconds = const Value.absent(),
                Value<String?> permissionState = const Value.absent(),
                Value<String?> workLocationId = const Value.absent(),
                required String locationValidation,
                required String requestId,
                required String source,
                required String syncStatus,
                required int createdMilliseconds,
                Value<int> rowid = const Value.absent(),
              }) => AttendanceEventsCompanion.insert(
                id: id,
                attendanceDayId: attendanceDayId,
                companyId: companyId,
                employeeId: employeeId,
                eventType: eventType,
                deviceMilliseconds: deviceMilliseconds,
                serverMilliseconds: serverMilliseconds,
                effectiveMilliseconds: effectiveMilliseconds,
                sequence: sequence,
                latitude: latitude,
                longitude: longitude,
                accuracyMeters: accuracyMeters,
                capturedMilliseconds: capturedMilliseconds,
                permissionState: permissionState,
                workLocationId: workLocationId,
                locationValidation: locationValidation,
                requestId: requestId,
                source: source,
                syncStatus: syncStatus,
                createdMilliseconds: createdMilliseconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attendanceDayId = false}) {
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
                    if (attendanceDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attendanceDayId,
                                referencedTable:
                                    $$AttendanceEventsTableReferences
                                        ._attendanceDayIdTable(db),
                                referencedColumn:
                                    $$AttendanceEventsTableReferences
                                        ._attendanceDayIdTable(db)
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

typedef $$AttendanceEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceEventsTable,
      AttendanceEventData,
      $$AttendanceEventsTableFilterComposer,
      $$AttendanceEventsTableOrderingComposer,
      $$AttendanceEventsTableAnnotationComposer,
      $$AttendanceEventsTableCreateCompanionBuilder,
      $$AttendanceEventsTableUpdateCompanionBuilder,
      (AttendanceEventData, $$AttendanceEventsTableReferences),
      AttendanceEventData,
      PrefetchHooks Function({bool attendanceDayId})
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
typedef $$ShiftRecordsTableCreateCompanionBuilder =
    ShiftRecordsCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String normalizedName,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String syncStatus,
      Value<String?> code,
      required int startMinutes,
      required int endMinutes,
      required int workingDayMask,
      required int gracePeriodMinutes,
      required String breakMode,
      Value<int?> defaultBreakMinutes,
      Value<int?> minimumWorkMinutes,
      Value<int> rowid,
    });
typedef $$ShiftRecordsTableUpdateCompanionBuilder =
    ShiftRecordsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<String?> code,
      Value<int> startMinutes,
      Value<int> endMinutes,
      Value<int> workingDayMask,
      Value<int> gracePeriodMinutes,
      Value<String> breakMode,
      Value<int?> defaultBreakMinutes,
      Value<int?> minimumWorkMinutes,
      Value<int> rowid,
    });

class $$ShiftRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftRecordsTable> {
  $$ShiftRecordsTableFilterComposer({
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

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workingDayMask => $composableBuilder(
    column: $table.workingDayMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gracePeriodMinutes => $composableBuilder(
    column: $table.gracePeriodMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breakMode => $composableBuilder(
    column: $table.breakMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultBreakMinutes => $composableBuilder(
    column: $table.defaultBreakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumWorkMinutes => $composableBuilder(
    column: $table.minimumWorkMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftRecordsTable> {
  $$ShiftRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workingDayMask => $composableBuilder(
    column: $table.workingDayMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gracePeriodMinutes => $composableBuilder(
    column: $table.gracePeriodMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breakMode => $composableBuilder(
    column: $table.breakMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultBreakMinutes => $composableBuilder(
    column: $table.defaultBreakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumWorkMinutes => $composableBuilder(
    column: $table.minimumWorkMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftRecordsTable> {
  $$ShiftRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get workingDayMask => $composableBuilder(
    column: $table.workingDayMask,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gracePeriodMinutes => $composableBuilder(
    column: $table.gracePeriodMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get breakMode =>
      $composableBuilder(column: $table.breakMode, builder: (column) => column);

  GeneratedColumn<int> get defaultBreakMinutes => $composableBuilder(
    column: $table.defaultBreakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumWorkMinutes => $composableBuilder(
    column: $table.minimumWorkMinutes,
    builder: (column) => column,
  );
}

class $$ShiftRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftRecordsTable,
          ShiftRecord,
          $$ShiftRecordsTableFilterComposer,
          $$ShiftRecordsTableOrderingComposer,
          $$ShiftRecordsTableAnnotationComposer,
          $$ShiftRecordsTableCreateCompanionBuilder,
          $$ShiftRecordsTableUpdateCompanionBuilder,
          (
            ShiftRecord,
            BaseReferences<_$AppDatabase, $ShiftRecordsTable, ShiftRecord>,
          ),
          ShiftRecord,
          PrefetchHooks Function()
        > {
  $$ShiftRecordsTableTableManager(_$AppDatabase db, $ShiftRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> endMinutes = const Value.absent(),
                Value<int> workingDayMask = const Value.absent(),
                Value<int> gracePeriodMinutes = const Value.absent(),
                Value<String> breakMode = const Value.absent(),
                Value<int?> defaultBreakMinutes = const Value.absent(),
                Value<int?> minimumWorkMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftRecordsCompanion(
                id: id,
                companyId: companyId,
                name: name,
                normalizedName: normalizedName,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                code: code,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                workingDayMask: workingDayMask,
                gracePeriodMinutes: gracePeriodMinutes,
                breakMode: breakMode,
                defaultBreakMinutes: defaultBreakMinutes,
                minimumWorkMinutes: minimumWorkMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String normalizedName,
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String syncStatus,
                Value<String?> code = const Value.absent(),
                required int startMinutes,
                required int endMinutes,
                required int workingDayMask,
                required int gracePeriodMinutes,
                required String breakMode,
                Value<int?> defaultBreakMinutes = const Value.absent(),
                Value<int?> minimumWorkMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftRecordsCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                normalizedName: normalizedName,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                code: code,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                workingDayMask: workingDayMask,
                gracePeriodMinutes: gracePeriodMinutes,
                breakMode: breakMode,
                defaultBreakMinutes: defaultBreakMinutes,
                minimumWorkMinutes: minimumWorkMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftRecordsTable,
      ShiftRecord,
      $$ShiftRecordsTableFilterComposer,
      $$ShiftRecordsTableOrderingComposer,
      $$ShiftRecordsTableAnnotationComposer,
      $$ShiftRecordsTableCreateCompanionBuilder,
      $$ShiftRecordsTableUpdateCompanionBuilder,
      (
        ShiftRecord,
        BaseReferences<_$AppDatabase, $ShiftRecordsTable, ShiftRecord>,
      ),
      ShiftRecord,
      PrefetchHooks Function()
    >;
typedef $$WorkLocationRecordsTableCreateCompanionBuilder =
    WorkLocationRecordsCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String normalizedName,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String syncStatus,
      Value<String?> code,
      required String addressLine1,
      Value<String> addressLine2,
      required String city,
      Value<String> stateRegion,
      Value<String> postalCode,
      required String countryCode,
      required double latitude,
      required double longitude,
      required double allowedRadiusMeters,
      Value<double?> maximumAccuracyMeters,
      required String validationMode,
      Value<int> rowid,
    });
typedef $$WorkLocationRecordsTableUpdateCompanionBuilder =
    WorkLocationRecordsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<String?> code,
      Value<String> addressLine1,
      Value<String> addressLine2,
      Value<String> city,
      Value<String> stateRegion,
      Value<String> postalCode,
      Value<String> countryCode,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> allowedRadiusMeters,
      Value<double?> maximumAccuracyMeters,
      Value<String> validationMode,
      Value<int> rowid,
    });

class $$WorkLocationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkLocationRecordsTable> {
  $$WorkLocationRecordsTableFilterComposer({
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

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateRegion => $composableBuilder(
    column: $table.stateRegion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get allowedRadiusMeters => $composableBuilder(
    column: $table.allowedRadiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maximumAccuracyMeters => $composableBuilder(
    column: $table.maximumAccuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validationMode => $composableBuilder(
    column: $table.validationMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkLocationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkLocationRecordsTable> {
  $$WorkLocationRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateRegion => $composableBuilder(
    column: $table.stateRegion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get allowedRadiusMeters => $composableBuilder(
    column: $table.allowedRadiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maximumAccuracyMeters => $composableBuilder(
    column: $table.maximumAccuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validationMode => $composableBuilder(
    column: $table.validationMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkLocationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkLocationRecordsTable> {
  $$WorkLocationRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get stateRegion => $composableBuilder(
    column: $table.stateRegion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get allowedRadiusMeters => $composableBuilder(
    column: $table.allowedRadiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maximumAccuracyMeters => $composableBuilder(
    column: $table.maximumAccuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get validationMode => $composableBuilder(
    column: $table.validationMode,
    builder: (column) => column,
  );
}

class $$WorkLocationRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkLocationRecordsTable,
          WorkLocationRecord,
          $$WorkLocationRecordsTableFilterComposer,
          $$WorkLocationRecordsTableOrderingComposer,
          $$WorkLocationRecordsTableAnnotationComposer,
          $$WorkLocationRecordsTableCreateCompanionBuilder,
          $$WorkLocationRecordsTableUpdateCompanionBuilder,
          (
            WorkLocationRecord,
            BaseReferences<
              _$AppDatabase,
              $WorkLocationRecordsTable,
              WorkLocationRecord
            >,
          ),
          WorkLocationRecord,
          PrefetchHooks Function()
        > {
  $$WorkLocationRecordsTableTableManager(
    _$AppDatabase db,
    $WorkLocationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkLocationRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkLocationRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkLocationRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> addressLine1 = const Value.absent(),
                Value<String> addressLine2 = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> stateRegion = const Value.absent(),
                Value<String> postalCode = const Value.absent(),
                Value<String> countryCode = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> allowedRadiusMeters = const Value.absent(),
                Value<double?> maximumAccuracyMeters = const Value.absent(),
                Value<String> validationMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkLocationRecordsCompanion(
                id: id,
                companyId: companyId,
                name: name,
                normalizedName: normalizedName,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                code: code,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                city: city,
                stateRegion: stateRegion,
                postalCode: postalCode,
                countryCode: countryCode,
                latitude: latitude,
                longitude: longitude,
                allowedRadiusMeters: allowedRadiusMeters,
                maximumAccuracyMeters: maximumAccuracyMeters,
                validationMode: validationMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String normalizedName,
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String syncStatus,
                Value<String?> code = const Value.absent(),
                required String addressLine1,
                Value<String> addressLine2 = const Value.absent(),
                required String city,
                Value<String> stateRegion = const Value.absent(),
                Value<String> postalCode = const Value.absent(),
                required String countryCode,
                required double latitude,
                required double longitude,
                required double allowedRadiusMeters,
                Value<double?> maximumAccuracyMeters = const Value.absent(),
                required String validationMode,
                Value<int> rowid = const Value.absent(),
              }) => WorkLocationRecordsCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                normalizedName: normalizedName,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                code: code,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                city: city,
                stateRegion: stateRegion,
                postalCode: postalCode,
                countryCode: countryCode,
                latitude: latitude,
                longitude: longitude,
                allowedRadiusMeters: allowedRadiusMeters,
                maximumAccuracyMeters: maximumAccuracyMeters,
                validationMode: validationMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkLocationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkLocationRecordsTable,
      WorkLocationRecord,
      $$WorkLocationRecordsTableFilterComposer,
      $$WorkLocationRecordsTableOrderingComposer,
      $$WorkLocationRecordsTableAnnotationComposer,
      $$WorkLocationRecordsTableCreateCompanionBuilder,
      $$WorkLocationRecordsTableUpdateCompanionBuilder,
      (
        WorkLocationRecord,
        BaseReferences<
          _$AppDatabase,
          $WorkLocationRecordsTable,
          WorkLocationRecord
        >,
      ),
      WorkLocationRecord,
      PrefetchHooks Function()
    >;
typedef $$AttendancePolicyRecordsTableCreateCompanionBuilder =
    AttendancePolicyRecordsCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String normalizedName,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String syncStatus,
      Value<String> description,
      required bool requireLocation,
      required bool allowOutsideLocation,
      required bool allowRemoteAttendance,
      required bool requireLocationOnPunchIn,
      required bool requireLocationOnPunchOut,
      required bool requireLocationOnBreak,
      required bool requireLocationAccuracy,
      Value<double?> maximumAcceptedAccuracyMeters,
      required bool trackBreaks,
      required bool allowMultipleBreaks,
      required bool allowPunchOutDuringBreak,
      required bool allowEmployeeCorrectionRequest,
      required bool allowEarlyPunchIn,
      Value<int?> earlyPunchInLimitMinutes,
      required bool allowLatePunchIn,
      required bool allowEarlyPunchOut,
      required String offlineMode,
      Value<int> rowid,
    });
typedef $$AttendancePolicyRecordsTableUpdateCompanionBuilder =
    AttendancePolicyRecordsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<String> description,
      Value<bool> requireLocation,
      Value<bool> allowOutsideLocation,
      Value<bool> allowRemoteAttendance,
      Value<bool> requireLocationOnPunchIn,
      Value<bool> requireLocationOnPunchOut,
      Value<bool> requireLocationOnBreak,
      Value<bool> requireLocationAccuracy,
      Value<double?> maximumAcceptedAccuracyMeters,
      Value<bool> trackBreaks,
      Value<bool> allowMultipleBreaks,
      Value<bool> allowPunchOutDuringBreak,
      Value<bool> allowEmployeeCorrectionRequest,
      Value<bool> allowEarlyPunchIn,
      Value<int?> earlyPunchInLimitMinutes,
      Value<bool> allowLatePunchIn,
      Value<bool> allowEarlyPunchOut,
      Value<String> offlineMode,
      Value<int> rowid,
    });

class $$AttendancePolicyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendancePolicyRecordsTable> {
  $$AttendancePolicyRecordsTableFilterComposer({
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

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireLocation => $composableBuilder(
    column: $table.requireLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowOutsideLocation => $composableBuilder(
    column: $table.allowOutsideLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowRemoteAttendance => $composableBuilder(
    column: $table.allowRemoteAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireLocationOnPunchIn => $composableBuilder(
    column: $table.requireLocationOnPunchIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireLocationOnPunchOut => $composableBuilder(
    column: $table.requireLocationOnPunchOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireLocationOnBreak => $composableBuilder(
    column: $table.requireLocationOnBreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireLocationAccuracy => $composableBuilder(
    column: $table.requireLocationAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maximumAcceptedAccuracyMeters => $composableBuilder(
    column: $table.maximumAcceptedAccuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackBreaks => $composableBuilder(
    column: $table.trackBreaks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowMultipleBreaks => $composableBuilder(
    column: $table.allowMultipleBreaks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowPunchOutDuringBreak => $composableBuilder(
    column: $table.allowPunchOutDuringBreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowEmployeeCorrectionRequest => $composableBuilder(
    column: $table.allowEmployeeCorrectionRequest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowEarlyPunchIn => $composableBuilder(
    column: $table.allowEarlyPunchIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earlyPunchInLimitMinutes => $composableBuilder(
    column: $table.earlyPunchInLimitMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowLatePunchIn => $composableBuilder(
    column: $table.allowLatePunchIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowEarlyPunchOut => $composableBuilder(
    column: $table.allowEarlyPunchOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get offlineMode => $composableBuilder(
    column: $table.offlineMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendancePolicyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendancePolicyRecordsTable> {
  $$AttendancePolicyRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireLocation => $composableBuilder(
    column: $table.requireLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowOutsideLocation => $composableBuilder(
    column: $table.allowOutsideLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowRemoteAttendance => $composableBuilder(
    column: $table.allowRemoteAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireLocationOnPunchIn => $composableBuilder(
    column: $table.requireLocationOnPunchIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireLocationOnPunchOut => $composableBuilder(
    column: $table.requireLocationOnPunchOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireLocationOnBreak => $composableBuilder(
    column: $table.requireLocationOnBreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireLocationAccuracy => $composableBuilder(
    column: $table.requireLocationAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maximumAcceptedAccuracyMeters =>
      $composableBuilder(
        column: $table.maximumAcceptedAccuracyMeters,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get trackBreaks => $composableBuilder(
    column: $table.trackBreaks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowMultipleBreaks => $composableBuilder(
    column: $table.allowMultipleBreaks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowPunchOutDuringBreak => $composableBuilder(
    column: $table.allowPunchOutDuringBreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowEmployeeCorrectionRequest =>
      $composableBuilder(
        column: $table.allowEmployeeCorrectionRequest,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get allowEarlyPunchIn => $composableBuilder(
    column: $table.allowEarlyPunchIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earlyPunchInLimitMinutes => $composableBuilder(
    column: $table.earlyPunchInLimitMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowLatePunchIn => $composableBuilder(
    column: $table.allowLatePunchIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowEarlyPunchOut => $composableBuilder(
    column: $table.allowEarlyPunchOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offlineMode => $composableBuilder(
    column: $table.offlineMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendancePolicyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendancePolicyRecordsTable> {
  $$AttendancePolicyRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requireLocation => $composableBuilder(
    column: $table.requireLocation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowOutsideLocation => $composableBuilder(
    column: $table.allowOutsideLocation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowRemoteAttendance => $composableBuilder(
    column: $table.allowRemoteAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requireLocationOnPunchIn => $composableBuilder(
    column: $table.requireLocationOnPunchIn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requireLocationOnPunchOut => $composableBuilder(
    column: $table.requireLocationOnPunchOut,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requireLocationOnBreak => $composableBuilder(
    column: $table.requireLocationOnBreak,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requireLocationAccuracy => $composableBuilder(
    column: $table.requireLocationAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maximumAcceptedAccuracyMeters =>
      $composableBuilder(
        column: $table.maximumAcceptedAccuracyMeters,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get trackBreaks => $composableBuilder(
    column: $table.trackBreaks,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowMultipleBreaks => $composableBuilder(
    column: $table.allowMultipleBreaks,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowPunchOutDuringBreak => $composableBuilder(
    column: $table.allowPunchOutDuringBreak,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowEmployeeCorrectionRequest =>
      $composableBuilder(
        column: $table.allowEmployeeCorrectionRequest,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get allowEarlyPunchIn => $composableBuilder(
    column: $table.allowEarlyPunchIn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get earlyPunchInLimitMinutes => $composableBuilder(
    column: $table.earlyPunchInLimitMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowLatePunchIn => $composableBuilder(
    column: $table.allowLatePunchIn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowEarlyPunchOut => $composableBuilder(
    column: $table.allowEarlyPunchOut,
    builder: (column) => column,
  );

  GeneratedColumn<String> get offlineMode => $composableBuilder(
    column: $table.offlineMode,
    builder: (column) => column,
  );
}

class $$AttendancePolicyRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendancePolicyRecordsTable,
          AttendancePolicyRecord,
          $$AttendancePolicyRecordsTableFilterComposer,
          $$AttendancePolicyRecordsTableOrderingComposer,
          $$AttendancePolicyRecordsTableAnnotationComposer,
          $$AttendancePolicyRecordsTableCreateCompanionBuilder,
          $$AttendancePolicyRecordsTableUpdateCompanionBuilder,
          (
            AttendancePolicyRecord,
            BaseReferences<
              _$AppDatabase,
              $AttendancePolicyRecordsTable,
              AttendancePolicyRecord
            >,
          ),
          AttendancePolicyRecord,
          PrefetchHooks Function()
        > {
  $$AttendancePolicyRecordsTableTableManager(
    _$AppDatabase db,
    $AttendancePolicyRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancePolicyRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AttendancePolicyRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AttendancePolicyRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> requireLocation = const Value.absent(),
                Value<bool> allowOutsideLocation = const Value.absent(),
                Value<bool> allowRemoteAttendance = const Value.absent(),
                Value<bool> requireLocationOnPunchIn = const Value.absent(),
                Value<bool> requireLocationOnPunchOut = const Value.absent(),
                Value<bool> requireLocationOnBreak = const Value.absent(),
                Value<bool> requireLocationAccuracy = const Value.absent(),
                Value<double?> maximumAcceptedAccuracyMeters =
                    const Value.absent(),
                Value<bool> trackBreaks = const Value.absent(),
                Value<bool> allowMultipleBreaks = const Value.absent(),
                Value<bool> allowPunchOutDuringBreak = const Value.absent(),
                Value<bool> allowEmployeeCorrectionRequest =
                    const Value.absent(),
                Value<bool> allowEarlyPunchIn = const Value.absent(),
                Value<int?> earlyPunchInLimitMinutes = const Value.absent(),
                Value<bool> allowLatePunchIn = const Value.absent(),
                Value<bool> allowEarlyPunchOut = const Value.absent(),
                Value<String> offlineMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendancePolicyRecordsCompanion(
                id: id,
                companyId: companyId,
                name: name,
                normalizedName: normalizedName,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                description: description,
                requireLocation: requireLocation,
                allowOutsideLocation: allowOutsideLocation,
                allowRemoteAttendance: allowRemoteAttendance,
                requireLocationOnPunchIn: requireLocationOnPunchIn,
                requireLocationOnPunchOut: requireLocationOnPunchOut,
                requireLocationOnBreak: requireLocationOnBreak,
                requireLocationAccuracy: requireLocationAccuracy,
                maximumAcceptedAccuracyMeters: maximumAcceptedAccuracyMeters,
                trackBreaks: trackBreaks,
                allowMultipleBreaks: allowMultipleBreaks,
                allowPunchOutDuringBreak: allowPunchOutDuringBreak,
                allowEmployeeCorrectionRequest: allowEmployeeCorrectionRequest,
                allowEarlyPunchIn: allowEarlyPunchIn,
                earlyPunchInLimitMinutes: earlyPunchInLimitMinutes,
                allowLatePunchIn: allowLatePunchIn,
                allowEarlyPunchOut: allowEarlyPunchOut,
                offlineMode: offlineMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String normalizedName,
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String syncStatus,
                Value<String> description = const Value.absent(),
                required bool requireLocation,
                required bool allowOutsideLocation,
                required bool allowRemoteAttendance,
                required bool requireLocationOnPunchIn,
                required bool requireLocationOnPunchOut,
                required bool requireLocationOnBreak,
                required bool requireLocationAccuracy,
                Value<double?> maximumAcceptedAccuracyMeters =
                    const Value.absent(),
                required bool trackBreaks,
                required bool allowMultipleBreaks,
                required bool allowPunchOutDuringBreak,
                required bool allowEmployeeCorrectionRequest,
                required bool allowEarlyPunchIn,
                Value<int?> earlyPunchInLimitMinutes = const Value.absent(),
                required bool allowLatePunchIn,
                required bool allowEarlyPunchOut,
                required String offlineMode,
                Value<int> rowid = const Value.absent(),
              }) => AttendancePolicyRecordsCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                normalizedName: normalizedName,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                description: description,
                requireLocation: requireLocation,
                allowOutsideLocation: allowOutsideLocation,
                allowRemoteAttendance: allowRemoteAttendance,
                requireLocationOnPunchIn: requireLocationOnPunchIn,
                requireLocationOnPunchOut: requireLocationOnPunchOut,
                requireLocationOnBreak: requireLocationOnBreak,
                requireLocationAccuracy: requireLocationAccuracy,
                maximumAcceptedAccuracyMeters: maximumAcceptedAccuracyMeters,
                trackBreaks: trackBreaks,
                allowMultipleBreaks: allowMultipleBreaks,
                allowPunchOutDuringBreak: allowPunchOutDuringBreak,
                allowEmployeeCorrectionRequest: allowEmployeeCorrectionRequest,
                allowEarlyPunchIn: allowEarlyPunchIn,
                earlyPunchInLimitMinutes: earlyPunchInLimitMinutes,
                allowLatePunchIn: allowLatePunchIn,
                allowEarlyPunchOut: allowEarlyPunchOut,
                offlineMode: offlineMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendancePolicyRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendancePolicyRecordsTable,
      AttendancePolicyRecord,
      $$AttendancePolicyRecordsTableFilterComposer,
      $$AttendancePolicyRecordsTableOrderingComposer,
      $$AttendancePolicyRecordsTableAnnotationComposer,
      $$AttendancePolicyRecordsTableCreateCompanionBuilder,
      $$AttendancePolicyRecordsTableUpdateCompanionBuilder,
      (
        AttendancePolicyRecord,
        BaseReferences<
          _$AppDatabase,
          $AttendancePolicyRecordsTable,
          AttendancePolicyRecord
        >,
      ),
      AttendancePolicyRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$AttendanceDaysTableTableManager get attendanceDays =>
      $$AttendanceDaysTableTableManager(_db, _db.attendanceDays);
  $$AttendanceEventsTableTableManager get attendanceEvents =>
      $$AttendanceEventsTableTableManager(_db, _db.attendanceEvents);
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
  $$ShiftRecordsTableTableManager get shiftRecords =>
      $$ShiftRecordsTableTableManager(_db, _db.shiftRecords);
  $$WorkLocationRecordsTableTableManager get workLocationRecords =>
      $$WorkLocationRecordsTableTableManager(_db, _db.workLocationRecords);
  $$AttendancePolicyRecordsTableTableManager get attendancePolicyRecords =>
      $$AttendancePolicyRecordsTableTableManager(
        _db,
        _db.attendancePolicyRecords,
      );
}
