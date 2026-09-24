import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/app/shell/app_shell.dart';

import 'auth_widget_test.dart' as harness;

const _routes = [
  '/app/services',
  '/app/services/enquiries',
  '/app/services/enquiries/new',
  '/app/services/enquiries/demo-enq-1',
  '/app/services/job-assignments',
  '/app/services/job-assignments/new',
  '/app/services/job-assignments/demo-ja-1',
  '/app/services/customers',
  '/app/services/customers/new',
  '/app/services/sites',
  '/app/services/teams',
  '/app/services/settings',
];

void main() {
  for (final width in [390.0, 768.0, 1024.0, 1440.0, 1920.0]) {
    testWidgets('services screens fit ${width.toInt()}', (tester) async {
      harness.viewport(tester, width);
      final h = await harness.mount(
        tester,
        AppLanguage.english,
        withServices: true,
      );
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await harness.pump(tester);
      expect(find.byType(AppShell), findsOneWidget);
      final router = harness.router(tester);

      for (final route in _routes) {
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

  testWidgets('desktop content is width-controlled, never edge-to-edge', (
    tester,
  ) async {
    for (final width in [1440.0, 1920.0]) {
      harness.viewport(tester, width);
      final h = await harness.mount(
        tester,
        AppLanguage.english,
        withServices: true,
      );
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await harness.pump(tester);
      final router = harness.router(tester);

      // List and form must share the one global centered content width.
      router.go('/app/services/enquiries');
      await harness.pump(tester);
      final listHeader = find.byType(AppPageHeader).first;
      final left = tester.getTopLeft(listHeader).dx;
      final right = tester.getTopRight(listHeader).dx;
      expect(left, greaterThan(0));
      expect(
        width - right,
        greaterThan(16),
        reason: 'list content must not touch the edge at $width',
      );
      expect(right - left, lessThanOrEqualTo(AppDimensions.contentMaxWidth));

      router.go('/app/services/enquiries/new');
      await harness.pump(tester);
      final formHeader = find.byType(AppPageHeader).first;
      final formLeft = tester.getTopLeft(formHeader).dx;
      final formRight = tester.getTopRight(formHeader).dx;
      expect(
        formLeft,
        closeTo(left, 0.5),
        reason: 'form must share the list page origin at $width',
      );
      expect(
        formRight - formLeft,
        closeTo(right - left, 0.5),
        reason: 'form must share the list page width at $width',
      );
      expect(
        formRight - formLeft,
        lessThanOrEqualTo(AppDimensions.contentMaxWidth),
      );

      await harness.unmount(tester, h);
    }
  });

  testWidgets('services screens render in Arabic RTL', (tester) async {
    harness.viewport(tester, 1440);
    final h = await harness.mount(
      tester,
      AppLanguage.arabic,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    expect(Directionality.of(context), TextDirection.rtl);
    final router = harness.router(tester);
    for (final route in [
      '/app/services',
      '/app/services/enquiries',
      '/app/services/enquiries/new',
      '/app/services/customers',
    ]) {
      router.go(route);
      await harness.pump(tester);
      expect(tester.takeException(), isNull, reason: 'arabic route $route');
    }
    await harness.unmount(tester, h);
  });

  testWidgets('enquiry form and detail show detail lines and material', (
    tester,
  ) async {
    harness.viewport(tester, 1280);
    final h = await harness.mount(
      tester,
      AppLanguage.english,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    final router = harness.router(tester);

    router.go('/app/services/enquiries/new');
    await harness.pump(tester);
    expect(
      find.text(context.l10n.servicesEnquiryMaterialReceived),
      findsWidgets,
    );
    expect(find.text(context.l10n.servicesEnquiryAddDetail), findsWidgets);
    expect(find.text(context.l10n.servicesEnquiryAddPhotos), findsWidgets);
    expect(
      find.text(context.l10n.servicesEnquiryDetailLine('1')),
      findsWidgets,
    );

    router.go('/app/services/enquiries/demo-enq-1');
    await harness.pump(tester);
    expect(find.text(context.l10n.servicesEnquiryDetailsSection), findsWidgets);
    expect(
      find.text('Main distribution board tripped repeatedly.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });

  testWidgets('job assignment form and detail render work items', (
    tester,
  ) async {
    harness.viewport(tester, 1280);
    final h = await harness.mount(
      tester,
      AppLanguage.english,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    final router = harness.router(tester);

    router.go('/app/services/job-assignments/new');
    await harness.pump(tester);
    expect(
      find.text(context.l10n.servicesJobAssignmentVisitDate),
      findsWidgets,
    );
    expect(find.text(context.l10n.servicesJobAssignmentAddLine), findsWidgets);
    expect(
      find.text(context.l10n.servicesJobAssignmentLineTitle('1')),
      findsWidgets,
    );

    router.go('/app/services/job-assignments/demo-ja-1');
    await harness.pump(tester);
    expect(
      find.text(context.l10n.servicesJobAssignmentDetailWork),
      findsWidgets,
    );
    expect(
      find.text('Inspect the distribution board and emergency lighting'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await harness.unmount(tester, h);
  });

  testWidgets('shell navigation groups destinations by module section', (
    tester,
  ) async {
    harness.viewport(tester, 1280);
    final h = await harness.mount(
      tester,
      AppLanguage.english,
      withServices: true,
    );
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await harness.pump(tester);
    final context = tester.element(find.byType(AppShell));
    expect(find.text(context.l10n.navSectionHr), findsWidgets);
    expect(find.text(context.l10n.navSectionServices), findsWidgets);
    await harness.unmount(tester, h);
  });
}
