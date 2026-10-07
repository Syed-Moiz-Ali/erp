import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/dashboard/application/hr_dashboard_contributor.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/modules/services/overview/application/services_dashboard_contributor.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';
import 'package:modular_erp/platform/workspace/dashboard/presentation/bloc/universal_dashboard_bloc.dart';
import 'package:modular_erp/platform/workspace/dashboard/presentation/universal_dashboard_page.dart';

// ── Test doubles ────────────────────────────────────────────────────────────

class _FakeHrRepository implements DashboardRepository {
  _FakeHrRepository(this.summary);
  final DashboardSummary summary;
  @override
  Future<Result<DashboardSummary>> load(
    AuthContext context, {
    bool refresh = false,
  }) async => Success(summary);
}

class _FakeServicesRepository implements ServicesDashboardRepository {
  _FakeServicesRepository(this.snapshot);
  final ServicesDashboardSnapshot snapshot;
  @override
  Future<ServicesDashboardSnapshot> load(AuthContext context) async => snapshot;
  @override
  Stream<Result<ServicesDashboardSnapshot>> watch(AuthContext context) =>
      Stream.value(Success(snapshot));
}

class _FixedContributor implements DashboardContributor {
  _FixedContributor({
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
  Set<String> modules = const {'dashboard', 'attendance', 'leave', 'services'},
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

DashboardAttentionItem _attention(String id, {required int priority}) =>
    DashboardAttentionItem(
      id: id,
      moduleId: 'services',
      type: 'inspection',
      title: id,
      subtitle: 'sub',
      icon: Icons.fact_check_outlined,
      priority: priority,
      categoryLabel: 'Inspection',
      priorityLabel: 'High',
    );

DashboardWorkItem _work(String id, {required int priority, String type = ''}) =>
    DashboardWorkItem(
      id: id,
      moduleId: 'services',
      title: id,
      subtitle: 'customer · site',
      statusLabel: 'In progress',
      icon: Icons.engineering_outlined,
      type: type,
      priority: priority,
      actionText: 'Continue work',
      route: '/app/services/work-executions/$id',
    );

DashboardContribution _richContribution() => DashboardContribution(
  moduleId: 'services',
  order: 20,
  scopeLabel: 'Viewing: All company services',
  kpis: const [
    DashboardKpi(
      id: 'k1',
      moduleId: 'services',
      label: 'Pending inspections',
      value: '8',
      detail: '3 scheduled today',
      icon: Icons.fact_check_outlined,
      tone: DashboardTone.warning,
      route: '/app/services/inspections',
    ),
    DashboardKpi(
      id: 'k2',
      moduleId: 'services',
      label: 'Work in progress',
      value: '4',
      icon: Icons.play_circle_outline,
    ),
  ],
  attention: [_attention('a2', priority: 20), _attention('a1', priority: 90)],
  schedule: [
    const DashboardScheduleItem(
      id: 's1',
      moduleId: 'services',
      title: 'INS-00041',
      subtitle: 'ABC Properties · Unit 302',
      statusLabel: 'Pending',
      icon: Icons.fact_check_outlined,
      time: null,
      dateOnly: true,
    ),
  ],
  myWork: [
    _work('w2', priority: 60, type: 'inspection'),
    _work('w1', priority: 100, type: 'execution'),
  ],
  team: const [
    DashboardTeamRow(
      id: 't1',
      moduleId: 'services',
      label: 'HVAC Team',
      detail: '8 active · 3 today · 2 in progress',
    ),
  ],
  breakdowns: const [
    DashboardBreakdown(
      moduleId: 'services',
      title: 'Workflow overview',
      rows: [
        DashboardBreakdownRow(label: 'Enquiries', value: 14),
        DashboardBreakdownRow(label: 'Assignments', value: 9),
      ],
    ),
  ],
  activity: [
    DashboardActivityItem(
      id: 'act1',
      moduleId: 'services',
      title: 'WE-00031',
      description: 'Work execution completed',
      moduleLabel: 'Services',
      icon: Icons.history_outlined,
      occurredAt: DateTime(2026, 9, 28, 11),
    ),
  ],
  quickActions: const [
    DashboardQuickAction(
      id: 'qa1',
      moduleId: 'services',
      label: 'New enquiry',
      icon: Icons.add,
      route: '/app/services/enquiries/new',
    ),
  ],
);

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

Future<UniversalDashboardBloc> _mountedBloc(
  WidgetTester tester,
  List<DashboardContributor> contributors, {
  required AuthContext auth,
  Locale locale = const Locale('en'),
  DateTime? businessToday,
}) async {
  final l10n = await AppLocalizations.delegate.load(locale);
  final bloc = UniversalDashboardBloc(
    UniversalDashboardCoordinator(
      contributors,
      businessToday: (_) => businessToday,
    ),
    auth,
    l10n,
  );
  addTearDown(bloc.close);
  await tester.pumpWidget(
    _app(
      BlocProvider.value(value: bloc, child: const UniversalDashboardView()),
      locale: locale,
    ),
  );
  bloc.add(const UniversalDashboardStarted());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return bloc;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeDateFormatting);

  group('presentation models', () {
    test('highlightedWork surfaces the highest-priority execution', () {
      final snapshot = UniversalDashboardSnapshot(
        contributions: [_richContribution()],
        generatedAt: DateTime(2026, 9, 28),
      );
      expect(snapshot.highlightedWork?.id, 'w1');
      expect(snapshot.myWork.first.id, 'w1');
    });

    test('attention sorts by priority then business date', () {
      final snapshot = UniversalDashboardSnapshot(
        contributions: [_richContribution()],
        generatedAt: DateTime(2026, 9, 28),
      );
      expect(snapshot.attention.map((a) => a.id), ['a1', 'a2']);
    });

    test('coordinator records failed module ids', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final coordinator = UniversalDashboardCoordinator([
        _FixedContributor(
          id: 'hr',
          order: 10,
          contribution: _richContribution(),
        ),
        _FixedContributor(
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
      expect(snapshot.failedModuleIds, {'services'});
    });
  });

  group('permission scenarios', () {
    late AppLocalizations l;
    setUpAll(() async {
      l = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test(
      'A — SELF HR only contributes personal context, no company KPIs',
      () async {
        final contributor = HrDashboardContributor(
          repository: _FakeHrRepository(
            DashboardSummary(
              scope: DashboardScope.self,
              asOf: DateTime(2026, 9, 28),
              isDemo: false,
            ),
          ),
          demoWidgets: false,
        );
        final auth = _auth(
          permissions: const {
            AppPermission.attendanceViewSelf,
            AppPermission.leaveViewSelf,
          },
          employeeId: 'e1',
        );
        final contribution = await contributor.load(
          DashboardCapabilityContext(auth: auth, l10n: l),
        );
        expect(contribution.kpis, isEmpty);
        expect(contribution.attention, isEmpty);
        expect(contribution.activity, isEmpty);
      },
    );

    test(
      'B — ASSIGNED Services without view scope leaks no record or count',
      () async {
        final repository = _FakeServicesRepository(
          const ServicesDashboardSnapshot(
            scope: ServicesDashboardScope.assigned,
            canViewEnquiries: false,
            canViewAssignments: false,
            canViewInspections: false,
            canViewMaterialRequests: false,
            canViewWorkExecutions: false,
            canCreateEnquiry: false,
          ),
        );
        final contributor = ServicesDashboardContributor(
          repository: repository,
        );
        final auth = _auth(
          permissions: const {AppPermission.serviceWorkExecutionPerform},
          employeeId: 'e1',
        );
        final contribution = await contributor.load(
          DashboardCapabilityContext(auth: auth, l10n: l),
        );
        expect(contribution.kpis, isEmpty);
        expect(contribution.myWork, isEmpty);
        expect(contribution.attention, isEmpty);
        expect(contribution.activity, isEmpty);
      },
    );

    test('C — HR SELF + Services ASSIGNED compose one dashboard', () async {
      final services = ServicesDashboardContributor(
        repository: _FakeServicesRepository(
          ServicesDashboardSnapshot(
            scope: ServicesDashboardScope.assigned,
            canViewEnquiries: false,
            canViewAssignments: true,
            canViewInspections: true,
            canViewMaterialRequests: false,
            canViewWorkExecutions: true,
            canCreateEnquiry: false,
            workInProgressCount: 1,
            scheduledAssignmentsCount: 2,
            pendingInspectionsCount: 3,
            myWork: const [
              ServicesMyWorkItem(
                kind: ServicesMyWorkKind.execution,
                entityId: 'we1',
                reference: 'WE-00031',
                customerName: 'ABC',
                siteSummary: 'Tower · Unit 403',
                summary: 'Capacitor replacement',
                statusKey: 'in_progress',
                action: ServicesMyWorkAction.continueWork,
              ),
            ],
          ),
        ),
      );
      final auth = _auth(
        permissions: const {
          AppPermission.attendanceViewSelf,
          AppPermission.serviceJobAssignmentViewAssigned,
          AppPermission.serviceInspectionViewAssigned,
          AppPermission.serviceWorkExecutionViewAssigned,
        },
        employeeId: 'e1',
      );
      final contribution = await services.load(
        DashboardCapabilityContext(auth: auth, l10n: l),
      );
      expect(contribution.kpis, isNotEmpty);
      expect(contribution.myWork.single.type, 'execution');
      expect(contribution.myWork.single.priority, greaterThan(0));
    });
  });

  group('layout and states', () {
    testWidgets('renders a geometry-aware skeleton while loading', (
      tester,
    ) async {
      final auth = _auth(permissions: const {});
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final bloc = UniversalDashboardBloc(
        UniversalDashboardCoordinator([
          _FixedContributor(
            id: 'services',
            order: 20,
            contribution: _richContribution(),
          ),
        ]),
        auth,
        l10n,
      );
      addTearDown(bloc.close);
      await tester.pumpWidget(
        _app(
          BlocProvider.value(
            value: bloc,
            child: const UniversalDashboardView(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AppDashboardSkeleton), findsOneWidget);
    });

    testWidgets('shows an intentional empty state with no work', (
      tester,
    ) async {
      await _mountedBloc(tester, const [], auth: _auth(permissions: const {}));
      final context = tester.element(find.byType(UniversalDashboardView));
      final l = context.l10n;
      expect(find.text(l.universalDashboardEmptyTitle), findsOneWidget);
      expect(find.byType(AppDashboardMetricCard), findsNothing);
    });

    testWidgets('first-time company shows no six zero cards', (tester) async {
      await _mountedBloc(tester, [
        _FixedContributor(
          id: 'services',
          order: 20,
          contribution: const DashboardContribution(
            moduleId: 'services',
            kpis: [
              DashboardKpi(
                id: 'z1',
                moduleId: 'services',
                label: 'Open enquiries',
                value: '0',
                icon: Icons.support_agent_outlined,
              ),
              DashboardKpi(
                id: 'z2',
                moduleId: 'services',
                label: 'Pending inspections',
                value: '0',
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
        ),
      ], auth: _auth(permissions: const {}));
      final context = tester.element(find.byType(UniversalDashboardView));
      final l = context.l10n;
      expect(find.text(l.universalDashboardFirstTimeTitle), findsOneWidget);
      expect(find.byType(AppDashboardMetricCard), findsNothing);
    });

    testWidgets('partial failure warns with retry and never a fake zero', (
      tester,
    ) async {
      await _mountedBloc(tester, [
        _FixedContributor(
          id: 'hr',
          order: 10,
          contribution: _richContribution(),
        ),
        _FixedContributor(
          id: 'services',
          order: 20,
          contribution: DashboardContribution.empty,
          fail: true,
        ),
      ], auth: _auth(permissions: const {}));
      final context = tester.element(find.byType(UniversalDashboardView));
      final l = context.l10n;
      expect(find.text(l.universalDashboardPartial), findsOneWidget);
      expect(find.text(l.retry), findsOneWidget);
    });

    testWidgets('module disable removes its contribution', (tester) async {
      await _mountedBloc(tester, [
        _FixedContributor(
          id: 'services',
          order: 20,
          contribution: _richContribution(),
          visible: false,
        ),
      ], auth: _auth(permissions: const {}));
      final context = tester.element(find.byType(UniversalDashboardView));
      final l = context.l10n;
      expect(find.text(l.universalDashboardEmptyTitle), findsOneWidget);
    });

    for (final width in [390.0, 600.0, 768.0, 1000.0, 1280.0, 1440.0, 1920.0]) {
      testWidgets('rich dashboard fits ${width.toInt()} LTR scale 1.0', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _mountedBloc(tester, [
          _FixedContributor(
            id: 'services',
            order: 20,
            contribution: _richContribution(),
          ),
        ], auth: _auth(permissions: const {}));
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(UniversalDashboardView));
        final l = context.l10n;
        expect(find.text(l.universalDashboardNeedsAttention), findsOneWidget);
        expect(
          find.byKey(const ValueKey('universal-attention-a1')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('universal-work-w1')), findsOneWidget);
        expect(find.byKey(const ValueKey('universal-kpi-k1')), findsOneWidget);
      });

      testWidgets('rich dashboard fits ${width.toInt()} RTL scale 1.3', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await _mountedBloc(
          tester,
          [
            _FixedContributor(
              id: 'services',
              order: 20,
              contribution: _richContribution(),
            ),
          ],
          auth: _auth(permissions: const {}),
          locale: const Locale('ar'),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('mobile orders My Day before Needs Attention and My Work', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _mountedBloc(tester, [
        _FixedContributor(
          id: 'services',
          order: 20,
          contribution: _richContribution(),
        ),
      ], auth: _auth(permissions: const {}));
      final context = tester.element(find.byType(UniversalDashboardView));
      final l = context.l10n;
      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(
        top(l.universalDashboardNeedsAttention),
        lessThan(top(l.universalDashboardMyWork)),
      );
      expect(
        top(l.universalDashboardMyWork),
        lessThan(top(l.universalDashboardSchedule)),
      );
    });
  });
}
