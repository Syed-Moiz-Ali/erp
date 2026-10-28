import 'package:modular_erp/app/router/route_segments.dart';

/// Canonical HR module routes.
///
/// Module-first URL architecture: every HR destination lives under `/app/hr`.
/// HR configuration lives under `/app/hr/settings` so it is never confused with
/// the application-wide `/app/settings`. Route paths are stable English
/// identifiers and are never localized.
///
/// All paths are composed from [RouteSegments] and the named constants below —
/// no string fragment is written inline.
abstract final class HrRoutes {
  static const root = '/${RouteSegments.app}/hr';
  static const settings = '$root/settings';

  // Employees.
  static const employees = '$root/employees';
  static const employeesNew = '$employees/${RouteSegments.newRecord}';
  static String employee(String id) => RouteSegments.byId(employees, id);
  static String employeeEdit(String id) =>
      RouteSegments.byIdEdit(employees, id);

  // Attendance.
  static const attendance = '$root/attendance';
  static const attendanceHistory = '$attendance/history';
  static const attendanceCorrections = '$attendance/corrections';
  static const attendanceRequests = '$attendance/requests';
  static const attendanceTeam = '$attendance/team';
  static const attendanceAll = '$attendance/all';
  static String attendanceCorrectionForm(String dayId) =>
      RouteSegments.byId(RouteSegments.newPath(attendanceCorrections), dayId);
  static String attendanceCorrectionDetails(String id) =>
      RouteSegments.byId(attendanceCorrections, id);
  static String attendanceReviewDetails(String id) =>
      RouteSegments.byId(attendanceRequests, id);
  static String attendanceWorkforceDetails(
    String employeeId,
    String dayId, {
    bool team = false,
  }) => RouteSegments.byId(
    RouteSegments.byId(team ? attendanceTeam : attendanceAll, employeeId),
    dayId,
  );
  static String attendanceDayDetails(String id) =>
      RouteSegments.byId(attendanceHistory, id);

  // Leave.
  static const leave = '$root/leave';
  static const leaveRequest = '$leave/request';
  static const leaveMyRequests = '$leave/my-requests';
  static const leaveRequestBase = '$leave/requests';
  static const leaveApprovals = '$leave/approvals';
  static const leaveTeam = '$leave/team';
  static const leaveAll = '$leave/all';
  static const leaveBalances = '$leave/balances';
  static const leaveCalendar = '$leave/calendar';
  static String leaveRequestDetails(String id) =>
      RouteSegments.byId(leaveRequestBase, id);
  static const leaveEmployeeBase = '$leave/employee';
  static String leaveEmployee(String id) =>
      RouteSegments.byId(leaveEmployeeBase, id);

  // Reports.
  static const reports = '$root/reports';
  static const reportAttendance = '$reports/attendance';
  static const reportLeave = '$reports/leave';

  // Configuration: shifts.
  static const shifts = '$settings/shifts';
  static const shiftsNew = '$shifts/${RouteSegments.newRecord}';
  static String shift(String id) => RouteSegments.byId(shifts, id);
  static String shiftEdit(String id) => RouteSegments.byIdEdit(shifts, id);

  // Configuration: work locations.
  static const workLocations = '$settings/work-locations';
  static const workLocationsNew = '$workLocations/${RouteSegments.newRecord}';
  static String workLocation(String id) =>
      RouteSegments.byId(workLocations, id);
  static String workLocationEdit(String id) =>
      RouteSegments.byIdEdit(workLocations, id);

  // Configuration: attendance policies.
  static const attendancePolicies = '$settings/attendance-policies';
  static const attendancePoliciesNew =
      '$attendancePolicies/${RouteSegments.newRecord}';
  static String attendancePolicy(String id) =>
      RouteSegments.byId(attendancePolicies, id);
  static String attendancePolicyEdit(String id) =>
      RouteSegments.byIdEdit(attendancePolicies, id);

  // Configuration: departments.
  static const departments = '$settings/departments';
  static const departmentsNew = '$departments/${RouteSegments.newRecord}';
  static String department(String id) => RouteSegments.byId(departments, id);
  static String departmentEdit(String id) =>
      RouteSegments.byIdEdit(departments, id);

  // Configuration: leave types.
  static const leaveTypes = '$settings/leave-types';
  static const leaveTypesNew = '$leaveTypes/${RouteSegments.newRecord}';
  static String leaveType(String id) => RouteSegments.byId(leaveTypes, id);
  static String leaveTypeEdit(String id) =>
      RouteSegments.byIdEdit(leaveTypes, id);

  // Configuration: leave policies.
  static const leavePolicies = '$settings/leave-policies';
  static const leavePoliciesNew = '$leavePolicies/${RouteSegments.newRecord}';
  static String leavePolicy(String id) => RouteSegments.byId(leavePolicies, id);
  static String leavePolicyEdit(String id) =>
      RouteSegments.byIdEdit(leavePolicies, id);

  // Configuration: holidays.
  static const holidays = '$settings/holidays';
  static const holidaysNew = '$holidays/${RouteSegments.newRecord}';
  static const holidaysImport = '$holidays/${RouteSegments.import}';
  static String holiday(String id) => RouteSegments.byId(holidays, id);
  static String holidayEdit(String id) => RouteSegments.byIdEdit(holidays, id);
}
