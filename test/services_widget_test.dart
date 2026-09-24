import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/app/shell/app_shell.dart';

import 'auth_widget_test.dart' as harness;

void main() {
  testWidgets('services screens render on mobile and desktop', (tester) async {
    for (final width in [390.0, 1280.0]) {
      harness.viewport(tester, width);
      final h = await harness.mount(
        tester,
        AppLanguage.english,
        withServices: true,
      );
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await harness.pump(tester);
      expect(find.byType(AppShell), findsOneWidget);
      final context = tester.element(find.byType(AppShell));
      final router = harness.router(tester);

      for (final route in [
        '/app/services',
        '/app/services/customers',
        '/app/services/customers/new',
        '/app/services/sites',
        '/app/services/teams',
        '/app/services/settings',
      ]) {
        router.go(route);
        await harness.pump(tester);
        expect(
          tester.takeException(),
          isNull,
          reason: 'route $route at width $width',
        );
      }

      router.go('/app/services/customers');
      await harness.pump(tester);
      expect(find.text(context.l10n.servicesCustomerAdd), findsWidgets);
      expect(tester.takeException(), isNull);

      await harness.unmount(tester, h);
    }
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
