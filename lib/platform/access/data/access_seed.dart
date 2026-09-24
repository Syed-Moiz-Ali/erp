import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/policies/account_role_templates.dart';

/// Demo access seed: converts the legacy role templates into **explicit
/// permission grants**. The persona names are test fixtures; runtime
/// authorization evaluates the resulting permissions, never the role label.
Future<void> seedAccessDemoData(
  AppDatabase db,
  PermissionCatalog catalog,
  DemoAuthSource source,
  AppClock clock, {
  Uuid uuid = const Uuid(),
}) async {
  final now = clock.now();
  for (final account in source.accounts) {
    final companyId = account.context.company.id;
    final userId = account.context.user.id;
    final permissions = permissionsForRole(account.context.user.role);
    final grants = catalog.grantsFor(permissions.values);
    for (final grant in grants) {
      await db
          .into(db.userPermissionGrants)
          .insert(
            UserPermissionGrantsCompanion.insert(
              id: uuid.v4(),
              companyId: companyId,
              userId: userId,
              permissionKey: grant.key,
              scopeKey: grant.scope.name,
              grantedByUserId: userId,
              grantedAt: now,
              updatedAt: now,
              syncStatus: 'synced',
              isActive: const Value(true),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }
}
