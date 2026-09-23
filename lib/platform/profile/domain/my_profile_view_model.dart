import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';

/// Typed read model for the unified My Profile screen. It combines the account
/// with the linked employee when one exists; it never merges the two domains.
class MyProfileViewModel {
  const MyProfileViewModel({
    required this.account,
    required this.capabilities,
    this.employee,
    this.references,
    this.employeeUnavailable = false,
    this.employeeFailure,
  });

  final AuthContext account;
  final UserCapabilityContext capabilities;
  final Employee? employee;
  final EmployeeReferences? references;

  /// The account references an employee that could not be resolved.
  final bool employeeUnavailable;
  final Failure? employeeFailure;

  bool get hasEmployee => employee != null;
  bool get accountOnly => employee == null;

  String get displayName => employee?.displayName ?? account.user.displayName;

  String? referenceName(List<WorkforceReference>? items, String? id) {
    if (id == null || items == null) return null;
    for (final item in items) {
      if (item.id == id) return item.name;
    }
    return null;
  }
}
