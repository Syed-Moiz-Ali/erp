/// Public cross-module workforce contract.
///
/// The Services module depends on this contract, never on HR Drift tables,
/// repositories or presentation code. A technician is conceptually an Employee
/// who is assignable to Service work — there is deliberately no separate
/// technician person entity.
class WorkforcePersonRef {
  const WorkforcePersonRef({
    required this.id,
    required this.name,
    required this.employeeCode,
    this.departmentId,
    this.departmentName,
    this.designationId,
    this.designationName,
    this.workLocationId,
    this.avatarReference,
    this.isActive = true,
  });
  final String id, name, employeeCode;
  final String? departmentId, departmentName, designationId, designationName;
  final String? workLocationId, avatarReference;
  final bool isActive;
}

/// Lightweight employee summary for assignment pickers and scheduling.
class AssignableEmployeeSummary {
  const AssignableEmployeeSummary({
    required this.id,
    required this.name,
    required this.employeeCode,
    this.departmentId,
    this.designationId,
  });
  final String id, name, employeeCode;
  final String? departmentId, designationId;
}

/// The HR module provides the implementation/adapter. Services consumes it.
///
/// All queries are company-scoped through the authenticated session. New
/// assignment search excludes inactive employees by default; historical lookups
/// use [getEmployeeReference] with `includeInactive: true`.
abstract interface class WorkforceDirectory {
  /// Resolves a lightweight reference. Returns null for unknown employees or
  /// employees outside the current company. Set [includeInactive] for historical
  /// references to terminated employees.
  Future<WorkforcePersonRef?> getEmployeeReference(
    String employeeId, {
    bool includeInactive = false,
  });

  /// Active, company-scoped employees eligible to be assigned new work.
  Future<List<WorkforcePersonRef>> searchAssignable({
    String query = '',
    int limit = 50,
  });

  /// Resolves several references at once (company-scoped), including inactive
  /// employees so historical membership stays resolvable. Unknown/other-company
  /// ids are omitted.
  Future<List<WorkforcePersonRef>> getEmployees(Iterable<String> employeeIds);

  /// Reactive variant used by assignment pickers.
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  });
}
