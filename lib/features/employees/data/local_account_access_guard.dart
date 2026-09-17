import 'dart:convert';
import '../../../core/security/app_permission.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../../core/database/app_database.dart';
import '../../auth/domain/repositories/account_access_guard.dart';

class LocalAccountAccessGuard implements AccountAccessGuard {
  LocalAccountAccessGuard(this.db);
  final AppDatabase db;
  @override
  Stream<void> get changes => db
      .customSelect(
        'SELECT id,status FROM workforce_accounts',
        readsFrom: {db.workforceAccounts, db.workforceEmployees},
      )
      .watch()
      .map((_) {});
  @override
  Future<bool> enabled(String userId) async {
    final account = await (db.select(
      db.workforceAccounts,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    if (account == null) return false;
    final employee = await (db.select(
      db.workforceEmployees,
    )..where((t) => t.linkedUserId.equals(userId))).getSingleOrNull();
    return account.status == 'active' &&
        !account.credentialPending &&
        (employee == null ||
            employee.status == 'active' && employee.loginEnabled);
  }

  @override
  Future<UserAccount?> effectiveUser(String userId) async {
    if (!await enabled(userId)) return null;
    final a = await (db.select(
      db.workforceAccounts,
    )..where((t) => t.id.equals(userId))).getSingle();
    return UserAccount(
      id: a.id,
      displayName: a.displayName,
      email: a.email,
      phone: a.phone,
      companyId: a.companyId,
      role: AppRole.values.byName(a.role),
      permissions: PermissionSet(
        (jsonDecode(a.grants) as List).map(
          (p) => AppPermission.values.byName(p as String),
        ),
      ),
      status: AccountStatus.values.byName(a.status),
    );
  }
}
