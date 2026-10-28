import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/shifts/data/datasources/shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';

/// MassERP shift datasource built on the shared [ApiClient] and the centralized
/// [ApiEndpoints] registry. No second HTTP client; the Phase 2 auth/refresh
/// lifecycle applies automatically.
class DioShiftRemoteDataSource implements ShiftRemoteDataSource {
  DioShiftRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<Result<PagedResult<ShiftDto>>> list({
    required int page,
    required int pageSize,
    String search = '',
    int? statusId,
    CancelToken? cancelToken,
  }) => _client.get<PagedResult<ShiftDto>>(
    ApiEndpoints.shifts.list,
    query: {
      'page': page,
      'pageSize': pageSize,
      'sort': 'startTime',
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (statusId != null) 'statusId': statusId,
    },
    cancelToken: cancelToken,
    fromJson: (json) => PagedResult.fromJson(
      (json as Map).cast<String, dynamic>(),
      (item) => ShiftDto.fromJson((item as Map).cast<String, dynamic>()),
    ),
  );

  @override
  Future<Result<ShiftDto>> getById(int id, {CancelToken? cancelToken}) =>
      _client.get<ShiftDto>(
        ApiEndpoints.shifts.byId(id),
        cancelToken: cancelToken,
        fromJson: _decode,
      );

  @override
  Future<Result<ShiftDto>> create(
    ShiftUpsertDto request, {
    CancelToken? cancelToken,
  }) => _client.post<ShiftDto>(
    ApiEndpoints.shifts.list,
    body: request,
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<ShiftDto>> update(
    int id,
    ShiftUpsertDto request, {
    CancelToken? cancelToken,
  }) => _client.put<ShiftDto>(
    ApiEndpoints.shifts.byId(id),
    body: request,
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken}) =>
      _client.requestVoid(
        'POST',
        ApiEndpoints.shifts.deactivate(id),
        cancelToken: cancelToken,
      );

  @override
  Future<Result<void>> activate(int id, {CancelToken? cancelToken}) =>
      _client.requestVoid(
        'POST',
        ApiEndpoints.shifts.activate(id),
        cancelToken: cancelToken,
      );

  static ShiftDto _decode(Object? json) =>
      ShiftDto.fromJson((json as Map).cast<String, dynamic>());
}
