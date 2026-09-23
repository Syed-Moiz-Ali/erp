/// Canonical HR module routes.
///
/// Module-first URL architecture: every HR destination lives under `/app/hr`.
/// HR configuration lives under `/app/hr/settings` so it is never confused with
/// the application-wide `/app/settings`. Route paths are stable English
/// identifiers and are never localized.
abstract final class HrRoutes {
  static const root = '/app/hr';

  static const employees = '$root/employees';
  static const employeesNew = '$employees/new';
  static String employee(String id) => '$employees/${Uri.encodeComponent(id)}';
  static String employeeEdit(String id) => '${employee(id)}/edit';

  static const attendance = '$root/attendance';
  static const attendanceHistory = '$attendance/history';
  static const attendanceCorrections = '$attendance/corrections';
  static const attendanceRequests = '$attendance/requests';
  static const attendanceTeam = '$attendance/team';
  static const attendanceAll = '$attendance/all';
  static String attendanceCorrectionForm(String dayId) =>
      '$attendanceCorrections/new/${Uri.encodeComponent(dayId)}';
  static String attendanceCorrectionDetails(String id) =>
      '$attendanceCorrections/${Uri.encodeComponent(id)}';
  static String attendanceReviewDetails(String id) =>
      '$attendanceRequests/${Uri.encodeComponent(id)}';
  static String attendanceWorkforceDetails(
    String employeeId,
    String dayId, {
    bool team = false,
  }) =>
      '${team ? attendanceTeam : attendanceAll}/${Uri.encodeComponent(employeeId)}/${Uri.encodeComponent(dayId)}';
  static String attendanceDayDetails(String id) =>
      '$attendanceHistory/${Uri.encodeComponent(id)}';

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
      '$leaveRequestBase/${Uri.encodeComponent(id)}';
  static const leaveEmployeeBase = '$leave/employee';
  static String leaveEmployee(String id) =>
      '$leaveEmployeeBase/${Uri.encodeComponent(id)}';

  static const reports = '$root/reports';
  static const reportAttendance = '$reports/attendance';
  static const reportLeave = '$reports/leave';

  static const settings = '$root/settings';
  static const shifts = '$settings/shifts';
  static const shiftsNew = '$shifts/new';
  static String shift(String id) => '$shifts/${Uri.encodeComponent(id)}';
  static String shiftEdit(String id) => '${shift(id)}/edit';

  static const workLocations = '$settings/work-locations';
  static const workLocationsNew = '$workLocations/new';
  static String workLocation(String id) =>
      '$workLocations/${Uri.encodeComponent(id)}';
  static String workLocationEdit(String id) => '${workLocation(id)}/edit';

  static const attendancePolicies = '$settings/attendance-policies';
  static const attendancePoliciesNew = '$attendancePolicies/new';
  static String attendancePolicy(String id) =>
      '$attendancePolicies/${Uri.encodeComponent(id)}';
  static String attendancePolicyEdit(String id) =>
      '${attendancePolicy(id)}/edit';

  static const leaveTypes = '$settings/leave-types';
  static const leaveTypesNew = '$leaveTypes/new';
  static String leaveType(String id) =>
      '$leaveTypes/${Uri.encodeComponent(id)}';
  static String leaveTypeEdit(String id) => '${leaveType(id)}/edit';

  static const leavePolicies = '$settings/leave-policies';
  static const leavePoliciesNew = '$leavePolicies/new';
  static String leavePolicy(String id) =>
      '$leavePolicies/${Uri.encodeComponent(id)}';
  static String leavePolicyEdit(String id) => '${leavePolicy(id)}/edit';

  static const holidays = '$settings/holidays';
  static const holidaysNew = '$holidays/new';
  static const holidaysImport = '$holidays/import';
  static String holiday(String id) => '$holidays/${Uri.encodeComponent(id)}';
  static String holidayEdit(String id) => '${holiday(id)}/edit';
}
