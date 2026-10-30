import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'employee.freezed.dart';
part 'employee.g.dart';

enum EmploymentType { fullTime, partTime, contract, intern, temporary }

enum EmploymentStatus { active, inactive }

enum EmployeeSyncStatus { synced, pending, failed }

enum EmployeeScope { none, self, team, all }

enum EmployeeSort {
  nameAscending,
  nameDescending,
  code,
  newestJoined,
  oldestJoined,
}

@freezed
abstract class Employee with _$Employee {
  const Employee._();
  const factory Employee({
    required String id,
    required String companyId,
    required String employeeCode,
    required String firstName,
    @Default('') String middleName,
    @Default('') String lastName,
    required String email,
    required String phone,
    String? avatarUrl,
    required String departmentId,
    required String designationId,
    String? managerId,
    required DateTime joiningDate,
    @Default(EmploymentType.fullTime) EmploymentType employmentType,
    @Default(EmploymentStatus.active) EmploymentStatus status,
    String? shiftId,
    String? workLocationId,
    String? attendancePolicyId,
    String? linkedUserId,
    @Default(false) bool loginEnabled,
    String? branchId,
    String? nationalityId,
    DateTime? dateOfBirth,
    String? maritalStatus,
    String? gratuity,
    double? workingHours,
    double? basicSalary,
    double? transportation,
    double? accommodation,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(EmployeeSyncStatus.pending) EmployeeSyncStatus syncStatus,
  }) = _Employee;
  String get displayName =>
      [firstName, middleName, lastName].where((s) => s.isNotEmpty).join(' ');
  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);
}

@freezed
abstract class EmployeeDraft with _$EmployeeDraft {
  const factory EmployeeDraft({
    @Default('') String firstName,
    @Default('') String middleName,
    @Default('') String lastName,
    @Default('') String email,
    @Default('') String phone,
    String? departmentId,
    String? designationId,
    String? managerId,
    String? shiftId,
    String? workLocationId,
    String? attendancePolicyId,
    DateTime? joiningDate,
    @Default(EmploymentType.fullTime) EmploymentType employmentType,
    @Default(EmploymentStatus.active) EmploymentStatus status,
    @Default(false) bool loginEnabled,
    String? branchId,
    String? nationalityId,
    DateTime? dateOfBirth,
    String? maritalStatus,
    String? gratuity,
    double? workingHours,
    double? basicSalary,
    double? transportation,
    double? accommodation,
  }) = _EmployeeDraft;
}

@freezed
abstract class EmployeeFilter with _$EmployeeFilter {
  const EmployeeFilter._();
  const factory EmployeeFilter({
    EmploymentStatus? status,
    String? departmentId,
    String? designationId,
    String? managerId,
    EmploymentType? employmentType,
  }) = _EmployeeFilter;
  int get activeCount => [
    status,
    departmentId,
    designationId,
    managerId,
    employmentType,
  ].where((v) => v != null).length;
}

class WorkforceReference {
  const WorkforceReference(this.id, this.name);
  final String id, name;
}

class EmployeeReferences {
  EmployeeReferences({
    required List<WorkforceReference> departments,
    required List<WorkforceReference> designations,
    required List<WorkforceReference> managers,
    List<WorkforceReference> managerLabels = const [],
    List<Shift> shifts = const [],
    List<WorkLocation> workLocations = const [],
    List<AttendancePolicy> attendancePolicies = const [],
    List<WorkforceReference> branches = const [],
    List<WorkforceReference> nationalities = const [],
    List<String> maritalStatuses = const [],
    List<String> employeeTypes = const [],
    List<String> gratuityTypes = const [],
  }) : shifts = List.unmodifiable(shifts),
       workLocations = List.unmodifiable(workLocations),
       attendancePolicies = List.unmodifiable(attendancePolicies),
       departments = List.unmodifiable(departments),
       designations = List.unmodifiable(designations),
       managers = List.unmodifiable(managers),
       managerLabels = List.unmodifiable([...managers, ...managerLabels]),
       branches = List.unmodifiable(branches),
       nationalities = List.unmodifiable(nationalities),
       maritalStatuses = List.unmodifiable(maritalStatuses),
       employeeTypes = List.unmodifiable(employeeTypes),
       gratuityTypes = List.unmodifiable(gratuityTypes);
  final List<Shift> shifts;
  final List<WorkLocation> workLocations;
  final List<AttendancePolicy> attendancePolicies;
  final List<WorkforceReference> departments,
      designations,
      managers,
      managerLabels,
      branches,
      nationalities;
  final List<String> maritalStatuses, employeeTypes, gratuityTypes;

  /// The backend supplies branch/nationality/scratch-pad values the local demo
  /// store does not model; demo mode therefore keeps the original form shape.
  bool get hasBackendProfileLookups =>
      branches.isNotEmpty || nationalities.isNotEmpty;
}

class EmployeePageData {
  EmployeePageData(List<Employee> employees, this.total, this.filtered)
    : employees = List.unmodifiable(employees);
  final List<Employee> employees;
  final int total, filtered;
}
