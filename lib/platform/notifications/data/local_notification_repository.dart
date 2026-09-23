import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/notifications/domain/app_notification.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';

class LocalNotificationRepository implements NotificationRepository {
  const LocalNotificationRepository(this.db);
  final AppDatabase db;

  AppNotification _map(AppNotificationData row) => AppNotification(
    id: row.id,
    companyId: row.companyId,
    userId: row.userId,
    type: AppNotificationType.fromName(row.type),
    payload: jsonDecode(row.payload) as Map<String, dynamic>,
    priority: AppNotificationPriority.values.firstWhere(
      (p) => p.name == row.priority,
      orElse: () => AppNotificationPriority.normal,
    ),
    source: AppNotificationSource.values.firstWhere(
      (s) => s.name == row.source,
      orElse: () => AppNotificationSource.local,
    ),
    route: row.route,
    dedupeKey: row.dedupeKey,
    createdAt: row.createdAt,
    readAt: row.readAt,
  );

  @override
  Stream<List<AppNotification>> watchNotifications({
    required String companyId,
    required String userId,
  }) =>
      (db.select(db.appNotifications)
            ..where(
              (t) => t.companyId.equals(companyId) & t.userId.equals(userId),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch()
          .map((rows) => rows.map(_map).toList());

  @override
  Stream<int> watchUnreadCount({
    required String companyId,
    required String userId,
  }) =>
      (db.select(db.appNotifications)..where(
            (t) =>
                t.companyId.equals(companyId) &
                t.userId.equals(userId) &
                t.readAt.isNull(),
          ))
          .watch()
          .map((rows) => rows.length);

  @override
  Future<Result<AppNotification?>> getById({
    required String companyId,
    required String userId,
    required String id,
  }) async {
    try {
      final row =
          await (db.select(db.appNotifications)..where(
                (t) =>
                    t.id.equals(id) &
                    t.companyId.equals(companyId) &
                    t.userId.equals(userId),
              ))
              .getSingleOrNull();
      return Success(row == null ? null : _map(row));
    } catch (_) {
      return const Failed(
        Failure(code: 'notification_read', kind: FailureKind.storageWrite),
      );
    }
  }

  @override
  Future<Result<void>> createLocal(AppNotification notification) async {
    try {
      await db
          .into(db.appNotifications)
          .insert(
            AppNotificationsCompanion.insert(
              id: notification.id,
              companyId: notification.companyId,
              userId: notification.userId,
              type: notification.type.name,
              payload: Value(jsonEncode(notification.payload)),
              priority: Value(notification.priority.name),
              source: Value(notification.source.name),
              route: Value(notification.route),
              dedupeKey: Value(notification.dedupeKey),
              createdAt: notification.createdAt,
              readAt: Value(notification.readAt),
            ),
            // Dedupe keys collapse repeated sync failures into one record.
            mode: InsertMode.insertOrIgnore,
          );
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'notification_create', kind: FailureKind.storageWrite),
      );
    }
  }

  @override
  Future<Result<void>> markRead({
    required String companyId,
    required String userId,
    required String id,
    required DateTime at,
  }) async {
    try {
      await (db.update(db.appNotifications)..where(
            (t) =>
                t.id.equals(id) &
                t.companyId.equals(companyId) &
                t.userId.equals(userId),
          ))
          .write(AppNotificationsCompanion(readAt: Value(at)));
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'notification_update', kind: FailureKind.storageUpdate),
      );
    }
  }

  @override
  Future<Result<void>> markAllRead({
    required String companyId,
    required String userId,
    required DateTime at,
  }) async {
    try {
      await (db.update(db.appNotifications)..where(
            (t) =>
                t.companyId.equals(companyId) &
                t.userId.equals(userId) &
                t.readAt.isNull(),
          ))
          .write(AppNotificationsCompanion(readAt: Value(at)));
      return const Success(null);
    } catch (_) {
      return const Failed(
        Failure(code: 'notification_update', kind: FailureKind.storageUpdate),
      );
    }
  }

  @override
  Future<Result<int>> purgeOlderThan({
    required String companyId,
    required String userId,
    required DateTime cutoff,
  }) async {
    try {
      final removed =
          await (db.delete(db.appNotifications)..where(
                (t) =>
                    t.companyId.equals(companyId) &
                    t.userId.equals(userId) &
                    t.createdAt.isSmallerThanValue(cutoff),
              ))
              .go();
      return Success(removed);
    } catch (_) {
      return const Failed(
        Failure(code: 'notification_purge', kind: FailureKind.storageUpdate),
      );
    }
  }
}
