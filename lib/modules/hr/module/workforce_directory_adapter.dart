import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

/// HR implementation of the public Services workforce contract. It keeps the
/// Services module free of HR Drift/presentation internals; Services depends on
/// the contract, HR provides this adapter.
class HrWorkforceDirectory implements WorkforceDirectory {
  const HrWorkforceDirectory(this.auth, this.employees);
  final AuthRepository auth;
  final EmployeeRepository employees;

  Future<AuthContext?> _context() async {
    final result = await auth.checkSession();
    return result is Success<AuthContext?> ? result.value : null;
  }

  WorkforcePersonRef _ref(Employee employee) => WorkforcePersonRef(
    id: employee.id,
    name: employee.displayName,
    employeeCode: employee.employeeCode,
    departmentId: employee.departmentId,
    designationId: employee.designationId,
    workLocationId: employee.workLocationId,
    avatarReference: employee.avatarUrl,
    linkedUserId: employee.linkedUserId,
    isActive: employee.status == EmploymentStatus.active,
  );

  @override
  Future<WorkforcePersonRef?> getEmployeeReference(
    String employeeId, {
    bool includeInactive = false,
  }) async {
    final context = await _context();
    if (context == null) return null;
    // Restricted reference: authorized by the cross-module contract, not by HR
    // employee-view permission.
    final result = await employees.getCompanyEmployee(context, employeeId);
    if (result is! Success<Employee?> || result.value == null) return null;
    final employee = result.value!;
    if (!includeInactive && employee.status != EmploymentStatus.active) {
      return null;
    }
    return _ref(employee);
  }

  @override
  Future<List<WorkforcePersonRef>> searchAssignable({
    String query = '',
    int limit = 50,
  }) async {
    final context = await _context();
    if (context == null) return const [];
    final result = await employees.searchAssignableCompanyEmployees(
      context,
      query: query,
      limit: limit,
    );
    if (result is! Success<List<Employee>>) return const [];
    return [for (final employee in result.value) _ref(employee)];
  }

  @override
  Future<List<WorkforcePersonRef>> getEmployees(
    Iterable<String> employeeIds,
  ) async {
    final context = await _context();
    if (context == null) return const [];
    final result = await employees.getCompanyEmployees(context, employeeIds);
    if (result is! Success<List<Employee>>) return const [];
    return [for (final employee in result.value) _ref(employee)];
  }

  @override
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  }) async* {
    final context = await _context();
    if (context == null) {
      yield const [];
      return;
    }
    await for (final result in employees.watchEmployees(
      context,
      query: query,
      pageSize: 100,
    )) {
      if (result is Success<EmployeePageData>) {
        yield [
          for (final employee in result.value.employees)
            if (employee.status == EmploymentStatus.active)
              AssignableEmployeeSummary(
                id: employee.id,
                name: employee.displayName,
                employeeCode: employee.employeeCode,
                departmentId: employee.departmentId,
                designationId: employee.designationId,
              ),
        ];
      }
    }
  }
}
