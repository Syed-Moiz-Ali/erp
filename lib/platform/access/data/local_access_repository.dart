import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/core/sync/outbox_repository.dart';
import 'package:modular_erp/core/sync/pending_mutation.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/platform/access/data/access_user_directory.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';

class LocalAccessRepository implements AccessRepository {
  LocalAccessRepository(
    this.database,
    this.clock,
    this.activity,
    this.directory, {
    OutboxRepository? outbox,
    Uuid? uuid,
  }) : _outbox = outbox,
       _uuid = uuid ?? const Uuid();
  final AppDatabase database;
  final AppClock clock;
  final ActivityRepository activity;
  final AccessUserDirectory directory;
  final OutboxRepository? _outbox;
  final Uuid _uuid;

  static const _pending = 'pending';
  static const _accessEntityType = 'accessUser';

  UserPermissionGrant _fromRow(UserPermissionGrantRow row) =>
      UserPermissionGrant(
        id: row.id,
        companyId: row.companyId,
        userId: row.userId,
        permissionKey: row.permissionKey,
        scope: PermissionScope.values.byName(row.scopeKey),
        grantedByUserId: row.grantedByUserId,
        grantedAt: row.grantedAt.toUtc(),
        updatedAt: row.updatedAt.toUtc(),
        expiresAt: row.expiresAt?.toUtc(),
        isActive: row.isActive,
        requestId: row.requestId,
        syncStatus: row.syncStatus,
      );

  @override
  Stream<List<AccessUserListItem>> watchUsers({required String companyId}) =>
      directory.watchUsers(companyId: companyId);

  @override
  Stream<List<UserPermissionGrant>> watchGrants({
    required String companyId,
    required String userId,
  }) =>
      (database.select(database.userPermissionGrants)..where(
            (t) =>
                t.companyId.equals(companyId) &
                t.userId.equals(userId) &
                t.isActive.equals(true),
          ))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Stream<List<UserPermissionGrant>> watchCompanyGrants({
    required String companyId,
  }) =>
      (database.select(database.userPermissionGrants)..where(
            (t) => t.companyId.equals(companyId) & t.isActive.equals(true),
          ))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  @override
  Future<Result<List<UserPermissionGrant>>> getGrants({
    required String companyId,
    required String userId,
  }) async {
    try {
      final rows =
          await (database.select(database.userPermissionGrants)..where(
                (t) =>
                    t.companyId.equals(companyId) &
                    t.userId.equals(userId) &
                    t.isActive.equals(true),
              ))
              .get();
      return Success(rows.map(_fromRow).toList());
    } catch (_) {
      return const Failed(
        Failure(code: 'accessFailure', kind: FailureKind.storageWrite),
      );
    }
  }

  @override
  Stream<List<BusinessActivityEvent>> watchHistory({
    required String companyId,
    required String userId,
  }) =>
      (database.select(database.businessActivityEvents)..where(
            (t) =>
                t.companyId.equals(companyId) &
                t.entityType.equals(_accessEntityType) &
                t.entityId.equals(userId),
          ))
          .watch()
          .map(
            (rows) =>
                rows
                    .map(
                      (row) => BusinessActivityEvent(
                        id: row.id,
                        companyId: row.companyId,
                        moduleKey: row.moduleKey,
                        entityType: row.entityType,
                        entityId: row.entityId,
                        eventType: row.eventType,
                        occurredAt: row.occurredAt.toUtc(),
                        actorUserId: row.actorUserId,
                        actorEmployeeId: row.actorEmployeeId,
                        summaryKey: row.summaryKey,
                        metadata:
                            jsonDecode(row.metadataJson)
                                as Map<String, Object?>? ??
                            const {},
                        requestId: row.requestId,
                        syncStatus: row.syncStatus,
                      ),
                    )
                    .toList()
                  ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)),
          );

  Future<void> _record(
    String eventType,
    String companyId,
    String actorUserId,
    String targetUserId,
    DateTime now, {
    String? permissionKey,
    PermissionScope? oldScope,
    PermissionScope? newScope,
  }) => activity.append(
    BusinessActivityEvent(
      id: _uuid.v4(),
      companyId: companyId,
      moduleKey: 'platform',
      entityType: _accessEntityType,
      entityId: targetUserId,
      eventType: eventType,
      occurredAt: now,
      actorUserId: actorUserId,
      syncStatus: _pending,
      metadata: {
        if (permissionKey != null) 'permissionKey': permissionKey,
        if (oldScope != null) 'oldScope': oldScope.name,
        if (newScope != null) 'newScope': newScope.name,
      },
    ),
  );

  @override
  Future<Result<void>> replaceGrants({
    required String companyId,
    required String actorUserId,
    required String targetUserId,
    required String requestId,
    required List<PermissionGrantInput> grants,
  }) async {
    try {
      await database.transaction(() async {
        final existingRows =
            await (database.select(database.userPermissionGrants)..where(
                  (t) =>
                      t.companyId.equals(companyId) &
                      t.userId.equals(targetUserId),
                ))
                .get();
        final existing = {
          for (final row in existingRows) row.permissionKey: row,
        };
        final incoming = {for (final grant in grants) grant.key: grant};
        final now = clock.now();

        await (database.delete(database.userPermissionGrants)..where(
              (t) =>
                  t.companyId.equals(companyId) & t.userId.equals(targetUserId),
            ))
            .go();

        for (final grant in grants) {
          await database
              .into(database.userPermissionGrants)
              .insert(
                UserPermissionGrantsCompanion.insert(
                  id: _uuid.v4(),
                  companyId: companyId,
                  userId: targetUserId,
                  permissionKey: grant.key,
                  scopeKey: grant.scope.name,
                  grantedByUserId: actorUserId,
                  grantedAt: now,
                  updatedAt: now,
                  syncStatus: _pending,
                  requestId: Value(requestId),
                ),
              );
          final previous = existing[grant.key];
          if (previous == null) {
            await _record(
              'access.permission.added',
              companyId,
              actorUserId,
              targetUserId,
              now,
              permissionKey: grant.key,
              newScope: grant.scope,
            );
          } else if (previous.scopeKey != grant.scope.name) {
            await _record(
              'access.permission.updated',
              companyId,
              actorUserId,
              targetUserId,
              now,
              permissionKey: grant.key,
              oldScope: PermissionScope.values.byName(previous.scopeKey),
              newScope: grant.scope,
            );
          }
        }
        for (final previous in existing.values) {
          if (!incoming.containsKey(previous.permissionKey)) {
            await _record(
              'access.permission.removed',
              companyId,
              actorUserId,
              targetUserId,
              now,
              permissionKey: previous.permissionKey,
              oldScope: PermissionScope.values.byName(previous.scopeKey),
            );
          }
        }

        await _outbox?.enqueue(
          PendingMutation(
            id: _uuid.v4(),
            moduleId: 'access',
            entityId: targetUserId,
            entityType: _accessEntityType,
            operation: 'ACCESS_GRANTS_REPLACE',
            payload: {
              'userId': targetUserId,
              'grants': [
                for (final grant in grants)
                  {'key': grant.key, 'scope': grant.scope.name},
              ],
            },
            createdAt: now,
            companyId: companyId,
            requestId: requestId,
          ),
        );
      });
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'accessFailure', kind: FailureKind.storageWrite),
      );
    }
  }
}
