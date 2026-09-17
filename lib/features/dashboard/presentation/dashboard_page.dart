import '../../../design_system/theme/app_motion.dart';
import '../../../design_system/theme/app_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/module_registry/module_registry.dart';
import '../../../app/module_registry/navigation_resolver.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/localization/app_formatters.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';
import 'bloc/dashboard_bloc.dart';
import 'dashboard_presentation.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.repository,
    required this.registry,
  });
  final DashboardRepository repository;
  final ModuleRegistry registry;
  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, auth) => auth == null
            ? const SizedBox.shrink()
            : BlocProvider(
                key: ValueKey(auth),
                create: (_) =>
                    DashboardBloc(repository, auth)
                      ..add(const DashboardStarted()),
                child: DashboardView(auth: auth, registry: registry),
              ),
      );
}

/// Public view boundary permits meaningful loading/error/empty tests without
/// introducing demo switches or extra screens in the product.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required this.auth, required this.registry});
  final AuthContext auth;
  final ModuleRegistry registry;
  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<DashboardBloc>();
    if (bloc.state.status == DashboardStatus.loading ||
        bloc.state.status == DashboardStatus.refreshing) {
      return;
    }
    final done = bloc.stream.firstWhere(
      (s) =>
          s.status == DashboardStatus.loaded ||
          s.status == DashboardStatus.failure,
    );
    bloc.add(const DashboardRefreshRequested());
    await done;
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DashboardBloc, DashboardState>(
    builder: (context, state) {
      final l = context.l10n,
          locale = Localizations.localeOf(context),
          now = DateTime.now();
      final summary = state.summary,
          busy =
              state.status == DashboardStatus.loading ||
              state.status == DashboardStatus.refreshing;
      final compact = AppBreakpoints.of(context) == AppSize.compact;
      final actions = NavigationResolver(registry)
          .resolve(auth.company, auth.user.permissions)
          .destinations
          .where(
            (d) =>
                d.route != AppRoutes.dashboard &&
                d.navigationGroup != NavigationGroup.account,
          )
          .toList();
      final header = AppPageHeader(
        compactActionsInline: true,
        title: compact
            ? DashboardPresentation.greeting(
                l,
                now,
                auth.user.displayName.split(' ').first,
              )
            : l.shellDashboard,
        subtitle: compact
            ? AppDateFormatter(locale).fullDate(now)
            : '${DashboardPresentation.greeting(l, now, auth.user.displayName.split(' ').first)} · ${AppDateFormatter(locale).fullDate(now)}',
        actions: [
          AppIconButton(
            icon: Icons.refresh,
            tooltip: l.dashboardRefresh,
            onPressed: busy
                ? null
                : () => context.read<DashboardBloc>().add(
                    const DashboardRefreshRequested(),
                  ),
          ),
        ],
      );
      Widget body;
      if (summary == null && state.status != DashboardStatus.failure) {
        body = const AppDashboardSkeleton();
      } else if (summary == null) {
        body = AppCard(
          child: AppErrorState(
            message: l.dashboardError,
            onRetry: () =>
                context.read<DashboardBloc>().add(const DashboardStarted()),
          ),
        );
      } else {
        final mainMetrics = summary.metrics
            .where(
              (m) => !{
                DashboardMetricKind.working,
                DashboardMetricKind.onBreak,
                DashboardMetricKind.corrections,
              }.contains(m.kind),
            )
            .where(
              (m) =>
                  !compact ||
                  !{
                    DashboardMetricKind.attendanceRate,
                    DashboardMetricKind.locations,
                    DashboardMetricKind.users,
                  }.contains(m.kind),
            )
            .toList();
        final quick = AppDashboardSection(
          title: l.dashboardQuickActions,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final action in actions)
                AppQuickActionCard(
                  key: ValueKey('dashboard-action-${action.id}'),
                  label: action.name(l),
                  icon: action.icon,
                  onPressed: () => context.go(action.route),
                ),
            ],
          ),
        );
        final activity = AppDashboardSection(
          title: l.dashboardActivity,
          child: summary.activities.isEmpty
              ? Text(
                  l.dashboardNoActivity,
                  style: AppTypography.of(context).bodySmall,
                )
              : Column(
                  children: [
                    for (final a in summary.activities)
                      AppActivityItem(
                        title: DashboardPresentation.activity(l, a),
                        description: l.dashboardActivityDetail,
                        timestamp:
                            '${AppDateFormatter(locale).date(a.timestamp)} · ${AppTimeFormatter(locale).time(a.timestamp)}',
                        icon: switch (a.kind) {
                          DashboardActivityKind.checkedIn => Icons.login,
                          DashboardActivityKind.breakStarted =>
                            Icons.coffee_outlined,
                          DashboardActivityKind.correctionSubmitted =>
                            Icons.edit_note,
                        },
                        status: a.kind == DashboardActivityKind.checkedIn
                            ? AppStatus.success
                            : AppStatus.neutral,
                      ),
                  ],
                ),
        );
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DashboardPresentation.contextLabel(l, summary.scope),
              style: AppTypography.of(context).body,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (summary.isDemo)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppStatusBadge(
                  label: l.dashboardDemo(
                    AppDateFormatter(locale).date(summary.asOf),
                  ),
                  status: AppStatus.info,
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            if (state.status == DashboardStatus.refreshing) ...[
              Semantics(
                liveRegion: true,
                label: l.dashboardRefreshing,
                child: const LinearProgressIndicator(minHeight: 2),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (state.failure != null) ...[
              AppAlert(
                message: l.dashboardRefreshError,
                status: AppStatus.warning,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (summary.isEmpty)
              AppCard(
                child: AppEmptyState(
                  title: l.dashboardEmptyTitle,
                  message: l.dashboardEmptyMessage,
                ),
              ),
            if (summary.today case final today?) ...[
              _today(context, today),
              const SizedBox(height: AppSpacing.xxl),
              AppSectionHeader(title: l.dashboardMonth),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (mainMetrics.isNotEmpty) ...[
              AppDashboardGrid(
                children: [
                  for (final metric in mainMetrics)
                    AppMetricCard(
                      key: ValueKey('metric-${metric.kind.name}'),
                      label: DashboardPresentation.label(l, metric.kind),
                      value: DashboardPresentation.value(context, metric),
                      detail:
                          metric.kind == DashboardMetricKind.present &&
                              summary.scope != DashboardScope.self
                          ? l.dashboardPresentDetail
                          : '',
                      icon: DashboardPresentation.icon(metric.kind),
                      status: DashboardPresentation.status(metric.kind),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
            if (summary.status != null) ...[
              AppDashboardTwoColumn(
                primary: compact
                    ? _attention(context, summary)
                    : _status(context, summary),
                secondary: compact
                    ? _status(context, summary)
                    : _attention(context, summary),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
            if (compact) ...[
              if (actions.isNotEmpty) ...[
                quick,
                const SizedBox(height: AppSpacing.xxl),
              ],
              if (!summary.isEmpty) activity,
            ] else if (!summary.isEmpty && actions.isNotEmpty)
              AppDashboardTwoColumn(primary: activity, secondary: quick)
            else if (!summary.isEmpty)
              activity
            else if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              quick,
            ],
          ],
        );
      }
      return RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: AppPage(
          header: header,
          animateEntrance: false,
          scrollPhysics: const AlwaysScrollableScrollPhysics(),
          child: summary == null ? body : AppMotion.entrance(context, body),
        ),
      );
    },
  );
  Widget _today(BuildContext context, DashboardToday today) {
    final l = context.l10n,
        times = AppTimeFormatter(Localizations.localeOf(context));
    final attendance = registry.destinations
        .where((d) => d.route == AppRoutes.attendance)
        .firstOrNull;
    final canOpen =
        attendance != null &&
        NavigationResolver(registry).routeAccess(attendance.route, auth) ==
            RouteAccess.allowed;
    return AppDashboardSection(
      title: l.dashboardToday,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (AppBreakpoints.of(context) == AppSize.expanded ||
              AppBreakpoints.of(context) == AppSize.large)
            AppResponsiveGrid(
              maxColumns: 3,
              minItemWidth: 200,
              children: [
                for (final fact in [
                  (
                    label: l.dashboardShift,
                    value: l.dashboardTimeRange(
                      times.time(today.shiftStart),
                      times.time(today.shiftEnd),
                    ),
                  ),
                  (label: l.dashboardLocation, value: l.dashboardOffice),
                  (label: l.dashboardAttendance, value: l.dashboardNotStarted),
                ])
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fact.label,
                        style: AppTypography.of(context).caption,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        fact.value,
                        style: AppTypography.of(context).bodyLarge,
                      ),
                    ],
                  ),
              ],
            )
          else
            AppStatusSummary(
              rows: [
                (
                  label: l.dashboardShift,
                  value: l.dashboardTimeRange(
                    times.time(today.shiftStart),
                    times.time(today.shiftEnd),
                  ),
                  status: AppStatus.neutral,
                ),
                (
                  label: l.dashboardLocation,
                  value: l.dashboardOffice,
                  status: AppStatus.neutral,
                ),
                (
                  label: l.dashboardAttendance,
                  value: l.dashboardNotStarted,
                  status: AppStatus.neutral,
                ),
              ],
            ),
          if (canOpen) ...[
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppQuickActionCard(
                label: attendance.name(l),
                icon: attendance.icon,
                onPressed: () => context.go(attendance.route),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _status(BuildContext context, DashboardSummary summary) {
    final l = context.l10n,
        numbers = AppNumberFormatter(Localizations.localeOf(context)),
        s = summary.status!;
    return AppDashboardSection(
      title: l.dashboardStatus,
      child: AppStatusSummary(
        rows: [
          (
            label: l.dashboardOnTime,
            value: numbers.integer(s.onTime),
            status: AppStatus.success,
          ),
          (
            label: l.dashboardLate,
            value: numbers.integer(s.late),
            status: AppStatus.warning,
          ),
          (
            label: l.dashboardAbsent,
            value: numbers.integer(s.absent),
            status: AppStatus.danger,
          ),
          (
            label: l.dashboardLeave,
            value: numbers.integer(s.onLeave),
            status: AppStatus.info,
          ),
          for (final metric in summary.metrics.where(
            (m) =>
                {
                  DashboardMetricKind.working,
                  DashboardMetricKind.onBreak,
                }.contains(m.kind) ||
                AppBreakpoints.of(context) == AppSize.compact &&
                    {
                      DashboardMetricKind.attendanceRate,
                      DashboardMetricKind.locations,
                      DashboardMetricKind.users,
                    }.contains(m.kind),
          ))
            (
              label: DashboardPresentation.label(l, metric.kind),
              value: DashboardPresentation.value(context, metric),
              status: DashboardPresentation.status(metric.kind),
            ),
        ],
      ),
    );
  }

  Widget _attention(BuildContext context, DashboardSummary summary) {
    final l = context.l10n,
        numbers = AppNumberFormatter(Localizations.localeOf(context));
    final canOpen =
        NavigationResolver(registry).routeAccess(AppRoutes.attendance, auth) ==
        RouteAccess.allowed;
    return AppDashboardSection(
      title: l.dashboardAttention,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (summary.alerts.isEmpty) Text(l.dashboardNoAttention),
          for (final alert in summary.alerts)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppActivityItem(
                title: alert.kind == DashboardAlertKind.lateArrivals
                    ? l.dashboardLateAlert(numbers.integer(alert.count))
                    : l.dashboardCorrectionsAlert(numbers.integer(alert.count)),
                description: '',
                timestamp: '',
                icon: alert.kind == DashboardAlertKind.lateArrivals
                    ? Icons.schedule
                    : Icons.rule_outlined,
                status: AppStatus.warning,
              ),
            ),
          if (canOpen)
            AppTextButton(
              label: l.shellAttendance,
              onPressed: () => context.go(AppRoutes.attendance),
            ),
        ],
      ),
    );
  }
}
