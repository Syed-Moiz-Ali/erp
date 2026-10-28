import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/router/platform_routes.dart';
import 'package:modular_erp/app/router/route_segments.dart';
import 'package:modular_erp/modules/hr/module/hr_routes.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';

/// Locks the centralized route constants and composition helpers so the
/// refactor cannot silently change any path.
void main() {
  test('shared segments compose predictable, safely-encoded paths', () {
    expect(RouteSegments.newPath('/a'), '/a/new');
    expect(RouteSegments.editPath('/a'), '/a/edit');
    expect(RouteSegments.printPath('/a'), '/a/print');
    expect(RouteSegments.importPath('/a'), '/a/import');
    expect(RouteSegments.byId('/a', 7), '/a/7');
    expect(RouteSegments.byId('/a', 'x y/z'), '/a/x%20y%2Fz');
    expect(RouteSegments.byIdEdit('/a', 7), '/a/7/edit');
  });

  test('module roots sit under the app mount', () {
    expect(PlatformRoutes.app, '/app');
    expect(HrRoutes.root, '/app/hr');
    expect(ServicesRoutes.root, '/app/services');
  });

  test('platform route values are stable', () {
    expect(PlatformRoutes.root, '/');
    expect(PlatformRoutes.login, '/login');
    expect(PlatformRoutes.access, '/app/settings/access');
    expect(PlatformRoutes.more, '/app/more');
    expect(PlatformRoutes.designSystem, '/design-system');
  });

  test('HR route values are unchanged', () {
    expect(HrRoutes.employees, '/app/hr/employees');
    expect(HrRoutes.employeesNew, '/app/hr/employees/new');
    expect(HrRoutes.employee('7'), '/app/hr/employees/7');
    expect(HrRoutes.employeeEdit('7'), '/app/hr/employees/7/edit');
    expect(
      HrRoutes.attendanceCorrectionForm('9'),
      '/app/hr/attendance/corrections/new/9',
    );
    expect(
      HrRoutes.attendanceWorkforceDetails('3', '9'),
      '/app/hr/attendance/all/3/9',
    );
    expect(HrRoutes.departments, '/app/hr/settings/departments');
    expect(HrRoutes.departmentsNew, '/app/hr/settings/departments/new');
    expect(HrRoutes.holidaysImport, '/app/hr/settings/holidays/import');
  });

  test('Services route values are unchanged', () {
    expect(ServicesRoutes.enquiries, '/app/services/enquiries');
    expect(ServicesRoutes.enquiriesNew, '/app/services/enquiries/new');
    expect(ServicesRoutes.enquiry('3'), '/app/services/enquiries/3');
    expect(
      ServicesRoutes.materialRequestPrint('5'),
      '/app/services/material-requests/5/print',
    );
    expect(
      ServicesRoutes.chargeResponsibilities,
      '/app/services/settings/charge-responsibilities',
    );
  });
}
