import '../../../core/errors/result.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

/// Used before a repository is injected (e.g. early bootstrap or widget tests).
/// It never fabricates notifications.
class NoopNotificationRepository implements NotificationRepository {
  const NoopNotificationRepository();

  @override
  Stream<List<AppNotification>> watchNotifications({
    required String companyId,
    required String userId,
  }) => Stream.value(const []);

  @override
  Stream<int> watchUnreadCount({
    required String companyId,
    required String userId,
  }) => Stream.value(0);

  @override
  Future<Result<AppNotification?>> getById({
    required String companyId,
    required String userId,
    required String id,
  }) async => const Success(null);

  @override
  Future<Result<void>> createLocal(AppNotification notification) async =>
      const Success(null);

  @override
  Future<Result<void>> markRead({
    required String companyId,
    required String userId,
    required String id,
    required DateTime at,
  }) async => const Success(null);

  @override
  Future<Result<void>> markAllRead({
    required String companyId,
    required String userId,
    required DateTime at,
  }) async => const Success(null);

  @override
  Future<Result<int>> purgeOlderThan({
    required String companyId,
    required String userId,
    required DateTime cutoff,
  }) async => const Success(0);
}
