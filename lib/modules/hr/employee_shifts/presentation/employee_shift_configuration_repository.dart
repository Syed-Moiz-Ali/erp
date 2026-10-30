import 'dart:async';

import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';

/// Presentation projection of a backend [EmployeeShift] onto the shared
/// [ConfigurationRecord] contract used by the existing configuration screens.
class EmployeeShiftRecord implements ConfigurationRecord {
  const EmployeeShiftRecord(this.employeeShift, {required this.companyId});

  final EmployeeShift employeeShift;

  @override
  final String companyId;

  int get employeeShiftId => employeeShift.employeeShiftId;
  int get employeeId => employeeShift.employeeId;
  String get employeeCode => employeeShift.employeeCode;
  String get employeeName => employeeShift.employeeName;
  int get shiftId => employeeShift.shiftId;
  String get shiftName => employeeShift.shiftName;
  String get fromDate => employeeShift.fromDate;
  String get toDate => employeeShift.toDate;
  String get startTime => employeeShift.startTime;
  String get endTime => employeeShift.endTime;
  int get earlyPunchInMinutes => employeeShift.earlyPunchInMinutes;
  int get lateGraceMinutes => employeeShift.lateGraceMinutes;
  int get statusId => employeeShift.statusId;
  String? get timeZoneId => employeeShift.timeZoneId;
  String? get punchInOpensAt => employeeShift.punchInOpensAt;
  bool get crossesMidnight => employeeShift.crossesMidnight;

  @override
  String get id => employeeShift.employeeShiftId.toString();

  @override
  String get name {
    final code = employeeShift.employeeCode.trim();
    final employee = employeeShift.employeeName.trim();
    final label = code.isEmpty ? employee : '$employee ($code)';
    return '$label – ${employeeShift.shiftName}';
  }

  @override
  ConfigurationStatus get status => employeeShift.isActive
      ? ConfigurationStatus.active
      : ConfigurationStatus.inactive;

  @override
  RecordSyncStatus get syncStatus => RecordSyncStatus.synced;

  @override
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  DateTime get updatedAt => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Map<String, dynamic> toJson() => {
    'employeeShiftId': employeeShift.employeeShiftId,
    'employeeId': employeeShift.employeeId,
    'employeeCode': employeeShift.employeeCode,
    'employeeName': employeeShift.employeeName,
    'shiftId': employeeShift.shiftId,
    'shiftName': employeeShift.shiftName,
    'fromDate': employeeShift.fromDate,
    'toDate': employeeShift.toDate,
    'startTime': employeeShift.startTime,
    'endTime': employeeShift.endTime,
    'earlyPunchInMinutes': employeeShift.earlyPunchInMinutes,
    'lateGraceMinutes': employeeShift.lateGraceMinutes,
    'statusId': employeeShift.statusId,
    'status': employeeShift.status,
    'timeZoneId': employeeShift.timeZoneId,
    'punchInOpensAt': employeeShift.punchInOpensAt,
    'crossesMidnight': employeeShift.crossesMidnight,
  };
}

/// Backend-only adapter from [EmployeeShiftRepository] to the shared
/// configuration workflow. The API has no text search, so [watchList] ignores
/// the query and only maps the status filter to `includeInactive`.
class EmployeeShiftConfigurationRepository
    implements
        ConfigurationRepository<EmployeeShiftRecord, EmployeeShiftDraft> {
  EmployeeShiftConfigurationRepository(this._repository);

  final EmployeeShiftRepository _repository;
  final _revision = StreamController<void>.broadcast();

  @override
  Stream<Result<ConfigurationPageData<EmployeeShiftRecord>>> watchList(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) => _watch(() => _load(context, status, page, pageSize));

  Stream<Result<T>> _watch<T>(Future<Result<T>> Function() load) {
    late StreamController<Result<T>> controller;
    StreamSubscription<void>? revision;
    controller = StreamController<Result<T>>(
      onListen: () {
        load().then((result) {
          if (!controller.isClosed) controller.add(result);
        });
        revision = _revision.stream.listen((_) {
          load().then((result) {
            if (!controller.isClosed) controller.add(result);
          });
        });
      },
      onCancel: () async => revision?.cancel(),
    );
    return controller.stream;
  }

  Future<Result<ConfigurationPageData<EmployeeShiftRecord>>> _load(
    AuthContext context,
    ConfigurationStatus? status,
    int page,
    int pageSize,
  ) async {
    final result = await _repository.list(
      includeInactive: switch (status) {
        null => true,
        ConfigurationStatus.active => false,
        ConfigurationStatus.inactive => true,
      },
      page: page + 1,
      pageSize: pageSize,
    );
    switch (result) {
      case Success<EmployeeShiftPage>(:final value):
        final items = value.items
            .map(
              (shift) => ConfigurationItem(
                EmployeeShiftRecord(shift, companyId: context.company.id),
                0,
              ),
            )
            .toList(growable: false);
        return Success(
          ConfigurationPageData<EmployeeShiftRecord>(
            items,
            value.totalItems,
            value.totalItems,
          ),
        );
      case Failed<EmployeeShiftPage>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Stream<Result<ConfigurationItem<EmployeeShiftRecord>?>> watchDetails(
    AuthContext context,
    String id,
  ) => _watch(() => _detail(context, id));

  Future<Result<ConfigurationItem<EmployeeShiftRecord>?>> _detail(
    AuthContext context,
    String id,
  ) async {
    final found = await getById(context, id);
    switch (found) {
      case Success<EmployeeShiftRecord?>(:final value):
        return Success(value == null ? null : ConfigurationItem(value, 0));
      case Failed<EmployeeShiftRecord?>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<EmployeeShiftRecord?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  }) async {
    final numericId = _parseId(id);
    if (numericId == null) return const Success(null);
    final result = await _repository.getById(numericId);
    switch (result) {
      case Success<EmployeeShift>(:final value):
        return Success(
          EmployeeShiftRecord(value, companyId: context.company.id),
        );
      case Failed<EmployeeShift>(:final failure):
        if (failure.kind == FailureKind.notFound) return const Success(null);
        return Failed(failure);
    }
  }

  @override
  Future<Result<EmployeeShiftRecord>> save(
    AuthContext context,
    EmployeeShiftDraft draft, {
    String? id,
  }) async {
    final normalized = draft.normalized();
    final errors = normalized.validate(requireEmployee: id == null);
    if (errors.isNotEmpty) {
      return Failed(
        Failure(
          code: errors.values.first,
          kind: FailureKind.validation,
          field: errors.keys.first,
        ),
      );
    }
    final Result<EmployeeShift> result;
    if (id == null) {
      result = await _repository.create(normalized);
    } else {
      final numericId = _parseId(id);
      if (numericId == null) return const Failed(Failure(code: 'notFound'));
      result = await _repository.update(
        numericId,
        normalized.copyWith(clearEmployeeId: true),
      );
    }
    switch (result) {
      case Success<EmployeeShift>(:final value):
        _revision.add(null);
        return Success(
          EmployeeShiftRecord(value, companyId: context.company.id),
        );
      case Failed<EmployeeShift>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) async {
    final numericId = _parseId(id);
    if (numericId == null) return const Failed(Failure(code: 'notFound'));
    if (active) {
      return const Failed(
        Failure(code: 'unsupported', kind: FailureKind.notConfigured),
      );
    }
    final result = await _repository.deactivate(numericId);
    switch (result) {
      case Success<void>():
        _revision.add(null);
        return const Success(null);
      case Failed<void>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<int>> assignedEmployeeCount(
    AuthContext context,
    String id,
  ) async => const Success(0);

  static int? _parseId(String id) => int.tryParse(id.trim());

  Future<void> dispose() => _revision.close();
}
