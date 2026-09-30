import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';
import 'package:modular_erp/platform/workspace/dashboard/presentation/bloc/universal_dashboard_bloc.dart';

/// The single, universal ERP dashboard.
///
/// Neutral ownership: it renders only typed contributions gathered by the
/// [UniversalDashboardCoordinator] and owns no module business logic, DAO or
/// Drift dependency. Sections compose by work/attention, never as stacked
/// per-module dashboards.
class UniversalDashboardPage extends StatelessWidget {
  const UniversalDashboardPage({super.key, required this.coordinator});

  final UniversalDashboardCoordinator coordinator;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, auth) {
          if (auth == null) return const SizedBox.shrink();
          final locale = Localizations.localeOf(context);
          return BlocProvider(
            key: ValueKey('universal-dashboard-$auth-$locale'),
            create: (_) =>
                UniversalDashboardBloc(coordinator, auth, context.l10n)
                  ..add(const UniversalDashboardStarted()),
            child: const UniversalDashboardView(),
          );
        },
      );
}

/// Public view boundary so loading/error/partial/ready can be tested directly.
class UniversalDashboardView extends StatelessWidget {
  const UniversalDashboardView({super.key});

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<UniversalDashboardBloc>();
    if (bloc.state.isBusy) return;
    final done = bloc.stream.firstWhere(
      (s) => !s.isBusy && s.status != UniversalDashboardStatus.initial,
    );
    bloc.add(const UniversalDashboardRefreshRequested());
    await done;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<UniversalDashboardBloc, UniversalDashboardState>(
      builder: (context, state) {
        final snapshot = state.snapshot;
        final header = AppPageHeader(
          title: l.shellDashboard,
          subtitle: l.universalDashboardSubtitle,
          actions: [
            AppIconButton(
              icon: Icons.refresh,
              tooltip: l.universalDashboardRefresh,
              onPressed: state.isBusy
                  ? null
                  : () => context.read<UniversalDashboardBloc>().add(
                      const UniversalDashboardRefreshRequested(),
                    ),
            ),
          ],
        );
        Widget body;
        if (snapshot == null &&
            state.status != UniversalDashboardStatus.failure) {
          body = const AppDashboardSkeleton();
        } else if (snapshot == null) {
          body = AppCard(
            child: AppErrorState(
              message: l.universalDashboardError,
              onRetry: () => context.read<UniversalDashboardBloc>().add(
                const UniversalDashboardStarted(),
              ),
            ),
          );
        } else {
          body = _DashboardBody(snapshot: snapshot, state: state);
        }
        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: AppPage(
            header: header,
            animateEntrance: false,
            scrollPhysics: const AlwaysScrollableScrollPhysics(),
            child: body,
          ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.snapshot, required this.state});

  final UniversalDashboardSnapshot snapshot;
  final UniversalDashboardState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final compact = AppBreakpoints.of(context) == AppSize.compact;
    final myDay = _MyDaySection(snapshot: snapshot);
    final attention = _AttentionSection(snapshot: snapshot);
    final kpis = _KpiSection(snapshot: snapshot);
    final schedule = _ScheduleSection(snapshot: snapshot);
    final myWork = _MyWorkSection(snapshot: snapshot);
    final overview = _OverviewSection(snapshot: snapshot);
    final activity = _ActivitySection(snapshot: snapshot);
    final quickActions = _QuickActionsSection(snapshot: snapshot);
    final contextRow = _ContextRow(snapshot: snapshot);

    final sections = <Widget>[
      if (state.status == UniversalDashboardStatus.refreshing) ...[
        Semantics(
          liveRegion: true,
          label: l.universalDashboardRefreshing,
          child: const LinearProgressIndicator(minHeight: 2),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
      if (snapshot.partialFailure || state.failure != null) ...[
        AppAlert(
          message: l.universalDashboardPartial,
          status: AppStatus.warning,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
      contextRow,
      if (!snapshot.hasAnyData) ...[
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: AppEmptyState(
            title: l.universalDashboardEmptyTitle,
            message: l.universalDashboardAllClear,
          ),
        ),
      ],
    ];

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...sections,
          myDay,
          attention,
          myWork,
          schedule,
          kpis,
          overview,
          activity,
          quickActions,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...sections,
        myDay,
        kpis,
        AppDashboardTwoColumn(
          primary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              attention,
              const SizedBox(height: AppSpacing.xxl),
              schedule,
            ],
          ),
          secondary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              myWork,
              const SizedBox(height: AppSpacing.xxl),
              overview,
            ],
          ),
        ),
        activity,
        quickActions,
      ],
    );
  }
}

class _ContextRow extends StatelessWidget {
  const _ContextRow({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context);
    final badges = <Widget>[
      AppStatusBadge(
        label: [
          l.universalDashboardToday,
          // Company-local business date from AppClock + CompanyTimeService,
          // never the device's raw local clock.
          AppDateFormatter(locale).date(snapshot.today ?? snapshot.generatedAt),
        ].join(' · '),
        status: AppStatus.neutral,
        icon: Icons.calendar_today_outlined,
        isPill: true,
      ),
      for (final label in snapshot.scopeLabels)
        AppStatusBadge(
          label: label,
          status: AppStatus.brand,
          icon: Icons.visibility_outlined,
          isPill: true,
        ),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: badges,
      ),
    );
  }
}

class _MyDaySection extends StatelessWidget {
  const _MyDaySection({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.myDay.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDashboardSection(
          title: context.l10n.universalDashboardMyDay,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < snapshot.myDay.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                snapshot.myDay[i],
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _AttentionSection extends StatelessWidget {
  const _AttentionSection({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = snapshot.attention;
    if (items.isEmpty && snapshot.viewAll(DashboardSection.attention) == null) {
      return const SizedBox.shrink();
    }
    return AppDashboardSection(
      title: l.universalDashboardNeedsAttention,
      action: _viewAll(context, snapshot, DashboardSection.attention),
      child: items.isEmpty
          ? Text(
              l.universalDashboardAllClear,
              style: AppTypography.of(context).bodySmall,
            )
          : AppAttentionList(
              children: [
                for (final item in items)
                  AppAttentionItem(
                    key: ValueKey('universal-attention-${item.id}'),
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    status: dashboardStatus(item.tone),
                    onTap: item.route == null
                        ? null
                        : () => context.go(item.route!),
                  ),
              ],
            ),
    );
  }
}

class _KpiSection extends StatelessWidget {
  const _KpiSection({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final kpis = snapshot.kpis;
    if (kpis.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDashboardSection(
          title: context.l10n.universalDashboardMetrics,
          card: false,
          child: AppDashboardGrid(
            children: [
              for (final kpi in kpis)
                AppMetricCard(
                  key: ValueKey('universal-kpi-${kpi.id}'),
                  label: kpi.label,
                  value: kpi.value,
                  detail: kpi.detail,
                  icon: kpi.icon,
                  status: dashboardStatus(kpi.tone),
                  onTap: kpi.route == null
                      ? null
                      : () => context.go(kpi.route!),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = snapshot.schedule;
    if (items.isEmpty && snapshot.viewAll(DashboardSection.schedule) == null) {
      return const SizedBox.shrink();
    }
    return AppDashboardSection(
      title: l.universalDashboardSchedule,
      action: _viewAll(context, snapshot, DashboardSection.schedule),
      child: items.isEmpty
          ? Text(
              l.universalDashboardNoSchedule,
              style: AppTypography.of(
                context,
              ).caption.copyWith(color: AppColors.textMuted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                    ),
                  _ScheduleRow(item: items[i]),
                ],
              ],
            ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.item});

  final DashboardScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final time = item.time;
    final timeLabel = time == null
        ? '—'
        : item.dateOnly
        ? AppDateFormatter(locale).date(time)
        : AppTimeFormatter(locale).time(time);
    return InkWell(
      onTap: item.route == null ? null : () => context.go(item.route!),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 68,
              child: Text(
                timeLabel,
                style: AppTypography.of(context).bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.of(context).bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.subtitle,
                      style: AppTypography.of(context).caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (item.statusLabel.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(
                label: item.statusLabel,
                status: dashboardStatus(item.tone),
                isPill: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MyWorkSection extends StatelessWidget {
  const _MyWorkSection({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = snapshot.myWork;
    if (items.isEmpty && snapshot.viewAll(DashboardSection.myWork) == null) {
      return const SizedBox.shrink();
    }
    return AppDashboardSection(
      title: l.universalDashboardMyWork,
      action: _viewAll(context, snapshot, DashboardSection.myWork),
      child: items.isEmpty
          ? Text(
              l.universalDashboardNoWork,
              style: AppTypography.of(
                context,
              ).caption.copyWith(color: AppColors.textMuted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                    ),
                  _MyWorkRow(item: items[i]),
                ],
              ],
            ),
    );
  }
}

class _MyWorkRow extends StatelessWidget {
  const _MyWorkRow({required this.item});

  final DashboardWorkItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.of(context).bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.subtitle,
                    style: AppTypography.of(context).caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (item.statusLabel.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.statusLabel,
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (item.route != null) ...[
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: AppSecondaryButton(
                label: item.actionText.isEmpty
                    ? context.l10n.universalDashboardOpen
                    : item.actionText,
                icon: item.icon,
                size: AppButtonSize.small,
                onPressed: () => context.go(item.route!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final team = snapshot.team;
    final breakdowns = snapshot.breakdowns;
    if (team.isEmpty && breakdowns.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (team.isNotEmpty)
          AppDashboardSection(
            title: context.l10n.universalDashboardTeam,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < team.length; i++) ...[
                  if (i > 0) const Divider(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team[i].label,
                          style: AppTypography.of(context).bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (team[i].detail.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            team[i].detail,
                            style: AppTypography.of(
                              context,
                            ).caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (team.isNotEmpty && breakdowns.isNotEmpty)
          const SizedBox(height: AppSpacing.xxl),
        for (var b = 0; b < breakdowns.length; b++) ...[
          if (b > 0) const SizedBox(height: AppSpacing.xxl),
          AppDashboardSection(
            title: breakdowns[b].title,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < breakdowns[b].rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  _BreakdownRow(row: breakdowns[b].rows[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.row});

  final DashboardBreakdownRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            row.label,
            style: AppTypography.of(context).caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          AppNumberFormatter(
            Localizations.localeOf(context),
          ).integer(row.value),
          style: AppTypography.of(context).bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = snapshot.activity;
    if (items.isEmpty && snapshot.viewAll(DashboardSection.activity) == null) {
      return const SizedBox.shrink();
    }
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: AppDashboardSection(
        title: l.universalDashboardRecentActivity,
        action: _viewAll(context, snapshot, DashboardSection.activity),
        child: items.isEmpty
            ? Text(
                l.universalDashboardNoActivity,
                style: AppTypography.of(
                  context,
                ).caption.copyWith(color: AppColors.textMuted),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in items)
                    AppActivityItem(
                      key: ValueKey('universal-activity-${item.id}'),
                      icon: item.icon,
                      title: item.title,
                      description: item.description,
                      timestamp: AppDateFormatter(
                        locale,
                      ).relative(item.occurredAt, l),
                      status: dashboardStatus(item.tone),
                    ),
                ],
              ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.snapshot});

  final UniversalDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final actions = snapshot.quickActions;
    if (actions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: AppDashboardSection(
        title: context.l10n.universalDashboardQuickActions,
        card: false,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final action in actions)
              AppQuickActionCard(
                key: ValueKey('universal-action-${action.id}'),
                label: action.label,
                icon: action.icon,
                onPressed: () => context.go(action.route),
              ),
          ],
        ),
      ),
    );
  }
}

Widget? _viewAll(
  BuildContext context,
  UniversalDashboardSnapshot snapshot,
  DashboardSection section,
) {
  final route = snapshot.viewAll(section);
  if (route == null) return null;
  return AppTextButton(
    label: context.l10n.universalDashboardViewAll,
    onPressed: () => context.go(route),
  );
}

AppStatus dashboardStatus(DashboardTone tone) => switch (tone) {
  DashboardTone.neutral => AppStatus.neutral,
  DashboardTone.info => AppStatus.info,
  DashboardTone.success => AppStatus.success,
  DashboardTone.warning => AppStatus.warning,
  DashboardTone.danger => AppStatus.danger,
  DashboardTone.brand => AppStatus.brand,
};
