import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';

/// Remote permission-administration operations used by backend mode.
abstract interface class AccessAdminRemoteDataSource {
  Future<Result<PagedResult<PermissionDto>>> permissions({
    int page = 1,
    int pageSize = 100,
    String search = '',
    int? statusId,
    String sort = 'keyAsc',
    CancelToken? cancelToken,
  });

  Future<Result<PermissionDto>> permissionById(
    int permissionId, {
    CancelToken? cancelToken,
  });

  Future<Result<PermissionDto>> createPermission(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  });

  Future<Result<PermissionDto>> updatePermission(
    int permissionId,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  });

  Future<Result<PermissionDto>> setPermissionActive(
    int permissionId, {
    required bool active,
    CancelToken? cancelToken,
  });

  Future<Result<PagedResult<UserPermissionDto>>> userPermissions({
    int? userId,
    int? employeeId,
    int? permissionId,
    int page = 1,
    int pageSize = 100,
    CancelToken? cancelToken,
  });

  Future<Result<List<UserPermissionDto>>> assignUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  });

  Future<Result<List<UserPermissionDto>>> replaceUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  });

  Future<Result<UserPermissionDto>> removeUserPermission(
    int userPermissionId, {
    CancelToken? cancelToken,
  });
}

class DioAccessAdminRemoteDataSource implements AccessAdminRemoteDataSource {
  DioAccessAdminRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<Result<PagedResult<PermissionDto>>> permissions({
    int page = 1,
    int pageSize = 100,
    String search = '',
    int? statusId,
    String sort = 'keyAsc',
    CancelToken? cancelToken,
  }) => _client.get<PagedResult<PermissionDto>>(
    ApiEndpoints.permissions.list,
    query: {
      'page': page,
      'pageSize': pageSize,
      if (sort.trim().isNotEmpty) 'sort': sort.trim(),
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (statusId != null) 'statusId': statusId,
    },
    cancelToken: cancelToken,
    fromJson: (json) => PagedResult.fromJson(
      (json as Map).cast<String, dynamic>(),
      (item) => PermissionDto.fromJson((item as Map).cast<String, dynamic>()),
    ),
  );

  @override
  Future<Result<PermissionDto>> permissionById(
    int permissionId, {
    CancelToken? cancelToken,
  }) => _client.get<PermissionDto>(
    ApiEndpoints.permissions.byId(permissionId),
    cancelToken: cancelToken,
    fromJson: (json) =>
        PermissionDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  @override
  Future<Result<PermissionDto>> createPermission(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) => _client.post<PermissionDto>(
    ApiEndpoints.permissions.list,
    body: body,
    cancelToken: cancelToken,
    fromJson: (json) =>
        PermissionDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  @override
  Future<Result<PermissionDto>> updatePermission(
    int permissionId,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) => _client.put<PermissionDto>(
    ApiEndpoints.permissions.byId(permissionId),
    body: body,
    cancelToken: cancelToken,
    fromJson: (json) =>
        PermissionDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  @override
  Future<Result<PermissionDto>> setPermissionActive(
    int permissionId, {
    required bool active,
    CancelToken? cancelToken,
  }) => _client.post<PermissionDto>(
    active
        ? ApiEndpoints.permissions.activate(permissionId)
        : ApiEndpoints.permissions.deactivate(permissionId),
    cancelToken: cancelToken,
    fromJson: (json) =>
        PermissionDto.fromJson((json as Map).cast<String, dynamic>()),
  );

  @override
  Future<Result<PagedResult<UserPermissionDto>>> userPermissions({
    int? userId,
    int? employeeId,
    int? permissionId,
    int page = 1,
    int pageSize = 100,
    CancelToken? cancelToken,
  }) => _client.get<PagedResult<UserPermissionDto>>(
    ApiEndpoints.userPermissions.list,
    query: {
      'page': page,
      'pageSize': pageSize,
      if (userId != null) 'userId': userId,
      if (employeeId != null) 'employeeId': employeeId,
      if (permissionId != null) 'permissionId': permissionId,
    },
    cancelToken: cancelToken,
    fromJson: (json) => PagedResult.fromJson(
      (json as Map).cast<String, dynamic>(),
      (item) =>
          UserPermissionDto.fromJson((item as Map).cast<String, dynamic>()),
    ),
  );

  @override
  Future<Result<List<UserPermissionDto>>> assignUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  }) => _client.post<List<UserPermissionDto>>(
    ApiEndpoints.userPermissions.list,
    body: {'userId': userId, 'permissionIds': permissionIds},
    cancelToken: cancelToken,
    fromJson: (json) => [
      for (final item in (json as List))
        UserPermissionDto.fromJson((item as Map).cast<String, dynamic>()),
    ],
  );

  @override
  Future<Result<List<UserPermissionDto>>> replaceUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  }) => _client.put<List<UserPermissionDto>>(
    ApiEndpoints.userPermissions.forUser(userId),
    body: {'permissionIds': permissionIds},
    cancelToken: cancelToken,
    fromJson: (json) => [
      for (final item in (json as List))
        UserPermissionDto.fromJson((item as Map).cast<String, dynamic>()),
    ],
  );

  @override
  Future<Result<UserPermissionDto>> removeUserPermission(
    int userPermissionId, {
    CancelToken? cancelToken,
  }) => _client.delete<UserPermissionDto>(
    ApiEndpoints.userPermissions.byId(userPermissionId),
    cancelToken: cancelToken,
    fromJson: (json) =>
        UserPermissionDto.fromJson((json as Map).cast<String, dynamic>()),
  );
}
