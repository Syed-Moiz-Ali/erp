import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_route_transitions.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';
import 'package:modular_erp/shared/navigation/form_navigation_guard.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_repository.dart';
import 'package:modular_erp/modules/hr/reports/data/attendance_report_export_service.dart';
import 'package:modular_erp/modules/hr/reports/presentation/bloc/attendance_report_bloc.dart';
import 'package:modular_erp/modules/hr/reports/presentation/attendance_reports_page.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart'
    show AttendanceScope;
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_correction_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/workforce_attendance_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/pages/attendance_correction_pages.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/pages/workforce_attendance_page.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/pages/workforce_attendance_details_page.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_history_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_day_details_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/pages/attendance_history_page.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/pages/attendance_day_details_page.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/pages/attendance_today_page.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/widgets/attendance_module_nav.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/bloc/shift_list_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/pages/shift_list_page.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/bloc/shift_details_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/pages/shift_details_page.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/bloc/shift_form_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/pages/shift_form_page.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/bloc/work_location_list_bloc.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/pages/work_location_list_page.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/bloc/work_location_details_bloc.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/pages/work_location_details_page.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/bloc/work_location_form_bloc.dart';
import 'package:modular_erp/modules/hr/work_locations/presentation/pages/work_location_form_page.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/bloc/attendance_policy_list_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/pages/attendance_policy_list_page.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/bloc/attendance_policy_details_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/pages/attendance_policy_details_page.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/bloc/attendance_policy_form_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/presentation/pages/attendance_policy_form_page.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_list_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_details_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_form_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_list_page.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_details_page.dart';
import 'package:modular_erp/modules/hr/employees/presentation/pages/employee_form_page.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_configuration_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_operations_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_holiday_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_type_pages.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_policy_pages.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/holiday_pages.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_home_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_overview_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_operations_pages.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_approvals_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_employee_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_request_form_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_request_list_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_request_details_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_balances_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/pages/leave_calendar_page.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_module_nav.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_today_banner.dart';

/// HR business-module destination composition. Owns Employees, Attendance,
/// Leave/Holidays, Attendance reports and the HR configuration routes.
class HrModules {
  const HrModules({required this.modules, required this.settingsDestinations});
  final List<AppModule> modules;
  final List<RegisteredDestination> settingsDestinations;
}

HrModules buildHrModules({
  required ModuleRegistry Function() registry,
  EmployeeRepository? employeeRepository,
  ShiftRepository? shiftRepository,
  WorkLocationRepository? workLocationRepository,
  AttendancePolicyRepository? attendancePolicyRepository,
  LocationService? locationService,
  AttendanceRepository? attendanceRepository,
  AttendanceCorrectionRepository? correctionRepository,
  WorkforceAttendanceReadRepository? workforceAttendanceRepository,
  AttendanceReportRepository? attendanceReportRepository,
  AttendanceReportExportService? attendanceReportExportService,
  LeaveRepository? leaveRepository,
  ConfigurationRepository<LeaveType, LeaveTypeDraft>? leaveTypeRepository,
  ConfigurationRepository<LeavePolicy, LeavePolicyDraft>? leavePolicyRepository,
  ConfigurationRepository<Holiday, HolidayDraft>? holidayRepository,
}) {
  final formGuard = FormNavigationGuard();
  RegisteredDestination destination(
    ErpModule navigation,
    WidgetBuilder builder,
  ) => RegisteredDestination(
    navigation: navigation,
    routes: [
      GoRoute(
        path: navigation.route,
        name: navigation.id,
        pageBuilder: (context, state) =>
            AppRouteTransitions.page(context, state, builder(context)),
      ),
    ],
  );
  RegisteredDestination shiftsDestination() {
    final guard = FormNavigationGuard();
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'shifts',
        moduleId: AppModuleIds.settings,
        name: (l) => l.cfgShifts,
        icon: Icons.schedule_outlined,
        route: AppRoutes.shifts,
        requiredPermissions: {AppPermission.shiftView},
        navigationGroup: NavigationGroup.configuration,
        order: 41,
        desktopVisible: false,
        mobileVisible: false,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (shiftRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) =>
                        ShiftListBloc(shiftRepository, auth)
                          ..add(const RecordListStarted()),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.shifts,
              name: 'shifts',
              builder: (c, s) => const ShiftListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  onExit: (c, s) => guard.onExit(c),
                  builder: (c, s) => BlocProvider(
                    key: const ValueKey('shift-new'),
                    create: (_) => ShiftFormBloc(
                      shiftRepository!,
                      c.read<ShiftListBloc>().context,
                      id: null,
                    )..add(const RecordFormInitialized<ShiftDraft>()),
                    child: ShiftFormPage(guard: guard),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (c, s) => BlocProvider(
                    key: ValueKey(s.pathParameters['id']),
                    create: (_) => ShiftDetailsBloc(
                      shiftRepository!,
                      c.read<ShiftListBloc>().context,
                      s.pathParameters['id']!,
                    )..add(const RecordDetailsStarted()),
                    child: const ShiftDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      onExit: (c, s) => guard.onExit(c),
                      builder: (c, s) => BlocProvider(
                        key: ValueKey('${s.pathParameters['id']}-edit'),
                        create: (_) => ShiftFormBloc(
                          shiftRepository!,
                          c.read<ShiftListBloc>().context,
                          id: s.pathParameters['id'],
                        )..add(const RecordFormInitialized<ShiftDraft>()),
                        child: ShiftFormPage(guard: guard),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  RegisteredDestination workLocationsDestination() {
    final guard = FormNavigationGuard();
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'work-locations',
        moduleId: AppModuleIds.settings,
        name: (l) => l.cfgLocations,
        icon: Icons.location_on_outlined,
        route: AppRoutes.workLocations,
        requiredPermissions: {AppPermission.workLocationView},
        navigationGroup: NavigationGroup.configuration,
        order: 42,
        desktopVisible: false,
        mobileVisible: false,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (workLocationRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) =>
                        WorkLocationListBloc(workLocationRepository, auth)
                          ..add(const RecordListStarted()),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.workLocations,
              name: 'work-locations',
              builder: (c, s) => const WorkLocationListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  onExit: (c, s) => guard.onExit(c),
                  builder: (c, s) => BlocProvider(
                    key: const ValueKey('work-location-new'),
                    create: (_) => WorkLocationFormBloc(
                      workLocationRepository!,
                      c.read<WorkLocationListBloc>().context,
                      locationService ?? DeviceLocationService(),
                      id: null,
                    )..add(const RecordFormInitialized<WorkLocationDraft>()),
                    child: WorkLocationFormPage(guard: guard),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (c, s) => BlocProvider(
                    key: ValueKey(s.pathParameters['id']),
                    create: (_) => WorkLocationDetailsBloc(
                      workLocationRepository!,
                      c.read<WorkLocationListBloc>().context,
                      s.pathParameters['id']!,
                    )..add(const RecordDetailsStarted()),
                    child: const WorkLocationDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      onExit: (c, s) => guard.onExit(c),
                      builder: (c, s) => BlocProvider(
                        key: ValueKey('${s.pathParameters['id']}-edit'),
                        create: (_) =>
                            WorkLocationFormBloc(
                              workLocationRepository!,
                              c.read<WorkLocationListBloc>().context,
                              locationService ?? DeviceLocationService(),
                              id: s.pathParameters['id'],
                            )..add(
                              const RecordFormInitialized<WorkLocationDraft>(),
                            ),
                        child: WorkLocationFormPage(guard: guard),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  RegisteredDestination attendancePoliciesDestination() {
    final guard = FormNavigationGuard();
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'attendance-policies',
        moduleId: AppModuleIds.settings,
        name: (l) => l.cfgPolicies,
        icon: Icons.rule_outlined,
        route: AppRoutes.attendancePolicies,
        requiredPermissions: {AppPermission.attendancePolicyView},
        navigationGroup: NavigationGroup.configuration,
        order: 43,
        desktopVisible: false,
        mobileVisible: false,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (attendancePolicyRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) => AttendancePolicyListBloc(
                      attendancePolicyRepository,
                      auth,
                    )..add(const RecordListStarted()),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.attendancePolicies,
              name: 'attendance-policies',
              builder: (c, s) => const AttendancePolicyListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  onExit: (c, s) => guard.onExit(c),
                  builder: (c, s) => BlocProvider(
                    key: const ValueKey('attendance-policy-new'),
                    create: (_) =>
                        AttendancePolicyFormBloc(
                          attendancePolicyRepository!,
                          c.read<AttendancePolicyListBloc>().context,
                          id: null,
                        )..add(
                          const RecordFormInitialized<AttendancePolicyDraft>(),
                        ),
                    child: AttendancePolicyFormPage(guard: guard),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (c, s) => BlocProvider(
                    key: ValueKey(s.pathParameters['id']),
                    create: (_) => AttendancePolicyDetailsBloc(
                      attendancePolicyRepository!,
                      c.read<AttendancePolicyListBloc>().context,
                      s.pathParameters['id']!,
                    )..add(const RecordDetailsStarted()),
                    child: const AttendancePolicyDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      onExit: (c, s) => guard.onExit(c),
                      builder: (c, s) => BlocProvider(
                        key: ValueKey('${s.pathParameters['id']}-edit'),
                        create: (_) =>
                            AttendancePolicyFormBloc(
                              attendancePolicyRepository!,
                              c.read<AttendancePolicyListBloc>().context,
                              id: s.pathParameters['id'],
                            )..add(
                              const RecordFormInitialized<
                                AttendancePolicyDraft
                              >(),
                            ),
                        child: AttendancePolicyFormPage(guard: guard),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  RegisteredDestination leaveMyRequestsDestination() => RegisteredDestination(
    navigation: ErpModule(
      id: 'leave-my-requests',
      moduleId: AppModuleIds.leave,
      name: (l) => l.leaveMyRequests,
      icon: Icons.event_note_outlined,
      route: AppRoutes.leaveMyRequests,
      navigationGroup: NavigationGroup.workforce,
      order: 26,
      desktopVisible: false,
      mobileVisible: false,
      requiredPermissions: {AppPermission.leaveViewSelf},
    ),
    routes: [
      GoRoute(
        path: AppRoutes.leaveMyRequests,
        name: 'leave-my-requests',
        builder: (c, s) {
          final account = c.read<AuthBloc>().state.context!;
          return BlocProvider(
            key: ValueKey(account),
            create: (_) => LeaveRequestListBloc(
              leaveRepository!,
              account,
              LeaveRequestScope.self,
            )..add(const LeaveRequestListStarted()),
            child: LeaveModuleScaffold(
              child: LeaveRequestListPage(
                title: c.l10n.leaveMyRequests,
                emptyMessage: c.l10n.leaveRequestsEmpty,
              ),
            ),
          );
        },
      ),
    ],
  );

  RegisteredDestination leaveTypeDestination() {
    final guard = FormNavigationGuard();
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'leave-types',
        moduleId: AppModuleIds.settings,
        name: (l) => l.leaveTypesNav,
        icon: Icons.category_outlined,
        route: AppRoutes.leaveTypes,
        requiredPermissions: {AppPermission.leaveTypeView},
        navigationGroup: NavigationGroup.configuration,
        order: 44,
        desktopVisible: false,
        mobileVisible: false,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (leaveTypeRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) =>
                        LeaveTypeListBloc(leaveTypeRepository, auth)
                          ..add(const RecordListStarted()),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.leaveTypes,
              name: 'leave-types',
              builder: (c, s) => const LeaveTypeListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  onExit: (c, s) => guard.onExit(c),
                  builder: (c, s) => BlocProvider(
                    key: const ValueKey('leave-type-new'),
                    create: (_) => LeaveTypeFormBloc(
                      leaveTypeRepository!,
                      c.read<LeaveTypeListBloc>().context,
                    )..add(const RecordFormInitialized<LeaveTypeDraft>()),
                    child: LeaveTypeFormPage(guard: guard),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (c, s) => BlocProvider(
                    key: ValueKey(s.pathParameters['id']),
                    create: (_) => LeaveTypeDetailsBloc(
                      leaveTypeRepository!,
                      c.read<LeaveTypeListBloc>().context,
                      s.pathParameters['id']!,
                    )..add(const RecordDetailsStarted()),
                    child: const LeaveTypeDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      onExit: (c, s) => guard.onExit(c),
                      builder: (c, s) => BlocProvider(
                        key: ValueKey('${s.pathParameters['id']}-edit'),
                        create: (_) => LeaveTypeFormBloc(
                          leaveTypeRepository!,
                          c.read<LeaveTypeListBloc>().context,
                          id: s.pathParameters['id'],
                        )..add(const RecordFormInitialized<LeaveTypeDraft>()),
                        child: LeaveTypeFormPage(guard: guard),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  RegisteredDestination leavePolicyDestination() {
    final guard = FormNavigationGuard();
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'leave-policies',
        moduleId: AppModuleIds.settings,
        name: (l) => l.leavePoliciesNav,
        icon: Icons.rule_folder_outlined,
        route: AppRoutes.leavePolicies,
        requiredPermissions: {AppPermission.leavePolicyView},
        navigationGroup: NavigationGroup.configuration,
        order: 45,
        desktopVisible: false,
        mobileVisible: false,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (leavePolicyRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) =>
                        LeavePolicyListBloc(leavePolicyRepository, auth)
                          ..add(const RecordListStarted()),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.leavePolicies,
              name: 'leave-policies',
              builder: (c, s) => const LeavePolicyListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  onExit: (c, s) => guard.onExit(c),
                  builder: (c, s) => BlocProvider(
                    key: const ValueKey('leave-policy-new'),
                    create: (_) => LeavePolicyFormBloc(
                      leavePolicyRepository!,
                      c.read<LeavePolicyListBloc>().context,
                    )..add(const RecordFormInitialized<LeavePolicyDraft>()),
                    child: LeavePolicyFormPage(
                      guard: guard,
                      repository: leaveRepository!,
                    ),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (c, s) => BlocProvider(
                    key: ValueKey(s.pathParameters['id']),
                    create: (_) => LeavePolicyDetailsBloc(
                      leavePolicyRepository!,
                      c.read<LeavePolicyListBloc>().context,
                      s.pathParameters['id']!,
                    )..add(const RecordDetailsStarted()),
                    child: const LeavePolicyDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      onExit: (c, s) => guard.onExit(c),
                      builder: (c, s) => BlocProvider(
                        key: ValueKey('${s.pathParameters['id']}-edit'),
                        create: (_) => LeavePolicyFormBloc(
                          leavePolicyRepository!,
                          c.read<LeavePolicyListBloc>().context,
                          id: s.pathParameters['id'],
                        )..add(const RecordFormInitialized<LeavePolicyDraft>()),
                        child: LeavePolicyFormPage(
                          guard: guard,
                          repository: leaveRepository!,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  RegisteredDestination holidayDestination() {
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'holidays',
        moduleId: AppModuleIds.settings,
        name: (l) => l.holidaysNav,
        icon: Icons.beach_access_outlined,
        route: AppRoutes.holidays,
        requiredPermissions: {AppPermission.holidayView},
        navigationGroup: NavigationGroup.configuration,
        order: 46,
        desktopVisible: false,
        mobileVisible: false,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (leaveRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) =>
                        HolidayManagementCubit(leaveRepository, auth),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.holidays,
              name: 'holidays',
              builder: (c, s) => const HolidayManagementPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  name: 'holiday-new',
                  builder: (c, s) =>
                      HolidayFormPage(workLocations: workLocationRepository),
                ),
                GoRoute(
                  path: 'import',
                  name: 'holiday-import',
                  builder: (c, s) => const HolidayImportPage(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'holiday-details',
                  builder: (c, s) => const HolidayDetailsPage(),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: 'holiday-edit',
                      builder: (c, s) => HolidayFormPage(
                        workLocations: workLocationRepository,
                        id: s.pathParameters['id'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  final settingsDestinations = <RegisteredDestination>[
    shiftsDestination(),
    workLocationsDestination(),
    attendancePoliciesDestination(),
    if (leaveTypeRepository != null) leaveTypeDestination(),
    if (leavePolicyRepository != null) leavePolicyDestination(),
    if (holidayRepository != null) holidayDestination(),
  ];
  return HrModules(
    modules: [
    AppModule(
      id: AppModuleIds.employees,
      destinations: [
        RegisteredDestination(
          navigation: ErpModule(
            id: 'employees',
            moduleId: AppModuleIds.employees,
            name: (l) => l.shellEmployees,
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            route: AppRoutes.employees,
            navigationGroup: NavigationGroup.people,
            order: 10,
            mobilePriority: 1,
            anyPermissions: {
              AppPermission.employeeViewTeam,
              AppPermission.employeeViewAll,
            },
          ),
          routes: [
            ShellRoute(
              builder: (context, state, child) =>
                  BlocSelector<AuthBloc, AuthState, AuthContext?>(
                    selector: (s) => s.context,
                    builder: (context, auth) {
                      if (auth == null) return const SizedBox.shrink();
                      if (employeeRepository == null) {
                        return AppPage(
                          child: AppErrorState(
                            message: context.l10n.empStorageError,
                          ),
                        );
                      }
                      return BlocProvider(
                        key: ValueKey(auth),
                        create: (_) =>
                            EmployeeListBloc(employeeRepository, auth)
                              ..add(const EmployeeListStarted()),
                        child: child,
                      );
                    },
                  ),
              routes: [
                GoRoute(
                  path: AppRoutes.employees,
                  name: 'employees',
                  builder: (context, state) => const EmployeeListPage(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      name: 'employee-new',
                      onExit: (context, state) => formGuard.onExit(context),
                      builder: (context, state) => BlocProvider(
                        key: const ValueKey('employee-new'),
                        create: (_) => EmployeeFormBloc(
                          employeeRepository!,
                          context.read<EmployeeListBloc>().context,
                        )..add(const EmployeeFormInitialized()),
                        child: EmployeeFormPage(guard: formGuard),
                      ),
                    ),
                    GoRoute(
                      path: ':employeeId',
                      name: 'employee-details',
                      builder: (context, state) => BlocProvider(
                        key: ValueKey(state.pathParameters['employeeId']),
                        create: (_) => EmployeeDetailsBloc(
                          employeeRepository!,
                          context.read<EmployeeListBloc>().context,
                          state.pathParameters['employeeId']!,
                        )..add(const EmployeeDetailsStarted()),
                        child: EmployeeDetailsPage(registry: registry()),
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          name: 'employee-edit',
                          onExit: (context, state) => formGuard.onExit(context),
                          builder: (context, state) => BlocProvider(
                            key: ValueKey(
                              '${state.pathParameters['employeeId']}-edit',
                            ),
                            create: (_) => EmployeeFormBloc(
                              employeeRepository!,
                              context.read<EmployeeListBloc>().context,
                              id: state.pathParameters['employeeId'],
                            )..add(const EmployeeFormInitialized()),
                            child: EmployeeFormPage(guard: formGuard),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    AppModule(
      id: AppModuleIds.attendance,
      destinations: [
        RegisteredDestination(
          navigation: ErpModule(
            id: 'attendance',
            moduleId: AppModuleIds.attendance,
            name: (l) => l.shellAttendance,
            icon: Icons.schedule_outlined,
            selectedIcon: Icons.schedule,
            route: AppRoutes.attendance,
            navigationGroup: NavigationGroup.workforce,
            order: 20,
            mobilePriority: 2,
            anyCapabilities: {
              UserCapability.selfAttendance,
              UserCapability.selfAttendanceHistory,
              UserCapability.teamAttendance,
              UserCapability.companyAttendance,
              UserCapability.approveAttendanceCorrections,
            },
          ),
          routes: [
            GoRoute(
              path: AppRoutes.attendance,
              name: 'attendance',
              // Attendance is one module: non-self users land on the most
              // relevant organizational destination instead of a self screen.
              redirect: (context, state) {
                final account = context.read<AuthBloc>().state.context;
                if (account == null) return null;
                final capabilities = const UserCapabilityResolver()
                    .forAuthContext(account);
                if (capabilities.has(UserCapability.selfAttendance)) {
                  return null;
                }
                if (capabilities.has(UserCapability.teamAttendance)) {
                  return AppRoutes.attendanceTeam;
                }
                if (capabilities.has(UserCapability.companyAttendance)) {
                  return AppRoutes.attendanceAll;
                }
                return AppRoutes.attendanceRequests;
              },
              pageBuilder: (context, state) => AppRouteTransitions.page(
                context,
                state,
                AttendanceModuleScaffold(
                  banner: leaveRepository == null
                      ? null
                      : LeaveTodayBanner(repository: leaveRepository),
                  child: context.read<AttendanceBloc?>() == null
                      ? AppPage(
                          child: AppErrorState(
                            message: context.l10n.attendanceUnavailableTitle,
                          ),
                        )
                      : const AttendanceTodayPage(),
                ),
              ),
            ),
          ],
        ),
        RegisteredDestination(
          navigation: ErpModule(
            id: 'attendance-history',
            moduleId: AppModuleIds.attendance,
            name: (l) => l.historyNav,
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            route: AppRoutes.attendanceHistory,
            navigationGroup: NavigationGroup.workforce,
            order: 21,
            mobilePriority: 3,
            desktopVisible: false,
            mobileVisible: false,
            requiredPermissions: {AppPermission.attendanceViewSelf},
            requiredCapabilities: {UserCapability.selfAttendanceHistory},
          ),
          routes: [
            ShellRoute(
              builder: (context, state, child) =>
                  BlocSelector<AuthBloc, AuthState, AuthContext?>(
                    selector: (s) => s.context,
                    builder: (context, actor) {
                      if (actor == null) return const SizedBox.shrink();
                      final repository =
                          attendanceRepository ??
                          context.read<AttendanceBloc?>()?.repository;
                      if (repository == null) {
                        return AppPage(
                          child: AppErrorState(
                            message: context.l10n.attendanceUnavailableTitle,
                          ),
                        );
                      }
                      return BlocProvider(
                        key: ValueKey(actor),
                        create: (_) =>
                            AttendanceHistoryBloc(repository)
                              ..add(const AttendanceHistoryStarted()),
                        child: child,
                      );
                    },
                  ),
              routes: [
                GoRoute(
                  path: AppRoutes.attendanceHistory,
                  name: 'attendance-history',
                  builder: (c, s) => AttendanceModuleScaffold(
                    child: const AttendanceHistoryPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: ':attendanceDayId',
                      name: 'attendance-day-details',
                      builder: (c, s) => BlocProvider(
                        key: ValueKey(s.pathParameters['attendanceDayId']),
                        create: (_) => AttendanceDayDetailsBloc(
                          c.read<AttendanceHistoryBloc>().repository,
                          s.pathParameters['attendanceDayId']!,
                        )..add(const AttendanceDayDetailsStarted()),
                        child: const AttendanceDayDetailsPage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (correctionRepository != null && attendanceRepository != null)
          RegisteredDestination(
            navigation: ErpModule(
              id: 'attendance-corrections',
              moduleId: AppModuleIds.attendance,
              name: (l) => l.correctionMyRequests,
              icon: Icons.rate_review_outlined,
              route: AppRoutes.attendanceCorrections,
              navigationGroup: NavigationGroup.workforce,
              order: 22,
              desktopVisible: false,
              mobileVisible: false,
              requiredPermissions: {AppPermission.attendanceRequestCorrection},
              requiredCapabilities: {
                UserCapability.requestAttendanceCorrection,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.attendanceCorrections,
                builder: (c, s) => BlocProvider(
                  create: (_) =>
                      AttendanceCorrectionBloc(correctionRepository)
                        ..add(const CorrectionMyStarted()),
                  child: AttendanceModuleScaffold(
                    child: const MyAttendanceCorrectionsPage(),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'new/:attendanceDayId',
                    builder: (c, s) => BlocProvider(
                      key: ValueKey(s.pathParameters['attendanceDayId']),
                      create: (_) =>
                          AttendanceCorrectionBloc(correctionRepository),
                      child: AttendanceCorrectionFormPage(
                        dayId: s.pathParameters['attendanceDayId']!,
                        attendanceRepository: attendanceRepository,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':correctionId',
                    builder: (c, s) => BlocProvider(
                      key: ValueKey(s.pathParameters['correctionId']),
                      create: (_) =>
                          AttendanceCorrectionBloc(correctionRepository)..add(
                            CorrectionDetailsStarted(
                              s.pathParameters['correctionId']!,
                            ),
                          ),
                      child: const AttendanceCorrectionDetailsPage(
                        review: false,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (correctionRepository != null)
          RegisteredDestination(
            navigation: ErpModule(
              id: 'attendance-requests',
              moduleId: AppModuleIds.attendance,
              name: (l) => l.correctionReviewQueue,
              icon: Icons.fact_check_outlined,
              route: AppRoutes.attendanceRequests,
              navigationGroup: NavigationGroup.workforce,
              order: 23,
              desktopVisible: false,
              mobileVisible: false,
              requiredPermissions: {AppPermission.attendanceApprove},
              anyPermissions: {
                AppPermission.attendanceViewTeam,
                AppPermission.attendanceViewAll,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.attendanceRequests,
                builder: (c, s) => BlocProvider(
                  create: (_) =>
                      AttendanceCorrectionBloc(correctionRepository)
                        ..add(const CorrectionQueueStarted()),
                  child: AttendanceModuleScaffold(
                    child: const AttendanceCorrectionQueuePage(),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':correctionId',
                    builder: (c, s) => BlocProvider(
                      key: ValueKey(s.pathParameters['correctionId']),
                      create: (_) =>
                          AttendanceCorrectionBloc(correctionRepository)..add(
                            CorrectionDetailsStarted(
                              s.pathParameters['correctionId']!,
                            ),
                          ),
                      child: const AttendanceCorrectionDetailsPage(
                        review: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (workforceAttendanceRepository != null)
          RegisteredDestination(
            navigation: ErpModule(
              id: 'attendance-team',
              moduleId: AppModuleIds.attendance,
              name: (l) => l.workforceTeam,
              icon: Icons.groups_outlined,
              route: AppRoutes.attendanceTeam,
              navigationGroup: NavigationGroup.workforce,
              order: 24,
              desktopVisible: false,
              mobileVisible: false,
              anyPermissions: {
                AppPermission.attendanceViewTeam,
                AppPermission.attendanceViewAll,
              },
              requiredCapabilities: {UserCapability.teamAttendance},
            ),
            routes: [
              GoRoute(
                path: AppRoutes.attendanceTeam,
                builder: (c, s) => BlocProvider(
                  create: (_) => WorkforceAttendanceBloc(
                    workforceAttendanceRepository,
                    AttendanceScope.team,
                  )..add(const WorkforceAttendanceStarted()),
                  child: AttendanceModuleScaffold(
                    child: const WorkforceAttendancePage(
                      scope: AttendanceScope.team,
                    ),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':employeeId/:attendanceDayId',
                    builder: (c, s) => WorkforceAttendanceDetailsPage(
                      repository: workforceAttendanceRepository,
                      employeeId: s.pathParameters['employeeId']!,
                      dayId: s.pathParameters['attendanceDayId']!,
                      scope: AttendanceScope.team,
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (workforceAttendanceRepository != null)
          RegisteredDestination(
            navigation: ErpModule(
              id: 'attendance-all',
              moduleId: AppModuleIds.attendance,
              name: (l) => l.workforceAll,
              icon: Icons.badge_outlined,
              route: AppRoutes.attendanceAll,
              navigationGroup: NavigationGroup.workforce,
              order: 25,
              requiredPermissions: {AppPermission.attendanceViewAll},
            ),
            routes: [
              GoRoute(
                path: AppRoutes.attendanceAll,
                builder: (c, s) => BlocProvider(
                  create: (_) => WorkforceAttendanceBloc(
                    workforceAttendanceRepository,
                    AttendanceScope.company,
                  )..add(const WorkforceAttendanceStarted()),
                  child: const WorkforceAttendancePage(
                    scope: AttendanceScope.company,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':employeeId/:attendanceDayId',
                    builder: (c, s) => WorkforceAttendanceDetailsPage(
                      repository: workforceAttendanceRepository,
                      employeeId: s.pathParameters['employeeId']!,
                      dayId: s.pathParameters['attendanceDayId']!,
                      scope: AttendanceScope.company,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    ),
    if (leaveRepository != null)
      AppModule(
        id: AppModuleIds.leave,
        destinations: [
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave',
              moduleId: AppModuleIds.leave,
              name: (l) => l.shellLeave,
              icon: Icons.event_available_outlined,
              selectedIcon: Icons.event_available,
              route: AppRoutes.leave,
              navigationGroup: NavigationGroup.workforce,
              order: 25,
              mobilePriority: 4,
              anyCapabilities: {
                UserCapability.requestLeave,
                UserCapability.viewMyLeave,
                UserCapability.viewMyLeaveBalance,
                UserCapability.viewTeamLeave,
                UserCapability.approveTeamLeave,
                UserCapability.viewCompanyLeave,
                UserCapability.approveCompanyLeave,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leave,
                name: 'leave',
                pageBuilder: (context, state) => AppRouteTransitions.page(
                  context,
                  state,
                  BlocSelector<AuthBloc, AuthState, AuthContext?>(
                    selector: (s) => s.context,
                    builder: (context, account) {
                      if (account == null) {
                        return const SizedBox.shrink();
                      }
                      final capabilities = const UserCapabilityResolver()
                          .forAuthContext(account);
                      if (capabilities.has(UserCapability.viewCompanyLeave)) {
                        return BlocProvider(
                          key: ValueKey(account),
                          create: (_) => LeaveOperationsBloc(
                            leaveRepository,
                            account,
                            LeaveRequestScope.company,
                          )..add(const LeaveOperationsStarted()),
                          child: const LeaveModuleScaffold(
                            child: LeaveOverviewPage(company: true),
                          ),
                        );
                      }
                      if (capabilities.has(UserCapability.viewTeamLeave)) {
                        return BlocProvider(
                          key: ValueKey(account),
                          create: (_) => LeaveOperationsBloc(
                            leaveRepository,
                            account,
                            LeaveRequestScope.team,
                          )..add(const LeaveOperationsStarted()),
                          child: const LeaveModuleScaffold(
                            child: LeaveOverviewPage(company: false),
                          ),
                        );
                      }
                      final employee = account.employeeReference;
                      if (employee == null) {
                        return AppPage(
                          child: AppErrorState(
                            message: context.l10n.leaveNoEmployee,
                          ),
                        );
                      }
                      return BlocProvider(
                        key: ValueKey(account),
                        create: (_) => LeaveHomeCubit(
                          leaveRepository,
                          account,
                          employee.id,
                        ),
                        child: const LeaveModuleScaffold(
                          child: LeaveHomePage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          leaveMyRequestsDestination(),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave-request',
              moduleId: AppModuleIds.leave,
              name: (l) => l.leaveNewRequest,
              icon: Icons.add_outlined,
              route: AppRoutes.leaveRequest,
              navigationGroup: NavigationGroup.workforce,
              order: 31,
              desktopVisible: false,
              mobileVisible: false,
              requiredPermissions: {AppPermission.leaveRequest},
              requiredCapabilities: {UserCapability.requestLeave},
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leaveRequest,
                name: 'leave-request',
                builder: (c, s) {
                  final account = c.read<AuthBloc>().state.context!;
                  return BlocProvider(
                    key: ValueKey(account),
                    create: (_) =>
                        LeaveRequestFormBloc(leaveRepository, account)
                          ..add(const LeaveRequestFormStarted()),
                    child: const LeaveRequestFormPage(),
                  );
                },
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave-request-details',
              moduleId: AppModuleIds.leave,
              name: (l) => l.leaveMyRequests,
              icon: Icons.event_note_outlined,
              route: AppRoutes.leaveRequestBase,
              navigationGroup: NavigationGroup.workforce,
              order: 34,
              desktopVisible: false,
              mobileVisible: false,
              anyCapabilities: {
                UserCapability.viewMyLeave,
                UserCapability.viewTeamLeave,
                UserCapability.viewCompanyLeave,
                UserCapability.approveTeamLeave,
                UserCapability.approveCompanyLeave,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leaveRequestBase,
                name: 'leave-request-base',
                redirect: (c, s) => s.uri.path == AppRoutes.leaveRequestBase
                    ? AppRoutes.leaveMyRequests
                    : null,
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'leave-request-details',
                    builder: (c, s) {
                      final account = c.read<AuthBloc>().state.context!;
                      final requestId = s.pathParameters['id']!;
                      return BlocProvider(
                        key: ValueKey(requestId),
                        create: (_) => LeaveRequestDetailsBloc(
                          leaveRepository,
                          account,
                          requestId,
                        )..add(const LeaveRequestDetailsStarted()),
                        child: const LeaveModuleScaffold(
                          child: LeaveRequestDetailsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave-team',
              moduleId: AppModuleIds.leave,
              name: (l) => l.leaveTeam,
              icon: Icons.groups_outlined,
              route: AppRoutes.leaveTeam,
              navigationGroup: NavigationGroup.workforce,
              order: 27,
              desktopVisible: false,
              mobileVisible: false,
              requiredPermissions: {AppPermission.leaveViewTeam},
              requiredCapabilities: {UserCapability.viewTeamLeave},
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leaveTeam,
                name: 'leave-team',
                builder: (c, s) {
                  final account = c.read<AuthBloc>().state.context!;
                  return BlocProvider(
                    key: ValueKey(account),
                    create: (_) => LeaveOperationsBloc(
                      leaveRepository,
                      account,
                      LeaveRequestScope.team,
                    )..add(const LeaveOperationsStarted()),
                    child: const LeaveModuleScaffold(
                      child: LeaveOperationsPage(company: false),
                    ),
                  );
                },
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave-all',
              moduleId: AppModuleIds.leave,
              name: (l) => l.leaveAllNav,
              icon: Icons.badge_outlined,
              route: AppRoutes.leaveAll,
              navigationGroup: NavigationGroup.workforce,
              order: 28,
              desktopVisible: false,
              mobileVisible: false,
              requiredPermissions: {AppPermission.leaveViewAll},
              requiredCapabilities: {UserCapability.viewCompanyLeave},
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leaveAll,
                name: 'leave-all',
                builder: (c, s) {
                  final account = c.read<AuthBloc>().state.context!;
                  return BlocProvider(
                    key: ValueKey(account),
                    create: (_) => LeaveOperationsBloc(
                      leaveRepository,
                      account,
                      LeaveRequestScope.company,
                    )..add(const LeaveOperationsStarted()),
                    child: const LeaveModuleScaffold(
                      child: LeaveOperationsPage(company: true),
                    ),
                  );
                },
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave-approvals',
              moduleId: AppModuleIds.leave,
              name: (l) => l.leaveApprovals,
              icon: Icons.fact_check_outlined,
              route: AppRoutes.leaveApprovals,
              navigationGroup: NavigationGroup.workforce,
              order: 29,
              desktopVisible: false,
              mobileVisible: false,
              anyPermissions: {
                AppPermission.leaveApproveTeam,
                AppPermission.leaveApproveAll,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leaveApprovals,
                name: 'leave-approvals',
                builder: (c, s) {
                  final account = c.read<AuthBloc>().state.context!;
                  return BlocProvider(
                    key: ValueKey(account),
                    create: (_) =>
                        LeaveApprovalsBloc(leaveRepository, account)
                          ..add(const LeaveApprovalsStarted()),
                    child: const LeaveModuleScaffold(
                      child: LeaveApprovalsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave-employee',
              moduleId: AppModuleIds.leave,
              name: (l) => l.leaveEmployeeLeave,
              icon: Icons.person_search_outlined,
              route: AppRoutes.leaveEmployeeBase,
              navigationGroup: NavigationGroup.workforce,
              order: 35,
              desktopVisible: false,
              mobileVisible: false,
              anyCapabilities: {
                UserCapability.viewTeamLeave,
                UserCapability.viewCompanyLeave,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leaveEmployeeBase,
                name: 'leave-employee-base',
                redirect: (c, s) => s.uri.path == AppRoutes.leaveEmployeeBase
                    ? AppRoutes.leaveAll
                    : null,
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'leave-employee',
                    builder: (c, s) {
                      final account = c.read<AuthBloc>().state.context!;
                      final employeeId = s.pathParameters['id']!;
                      return BlocProvider(
                        key: ValueKey(employeeId),
                        create: (_) => EmployeeLeaveBloc(
                          leaveRepository,
                          account,
                          employeeId,
                        )..add(const EmployeeLeaveStarted()),
                        child: const LeaveModuleScaffold(
                          child: EmployeeLeavePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave-balances',
              moduleId: AppModuleIds.leave,
              name: (l) => l.leaveBalancesNav,
              icon: Icons.account_balance_wallet_outlined,
              route: AppRoutes.leaveBalances,
              navigationGroup: NavigationGroup.workforce,
              order: 32,
              desktopVisible: false,
              mobileVisible: false,
              anyCapabilities: {
                UserCapability.viewMyLeaveBalance,
                UserCapability.viewCompanyLeave,
                UserCapability.viewTeamLeave,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leaveBalances,
                name: 'leave-balances',
                builder: (c, s) =>
                    BlocSelector<AuthBloc, AuthState, AuthContext?>(
                      selector: (s) => s.context,
                      builder: (context, account) {
                        if (account == null) {
                          return const SizedBox.shrink();
                        }
                        final employeeId = account.employeeReference?.id;
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) => LeaveBalanceTableBloc(
                                leaveRepository,
                                account,
                              )..add(const LeaveBalanceTableStarted()),
                            ),
                            if (employeeId != null)
                              BlocProvider(
                                create: (_) => LeaveBalancesCubit(
                                  leaveRepository,
                                  account,
                                  employeeId,
                                ),
                              ),
                          ],
                          child: const LeaveModuleScaffold(
                            child: LeaveBalancesPage(),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'leave-calendar',
              moduleId: AppModuleIds.leave,
              name: (l) => l.leaveCalendarNav,
              icon: Icons.calendar_month_outlined,
              route: AppRoutes.leaveCalendar,
              navigationGroup: NavigationGroup.workforce,
              order: 33,
              desktopVisible: false,
              mobileVisible: false,
              anyCapabilities: {
                UserCapability.viewMyLeave,
                UserCapability.viewTeamLeave,
                UserCapability.viewCompanyLeave,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.leaveCalendar,
                name: 'leave-calendar',
                builder: (c, s) {
                  final account = c.read<AuthBloc>().state.context!;
                  return BlocProvider(
                    key: ValueKey(account),
                    create: (_) =>
                        LeaveCalendarCubit(leaveRepository, account)..load(),
                    child: const LeaveModuleScaffold(
                      child: LeaveCalendarPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    AppModule(
      id: AppModuleIds.reports,
      destinations: [
        destination(
          ErpModule(
            id: 'reports',
            moduleId: AppModuleIds.reports,
            name: (l) => l.shellReports,
            icon: Icons.assessment_outlined,
            selectedIcon: Icons.assessment,
            route: AppRoutes.reports,
            navigationGroup: NavigationGroup.insights,
            order: 30,
            requiredPermissions: {AppPermission.attendanceReportView},
            anyPermissions: {
              AppPermission.attendanceViewTeam,
              AppPermission.attendanceViewAll,
            },
            requiredCapabilities: {UserCapability.viewAttendanceReports},
          ),
          (context) {
            final repository = attendanceReportRepository;
            final exportService = attendanceReportExportService;
            if (repository == null || exportService == null) {
              return AppPage(
                child: AppErrorState(message: context.l10n.reportUnavailable),
              );
            }
            final actor = context.read<AuthBloc>().state.context!;
            final scope =
                actor.user.permissions.contains(AppPermission.attendanceViewAll)
                ? AttendanceScope.company
                : AttendanceScope.team;
            return BlocProvider(
              create: (_) =>
                  AttendanceReportBloc(repository, exportService, scope)
                    ..add(const AttendanceReportStarted()),
              child: const AttendanceReportsPage(),
            );
          },
        ),
      ],
    ),
    ],
    settingsDestinations: settingsDestinations,
  );
}