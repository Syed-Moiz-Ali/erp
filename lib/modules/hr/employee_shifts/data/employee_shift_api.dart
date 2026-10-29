import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';

class EmployeeShiftApi {
  EmployeeShiftApi(this._client);
  final ApiClient _client;

  EmployeeShift _map(Map<String, dynamic> json) => EmployeeShift(
    id: (json['employeeShiftId'] as num).toInt(),
    employeeId: (json['employeeId'] as num).toInt(),
    shiftId: (json['shiftId'] as num).toInt(),
    fromDate: json['fromDate'] as String? ?? '',
    toDate: json['toDate'] as String? ?? '',
    statusId: (json['statusId'] as num?)?.toInt() ?? 1,
    raw: json,
    employeeCode: json['employeeCode'] as String?,
    employeeName: json['employeeName'] as String?,
    shiftName: json['shiftName'] as String?,
    startTime: json['startTime'] as String?,
    endTime: json['endTime'] as String?,
    timeZoneId: json['timeZoneId'] as String?,
    punchInOpensAt: json['punchInOpensAt'] as String?,
    crossesMidnight: json['crossesMidnight'] as bool? ?? false,
    earlyPunchInMinutes: (json['earlyPunchInMinutes'] as num?)?.toInt() ?? 15,
    lateGraceMinutes: (json['lateGraceMinutes'] as num?)?.toInt() ?? 15,
    status: json['status'] as String?,
  );

  Future<Result<EmployeeShiftPage>> list({
    int? employeeId,
    int? shiftId,
    String? fromDate,
    String? toDate,
    bool includeInactive = false,
    int page = 1,
    int pageSize = 25,
    CancelToken? cancelToken,
  }) async {
    final result = await _client.get<PagedResult<EmployeeShift>>(
      ApiEndpoints.employeeShifts.list,
      query: {
        'page': page,
        'pageSize': pageSize,
        'includeInactive': includeInactive,
        if (employeeId != null) 'employeeId': employeeId,
        if (shiftId != null) 'shiftId': shiftId,
        if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
      },
      cancelToken: cancelToken,
      fromJson: (json) => PagedResult.fromJson(
        (json as Map).cast<String, dynamic>(),
        (item) => _map((item as Map).cast<String, dynamic>()),
      ),
    );
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success(:final value) => Success(
        EmployeeShiftPage(
          items: value.items,
          page: value.page,
          pageSize: value.pageSize,
          totalItems: value.totalItems,
          totalPages: value.totalPages,
        ),
      ),
    };
  }

  Future<Result<EmployeeShift>> create(
    EmployeeShiftDraft draft, {
    CancelToken? cancelToken,
  }) async => _single(
    await _client.post<EmployeeShift>(
      ApiEndpoints.employeeShifts.list,
      body: draft.toBody(),
      cancelToken: cancelToken,
      fromJson: (json) => _map((json as Map).cast<String, dynamic>()),
    ),
  );

  Future<Result<EmployeeShift>> update(
    int id,
    EmployeeShiftDraft draft, {
    CancelToken? cancelToken,
  }) async => _single(
    await _client.put<EmployeeShift>(
      ApiEndpoints.employeeShifts.byId(id),
      body: draft.toBody(includeEmployee: false),
      cancelToken: cancelToken,
      fromJson: (json) => _map((json as Map).cast<String, dynamic>()),
    ),
  );

  Future<Result<EmployeeShift>> deactivate(
    int id, {
    CancelToken? cancelToken,
  }) async => _single(
    await _client.post<EmployeeShift>(
      ApiEndpoints.employeeShifts.deactivate(id),
      cancelToken: cancelToken,
      fromJson: (json) => _map((json as Map).cast<String, dynamic>()),
    ),
  );

  Future<Result<List<ShiftOption>>> employees({CancelToken? cancelToken}) =>
      _client.get<List<ShiftOption>>(
        ApiEndpoints.employees.list,
        query: const {'page': 1, 'pageSize': 100, 'statusId': 1},
        cancelToken: cancelToken,
        fromJson: (json) {
          final map = (json as Map).cast<String, dynamic>();
          return [
            for (final item in (map['items'] as List? ?? const []))
              if (item is Map)
                ShiftOption(
                  (item['employeeId'] as num).toInt(),
                  [item['employeeCode'], item['employeeName']]
                      .whereType<String>()
                      .where((value) => value.isNotEmpty)
                      .join(' - '),
                ),
          ];
        },
      );

  Future<Result<List<ShiftOption>>> shifts({CancelToken? cancelToken}) =>
      _client.get<List<ShiftOption>>(
        ApiEndpoints.shifts.list,
        query: const {'page': 1, 'pageSize': 100, 'statusId': 1},
        cancelToken: cancelToken,
        fromJson: (json) {
          final map = (json as Map).cast<String, dynamic>();
          return [
            for (final item in (map['items'] as List? ?? const []))
              if (item is Map)
                ShiftOption(
                  (item['shiftId'] as num).toInt(),
                  item['shiftName'] as String? ?? '',
                ),
          ];
        },
      );

  Future<Result<List<String>>> timeZones({CancelToken? cancelToken}) =>
      _client.get<List<String>>(
        ApiEndpoints.branches.lookups,
        cancelToken: cancelToken,
        fromJson: (json) {
          final map = (json as Map).cast<String, dynamic>();
          return [
            for (final item in (map['timeZones'] as List? ?? const []))
              if (item is Map) item['id'] as String? ?? '' else '',
          ]..removeWhere((zone) => zone.isEmpty);
        },
      );

  Result<EmployeeShift> _single(Result<EmployeeShift> result) => result;
}
