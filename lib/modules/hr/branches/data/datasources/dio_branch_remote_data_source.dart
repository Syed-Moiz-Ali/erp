import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/datasources/branch_remote_data_source.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

class DioBranchRemoteDataSource implements BranchRemoteDataSource {
  DioBranchRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<Result<PagedResult<BranchDto>>> list({
    String? search,
    BranchStatus? status,
    int? divisionId,
    String? sort,
    required int page,
    required int pageSize,
    CancelToken? cancelToken,
  }) => _client.get<PagedResult<BranchDto>>(
    ApiEndpoints.branches.list,
    query: {
      'page': page,
      'pageSize': pageSize,
      if (_hasValue(search)) 'search': search!.trim(),
      if (status != null) 'status': status.wire,
      if (divisionId != null) 'divisionId': divisionId,
      if (_hasValue(sort)) 'sort': sort!.trim(),
    },
    cancelToken: cancelToken,
    fromJson: (json) => PagedResult.fromJson(
      (json as Map).cast<String, dynamic>(),
      (item) => BranchDto.fromJson((item as Map).cast<String, dynamic>()),
    ),
  );

  @override
  Future<Result<BranchLookupsDto>> lookups({CancelToken? cancelToken}) =>
      _client.get<BranchLookupsDto>(
        ApiEndpoints.branches.lookups,
        cancelToken: cancelToken,
        fromJson: (json) =>
            BranchLookupsDto.fromJson((json as Map).cast<String, dynamic>()),
      );

  @override
  Future<Result<BranchDto>> getById(int id, {CancelToken? cancelToken}) =>
      _client.get<BranchDto>(
        ApiEndpoints.branches.byId(id),
        cancelToken: cancelToken,
        fromJson: _decode,
      );

  @override
  Future<Result<BranchDto>> create(
    BranchUpsertDto request, {
    CancelToken? cancelToken,
  }) => _client.post<BranchDto>(
    ApiEndpoints.branches.list,
    body: request.toJson(),
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<BranchDto>> update(
    int id,
    BranchUpsertDto request, {
    CancelToken? cancelToken,
  }) => _client.put<BranchDto>(
    ApiEndpoints.branches.byId(id),
    body: request.toJson(),
    cancelToken: cancelToken,
    fromJson: _decode,
  );

  @override
  Future<Result<void>> activate(int id, {CancelToken? cancelToken}) =>
      _client.requestVoid(
        'POST',
        ApiEndpoints.branches.activate(id),
        cancelToken: cancelToken,
      );

  @override
  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken}) =>
      _client.requestVoid(
        'POST',
        ApiEndpoints.branches.deactivate(id),
        cancelToken: cancelToken,
      );

  static BranchDto _decode(Object? json) =>
      BranchDto.fromJson((json as Map).cast<String, dynamic>());

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;
}
