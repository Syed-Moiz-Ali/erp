import 'package:modular_erp/app/router/platform_routes.dart';
import 'package:modular_erp/modules/hr/module/hr_routes.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';

/// Public route facade used across the application.
///
/// Ownership lives in the module route classes (`HrRoutes`, `ServicesRoutes`,
/// `PlatformRoutes`); this facade keeps stable names for existing callers while
/// the canonical module-first values are defined in one place. New code should
/// prefer the module route class directly.
abstract final class AppRoutes {
  static const root = '/',
      bootstrap = '/bootstrap',
      login = '/login',
      forgotPassword = '/forgot-password',
      app = PlatformRoutes.app,
      dashboard = HrRoutes.root,
      employees = HrRoutes.employees,
      attendance = HrRoutes.attendance,
      leave = HrRoutes.leave,
      services = ServicesRoutes.root,
      reports = HrRoutes.reports,
      settings = PlatformRoutes.settings,
      access = '$settings/access',
      modules = '$settings/modules',
      profile = PlatformRoutes.profile,
      changePassword = PlatformRoutes.changePassword,
      more = '/app/more',
      notifications = PlatformRoutes.notifications,
      reminderSettings = PlatformRoutes.reminderSettings,
      syncSettings = PlatformRoutes.syncSettings,
      syncInspector = '/app/sync-inspector',
      unauthorized = '/app/access-denied',
      unavailable = '/app/module-unavailable',
      notFound = '/app/not-found',
      noDestinations = '/app/no-destinations',
      designSystem = '/design-system';
  static const attendanceHistory = HrRoutes.attendanceHistory;
  static const attendanceCorrections = HrRoutes.attendanceCorrections;
  static const attendanceRequests = HrRoutes.attendanceRequests;
  static const attendanceTeam = HrRoutes.attendanceTeam;
  static const attendanceAll = HrRoutes.attendanceAll;
  static String attendanceCorrectionForm(String dayId) =>
      HrRoutes.attendanceCorrectionForm(dayId);
  static String attendanceCorrectionDetails(String id) =>
      HrRoutes.attendanceCorrectionDetails(id);
  static String attendanceReviewDetails(String id) =>
      HrRoutes.attendanceReviewDetails(id);
  static String attendanceWorkforceDetails(
    String employeeId,
    String dayId, {
    bool team = false,
  }) => HrRoutes.attendanceWorkforceDetails(employeeId, dayId, team: team);
  static String attendanceDayDetails(String id) =>
      HrRoutes.attendanceDayDetails(id);
  static const employeeNew = HrRoutes.employeesNew;
  static const leaveRequest = HrRoutes.leaveRequest;
  static const leaveMyRequests = HrRoutes.leaveMyRequests;
  static const leaveRequestBase = HrRoutes.leaveRequestBase;
  static const leaveApprovals = HrRoutes.leaveApprovals;
  static const leaveTeam = HrRoutes.leaveTeam;
  static const leaveAll = HrRoutes.leaveAll;
  static const leaveBalances = HrRoutes.leaveBalances;
  static const leaveCalendar = HrRoutes.leaveCalendar;
  static String leaveRequestDetails(String id) =>
      HrRoutes.leaveRequestDetails(id);
  static const leaveEmployeeBase = HrRoutes.leaveEmployeeBase;
  static String leaveEmployee(String id) => HrRoutes.leaveEmployee(id);
  static const leaveTypes = HrRoutes.leaveTypes;
  static const leaveTypesNew = HrRoutes.leaveTypesNew;
  static String leaveTypesDetails(String id) => HrRoutes.leaveType(id);
  static String leaveTypesEdit(String id) => HrRoutes.leaveTypeEdit(id);
  static const leavePolicies = HrRoutes.leavePolicies;
  static const leavePoliciesNew = HrRoutes.leavePoliciesNew;
  static String leavePoliciesDetails(String id) => HrRoutes.leavePolicy(id);
  static String leavePoliciesEdit(String id) => HrRoutes.leavePolicyEdit(id);
  static const holidays = HrRoutes.holidays;
  static const holidaysNew = HrRoutes.holidaysNew;
  static const holidaysImport = HrRoutes.holidaysImport;
  static String holidaysDetails(String id) => HrRoutes.holiday(id);
  static String holidaysEdit(String id) => HrRoutes.holidayEdit(id);
  static String employeeDetails(String id) => HrRoutes.employee(id);
  static String employeeEdit(String id) => HrRoutes.employeeEdit(id);
  static const shifts = HrRoutes.shifts;
  static const shiftsNew = HrRoutes.shiftsNew;
  static String shiftsDetails(String id) => HrRoutes.shift(id);
  static String shiftsEdit(String id) => HrRoutes.shiftEdit(id);
  static const workLocations = HrRoutes.workLocations;
  static const workLocationsNew = HrRoutes.workLocationsNew;
  static String workLocationsDetails(String id) => HrRoutes.workLocation(id);
  static String workLocationsEdit(String id) => HrRoutes.workLocationEdit(id);
  static const attendancePolicies = HrRoutes.attendancePolicies;
  static const attendancePoliciesNew = HrRoutes.attendancePoliciesNew;
  static String attendancePoliciesDetails(String id) =>
      HrRoutes.attendancePolicy(id);
  static String attendancePoliciesEdit(String id) =>
      HrRoutes.attendancePolicyEdit(id);
  static String accessUser(String id) =>
      '$access/users/${Uri.encodeComponent(id)}';
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
