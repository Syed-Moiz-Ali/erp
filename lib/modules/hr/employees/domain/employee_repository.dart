import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'employee.dart';

abstract interface class EmployeeRepository {
  Stream<Result<EmployeePageData>> watchEmployees(
    AuthContext context, {
    String query = '',
    EmployeeFilter filter = const EmployeeFilter(),
    EmployeeSort sort = EmployeeSort.nameAscending,
    int page = 0,
    int pageSize = 10,
  });
  Stream<Result<Employee?>> watchEmployee(AuthContext context, String id);
  Future<Result<Employee?>> getEmployeeById(AuthContext context, String id);

  /// Restricted, company-scoped active-employee search for the cross-module
  /// workforce contract. Does not require HR employee-view permission.
  Future<Result<List<Employee>>> searchAssignableCompanyEmployees(
    AuthContext context, {
    String query = '',
    int limit = 50,
  });

  /// Restricted, company-scoped employee lookup (active or historical) for the
  /// cross-module workforce contract. Does not require HR employee-view permission.
  Future<Result<Employee?>> getCompanyEmployee(AuthContext context, String id);

  /// Restricted, company-scoped batch employee lookup (active or historical).
  Future<Result<List<Employee>>> getCompanyEmployees(
    AuthContext context,
    Iterable<String> ids,
  );
  Future<Result<Employee>> saveEmployee(
    AuthContext context,
    EmployeeDraft draft, {
    String? id,
  });
  Future<Result<void>> setActive(AuthContext context, String id, bool active);
  Future<Result<bool>> checkEmailAvailability(
    AuthContext context,
    String email, {
    String? excludingId,
  });
  Future<Result<bool>> checkPhoneAvailability(
    AuthContext context,
    String phone, {
    String? excludingId,
  });
  Future<Result<EmployeeAccountAccess?>> getLinkedAccount(
    AuthContext context,
    String employeeId,
  );
  Future<Result<EmployeeReferences>> getReferences(
    AuthContext context, {
    String? excludingId,
  });
}

class EmployeeAccountAccess {
  const EmployeeAccountAccess(this.user, {required this.credentialPending});
  final UserAccount user;
  final bool credentialPending;
}
