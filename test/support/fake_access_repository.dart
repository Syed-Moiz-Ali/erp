import 'dart:async';

import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

/// In-memory [AccessRepository] for widget tests. It deliberately mirrors the
/// backend contract (replace/assign/revoke) without any local grant storage.
class FakeAccessRepository implements AccessRepository {
  FakeAccessRepository({
    required List<AccessUserListItem> users,
    Map<String, List<UserPermissionGrant>> grants = const {},
  }) : _users = List.unmodifiable(users),
       _grants = {
         for (final entry in grants.entries)
           entry.key: List.of(entry.value),
       };

  final List<AccessUserListItem> _users;
  final Map<String, List<UserPermissionGrant>> _grants;
  final _revision = StreamController<void>.broadcast();
  var _nextId = 1000;

  Stream<List<T>> _watch<T>(List<T> Function() load) {
    late StreamController<List<T>> controller;
    StreamSubscription<void>? revision;
    void emit() {
      if (!controller.isClosed) controller.add(load());
    }

    controller = StreamController<List<T>>(
      onListen: () {
        emit();
        revision = _revision.stream.listen((_) => emit());
      },
      onCancel: () => revision?.cancel(),
    );
    return controller.stream;
  }

  List<UserPermissionGrant> _list(String companyId, String? userId) => [
    for (final entry in _grants.entries)
      if (userId == null || entry.key == userId) ...entry.value,
  ];

  UserPermissionGrant _grant(
    String companyId,
    String userId,
    PermissionGrantInput input,
  ) => UserPermissionGrant(
    id: '${_nextId++}',
    companyId: companyId,
    userId: userId,
    permissionKey: input.key,
    scope: input.scope,
    grantedByUserId: 'admin',
    grantedAt: DateTime.utc(2026, 10, 28),
    updatedAt: DateTime.utc(2026, 10, 28),
    syncStatus: 'synced',
  );

  @override
  Stream<List<AccessUserListItem>> watchUsers({required String companyId}) =>
      _watch(() => _users.where((u) => true).toList());

  @override
  Stream<List<UserPermissionGrant>> watchGrants({
    required String companyId,
    required String userId,
  }) => _watch(() => _list(companyId, userId));

  @override
  Stream<List<UserPermissionGrant>> watchCompanyGrants({
    required String companyId,
  }) => _watch(() => _list(companyId, null));

  @override
  Future<Result<List<UserPermissionGrant>>> getGrants({
    required String companyId,
    required String userId,
  }) async => Success(_list(companyId, userId));

  @override
  Stream<List<BusinessActivityEvent>> watchHistory({
    required String companyId,
    required String userId,
  }) => Stream.value(const []);

  @override
  Future<Result<void>> replaceGrants({
    required String companyId,
    required String actorUserId,
    required String targetUserId,
    required String requestId,
    required List<PermissionGrantInput> grants,
  }) async {
    _grants[targetUserId] = [
      for (final grant in grants) _grant(companyId, targetUserId, grant),
    ];
    _revision.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> assignGrants({
    required String companyId,
    required String actorUserId,
    required String targetUserId,
    required String requestId,
    required List<PermissionGrantInput> grants,
  }) async {
    final current = _grants.putIfAbsent(targetUserId, () => []);
    for (final grant in grants) {
      current.removeWhere((row) => row.permissionKey == grant.key);
      current.add(_grant(companyId, targetUserId, grant));
    }
    _revision.add(null);
    return const Success(null);
  }

  @override
  Future<Result<void>> revokeGrant({
    required String companyId,
    required String targetUserId,
    required String grantId,
  }) async {
    _grants[targetUserId]?.removeWhere((row) => row.id == grantId);
    _revision.add(null);
    return const Success(null);
  }

  Future<void> dispose() => _revision.close();
}
