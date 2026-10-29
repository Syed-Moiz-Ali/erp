import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/access/presentation/user_access_detail_page.dart';
import 'package:modular_erp/platform/access/presentation/users_access_page.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'auth_widget_test.dart' as ui_test;
import 'support/fake_access_repository.dart';

void main() {
  testWidgets(
    'Users & Access list and editor render on desktop and Arabic RTL',
    (tester) async {
      ui_test.viewport(tester, 1440);
      final repository = FakeAccessRepository(
        grants: {
          'demo-employee': [
            for (final id in [1, 2, 3])
              UserPermissionGrant(
                id: '$id',
                companyId: 'demo-company',
                userId: 'demo-employee',
                permissionKey: '__orphan__$id',
                scope: PermissionScope.none,
                grantedByUserId: 'admin',
                grantedAt: DateTime.utc(2026, 10, 28),
                updatedAt: DateTime.utc(2026, 10, 28),
                syncStatus: 'synced',
                isActive: false,
                isOrphan: true,
                orphanPermissionId: id,
              ),
          ],
        },
        users: const [
          AccessUserListItem(
            userId: 'demo-admin',
            displayName: 'Super admin',
            email: 'admin@erp.demo',
            hasLogin: true,
            accountStatus: 'active',
          ),
          AccessUserListItem(
            userId: 'demo-employee',
            displayName: 'Employee',
            email: 'employee@erp.demo',
            hasLogin: true,
            accountStatus: 'active',
            employeeId: 'employee-employee',
            employeeCode: 'EMP-EMPLOYEE',
            isEmployeeActive: true,
          ),
        ],
      );
      addTearDown(repository.dispose);
      final h = await ui_test.mount(
        tester,
        AppLanguage.english,
        registryFactory: (authRepository) => createErpRegistry(
          authRepository,
          accessRepository: repository,
          accessCatalog: erpAccessCatalog,
          accessAuthority: const GrantAuthorityResolver(),
        ),
      );
      h.auth.add(const AuthLoginRequested('admin@erp.demo', 'Admin@123'));
      await ui_test.pump(tester);
      final r = ui_test.router(tester);

      r.go(AppRoutes.access);
      await ui_test.pump(tester);
      expect(find.byType(UsersAccessPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      r.go(AppRoutes.accessUser('demo-admin'));
      await ui_test.pump(tester);
      expect(find.byType(UserAccessDetailPage), findsOneWidget);
      // Admin has no employee link, so the linking guidance is shown.
      expect(find.text('No linked employee'), findsWidgets);
      expect(tester.takeException(), isNull);

      // A linked demo user enables personal permissions.
      r.go(AppRoutes.accessUser('demo-employee'));
      await ui_test.pump(tester);
      expect(find.text('Linked employee'), findsWidgets);
      expect(find.text('No linked employee'), findsNothing);
      expect(find.text('Orphan grant (permission #1)'), findsOneWidget);
      expect(find.text('Orphan grant (permission #2)'), findsOneWidget);
      expect(find.text('Orphan grant (permission #3)'), findsOneWidget);
      expect(find.text('Revoke'), findsNWidgets(3));
      expect(tester.takeException(), isNull);

      // A user with no grants opens directly from the employee access entry.
      r.go(AppRoutes.accessUser('fresh-user'));
      await ui_test.pump(tester);
      expect(find.text('No permissions assigned'), findsOneWidget);
      expect(find.text('Add permissions'), findsWidgets);
      expect(tester.takeException(), isNull);

      // HR is enabled for the demo company (feature flags employees/attendance/
      // leave/reports/settings), so at least one module shows as enabled.
      r.go(AppRoutes.modules);
      await ui_test.pump(tester);
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      expect(texts.contains('Enabled'), isTrue, reason: texts.join(' | '));
      expect(tester.takeException(), isNull);

      // Arabic RTL on a compact viewport must not overflow.
      r.go(AppRoutes.access);
      tester.view.physicalSize = const Size(390, 900);
      final saved = h.locale.changeLanguage(AppLanguage.arabic);
      await ui_test.pump(tester);
      await saved;
      expect(tester.takeException(), isNull);

      await ui_test.unmount(tester, h);
    },
  );
}
