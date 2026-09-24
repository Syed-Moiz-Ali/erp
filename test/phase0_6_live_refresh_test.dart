import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/platform/access/application/user_grants_controller.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'auth_widget_test.dart' as ui_test;

class _FakeGrants implements UserGrantsController {
  _FakeGrants(this._current);
  PermissionSet _current;
  final _controller = StreamController<PermissionSet>.broadcast();
  @override
  Future<PermissionSet> permissionsFor(AuthContext context) async => _current;
  @override
  Stream<PermissionSet> watch(AuthContext context) => _controller.stream;
  void emit(PermissionSet permissions) {
    _current = permissions;
    _controller.add(permissions);
  }

  Future<void> close() => _controller.close();
}

Finder _navItem(String id) =>
    find.byWidgetPredicate((w) => w is AppSidebarItem && w.item.id == id);

void main() {
  testWidgets('live grant removal updates navigation and redirects the route', (
    tester,
  ) async {
    ui_test.viewport(tester, 1440);
    final grants = _FakeGrants(demoScenarioGrants(DemoScenario.hr));
    addTearDown(grants.close);
    final h = await ui_test.mount(tester, AppLanguage.english, grants: grants);
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await ui_test.pump(tester);
    final r = ui_test.router(tester);

    r.go(AppRoutes.reports);
    await ui_test.pump(tester);
    expect(r.routeInformationProvider.value.uri.path, AppRoutes.reports);
    expect(_navItem('reports'), findsOneWidget);

    // Remove organizational/report grants while the session is active.
    grants.emit(
      PermissionSet({
        AppPermission.attendanceViewSelf,
        AppPermission.attendancePunchIn,
        AppPermission.attendancePunchOut,
        AppPermission.attendanceBreak,
        AppPermission.leaveViewSelf,
        AppPermission.leaveRequest,
      }),
    );
    await ui_test.pump(tester);
    await ui_test.pump(tester);

    // Navigation removes Reports and the current route is no longer accessible.
    expect(_navItem('reports'), findsNothing);
    expect(r.routeInformationProvider.value.uri.path, isNot(AppRoutes.reports));
    expect(tester.takeException(), isNull);

    // Granting it back restores navigation live (no re-login).
    grants.emit(demoScenarioGrants(DemoScenario.hr));
    await ui_test.pump(tester);
    expect(_navItem('reports'), findsOneWidget);

    await ui_test.unmount(tester, h);
  });
}
