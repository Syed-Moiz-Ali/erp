import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/modules/hr/dashboard/data/local_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/module/hr_module_registration.dart';
import 'package:modular_erp/modules/hr/module/workforce_directory_adapter.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/module/services_module_registration.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/module/platform_registration.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final registry = ModuleRegistry(const <ErpModule>[]);

  group('Phase 0 module ownership', () {
    test('HR owns the /app/dashboard destination', () {
      final hr = buildHrModules(
        registry: () => registry,
        dashboardRepository: const LocalDashboardRepository(),
      );
      final dashboard = hr.modules.firstWhere(
        (module) => module.id == AppModuleIds.dashboard,
      );
      final navigation = dashboard.destinations.single.navigation;
      expect(navigation.route, AppRoutes.dashboard);
      expect(navigation.route, '/app/hr');
      expect(navigation.navigationGroup, NavigationGroup.general);
    });

    test('platform no longer registers the HR dashboard', () {
      final platform = buildPlatformModules(
        registry: () => registry,
        authRepository: _MockAuthRepository(),
      );
      expect(platform.map((module) => module.id), isNot(contains('dashboard')));
      expect(
        platform.any(
          (module) => module.destinations.any(
            (destination) =>
                destination.navigation.route == AppRoutes.dashboard,
          ),
        ),
        isFalse,
      );
    });

    test('Services registration is an empty foundation', () {
      expect(buildServicesModules(), isEmpty);
    });

    test('route and module identifiers remain compatible', () {
      expect(AppRoutes.dashboard, '/app/hr');
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
