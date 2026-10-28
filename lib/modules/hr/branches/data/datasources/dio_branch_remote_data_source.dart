import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

class DioBranchRemoteDataSource {
  DioBranchRemoteDataSource(this._client);
  final ApiClient _client;

  Future<Result<PagedResult<BranchDto>>> list({
    String search = '',
    String? status,
    int? divisionId,
    String sort = 'nameAsc',
    int page = 1,
    int pageSize = 25,
    CancelToken? cancelToken,
  }) => _client.get<PagedResult<BranchDto>>(
    ApiEndpoints.branches.list,
    query: {
      'page': page,
      'pageSize': pageSize,
      'sort': sort,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status.isNotEmpty) 'status': status,
      if (divisionId != null) 'divisionId': divisionId,
    },
    cancelToken: cancelToken,
    fromJson: (json) => PagedResult.fromJson(
      (json as Map).cast<String, dynamic>(),
      (item) => BranchDto.fromJson((item as Map).cast<String, dynamic>()),
    ),
  );

  Future<Result<BranchDto>> getById(int id, {CancelToken? cancelToken}) =>
      _client.get<BranchDto>(
        ApiEndpoints.branches.byId(id),
        cancelToken: cancelToken,
        fromJson: (json) =>
            BranchDto.fromJson((json as Map).cast<String, dynamic>()),
      );

  Future<Result<BranchDto>> create(
    BranchDraft draft, {
    CancelToken? cancelToken,
  }) => _client.post<BranchDto>(
    ApiEndpoints.branches.list,
    body: branchBody(draft),
    cancelToken: cancelToken,
    fromJson: (json) =>
        BranchDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  Future<Result<BranchDto>> update(
    int id,
    BranchDraft draft, {
    CancelToken? cancelToken,
  }) => _client.put<BranchDto>(
    ApiEndpoints.branches.byId(id),
    body: branchBody(draft),
    cancelToken: cancelToken,
    fromJson: (json) =>
        BranchDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  Future<Result<BranchDto>> setActive(
    int id, {
    required bool active,
    CancelToken? cancelToken,
  }) => _client.post<BranchDto>(
    active
        ? ApiEndpoints.branches.activate(id)
        : ApiEndpoints.branches.deactivate(id),
    cancelToken: cancelToken,
    fromJson: (json) =>
        BranchDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  Future<Result<BranchLookups>> lookups({CancelToken? cancelToken}) =>
      _client.get<BranchLookups>(
        ApiEndpoints.branches.lookups,
        cancelToken: cancelToken,
        fromJson: (json) {
          final map = (json as Map).cast<String, dynamic>();
          List<BranchLookup> items(String key) => [
            for (final item in (map[key] as List? ?? const []))
              if (item is Map)
                BranchLookup(
                  id: '${item['id']}',
                  name: item['name'] as String? ?? '',
                  utcOffset: item['utcOffset'] as String?,
                )
              else
                BranchLookup(id: '$item', name: '$item'),
          ];
          return BranchLookups(
            divisions: items('divisions'),
            statuses: (map['statuses'] as List? ?? const []).cast<String>(),
            yesNo: (map['yesNo'] as List? ?? const []).cast<String>(),
            timeZones: items('timeZones'),
          );
        },
      );
}
