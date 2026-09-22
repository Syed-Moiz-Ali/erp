abstract final class AppRoutes {
  static const root = '/',
      bootstrap = '/bootstrap',
      login = '/login',
      forgotPassword = '/forgot-password',
      app = '/app',
      dashboard = '/app/dashboard',
      employees = '/app/employees',
      attendance = '/app/attendance',
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
      reports = 'reports',
      settings = 'settings',
      account = 'account';
}
