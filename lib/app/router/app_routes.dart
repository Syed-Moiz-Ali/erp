abstract final class AppRoutes {
  static const root = '/',
      bootstrap = '/bootstrap',
      login = '/login',
      forgotPassword = '/forgot-password',
      app = '/app',
      dashboard = '/app/dashboard',
      employees = '/app/employees',
      attendance = '/app/attendance',
      leave = '/app/leave',
      services = '/app/services',
      reports = '/app/reports',
      settings = '/app/settings',
      profile = '/app/profile',
      changePassword = '/app/change-password',
      more = '/app/more',
      notifications = '/app/notifications',
      reminderSettings = '/app/settings/notifications',
      syncSettings = '/app/settings/sync',
      syncInspector = '/app/sync-inspector',
      unauthorized = '/app/access-denied',
      unavailable = '/app/module-unavailable',
      notFound = '/app/not-found',
      noDestinations = '/app/no-destinations',
      designSystem = '/design-system';
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
  static const employeeNew = '/app/employees/new';
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
  static const leaveTypes = '/app/settings/leave-types';
  static const leaveTypesNew = '$leaveTypes/new';
  static String leaveTypesDetails(String id) =>
      '$leaveTypes/${Uri.encodeComponent(id)}';
  static String leaveTypesEdit(String id) => '${leaveTypesDetails(id)}/edit';
  static const leavePolicies = '/app/settings/leave-policies';
  static const leavePoliciesNew = '$leavePolicies/new';
  static String leavePoliciesDetails(String id) =>
      '$leavePolicies/${Uri.encodeComponent(id)}';
  static String leavePoliciesEdit(String id) =>
      '${leavePoliciesDetails(id)}/edit';
  static const holidays = '/app/settings/holidays';
  static const holidaysNew = '$holidays/new';
  static const holidaysImport = '$holidays/import';
  static String holidaysDetails(String id) =>
      '$holidays/${Uri.encodeComponent(id)}';
  static String holidaysEdit(String id) => '${holidaysDetails(id)}/edit';
  static String employeeDetails(String id) =>
      '$employees/${Uri.encodeComponent(id)}';
  static String employeeEdit(String id) => '${employeeDetails(id)}/edit';
  static const shifts = '/app/settings/shifts';
  static const shiftsNew = '$shifts/new';
  static String shiftsDetails(String id) =>
      '$shifts/${Uri.encodeComponent(id)}';
  static String shiftsEdit(String id) => '${shiftsDetails(id)}/edit';
  static const workLocations = '/app/settings/work-locations';
  static const workLocationsNew = '$workLocations/new';
  static String workLocationsDetails(String id) =>
      '$workLocations/${Uri.encodeComponent(id)}';
  static String workLocationsEdit(String id) =>
      '${workLocationsDetails(id)}/edit';
  static const attendancePolicies = '/app/settings/attendance-policies';
  static const attendancePoliciesNew = '$attendancePolicies/new';
  static String attendancePoliciesDetails(String id) =>
      '$attendancePolicies/${Uri.encodeComponent(id)}';
  static String attendancePoliciesEdit(String id) =>
      '${attendancePoliciesDetails(id)}/edit';
  static const utilityPaths = {
    more,
    notifications,
    reminderSettings,
    syncSettings,
    unauthorized,
    unavailable,
    notFound,
    noDestinations,
  };
}

abstract final class AppModuleIds {
  static const dashboard = 'dashboard',
      employees = 'employees',
      attendance = 'attendance',
      leave = 'leave',
      services = 'services',
      reports = 'reports',
      settings = 'settings',
      account = 'account';
}
