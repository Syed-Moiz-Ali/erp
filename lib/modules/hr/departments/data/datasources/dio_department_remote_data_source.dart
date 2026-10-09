import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/departments/data/datasources/department_remote_data_source.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';

/// MassERP department datasource built on the shared Phase 1 [ApiClient].
///
/// Uses the shared authenticated transport (so the Phase 2 refresh lifecycle
/// applies automatically) and the centralized [ApiEndpoints] registry. No
/// second HTTP client and no custom authentication are introduced. Request
/// bodies carry only documented fields; no `Idempotency-Key` is sent because the
/// backend does not document it (double-submit is guarded client-side instead).
class DioDepartmentRemoteDataSource implements DepartmentRemoteDataSource {
  DioDepartmentRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<Result<PagedResult<DepartmentDto>>> list({
    required int page,
    required int pageSize,
    String search = '',
    CancelToken? cancelToken,
  }) => _client.get<PagedResult<DepartmentDto>>(
    ApiEndpoints.departments.list,
    query: {
      'page': page,
      'pageSize': pageSize,
      'sort': 'nameAsc',
      if (search.trim().isNotEmpty) 'search': search.trim(),
    },
    cancelToken: cancelToken,
    fromJson: (json) => PagedResult.fromJson(
      (json as Map).cast<String, dynamic>(),
      (item) => DepartmentDto.fromJson((item as Map).cast<String, dynamic>()),
    ),
  );

  @override
  Future<Result<DepartmentDto>> getById(int id, {CancelToken? cancelToken}) =>
      _client.get<DepartmentDto>(
        ApiEndpoints.departments.byId(id),
        cancelToken: cancelToken,
        fromJson: _decode,
      );

  @override
  Future<Result<DepartmentDto>> create(
    DepartmentUpsertDto request, {
    CancelToken? cancelToken,
  }) => _client.post<DepartmentDto>(
    ApiEndpoints.departments.list,
    body: request,
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<DepartmentDto>> rename(
    int id,
    DepartmentUpsertDto request, {
    CancelToken? cancelToken,
  }) => _client.put<DepartmentDto>(
    ApiEndpoints.departments.byId(id),
    body: request,
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken}) =>
      _client.requestVoid(
        'POST',
        ApiEndpoints.departments.deactivate(id),
        cancelToken: cancelToken,
      );

  static DepartmentDto _decode(Object? json) =>
      DepartmentDto.fromJson((json as Map).cast<String, dynamic>());
}
