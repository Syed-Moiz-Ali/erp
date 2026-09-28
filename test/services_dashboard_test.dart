import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/services/demo/services_demo_seed.dart';
import 'package:modular_erp/modules/services/overview/data/local_services_dashboard_repository.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/modules/services/overview/presentation/bloc/service_dashboard_cubit.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';

class _FixedClock implements AppClock {
  _FixedClock(this.value);
  DateTime value;
  @override
  DateTime now() => value;
}

AuthContext _ctx({
  required Set<AppPermission> permissions,
  String companyId = 'demo-company',
  String? employeeId,
  String timezone = 'Asia/Dubai',
  bool services = true,
}) {
  final user = UserAccount(
    id: 'test-user-${employeeId ?? 'none'}',
    displayName: 'Test User',
    email: 'test@erp.demo',
    companyId: companyId,
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  );
  return AuthContext(
    user: user,
    company: CompanyContext(
      id: companyId,
      name: 'Company',
      code: 'C',
      timezone: timezone,
      defaultLocale: 'en',
      enabledModules: services ? {'dashboard', 'services'} : {'dashboard'},
    ),
    employeeReference: employeeId == null
        ? null
        : EmployeeReference(
            id: employeeId,
            userAccountId: user.id,
            companyId: companyId,
          ),
  );
}

const _allServices = {
  AppPermission.serviceEnquiryView,
  AppPermission.serviceJobAssignmentViewAll,
  AppPermission.serviceInspectionViewAll,
  AppPermission.serviceMaterialRequestViewAll,
  AppPermission.serviceWorkExecutionViewAll,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late LocalServicesDashboardRepository repository;
  late AppClock clock;
  late AuthContext admin;

  Future<void> seedWorkflow() async {
    final source = DemoAuthSource();
    admin = source.findByScenario(DemoScenario.platformAdmin)!.context;
    await seedEmployees(db);
    await seedServicesDemoData(db, admin, clock);
    await seedServiceEnquiriesDemoData(db, admin, clock);
    await seedServiceJobAssignmentDemoData(db, admin, clock);
    await seedServiceInspectionDemoData(db, admin, clock);
    await seedServiceMaterialRequestDemoData(db, admin, clock);
    await seedServiceWorkExecutionDemoData(db, admin, clock);
  }

  Future<String> firstEmployeeId() async {
    final row =
        await (db.select(db.workforceEmployees)
              ..where((t) => t.companyId.equals('demo-company'))
              ..limit(1))
            .getSingle();
    return row.id;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = const SystemAppClock();
    repository = LocalServicesDashboardRepository(
      db: db,
      clock: clock,
      time: const FixedOffsetCompanyTimeService(),
    );
  });
  tearDown(() => db.close());

  test(
    'no Services permission queries nothing and hides every domain',
    () async {
      await seedWorkflow();
      final snapshot = await repository.load(
        _ctx(permissions: {AppPermission.employeeViewSelf}),
      );
      expect(snapshot.hasAnyData, isFalse);
      expect(snapshot.canViewEnquiries, isFalse);
      expect(snapshot.canViewAssignments, isFalse);
      expect(snapshot.canViewInspections, isFalse);
      expect(snapshot.canViewMaterialRequests, isFalse);
      expect(snapshot.canViewWorkExecutions, isFalse);
      expect(snapshot.attentionItems, isEmpty);
      expect(snapshot.todaySchedule, isEmpty);
      expect(snapshot.recentActivity, isEmpty);
    },
  );

  test('services module disabled yields an empty snapshot', () async {
    await seedWorkflow();
    final snapshot = await repository.load(
      _ctx(permissions: _allServices, services: false),
    );
    expect(snapshot.hasAnyData, isFalse);
    expect(snapshot.canViewEnquiries, isFalse);
  });

  test('enquiry-only user sees enquiry metrics and nothing else', () async {
    await seedWorkflow();
    final snapshot = await repository.load(
      _ctx(permissions: {AppPermission.serviceEnquiryView}),
    );
    expect(snapshot.canViewEnquiries, isTrue);
    expect(snapshot.canViewAssignments, isFalse);
    expect(snapshot.canViewInspections, isFalse);
    expect(snapshot.canViewMaterialRequests, isFalse);
    expect(snapshot.canViewWorkExecutions, isFalse);
    expect(snapshot.kpiCount, 1);
    expect(snapshot.openEnquiriesCount, greaterThan(0));
    expect(snapshot.workflowStages.map((s) => s.stage), [
      ServiceWorkflowStage.enquiry,
    ]);
    expect(
      snapshot.attentionItems.every(
        (i) => i.kind == ServicesAttentionKind.openEnquiryUnassigned,
      ),
      isTrue,
    );
  });

  test(
    'ASSIGNED field employee emphasises My Work without company leakage',
    () async {
      await seedWorkflow();
      final employeeId = await firstEmployeeId();
      final assigned = _ctx(
        permissions: {
          AppPermission.serviceEnquiryView,
          AppPermission.serviceJobAssignmentViewAssigned,
          AppPermission.serviceInspectionViewAssigned,
          AppPermission.serviceWorkExecutionViewAssigned,
        },
        employeeId: employeeId,
      );
      final all = _ctx(permissions: _allServices);
      final assignedSnapshot = await repository.load(assigned);
      final allSnapshot = await repository.load(all);

      expect(assignedSnapshot.scope, ServicesDashboardScope.assigned);
      expect(assignedSnapshot.myWork, isNotEmpty);
      expect(
        assignedSnapshot.scheduledAssignmentsCount,
        lessThanOrEqualTo(allSnapshot.scheduledAssignmentsCount),
      );
      expect(
        assignedSnapshot.recentActivity.every((e) => e.entityId.isNotEmpty),
        isTrue,
      );
    },
  );

  test('TEAM scope restricts records and exposes team workload', () async {
    await seedWorkflow();
    final employeeId = await firstEmployeeId();
    final team = _ctx(
      permissions: {
        AppPermission.serviceJobAssignmentViewTeam,
        AppPermission.serviceInspectionViewTeam,
        AppPermission.serviceWorkExecutionViewTeam,
      },
      employeeId: employeeId,
    );
    final all = _ctx(permissions: _allServices);
    final teamSnapshot = await repository.load(team);
    final allSnapshot = await repository.load(all);
    expect(teamSnapshot.scope, ServicesDashboardScope.team);
    expect(teamSnapshot.teamWorkload, isNotEmpty);
    expect(
      teamSnapshot.scheduledAssignmentsCount,
      lessThanOrEqualTo(allSnapshot.scheduledAssignmentsCount),
    );
  });

  test('ALL scope is company-wide only', () async {
    await seedWorkflow();
    final snapshot = await repository.load(_ctx(permissions: _allServices));
    expect(snapshot.scope, ServicesDashboardScope.all);
    expect(snapshot.canViewWorkExecutions, isTrue);
    expect(snapshot.openEnquiriesCount, greaterThan(0));
    expect(
      snapshot.recentActivity.every((e) => e.eventType.startsWith('services.')),
      isTrue,
    );
  });

  test('company switch recomputes and never leaks another company', () async {
    await seedWorkflow();
    final companyA = await repository.load(_ctx(permissions: _allServices));
    expect(companyA.hasAnyData, isTrue);
    final companyB = await repository.load(
      _ctx(permissions: _allServices, companyId: 'other-company'),
    );
    expect(companyB.hasAnyData, isFalse);
    expect(companyB.openEnquiriesCount, 0);
  });

  test(
    'empty dashboard is intentional when no operational records exist',
    () async {
      admin = DemoAuthSource()
          .findByScenario(DemoScenario.platformAdmin)!
          .context;
      await seedEmployees(db);
      await seedServicesDemoData(db, admin, clock);
      final snapshot = await repository.load(_ctx(permissions: _allServices));
      expect(snapshot.hasAnyData, isFalse);
      expect(snapshot.openEnquiriesCount, 0);
      expect(snapshot.attentionItems, isEmpty);
    },
  );

  test('Today uses the company timezone, not the device timezone', () async {
    admin = DemoAuthSource()
        .findByScenario(DemoScenario.platformAdmin)!
        .context;
    await seedEmployees(db);
    await seedServicesDemoData(db, admin, clock);
    // 22:00 UTC is already the next day in Asia/Dubai (+04:00).
    final fixed = _FixedClock(DateTime.utc(2026, 9, 27, 22, 0));
    repository = LocalServicesDashboardRepository(
      db: db,
      clock: fixed,
      time: const FixedOffsetCompanyTimeService(),
    );
    final snapshot = await repository.load(
      _ctx(permissions: _allServices, timezone: 'Asia/Dubai'),
    );
    expect(snapshot.today, DateTime.utc(2026, 9, 28));
  });

  test('Material Request is optional: completed work needs no request', () async {
    await seedWorkflow();
    // A completed Work Execution exists whose source inspection has no request.
    final row = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM service_work_executions w "
          'LEFT JOIN service_material_requests r ON r.source_inspection_id=w.source_inspection_id AND r.company_id=w.company_id '
          "WHERE w.company_id='demo-company' AND w.status='completed' AND r.id IS NULL",
        )
        .getSingle();
    expect(row.read<int>('c'), greaterThan(0));

    final snapshot = await repository.load(_ctx(permissions: _allServices));
    expect(
      snapshot.workflowStages.any(
        (s) => s.stage == ServiceWorkflowStage.workExecution,
      ),
      isTrue,
    );
    expect(
      snapshot.workflowStages.any(
        (s) => s.stage == ServiceWorkflowStage.materialRequest,
      ),
      isTrue,
    );
    // No attention rule demands a material request for completed work.
    expect(
      snapshot.attentionItems.any(
        (i) =>
            i.kind == ServicesAttentionKind.activeWorkLine &&
            i.reference == 'WE-000002',
      ),
      isFalse,
    );
  });

  test('Material Received never drives dashboard workflow logic', () async {
    await seedWorkflow();
    final snapshot = await repository.load(_ctx(permissions: _allServices));
    // demo-enq-2 has Material Received = No and no assignment; it must surface
    // only as an un-assigned enquiry, never as a material requirement.
    final unassigned = snapshot.attentionItems.where(
      (i) => i.kind == ServicesAttentionKind.openEnquiryUnassigned,
    );
    expect(unassigned.any((i) => i.reference == 'ENQ-000002'), isTrue);
    expect(
      snapshot.attentionItems.any(
        (i) =>
            i.kind == ServicesAttentionKind.openMaterialRequest &&
            i.reference.contains('ENQ'),
      ),
      isFalse,
    );
  });

  test('large data stays bounded (no full-history loading)', () async {
    admin = DemoAuthSource()
        .findByScenario(DemoScenario.platformAdmin)!
        .context;
    await seedEmployees(db);
    await seedServicesDemoData(db, admin, clock);
    final now = clock.now();
    await db.transaction(() async {
      for (var i = 0; i < 600; i++) {
        await db
            .into(db.serviceEnquiries)
            .insert(
              ServiceEnquiriesCompanion.insert(
                id: 'bulk-$i',
                companyId: 'demo-company',
                enquiryNumber: 'ENQ-B${i.toString().padLeft(5, '0')}',
                customerId: 'demo-cus-abc',
                siteId: 'demo-site-abc-1',
                serviceTypeId: 'demo-st-electrical',
                complaintTypeId: 'demo-ct-power',
                priorityId: 'demo-pr-normal',
                ticketTypeId: 'demo-tt-complaint',
                description: '',
                status: 'open',
                partySnapshot: '{}',
                createdAt: now.subtract(Duration(minutes: i)),
                updatedAt: now.subtract(Duration(minutes: i)),
                createdByUserId: admin.user.id,
                updatedByUserId: admin.user.id,
                syncStatus: 'synced',
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
    final stopwatch = Stopwatch()..start();
    final snapshot = await repository.load(_ctx(permissions: _allServices));
    stopwatch.stop();
    expect(snapshot.openEnquiriesCount, 600);
    // The dashboard returns bounded, fixed-size sections regardless of volume.
    expect(snapshot.attentionItems.length, lessThanOrEqualTo(6));
    expect(snapshot.recentActivity.length, lessThanOrEqualTo(8));
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
  });

  test('a live grant change recomputes the dashboard', () async {
    await seedWorkflow();
    final restricted = _ctx(permissions: {AppPermission.serviceEnquiryView});
    final cubit = ServiceDashboardCubit(repository, restricted)..start();
    addTearDown(cubit.close);
    await _waitUntil(() => cubit.state.snapshot != null);
    expect(cubit.state.snapshot!.canViewAssignments, isFalse);

    cubit.updateContext(_ctx(permissions: _allServices));
    await _waitUntil(() => cubit.state.snapshot?.canViewAssignments == true);
    expect(cubit.state.snapshot!.canViewWorkExecutions, isTrue);
  });
}

Future<void> _waitUntil(bool Function() predicate) async {
  for (var i = 0; i < 200; i++) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('condition not reached in time');
}
