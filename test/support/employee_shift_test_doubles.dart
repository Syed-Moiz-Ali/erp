import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/datasources/employee_shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/dto/employee_shift_dtos.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift_repository.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

EmployeeShiftDto employeeShiftDto({
  int employeeShiftId = 1,
  int employeeId = 2,
  String employeeCode = 'EMP-SANITIZED',
  String employeeName = 'Sanitized Employee',
  int shiftId = 1,
  String shiftName = 'Shift 1',
  String fromDate = '2026-09-01',
  String toDate = '2026-10-31',
  String startTime = '09:00:00',
  String endTime = '12:00:00',
  int earlyPunchInMinutes = 20,
  int lateGraceMinutes = 20,
  int statusId = 1,
  String status = 'Active',
  String? timeZoneId = 'Asia/Dubai',
  String? punchInOpensAt = '08:40:00',
  bool crossesMidnight = false,
}) => EmployeeShiftDto(
  employeeShiftId: employeeShiftId,
  employeeId: employeeId,
  employeeCode: employeeCode,
  employeeName: employeeName,
  shiftId: shiftId,
  shiftName: shiftName,
  fromDate: fromDate,
  toDate: toDate,
  startTime: startTime,
  endTime: endTime,
  earlyPunchInMinutes: earlyPunchInMinutes,
  lateGraceMinutes: lateGraceMinutes,
  statusId: statusId,
  status: status,
  timeZoneId: timeZoneId,
  punchInOpensAt: punchInOpensAt,
  crossesMidnight: crossesMidnight,
);

PagedResult<EmployeeShiftDto> employeeShiftPage(
  List<EmployeeShiftDto> items, {
  int page = 1,
  int pageSize = 25,
  int? totalItems,
  int? totalPages,
}) => PagedResult(
  items: items,
  page: page,
  pageSize: pageSize,
  totalItems: totalItems ?? items.length,
  totalPages: totalPages ?? 1,
);

/// Scriptable in-memory remote datasource. No network is touched.
class FakeEmployeeShiftRemoteDataSource
    implements EmployeeShiftRemoteDataSource {
  Future<Result<PagedResult<EmployeeShiftDto>>> Function(
    int? employeeId,
    int? shiftId,
    String? fromDate,
    String? toDate,
    bool? includeInactive,
    int page,
    int pageSize,
  )?
  onList;
  Future<Result<EmployeeShiftDto>> Function(int id)? onGet;
  Future<Result<EmployeeShiftDto>> Function(EmployeeShiftCreateDto request)?
  onCreate;
  Future<Result<EmployeeShiftDto>> Function(
    int id,
    EmployeeShiftUpdateDto request,
  )?
  onUpdate;
  Future<Result<void>> Function(int id)? onDeactivate;

  int listCalls = 0, getCalls = 0, createCalls = 0, updateCalls = 0;
  int deactivateCalls = 0;
  int? lastEmployeeId, lastShiftId, lastPage, lastPageSize, lastGetId;
  String? lastFromDate, lastToDate;
  bool? lastIncludeInactive;
  EmployeeShiftCreateDto? lastCreate;
  EmployeeShiftUpdateDto? lastUpdate;
  int? lastUpdateId, lastDeactivateId;

  @override
  Future<Result<PagedResult<EmployeeShiftDto>>> list({
    int? employeeId,
    int? shiftId,
    String? fromDate,
    String? toDate,
    bool? includeInactive,
    required int page,
    required int pageSize,
    CancelToken? cancelToken,
  }) async {
    listCalls++;
    lastEmployeeId = employeeId;
    lastShiftId = shiftId;
    lastFromDate = fromDate;
    lastToDate = toDate;
    lastIncludeInactive = includeInactive;
    lastPage = page;
    lastPageSize = pageSize;
    return (onList ??
        (_, _, _, _, _, _, _) async => Success(employeeShiftPage(const [])))(
      employeeId,
      shiftId,
      fromDate,
      toDate,
      includeInactive,
      page,
      pageSize,
    );
  }

  @override
  Future<Result<EmployeeShiftDto>> getById(
    int id, {
    CancelToken? cancelToken,
  }) async {
    getCalls++;
    lastGetId = id;
    return (onGet ??
        (id) async => Success(employeeShiftDto(employeeShiftId: id)))(id);
  }

  @override
  Future<Result<EmployeeShiftDto>> create(
    EmployeeShiftCreateDto request, {
    CancelToken? cancelToken,
  }) async {
    createCalls++;
    lastCreate = request;
    return (onCreate ??
        (request) async => Success(
          employeeShiftDto(
            employeeId: request.employeeId,
            shiftId: request.shiftId,
            fromDate: request.fromDate,
            toDate: request.toDate,
            timeZoneId: request.timeZoneId,
          ),
        ))(request);
  }

  @override
  Future<Result<EmployeeShiftDto>> update(
    int id,
    EmployeeShiftUpdateDto request, {
    CancelToken? cancelToken,
  }) async {
    updateCalls++;
    lastUpdateId = id;
    lastUpdate = request;
    return (onUpdate ??
        (id, request) async => Success(
          employeeShiftDto(
            employeeShiftId: id,
            shiftId: request.shiftId,
            fromDate: request.fromDate,
            toDate: request.toDate,
            timeZoneId: request.timeZoneId,
          ),
        ))(id, request);
  }

  @override
  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken}) async {
    deactivateCalls++;
    lastDeactivateId = id;
    return (onDeactivate ?? (id) async => const Success(null))(id);
  }
}

/// In-memory [EmployeeShiftRepository] for adapter/bloc/widget tests. No
/// network and no live writes; every call is recorded.
class InMemoryEmployeeShiftRepository implements EmployeeShiftRepository {
  InMemoryEmployeeShiftRepository({List<EmployeeShift>? shifts})
    : shifts = [...?shifts];

  final List<EmployeeShift> shifts;
  int listCalls = 0, getCalls = 0, createCalls = 0, updateCalls = 0;
  int deactivateCalls = 0;
  int? lastPage, lastPageSize, lastGetId, lastUpdateId, lastDeactivateId;
  bool? lastIncludeInactive;
  EmployeeShiftDraft? lastCreate, lastUpdate;

  @override
  Future<Result<EmployeeShiftPage>> list({
    int? employeeId,
    int? shiftId,
    String? fromDate,
    String? toDate,
    bool? includeInactive,
    int page = 1,
    int pageSize = 25,
  }) async {
    listCalls++;
    lastIncludeInactive = includeInactive;
    lastPage = page;
    lastPageSize = pageSize;
    final filtered = shifts
        .where((item) => includeInactive == false ? item.isActive : true)
        .toList(growable: false);
    final start = (page - 1) * pageSize;
    final end = start + pageSize > filtered.length
        ? filtered.length
        : start + pageSize;
    final items = start >= filtered.length
        ? const <EmployeeShift>[]
        : filtered.sublist(start, end);
    return Success(
      EmployeeShiftPage(
        items: items,
        page: page,
        pageSize: pageSize,
        totalItems: filtered.length,
        totalPages: filtered.isEmpty
            ? 0
            : ((filtered.length - 1) ~/ pageSize) + 1,
      ),
    );
  }

  @override
  Future<Result<EmployeeShift>> getById(int id) async {
    getCalls++;
    lastGetId = id;
    for (final shift in shifts) {
      if (shift.employeeShiftId == id) return Success(shift);
    }
    return const Failed(
      Failure(code: 'EMPLOYEE_SHIFT_NOT_FOUND', kind: FailureKind.notFound),
    );
  }

  @override
  Future<Result<EmployeeShift>> create(EmployeeShiftDraft draft) async {
    createCalls++;
    lastCreate = draft;
    final shift = _fromDraft(draft, _nextId(), existing: null);
    shifts.add(shift);
    return Success(shift);
  }

  @override
  Future<Result<EmployeeShift>> update(int id, EmployeeShiftDraft draft) async {
    updateCalls++;
    lastUpdateId = id;
    lastUpdate = draft;
    final index = shifts.indexWhere((item) => item.employeeShiftId == id);
    if (index < 0) {
      return const Failed(
        Failure(code: 'EMPLOYEE_SHIFT_NOT_FOUND', kind: FailureKind.notFound),
      );
    }
    final shift = _fromDraft(draft, id, existing: shifts[index]);
    shifts[index] = shift;
    return Success(shift);
  }

  @override
  Future<Result<void>> deactivate(int id) async {
    deactivateCalls++;
    lastDeactivateId = id;
    final index = shifts.indexWhere((item) => item.employeeShiftId == id);
    if (index < 0) {
      return const Failed(
        Failure(code: 'EMPLOYEE_SHIFT_NOT_FOUND', kind: FailureKind.notFound),
      );
    }
    final current = shifts[index];
    shifts[index] = EmployeeShift(
      employeeShiftId: current.employeeShiftId,
      employeeId: current.employeeId,
      employeeCode: current.employeeCode,
      employeeName: current.employeeName,
      shiftId: current.shiftId,
      shiftName: current.shiftName,
      fromDate: current.fromDate,
      toDate: current.toDate,
      startTime: current.startTime,
      endTime: current.endTime,
      earlyPunchInMinutes: current.earlyPunchInMinutes,
      lateGraceMinutes: current.lateGraceMinutes,
      statusId: 2,
      status: 'InActive',
      timeZoneId: current.timeZoneId,
      punchInOpensAt: current.punchInOpensAt,
      crossesMidnight: current.crossesMidnight,
    );
    return const Success(null);
  }

  int _nextId() => shifts.isEmpty
      ? 1
      : shifts
                .map((item) => item.employeeShiftId)
                .reduce((a, b) => a > b ? a : b) +
            1;

  EmployeeShift _fromDraft(
    EmployeeShiftDraft draft,
    int id, {
    EmployeeShift? existing,
  }) {
    final shiftId = draft.shiftId!;
    return EmployeeShift(
      employeeShiftId: id,
      employeeId: draft.employeeId ?? existing!.employeeId,
      employeeCode:
          draft.employeeCode ??
          existing?.employeeCode ??
          'EMP-${draft.employeeId ?? existing?.employeeId}',
      employeeName:
          draft.employeeName ??
          existing?.employeeName ??
          'Employee ${draft.employeeId ?? existing?.employeeId}',
      shiftId: shiftId,
      shiftName: existing?.shiftId == shiftId
          ? existing!.shiftName
          : 'Shift $shiftId',
      fromDate: draft.fromDate!,
      toDate: draft.toDate!,
      startTime: existing?.startTime ?? '09:00:00',
      endTime: existing?.endTime ?? '17:00:00',
      earlyPunchInMinutes: existing?.earlyPunchInMinutes ?? 15,
      lateGraceMinutes: existing?.lateGraceMinutes ?? 15,
      statusId: existing?.statusId ?? 1,
      status: existing?.status ?? 'Active',
      timeZoneId: draft.timeZoneId,
      punchInOpensAt: existing?.punchInOpensAt,
      crossesMidnight: existing?.crossesMidnight ?? false,
    );
  }
}

/// Minimal in-memory employee lookup source for the assignment form.
class FakeEmployeeRepository implements EmployeeRepository {
  FakeEmployeeRepository({List<Employee>? employees})
    : employees = [...?employees];

  final List<Employee> employees;
  int searchCalls = 0;
  int? lastLimit;
  String? lastQuery;

  @override
  Future<Result<List<Employee>>> searchAssignableCompanyEmployees(
    AuthContext context, {
    String query = '',
    int limit = 50,
  }) async {
    searchCalls++;
    lastQuery = query;
    lastLimit = limit;
    return Success(
      employees
          .where(
            (employee) =>
                query.isEmpty ||
                employee.displayName.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .take(limit)
          .toList(growable: false),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Minimal in-memory shift list source for the assignment form.
class FakeShiftRepository implements ShiftRepository {
  FakeShiftRepository({List<Shift>? shifts}) : shifts = [...?shifts];

  final List<Shift> shifts;
  int watchCalls = 0;

  @override
  Stream<Result<ConfigurationPageData<Shift>>> watchList(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) async* {
    watchCalls++;
    final filtered = shifts
        .where((shift) => status == null || shift.status == status)
        .toList(growable: false);
    yield Success(
      ConfigurationPageData<Shift>(
        [for (final shift in filtered) ConfigurationItem<Shift>(shift, 0)],
        filtered.length,
        filtered.length,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
