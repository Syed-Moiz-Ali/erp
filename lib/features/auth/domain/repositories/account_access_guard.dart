import '../entities/auth_context.dart';

abstract interface class AccountAccessGuard {
  Future<bool> enabled(String userId);
  Future<UserAccount?> effectiveUser(String userId);
  Stream<void> get changes;
}
