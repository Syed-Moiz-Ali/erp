import 'dart:async';

import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

/// Backend-mode access administration over `/api/permissions` and
/// `/api/user-permissions`.
///
/// The backend has no access-history endpoint, so history is an empty stream.
/// Users are derived from grant rows (the contract has no standalone company
/// user directory); a user with no grants is not listed.
class RemoteAccessRepository implements AccessRepository {
  RemoteAccessRepository(this._dataSource, this._catalog);

  final AccessAdminRemoteDataSource _dataSource;
  final PermissionCatalog _catalog;
  final _revision = StreamController<void>.broadcast();
  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  Stream<List<T>> _watchList<T>(Future<Result<List<T>>> Function() load) {
    late StreamController<List<T>> controller;
    StreamSubscription<void>? revision;
    void emit() {
      load().then((result) {
        if (controller.isClosed) return;
        controller.add(
          switch (result) {
            Success<List<T>>(:final value) => value,
            Failed<List<T>>() => const [],
          },
        );
      });
    }

    controller = StreamController<List<T>>(
      onListen: () {
        emit();
        revision = _revision.stream.listen((_) => emit());
      },
      onCancel: () async => revision?.cancel(),
    );
    return controller.stream;
  }

  Future<Result<List<UserPermissionDto>>> _allPermissions() async {
    final result = await _loadAllUserPermissions();
    return result;
  }

  Future<Result<List<UserPermissionDto>>> _loadAllUserPermissions() async {
    final rows = <UserPermissionDto>[];
    for (var page = 1; page <= 20; page++) {
      final result = await _dataSource.userPermissions(
        page: page,
        pageSize: 100,
      );
      switch (result) {
        case Failed<PagedResult<UserPermissionDto>>(:final failure):
          return Failed(failure);
        case Success<PagedResult<UserPermissionDto>>(:final value):
          rows.addAll(value.items);
          if (page >= value.totalPages) {
            return Success(rows);
          }
      }
    }
    return Success(rows);
  }

  Future<Result<List<PermissionDto>>> _allPermissionMasters() async {
    final rows = <PermissionDto>[];
    for (var page = 1; page <= 20; page++) {
      final result = await _dataSource.permissions(
        page: page,
        pageSize: 100,
        statusId: 1,
      );
      switch (result) {
        case Failed<PagedResult<PermissionDto>>(:final failure):
          return Failed(failure);
        case Success<PagedResult<PermissionDto>>(:final value):
          rows.addAll(value.items);
          if (page >= value.totalPages) return Success(rows);
      }
    }
    return Success(rows);
  }

  PermissionScope _scopeFor(String? key) {
    if (key == null) return PermissionScope.none;
    final scopes = _catalog.byKey(key)?.supportedScopes ?? const [];
    if (scopes.contains(PermissionScope.all)) return PermissionScope.all;
    if (scopes.contains(PermissionScope.team)) return PermissionScope.team;
    if (scopes.contains(PermissionScope.assigned)) {
      return PermissionScope.assigned;
    }
    if (scopes.contains(PermissionScope.self)) return PermissionScope.self;
    return PermissionScope.none;
  }

  List<UserPermissionGrant> _grants(
    List<UserPermissionDto> rows,
    String companyId, {
    String? userId,
  }) => [
    for (final row in rows)
      if (row.isActive && (userId == null || row.userId.toString() == userId))
        UserPermissionGrant(
          id: row.userPermissionId.toString(),
          companyId: companyId,
          userId: row.userId.toString(),
          permissionKey:
              row.permissionKey ?? '__orphan__${row.permissionId}',
          scope: _scopeFor(row.permissionKey),
          grantedByUserId: (row.createdBy ?? 0).toString(),
          grantedAt: row.createdOn?.toUtc() ?? _epoch,
          updatedAt: row.createdOn?.toUtc() ?? _epoch,
          isOrphan: row.permissionKey == null,
          orphanPermissionId: row.permissionKey == null
              ? row.permissionId
              : null,
          syncStatus: 'synced',
        ),
  ];

  List<AccessUserListItem> _users(
    List<UserPermissionDto> rows,
    String companyId,
  ) {
    final byUser = <String, UserPermissionDto>{};
    for (final row in rows) {
      byUser.putIfAbsent(row.userId.toString(), () => row);
    }
    return [
      for (final entry in byUser.entries)
        AccessUserListItem(
          userId: entry.key,
          displayName: entry.value.userName ??
              entry.value.loginId ??
              'User ${entry.key}',
          email: entry.value.loginId ?? '',
          hasLogin: entry.value.loginId != null,
          accountStatus: 'active',
          employeeId: entry.value.employeeId?.toString(),
          employeeCode: entry.value.employeeCode,
          designationName: null,
          departmentName: null,
          isEmployeeActive: true,
        ),
    ];
  }

  @override
  Stream<List<AccessUserListItem>> watchUsers({
    required String companyId,
  }) => _watchList(() async {
    final result = await _allPermissions();
    return switch (result) {
      Success<List<UserPermissionDto>>(:final value) =>
        Success(_users(value, companyId)),
      Failed<List<UserPermissionDto>>(:final failure) => Failed(failure),
    };
  });

  @override
  Stream<List<UserPermissionGrant>> watchGrants({
    required String companyId,
    required String userId,
  }) => _watchList(() async {
    final result = await _allPermissions();
    return switch (result) {
      Success<List<UserPermissionDto>>(:final value) =>
        Success(_grants(value, companyId, userId: userId)),
      Failed<List<UserPermissionDto>>(:final failure) => Failed(failure),
    };
  });

  @override
  Stream<List<UserPermissionGrant>> watchCompanyGrants({
    required String companyId,
  }) => _watchList(() async {
    final result = await _allPermissions();
    return switch (result) {
      Success<List<UserPermissionDto>>(:final value) =>
        Success(_grants(value, companyId)),
      Failed<List<UserPermissionDto>>(:final failure) => Failed(failure),
    };
  });

  @override
  Future<Result<List<UserPermissionGrant>>> getGrants({
    required String companyId,
    required String userId,
  }) async {
    final result = await _allPermissions();
    return switch (result) {
      Success<List<UserPermissionDto>>(:final value) =>
        Success(_grants(value, companyId, userId: userId)),
      Failed<List<UserPermissionDto>>(:final failure) => Failed(failure),
    };
  }

  @override
  Stream<List<BusinessActivityEvent>> watchHistory({
    required String companyId,
    required String userId,
  }) => Stream.value(const []);

  Future<Result<(int, List<int>)>> _resolveGrantIds(
    String targetUserId,
    List<PermissionGrantInput> grants,
  ) async {
    final userId = int.tryParse(targetUserId);
    if (userId == null) {
      return const Failed(
        Failure(code: 'access.invalidUser', kind: FailureKind.validation),
      );
    }
    final masters = await _allPermissionMasters();
    return switch (masters) {
      Failed<List<PermissionDto>>(:final failure) => Failed(failure),
      Success<List<PermissionDto>>(:final value) => () {
        final ids = <String, int>{
          for (final permission in value)
            if (permission.isActive)
              permission.permissionKey: permission.permissionId,
        };
        final unknown = grants.where((grant) => !ids.containsKey(grant.key));
        if (unknown.isNotEmpty) {
          return Failed<(int, List<int>)>(
            Failure(
              code: 'access.unknownPermission',
              kind: FailureKind.validation,
              field: 'permissionIds',
              serverMessage: unknown.map((g) => g.key).join(', '),
            ),
          );
        }
        return Success<(int, List<int>)>(
          (userId, [for (final grant in grants) ids[grant.key]!]),
        );
      }(),
    };
  }

  @override
  Future<Result<void>> replaceGrants({
    required String companyId,
    required String actorUserId,
    required String targetUserId,
    required String requestId,
    required List<PermissionGrantInput> grants,
  }) async {
    final resolved = await _resolveGrantIds(targetUserId, grants);
    if (resolved is Failed<(int, List<int>)>) {
      return Failed(resolved.failure);
    }
    final (userId, ids) = (resolved as Success<(int, List<int>)>).value;
    final result = await _dataSource.replaceUserPermissions(userId, ids);
    return switch (result) {
      Success<List<UserPermissionDto>>() => () {
        _revision.add(null);
        return const Success<void>(null);
      }(),
      Failed<List<UserPermissionDto>>(:final failure) => Failed(failure),
    };
  }

  @override
  Future<Result<void>> assignGrants({
    required String companyId,
    required String actorUserId,
    required String targetUserId,
    required String requestId,
    required List<PermissionGrantInput> grants,
  }) async {
    final resolved = await _resolveGrantIds(targetUserId, grants);
    if (resolved is Failed<(int, List<int>)>) {
      return Failed(resolved.failure);
    }
    final (userId, ids) = (resolved as Success<(int, List<int>)>).value;
    final result = await _dataSource.assignUserPermissions(userId, ids);
    return switch (result) {
      Success<List<UserPermissionDto>>() => () {
        _revision.add(null);
        return const Success<void>(null);
      }(),
      Failed<List<UserPermissionDto>>(:final failure) => Failed(failure),
    };
  }

  @override
  Future<Result<void>> revokeGrant({
    required String companyId,
    required String targetUserId,
    required String grantId,
  }) async {
    final id = int.tryParse(grantId);
    if (id == null) {
      return const Failed(
        Failure(code: 'access.invalidGrant', kind: FailureKind.validation),
      );
    }
    final result = await _dataSource.removeUserPermission(id);
    return switch (result) {
      Success<UserPermissionDto>() => () {
        _revision.add(null);
        return const Success<void>(null);
      }(),
      Failed<UserPermissionDto>(:final failure) => Failed(failure),
    };
  }

  Future<void> dispose() => _revision.close();
}


