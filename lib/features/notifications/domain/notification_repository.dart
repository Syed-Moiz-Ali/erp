import '../../../core/errors/result.dart';
import 'app_notification.dart';

abstract interface class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications({
    required String companyId,
    required String userId,
  });
  Stream<int> watchUnreadCount({
    required String companyId,
    required String userId,
  });
  Future<Result<AppNotification?>> getById({
    required String companyId,
    required String userId,
    required String id,
  });
  Future<Result<void>> createLocal(AppNotification notification);
  Future<Result<void>> markRead({
    required String companyId,
    required String userId,
    required String id,
    required DateTime at,
  });
  Future<Result<void>> markAllRead({
    required String companyId,
    required String userId,
    required DateTime at,
  });
  Future<Result<int>> purgeOlderThan({
    required String companyId,
    required String userId,
    required DateTime cutoff,
  });
}
