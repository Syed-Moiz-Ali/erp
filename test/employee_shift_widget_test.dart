import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/pages/employee_shift_details_page.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/pages/employee_shift_form_page.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/pages/employee_shift_list_page.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

import 'auth_widget_test.dart' as h;
import 'employee_widget_test.dart' show settleDb;
import 'support/employee_shift_test_doubles.dart';

EmployeeShift _assignment({
  int id = 1,
  int employeeId = 2,
  String employeeName = 'Sanitized Employee',
  String employeeCode = 'EMP-2',
  int shiftId = 3,
  String shiftName = 'Morning',
  int statusId = 1,
  String status = 'Active',
}) => EmployeeShift(
  employeeShiftId: id,
  employeeId: employeeId,
  employeeCode: employeeCode,
  employeeName: employeeName,
  shiftId: shiftId,
  shiftName: shiftName,
  fromDate: '2026-09-01',
  toDate: '2026-10-31',
  startTime: '09:00:00',
  endTime: '17:00:00',
  earlyPunchInMinutes: 20,
  lateGraceMinutes: 10,
  statusId: statusId,
  status: status,
  timeZoneId: 'Asia/Dubai',
  punchInOpensAt: '08:40:00',
);

Employee _employee({
  String id = '2',
  String firstName = 'Sanitized Employee',
}) => Employee(
  id: id,
  companyId: '3',
  employeeCode: 'EMP-$id',
  firstName: firstName,
  email: 'employee$id@example.test',
  phone: '0000000000',
  departmentId: '1',
  designationId: '1',
  joiningDate: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Shift _shift({String id = '3', String name = 'Morning'}) => Shift(
  id: id,
  companyId: '3',
  name: name,
  startTime: const LocalTime(hour: 9, minute: 0),
  endTime: const LocalTime(hour: 17, minute: 0),
  workingDays: const {WorkingDay.monday},
  earlyPunchInMinutes: 20,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  status: ConfigurationStatus.active,
);

Future<(InMemoryEmployeeShiftRepository, h.Harness)> _login(
  WidgetTester t,
  double width,
) async {
  h.viewport(t, width);
  final repository = InMemoryEmployeeShiftRepository(
    shifts: [
      _assignment(id: 1),
      _assignment(
        id: 2,
        employeeId: 4,
        employeeName: 'Second Employee',
        employeeCode: 'EMP-4',
        shiftName: 'Evening',
      ),
    ],
  );
  final employees = FakeEmployeeRepository(
    employees: [
      _employee(),
      _employee(id: '4', firstName: 'Second Employee'),
    ],
  );
  final shifts = FakeShiftRepository(
    shifts: [
      _shift(),
      _shift(id: '4', name: 'Evening'),
    ],
  );
  final app = await h.mount(
    t,
    AppLanguage.english,
    registryFactory: (auth) => createErpRegistry(
      auth,
      employeeShiftRepository: repository,
      employeeRepository: employees,
      shiftRepository: shifts,
    ),
  );
  app.auth.add(const AuthLoginRequested('company@erp.demo', 'Company@123'));
  await h.pump(t);
  return (repository, app);
}

void main() {
  testWidgets('employee shift list, detail and form render and validate', (
    t,
  ) async {
    final (_, app) = await _login(t, 390);

    h.router(t).go(AppRoutes.employeeShifts);
    await settleDb(t);
    expect(find.byType(EmployeeShiftListPage), findsOneWidget);
    expect(find.text('Sanitized Employee (EMP-2) – Morning'), findsOneWidget);

    h.router(t).go(AppRoutes.employeeShiftsDetails('1'));
    await settleDb(t);
    expect(find.byType(EmployeeShiftDetailsPage), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('2026-09-01'), findsOneWidget);
    expect(find.text('08:40:00'), findsOneWidget);

    h.router(t).go(AppRoutes.employeeShiftsNew);
    await settleDb(t);
    final form = t.element(find.byType(EmployeeShiftFormPage));
    expect(
      find.text('${form.l10n.cfgEmployeeShiftEmployee} *', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('${form.l10n.cfgEmployeeShiftShift} *', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('${form.l10n.cfgEmployeeShiftFrom} *', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('${form.l10n.cfgEmployeeShiftTo} *', findRichText: true),
      findsOneWidget,
    );

    final save = find.widgetWithText(AppPrimaryButton, form.l10n.save);
    await t.ensureVisible(save);
    await settleDb(t);
    await t.tap(save);
    await settleDb(t);
    expect(find.text(form.l10n.cfgRequired), findsNWidgets(4));
    await h.unmount(t, app);
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets('employee shift screens fit at $width', (t) async {
      final (_, app) = await _login(t, width);

      h.router(t).go(AppRoutes.employeeShifts);
      await settleDb(t);
      expect(find.byType(EmployeeShiftListPage), findsOneWidget);
      expect(t.takeException(), isNull);

      h.router(t).go(AppRoutes.employeeShiftsDetails('1'));
      await settleDb(t);
      expect(find.byType(EmployeeShiftDetailsPage), findsOneWidget);
      expect(t.takeException(), isNull);

      h.router(t).go(AppRoutes.employeeShiftsEdit('1'));
      await settleDb(t);
      expect(find.byType(EmployeeShiftFormPage), findsOneWidget);
      expect(t.takeException(), isNull);
      await h.unmount(t, app);
    });
  }
}
