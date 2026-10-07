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
/// Drift dependency. Sections compose by work/attention (My Day, Needs
/// Attention, KPIs, Today's Schedule, My Work, Team/Company, Recent Activity),
/// never as stacked per-module dashboards.
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

    final banners = <Widget>[
      if (state.status == UniversalDashboardStatus.refreshing)
        Semantics(
          liveRegion: true,
          label: l.universalDashboardRefreshing,
          child: const LinearProgressIndicator(minHeight: 2),
        ),
      if (snapshot.partialFailure || state.failure != null)
        _PartialBanner(
          message: l.universalDashboardPartial,
          onRetry: () => context.read<UniversalDashboardBloc>().add(
            const UniversalDashboardStarted(),
          ),
        ),
    ];

    final sections = _buildSections(context, compact: compact);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ContextRow(snapshot: snapshot),
        for (final banner in banners) ...[
          banner,
          const SizedBox(height: AppSpacing.lg),
        ],
        ...sections,
      ],
    );
  }

  List<Widget> _buildSections(BuildContext context, {required bool compact}) {
    if (_isFirstTime(snapshot)) {
      return [
        _FirstTimeEmpty(
          canCreate: snapshot.quickActions.isNotEmpty,
          onCreate: snapshot.quickActions.isEmpty
              ? null
              : () => context.go(snapshot.quickActions.first.route),
          onLeaveRequest: null,
        ),
      ];
    }
    if (!snapshot.hasAnyData) {
      return [
        AppCard(
          child: AppEmptyState(
            title: context.l10n.universalDashboardEmptyTitle,
            message: context.l10n.universalDashboardAllClear,
          ),
        ),
      ];
    }

    final myDay = _myDay(context);
    final attention = _attention(context);
    final kpis = _kpis(context);
    final schedule = _schedule(context);
    final myWork = _myWork(context);
    final overview = _overview(context);
    final activity = _activity(context);
    final quickActions = _quickActions(context);

    if (compact) {
      // Mobile priority: My Day → Needs Attention → My Work → Today's Schedule
      // → relevant KPIs → Recent Activity → optional lower-priority overview.
      return _stack([
        myDay,
        attention,
        myWork,
        schedule,
        kpis,
        activity,
        overview,
        quickActions,
      ]);
    }
    return _stack([
      myDay,
      attention,
      kpis,
      _columns([schedule, myWork]),
      overview,
      activity,
      quickActions,
    ]);
  }

  // ── Section builders (null == section has nothing to show) ────────────────

  Widget? _myDay(BuildContext context) {
    final widgets = snapshot.myDay;
    final highlight = snapshot.highlightedWork;
    if (widgets.isEmpty && highlight == null) return null;
    return AppDashboardSection(
      title: context.l10n.universalDashboardMyDay,
      card: false,
      child: AppResponsiveGrid(
        minItemWidth: 300,
        maxColumns: 2,
        children: [
          ...widgets,
          if (highlight != null) _HighlightWork(item: highlight),
        ],
      ),
    );
  }

  Widget? _attention(BuildContext context) {
    final l = context.l10n;
    final items = snapshot.attention;
    final viewAll = snapshot.viewAll(DashboardSection.attention);
    if (items.isEmpty && viewAll == null) return null;
    return AppDashboardSection(
      title: l.universalDashboardNeedsAttention,
      action: viewAll == null
          ? null
          : AppTextButton(
              label: l.universalDashboardViewAll,
              onPressed: () => context.go(viewAll),
            ),
      child: items.isEmpty
          ? AppDashboardEmptySection(message: l.universalDashboardAllClear)
          : AppAttentionList(
              children: [
                for (final item in items)
                  AppDashboardAttentionRow(
                    key: ValueKey('universal-attention-${item.id}'),
                    icon: item.icon,
                    category: item.categoryLabel,
                    title: item.title,
                    subtitle: item.subtitle,
                    meta: _timeMeta(context, item.date, snapshot.today),
                    priorityLabel: item.priorityLabel,
                    status: dashboardStatus(item.tone),
                    actionLabel: item.route == null
                        ? null
                        : (item.actionText.isEmpty
                              ? l.universalDashboardOpen
                              : item.actionText),
                    onAction: item.route == null
                        ? null
                        : () => context.go(item.route!),
                  ),
              ],
            ),
    );
  }

  Widget? _kpis(BuildContext context) {
    final kpis = snapshot.kpis;
    if (kpis.isEmpty) return null;
    return AppDashboardSection(
      title: context.l10n.universalDashboardMetrics,
      card: false,
      child: AppDashboardGrid(
        children: [
          for (final kpi in kpis)
            AppDashboardMetricCard(
              key: ValueKey('universal-kpi-${kpi.id}'),
              label: kpi.label,
              value: kpi.value,
              detail: kpi.detail,
              icon: kpi.icon,
              status: dashboardStatus(kpi.tone),
              onTap: kpi.route == null ? null : () => context.go(kpi.route!),
            ),
        ],
      ),
    );
  }

  Widget? _schedule(BuildContext context) {
    final l = context.l10n;
    final items = snapshot.schedule;
    final viewAll = snapshot.viewAll(DashboardSection.schedule);
    if (items.isEmpty && viewAll == null) return null;
    return AppDashboardSection(
      title: l.universalDashboardSchedule,
      action: viewAll == null
          ? null
          : AppTextButton(
              label: l.universalDashboardViewAll,
              onPressed: () => context.go(viewAll),
            ),
      child: AppDashboardTimeline(
        emptyMessage: l.universalDashboardNoSchedule,
        entries: [
          for (final item in items)
            AppDashboardTimelineEntry(
              timeLabel: _scheduleTime(context, item),
              title: item.title,
              subtitle: item.subtitle,
              statusLabel: item.statusLabel,
              status: dashboardStatus(item.tone),
              icon: item.icon,
              onTap: item.route == null ? null : () => context.go(item.route!),
            ),
        ],
      ),
    );
  }

  Widget? _myWork(BuildContext context) {
    final l = context.l10n;
    final items = snapshot.myWork;
    final viewAll = snapshot.viewAll(DashboardSection.myWork);
    if (items.isEmpty && viewAll == null) return null;
    return AppDashboardSection(
      title: l.universalDashboardMyWork,
      action: viewAll == null
          ? null
          : AppTextButton(
              label: l.universalDashboardViewAll,
              onPressed: () => context.go(viewAll),
            ),
      child: items.isEmpty
          ? AppDashboardEmptySection(message: l.universalDashboardNoWork)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  AppDashboardWorkRow(
                    key: ValueKey('universal-work-${items[i].id}'),
                    title: items[i].title,
                    subtitle: items[i].subtitle,
                    statusLabel: items[i].statusLabel,
                    icon: items[i].icon,
                    status: dashboardStatus(items[i].tone),
                    actionLabel: items[i].route == null
                        ? null
                        : (items[i].actionText.isEmpty
                              ? l.universalDashboardOpen
                              : items[i].actionText),
                    onAction: items[i].route == null
                        ? null
                        : () => context.go(items[i].route!),
                  ),
                ],
              ],
            ),
    );
  }

  Widget? _overview(BuildContext context) {
    final team = snapshot.team;
    final breakdowns = snapshot.breakdowns;
    if (team.isEmpty && breakdowns.isEmpty) return null;
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
                  if (i > 0) const Divider(height: 1),
                  AppDashboardWorkRow(
                    title: team[i].label,
                    subtitle: team[i].detail,
                    icon: Icons.groups_outlined,
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
            child: AppDashboardStageStrip(
              stages: [
                for (final row in breakdowns[b].rows)
                  AppDashboardStage(
                    label: row.label,
                    value: AppNumberFormatter(
                      Localizations.localeOf(context),
                    ).integer(row.value),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget? _activity(BuildContext context) {
    final l = context.l10n;
    final items = snapshot.activity;
    final viewAll = snapshot.viewAll(DashboardSection.activity);
    if (items.isEmpty && viewAll == null) return null;
    final locale = Localizations.localeOf(context);
    final dates = AppDateFormatter(locale);
    return AppDashboardSection(
      title: l.universalDashboardRecentActivity,
      action: viewAll == null
          ? null
          : AppTextButton(
              label: l.universalDashboardViewAll,
              onPressed: () => context.go(viewAll),
            ),
      child: items.isEmpty
          ? AppDashboardEmptySection(message: l.universalDashboardNoActivity)
          : AppAttentionList(
              children: [
                for (final item in items)
                  AppDashboardActivityRow(
                    key: ValueKey('universal-activity-${item.id}'),
                    icon: item.icon,
                    title: item.title,
                    description: item.description,
                    moduleLabel: item.moduleLabel,
                    status: dashboardStatus(item.tone),
                    timestamp: dates.relative(item.occurredAt, l),
                    onTap: item.route == null
                        ? null
                        : () => context.go(item.route!),
                  ),
              ],
            ),
    );
  }

  Widget? _quickActions(BuildContext context) {
    final actions = snapshot.quickActions;
    if (actions.isEmpty) return null;
    return AppDashboardSection(
      title: context.l10n.universalDashboardQuickActions,
      card: false,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final action in actions)
            AppSecondaryButton(
              key: ValueKey('universal-action-${action.id}'),
              label: action.label,
              icon: action.icon,
              onPressed: () => context.go(action.route),
            ),
        ],
      ),
    );
  }

  bool _isFirstTime(UniversalDashboardSnapshot snapshot) {
    if (snapshot.myDay.isNotEmpty) return false;
    if (snapshot.highlightedWork != null) return false;
    if (snapshot.attention.isNotEmpty ||
        snapshot.schedule.isNotEmpty ||
        snapshot.myWork.isNotEmpty ||
        snapshot.team.isNotEmpty ||
        snapshot.breakdowns.isNotEmpty ||
        snapshot.activity.isNotEmpty) {
      return false;
    }
    final kpis = snapshot.kpis;
    if (kpis.isEmpty) return false;
    return kpis.every((kpi) => kpi.value.trim() == '0');
  }
}

/// Reflows two sections into columns, dropping any empty side so a blank
/// column is never left behind (§65).
Widget? _columns(List<Widget?> sections) {
  final present = sections.whereType<Widget>().toList();
  if (present.isEmpty) return null;
  if (present.length == 1) return present.first;
  return AppDashboardTwoColumn(primary: present[0], secondary: present[1]);
}

/// Stacks non-null sections with a consistent vertical rhythm.
List<Widget> _stack(List<Widget?> sections) {
  final present = sections.whereType<Widget>().toList();
  final output = <Widget>[];
  for (var i = 0; i < present.length; i++) {
    if (i > 0) output.add(const SizedBox(height: AppSpacing.xxl));
    output.add(present[i]);
  }
  return output;
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

class _PartialBanner extends StatelessWidget {
  const _PartialBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: AppAlert(message: message, status: AppStatus.warning),
      ),
      const SizedBox(width: AppSpacing.sm),
      AppTextButton(
        label: context.l10n.retry,
        size: AppButtonSize.small,
        onPressed: onRetry,
      ),
    ],
  );
}

class _FirstTimeEmpty extends StatelessWidget {
  const _FirstTimeEmpty({
    required this.canCreate,
    this.onCreate,
    this.onLeaveRequest,
  });

  final bool canCreate;
  final VoidCallback? onCreate;
  final VoidCallback? onLeaveRequest;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      child: AppEmptyState(
        title: l.universalDashboardFirstTimeTitle,
        message: l.universalDashboardFirstTimeMessage,
        icon: Icons.rocket_launch_outlined,
        actionLabel: canCreate ? l.universalDashboardGetStarted : null,
        onAction: canCreate ? onCreate : null,
      ),
    );
  }
}

/// Compact highlight of the immediate next assigned task inside My Day.
class _HighlightWork extends StatelessWidget {
  const _HighlightWork({required this.item});

  final DashboardWorkItem item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                item.icon,
                size: 16,
                color: isDark ? AppColors.darkBrand : AppColors.brandPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l.universalDashboardNextServiceWork,
                  style: theme.caption.copyWith(
                    fontWeight: AppTypography.weightSemibold,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (item.statusLabel.isNotEmpty)
                AppStatusBadge(
                  label: item.statusLabel,
                  status: dashboardStatus(item.tone),
                  isPill: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.bodyLarge.copyWith(
              fontWeight: AppTypography.weightSemibold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (item.subtitle.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.caption,
            ),
          ],
          if (item.route != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppSecondaryButton(
              label: item.actionText.isEmpty
                  ? l.universalDashboardOpen
                  : item.actionText,
              icon: item.icon,
              size: AppButtonSize.small,
              onPressed: () => context.go(item.route!),
            ),
          ],
        ],
      ),
    );
  }
}

String _timeMeta(BuildContext context, DateTime? value, DateTime? today) {
  if (value == null) return '';
  final locale = Localizations.localeOf(context);
  // "Today" is the company-local business date resolved by the coordinator
  // (AppClock + CompanyTimeService); the device clock is never consulted.
  final isToday =
      today != null &&
      value.year == today.year &&
      value.month == today.month &&
      value.day == today.day;
  final time = AppTimeFormatter(locale).time(value);
  return isToday ? time : '${AppDateFormatter(locale).date(value)} · $time';
}

String _scheduleTime(BuildContext context, DashboardScheduleItem item) {
  final time = item.time;
  if (time == null) return '—';
  final locale = Localizations.localeOf(context);
  return item.dateOnly
      ? AppDateFormatter(locale).date(time)
      : AppTimeFormatter(locale).time(time);
}

AppStatus dashboardStatus(DashboardTone tone) => switch (tone) {
  DashboardTone.neutral => AppStatus.neutral,
  DashboardTone.info => AppStatus.info,
  DashboardTone.success => AppStatus.success,
  DashboardTone.warning => AppStatus.warning,
  DashboardTone.danger => AppStatus.danger,
  DashboardTone.brand => AppStatus.brand,
};
