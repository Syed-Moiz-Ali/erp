import 'dart:async';

import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/live/data/datasources/live_employee_data_source.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Backend-mode employee repository bridging the MassERP employee endpoints onto
/// the frozen baseline [EmployeeRepository] interface.
///
/// Successful mutations bump a revision stream so active list/detail watchers
/// re-fetch rather than showing optimistic local state.
class RemoteEmployeeRepository implements EmployeeRepository {
  RemoteEmployeeRepository(this._dataSource);

  final LiveEmployeeRemoteDataSource _dataSource;
  final _revision = StreamController<void>.broadcast();

  static final DateTime _epoch = DateTime.utc(1970, 1, 1);

  @override
  Stream<Result<EmployeePageData>> watchEmployees(
    AuthContext context, {
    String query = '',
    EmployeeFilter filter = const EmployeeFilter(),
    EmployeeSort sort = EmployeeSort.nameAscending,
    int page = 0,
    int pageSize = 10,
  }) => _watch(() => _load(context, query, filter, sort, page, pageSize));

  @override
  Stream<Result<Employee?>> watchEmployee(AuthContext context, String id) =>
      _watch(() => _detail(context, id));

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

  Future<Result<EmployeePageData>> _load(
    AuthContext context,
    String query,
    EmployeeFilter filter,
    EmployeeSort sort,
    int page,
    int pageSize,
  ) async {
    final result = await _dataSource.list(
      search: query.trim(),
      statusId: _statusId(filter.status),
      departmentId: _parseId(filter.departmentId),
      sort: _sortName(sort),
      page: page + 1,
      pageSize: pageSize,
    );
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success<PagedResult<LiveEmployeeDto>>(:final value) => Success(
        EmployeePageData(
          value.items
              .map((dto) => _toEmployee(dto.toDomain(), context))
              .toList(),
          value.totalItems,
          value.totalItems,
        ),
      ),
    };
  }

  Future<Result<Employee?>> _detail(AuthContext context, String id) async {
    final numericId = _parseId(id);
    if (numericId == null) return const Success(null);
    final result = await _dataSource.getById(numericId);
    switch (result) {
      case Success<LiveEmployeeDto>(:final value):
        return Success(_toEmployee(value.toDomain(), context));
      case Failed<LiveEmployeeDto>(:final failure):
        if (failure.kind == FailureKind.notFound) return const Success(null);
        return Failed(failure);
    }
  }

  @override
  Future<Result<Employee?>> getEmployeeById(AuthContext context, String id) =>
      _detail(context, id);

  @override
  Future<Result<List<Employee>>> searchAssignableCompanyEmployees(
    AuthContext context, {
    String query = '',
    int limit = 50,
  }) async {
    final result = await _dataSource.list(
      search: query.trim(),
      statusId: 1,
      sort: 'nameAsc',
      page: 1,
      pageSize: limit,
    );
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success<PagedResult<LiveEmployeeDto>>(:final value) => Success(
        value.items.map((dto) => _toEmployee(dto.toDomain(), context)).toList(),
      ),
    };
  }

  @override
  Future<Result<Employee?>> getCompanyEmployee(
    AuthContext context,
    String id,
  ) => _detail(context, id);

  @override
  Future<Result<List<Employee>>> getCompanyEmployees(
    AuthContext context,
    Iterable<String> ids,
  ) async {
    final employees = <Employee>[];
    for (final id in ids) {
      final numericId = _parseId(id);
      if (numericId == null) continue;
      final result = await _dataSource.getById(numericId);
      switch (result) {
        case Success<LiveEmployeeDto>(:final value):
          employees.add(_toEmployee(value.toDomain(), context));
        case Failed<LiveEmployeeDto>(:final failure):
          if (failure.kind == FailureKind.notFound) continue;
          return Failed(failure);
      }
    }
    return Success(employees);
  }

  @override
  Future<Result<Employee>> saveEmployee(
    AuthContext context,
    EmployeeDraft draft, {
    String? id,
  }) async {
    if (id == null) return _create(context, draft);
    final numericId = _parseId(id);
    if (numericId == null) {
      return const Failed(
        Failure(code: 'notFound', kind: FailureKind.notFound),
      );
    }
    return _update(context, numericId, draft);
  }

  Future<Result<Employee>> _create(
    AuthContext context,
    EmployeeDraft draft,
  ) async {
    final result = await _dataSource.create(_createBody(draft));
    switch (result) {
      case Failed<LiveEmployeeDto>(:final failure):
        return Failed(failure);
      case Success<LiveEmployeeDto>(:final value):
        final created = value.toDomain();
        // Re-read so the UI shows the real post-create login state. If the
        // actor can create but not view, keep the 201 payload.
        final fresh = await _dataSource.getById(created.id);
        final employee = fresh is Success<LiveEmployeeDto>
            ? fresh.value.toDomain()
            : created;
        _revision.add(null);
        return Success(_toEmployee(employee, context));
    }
  }

  /// PUT is a full replacement: every field returned by GET is copied, then the
  /// fields the frozen form edits are overlaid. Loaded fields are never dropped.
  Future<Result<Employee>> _update(
    AuthContext context,
    int id,
    EmployeeDraft draft,
  ) async {
    final detail = await _dataSource.getById(id);
    if (detail is Failed<LiveEmployeeDto>) return Failed(detail.failure);
    final loaded = (detail as Success<LiveEmployeeDto>).value;
    final body = _updateBody(loaded.json, draft);
    final result = await _dataSource.update(id, body);
    switch (result) {
      case Failed<LiveEmployeeDto>(:final failure):
        return Failed(failure);
      case Success<LiveEmployeeDto>(:final value):
        _revision.add(null);
        return Success(_toEmployee(value.toDomain(), context));
    }
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) async {
    final numericId = _parseId(id);
    if (numericId == null) {
      return const Failed(
        Failure(code: 'notFound', kind: FailureKind.notFound),
      );
    }
    final result = await _dataSource.setActive(numericId, active: active);
    switch (result) {
      case Success<LiveEmployeeDto>():
        _revision.add(null);
        return const Success(null);
      case Failed<LiveEmployeeDto>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<bool>> checkEmailAvailability(
    AuthContext context,
    String email, {
    String? excludingId,
  }) => Future.value(
    const Failed(Failure(code: 'unsupported', kind: FailureKind.notConfigured)),
  );

  @override
  Future<Result<bool>> checkPhoneAvailability(
    AuthContext context,
    String phone, {
    String? excludingId,
  }) => Future.value(
    const Failed(Failure(code: 'unsupported', kind: FailureKind.notConfigured)),
  );

  @override
  Future<Result<EmployeeAccountAccess?>> getLinkedAccount(
    AuthContext context,
    String employeeId,
  ) async {
    final numericId = _parseId(employeeId);
    if (numericId == null) return const Success(null);
    final result = await _dataSource.getById(numericId);
    switch (result) {
      case Failed<LiveEmployeeDto>(:final failure):
        return Failed(failure);
      case Success<LiveEmployeeDto>(:final value):
        final employee = value.toDomain();
        if (employee.loginUserId == null) return const Success(null);
        return Success(
          EmployeeAccountAccess(
            UserAccount(
              id: employee.loginUserId.toString(),
              displayName: employee.name,
              email: employee.loginId ?? '',
              phone: employee.loginMobile,
              companyId: context.company.id,
              permissions: PermissionSet(const []),
              status: employee.loginEnabled
                  ? AccountStatus.active
                  : AccountStatus.inactive,
            ),
            credentialPending: !(employee.loginEnabled && employee.canLogin),
          ),
        );
    }
  }

  @override
  Future<Result<EmployeeReferences>> getReferences(
    AuthContext context, {
    String? excludingId,
  }) async {
    final result = await _dataSource.lookups();
    switch (result) {
      case Failed<LiveEmployeeLookups>(:final failure):
        return Failed(failure);
      case Success<LiveEmployeeLookups>(:final value):
        return Success(
          EmployeeReferences(
            departments: [
              for (final department in value.departments)
                WorkforceReference(department.id.toString(), department.name),
            ],
            designations: const [],
            managers: const [],
          ),
        );
    }
  }

  Employee _toEmployee(LiveEmployee employee, AuthContext context) => Employee(
    id: employee.id.toString(),
    companyId: context.company.id,
    employeeCode: employee.code,
    firstName: employee.name,
    email: employee.email ?? '',
    phone: employee.phone ?? '',
    departmentId: employee.departmentId?.toString() ?? '',
    designationId: employee.designation ?? '',
    managerId: employee.reportingManager,
    joiningDate: _parseDate(employee.joiningDate),
    status: employee.statusId == 1
        ? EmploymentStatus.active
        : EmploymentStatus.inactive,
    shiftId: null,
    workLocationId: null,
    attendancePolicyId: null,
    linkedUserId: employee.loginUserId?.toString(),
    loginEnabled: employee.loginEnabled,
    createdAt: _epoch,
    updatedAt: _epoch,
    syncStatus: EmployeeSyncStatus.synced,
  );

  static Map<String, dynamic> _createBody(EmployeeDraft draft) {
    final name = _employeeName(draft);
    final email = draft.email.trim();
    final phone = draft.phone.trim();
    final departmentId = _parseId(draft.departmentId);
    final joiningDate = draft.joiningDate;
    final designation = draft.designationId?.trim() ?? '';
    return {
      'employeeName': name,
      'statusId': draft.status == EmploymentStatus.active ? 1 : 2,
      if (departmentId != null) 'departmentId': departmentId,
      'designation': designation.isEmpty ? null : designation,
      if (joiningDate != null) 'joiningDate': _isoDate(joiningDate),
      'email': email.isEmpty ? null : email,
      'uaeContactNumber': phone.isEmpty ? null : phone,
      if (draft.loginEnabled)
        'login': {
          'enabled': true,
          'loginId': email,
          'mobileNo': phone,
          // The frozen form has no password control; the backend validation
          // response is allowed to surface instead of inventing credentials.
          'password': '',
          'branchIds': <int>[],
        },
    };
  }

  static Map<String, dynamic> _updateBody(
    Map<String, dynamic> loaded,
    EmployeeDraft draft,
  ) {
    final email = draft.email.trim();
    final phone = draft.phone.trim();
    final departmentId = _parseId(draft.departmentId);
    final joiningDate = draft.joiningDate;
    final designation = draft.designationId?.trim() ?? '';
    final body = <String, dynamic>{
      ...loaded,
      'employeeName': _employeeName(draft),
      if (departmentId != null) 'departmentId': departmentId,
      'designation': designation.isEmpty ? null : designation,
      if (joiningDate != null) 'joiningDate': _isoDate(joiningDate),
      'email': email.isEmpty ? null : email,
      'uaeContactNumber': phone.isEmpty ? null : phone,
      'statusId': draft.status == EmploymentStatus.active ? 1 : 2,
    };
    final login = loaded['login'];
    if (login is Map) {
      body['login'] = <String, dynamic>{...login.cast<String, dynamic>()}
        ..remove('userType')
        ..['enabled'] = draft.loginEnabled;
    }
    return body;
  }

  static String _employeeName(EmployeeDraft draft) => [
    draft.firstName,
    draft.middleName,
    draft.lastName,
  ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(' ');

  static int? _statusId(EmploymentStatus? status) => switch (status) {
    EmploymentStatus.active => 1,
    EmploymentStatus.inactive => 2,
    null => null,
  };

  /// The backend has no documented oldest-joined sort. Never send it; fall back
  /// to the documented default and record the gap in the integration notes.
  static String _sortName(EmployeeSort sort) => switch (sort) {
    EmployeeSort.nameAscending => 'nameAsc',
    EmployeeSort.nameDescending => 'nameDesc',
    EmployeeSort.code => 'codeAsc',
    EmployeeSort.newestJoined => 'newest',
    EmployeeSort.oldestJoined => 'nameAsc',
  };

  static int? _parseId(String? value) {
    if (value == null) return null;
    return int.tryParse(value.trim());
  }

  static DateTime _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return _epoch;
    return DateTime.tryParse(value) ?? _epoch;
  }

  static String _isoDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  Future<void> dispose() => _revision.close();
}
