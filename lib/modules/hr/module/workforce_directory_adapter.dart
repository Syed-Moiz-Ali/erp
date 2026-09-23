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

  @override
  Future<WorkforcePersonRef?> getEmployeeReference(String employeeId) async {
    final context = await _context();
    if (context == null) return null;
    final result = await employees.getEmployeeById(context, employeeId);
    if (result is! Success<Employee?> || result.value == null) return null;
    final employee = result.value!;
    return WorkforcePersonRef(
      id: employee.id,
      name: employee.displayName,
      employeeCode: employee.employeeCode,
    );
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
