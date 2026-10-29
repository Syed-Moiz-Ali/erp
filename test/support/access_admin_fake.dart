import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';

/// In-memory [AccessAdminRemoteDataSource] for backend-mode access tests.
/// No network is touched and every write is only recorded.
class FakeAccessAdminRemoteDataSource implements AccessAdminRemoteDataSource {
  List<PermissionDto> permissionsCatalog = const [];
  List<UserPermissionDto> grantRows = const [];

  /// When set, the corresponding operation fails instead of returning data.
  Failure? permissionsFailure;
  Failure? permissionByIdFailure;
  Failure? userPermissionsFailure;
  Failure? userPermissionByIdFailure;
  Failure? assignFailure;
  Failure? replaceFailure;
  Failure? removeFailure;

  Result<PermissionDto>? permissionByIdResult;
  Result<PermissionDto>? createResult;
  Result<PermissionDto>? updateResult;
  Result<PermissionDto>? setActiveResult;
  Result<List<UserPermissionDto>>? assignResult;
  Result<List<UserPermissionDto>>? replaceResult;
  Result<UserPermissionDto>? userPermissionByIdResult;
  Result<UserPermissionDto>? removeResult;

  final List<int> permissionPages = [];
  final List<int> userPermissionPages = [];

  int? lastPermissionsPage;
  int? lastPermissionsPageSize;
  String? lastPermissionsSearch;
  int? lastPermissionsStatusId;
  String? lastPermissionsSort;
  Map<String, dynamic>? lastCreateBody;
  int? lastUpdateId;
  Map<String, dynamic>? lastUpdateBody;
  int? lastActiveId;
  bool? lastActive;
  int? lastUserIdFilter;
  int? lastUserPermissionById;
  int? lastAssignUserId;
  List<int>? lastAssignPermissionIds;
  int? lastReplaceUserId;
  List<int>? lastReplacePermissionIds;
  int? lastRemoveUserPermissionId;

  @override
  Future<Result<PagedResult<PermissionDto>>> permissions({
    int page = 1,
    int pageSize = 100,
    String search = '',
    int? statusId,
    String sort = 'keyAsc',
    CancelToken? cancelToken,
  }) async {
    permissionPages.add(page);
    lastPermissionsPage = page;
    lastPermissionsPageSize = pageSize;
    lastPermissionsSearch = search;
    lastPermissionsStatusId = statusId;
    lastPermissionsSort = sort;
    if (permissionsFailure != null) return Failed(permissionsFailure!);
    var filtered = permissionsCatalog;
    if (statusId != null) {
      filtered = filtered.where((p) => p.statusId == statusId).toList();
    }
    return Success(_page(filtered, page, pageSize));
  }

  @override
  Future<Result<PermissionDto>> permissionById(
    int permissionId, {
    CancelToken? cancelToken,
  }) async {
    if (permissionByIdFailure != null) {
      return Failed(permissionByIdFailure!);
    }
    if (permissionByIdResult != null) return permissionByIdResult!;
    for (final permission in permissionsCatalog) {
      if (permission.permissionId == permissionId) {
        return Success(permission);
      }
    }
    return const Failed(
      Failure(code: 'PERMISSION_NOT_FOUND', kind: FailureKind.notFound),
    );
  }

  @override
  Future<Result<PermissionDto>> createPermission(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    lastCreateBody = body;
    return createResult ??
        const Failed(Failure(code: 'unused', kind: FailureKind.unknown));
  }

  @override
  Future<Result<PermissionDto>> updatePermission(
    int permissionId,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    lastUpdateId = permissionId;
    lastUpdateBody = body;
    return updateResult ??
        const Failed(Failure(code: 'unused', kind: FailureKind.unknown));
  }

  @override
  Future<Result<PermissionDto>> setPermissionActive(
    int permissionId, {
    required bool active,
    CancelToken? cancelToken,
  }) async {
    lastActiveId = permissionId;
    lastActive = active;
    return setActiveResult ??
        const Failed(Failure(code: 'unused', kind: FailureKind.unknown));
  }

  @override
  Future<Result<PagedResult<UserPermissionDto>>> userPermissions({
    int? userId,
    int? employeeId,
    int? permissionId,
    int page = 1,
    int pageSize = 100,
    CancelToken? cancelToken,
  }) async {
    userPermissionPages.add(page);
    lastUserIdFilter = userId;
    if (userPermissionsFailure != null) {
      return Failed(userPermissionsFailure!);
    }
    var filtered = grantRows;
    if (userId != null) {
      filtered = filtered.where((row) => row.userId == userId).toList();
    }
    if (employeeId != null) {
      filtered = filtered.where((row) => row.employeeId == employeeId).toList();
    }
    if (permissionId != null) {
      filtered = filtered
          .where((row) => row.permissionId == permissionId)
          .toList();
    }
    return Success(_page(filtered, page, pageSize));
  }

  @override
  Future<Result<UserPermissionDto>> userPermissionById(
    int userPermissionId, {
    CancelToken? cancelToken,
  }) async {
    lastUserPermissionById = userPermissionId;
    if (userPermissionByIdFailure != null) {
      return Failed(userPermissionByIdFailure!);
    }
    if (userPermissionByIdResult != null) return userPermissionByIdResult!;
    for (final row in grantRows) {
      if (row.userPermissionId == userPermissionId) return Success(row);
    }
    return const Failed(
      Failure(code: 'USER_PERMISSION_NOT_FOUND', kind: FailureKind.notFound),
    );
  }

  @override
  Future<Result<List<UserPermissionDto>>> assignUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  }) async {
    lastAssignUserId = userId;
    lastAssignPermissionIds = List.of(permissionIds);
    if (assignFailure != null) return Failed(assignFailure!);
    if (assignResult != null) return assignResult!;
    return const Success([]);
  }

  @override
  Future<Result<List<UserPermissionDto>>> replaceUserPermissions(
    int userId,
    List<int> permissionIds, {
    CancelToken? cancelToken,
  }) async {
    lastReplaceUserId = userId;
    lastReplacePermissionIds = List.of(permissionIds);
    if (replaceFailure != null) return Failed(replaceFailure!);
    if (replaceResult != null) return replaceResult!;
    return Success(
      grantRows.where((row) => row.userId == userId).toList(growable: false),
    );
  }

  @override
  Future<Result<UserPermissionDto>> removeUserPermission(
    int userPermissionId, {
    CancelToken? cancelToken,
  }) async {
    lastRemoveUserPermissionId = userPermissionId;
    if (removeFailure != null) return Failed(removeFailure!);
    if (removeResult != null) return removeResult!;
    return const Failed(
      Failure(code: 'USER_PERMISSION_NOT_FOUND', kind: FailureKind.notFound),
    );
  }

  PagedResult<T> _page<T>(List<T> items, int page, int pageSize) {
    final totalPages = items.isEmpty ? 0 : (items.length / pageSize).ceil();
    final start = (page - 1) * pageSize;
    final slice = start >= items.length
        ? <T>[]
        : items.sublist(start, math.min(start + pageSize, items.length));
    return PagedResult(
      items: slice,
      page: page,
      pageSize: pageSize,
      totalItems: items.length,
      totalPages: totalPages,
    );
  }
}
