import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/shell/app_shell.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

import 'auth_widget_test.dart' as harness;

void main() {
  for (final width in [390.0, 768.0, 1024.0, 1280.0, 1440.0, 1600.0, 1920.0]) {
    testWidgets('services dashboard fits ${width.toInt()}', (tester) async {
      harness.viewport(tester, width);
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
      expect(tester.takeException(), isNull, reason: 'width $width');
      final context = tester.element(find.byType(AppShell));
      expect(find.text(context.l10n.servicesDashboardSubtitle), findsWidgets);
      expect(
        find.text(context.l10n.servicesDashboardNeedsAttention),
        findsWidgets,
      );
      expect(
        find.text(context.l10n.servicesDashboardRecentActivity),
        findsWidgets,
      );
      await harness.unmount(tester, h);
    });
  }

  testWidgets('desktop ALL scope renders the operational dashboard', (
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
    final context = tester.element(find.byType(AppShell));
    final l = context.l10n;
    expect(find.text(l.servicesDashboardScopeAll), findsWidgets);
    expect(find.text(l.servicesDashboardKpiOpenEnquiries), findsWidgets);
    expect(find.text(l.servicesDashboardKpiWorkInProgress), findsWidgets);
    expect(find.text(l.servicesDashboardKpiCompletedToday), findsWidgets);
    expect(find.text(l.servicesDashboardMyWork), findsWidgets);
    expect(find.text(l.servicesDashboardWorkflowOverview), findsWidgets);
    expect(find.text(l.servicesDashboardQuickActions), findsWidgets);
    expect(find.text(l.servicesDashboardTodaySchedule), findsWidgets);
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });

  testWidgets('mobile ASSIGNED employee dashboard is field-friendly', (
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
    router.go('/app/services');
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    final l = context.l10n;
    expect(find.text(l.servicesDashboardMyWork), findsWidgets);
    expect(find.text(l.servicesDashboardKpiWorkInProgress), findsWidgets);
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
    router.go('/app/services');
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(
      find.text(context.l10n.servicesDashboardNeedsAttention),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });
}
