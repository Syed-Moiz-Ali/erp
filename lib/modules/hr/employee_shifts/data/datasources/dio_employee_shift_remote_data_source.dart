import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/datasources/employee_shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/dto/employee_shift_dtos.dart';

/// Employee-shift datasource over the shared [ApiClient] and the centralized
/// [ApiEndpoints] registry.
class DioEmployeeShiftRemoteDataSource
    implements EmployeeShiftRemoteDataSource {
  DioEmployeeShiftRemoteDataSource(this._client);

  final ApiClient _client;

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
  }) => _client.get<PagedResult<EmployeeShiftDto>>(
    ApiEndpoints.employeeShifts.list,
    query: {
      'page': page,
      'pageSize': pageSize,
      if (employeeId != null) 'employeeId': employeeId,
      if (shiftId != null) 'shiftId': shiftId,
      if (_hasValue(fromDate)) 'fromDate': fromDate!.trim(),
      if (_hasValue(toDate)) 'toDate': toDate!.trim(),
      if (includeInactive != null) 'includeInactive': includeInactive,
    },
    cancelToken: cancelToken,
    fromJson: (json) => PagedResult.fromJson(
      (json as Map).cast<String, dynamic>(),
      (item) =>
          EmployeeShiftDto.fromJson((item as Map).cast<String, dynamic>()),
    ),
  );

  @override
  Future<Result<EmployeeShiftDto>> getById(
    int id, {
    CancelToken? cancelToken,
  }) => _client.get<EmployeeShiftDto>(
    ApiEndpoints.employeeShifts.byId(id),
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<EmployeeShiftDto>> create(
    EmployeeShiftCreateDto request, {
    CancelToken? cancelToken,
  }) => _client.post<EmployeeShiftDto>(
    ApiEndpoints.employeeShifts.list,
    body: request.toJson(),
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<EmployeeShiftDto>> update(
    int id,
    EmployeeShiftUpdateDto request, {
    CancelToken? cancelToken,
  }) => _client.put<EmployeeShiftDto>(
    ApiEndpoints.employeeShifts.byId(id),
    body: request.toJson(),
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken}) =>
      _client.requestVoid(
        'POST',
        ApiEndpoints.employeeShifts.deactivate(id),
        cancelToken: cancelToken,
      );

  static EmployeeShiftDto _decode(Object? json) =>
      EmployeeShiftDto.fromJson((json as Map).cast<String, dynamic>());

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;
}
