import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_theme.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/auth/domain/policies/account_role_templates.dart';
import 'package:modular_erp/features/auth/domain/policies/user_capability.dart';
import 'package:modular_erp/features/employees/domain/employee.dart';
import 'package:modular_erp/features/profile/application/my_profile_cubit.dart';
import 'package:modular_erp/features/profile/presentation/my_profile_page.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'attendance_test.dart' show MockAuth;
import 'employee_test.dart' show employeeContext, MockEmployeeRepository;

const _resolver = UserCapabilityResolver();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('user capability resolver', () {
    test('super admin without employee has no self attendance', () {
      final c = _resolver.forAuthContext(employeeContext(AppRole.superAdmin));
      expect(c.hasLinkedEmployee, isFalse);
      expect(c.has(UserCapability.selfAttendance), isFalse);
      expect(c.has(UserCapability.selfAttendanceHistory), isFalse);
      expect(c.has(UserCapability.teamAttendance), isFalse);
      expect(c.has(UserCapability.requestAttendanceCorrection), isFalse);
      expect(c.has(UserCapability.companyAttendance), isTrue);
      expect(c.has(UserCapability.manageEmployees), isTrue);
      expect(c.has(UserCapability.viewAttendanceReports), isTrue);
    });

    test('company admin without employee has no self attendance', () {
      final c = _resolver.forAuthContext(employeeContext(AppRole.companyAdmin));
      expect(c.hasLinkedEmployee, isFalse);
      expect(c.has(UserCapability.selfAttendance), isFalse);
      expect(c.has(UserCapability.companyAttendance), isTrue);
    });

    test('HR without employee manages workforce but not self attendance', () {
      final c = _resolver.forAuthContext(employeeContext(AppRole.hr));
      expect(c.hasLinkedEmployee, isTrue); // demo HR is linked
      expect(c.has(UserCapability.selfAttendance), isTrue);
      final unlinked = _resolver.resolve(
        company: employeeContext(AppRole.hr).company,
        permissions: employeeContext(AppRole.hr).user.permissions,
      );
      expect(unlinked.has(UserCapability.selfAttendance), isFalse);
      expect(unlinked.has(UserCapability.companyAttendance), isTrue);
      expect(unlinked.has(UserCapability.approveAttendanceCorrections), isTrue);
    });

    test('manager linked gets team + self but not company', () {
      final c = _resolver.forAuthContext(employeeContext(AppRole.manager));
      expect(c.has(UserCapability.selfAttendance), isTrue);
      expect(c.has(UserCapability.teamAttendance), isTrue);
      expect(c.has(UserCapability.companyAttendance), isFalse);
    });

    test('manager without employee cannot resolve a team', () {
      final manager = employeeContext(AppRole.manager);
      final c = _resolver.resolve(
        company: manager.company,
        permissions: manager.user.permissions,
      );
      expect(c.has(UserCapability.teamAttendance), isFalse);
      expect(c.has(UserCapability.selfAttendance), isFalse);
    });

    test('employee self only', () {
      final c = _resolver.forAuthContext(employeeContext(AppRole.employee));
      expect(c.has(UserCapability.selfAttendance), isTrue);
      expect(c.has(UserCapability.teamAttendance), isFalse);
      expect(c.has(UserCapability.companyAttendance), isFalse);
    });

    test('attendanceViewAll does not imply self attendance', () {
      final base = employeeContext(AppRole.companyAdmin);
      final c = _resolver.resolve(
        company: base.company,
        permissions: PermissionSet([AppPermission.attendanceViewAll]),
      );
      expect(c.has(UserCapability.companyAttendance), isTrue);
      expect(c.has(UserCapability.selfAttendance), isFalse);
      expect(c.has(UserCapability.selfAttendanceHistory), isFalse);
    });

    test('attendanceViewTeam does not imply attendanceViewAll', () {
      final base = employeeContext(AppRole.manager);
      final c = _resolver.resolve(
        company: base.company,
        permissions: PermissionSet([AppPermission.attendanceViewTeam]),
        employee: base.employeeReference,
      );
      expect(c.has(UserCapability.teamAttendance), isTrue);
      expect(c.has(UserCapability.companyAttendance), isFalse);
    });

    test('linked admin with self permission regains self attendance', () {
      final base = employeeContext(AppRole.companyAdmin);
      final linked = base.copyWith(
        employeeReference: EmployeeReference(
          id: 'employee-company',
          userAccountId: base.user.id,
          companyId: base.company.id,
        ),
      );
      final c = _resolver.resolve(
        company: base.company,
        permissions: PermissionSet([AppPermission.attendanceViewSelf]),
        employee: linked.employeeReference,
      );
      expect(c.has(UserCapability.selfAttendance), isTrue);
    });
  });

  group('navigation capability gating', () {
    ModuleRegistry registry() => ModuleRegistry.fromModules([
      AppModule(
        id: 'dashboard',
        destinations: [
          RegisteredDestination(
            navigation: ErpModule(
              id: 'dashboard',
              name: (l) => l.shellDashboard,
              icon: Icons.home,
              route: '/app/dashboard',
            ),
            routes: [
              GoRoute(
                path: '/app/dashboard',
                builder: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
      AppModule(
        id: 'attendance',
        destinations: [
          RegisteredDestination(
            navigation: ErpModule(
              id: 'self-attendance',
              moduleId: 'attendance',
              name: (l) => l.shellAttendance,
              icon: Icons.schedule,
              route: '/app/attendance',
              requiredPermissions: {AppPermission.attendanceViewSelf},
              requiredCapabilities: {UserCapability.selfAttendance},
            ),
            routes: [
              GoRoute(
                path: '/app/attendance',
                builder: (_, __) => const SizedBox(),
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'all-attendance',
              moduleId: 'attendance',
              name: (l) => l.workforceAll,
              icon: Icons.badge,
              route: '/app/attendance/all',
              requiredPermissions: {AppPermission.attendanceViewAll},
            ),
            routes: [
              GoRoute(
                path: '/app/attendance/all',
                builder: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    ]);

    test('unlinked admin sees all attendance but not self attendance', () {
      final nav = NavigationResolver(registry());
      final admin = employeeContext(AppRole.companyAdmin);
      final destinations = nav
          .resolve(
            admin.company,
            admin.user.permissions,
            employee: admin.employeeReference,
          )
          .destinations
          .map((d) => d.id);
      expect(destinations, contains('all-attendance'));
      expect(destinations, isNot(contains('self-attendance')));
    });

    test('linked employee sees self attendance only', () {
      final nav = NavigationResolver(registry());
      final employee = employeeContext(AppRole.employee);
      final destinations = nav
          .resolve(
            employee.company,
            employee.user.permissions,
            employee: employee.employeeReference,
          )
          .destinations
          .map((d) => d.id);
      expect(destinations, contains('self-attendance'));
      expect(destinations, isNot(contains('all-attendance')));
    });
  });

  Widget host(Locale locale, Widget child) => MaterialApp(
    locale: locale,
    theme: AppTheme.light(locale: locale),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  Employee employeeFixture() => Employee(
    id: 'employee-employee',
    companyId: 'demo-company',
    employeeCode: 'EMP-0012',
    firstName: 'Noor',
    lastName: 'Ali',
    email: 'noor@erp.demo',
    phone: '+15550001005',
    departmentId: 'dept-1',
    designationId: 'desig-1',
    joiningDate: DateTime(2024, 1, 15),
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  testWidgets('unlinked admin profile shows no employment section', (t) async {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      final auth = MockAuth();
      when(
        () => auth.checkSession(),
      ).thenAnswer((_) async => Success(employeeContext(AppRole.companyAdmin)));
      when(() => auth.sessionChanges).thenAnswer((_) => const Stream.empty());
      final cubit = MyProfileCubit(auth, null)..start();
      addTearDown(cubit.close);
      await t.pumpWidget(
        host(
          locale,
          BlocProvider.value(value: cubit, child: const MyProfilePage()),
        ),
      );
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      final l = AppLocalizations.of(t.element(find.byType(MyProfilePage)));
      expect(find.text(l.profileAccountAccess), findsOneWidget);
      expect(find.text(l.empEmployment), findsNothing);
      expect(find.text(l.profileMyAttendance), findsNothing);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('linked employee profile shows employment and self attendance', (
    t,
  ) async {
    final auth = MockAuth();
    final employee = employeeFixture();
    final context = employeeContext(AppRole.employee);
    when(() => auth.checkSession()).thenAnswer((_) async => Success(context));
    when(() => auth.sessionChanges).thenAnswer((_) => const Stream.empty());
    final repo = MockEmployeeRepository();
    when(() => repo.getReferences(context)).thenAnswer(
      (_) async => Success(
        EmployeeReferences(
          departments: const [WorkforceReference('dept-1', 'Engineering')],
          designations: const [WorkforceReference('desig-1', 'Engineer')],
          managers: const [],
          shifts: const [],
          workLocations: const [],
          attendancePolicies: const [],
        ),
      ),
    );
    when(
      () => repo.watchEmployee(context, employee.id),
    ).thenAnswer((_) => Stream.value(Success(employee)));
    final cubit = MyProfileCubit(auth, repo)..start();
    addTearDown(cubit.close);
    await t.pumpWidget(
      host(
        const Locale('en'),
        BlocProvider.value(value: cubit, child: const MyProfilePage()),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    final l = AppLocalizations.of(t.element(find.byType(MyProfilePage)));
    expect(find.text(l.empEmployment), findsOneWidget);
    expect(find.text(l.profileMyAttendance), findsOneWidget);
    expect(find.text('EMP-0012'), findsWidgets);
    expect(t.takeException(), isNull);
  });

  test('role templates withhold self attendance from platform admins', () {
    final superAdmin = permissionsForRole(AppRole.superAdmin);
    final companyAdmin = permissionsForRole(AppRole.companyAdmin);
    expect(superAdmin.contains(AppPermission.attendanceViewSelf), isFalse);
    expect(companyAdmin.contains(AppPermission.attendanceViewSelf), isFalse);
    expect(superAdmin.contains(AppPermission.attendanceViewAll), isTrue);
    expect(companyAdmin.contains(AppPermission.userManage), isTrue);
  });
}
