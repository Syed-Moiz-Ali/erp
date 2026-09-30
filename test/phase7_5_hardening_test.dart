import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/dashboard/application/hr_dashboard_contributor.dart';
import 'package:modular_erp/modules/hr/dashboard/data/local_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/leave/data/local_leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_today_banner.dart';
import 'package:modular_erp/modules/services/configuration/data/local_service_master_repository.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master.dart';
import 'package:modular_erp/modules/services/configuration/presentation/bloc/service_master_blocs.dart';
import 'package:modular_erp/modules/services/configuration/presentation/pages/service_master_form_page.dart';
import 'package:modular_erp/modules/services/customers/data/local_service_customer_repository.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_scope.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_scope.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_scope.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/overview/data/local_services_dashboard_repository.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/modules/services/sites/data/local_service_site_repository.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site.dart';
import 'package:modular_erp/modules/services/teams/data/local_service_team_repository.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team.dart';
import 'package:modular_erp/modules/services/work_executions/data/local_service_work_execution_repository.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';

class _FixedClock implements AppClock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

class _StubAuth implements AuthRepository {
  @override
  Future<Result<AuthContext?>> restoreSession() => throw UnimplementedError();
  @override
  Future<Result<AuthContext?>> checkSession() => throw UnimplementedError();
  @override
  Future<Result<AuthContext>> login(AuthIdentifier identifier, String p) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> logout() => throw UnimplementedError();
  @override
  Future<Result<void>> requestPasswordReset(AuthIdentifier identifier) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> changePassword(String c, String n) =>
      throw UnimplementedError();
  @override
  Stream<AuthContext?> get sessionChanges => const Stream.empty();
  @override
  Future<void> dispose() async {}
}

class _StubLeaveRepository implements LeaveRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Directory implements WorkforceDirectory {
  _Directory(this.refs);
  final Map<String, WorkforcePersonRef> refs;
  @override
  Future<WorkforcePersonRef?> getEmployeeReference(
    String employeeId, {
    bool includeInactive = false,
  }) async => refs[employeeId];
  @override
  Future<List<WorkforcePersonRef>> getEmployees(Iterable<String> ids) async => [
    for (final id in ids)
      if (refs[id] != null) refs[id]!,
  ];
  @override
  Future<List<WorkforcePersonRef>> searchAssignable({
    String query = '',
    int limit = 50,
  }) async => refs.values.where((r) => r.isActive).toList();
  @override
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  }) => Stream.value(const []);
}

const _servicesAll = {
  AppPermission.serviceCustomerView,
  AppPermission.serviceCustomerCreate,
  AppPermission.serviceCustomerEdit,
  AppPermission.serviceCustomerDeactivate,
  AppPermission.serviceSiteView,
  AppPermission.serviceSiteCreate,
  AppPermission.serviceSiteEdit,
  AppPermission.serviceSiteDeactivate,
  AppPermission.serviceTeamView,
  AppPermission.serviceTeamManage,
  AppPermission.serviceTypeView,
  AppPermission.serviceTypeManage,
  AppPermission.serviceRootCauseView,
  AppPermission.serviceRootCauseManage,
  AppPermission.serviceChargeResponsibilityView,
  AppPermission.serviceChargeResponsibilityManage,
  AppPermission.serviceMaterialRequestPurposeView,
  AppPermission.serviceMaterialRequestPurposeManage,
  AppPermission.serviceJobAssignmentViewAll,
  AppPermission.serviceInspectionViewAll,
  AppPermission.serviceMaterialRequestViewAll,
  AppPermission.serviceWorkExecutionViewAll,
};

AuthContext _ctx({
  Set<AppPermission> permissions = const {},
  String companyId = 'c1',
  String? employeeId,
  Set<String> modules = const {
    'dashboard',
    'services',
    'employees',
    'attendance',
    'leave',
  },
  String timezone = 'UTC',
}) => AuthContext(
  user: UserAccount(
    id: 'u1',
    displayName: 'User',
    email: 'u@erp.demo',
    companyId: companyId,
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: companyId,
    name: 'Company',
    code: 'C',
    timezone: timezone,
    defaultLocale: 'en',
    enabledModules: modules,
  ),
  employeeReference: employeeId == null
      ? null
      : EmployeeReference(
          id: employeeId,
          userAccountId: 'u-$employeeId',
          companyId: companyId,
        ),
);

Future<void> _insertRow(
  AppDatabase db,
  String table,
  Map<String, Object?> values,
) => db.customInsert(
  'INSERT OR IGNORE INTO $table (${values.keys.join(',')}) '
  'VALUES (${values.keys.map((_) => '?').join(',')})',
  variables: [for (final v in values.values) Variable(v)],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('action permission never upgrades View scope', () {
    const scopedActions = <AppPermission>[
      AppPermission.serviceJobAssignmentCreate,
      AppPermission.serviceJobAssignmentEdit,
      AppPermission.serviceJobAssignmentCancel,
      AppPermission.serviceInspectionCreate,
      AppPermission.serviceInspectionEdit,
      AppPermission.serviceInspectionComplete,
      AppPermission.serviceInspectionCancel,
      AppPermission.serviceMaterialRequestCreate,
      AppPermission.serviceMaterialRequestEdit,
      AppPermission.serviceMaterialRequestCancel,
      AppPermission.serviceMaterialRequestPrint,
      AppPermission.serviceWorkExecutionCreate,
      AppPermission.serviceWorkExecutionEdit,
      AppPermission.serviceWorkExecutionPerform,
      AppPermission.serviceWorkExecutionComplete,
      AppPermission.serviceWorkExecutionCancel,
    ];

    test('no scoped action grant normalizes to a *ViewAll permission', () {
      const viewAlls = {
        AppPermission.serviceJobAssignmentViewAll,
        AppPermission.serviceInspectionViewAll,
        AppPermission.serviceMaterialRequestViewAll,
        AppPermission.serviceWorkExecutionViewAll,
      };
      for (final action in scopedActions) {
        final normalized = normalizePermissionGrants([action]);
        expect(
          normalized.intersection(viewAlls),
          isEmpty,
          reason: '$action must never imply a ViewAll grant',
        );
      }
    });

    test('ASSIGNED stays ASSIGNED with perform/edit/complete grants', () {
      final assigned = PermissionSet({
        AppPermission.serviceWorkExecutionViewAssigned,
        AppPermission.serviceWorkExecutionPerform,
        AppPermission.serviceWorkExecutionEdit,
        AppPermission.serviceWorkExecutionComplete,
      });
      expect(
        const ServiceWorkExecutionScopeResolver().resolve(
          _ctx(permissions: assigned.values, employeeId: 'e1'),
        ),
        ServiceWorkExecutionScope.assigned,
      );
    });

    test('TEAM stays TEAM with complete/print grants', () {
      final team = PermissionSet({
        AppPermission.serviceInspectionViewTeam,
        AppPermission.serviceInspectionComplete,
        AppPermission.serviceMaterialRequestViewTeam,
        AppPermission.serviceMaterialRequestPrint,
      });
      final ctx = _ctx(permissions: team.values, employeeId: 'e1');
      expect(
        const ServiceInspectionScopeResolver().resolve(ctx),
        ServiceInspectionScope.team,
      );
      expect(
        const ServiceMaterialRequestScopeResolver().resolve(ctx),
        ServiceMaterialRequestScope.team,
      );
    });

    test('ALL exists only when explicitly granted', () {
      final context = _ctx(
        permissions: {
          AppPermission.serviceJobAssignmentViewAll,
          AppPermission.serviceJobAssignmentCreate,
          AppPermission.serviceJobAssignmentEdit,
        },
      );
      expect(
        const ServiceJobAssignmentScopeResolver().resolve(context),
        ServiceJobAssignmentScope.all,
      );
      final actionOnly = _ctx(
        permissions: {AppPermission.serviceJobAssignmentCreate},
      );
      expect(
        const ServiceJobAssignmentScopeResolver().resolve(actionOnly),
        ServiceJobAssignmentScope.none,
      );
    });
  });

  group('security matrix (repository object scope)', () {
    late AppDatabase db;
    late LocalServiceWorkExecutionRepository executions;
    final now = DateTime.utc(2026, 6, 1, 9);

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final fixed = _FixedClock(DateTime.utc(2026, 6, 1, 9));
      final numbers = LocalDocumentNumberService(db, fixed);
      final activity = LocalActivityRepository(db);
      final directory = _Directory({
        'e1': const WorkforcePersonRef(
          id: 'e1',
          name: 'Ahmed',
          employeeCode: 'EMP-1',
        ),
        'e2': const WorkforcePersonRef(
          id: 'e2',
          name: 'Sara',
          employeeCode: 'EMP-2',
        ),
      });
      executions = LocalServiceWorkExecutionRepository(
        db,
        fixed,
        numbers,
        activity,
        LocalAttachmentRepository(db, fixed),
        directory,
        const FixedOffsetCompanyTimeService(),
      );
      await _insertRow(db, 'service_work_executions', {
        'id': 'we1',
        'company_id': 'c1',
        'execution_number': 'WE-000001',
        'execution_date': now,
        'source_inspection_id': 'ins1',
        'source_job_assignment_id': 'as1',
        'source_enquiry_id': 'enq1',
        'status': 'pending',
        'created_at': now,
        'updated_at': now,
        'created_by_user_id': 'u1',
        'updated_by_user_id': 'u1',
        'sync_status': 'synced',
      });
      await _insertRow(db, 'service_work_executions', {
        'id': 'we2',
        'company_id': 'c1',
        'execution_number': 'WE-000002',
        'execution_date': now,
        'source_inspection_id': 'ins2',
        'source_job_assignment_id': 'as2',
        'source_enquiry_id': 'enq2',
        'status': 'pending',
        'created_at': now,
        'updated_at': now,
        'created_by_user_id': 'u1',
        'updated_by_user_id': 'u1',
        'sync_status': 'synced',
      });
      await _insertRow(db, 'service_work_execution_lines', {
        'id': 'wl1',
        'company_id': 'c1',
        'work_execution_id': 'we1',
        'line_number': 1,
        'work': 'Repair',
        'employee_id': 'e1',
        'created_at': now,
        'updated_at': now,
      });
      await _insertRow(db, 'service_work_execution_lines', {
        'id': 'wl2',
        'company_id': 'c1',
        'work_execution_id': 'we2',
        'line_number': 1,
        'work': 'Repair',
        'employee_id': 'e2',
        'created_at': now,
        'updated_at': now,
      });
    });
    tearDown(() => db.close());

    test('CASE A: View ASSIGNED + Perform works on assigned only', () async {
      final actor = _ctx(
        permissions: {
          AppPermission.serviceWorkExecutionViewAssigned,
          AppPermission.serviceWorkExecutionPerform,
        },
        employeeId: 'e1',
      );
      final assigned = await executions.getExecution(actor, 'we1');
      expect((assigned as Success<dynamic>).value, isNotNull);
      final unrelated = await executions.getExecution(actor, 'we2');
      expect((unrelated as Success<dynamic>).value, isNull);

      expect(
        await executions.startWorkLine(actor, 'we1', 'wl1'),
        isA<Success<dynamic>>(),
      );
      expect(
        await executions.endWorkLine(actor, 'we1', 'wl1'),
        isA<Success<dynamic>>(),
      );
      final deniedStart = await executions.startWorkLine(actor, 'we2', 'wl2');
      expect(deniedStart, isA<Failed<dynamic>>());
    });

    test('CASE A: Perform without a View grant cannot see or act', () async {
      final actor = _ctx(
        permissions: {AppPermission.serviceWorkExecutionPerform},
        employeeId: 'e1',
      );
      // Without a real View grant the record is not even readable...
      expect(
        await executions.getExecution(actor, 'we1'),
        isA<Failed<dynamic>>(),
      );
      // ...and the action cannot target it.
      expect(
        await executions.startWorkLine(actor, 'we1', 'wl1'),
        isA<Failed<dynamic>>(),
      );
    });

    test('CASE D: View ALL + action spans the whole company', () async {
      final actor = _ctx(
        permissions: {
          AppPermission.serviceWorkExecutionViewAll,
          AppPermission.serviceWorkExecutionPerform,
        },
      );
      expect(
        (await executions.getExecution(actor, 'we2') as Success<dynamic>).value,
        isNotNull,
      );
      expect(
        await executions.startWorkLine(actor, 'we2', 'wl2'),
        isA<Success<dynamic>>(),
      );
    });
  });

  group('create does not mean edit', () {
    late AppDatabase db;
    late LocalServiceCustomerRepository customers;
    late LocalServiceSiteRepository sites;
    final now = DateTime.utc(2026, 6, 1);

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final clock = _FixedClock(now);
      final numbers = LocalDocumentNumberService(db, clock);
      final activity = LocalActivityRepository(db);
      customers = LocalServiceCustomerRepository(db, clock, numbers, activity);
      sites = LocalServiceSiteRepository(db, clock, numbers, activity);
    });
    tearDown(() => db.close());

    test('customer create-only cannot edit or deactivate', () async {
      final admin = _ctx(permissions: _servicesAll);
      final created =
          (await customers.saveCustomer(
                    admin,
                    const ServiceCustomerDraft(
                      name: 'ABC',
                      mobile: '+971500000001',
                    ),
                  )
                  as Success<ServiceCustomer>)
              .value;
      final creator = _ctx(permissions: {AppPermission.serviceCustomerCreate});
      expect(
        await customers.saveCustomer(
          creator,
          const ServiceCustomerDraft(name: 'New', mobile: '+971500000002'),
        ),
        isA<Success<ServiceCustomer>>(),
      );
      expect(
        await customers.saveCustomer(
          creator,
          const ServiceCustomerDraft(name: 'X', mobile: '+971500000003'),
          id: created.id,
        ),
        isA<Failed<ServiceCustomer>>(),
      );
      expect(
        await customers.setActive(creator, created.id, false),
        isA<Failed<void>>(),
      );
    });

    test('customer edit-only edits without requiring create', () async {
      final admin = _ctx(permissions: _servicesAll);
      final created =
          (await customers.saveCustomer(
                    admin,
                    const ServiceCustomerDraft(
                      name: 'ABC',
                      mobile: '+971500000001',
                    ),
                  )
                  as Success<ServiceCustomer>)
              .value;
      final editor = _ctx(
        permissions: {
          AppPermission.serviceCustomerView,
          AppPermission.serviceCustomerEdit,
        },
      );
      expect(
        await customers.saveCustomer(
          editor,
          const ServiceCustomerDraft(name: 'ABC 2', mobile: '+971500000001'),
          id: created.id,
        ),
        isA<Success<ServiceCustomer>>(),
      );
    });

    test('site create-only cannot edit or deactivate', () async {
      final admin = _ctx(permissions: _servicesAll);
      final customer =
          (await customers.saveCustomer(
                    admin,
                    const ServiceCustomerDraft(
                      name: 'ABC',
                      mobile: '+971500000001',
                    ),
                  )
                  as Success<ServiceCustomer>)
              .value;
      final site =
          (await sites.saveSite(
                    admin,
                    ServiceSiteDraft(
                      customerId: customer.id,
                      siteName: 'Tower 1',
                      addressLine1: 'Main Rd',
                      city: 'Dubai',
                    ),
                  )
                  as Success<ServiceSite>)
              .value;
      final creator = _ctx(permissions: {AppPermission.serviceSiteCreate});
      expect(
        await sites.saveSite(
          creator,
          ServiceSiteDraft(
            customerId: customer.id,
            siteName: 'Tower 2',
            addressLine1: 'Road',
            city: 'Dubai',
          ),
        ),
        isA<Success<ServiceSite>>(),
      );
      expect(
        await sites.saveSite(
          creator,
          ServiceSiteDraft(
            customerId: customer.id,
            siteName: 'Tower 1 X',
            addressLine1: 'Main Rd',
            city: 'Dubai',
          ),
          id: site.id,
        ),
        isA<Failed<ServiceSite>>(),
      );
      expect(
        await sites.setActive(creator, site.id, false),
        isA<Failed<void>>(),
      );
    });
  });

  group('service team member validation', () {
    late AppDatabase db;
    late LocalServiceTeamRepository teams;
    final now = DateTime.utc(2026, 6, 1);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      final clock = _FixedClock(now);
      final numbers = LocalDocumentNumberService(db, clock);
      final activity = LocalActivityRepository(db);
      teams = LocalServiceTeamRepository(
        db,
        clock,
        numbers,
        activity,
        _Directory({
          'e1': const WorkforcePersonRef(
            id: 'e1',
            name: 'Ali',
            employeeCode: 'EMP-1',
          ),
          'inactive': const WorkforcePersonRef(
            id: 'inactive',
            name: 'Gone',
            employeeCode: 'EMP-9',
            isActive: false,
          ),
        }),
      );
    });
    tearDown(() => db.close());

    test('rejects unknown/cross-company and newly-inactive members', () async {
      final admin = _ctx(permissions: _servicesAll);
      final unknown = await teams.saveTeam(
        admin,
        const ServiceTeamDraft(name: 'Team', memberIds: ['ghost']),
      );
      expect(
        (unknown as Failed<ServiceTeam>).failure.code,
        'servicesTeamMemberUnknown',
      );

      // A cross-company id resolves to null through the company-scoped contract.
      final cross = await teams.saveTeam(
        admin,
        const ServiceTeamDraft(name: 'Team', memberIds: ['other-company-e']),
      );
      expect(
        (cross as Failed<ServiceTeam>).failure.code,
        'servicesTeamMemberUnknown',
      );

      final inactive = await teams.saveTeam(
        admin,
        const ServiceTeamDraft(
          name: 'Team',
          leadEmployeeId: 'inactive',
          memberIds: ['inactive'],
        ),
      );
      expect(
        (inactive as Failed<ServiceTeam>).failure.code,
        'servicesTeamMemberInactive',
      );

      expect(
        await teams.saveTeam(
          admin,
          const ServiceTeamDraft(name: 'Team', leadEmployeeId: 'e1'),
        ),
        isA<Success<ServiceTeam>>(),
      );
    });

    test('team mutations require Manage', () async {
      final viewer = _ctx(permissions: {AppPermission.serviceTeamView});
      final denied = await teams.saveTeam(
        viewer,
        const ServiceTeamDraft(name: 'Team', memberIds: ['e1']),
      );
      expect(denied, isA<Failed<ServiceTeam>>());
    });
  });

  group('HR dashboard works outside DemoAuth', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('demo-disabled repository still loads permitted data', () async {
      final repository = LocalDashboardRepository(demoEnabled: false);
      final context = _ctx(
        permissions: {AppPermission.attendanceViewSelf},
        employeeId: 'e1',
      );
      final result = await repository.load(context);
      expect(result, isA<Success<DashboardSummary>>());
    });

    test('demo and non-demo both contribute without demo_disabled', () async {
      for (final enabled in [true, false]) {
        final repository = LocalDashboardRepository(demoEnabled: enabled);
        final context = _ctx(permissions: {AppPermission.attendanceViewAll});
        final result = await repository.load(context);
        expect(result, isA<Success<DashboardSummary>>());
      }
    });
  });

  group('leave widget requires self leave permission', () {
    late AppLocalizations l10n;
    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('absent without leaveViewSelf, present with it', () async {
      final contributor = HrDashboardContributor(
        repository: LocalDashboardRepository(demoEnabled: false),
        leaveRepository: _StubLeaveRepository(),
        demoWidgets: true,
      );
      final without = DashboardCapabilityContext(
        auth: _ctx(
          permissions: const {AppPermission.attendanceViewSelf},
          employeeId: 'e1',
          modules: const {'dashboard', 'attendance', 'leave'},
        ),
        l10n: l10n,
      );
      final withoutContribution = await contributor.load(without);
      expect(withoutContribution.myDay.whereType<LeaveTodayBanner>(), isEmpty);

      final withPermission = DashboardCapabilityContext(
        auth: _ctx(
          permissions: const {
            AppPermission.attendanceViewSelf,
            AppPermission.leaveViewSelf,
          },
          employeeId: 'e1',
          modules: const {'dashboard', 'attendance', 'leave'},
        ),
        l10n: l10n,
      );
      final withContribution = await contributor.load(withPermission);
      expect(
        withContribution.myDay.whereType<LeaveTodayBanner>(),
        hasLength(1),
      );
    });

    test(
      'dayOverride hides personal leave at the repository boundary',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final leave = LocalLeaveRepository(
          db,
          _StubAuth(),
          _FixedClock(DateTime.utc(2026, 6, 1)),
        );
        final without = _ctx(
          permissions: const {AppPermission.attendanceViewSelf},
          employeeId: 'e1',
          modules: const {'leave'},
        );
        final denied = await leave.dayOverride(
          without,
          'e1',
          DateTime.utc(2026, 6, 1),
        );
        expect((denied as Success<LeaveWorkdayOverlay?>).value, isNull);

        final withPermission = _ctx(
          permissions: const {AppPermission.leaveViewSelf},
          employeeId: 'e1',
          modules: const {'leave'},
        );
        expect(
          await leave.dayOverride(
            withPermission,
            'e1',
            DateTime.utc(2026, 6, 1),
          ),
          isA<Success<LeaveWorkdayOverlay?>>(),
        );
      },
    );
  });

  group('universal dashboard company date', () {
    test(
      'header today comes from the injected company-time provider',
      () async {
        final coordinator = UniversalDashboardCoordinator(
          const [],
          clock: _FixedClock(DateTime.utc(2026, 9, 27, 22)),
          businessToday: (auth) => DateTime.utc(2026, 9, 28),
        );
        final snapshot = await coordinator.load(
          DashboardCapabilityContext(
            auth: _ctx(permissions: const {}),
            l10n: await AppLocalizations.delegate.load(const Locale('en')),
          ),
        );
        expect(snapshot.today, DateTime.utc(2026, 9, 28));
        expect(snapshot.generatedAt, DateTime.utc(2026, 9, 27, 22));
      },
    );
  });

  group('dashboard KPI queries and errors', () {
    late AppDatabase db;
    late LocalServicesDashboardRepository repository;
    final today = DateTime.utc(2026, 6, 1);

    Future<void> seedKpis() async {
      final now = DateTime.utc(2026, 6, 1, 9);
      // Two active assignments, each assigned to e1 and team t1. Distinct
      // enquiries because at most one active assignment per enquiry is allowed.
      for (final (id, enquiry) in [('a1', 'enq1'), ('a2', 'enq2')]) {
        await _insertRow(db, 'service_job_assignments', {
          'id': id,
          'company_id': 'c1',
          'assignment_number': 'JA-$id',
          'assignment_date': now,
          'source_enquiry_id': enquiry,
          'scheduled_visit_date': today,
          'status': 'active',
          'created_at': now,
          'updated_at': now,
          'created_by_user_id': 'u1',
          'updated_by_user_id': 'u1',
          'sync_status': 'synced',
        });
        await _insertRow(db, 'service_job_assignment_lines', {
          'id': 'line-$id',
          'company_id': 'c1',
          'assignment_id': id,
          'line_number': 1,
          'work': 'Repair',
          'assigned_employee_id': 'e1',
          'assigned_team_id': 't1',
          'status': 'active',
          'created_at': now,
          'updated_at': now,
          'created_by_user_id': 'u1',
          'updated_by_user_id': 'u1',
          'sync_status': 'synced',
        });
      }
      await _insertRow(db, 'service_team_members', {
        'id': 'tm1',
        'company_id': 'c1',
        'team_id': 't1',
        'employee_id': 'e1',
        'status': 'active',
        'created_at': now,
        'created_by_user_id': 'u1',
      });
      // One pending inspection on a1.
      await _insertRow(db, 'service_inspections', {
        'id': 'i1',
        'company_id': 'c1',
        'inspection_number': 'INS-1',
        'inspection_date': now,
        'source_job_assignment_id': 'a1',
        'source_enquiry_id': 'enq1',
        'visit_date': today,
        'visit_minutes': 600,
        'technician_employee_id': 'e1',
        'root_cause_id': 'rc1',
        'charge_responsibility_id': 'ch1',
        'status': 'pending',
        'created_at': now,
        'updated_at': now,
        'created_by_user_id': 'u1',
        'updated_by_user_id': 'u1',
        'sync_status': 'synced',
      });
      // Three open material requests originating from i1.
      for (final id in ['m1', 'm2', 'm3']) {
        await _insertRow(db, 'service_material_requests', {
          'id': id,
          'company_id': 'c1',
          'request_number': 'MR-$id',
          'request_date': today,
          'source_inspection_id': 'i1',
          'source_job_assignment_id': 'a1',
          'source_enquiry_id': 'enq1',
          'status': 'open',
          'created_at': now,
          'updated_at': now,
          'created_by_user_id': 'u1',
          'updated_by_user_id': 'u1',
          'sync_status': 'synced',
        });
      }
      // One in-progress and one completed-today work execution. Distinct source
      // inspections because at most one non-cancelled execution per inspection.
      for (final (id, status, source, assignment, enquiry) in [
        ('w1', 'inProgress', 'i1', 'a1', 'enq1'),
        ('w2', 'completed', 'i2', 'a2', 'enq2'),
      ]) {
        await _insertRow(db, 'service_work_executions', {
          'id': id,
          'company_id': 'c1',
          'execution_number': 'WE-$id',
          'execution_date': status == 'completed' ? today : now,
          'source_inspection_id': source,
          'source_job_assignment_id': assignment,
          'source_enquiry_id': enquiry,
          'status': status,
          'created_at': now,
          'updated_at': now,
          'created_by_user_id': 'u1',
          'updated_by_user_id': 'u1',
          'sync_status': 'synced',
        });
        await _insertRow(db, 'service_work_execution_lines', {
          'id': 'wl-$id',
          'company_id': 'c1',
          'work_execution_id': id,
          'line_number': 1,
          'work': 'Repair',
          'employee_id': 'e1',
          'service_team_id': 't1',
          'created_at': now,
          'updated_at': now,
        });
      }
    }

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = LocalServicesDashboardRepository(
        db: db,
        clock: _FixedClock(DateTime.utc(2026, 6, 1, 9)),
        time: const FixedOffsetCompanyTimeService(),
      );
      await seedKpis();
    });
    tearDown(() => db.close());

    void expectKpis(ServicesDashboardSnapshot snapshot) {
      expect(snapshot.scheduledAssignmentsCount, 2, reason: 'assignments');
      expect(snapshot.pendingInspectionsCount, 1, reason: 'inspections');
      expect(snapshot.openMaterialRequestsCount, 3, reason: 'material');
      expect(snapshot.workInProgressCount, 1, reason: 'in progress');
      expect(snapshot.completedTodayCount, 1, reason: 'completed today');
    }

    test('ALL scope returns the deterministic KPI counts', () async {
      final snapshot = await repository.load(
        _ctx(
          permissions: {
            AppPermission.serviceJobAssignmentViewAll,
            AppPermission.serviceInspectionViewAll,
            AppPermission.serviceMaterialRequestViewAll,
            AppPermission.serviceWorkExecutionViewAll,
          },
        ),
      );
      expectKpis(snapshot);
    });

    test('ASSIGNED scope returns the deterministic KPI counts', () async {
      final snapshot = await repository.load(
        _ctx(
          permissions: {
            AppPermission.serviceJobAssignmentViewAssigned,
            AppPermission.serviceInspectionViewAssigned,
            AppPermission.serviceMaterialRequestViewAssigned,
            AppPermission.serviceWorkExecutionViewAssigned,
          },
          employeeId: 'e1',
        ),
      );
      expectKpis(snapshot);
    });

    test('TEAM scope returns the deterministic KPI counts', () async {
      final snapshot = await repository.load(
        _ctx(
          permissions: {
            AppPermission.serviceJobAssignmentViewTeam,
            AppPermission.serviceInspectionViewTeam,
            AppPermission.serviceMaterialRequestViewTeam,
            AppPermission.serviceWorkExecutionViewTeam,
          },
          employeeId: 'e1',
        ),
      );
      expectKpis(snapshot);
    });

    test(
      'a failed projection throws a typed error, never a zero count',
      () async {
        await db.customStatement('DROP TABLE service_job_assignments');
        await expectLater(
          repository.load(
            _ctx(permissions: {AppPermission.serviceJobAssignmentViewAll}),
          ),
          throwsA(isA<ServicesDashboardQueryException>()),
        );
      },
    );
  });

  group('pagination totals', () {
    late AppDatabase db;
    late LocalServiceCustomerRepository customers;
    late LocalServiceSiteRepository sites;
    late LocalServiceTeamRepository teams;
    late LocalServiceMasterRepository masters;
    final now = DateTime.utc(2026, 6, 1);

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final clock = _FixedClock(now);
      final numbers = LocalDocumentNumberService(db, clock);
      final activity = LocalActivityRepository(db);
      final directory = _Directory({
        'e1': const WorkforcePersonRef(
          id: 'e1',
          name: 'Ali',
          employeeCode: 'EMP-1',
        ),
      });
      customers = LocalServiceCustomerRepository(db, clock, numbers, activity);
      sites = LocalServiceSiteRepository(db, clock, numbers, activity);
      teams = LocalServiceTeamRepository(
        db,
        clock,
        numbers,
        activity,
        directory,
      );
      masters = LocalServiceMasterRepository(db, clock, activity);
      for (var i = 0; i < 53; i++) {
        await _insertRow(db, 'service_customers', {
          'id': 'c$i',
          'company_id': 'c1',
          'customer_code': 'CUS-${i.toString().padLeft(4, '0')}',
          'name': 'Customer ${i.toString().padLeft(3, '0')}',
          'kind': 'company',
          'mobile': '+9715000${i.toString().padLeft(4, '0')}',
          'status': 'active',
          'created_at': now,
          'updated_at': now,
          'created_by_user_id': 'u1',
          'updated_by_user_id': 'u1',
          'sync_status': 'synced',
        });
      }
      await _insertRow(db, 'service_customers', {
        'id': 'cus0',
        'company_id': 'c1',
        'customer_code': 'CUS-BASE',
        'name': 'Base',
        'kind': 'company',
        'mobile': '+971500000000',
        'status': 'active',
        'created_at': now,
        'updated_at': now,
        'created_by_user_id': 'u1',
        'updated_by_user_id': 'u1',
        'sync_status': 'synced',
      });
      for (var i = 0; i < 45; i++) {
        await _insertRow(db, 'service_sites', {
          'id': 's$i',
          'company_id': 'c1',
          'customer_id': 'cus0',
          'site_code': 'SITE-${i.toString().padLeft(4, '0')}',
          'site_name': 'Site ${i.toString().padLeft(3, '0')}',
          'address_line1': 'Road',
          'city': 'Dubai',
          'status': 'active',
          'created_at': now,
          'updated_at': now,
          'created_by_user_id': 'u1',
          'updated_by_user_id': 'u1',
          'sync_status': 'synced',
        });
      }
      for (var i = 0; i < 25; i++) {
        await _insertRow(db, 'service_teams', {
          'id': 't$i',
          'company_id': 'c1',
          'team_code': 'TEAM-${i.toString().padLeft(4, '0')}',
          'name': 'Team ${i.toString().padLeft(3, '0')}',
          'status': 'active',
          'created_at': now,
          'updated_at': now,
          'created_by_user_id': 'u1',
          'updated_by_user_id': 'u1',
          'sync_status': 'synced',
        });
      }
      for (var i = 0; i < 15; i++) {
        await _insertRow(db, 'service_types', {
          'id': 'st$i',
          'company_id': 'c1',
          'code': 'ST-${i.toString().padLeft(4, '0')}',
          'name': 'Type ${i.toString().padLeft(3, '0')}',
          'status': 'active',
          'created_at': now,
          'updated_at': now,
          'sync_status': 'synced',
        });
      }
    });
    tearDown(() => db.close());

    test('customers report accurate totals across pages', () async {
      final context = _ctx(permissions: _servicesAll);
      final expected = [20, 20, 14];
      for (var page = 0; page < expected.length; page++) {
        final result =
            (await customers
                        .watchCustomers(context, page: page, pageSize: 20)
                        .first
                    as Success<ServiceCustomerPage>)
                .value;
        expect(result.items, hasLength(expected[page]));
        expect(result.total, 54);
        expect(result.filtered, 54);
      }
    });

    test('sites report accurate totals', () async {
      final context = _ctx(permissions: _servicesAll);
      final page0 =
          (await sites.watchSites(context, page: 0, pageSize: 20).first
                  as Success<ServiceSitePage>)
              .value;
      expect(page0.items, hasLength(20));
      expect(page0.total, 45);
      final page2 =
          (await sites.watchSites(context, page: 2, pageSize: 20).first
                  as Success<ServiceSitePage>)
              .value;
      expect(page2.items, hasLength(5));
      expect(page2.total, 45);
    });

    test('teams report accurate totals', () async {
      final context = _ctx(permissions: _servicesAll);
      final page0 =
          (await teams.watchTeams(context, page: 0, pageSize: 10).first
                  as Success<ServiceTeamPage>)
              .value;
      expect(page0.items, hasLength(10));
      expect(page0.total, 25);
      final page2 =
          (await teams.watchTeams(context, page: 2, pageSize: 10).first
                  as Success<ServiceTeamPage>)
              .value;
      expect(page2.items, hasLength(5));
      expect(page2.total, 25);
    });

    test('masters report accurate totals', () async {
      final context = _ctx(permissions: _servicesAll);
      final page0 =
          (await masters
                      .watchList(
                        ServiceMasterKind.serviceType,
                        context,
                        page: 0,
                        pageSize: 10,
                      )
                      .first
                  as Success<ServiceMasterPage>)
              .value;
      expect(page0.items, hasLength(10));
      expect(page0.total, 15);
      final page1 =
          (await masters
                      .watchList(
                        ServiceMasterKind.serviceType,
                        context,
                        page: 1,
                        pageSize: 10,
                      )
                      .first
                  as Success<ServiceMasterPage>)
              .value;
      expect(page1.items, hasLength(5));
      expect(page1.total, 15);
    });
  });

  group('route guards and settings visibility', () {
    late AppDatabase db;
    late ModuleRegistry registry;
    late NavigationResolver resolver;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final clock = _FixedClock(DateTime.utc(2026, 6, 1));
      final numbers = LocalDocumentNumberService(db, clock);
      final activity = LocalActivityRepository(db);
      final directory = _Directory(const {});
      registry = createErpRegistry(
        _StubAuth(),
        serviceCustomerRepository: LocalServiceCustomerRepository(
          db,
          clock,
          numbers,
          activity,
        ),
        serviceSiteRepository: LocalServiceSiteRepository(
          db,
          clock,
          numbers,
          activity,
        ),
        serviceTeamRepository: LocalServiceTeamRepository(
          db,
          clock,
          numbers,
          activity,
          directory,
        ),
        serviceMasterRepository: LocalServiceMasterRepository(
          db,
          clock,
          activity,
        ),
        workforceDirectory: directory,
        activityRepository: activity,
        database: db,
        clock: clock,
        companyTimeService: const FixedOffsetCompanyTimeService(),
      );
      resolver = NavigationResolver(registry);
    });
    tearDown(() => db.close());

    AuthContext withPerms(Set<AppPermission> permissions) =>
        _ctx(permissions: permissions);

    test('customer/site/team mutation routes require the right permission', () {
      final customerView = withPerms({AppPermission.serviceCustomerView});
      expect(
        resolver.routeAccess(ServicesRoutes.customers, customerView),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.customer('abc'), customerView),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.customersNew, customerView),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.customerEdit('abc'), customerView),
        RouteAccess.unauthorized,
      );
      final customerCreate = withPerms({AppPermission.serviceCustomerCreate});
      expect(
        resolver.routeAccess(ServicesRoutes.customersNew, customerCreate),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.customers, customerCreate),
        RouteAccess.unauthorized,
      );

      final siteView = withPerms({AppPermission.serviceSiteView});
      expect(
        resolver.routeAccess(ServicesRoutes.site('abc'), siteView),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.sitesNew, siteView),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.siteEdit('abc'), siteView),
        RouteAccess.unauthorized,
      );

      final teamView = withPerms({AppPermission.serviceTeamView});
      expect(
        resolver.routeAccess(ServicesRoutes.team('abc'), teamView),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.teamsNew, teamView),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.teamEdit('abc'), teamView),
        RouteAccess.unauthorized,
      );
      final teamManage = withPerms({AppPermission.serviceTeamManage});
      expect(
        resolver.routeAccess(ServicesRoutes.teamsNew, teamManage),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.teamEdit('abc'), teamManage),
        RouteAccess.allowed,
      );
    });

    test('master detail is view-only; edit/new require manage', () {
      final view = withPerms({AppPermission.serviceRootCauseView});
      expect(
        resolver.routeAccess(ServicesRoutes.rootCauses, view),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.rootCause('abc'), view),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.rootCauseEdit('abc'), view),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.rootCausesNew, view),
        RouteAccess.unauthorized,
      );
      final manage = withPerms({AppPermission.serviceRootCauseManage});
      expect(
        resolver.routeAccess(ServicesRoutes.rootCauseEdit('abc'), manage),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(ServicesRoutes.rootCausesNew, manage),
        RouteAccess.allowed,
      );
    });

    test(
      'Services Settings appears for Root Cause / Charge Responsibility',
      () {
        final rootCause = resolver.resolve(
          _ctx(permissions: const {}).company,
          PermissionSet(const {AppPermission.serviceRootCauseView}),
        );
        expect(
          rootCause.destinations.map((d) => d.id),
          contains('services-settings'),
        );
        expect(
          resolver.routeAccess(
            ServicesRoutes.settings,
            withPerms({AppPermission.serviceRootCauseView}),
          ),
          RouteAccess.allowed,
        );
        expect(
          resolver.routeAccess(
            ServicesRoutes.settings,
            withPerms({AppPermission.serviceChargeResponsibilityView}),
          ),
          RouteAccess.allowed,
        );
        expect(
          resolver.routeAccess(
            ServicesRoutes.settings,
            withPerms({AppPermission.employeeViewSelf}),
          ),
          RouteAccess.unauthorized,
        );
      },
    );
  });

  group('master read-only form', () {
    testWidgets('read-only detail page has no Save action', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final clock = _FixedClock(DateTime.utc(2026, 6, 1));
      final masters = LocalServiceMasterRepository(
        db,
        clock,
        LocalActivityRepository(db),
      );
      final admin = _ctx(permissions: _servicesAll);
      final created =
          (await masters.save(
                    ServiceMasterKind.rootCause,
                    admin,
                    const ServiceMasterDraft(code: 'ELEC', name: 'Electrical'),
                  )
                  as Success<ServiceMasterRecord>)
              .value;
      final cubit = ServiceMasterFormCubit(
        masters,
        ServiceMasterKind.rootCause,
        admin,
        created.id,
      );
      await cubit.init();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(locale: const Locale('en')),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<ServiceMasterFormCubit>.value(
              value: cubit,
              child: const ServiceMasterFormPage(
                kind: ServiceMasterKind.rootCause,
                id: 'x',
                readOnly: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Save'), findsNothing);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
