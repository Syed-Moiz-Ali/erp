import 'package:modular_erp/modules/hr/attendance/presentation/widgets/attendance_dashboard_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/shell/app_shell.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/platform/dashboard/data/demo_dashboard_source.dart';
import 'package:modular_erp/platform/dashboard/presentation/dashboard_page.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'auth_widget_test.dart' as ui_test;
import 'dashboard_test.dart' show ControlledDashboardRepository;

void main() {
  setUpAll(() async {
    for (final font in {
      'Manrope': 'assets/fonts/Manrope-SemiBold.ttf',
      'IBMPlexSansArabic': 'assets/fonts/IBMPlexSansArabic-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });
  const accounts = {
    'employee': 'Employee@123',
    'manager': 'Manager@123',
    'hr': 'Hr@123',
    'admin': 'Admin@123',
    'company': 'Company@123',
  };
  for (final language in AppLanguage.values) {
    for (final account in accounts.entries) {
      for (final width in [
        360.0,
        390.0,
        430.0,
        600.0,
        768.0,
        900.0,
        1024.0,
        1280.0,
        1440.0,
        1920.0,
      ]) {
        testWidgets('${account.key} ${language.name} dashboard at $width', (
          tester,
        ) async {
          ui_test.viewport(tester, width);
          final h = await ui_test.mount(tester, language);
          h.auth.add(
            AuthLoginRequested('${account.key}@erp.demo', account.value),
          );
          await ui_test.pump(tester);
          expect(find.byType(DashboardPage), findsOneWidget);
          expect(find.byType(AppShell), findsOneWidget);
          expect(
            ui_test.router(tester).routeInformationProvider.value.uri.path,
            AppRoutes.dashboard,
          );
          expect(find.byType(AppDashboardSkeleton), findsNothing);
          expect(
            Directionality.of(tester.element(find.byType(DashboardView))),
            language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          expect(
            find.byKey(const ValueKey('metric-employees')),
            account.key == 'hr' ||
                    account.key == 'admin' ||
                    account.key == 'company'
                ? findsOneWidget
                : findsNothing,
          );
          expect(
            find.byKey(const ValueKey('metric-teamSize')),
            account.key == 'manager' ? findsOneWidget : findsNothing,
          );
          expect(
            find.byKey(const ValueKey('metric-users')),
            width >= 600 && (account.key == 'admin' || account.key == 'company')
                ? findsOneWidget
                : findsNothing,
          );
          expect(find.byKey(const ValueKey('metric-hours')), findsNothing);
          expect(
            find.byKey(const ValueKey('dashboard-action-employees')),
            account.key == 'employee' ? findsNothing : findsOneWidget,
          );
          final context = tester.element(find.byType(DashboardView));
          expect(
            find.text(context.l10n.dashboardDemo('Sep 17, 2026')),
            language == AppLanguage.english && account.key != 'employee'
                ? findsOneWidget
                : findsNothing,
          );
          expect(tester.takeException(), isNull);
          if (width == 390 || width == 1280) {
            await ui_test.screenshot(
              tester,
              h.key,
              'phase3_${account.key}_${language.name}_${width.toInt()}',
            );
          }
          final last = account.key == 'employee'
              ? find.byKey(const ValueKey('dashboard-action-attendance'))
              : find.byType(AppActivityItem).last;
          await tester.ensureVisible(last);
          await ui_test.pump(tester);
          expect(tester.takeException(), isNull);
          if (width == 390 || width == 1280) {
            await ui_test.screenshot(
              tester,
              h.key,
              'phase3_${account.key}_${language.name}_${width.toInt()}_lower',
            );
          }
          await ui_test.unmount(tester, h);
        });
      }
    }
    testWidgets(
      '${language.name} skeleton, error retry, empty and refresh keep data',
      (tester) async {
        ui_test.viewport(tester, 390);
        final repo = ControlledDashboardRepository();
        final h = await ui_test.mount(
          tester,
          language,
          registryFactory: (auth) =>
              createErpRegistry(auth, dashboardRepository: repo),
        );
        h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
        await ui_test.pump(tester);
        expect(find.byType(AppDashboardSkeleton), findsOneWidget);
        repo.requests[0].complete(
          const Failed(
            Failure(code: 'private server response', retryable: true),
          ),
        );
        await ui_test.pump(tester);
        final context = tester.element(find.byType(DashboardView));
        expect(find.byType(AppErrorState), findsOneWidget);
        expect(find.text('private server response'), findsNothing);
        await tester.ensureVisible(find.text(context.l10n.retry));
        await tester.tap(find.text(context.l10n.retry));
        await ui_test.pump(tester);
        repo.requests[1].complete(
          Success(
            DashboardSummary(
              scope: DashboardScope.none,
              asOf: DemoDashboardSource.asOf,
              isDemo: true,
            ),
          ),
        );
        await ui_test.pump(tester);
        expect(find.text(context.l10n.dashboardEmptyTitle), findsOneWidget);
        expect(find.byType(AppMetricCard), findsNothing);
        expect(
          find.byKey(const ValueKey('dashboard-action-employees')),
          findsOneWidget,
        );
        await tester.ensureVisible(
          find.byTooltip(context.l10n.dashboardRefresh),
        );
        await tester.tap(find.byTooltip(context.l10n.dashboardRefresh));
        await ui_test.pump(tester);
        expect(find.text(context.l10n.dashboardEmptyTitle), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        final snapshot = const DemoDashboardSource().read(
          DashboardScope.company,
          h.auth.state.context!.user.displayName,
        );
        repo.requests[2].complete(Success(snapshot));
        await ui_test.pump(tester);
        expect(find.byType(AppMetricCard), findsNWidgets(4));
        await tester.tap(find.byTooltip(context.l10n.dashboardRefresh));
        await ui_test.pump(tester);
        expect(find.byType(AppMetricCard), findsNWidgets(4));
        repo.requests[3].complete(
          const Failed(Failure(code: 'offline', kind: FailureKind.offline)),
        );
        await ui_test.pump(tester);
        expect(find.text(context.l10n.dashboardRefreshError), findsOneWidget);
        expect(find.byType(AppMetricCard), findsNWidgets(4));
        expect(tester.takeException(), isNull);
        await ui_test.unmount(tester, h);
      },
    );
    for (final textAccount in accounts.entries) {
      testWidgets(
        '${textAccount.key} ${language.name} enlarged text, live localization and accessible quick navigation',
        (tester) async {
          ui_test.viewport(tester, 360);
          tester.platformDispatcher.textScaleFactorTestValue = 1.5;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final h = await ui_test.mount(tester, language);
          h.auth.add(
            AuthLoginRequested(
              '${textAccount.key}@erp.demo',
              textAccount.value,
            ),
          );
          await ui_test.pump(tester);
          expect(tester.takeException(), isNull);
          final selfCapable = const {
            'employee',
            'manager',
            'hr',
          }.contains(textAccount.key);
          final action = find.byKey(
            const ValueKey('dashboard-action-attendance'),
          );
          if (selfCapable) {
            await Scrollable.ensureVisible(
              tester.element(action),
              alignment: 0.5,
            );
            await ui_test.pump(tester);
            expect(tester.takeException(), isNull);
            await tester.tap(action);
            await ui_test.pump(tester);
            expect(
              ui_test.router(tester).routeInformationProvider.value.uri.path,
              AppRoutes.attendance,
            );
          }
          ui_test.router(tester).go(AppRoutes.dashboard);
          await ui_test.pump(tester);
          final before = ui_test.router(tester);
          h.locale.changeLanguage(
            language == AppLanguage.english
                ? AppLanguage.arabic
                : AppLanguage.english,
          );
          await ui_test.pump(tester);
          expect(identical(before, ui_test.router(tester)), isTrue);
          expect(find.byType(DashboardView), findsOneWidget);
          expect(tester.takeException(), isNull);
          await ui_test.unmount(tester, h);
        },
      );
    }
  }

  testWidgets(
    'mobile pull refresh retains content and metric semantics describe values',
    (tester) async {
      ui_test.viewport(tester, 390);
      final semantics = tester.ensureSemantics();
      try {
        final repo = ControlledDashboardRepository();
        final h = await ui_test.mount(
          tester,
          AppLanguage.english,
          registryFactory: (auth) =>
              createErpRegistry(auth, dashboardRepository: repo),
        );
        h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
        await ui_test.pump(tester);
        final snapshot = const DemoDashboardSource().read(
          DashboardScope.company,
          h.auth.state.context!.user.displayName,
        );
        repo.requests[0].complete(Success(snapshot));
        await ui_test.pump(tester);
        final metric = find.byKey(const ValueKey('metric-present'));
        expect(
          tester.getSemantics(metric).label,
          'Present, 73, Includes late arrivals',
        );
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, 400),
        );
        await ui_test.pump(tester);
        expect(repo.refreshFlags, [false, true]);
        expect(find.byType(AppMetricCard), findsNWidgets(4));
        repo.requests[1].complete(Success(snapshot));
        await ui_test.pump(tester);
        expect(find.byType(AppDashboardSkeleton), findsNothing);
        expect(tester.takeException(), isNull);
        await ui_test.unmount(tester, h);
      } finally {
        semantics.dispose();
      }
    },
  );
  testWidgets(
    'context permission revocation replaces company data with self data',
    (tester) async {
      ui_test.viewport(tester, 1280);
      final h = await ui_test.mount(tester, AppLanguage.english);
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await ui_test.pump(tester);
      expect(find.byKey(const ValueKey('metric-employees')), findsOneWidget);
      final previous = h.auth.state.context!;
      // Context changes travel through the existing auth session stream.
      final updated = previous.copyWith(
        user: previous.user.copyWith(
          permissions: PermissionSet([AppPermission.attendanceViewSelf]),
        ),
      );
      h.auth.add(AuthSessionUpdated(updated));
      await ui_test.pump(tester);
      expect(find.byKey(const ValueKey('metric-employees')), findsNothing);
      expect(find.byKey(const ValueKey('metric-hours')), findsNothing);
      expect(find.byType(AttendanceDashboardPreview), findsOneWidget);
      expect(tester.takeException(), isNull);
      await ui_test.unmount(tester, h);
    },
  );
}
