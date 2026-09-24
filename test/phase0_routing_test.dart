import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/router/legacy_routes.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_details_page.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_list_page.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'support/memory_session_storage.dart';
import 'auth_widget_test.dart' as ui_test;

void main() {
  final source = DemoAuthSource();
  AuthContext account(DemoScenario role) =>
      source.accounts.firstWhere((a) => a.scenario == role).context;
  final resolver = NavigationResolver(
    createErpRegistry(DemoAuthRepository(MemorySessionStorage())),
  );
  final hr = AuthState(
    AuthStatus.authenticated,
    context: account(DemoScenario.hr),
  );

  group('LegacyRoutes.rewrite', () {
    test('maps old HR roots to canonical module-first paths', () {
      expect(LegacyRoutes.rewrite(Uri.parse('/app/dashboard')), '/app/hr');
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/employees')),
        '/app/hr/employees',
      );
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/attendance')),
        '/app/hr/attendance',
      );
      expect(LegacyRoutes.rewrite(Uri.parse('/app/leave')), '/app/hr/leave');
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/reports')),
        '/app/hr/reports',
      );
    });

    test('preserves dynamic ids', () {
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/employees/EMP-123')),
        '/app/hr/employees/EMP-123',
      );
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/leave/requests/LR-100')),
        '/app/hr/leave/requests/LR-100',
      );
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/attendance/requests/CR-9')),
        '/app/hr/attendance/requests/CR-9',
      );
    });

    test('preserves query parameters', () {
      expect(
        LegacyRoutes.rewrite(
          Uri.parse('/app/leave/all?status=approved&page=2'),
        ),
        '/app/hr/leave/all?status=approved&page=2',
      );
    });

    test('maps old HR configuration routes', () {
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/settings/shifts')),
        '/app/hr/settings/shifts',
      );
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/settings/holidays/import')),
        '/app/hr/settings/holidays/import',
      );
    });

    test('never rewrites platform routes', () {
      expect(LegacyRoutes.rewrite(Uri.parse('/app/settings')), isNull);
      expect(
        LegacyRoutes.rewrite(Uri.parse('/app/settings/notifications')),
        isNull,
      );
      expect(LegacyRoutes.rewrite(Uri.parse('/app/settings/sync')), isNull);
      expect(LegacyRoutes.rewrite(Uri.parse('/app/profile')), isNull);
      expect(LegacyRoutes.rewrite(Uri.parse('/app/notifications')), isNull);
      expect(LegacyRoutes.rewrite(Uri.parse('/app/hr/employees')), isNull);
    });
  });

  group('authRedirect legacy compatibility', () {
    String? redirect(Uri uri) => authRedirect(hr, uri, navigation: resolver);

    test('old HR routes redirect to canonical routes', () {
      expect(redirect(Uri.parse('/app/dashboard')), '/app/hr');
      expect(
        redirect(Uri.parse('/app/employees/EMP-123')),
        '/app/hr/employees/EMP-123',
      );
      expect(
        redirect(Uri.parse('/app/leave/all?status=approved&page=2')),
        '/app/hr/leave/all?status=approved&page=2',
      );
    });

    test('canonical routes need no redirect', () {
      expect(redirect(Uri.parse(AppRoutes.dashboard)), isNull);
      expect(redirect(Uri.parse(AppRoutes.employees)), isNull);
      expect(redirect(Uri.parse(AppRoutes.profile)), isNull);
    });

    test('unauthenticated legacy deep links carry canonical from target', () {
      expect(
        authRedirect(
          const AuthState(AuthStatus.unauthenticated),
          Uri.parse('/app/leave/requests/LR1'),
          navigation: resolver,
        ),
        Uri(
          path: AppRoutes.login,
          queryParameters: {'from': '/app/hr/leave/requests/LR1'},
        ).toString(),
      );
    });
  });

  testWidgets('legacy employee deep link resolves the canonical route', (
    tester,
  ) async {
    ui_test.viewport(tester, 1280);
    final h = await ui_test.mount(tester, AppLanguage.english);
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await ui_test.pump(tester);
    final r = ui_test.router(tester);
    r.go('/app/employees');
    await ui_test.pump(tester);
    expect(r.routeInformationProvider.value.uri.path, AppRoutes.employees);
    expect(find.byType(EmployeeListPage), findsOneWidget);
    await ui_test.unmount(tester, h);
  });

  testWidgets('legacy configuration deep link resolves canonical route', (
    tester,
  ) async {
    ui_test.viewport(tester, 1280);
    final h = await ui_test.mount(tester, AppLanguage.english);
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await ui_test.pump(tester);
    final r = ui_test.router(tester);
    r.go('/app/settings/shifts');
    await ui_test.pump(tester);
    expect(r.routeInformationProvider.value.uri.path, AppRoutes.shifts);
    await ui_test.unmount(tester, h);
  });

  testWidgets('employee detail route lives under the HR namespace', (
    tester,
  ) async {
    ui_test.viewport(tester, 1280);
    final h = await ui_test.mount(tester, AppLanguage.english);
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await ui_test.pump(tester);
    final r = ui_test.router(tester);
    r.go('/app/employees/does-not-exist');
    await ui_test.pump(tester);
    expect(
      r.routeInformationProvider.value.uri.path,
      '/app/hr/employees/does-not-exist',
    );
    expect(find.byType(EmployeeDetailsPage), findsOneWidget);
    await ui_test.unmount(tester, h);
  });

  test('lib sources only reference old HR paths through the legacy mapper', () {
    const oldLiterals = [
      "'/app/employees",
      "'/app/attendance",
      "'/app/leave",
      "'/app/reports",
      "'/app/dashboard",
      "'/app/settings/shifts",
      "'/app/settings/work-locations",
      "'/app/settings/attendance-policies",
      "'/app/settings/leave-types",
      "'/app/settings/leave-policies",
      "'/app/settings/holidays",
    ];
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final normalized = entity.path.replaceAll('\\', '/');
      if (normalized.endsWith('app/router/legacy_routes.dart')) continue;
      final content = entity.readAsStringSync();
      for (final literal in oldLiterals) {
        if (content.contains(literal)) {
          offenders.add('$normalized: $literal');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
