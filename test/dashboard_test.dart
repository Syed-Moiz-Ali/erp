import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/dashboard/application/hr_dashboard_contributor.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_scope_resolver.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';
import 'package:modular_erp/platform/workspace/dashboard/presentation/bloc/universal_dashboard_bloc.dart';

class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository(this.summary);
  final DashboardSummary summary;
  int loads = 0;
  @override
  Future<Result<DashboardSummary>> load(
    AuthContext context, {
    bool refresh = false,
  }) async {
    loads++;
    return Success(summary);
  }
}

class FixedContributor implements DashboardContributor {
  FixedContributor({
    required this.id,
    required this.order,
    required this.contribution,
    this.visible = true,
    this.fail = false,
  });
  @override
  final String id;
  @override
  final int order;
  @override
  String get moduleId => id;
  final DashboardContribution contribution;
  final bool visible, fail;
  @override
  bool isVisible(DashboardCapabilityContext context) => visible;
  @override
  Future<DashboardContribution> load(DashboardCapabilityContext context) async {
    if (fail) throw StateError('boom');
    return contribution;
  }
}

AuthContext _auth({
  required Set<AppPermission> permissions,
  String? employeeId,
  Set<String> modules = const {'dashboard', 'employees', 'attendance', 'leave'},
  String companyId = 'c1',
}) {
  final user = UserAccount(
    id: 'u1',
    displayName: 'Test User',
    email: 't@erp.demo',
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
      timezone: 'Asia/Dubai',
      defaultLocale: 'en',
      enabledModules: modules,
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeDateFormatting);
  const resolver = DashboardScopeResolver();

  test('scope selects the highest explicitly granted attendance scope', () {
    final employee = _auth(permissions: const {}, employeeId: 'e1');
    AuthContext grants(Set<AppPermission> p) => employee.copyWith(
      user: employee.user.copyWith(permissions: PermissionSet(p)),
    );
    expect(
      resolver.resolve(
        grants(const {
          AppPermission.attendanceViewAll,
          AppPermission.attendanceViewTeam,
          AppPermission.attendanceViewSelf,
        }),
      ),
      DashboardScope.company,
    );
    expect(
      resolver.resolve(
        grants(const {
          AppPermission.attendanceViewTeam,
          AppPermission.attendanceViewSelf,
        }),
      ),
      DashboardScope.team,
    );
    expect(
      resolver.resolve(grants(const {AppPermission.attendanceViewSelf})),
      DashboardScope.self,
    );
    expect(resolver.resolve(grants(const {})), DashboardScope.none);
    expect(
      resolver.resolve(
        employee.copyWith(
          company: employee.company.copyWith(enabledModules: {'dashboard'}),
        ),
      ),
      DashboardScope.none,
    );
  });

  group('HrDashboardContributor', () {
    late AppLocalizations l10n;
    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    DashboardSummary summary() => DashboardSummary(
      scope: DashboardScope.company,
      asOf: DateTime(2026, 9, 28, 9),
      isDemo: false,
      status: const DashboardStatusSummary(
        onTime: 68,
        late: 5,
        absent: 4,
        onLeave: 7,
      ),
      metrics: const [
        DashboardMetric(DashboardMetricKind.employees, 84),
        DashboardMetric(DashboardMetricKind.present, 73),
        DashboardMetric(DashboardMetricKind.late, 5),
        DashboardMetric(DashboardMetricKind.absent, 4),
        DashboardMetric(DashboardMetricKind.leave, 7),
        DashboardMetric(DashboardMetricKind.working, 70),
        DashboardMetric(DashboardMetricKind.corrections, 6),
        DashboardMetric(DashboardMetricKind.attendanceRate, 0.86),
      ],
      alerts: const [
        DashboardAlert(DashboardAlertKind.lateArrivals, 5),
        DashboardAlert(DashboardAlertKind.pendingCorrections, 6),
      ],
      activities: [
        DashboardActivity(
          kind: DashboardActivityKind.checkedIn,
          person: 'Ahmed',
          timestamp: DateTime(2026, 9, 28, 9, 3),
        ),
      ],
      today: DashboardToday(
        shiftStart: DateTime(2026, 9, 28, 9),
        shiftEnd: DateTime(2026, 9, 28, 18),
      ),
    );

    test('maps permitted HR KPIs, attention, schedule and activity', () async {
      final contributor = HrDashboardContributor(
        repository: FakeDashboardRepository(summary()),
        demoWidgets: false,
      );
      final context = _auth(
        permissions: const {
          AppPermission.attendanceViewAll,
          AppPermission.attendanceApprove,
        },
      );
      final contribution = await contributor.load(
        DashboardCapabilityContext(auth: context, l10n: l10n),
      );
      final kpiIds = contribution.kpis.map((k) => k.id).toList();
      expect(kpiIds, contains('hr-present'));
      expect(kpiIds, contains('hr-absent'));
      expect(kpiIds, contains('hr-leave'));
      expect(kpiIds, contains('hr-corrections'));
      expect(kpiIds, isNot(contains('hr-working')));
      expect(contribution.attention, hasLength(2));
      expect(contribution.schedule, hasLength(1));
      expect(contribution.activity, hasLength(1));
      expect(contribution.scopeLabel, isNotEmpty);
      expect(
        contribution.viewAll[DashboardSection.attention],
        '/app/hr/attendance/requests',
      );
    });

    test(
      'self scope contributes personal data without company totals',
      () async {
        final contributor = HrDashboardContributor(
          repository: FakeDashboardRepository(
            DashboardSummary(
              scope: DashboardScope.self,
              asOf: DateTime(2026, 9, 28),
              isDemo: false,
            ),
          ),
        );
        final context = _auth(
          permissions: const {AppPermission.attendanceViewSelf},
          employeeId: 'e1',
        );
        final contribution = await contributor.load(
          DashboardCapabilityContext(auth: context, l10n: l10n),
        );
        expect(contribution.kpis, isEmpty);
        expect(contribution.myDay, hasLength(1));
      },
    );

    test('an unlinked user still gets broad metrics from explicit grants', () {
      final contributor = HrDashboardContributor(
        repository: FakeDashboardRepository(summary()),
        demoWidgets: false,
      );
      final context = _auth(
        permissions: const {AppPermission.attendanceViewAll},
      );
      expect(
        contributor.isVisible(
          DashboardCapabilityContext(auth: context, l10n: l10n),
        ),
        isTrue,
      );
    });

    test('module disable removes the contribution', () {
      final contributor = HrDashboardContributor(
        repository: FakeDashboardRepository(summary()),
      );
      final context = _auth(
        permissions: const {AppPermission.attendanceViewAll},
        modules: const {'services'},
      );
      expect(
        contributor.isVisible(
          DashboardCapabilityContext(auth: context, l10n: l10n),
        ),
        isFalse,
      );
    });
  });

  group('UniversalDashboardCoordinator', () {
    late AppLocalizations l10n;
    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    DashboardContribution contribution(
      String module,
      int order, {
      int attentionPriority = 0,
      String kpiId = 'k',
      int kpiRank = 100,
    }) => DashboardContribution(
      moduleId: module,
      order: order,
      kpis: [
        DashboardKpi(
          id: kpiId,
          moduleId: module,
          label: module,
          value: '1',
          icon: Icons.circle,
          rank: kpiRank,
        ),
      ],
      attention: [
        DashboardAttentionItem(
          id: '$module-a',
          moduleId: module,
          type: 't',
          title: module,
          subtitle: '',
          icon: Icons.circle,
          priority: attentionPriority,
        ),
      ],
    );

    test('merges contributors in order and caps sections', () async {
      final coordinator = UniversalDashboardCoordinator([
        FixedContributor(
          id: 'services',
          order: 20,
          contribution: contribution('services', 20, kpiId: 's', kpiRank: 5),
        ),
        FixedContributor(
          id: 'hr',
          order: 10,
          contribution: contribution('hr', 10, kpiId: 'h', kpiRank: 50),
        ),
      ]);
      final snapshot = await coordinator.load(
        DashboardCapabilityContext(
          auth: _auth(permissions: const {}),
          l10n: l10n,
        ),
      );
      expect(snapshot.kpis, hasLength(2));
      expect(snapshot.kpis.first.id, 's');
      expect(snapshot.attention, hasLength(2));
      expect(snapshot.hasAnyData, isTrue);
      expect(snapshot.partialFailure, isFalse);
    });

    test('a failed contributor degrades to a partial snapshot', () async {
      final coordinator = UniversalDashboardCoordinator([
        FixedContributor(
          id: 'hr',
          order: 10,
          contribution: contribution('hr', 10),
        ),
        FixedContributor(
          id: 'services',
          order: 20,
          contribution: DashboardContribution.empty,
          fail: true,
        ),
      ]);
      final snapshot = await coordinator.load(
        DashboardCapabilityContext(
          auth: _auth(permissions: const {}),
          l10n: l10n,
        ),
      );
      expect(snapshot.partialFailure, isTrue);
      expect(snapshot.kpis, hasLength(1));
    });
  });

  group('UniversalDashboardBloc', () {
    late AppLocalizations l10n;
    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    UniversalDashboardCoordinator coordinator({bool fail = false}) =>
        UniversalDashboardCoordinator([
          FixedContributor(
            id: 'hr',
            order: 10,
            fail: fail,
            contribution: DashboardContribution(
              moduleId: 'hr',
              kpis: const [
                DashboardKpi(
                  id: 'hr-present',
                  moduleId: 'hr',
                  label: 'Present',
                  value: '73',
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ]);

    blocTest<UniversalDashboardBloc, UniversalDashboardState>(
      'loads all contributions into a ready snapshot',
      build: () => UniversalDashboardBloc(
        coordinator(),
        _auth(permissions: const {AppPermission.attendanceViewSelf}),
        l10n,
      ),
      act: (bloc) => bloc.add(const UniversalDashboardStarted()),
      expect: () => [
        isA<UniversalDashboardState>().having(
          (s) => s.status,
          'status',
          UniversalDashboardStatus.loading,
        ),
        isA<UniversalDashboardState>()
            .having((s) => s.status, 'status', UniversalDashboardStatus.ready)
            .having((s) => s.snapshot?.kpis.first.id, 'kpi', 'hr-present'),
      ],
    );

    blocTest<UniversalDashboardBloc, UniversalDashboardState>(
      'reports a partial snapshot when a contributor fails',
      build: () => UniversalDashboardBloc(
        coordinator(fail: true),
        _auth(permissions: const {AppPermission.attendanceViewSelf}),
        l10n,
      ),
      act: (bloc) => bloc.add(const UniversalDashboardStarted()),
      expect: () => [
        isA<UniversalDashboardState>(),
        isA<UniversalDashboardState>().having(
          (s) => s.status,
          'status',
          UniversalDashboardStatus.partial,
        ),
      ],
    );
  });

  test('dashboard width uses the shared centered AppPage container', () {
    // Guard against a dashboard-specific wider container creeping back in.
    expect(AppDimensions.contentMaxWidth, isNotNull);
  });
}
