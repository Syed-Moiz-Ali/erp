import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/shell/app_shell.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/workspace/dashboard/presentation/no_dashboard_data_page.dart';

import 'auth_widget_test.dart' as harness;

void main() {
  for (final width in [390.0, 768.0, 1024.0, 1280.0, 1440.0, 1600.0, 1920.0]) {
    testWidgets('no-data dashboard fits ${width.toInt()}', (tester) async {
      harness.viewport(tester, width);
      final h = await harness.mount(
        tester,
        AppLanguage.english,
        withServices: true,
      );
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await harness.pump(tester);
      final router = harness.router(tester);
      router.go('/app/dashboard');
      await harness.pump(tester);
      expect(tester.takeException(), isNull, reason: 'width $width');
      final context = tester.element(find.byType(AppShell));
      expect(find.byType(NoDashboardDataPage), findsOneWidget);
      expect(find.text(context.l10n.dashboardNoDataSource), findsWidgets);
      await harness.unmount(tester, h);
    });
  }

  testWidgets('services content is not rendered on the live dashboard', (
    tester,
  ) async {
    harness.viewport(tester, 1440);
    final h = await harness.mount(
      tester,
      AppLanguage.english,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await harness.pump(tester);
    final router = harness.router(tester);
    router.go('/app/dashboard');
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    final l = context.l10n;
    expect(find.text(l.dashboardNoDataSource), findsWidgets);
    expect(find.text(l.servicesDashboardScopeAll), findsNothing);
    expect(find.text(l.servicesDashboardMyWork), findsNothing);
    expect(find.text(l.servicesDashboardWorkflowOverview), findsNothing);
    expect(find.text(l.universalDashboardQuickActions), findsNothing);
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });

  testWidgets('module landing redirects to the first permitted feature', (
    tester,
  ) async {
    harness.viewport(tester, 1440);
    final h = await harness.mount(
      tester,
      AppLanguage.english,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await harness.pump(tester);
    final router = harness.router(tester);
    router.go('/app/services');
    await harness.pump(tester);
    expect(
      router.routeInformationProvider.value.uri.path,
      ServicesRoutes.enquiries,
    );
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });

  testWidgets('employee sees personal operational content only', (
    tester,
  ) async {
    harness.viewport(tester, 390);
    final h = await harness.mount(
      tester,
      AppLanguage.english,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('employee@erp.demo', 'Employee@123'));
    await harness.pump(tester);
    final router = harness.router(tester);
    router.go('/app/dashboard');
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    final l = context.l10n;
    expect(find.text(l.dashboardNoDataSource), findsWidgets);
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });

  testWidgets('dashboard renders in Arabic RTL', (tester) async {
    harness.viewport(tester, 1440);
    final h = await harness.mount(
      tester,
      AppLanguage.arabic,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await harness.pump(tester);
    final router = harness.router(tester);
    router.go('/app/dashboard');
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.byType(NoDashboardDataPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });
}
