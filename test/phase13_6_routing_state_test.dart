import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_details_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_list_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_details_page.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_list_page.dart';
import 'package:modular_erp/shared/navigation/app_navigation.dart';
import 'auth_widget_test.dart' as h;
import 'employee_test.dart' show employeeContext;
import 'support/memory_session_storage.dart';

Future<void> settle(WidgetTester t) async {
  for (var n = 0; n < 6; n++) {
    await h.pump(t);
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
}

void main() {
  final detail = AppRoutes.employeeDetails('employee-employee');

  test(
    'module root resolver returns the canonical parent for nested paths',
    () {
      final registry = createErpRegistry(
        DemoAuthRepository(MemorySessionStorage()),
      );
      expect(
        moduleRootForPath(AppRoutes.employees, registry),
        AppRoutes.employees,
      );
      expect(moduleRootForPath(detail, registry), AppRoutes.employees);
      expect(
        moduleRootForPath(AppRoutes.employeeEdit('e1'), registry),
        AppRoutes.employees,
      );
      expect(
        moduleRootForPath('${AppRoutes.attendanceHistory}/day-1', registry),
        AppRoutes.attendanceHistory,
      );
      expect(moduleRootForPath('/totally/unknown', registry), isNull);
    },
  );

  group('auth bootstrap deep link', () {
    late NavigationResolver navigation;
    setUp(() {
      navigation = NavigationResolver(
        createErpRegistry(DemoAuthRepository(MemorySessionStorage())),
      );
    });

    test('holds the intended location while bootstrapping', () {
      final redirect = authRedirect(
        const AuthState(AuthStatus.bootstrapping),
        Uri.parse(detail),
        navigation: navigation,
      );
      expect(redirect, isNotNull);
      final uri = Uri.parse(redirect!);
      expect(uri.path, AppRoutes.bootstrap);
      expect(uri.queryParameters['from'], detail);
    });

    test('preserves the safe return location for unauthenticated users', () {
      expect(
        authRedirect(
          const AuthState(AuthStatus.unauthenticated),
          Uri.parse(detail),
          navigation: navigation,
        ),
        '/login?from=${Uri.encodeComponent(detail)}',
      );
    });

    test('rejects unsafe external return locations', () {
      expect(
        authRedirect(
          AuthState(
            AuthStatus.authenticated,
            context: employeeContext(AppRole.hr),
          ),
          Uri.parse('/login?from=https%3A%2F%2Fevil.example'),
          navigation: navigation,
        ),
        AppRoutes.dashboard,
      );
    });

    test('authorized session keeps the deep link', () {
      expect(
        authRedirect(
          AuthState(
            AuthStatus.authenticated,
            context: employeeContext(AppRole.hr),
          ),
          Uri.parse(detail),
          navigation: navigation,
        ),
        isNull,
      );
    });

    test('employee self-scope may reach the route; object scope blocks data', () {
      // Employees allow self-viewing routes; record-level scope is enforced by
      // the page/repository (see the widget test that renders UnauthorizedPage
      // for a different employee id).
      expect(
        authRedirect(
          AuthState(
            AuthStatus.authenticated,
            context: employeeContext(AppRole.employee),
          ),
          Uri.parse(detail),
          navigation: navigation,
        ),
        isNull,
      );
    });

    test('disabled module is unavailable', () {
      final hr = employeeContext(AppRole.hr);
      final redirect = authRedirect(
        AuthState(
          AuthStatus.authenticated,
          context: hr.copyWith(
            company: hr.company.copyWith(enabledModules: {'dashboard'}),
          ),
        ),
        Uri.parse(detail),
        navigation: navigation,
      );
      expect(Uri.parse(redirect!).path, AppRoutes.unavailable);
    });
  });

  testWidgets('changing the route id loads the new entity, not stale state', (
    t,
  ) async {
    h.viewport(t, 1440);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    final router = h.router(t);
    router.go(AppRoutes.employees);
    await settle(t);
    final list = t
        .element(find.byType(EmployeeListPage))
        .read<EmployeeListBloc>();
    final first = list.state.data!.employees[0];
    final second = list.state.data!.employees[1];

    router.go(AppRoutes.employeeDetails(first.id));
    await settle(t);
    expect(
      t
          .element(find.byType(EmployeeDetailsPage))
          .read<EmployeeDetailsBloc>()
          .id,
      first.id,
    );

    // Address-bar style change to another id must rebuild the detail Bloc.
    router.go(AppRoutes.employeeDetails(second.id));
    await settle(t);
    expect(
      t
          .element(find.byType(EmployeeDetailsPage))
          .read<EmployeeDetailsBloc>()
          .id,
      second.id,
    );
    expect(find.text(second.displayName), findsWidgets);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });
}
