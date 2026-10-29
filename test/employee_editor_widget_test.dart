import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';
import 'package:modular_erp/modules/hr/employees/live/presentation/pages/live_employees_page.dart';

void main() {
  testWidgets('login toggle reveals login fields and omits login when off', (
    tester,
  ) async {
    const lookups = LiveEmployeeLookups(
      branches: [Lookup(1, 'Branch One'), Lookup(2, 'Branch Two')],
      departments: [Lookup(1, 'Department One')],
      nationalities: [Lookup(99, 'Nationality One')],
      statuses: [Lookup(1, 'Active'), Lookup(2, 'InActive')],
      maritalStatuses: ['Single'],
      employeeTypes: ['Revenue'],
      gratuityTypes: ['Limited Contract'],
    );
    const initial = LiveEmployeeDraft(
      name: 'QA Employee',
      branchId: 1,
      departmentId: 1,
      nationalityId: 99,
      joiningDate: '2026-10-01',
      email: 'qa@example.com',
      phone: '0500000000',
      loginBranchIds: [1],
    );
    LiveEmployeeDraft? submitted;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(locale: const Locale('en')),
        home: Scaffold(
          body: EmployeeEditor(
            lookups: lookups,
            initial: initial,
            raw: const {},
            title: 'Create employee',
            canManageLogin: true,
            onSave: (draft) async {
              submitted = draft;
              return null;
            },
          ),
        ),
      ),
    );
    expect(find.text('Login mobile'), findsNothing);
    tester.widget<Switch>(find.byType(Switch)).onChanged!(true);
    await tester.pumpAndSettle();
    expect(find.text('Login mobile'), findsWidgets);
    expect(find.text('Password'), findsWidgets);
    expect(find.text('Branch One'), findsWidgets);
    expect(find.text('Branch Two'), findsWidgets);

    tester.widget<Switch>(find.byType(Switch)).onChanged!(false);
    await tester.pumpAndSettle();
    expect(find.text('Login mobile'), findsNothing);
    expect(find.text('Password'), findsNothing);

    tester
        .widget<AppPrimaryButton>(find.widgetWithText(AppPrimaryButton, 'Save'))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(submitted, isNotNull);
    expect(submitted!.toBody().containsKey('login'), isFalse);
  });
}
