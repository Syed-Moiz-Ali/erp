import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_scope_resolver.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/data/demo_dashboard_source.dart';
import 'package:modular_erp/modules/hr/dashboard/data/local_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/presentation/bloc/dashboard_bloc.dart';

class ControlledDashboardRepository implements DashboardRepository {
  final requests = <Completer<Result<DashboardSummary>>>[];
  final refreshFlags = <bool>[];
  final contexts = <AuthContext>[];
  @override
  Future<Result<DashboardSummary>> load(
    AuthContext context, {
    bool refresh = false,
  }) {
    contexts.add(context);
    refreshFlags.add(refresh);
    final c = Completer<Result<DashboardSummary>>();
    requests.add(c);
    return c.future;
  }
}

class ThrowingSource extends DemoDashboardSource {
  @override
  DashboardSummary read(DashboardScope scope, String person) =>
      throw StateError('sensitive implementation detail');
}

void main() {
  final source = DemoAuthSource();
  AuthContext account(DemoScenario role) =>
      source.accounts.firstWhere((a) => a.scenario == role).context;
  final employee = account(DemoScenario.employee);
  AuthContext grants(Iterable<AppPermission> p) => employee.copyWith(
    user: employee.user.copyWith(permissions: PermissionSet(p)),
  );
  const resolver = DashboardScopeResolver(),
      repository = LocalDashboardRepository();
  final snapshot = const DemoDashboardSource().read(
    DashboardScope.self,
    employee.user.displayName,
  );
  final loaded = isA<DashboardState>().having(
    (s) => s.status,
    'status',
    DashboardStatus.loaded,
  );
  test(
    'scope selects highest explicitly granted attendance scope, never role',
    () {
      expect(
        resolver.resolve(
          grants([
            AppPermission.attendanceViewAll,
            AppPermission.attendanceViewTeam,
            AppPermission.attendanceViewSelf,
          ]),
        ),
        DashboardScope.company,
      );
      expect(
        resolver.resolve(
          grants([
            AppPermission.attendanceViewTeam,
            AppPermission.attendanceViewSelf,
          ]),
        ),
        DashboardScope.team,
      );
      expect(
        resolver.resolve(grants([AppPermission.attendanceViewSelf])),
        DashboardScope.self,
      );
      expect(resolver.resolve(grants([])), DashboardScope.none);
      final admin = account(DemoScenario.platformAdmin);
      expect(
        resolver.resolve(
          admin.copyWith(
            user: admin.user.copyWith(permissions: PermissionSet([])),
          ),
        ),
        DashboardScope.none,
      );
      expect(
        resolver.resolve(
          admin.copyWith(
            company: admin.company.copyWith(enabledModules: {'dashboard'}),
          ),
        ),
        DashboardScope.none,
      );
    },
  );
  for (final role in DemoScenario.values) {
    test(
      '$role receives permission-scoped deterministic immutable data',
      () async {
        final context = account(role);
        final data =
            (await repository.load(context) as Success<DashboardSummary>).value;
        final again =
            (await repository.load(context, refresh: true)
                    as Success<DashboardSummary>)
                .value;
        expect(
          data.scope,
          role == DemoScenario.employee
              ? DashboardScope.self
              : role == DemoScenario.manager
              ? DashboardScope.team
              : DashboardScope.company,
        );
        expect(
          data.metrics.map((m) => m.value),
          again.metrics.map((m) => m.value),
        );
        expect(data.asOf, again.asOf);
        for (var i = 1; i < data.activities.length; i++) {
          expect(
            data.activities[i - 1].timestamp.isBefore(
              data.activities[i].timestamp,
            ),
            isFalse,
          );
        }
        expect(() => data.metrics.clear(), throwsUnsupportedError);
        if (role == DemoScenario.employee) {
          expect(data.status, isNull);
          expect(data.today, isNull);
          expect(data.metrics, isEmpty);
          expect(data.activities, isEmpty);
          expect(data.isDemo, isFalse);
          expect(data.alerts, isEmpty);
        } else {
          final status = data.status!;
          expect(status.total, role == DemoScenario.manager ? 12 : 84);
          expect(status.present, role == DemoScenario.manager ? 9 : 73);
          expect(data.metrics.first.value, status.total);
          final work = data.metrics
              .firstWhere((m) => m.kind == DashboardMetricKind.working)
              .value;
          final rest = data.metrics
              .firstWhere((m) => m.kind == DashboardMetricKind.onBreak)
              .value;
          expect(work + rest, status.present);
          if (role == DemoScenario.manager) {
            expect(
              data.metrics.any(
                (m) => {
                  DashboardMetricKind.employees,
                  DashboardMetricKind.users,
                  DashboardMetricKind.locations,
                }.contains(m.kind),
              ),
              isFalse,
            );
          }
        }
      },
    );
  }
  test(
    'company scope alone does not grant employee, user, location or correction data',
    () async {
      final data =
          (await repository.load(grants([AppPermission.attendanceViewAll]))
                  as Success<DashboardSummary>)
              .value;
      expect(data.scope, DashboardScope.company);
      expect(
        data.metrics.any(
          (m) => {
            DashboardMetricKind.employees,
            DashboardMetricKind.users,
            DashboardMetricKind.locations,
            DashboardMetricKind.corrections,
          }.contains(m.kind),
        ),
        isFalse,
      );
      expect(data.alerts.map((a) => a.kind), [DashboardAlertKind.lateArrivals]);
      expect(
        data.activities.any(
          (a) => a.kind == DashboardActivityKind.correctionSubmitted,
        ),
        isFalse,
      );
    },
  );
  test(
    'disabled company modules suppress dependent metrics; no attendance grant returns empty',
    () async {
      final admin = account(DemoScenario.platformAdmin);
      final disabled = admin.copyWith(
        company: admin.company.copyWith(
          enabledModules: {'dashboard', 'attendance'},
        ),
      );
      final data =
          (await repository.load(disabled) as Success<DashboardSummary>).value;
      expect(
        data.metrics.any(
          (m) => {
            DashboardMetricKind.employees,
            DashboardMetricKind.users,
          }.contains(m.kind),
        ),
        isFalse,
      );
      expect(
        (await repository.load(grants([])) as Success<DashboardSummary>)
            .value
            .isEmpty,
        isTrue,
      );
    },
  );
  test(
    'disabled demos and source exceptions return safe typed failures',
    () async {
      expect(
        await const LocalDashboardRepository(demoEnabled: false).load(employee),
        isA<Failed<DashboardSummary>>().having(
          (r) => r.failure.kind,
          'kind',
          FailureKind.demoDisabled,
        ),
      );
      final result = await LocalDashboardRepository(
        source: ThrowingSource(),
      ).load(employee);
      expect(
        result,
        isA<Failed<DashboardSummary>>().having(
          (r) => r.failure.code,
          'safe code',
          'dashboard.local_read',
        ),
      );
    },
  );
  test('Bloc starts initial with no data', () async {
    final bloc = DashboardBloc(repository, employee);
    expect(bloc.state.status, DashboardStatus.initial);
    expect(bloc.state.summary, isNull);
    await bloc.close();
  });
  blocTest<DashboardBloc, DashboardState>(
    'load uses repository and becomes loaded',
    build: () => DashboardBloc(repository, employee),
    act: (b) => b.add(const DashboardStarted()),
    expect: () => [
      isA<DashboardState>().having(
        (s) => s.status,
        'status',
        DashboardStatus.loading,
      ),
      loaded.having((s) => s.summary?.scope, 'scope', DashboardScope.self),
    ],
  );
  blocTest<DashboardBloc, DashboardState>(
    'failure is recoverable with retry',
    build: () => DashboardBloc(
      const LocalDashboardRepository(demoEnabled: false),
      employee,
    ),
    act: (b) => b.add(const DashboardStarted()),
    expect: () => [
      isA<DashboardState>().having(
        (s) => s.status,
        'status',
        DashboardStatus.loading,
      ),
      isA<DashboardState>()
          .having((s) => s.status, 'status', DashboardStatus.failure)
          .having((s) => s.failure?.kind, 'failure', FailureKind.demoDisabled),
    ],
  );
  test(
    'refresh retains snapshot, coalesces submissions, handles failure and retry',
    () async {
      final repo = ControlledDashboardRepository();
      final b = DashboardBloc(repo, employee);
      Future<void> tick() => Future<void>.delayed(Duration.zero);
      b.add(const DashboardStarted());
      await tick();
      expect(b.state.status, DashboardStatus.loading);
      repo.requests[0].complete(Success(snapshot));
      await tick();
      b.add(const DashboardRefreshRequested());
      b.add(const DashboardRefreshRequested());
      await tick();
      expect(b.state.status, DashboardStatus.refreshing);
      expect(identical(b.state.summary, snapshot), isTrue);
      expect(repo.requests.length, 2);
      repo.requests[1].complete(
        const Failed(
          Failure(code: 'offline', kind: FailureKind.offline, retryable: true),
        ),
      );
      await tick();
      expect(b.state.status, DashboardStatus.loaded);
      expect(identical(b.state.summary, snapshot), isTrue);
      expect(b.state.failure?.kind, FailureKind.offline);
      b.add(const DashboardRefreshRequested());
      await tick();
      repo.requests[2].complete(Success(snapshot));
      await tick();
      expect(b.state.failure, isNull);
      expect(repo.refreshFlags, [false, true, true]);
      expect(repo.contexts.every((c) => identical(c, employee)), isTrue);
      await b.close();
    },
  );
}
