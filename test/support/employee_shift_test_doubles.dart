import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/datasources/employee_shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/dto/employee_shift_dtos.dart';

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
