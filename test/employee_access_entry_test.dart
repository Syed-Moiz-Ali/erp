import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';
import 'package:modular_erp/modules/hr/employees/live/presentation/pages/live_employees_page.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

AuthContext _account(Set<AppPermission> permissions) => AuthContext(
  user: UserAccount(
    id: '8',
    displayName: 'Admin',
    email: 'admin@example.com',
    companyId: '1',
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: const CompanyContext(
    id: '1',
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: {'hr'},
  ),
);

LiveEmployee _employee({int? userId}) => LiveEmployee(
  id: 1032,
  code: 'EMP-33',
  name: 'QA Employee',
  raw: const {},
  loginUserId: userId,
);

void main() {
  test('manage access requires the permission and a login user id', () {
    final admin = _account({AppPermission.accessPermissionsManage});
    final viewer = _account({AppPermission.employeeViewAll});
    expect(canManageEmployeeAccess(admin, _employee(userId: 44)), isTrue);
    expect(canManageEmployeeAccess(admin, _employee()), isFalse);
    expect(canManageEmployeeAccess(viewer, _employee(userId: 44)), isFalse);
    expect(canManageEmployeeAccess(null, _employee(userId: 44)), isFalse);
  });
}
