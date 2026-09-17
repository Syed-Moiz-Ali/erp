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
      unauthorized = '/app/access-denied',
      unavailable = '/app/module-unavailable',
      notFound = '/app/not-found',
      noDestinations = '/app/no-destinations',
      designSystem = '/design-system';
  static const employeeNew = '/app/employees/new';
  static String employeeDetails(String id) =>
      '$employees/${Uri.encodeComponent(id)}';
  static String employeeEdit(String id) => '${employeeDetails(id)}/edit';
  static const utilityPaths = {
    more,
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
