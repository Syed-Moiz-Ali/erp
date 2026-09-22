import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/features/employees/presentation/pages/employee_details_page.dart';
import 'package:modular_erp/features/employees/presentation/pages/employee_list_page.dart';
import 'package:modular_erp/features/employees/presentation/bloc/employee_list_bloc.dart';
import 'auth_widget_test.dart' as h;
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
  setUpAll(() async {
    for (final f in {
      'Manrope': 'assets/fonts/Manrope-SemiBold.ttf',
      'IBMPlexSansArabic': 'assets/fonts/IBMPlexSansArabic-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(f.key)..addFont(rootBundle.load(f.value))).load();
    }
  });

  group('active module resolver', () {
    test('nested routes resolve to their owning destination', () {
      final registry = createErpRegistry(
        DemoAuthRepository(MemorySessionStorage()),
      );
      String? owner(String path) => registry.ownerOf(path)?.id;
      expect(owner(AppRoutes.employees), 'employees');
      expect(owner('${AppRoutes.employees}/employee-employee'), 'employees');
      expect(
        owner('${AppRoutes.employees}/employee-employee/edit'),
        'employees',
      );
      expect(owner(AppRoutes.attendanceHistory), 'attendance-history');
      expect(
        owner('${AppRoutes.attendanceHistory}/day-1'),
        'attendance-history',
      );
      expect(owner(AppRoutes.reports), 'reports');
      expect(owner('${AppRoutes.shifts}/shift-1/edit'), 'shifts');
      expect(owner('${AppRoutes.workLocations}/loc-1'), 'work-locations');
    });

    test('prefix lookalikes are not treated as the same module', () {
      final registry = createErpRegistry(
        DemoAuthRepository(MemorySessionStorage()),
      );
      expect(registry.ownerOf('/app/employee'), isNull);
      expect(registry.ownerOf('/app/employees-extra'), isNull);
    });
  });

  testWidgets('employee detail route updates the location and renders detail', (
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
    final first = list.state.data!.employees.first;
    // The list wires this same detail route on row selection; navigate it.
    router.push(AppRoutes.employeeDetails(first.id));
    await settle(t);
    expect(find.byType(EmployeeDetailsPage), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.employeeDetails(first.id),
    );

    // Back returns to the list for the same reason the browser back does.
    router.pop();
    await settle(t);
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.employees);
    expect(find.byType(EmployeeListPage), findsOneWidget);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });

  testWidgets('reselecting the module returns to its canonical root', (
    t,
  ) async {
    h.viewport(t, 1440);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    final router = h.router(t);
    router.go(AppRoutes.employees);
    await settle(t);
    router.push(AppRoutes.employeeDetails('employee-employee'));
    await settle(t);
    expect(find.byType(EmployeeDetailsPage), findsOneWidget);

    Finder item(String id) =>
        find.byWidgetPredicate((w) => w is AppSidebarItem && w.item.id == id);
    await t.tap(item('employees'));
    await settle(t);
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.employees);
    expect(find.byType(EmployeeListPage), findsOneWidget);
    expect(find.byType(EmployeeDetailsPage), findsNothing);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });

  testWidgets('direct deep link loads detail without opening the list', (
    t,
  ) async {
    h.viewport(t, 1440);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    final router = h.router(t);
    // Equivalent to a browser refresh on a copied URL.
    router.go(AppRoutes.employeeDetails('employee-employee'));
    await settle(t);
    expect(find.byType(EmployeeDetailsPage), findsOneWidget);
    expect(find.byType(EmployeeListPage), findsNothing);
    expect(find.text('Noor Ali'), findsWidgets);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });

  testWidgets('unauthorized deep link is blocked', (t) async {
    h.viewport(t, 1440);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('employee@erp.demo', 'Employee@123'));
    await h.pump(t);
    h.router(t).go(AppRoutes.employeeDetails('employee-hr'));
    await settle(t);
    expect(find.byType(UnauthorizedPage), findsOneWidget);
    expect(find.byType(EmployeeDetailsPage), findsNothing);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });

  testWidgets('Arabic keeps the nested route and mirrors direction', (t) async {
    h.viewport(t, 1024);
    final app = await h.mount(t, AppLanguage.arabic);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    final router = h.router(t);
    router.go(AppRoutes.employeeDetails('employee-employee'));
    await settle(t);
    expect(find.byType(EmployeeDetailsPage), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.employeeDetails('employee-employee'),
    );
    expect(
      Directionality.of(t.element(find.byType(EmployeeDetailsPage))),
      TextDirection.rtl,
    );
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });
}
