import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/module/hr_module_registration.dart';
import 'package:modular_erp/modules/hr/module/workforce_directory_adapter.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/module/services_module_registration.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/module/platform_registration.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final registry = ModuleRegistry(const <ErpModule>[]);

  group('Universal dashboard ownership', () {
    test('platform owns the single canonical /app/dashboard destination', () {
      final platform = buildPlatformModules(
        registry: () => registry,
        authRepository: _MockAuthRepository(),
        dashboardCoordinator: const UniversalDashboardCoordinator([]),
      );
      final dashboard = platform.firstWhere(
        (module) => module.id == AppModuleIds.dashboard,
      );
      final navigation = dashboard.destinations.single.navigation;
      expect(navigation.route, AppRoutes.dashboard);
      expect(navigation.route, '/app/dashboard');
      expect(navigation.navigationGroup, NavigationGroup.general);
    });

    test('HR no longer registers a dashboard destination', () {
      final hr = buildHrModules(registry: () => registry);
      expect(
        hr.modules.map((module) => module.id),
        isNot(contains(AppModuleIds.dashboard)),
      );
      expect(
        hr.modules
            .expand((module) => module.destinations)
            .any((destination) => destination.navigation.route == '/app/hr'),
        isFalse,
      );
    });

    test('Services registration is an empty foundation', () {
      expect(buildServicesModules(), isEmpty);
    });

    test('route and module identifiers remain compatible', () {
      expect(AppRoutes.dashboard, '/app/dashboard');
      expect(AppRoutes.services, '/app/services');
      expect(AppRoutes.employees, '/app/hr/employees');
      expect(AppRoutes.attendance, '/app/hr/attendance');
      expect(AppRoutes.leave, '/app/hr/leave');
      expect(AppRoutes.reports, '/app/hr/reports');
      expect(AppRoutes.shifts, '/app/hr/settings/shifts');
      expect(AppRoutes.holidays, '/app/hr/settings/holidays');
      expect(AppRoutes.profile, '/app/profile');
      expect(AppRoutes.settings, '/app/settings');
      expect(AppModuleIds.dashboard, 'dashboard');
      expect(AppModuleIds.employees, 'employees');
      expect(AppModuleIds.attendance, 'attendance');
      expect(AppModuleIds.leave, 'leave');
      expect(AppModuleIds.services, 'services');
      expect(AppModuleIds.reports, 'reports');
      expect(AppModuleIds.settings, 'settings');
    });

    test('HR adapter satisfies the Services workforce contract', () {
      const WorkforceDirectory Function(AuthRepository, EmployeeRepository)
      factory = HrWorkforceDirectory.new;
      expect(factory, isNotNull);
    });
  });
}
