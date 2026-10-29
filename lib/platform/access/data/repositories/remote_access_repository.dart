import 'dart:async';

import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

/// Backend-mode [AccessRepository] over `/api/user-permissions` and
/// `/api/permissions`.
///
/// The MassERP backend exposes grants, not a user directory, so the Users list
/// is derived from key-bearing grants and grouped by `userId`. Orphan rows
/// (`permissionKey == null` or `permissionStatusId == 2`) are filtered out of
/// both the user list and the grant streams. Access history has no backend
/// endpoint and therefore stays empty; the local Drift activity log is never
/// read in backend mode.
///
/// Successful replaces/assigns/revokes bump an internal revision stream so
/// active watchers re-fetch the authoritative grant list instead of showing
/// optimistic state.
class RemoteAccessRepository implements AccessRepository {
  RemoteAccessRepository(this._dataSource);

  final AccessAdminRemoteDataSource _dataSource;
  final _revision = StreamController<void>.broadcast();

  static const int _pageSize = 100;
  static final DateTime _epoch = DateTime.utc(1970, 1, 1);

  /// Backend self-service permission keys.
  ///
  /// The backend stores key-only grants with no scope column. Self-service keys
  /// keep their intrinsic `self` meaning; every other key is treated as
  /// company-wide (`all`). This mirrors [BackendAccessPolicy] and the documented
  /// AC3 decision without inventing backend scope data.
  static const Set<String> selfServiceKeys = {
    'hr.attendance.self.punch',
    'hr.attendance.self.view',
  };

  static PermissionScope scopeFor(String permissionKey) =>
      selfServiceKeys.contains(permissionKey)
      ? PermissionScope.self
      : PermissionScope.all;

  static bool _isKeyBearing(UserPermissionDto dto) =>
      dto.permissionKey != null && dto.permissionStatusId != 2;

  @override
  Stream<List<AccessUserListItem>> watchUsers({required String companyId}) =>
      _watch(_loadUsers, const <AccessUserListItem>[]);

  @override
  Stream<List<UserPermissionGrant>> watchGrants({
    required String companyId,
    required String userId,
  }) => _watch(
    () => _loadGrants(companyId: companyId, userId: userId),
    const <UserPermissionGrant>[],
  );

  @override
  Stream<List<UserPermissionGrant>> watchCompanyGrants({
    required String companyId,
  }) => _watch(
    () => _loadGrants(companyId: companyId),
    const <UserPermissionGrant>[],
  );

  @override
  Future<Result<List<UserPermissionGrant>>> getGrants({
    required String companyId,
    required String userId,
  }) => _loadGrants(companyId: companyId, userId: userId);

  /// No backend endpoint exists for access history. Do not read local rows.
  @override
  Stream<List<BusinessActivityEvent>> watchHistory({
    required String companyId,
    required String userId,
  }) => Stream.value(const <BusinessActivityEvent>[]);

  @override
  Future<Result<void>> replaceGrants({
    required String companyId,
    required String actorUserId,
    required String targetUserId,
    required String requestId,
    required List<PermissionGrantInput> grants,
  }) async {
    final userId = int.tryParse(targetUserId);
    if (userId == null) {
      return const Failed(
        Failure(code: 'access.invalidUser', kind: FailureKind.invalidData),
      );
    }
    final resolved = await _resolvePermissionIds(grants);
    switch (resolved) {
      case Failed(:final failure):
        return Failed<void>(failure);
      case Success(:final value):
        final result = await _dataSource.replaceUserPermissions(userId, value);
        switch (result) {
          case Failed(:final failure):
            return Failed<void>(failure);
          case Success():
            _revision.add(null);
            return const Success(null);
        }
    }
  }

  /// Assigns additional permission keys to a user (concrete helper, not part of
  /// [AccessRepository]). Kept so the `POST /api/user-permissions` mapping is
  /// exercised without widening the frozen access interface.
  Future<Result<List<UserPermissionGrant>>> assignPermissions({
    required String companyId,
    required String targetUserId,
    required List<PermissionGrantInput> grants,
  }) async {
    final userId = int.tryParse(targetUserId);
    if (userId == null) {
      return const Failed(
        Failure(code: 'access.invalidUser', kind: FailureKind.invalidData),
      );
    }
    final resolved = await _resolvePermissionIds(grants);
    switch (resolved) {
      case Failed(:final failure):
        return Failed(failure);
      case Success(:final value):
        final result = await _dataSource.assignUserPermissions(userId, value);
        switch (result) {
          case Failed(:final failure):
            return Failed(failure);
          case Success(:final value):
            _revision.add(null);
            return Success(_mapGrants(value, companyId: companyId));
        }
    }
  }

  /// Revokes one grant row by its `userPermissionId` (concrete helper, not part
  /// of [AccessRepository]).
  Future<Result<void>> revokePermission({
    required String userPermissionId,
  }) async {
    final id = int.tryParse(userPermissionId);
    if (id == null) {
      return const Failed(
        Failure(code: 'access.invalidGrant', kind: FailureKind.invalidData),
      );
    }
    final result = await _dataSource.removeUserPermission(id);
    switch (result) {
      case Failed(:final failure):
        return Failed<void>(failure);
      case Success():
        _revision.add(null);
        return const Success(null);
    }
  }

  Future<void> dispose() => _revision.close();

  Stream<T> _watch<T>(Future<Result<T>> Function() load, T empty) {
    late StreamController<T> controller;
    StreamSubscription<void>? revision;
    void emit() {
      load().then((result) {
        if (controller.isClosed) return;
        controller.add(result is Success<T> ? result.value : empty);
      });
    }

    controller = StreamController<T>(
      onListen: () {
        emit();
        revision = _revision.stream.listen((_) => emit());
      },
      onCancel: () async => revision?.cancel(),
    );
    return controller.stream;
  }

  Future<Result<List<AccessUserListItem>>> _loadUsers() async {
    final result = await _loadUserPermissionRows();
    switch (result) {
      case Failed(:final failure):
        return Failed(failure);
      case Success(:final value):
        final byUser = <String, AccessUserListItem>{};
        for (final dto in value) {
          if (!_isKeyBearing(dto)) continue;
          byUser.putIfAbsent(dto.userId.toString(), () => _toUser(dto));
        }
        return Success(byUser.values.toList(growable: false));
    }
  }

  Future<Result<List<UserPermissionGrant>>> _loadGrants({
    required String companyId,
    String? userId,
  }) async {
    final numericUserId = userId == null ? null : int.tryParse(userId);
    if (userId != null && numericUserId == null) {
      return const Failed(
        Failure(code: 'access.invalidUser', kind: FailureKind.invalidData),
      );
    }
    final result = await _loadUserPermissionRows(userId: numericUserId);
    switch (result) {
      case Failed(:final failure):
        return Failed(failure);
      case Success(:final value):
        return Success(_mapGrants(value, companyId: companyId));
    }
  }

  Future<Result<List<UserPermissionDto>>> _loadUserPermissionRows({
    int? userId,
  }) async {
    final rows = <UserPermissionDto>[];
    var page = 1;
    while (true) {
      final result = await _dataSource.userPermissions(
        userId: userId,
        page: page,
        pageSize: _pageSize,
      );
      switch (result) {
        case Failed(:final failure):
          return Failed(failure);
        case Success(:final value):
          rows.addAll(value.items);
          if (value.items.isEmpty || value.totalPages <= page) {
            return Success(rows);
          }
          page++;
      }
    }
  }

  Future<Result<List<PermissionDto>>> _loadActivePermissions() async {
    final masters = <PermissionDto>[];
    var page = 1;
    while (true) {
      final result = await _dataSource.permissions(
        page: page,
        pageSize: _pageSize,
        statusId: 1,
      );
      switch (result) {
        case Failed(:final failure):
          return Failed(failure);
        case Success(:final value):
          masters.addAll(value.items);
          if (value.items.isEmpty || value.totalPages <= page) {
            return Success(masters);
          }
          page++;
      }
    }
  }

  Future<Result<List<int>>> _resolvePermissionIds(
    List<PermissionGrantInput> grants,
  ) async {
    final result = await _loadActivePermissions();
    switch (result) {
      case Failed(:final failure):
        return Failed(failure);
      case Success(:final value):
        final byKey = <String, int>{
          for (final permission in value)
            permission.permissionKey: permission.permissionId,
        };
        final ids = <int>[];
        final seen = <String>{};
        for (final grant in grants) {
          if (!seen.add(grant.key)) continue;
          final id = byKey[grant.key];
          if (id == null) {
            return Failed(
              Failure(
                code: 'access.unknownPermission',
                kind: FailureKind.invalidData,
                field: 'permissionKey',
              ),
            );
          }
          ids.add(id);
        }
        return Success(ids);
    }
  }

  List<UserPermissionGrant> _mapGrants(
    List<UserPermissionDto> rows, {
    required String companyId,
  }) => [
    for (final dto in rows)
      if (_isKeyBearing(dto)) _toGrant(dto, companyId: companyId),
  ];

  AccessUserListItem _toUser(UserPermissionDto dto) => AccessUserListItem(
    userId: dto.userId.toString(),
    displayName:
        _firstNonEmpty([dto.userName, dto.employeeName, dto.loginId]) ??
        dto.userId.toString(),
    email: dto.loginId ?? '',
    hasLogin: true,
    accountStatus: 'active',
    employeeId: dto.employeeId?.toString(),
    employeeCode: dto.employeeCode,
  );

  UserPermissionGrant _toGrant(
    UserPermissionDto dto, {
    required String companyId,
  }) {
    final timestamp = dto.createdOn?.toUtc() ?? _epoch;
    return UserPermissionGrant(
      id: dto.userPermissionId.toString(),
      companyId: companyId,
      userId: dto.userId.toString(),
      permissionKey: dto.permissionKey!,
      scope: scopeFor(dto.permissionKey!),
      grantedByUserId: dto.createdBy?.toString() ?? '',
      grantedAt: timestamp,
      updatedAt: timestamp,
      isActive: true,
      syncStatus: 'synced',
    );
  }

  static String? _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
