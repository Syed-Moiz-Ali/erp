import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/app/shell/app_shell.dart';

import 'auth_widget_test.dart' as harness;

/// Global page-width contract: every screen shares one centered content
/// container with equal left/right free space inside the main workspace.
void main() {
  ({double left, double right}) headerBounds(WidgetTester tester) {
    final finder = find.byType(AppPageHeader).first;
    return (
      left: tester.getTopLeft(finder).dx,
      right: tester.getTopRight(finder).dx,
    );
  }

  Future<({double left, double right})> boundsFor(
    WidgetTester tester,
    String route,
  ) async {
    harness.router(tester).go(route);
    await harness.pump(tester);
    return headerBounds(tester);
  }

  for (final width in [1280.0, 1440.0, 1920.0]) {
    testWidgets('every screen shares one centered content width at '
        '${width.toInt()}', (tester) async {
      harness.viewport(tester, width);
      final h = await harness.mount(
        tester,
        AppLanguage.english,
        withServices: true,
      );
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await harness.pump(tester);
      expect(find.byType(AppShell), findsOneWidget);

      final employeesList = await boundsFor(tester, '/app/hr/employees');
      final employeeForm = await boundsFor(tester, '/app/hr/employees/new');
      final enquiriesList = await boundsFor(tester, '/app/services/enquiries');
      final newEnquiry = await boundsFor(tester, '/app/services/enquiries/new');
      final customers = await boundsFor(tester, '/app/services/customers');
      final teams = await boundsFor(tester, '/app/services/teams');

      for (final bounds in [
        employeeForm,
        enquiriesList,
        newEnquiry,
        customers,
        teams,
      ]) {
        expect(
          bounds.left,
          closeTo(employeesList.left, 0.5),
          reason: 'all screens share one left page edge at $width',
        );
        expect(
          bounds.right,
          closeTo(employeesList.right, 0.5),
          reason: 'all screens share one right page edge at $width',
        );
      }

      final contentWidth = employeesList.right - employeesList.left;
      expect(contentWidth, lessThanOrEqualTo(AppDimensions.contentMaxWidth));

      // Equal free space inside the main workspace (after the sidebar).
      final sidebar = tester.getSize(find.byType(AppSidebar)).width;
      expect(
        employeesList.left - sidebar,
        closeTo(width - employeesList.right, 1.0),
        reason: 'left and right free space must be equal at $width',
      );

      await harness.unmount(tester, h);
    });
  }

  testWidgets('content stops growing and stays centered at 1920', (
    tester,
  ) async {
    harness.viewport(tester, 1920);
    final h = await harness.mount(
      tester,
      AppLanguage.english,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await harness.pump(tester);
    final bounds = await boundsFor(tester, '/app/hr/employees');
    final sidebar = tester.getSize(find.byType(AppSidebar)).width;
    // Balanced, obvious whitespace on both sides.
    expect(bounds.left - sidebar, greaterThan(100));
    expect(1920 - bounds.right, greaterThan(100));
    expect(bounds.left - sidebar, closeTo(1920 - bounds.right, 1.0));
    await harness.unmount(tester, h);
  });
}
