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
  });
  final String id, name, employeeCode;
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
abstract interface class WorkforceDirectory {
  Future<WorkforcePersonRef?> getEmployeeReference(String employeeId);
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  });
}
