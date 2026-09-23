import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_form_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_list_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_list_page.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_details_page.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_form_page.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'auth_widget_test.dart' as h;
import 'employee_test.dart' show validDraft;

Future<void> settleDb(WidgetTester t) async {
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
  for (final language in AppLanguage.values) {
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
      testWidgets(
        '${language.name} employee list/details/create/edit fit $width',
        (t) async {
          h.viewport(t, width);
          final app = await h.mount(t, language);
          app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
          await h.pump(t);
          final router = h.router(t);
          router.go(AppRoutes.employees);
          await settleDb(t);
          expect(find.byType(EmployeeListPage), findsOneWidget);
          final c = t.element(find.byType(EmployeeListPage));
          final list = c.read<EmployeeListBloc>();
          expect(list.state.data!.total, 25);
          expect(list.state.loading, isFalse);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'employees_${language.name}_${width.toInt()}',
            );
          }
          router.push(AppRoutes.employeeDetails('employee-employee'));
          await settleDb(t);
          expect(find.byType(EmployeeDetailsPage), findsOneWidget);
          expect(find.text('Noor Ali'), findsWidgets);
          expect(t.takeException(), isNull);
          router.push(AppRoutes.employeeEdit('employee-employee'));
          await settleDb(t);
          expect(find.byType(EmployeeFormPage), findsOneWidget);
          expect(
            t
                .widgetList<TextFormField>(find.byType(TextFormField))
                .any((f) => f.controller?.text == 'Noor'),
            isTrue,
          );
          expect(t.takeException(), isNull);
          router.go(AppRoutes.employeeNew);
          await settleDb(t);
          expect(find.byType(EmployeeFormPage), findsOneWidget);
          final form = t
              .element(find.byType(EmployeeFormPage))
              .read<EmployeeFormBloc>();
          expect(form.state.loading, isFalse);
          expect(form.state.dirty, isFalse);
          expect(t.takeException(), isNull);
          if (width == 390 || width == 1440) {
            await h.screenshot(
              t,
              app.key,
              'employee_form_${language.name}_${width.toInt()}',
            );
          }
          form.add(const EmployeeSubmitted());
          await settleDb(t);
          expect(
            form.state.fieldErrors.keys,
            containsAll([
              'firstName',
              'email',
              'phone',
              'departmentId',
              'designationId',
              'joiningDate',
            ]),
          );
          expect(t.takeException(), isNull);
          await h.unmount(t, app);
        },
      );
    }
    for (final width in [390.0, 1440.0]) {
      testWidgets(
        '${language.name} filters, search, menu and confirmation at $width',
        (t) async {
          h.viewport(t, width);
          final app = await h.mount(t, language);
          app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
          await h.pump(t);
          h.router(t).go(AppRoutes.employees);
          await settleDb(t);
          var c = t.element(find.byType(EmployeeListPage));
          final l = c.l10n;
          final filters = find.byWidgetPredicate(
            (w) => w is AppSecondaryButton && w.icon == Icons.tune,
          );
          await h.tapVisible(t, filters);
          expect(find.text(l.empApply), findsOneWidget);
          expect(t.takeException(), isNull);
          await h.tapVisible(t, find.byType(AppDropdown<EmploymentStatus>));
          await h.tapVisible(t, find.text(l.empInactive).last);
          await h.tapVisible(
            t,
            find.widgetWithText(AppPrimaryButton, l.empApply),
          );
          await settleDb(t);
          expect(c.read<EmployeeListBloc>().state.data!.filtered, 4);
          await h.tapVisible(t, find.widgetWithText(AppTextButton, l.empClear));
          await settleDb(t);
          await h.tapVisible(t, filters);
          await t.sendKeyEvent(LogicalKeyboardKey.escape);
          await h.pump(t);
          final search = find
              .descendant(
                of: find.byType(AppSearchField),
                matching: find.byType(TextFormField),
              )
              .first;
          await t.enterText(search, 'Noor Ali');
          await settleDb(t);
          c = t.element(find.byType(EmployeeListPage));
          expect(c.read<EmployeeListBloc>().state.data!.filtered, 1);
          await h.tapVisible(t, find.byType(AppActionMenu).first);
          await h.tapVisible(t, find.text(l.empDeactivate));
          expect(find.text(l.empStatusConfirm), findsOneWidget);
          expect(t.takeException(), isNull);
          await h.tapVisible(
            t,
            find.widgetWithText(AppPrimaryButton, l.empDeactivate),
          );
          await settleDb(t);
          expect(
            c.read<EmployeeListBloc>().state.data!.employees.single.status,
            EmploymentStatus.inactive,
          );
          await h.unmount(t, app);
        },
      );
    }
  }
  testWidgets(
    'form failure retains input, successful save navigates to reactive detail',
    (t) async {
      h.viewport(t, 1280);
      final app = await h.mount(t, AppLanguage.english);
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      h.router(t).go(AppRoutes.employeeNew);
      await settleDb(t);
      final c = t.element(find.byType(EmployeeFormPage)),
          form = c.read<EmployeeFormBloc>();
      form.add(EmployeeDraftChanged((d) => d.copyWith(firstName: 'Retained')));
      form.add(const EmployeeSubmitted());
      await settleDb(t);
      expect(form.state.failure, isNotNull);
      expect(form.state.draft.firstName, 'Retained');
      expect(find.byType(AppAlert), findsWidgets);
      form.add(EmployeeDraftChanged((_) => validDraft()));
      form.add(const EmployeeSubmitted());
      await settleDb(t);
      expect(find.byType(EmployeeDetailsPage), findsOneWidget);
      expect(find.text('New Colleague'), findsWidgets);
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  testWidgets('dirty form route exit requires discard; cancel keeps draft', (
    t,
  ) async {
    h.viewport(t, 1280);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    final router = h.router(t);
    router.go(AppRoutes.employeeNew);
    await settleDb(t);
    final c = t.element(find.byType(EmployeeFormPage)), l = c.l10n;
    await t.enterText(find.widgetWithText(TextFormField, l.empFirst), 'Dirty');
    await h.pump(t);
    router.go(AppRoutes.employees);
    await h.pump(t);
    expect(find.text(l.cfgDiscard), findsOneWidget);
    await h.tapVisible(
      t,
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.widgetWithText(AppTextButton, l.cfgKeepEditing),
      ),
    );
    expect(find.byType(EmployeeFormPage), findsOneWidget);
    router.go(AppRoutes.employees);
    await h.pump(t);
    await h.tapVisible(
      t,
      find.widgetWithText(AppPrimaryButton, l.cfgDiscardAction),
    );
    await settleDb(t);
    expect(find.byType(EmployeeListPage), findsOneWidget);
    await h.unmount(t, app);
  });
  testWidgets(
    'self detail is available but list, another employee and creation are denied',
    (t) async {
      h.viewport(t, 390);
      final app = await h.mount(t, AppLanguage.english);
      app.auth.add(
        const AuthLoginRequested('employee@erp.demo', 'Employee@123'),
      );
      await h.pump(t);
      final router = h.router(t);
      router.go(AppRoutes.employeeDetails('employee-employee'));
      await settleDb(t);
      expect(find.byType(EmployeeDetailsPage), findsOneWidget);
      for (final route in [
        AppRoutes.employees,
        AppRoutes.employeeDetails('employee-hr'),
        AppRoutes.employeeNew,
        AppRoutes.employeeEdit('employee-employee'),
      ]) {
        router.go(route);
        await settleDb(t);
        expect(find.byType(UnauthorizedPage), findsOneWidget);
      }
      await h.unmount(t, app);
    },
  );
  testWidgets('manager list is scoped and out-of-team detail is denied', (
    t,
  ) async {
    h.viewport(t, 1280);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('manager@erp.demo', 'Manager@123'));
    await h.pump(t);
    final router = h.router(t);
    router.go(AppRoutes.employees);
    await settleDb(t);
    expect(
      t
          .element(find.byType(EmployeeListPage))
          .read<EmployeeListBloc>()
          .state
          .data!
          .total,
      10,
    );
    router.go(AppRoutes.employeeDetails('employee-hr'));
    await settleDb(t);
    expect(find.byType(UnauthorizedPage), findsOneWidget);
    await h.unmount(t, app);
  });
  testWidgets(
    'create and edit through shared fields, searchable selections and date picker',
    (t) async {
      h.viewport(t, 1280);
      final app = await h.mount(t, AppLanguage.english);
      app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await h.pump(t);
      final router = h.router(t);
      router.go(AppRoutes.employeeNew);
      await settleDb(t);
      final l = t.element(find.byType(EmployeeFormPage)).l10n;
      for (final input in [
        (l.empFirst, 'UI Colleague'),
        (l.email, 'ui@erp.demo'),
        (l.phone, '+15557771111'),
      ]) {
        final field = find.widgetWithText(TextFormField, input.$1);
        await t.ensureVisible(field);
        await t.enterText(field, input.$2);
        await h.pump(t);
      }
      for (final reference in [
        (l.empDepartment, 'Human Resources'),
        (l.empDesignation, 'HR Executive'),
      ]) {
        await h.tapVisible(
          t,
          find.byWidgetPredicate(
            (w) => w is AppSelectField<String> && w.label == reference.$1,
          ),
        );
        await h.tapVisible(t, find.text(reference.$2));
      }
      await h.tapVisible(t, find.byType(AppDateField));
      await h.tapVisible(t, find.text(l.confirm));
      await h.tapVisible(t, find.byType(AppSwitchField));
      await h.pump(t);
      await h.tapVisible(
        t,
        find.widgetWithText(AppPrimaryButton, l.empSave).first,
      );
      await settleDb(t);
      expect(find.byType(EmployeeDetailsPage), findsOneWidget);
      expect(find.text('UI Colleague'), findsWidgets);
      expect(find.text(l.empCredentialPending), findsWidgets);
      final id = router.routeInformationProvider.value.uri.pathSegments.last;
      router.push(AppRoutes.employeeEdit(id));
      await settleDb(t);
      final first = find.widgetWithText(TextFormField, l.empFirst);
      await t.enterText(first, 'Edited Colleague');
      await h.pump(t);
      await h.tapVisible(
        t,
        find.widgetWithText(AppPrimaryButton, l.empSave).first,
      );
      await settleDb(t);
      expect(find.byType(EmployeeDetailsPage), findsOneWidget);
      expect(find.text('Edited Colleague'), findsWidgets);
      expect(
        (await t.runAsync(
          () => app.database!.select(app.database!.syncOutbox).get(),
        ))!.length,
        2,
      );
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    },
  );
  testWidgets('filtered no results differs from a genuinely empty workforce', (
    t,
  ) async {
    h.viewport(t, 390);
    final app = await h.mount(t, AppLanguage.english);
    app.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await h.pump(t);
    h.router(t).go(AppRoutes.employees);
    await settleDb(t);
    final c = t.element(find.byType(EmployeeListPage)), l = c.l10n;
    c.read<EmployeeListBloc>().add(
      const EmployeeSearchChanged('no such colleague'),
    );
    await settleDb(t);
    expect(find.text(l.empNoResults), findsOneWidget);
    expect(find.text(l.empEmpty), findsNothing);
    // Remove test fixtures only, to verify first-use presentation.
    await t.runAsync(
      () => app.database!.delete(app.database!.workforceEmployees).go(),
    );
    c.read<EmployeeListBloc>().add(const EmployeeSearchChanged(''));
    await settleDb(t);
    expect(find.text(l.empEmpty), findsOneWidget);
    expect(find.text(l.empNoResults), findsNothing);
    expect(t.takeException(), isNull);
    await h.unmount(t, app);
  });
}
