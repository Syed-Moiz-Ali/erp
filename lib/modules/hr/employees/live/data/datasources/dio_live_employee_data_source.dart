import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';

class DioLiveEmployeeDataSource {
  DioLiveEmployeeDataSource(this._client);
  final ApiClient _client;

  Future<Result<PagedResult<LiveEmployeeDto>>> list({
    String search = '',
    int? statusId,
    int? departmentId,
    int? branchId,
    String sort = 'nameAsc',
    int page = 1,
    int pageSize = 25,
    CancelToken? cancelToken,
  }) => _client.get<PagedResult<LiveEmployeeDto>>(
    ApiEndpoints.employees.list,
    query: {
      'page': page,
      'pageSize': pageSize,
      'sort': sort,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (statusId != null) 'statusId': statusId,
      if (departmentId != null) 'departmentId': departmentId,
      if (branchId != null) 'branchId': branchId,
    },
    cancelToken: cancelToken,
    fromJson: (json) => PagedResult.fromJson(
      (json as Map).cast<String, dynamic>(),
      (item) =>
          LiveEmployeeDto.fromJson((item as Map).cast<String, dynamic>()),
    ),
  );

  Future<Result<LiveEmployeeDto>> getById(
    int id, {
    CancelToken? cancelToken,
  }) => _client.get<LiveEmployeeDto>(
    ApiEndpoints.employees.byId(id),
    cancelToken: cancelToken,
    fromJson: (json) =>
        LiveEmployeeDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  Future<Result<LiveEmployeeDto>> create(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) => _client.post<LiveEmployeeDto>(
    ApiEndpoints.employees.list,
    body: body,
    cancelToken: cancelToken,
    fromJson: (json) =>
        LiveEmployeeDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  Future<Result<LiveEmployeeDto>> update(
    int id,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) => _client.put<LiveEmployeeDto>(
    ApiEndpoints.employees.byId(id),
    body: body,
    cancelToken: cancelToken,
    fromJson: (json) =>
        LiveEmployeeDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  Future<Result<LiveEmployeeDto>> setActive(
    int id, {
    required bool active,
    CancelToken? cancelToken,
  }) => _client.post<LiveEmployeeDto>(
    active
        ? ApiEndpoints.employees.activate(id)
        : ApiEndpoints.employees.deactivate(id),
    cancelToken: cancelToken,
    fromJson: (json) =>
        LiveEmployeeDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  Future<Result<LiveEmployeeLookups>> lookups({CancelToken? cancelToken}) async {
    final employeeLookups = await _client.get<LiveEmployeeLookups>(
      ApiEndpoints.employees.lookups,
      cancelToken: cancelToken,
      fromJson: (json) => mapLookups((json as Map).cast<String, dynamic>()),
    );
    if (employeeLookups is Failed<LiveEmployeeLookups>) {
      return employeeLookups;
    }
    final activeBranches = await _client.get<List<Lookup>>(
      ApiEndpoints.branches.list,
      query: const {'page': 1, 'pageSize': 100, 'status': 'Active'},
      cancelToken: cancelToken,
      fromJson: (json) {
        final map = (json as Map).cast<String, dynamic>();
        return [
          for (final item in (map['items'] as List? ?? const []))
            if (item is Map)
              Lookup(
                (item['branchId'] as num).toInt(),
                item['branchName'] as String? ?? '',
              ),
        ];
      },
    );
    final base = (employeeLookups as Success<LiveEmployeeLookups>).value;
    return Success(
      LiveEmployeeLookups(
        branches: activeBranches is Success<List<Lookup>>
            ? activeBranches.value
            : base.branches,
        departments: base.departments,
        nationalities: base.nationalities,
        statuses: base.statuses,
      ),
    );
  }
}



