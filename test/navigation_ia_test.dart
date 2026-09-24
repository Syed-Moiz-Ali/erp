import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'support/memory_session_storage.dart';
import 'employee_test.dart' show employeeContext;

void main() {
  NavigationResolver resolver() => NavigationResolver(
    createErpRegistry(DemoAuthRepository(MemorySessionStorage())),
  );

  List<String> visible(NavigationResolver r, AuthContext ctx) => r
      .resolve(
        ctx.company,
        ctx.user.permissions,
        employee: ctx.employeeReference,
      )
      .desktop
      .map((d) => d.id)
      .toList();

  test('configuration pages are secondary, not main navigation', () {
    final hr = employeeContext(DemoScenario.hr);
    final items = visible(resolver(), hr);
    expect(items, contains('settings'));
    expect(items, isNot(contains('shifts')));
    expect(items, isNot(contains('work-locations')));
    expect(items, isNot(contains('attendance-policies')));
  });

  test('attendance is a single primary module with internal destinations', () {
    final hr = employeeContext(DemoScenario.hr);
    final items = visible(resolver(), hr);
    expect(items.where((id) => id.startsWith('attendance')).toList(), [
      'attendance',
    ]);
    expect(items, isNot(contains('attendance-history')));
    expect(items, isNot(contains('attendance-all')));
    expect(items, isNot(contains('attendance-requests')));
  });

  test('employee sees a minimal navigation', () {
    final employee = employeeContext(DemoScenario.employee);
    final items = visible(resolver(), employee);
    expect(items, ['dashboard', 'attendance', 'profile']);
  });

  test('settings items follow configuration permissions independently', () {
    final hr = employeeContext(DemoScenario.hr);
    final onlyShifts = hr.copyWith(
      user: hr.user.copyWith(
        permissions: PermissionSet([
          AppPermission.shiftView,
          AppPermission.attendanceViewAll,
        ]),
      ),
    );
    final resolverInstance = resolver();
    // Shifts route remains authorized while locations/policies are not.
    expect(
      resolverInstance.routeAccess(AppRoutes.shifts, onlyShifts),
      RouteAccess.allowed,
    );
    expect(
      resolverInstance.routeAccess(AppRoutes.workLocations, onlyShifts),
      RouteAccess.unauthorized,
    );
    expect(
      resolverInstance.routeAccess(AppRoutes.attendancePolicies, onlyShifts),
      RouteAccess.unauthorized,
    );
  });

  test('primary module stays selected across nested configuration routes', () {
    final hr = employeeContext(DemoScenario.hr);
    final registry = createErpRegistry(
      DemoAuthRepository(MemorySessionStorage()),
    );
    expect(registry.ownerOf('/app/settings')!.id, 'settings');
    expect(registry.ownerOf('${AppRoutes.shifts}/shift-1')!.id, 'shifts');
    final nav = NavigationResolver(
      registry,
    ).resolve(hr.company, hr.user.permissions, employee: hr.employeeReference);
    // Shifts is owned by the settings module family for active-state purposes;
    // the most specific visible owner wins over the broader `/app/hr` root.
    final owners = nav.desktop.where((m) => m.owns(AppRoutes.shifts)).toList()
      ..sort((a, b) => b.route.length.compareTo(a.route.length));
    expect(owners.first.id, 'settings');
  });

  test('attendance primary is gated by any attendance capability', () {
    final hr = employeeContext(DemoScenario.hr);
    final capabilities = const UserCapabilityResolver().forAuthContext(hr);
    expect(
      capabilities.hasAny([
        UserCapability.selfAttendance,
        UserCapability.teamAttendance,
        UserCapability.companyAttendance,
      ]),
      isTrue,
    );
  });

  test('role templates no longer grant self service to platform admins', () {
    expect(
      demoScenarioGrants(
        DemoScenario.platformAdmin,
      ).contains(AppPermission.attendanceViewSelf),
      isFalse,
    );
    expect(
      demoScenarioGrants(
        DemoScenario.companyAdmin,
      ).contains(AppPermission.attendanceViewSelf),
      isFalse,
    );
  });
}
