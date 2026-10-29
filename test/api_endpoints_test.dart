import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';

void main() {
  test('authentication endpoints match the documented contract', () {
    expect(ApiEndpoints.auth.login, '/api/auth/login');
    expect(ApiEndpoints.auth.refresh, '/api/auth/refresh');
    expect(ApiEndpoints.auth.logout, '/api/auth/logout');
  });

  test('resource endpoints build safely-encoded parameterised paths', () {
    expect(ApiEndpoints.departments.list, '/api/departments');
    expect(ApiEndpoints.departments.byId(7), '/api/departments/7');
    expect(
      ApiEndpoints.departments.deactivate(7),
      '/api/departments/7/deactivate',
    );
    expect(ApiEndpoints.employees.lookups, '/api/employees/lookups');
    expect(ApiEndpoints.employees.byId('a b/c'), '/api/employees/a%20b%2Fc');
    expect(ApiEndpoints.branches.activate(3), '/api/branches/3/activate');
    expect(ApiEndpoints.shifts.byId(4), '/api/shifts/4');
    expect(
      ApiEndpoints.employeeShifts.deactivate(9),
      '/api/employee-shifts/9/deactivate',
    );
    expect(ApiEndpoints.attendance.today, '/api/attendance/today');
    expect(ApiEndpoints.attendance.punch, '/api/attendance/punch');
  });
}
