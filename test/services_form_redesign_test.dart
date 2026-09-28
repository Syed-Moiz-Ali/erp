import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/app/shell/app_shell.dart';

import 'auth_widget_test.dart' as harness;

const _representativeRoutes = <String>[
  '/app/services/settings/priorities/new',
  '/app/services/settings/priorities/demo-pr-high/edit',
  '/app/services/customers/new',
  '/app/services/sites/demo-site-abc-1/edit',
  '/app/services/enquiries/new',
  '/app/services/job-assignments/demo-ja-1/edit',
  '/app/services/inspections/demo-ins-1/edit',
  '/app/services/material-requests/new',
  '/app/services/work-executions/demo-we-1/edit',
];

Future<harness.Harness> _login(
  WidgetTester tester,
  AppLanguage language,
) async {
  final h = await harness.mount(tester, language, withServices: true);
  h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
  await harness.pump(tester);
  expect(find.byType(AppShell), findsOneWidget);
  return h;
}

void main() {
  for (final width in [390.0, 768.0, 1024.0, 1280.0, 1440.0, 1600.0, 1920.0]) {
    testWidgets('services create/edit forms fit ${width.toInt()}', (
      tester,
    ) async {
      harness.viewport(tester, width);
      final h = await _login(tester, AppLanguage.english);
      final router = harness.router(tester);
      for (final route in _representativeRoutes) {
        router.go(route);
        await harness.pump(tester);
        expect(
          tester.takeException(),
          isNull,
          reason: 'route $route at width $width',
        );
      }
      await harness.unmount(tester, h);
    });
  }

  testWidgets('priority form uses mode-aware title and one visual language', (
    tester,
  ) async {
    harness.viewport(tester, 1280);
    final h = await _login(tester, AppLanguage.english);
    final context = tester.element(find.byType(AppShell));
    final l = context.l10n;
    final router = harness.router(tester);

    router.go('/app/services/settings/priorities/new');
    await harness.pump(tester);
    final form = find.byType(AppFormPage);
    expect(
      find.descendant(
        of: form,
        matching: find.text(
          l.servicesMasterAddName(l.servicesPrioritySingular),
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: form, matching: find.text(l.servicesPrioritiesTitle)),
      findsNothing,
    );
    expect(
      find.descendant(
        of: form,
        matching: find.text(l.servicesMasterBasicInformation),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: form,
        matching: find.text(l.servicesMasterOrderingBehavior),
      ),
      findsOneWidget,
    );
    expect(find.byType(AppBooleanSettingRow), findsOneWidget);
    expect(find.textContaining(l.servicesMasterCode), findsWidgets);
    expect(find.text(l.servicesMasterCodeHelper), findsOneWidget);

    router.go('/app/services/settings/priorities/demo-pr-high/edit');
    await harness.pump(tester);
    expect(
      find.descendant(
        of: find.byType(AppPageHeader),
        matching: find.text(
          l.servicesMasterEditName(l.servicesPrioritySingular),
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });

  testWidgets('all representative forms show Add/Edit mode titles', (
    tester,
  ) async {
    harness.viewport(tester, 1280);
    final h = await _login(tester, AppLanguage.english);
    final l = tester.element(find.byType(AppShell)).l10n;
    final router = harness.router(tester);

    final expectations = <String, String>{
      '/app/services/customers/new': l.servicesCustomerAdd,
      '/app/services/sites/demo-site-abc-1/edit': l.servicesSiteEdit,
      '/app/services/enquiries/new': l.servicesEnquiryFormNew,
      '/app/services/job-assignments/demo-ja-1/edit':
          l.servicesJobAssignmentFormEdit,
      '/app/services/inspections/demo-ins-1/edit': l.servicesInspectionFormEdit,
      '/app/services/material-requests/new': l.servicesMaterialRequestFormNew,
      '/app/services/work-executions/demo-we-1/edit':
          l.servicesWorkExecutionFormEdit,
    };
    for (final entry in expectations.entries) {
      router.go(entry.key);
      await harness.pump(tester);
      expect(
        find.descendant(
          of: find.byType(AppPageHeader),
          matching: find.text(entry.value),
        ),
        findsOneWidget,
        reason: 'title for ${entry.key}',
      );
      expect(tester.takeException(), isNull, reason: entry.key);
    }
    await harness.unmount(tester, h);
  });

  testWidgets(
    'transaction forms expose read-only context and generated values',
    (tester) async {
      harness.viewport(tester, 1280);
      final h = await _login(tester, AppLanguage.english);
      final router = harness.router(tester);

      router.go('/app/services/inspections/demo-ins-1/edit');
      await harness.pump(tester);
      expect(find.byType(AppReadOnlyContextSection), findsWidgets);
      expect(find.byType(AppGeneratedValueField), findsWidgets);
      expect(tester.takeException(), isNull);

      router.go('/app/services/work-executions/demo-we-1/edit');
      await harness.pump(tester);
      expect(find.byType(AppReadOnlyContextSection), findsWidgets);
      expect(tester.takeException(), isNull);
      await harness.unmount(tester, h);
    },
  );

  testWidgets('services forms share the one global centered width', (
    tester,
  ) async {
    for (final width in [1440.0, 1920.0]) {
      harness.viewport(tester, width);
      final h = await _login(tester, AppLanguage.english);
      final router = harness.router(tester);

      router.go('/app/services/enquiries');
      await harness.pump(tester);
      final listHeader = find.byType(AppPageHeader).first;
      final left = tester.getTopLeft(listHeader).dx;
      final right = tester.getTopRight(listHeader).dx;

      for (final route in [
        '/app/services/settings/priorities/new',
        '/app/services/enquiries/new',
        '/app/services/material-requests/new',
      ]) {
        router.go(route);
        await harness.pump(tester);
        final header = find.byType(AppPageHeader).first;
        expect(
          tester.getTopLeft(header).dx,
          closeTo(left, 0.5),
          reason: 'left origin for $route at $width',
        );
        expect(
          tester.getTopRight(header).dx,
          closeTo(right, 0.5),
          reason: 'right edge for $route at $width',
        );
        expect(
          tester.getTopRight(header).dx - tester.getTopLeft(header).dx,
          lessThanOrEqualTo(AppDimensions.contentMaxWidth),
        );
      }
      await harness.unmount(tester, h);
    }
  });

  testWidgets('services forms render in Arabic RTL', (tester) async {
    harness.viewport(tester, 1440);
    final h = await _login(tester, AppLanguage.arabic);
    final context = tester.element(find.byType(AppShell));
    expect(Directionality.of(context), TextDirection.rtl);
    final router = harness.router(tester);
    router.go('/app/services/settings/priorities/new');
    await harness.pump(tester);
    expect(find.byType(AppBooleanSettingRow), findsOneWidget);
    expect(tester.takeException(), isNull);
    for (final route in [
      '/app/services/customers/new',
      '/app/services/enquiries/new',
    ]) {
      router.go(route);
      await harness.pump(tester);
      expect(tester.takeException(), isNull, reason: 'arabic route $route');
    }
    await harness.unmount(tester, h);
  });
}
