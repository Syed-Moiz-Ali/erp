import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/modules/services/overview/presentation/bloc/service_dashboard_cubit.dart';
import 'package:modular_erp/modules/services/overview/presentation/service_dashboard_localization.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/presentation/service_workflow_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// The Services operational dashboard (module Overview page).
///
/// Read-only operational control center: every card, section and action is
/// permission/scope-gated and derived from the real Services workflow.
class ServiceDashboardPage extends StatelessWidget {
  const ServiceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.isAuthenticated &&
          current.context != null &&
          !_sameIdentity(previous.context, current.context),
      listener: (context, state) =>
          context.read<ServiceDashboardCubit>().updateContext(state.context!),
      child: BlocBuilder<ServiceDashboardCubit, ServiceDashboardState>(
        builder: (context, state) {
          final l = context.l10n;
          final cubit = context.read<ServiceDashboardCubit>();
          final auth = cubit.context;
          bool can(AppPermission permission) =>
              auth.user.permissions.contains(permission);
          final header = AppPageHeader(
            title: l.servicesPermModuleServices,
            subtitle: l.servicesDashboardSubtitle,
            actions: [
              if (can(AppPermission.serviceEnquiryCreate))
                AppPrimaryButton(
                  label: l.servicesOverviewNewEnquiry,
                  icon: Icons.add,
                  onPressed: () => context.go(ServicesRoutes.enquiriesNew),
                ),
            ],
          );
          if (state.loading && state.snapshot == null) {
            return AppPage(header: header, child: const AppDashboardSkeleton());
          }
          if (state.hasError) {
            return AppPage(
              header: header,
              child: AppCard(
                child: AppErrorState(
                  message: l.servicesDashboardError,
                  onRetry: cubit.retry,
                ),
              ),
            );
          }
          final snapshot = state.snapshot ?? ServicesDashboardSnapshot.empty;
          return AppPage(
            header: header,
            child: _DashboardBody(snapshot: snapshot, auth: auth),
          );
        },
      ),
    );
  }

  static bool _sameIdentity(AuthContext? a, AuthContext? b) {
    if (a == null || b == null) return a == b;
    return a.company.id == b.company.id && a.user.id == b.user.id;
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.snapshot, required this.auth});
  final ServicesDashboardSnapshot snapshot;
  final AuthContext auth;

  @override
  Widget build(BuildContext context) {
    final size = AppBreakpoints.of(context);
    final scopeBar = _ContextBar(snapshot: snapshot);
    if (!snapshot.hasAnyData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          scopeBar,
          const SizedBox(height: AppSpacing.xl),
          AppCard(child: _EmptyDashboard(snapshot: snapshot)),
        ],
      );
    }

    final kpis = _KpiGrid(snapshot: snapshot, auth: auth);
    final attention = _AttentionSection(snapshot: snapshot, auth: auth);
    final schedule = _ScheduleSection(snapshot: snapshot, auth: auth);
    final myWork = _MyWorkSection(snapshot: snapshot, auth: auth);
    final team = _TeamWorkloadSection(snapshot: snapshot, auth: auth);
    final workflow = _WorkflowSection(snapshot: snapshot);
    final activity = _ActivitySection(snapshot: snapshot);
    final quickActions = _QuickActions(auth: auth);

    if (size == AppSize.compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          scopeBar,
          const SizedBox(height: AppSpacing.xl),
          attention,
          const SizedBox(height: AppSpacing.xxl),
          myWork,
          const SizedBox(height: AppSpacing.xxl),
          schedule,
          const SizedBox(height: AppSpacing.xxl),
          kpis,
          const SizedBox(height: AppSpacing.xxl),
          team,
          const SizedBox(height: AppSpacing.xxl),
          workflow,
          const SizedBox(height: AppSpacing.xxl),
          quickActions,
          const SizedBox(height: AppSpacing.xxl),
          activity,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        scopeBar,
        const SizedBox(height: AppSpacing.xl),
        kpis,
        const SizedBox(height: AppSpacing.xl),
        quickActions,
        const SizedBox(height: AppSpacing.xxl),
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
              team,
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        workflow,
        const SizedBox(height: AppSpacing.xxl),
        activity,
      ],
    );
  }
}

class _ContextBar extends StatelessWidget {
  const _ContextBar({required this.snapshot});
  final ServicesDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context);
    final children = <Widget>[
      AppStatusBadge(
        label: servicesDashboardScopeLabel(snapshot.scope, l),
        status: AppStatus.neutral,
        icon: Icons.visibility_outlined,
        isPill: true,
      ),
    ];
    final today = snapshot.today;
    if (today != null) {
      children.add(
        AppStatusBadge(
          label: [
            l.servicesDashboardToday,
            AppDateFormatter(locale).date(today),
          ].join(' · '),
          status: AppStatus.neutral,
          icon: Icons.calendar_today_outlined,
          isPill: true,
        ),
      );
    }
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: children,
    );
  }
}

// ----------------------------------------------------------------- KPI grid

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.snapshot, required this.auth});
  final ServicesDashboardSnapshot snapshot;
  final AuthContext auth;

  bool _can(AppPermission permission) =>
      auth.user.permissions.contains(permission);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final numbers = AppNumberFormatter(Localizations.localeOf(context));
    final cards = <Widget>[];
    void add(
      ServicesDashboardKpiKind kind,
      int value, {
      bool visible = true,
      String? route,
      bool authorized = false,
    }) {
      if (!visible) return;
      cards.add(
        AppMetricCard(
          label: servicesDashboardKpiLabel(kind, l),
          value: numbers.integer(value),
          detail: servicesDashboardKpiContext(kind, l),
          icon: servicesDashboardKpiIcon(kind),
          onTap: authorized && route != null ? () => context.go(route) : null,
        ),
      );
    }

    add(
      ServicesDashboardKpiKind.openEnquiries,
      snapshot.openEnquiriesCount,
      visible: snapshot.canViewEnquiries,
      route: '${ServicesRoutes.enquiries}?status=open',
      authorized: _can(AppPermission.serviceEnquiryView),
    );
    add(
      ServicesDashboardKpiKind.scheduledAssignments,
      snapshot.scheduledAssignmentsCount,
      visible: snapshot.canViewAssignments,
      route: ServicesRoutes.assignments,
      authorized: true,
    );
    add(
      ServicesDashboardKpiKind.pendingInspections,
      snapshot.pendingInspectionsCount,
      visible: snapshot.canViewInspections,
      route: '${ServicesRoutes.inspections}?status=pending',
      authorized: true,
    );
    add(
      ServicesDashboardKpiKind.openMaterialRequests,
      snapshot.openMaterialRequestsCount,
      visible: snapshot.canViewMaterialRequests,
      route: '${ServicesRoutes.materialRequests}?status=open',
      authorized: true,
    );
    add(
      ServicesDashboardKpiKind.workInProgress,
      snapshot.workInProgressCount,
      visible: snapshot.canViewWorkExecutions,
      route: '${ServicesRoutes.workExecutions}?status=in_progress',
      authorized: true,
    );
    add(
      ServicesDashboardKpiKind.completedToday,
      snapshot.completedTodayCount,
      visible: snapshot.canViewWorkExecutions,
    );
    if (cards.isEmpty) return const SizedBox.shrink();
    return AppDashboardGrid(children: cards);
  }
}

// ------------------------------------------------------------ needs attention

class _AttentionSection extends StatelessWidget {
  const _AttentionSection({required this.snapshot, required this.auth});
  final ServicesDashboardSnapshot snapshot;
  final AuthContext auth;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDashboardSection(
      title: l.servicesDashboardNeedsAttention,
      child: snapshot.attentionItems.isEmpty
          ? _CompactEmpty(message: l.servicesDashboardAllCaughtUp)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < snapshot.attentionItems.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                    ),
                  _AttentionRow(
                    item: snapshot.attentionItems[i],
                    today: snapshot.today,
                  ),
                ],
              ],
            ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.item, this.today});
  final ServicesAttentionItem item;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context);
    final stage = servicesDashboardAttentionStage(item.kind);
    final reason = servicesDashboardAttentionReason(item.kind, l);
    final status = servicesDashboardAttentionStatus(item.kind);
    final due = item.dueAt;
    final subtitleParts = [
      item.customerName,
      if (item.siteSummary.isNotEmpty) item.siteSummary,
    ].where((s) => s.trim().isNotEmpty);
    final contextParts = <String>[
      if (due != null) _formatDue(locale, due),
      if (item.waitingMaterialCount > 0)
        [
          item.waitingMaterialCount.toString(),
          l.servicesDashboardWaitingMaterials,
        ].join(' '),
    ];
    final route = _route(item);
    return Semantics(
      button: route != null,
      label: [item.reference, reason].join(', '),
      child: InkWell(
        onTap: route == null ? null : () => context.go(route),
        hoverColor: AppColors.surfaceHover,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                ),
                child: Icon(
                  serviceWorkflowStageIcon(stage),
                  size: 16,
                  color: status.color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.reference,
                          style: AppTypography.of(context).bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AppStatusBadge(
                          label: serviceWorkflowStageLabel(stage, l),
                          status: status,
                          isPill: true,
                        ),
                        if (item.priorityName.isNotEmpty)
                          AppStatusBadge(
                            label: item.priorityName,
                            status: servicePriorityStatus(item.priorityRank),
                            isPill: true,
                          ),
                      ],
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitleParts.join(' · '),
                        style: AppTypography.of(context).caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      contextParts.isEmpty
                          ? reason
                          : [reason, contextParts.join(' · ')].join(' — '),
                      style: AppTypography.of(
                        context,
                      ).caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (route != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDue(Locale locale, DateTime due) {
    final isToday =
        today != null &&
        due.year == today!.year &&
        due.month == today!.month &&
        due.day == today!.day;
    final date = isToday
        ? AppTimeFormatter(locale).time(due)
        : [
            AppDateFormatter(locale).date(due),
            AppTimeFormatter(locale).time(due),
          ].join(' · ');
    return date;
  }

  String? _route(ServicesAttentionItem item) => switch (item.kind) {
    ServicesAttentionKind.openEnquiryUnassigned => ServicesRoutes.enquiry(
      item.entityId,
    ),
    ServicesAttentionKind.visitTodayWithoutInspection =>
      ServicesRoutes.assignment(item.entityId),
    ServicesAttentionKind.pendingInspectionToday ||
    ServicesAttentionKind.inspectionWaitingMaterials =>
      ServicesRoutes.inspection(item.entityId),
    ServicesAttentionKind.openMaterialRequest => ServicesRoutes.materialRequest(
      item.entityId,
    ),
    ServicesAttentionKind.activeWorkLine => ServicesRoutes.workExecution(
      item.entityId,
    ),
  };
}

// -------------------------------------------------------------- schedule

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.snapshot, required this.auth});
  final ServicesDashboardSnapshot snapshot;
  final AuthContext auth;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDashboardSection(
      title: l.servicesDashboardTodaySchedule,
      child: snapshot.todaySchedule.isEmpty
          ? _CompactEmpty(message: l.servicesDashboardNoSchedule)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < snapshot.todaySchedule.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                    ),
                  _ScheduleRow(item: snapshot.todaySchedule[i]),
                ],
              ],
            ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.item});
  final ServicesScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context);
    final time = item.at;
    final isInspection = item.kind == ServicesScheduleKind.inspection;
    final stage = isInspection
        ? ServiceWorkflowStage.inspection
        : ServiceWorkflowStage.jobAssignment;
    final statusLabel = isInspection
        ? serviceInspectionStatusLabel(
            ServiceInspectionStatusX.fromWire(item.statusKey),
            l,
          )
        : l.servicesJobAssignmentStatusActive;
    final status = isInspection
        ? serviceInspectionStatus(
            ServiceInspectionStatusX.fromWire(item.statusKey),
          )
        : serviceJobAssignmentStatus(
            ServiceJobAssignmentStatusX.fromWire(item.statusKey),
          );
    final route = isInspection
        ? ServicesRoutes.inspection(item.entityId)
        : ServicesRoutes.assignment(item.entityId);
    final subtitle = [
      item.customerName,
      if (item.siteSummary.isNotEmpty) item.siteSummary,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    return InkWell(
      onTap: () => context.go(route),
      hoverColor: AppColors.surfaceHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 68,
              child: Text(
                time == null ? '—' : AppTimeFormatter(locale).time(time),
                style: AppTypography.of(context).bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        item.reference,
                        style: AppTypography.of(context).bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppStatusBadge(
                        label: serviceWorkflowStageLabel(stage, l),
                        status: AppStatus.neutral,
                        isPill: true,
                      ),
                      AppStatusBadge(
                        label: statusLabel,
                        status: status,
                        isPill: true,
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTypography.of(context).caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.complaint.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.complaint,
                      style: AppTypography.of(
                        context,
                      ).caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.assignedSummary.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.assignedSummary,
                      style: AppTypography.of(
                        context,
                      ).caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- my work

class _MyWorkSection extends StatelessWidget {
  const _MyWorkSection({required this.snapshot, required this.auth});
  final ServicesDashboardSnapshot snapshot;
  final AuthContext auth;

  bool _enabled() =>
      auth.employeeReference != null ||
      snapshot.canViewAssignments ||
      snapshot.canViewInspections ||
      snapshot.canViewWorkExecutions;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!_enabled()) return const SizedBox.shrink();
    return AppDashboardSection(
      title: l.servicesDashboardMyWork,
      child: snapshot.myWork.isEmpty
          ? _CompactEmpty(message: l.servicesDashboardNoMyWork)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < snapshot.myWork.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                    ),
                  _MyWorkRow(item: snapshot.myWork[i]),
                ],
              ],
            ),
    );
  }
}

class _MyWorkRow extends StatelessWidget {
  const _MyWorkRow({required this.item});
  final ServicesMyWorkItem item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final route = switch (item.kind) {
      ServicesMyWorkKind.assignment => ServicesRoutes.assignment(item.entityId),
      ServicesMyWorkKind.inspection => ServicesRoutes.inspection(item.entityId),
      ServicesMyWorkKind.execution => ServicesRoutes.workExecution(
        item.entityId,
      ),
    };
    final statusLabel = switch (item.kind) {
      ServicesMyWorkKind.assignment => l.servicesJobAssignmentStatusActive,
      ServicesMyWorkKind.inspection => serviceInspectionStatusLabel(
        ServiceInspectionStatusX.fromWire(item.statusKey),
        l,
      ),
      ServicesMyWorkKind.execution => serviceWorkExecutionStatusLabel(
        ServiceWorkExecutionStatusX.fromWire(item.statusKey),
        l,
      ),
    };
    final subtitle = [
      item.customerName,
      if (item.siteSummary.isNotEmpty) item.siteSummary,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
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
                  item.reference,
                  style: AppTypography.of(context).bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.of(context).caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  statusLabel,
                  style: AppTypography.of(
                    context,
                  ).caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (item.action != null) ...[
            Flexible(
              child: AppSecondaryButton(
                label: servicesDashboardMyWorkActionLabel(item.action!, l),
                icon: servicesDashboardMyWorkActionIcon(item.action!),
                size: AppButtonSize.small,
                onPressed: () => context.go(route),
              ),
            ),
          ] else ...[
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------- team workload

class _TeamWorkloadSection extends StatelessWidget {
  const _TeamWorkloadSection({required this.snapshot, required this.auth});
  final ServicesDashboardSnapshot snapshot;
  final AuthContext auth;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = snapshot.teamWorkload.where((row) => !row.isEmpty).toList();
    if (!snapshot.canViewAssignments ||
        (snapshot.scope != ServicesDashboardScope.team &&
            snapshot.scope != ServicesDashboardScope.all)) {
      return const SizedBox.shrink();
    }
    return AppDashboardSection(
      title: l.servicesDashboardTeamWorkload,
      child: rows.isEmpty
          ? _CompactEmpty(message: l.servicesDashboardNoTeamWorkload)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                    ),
                  _TeamWorkloadRowView(row: rows[i], max: _max(rows)),
                ],
              ],
            ),
    );
  }

  int _max(List<ServicesTeamWorkloadRow> rows) {
    var max = 1;
    for (final row in rows) {
      if (row.activeAssignments > max) max = row.activeAssignments;
      if (row.inProgress > max) max = row.inProgress;
    }
    return max;
  }
}

class _TeamWorkloadRowView extends StatelessWidget {
  const _TeamWorkloadRowView({required this.row, required this.max});
  final ServicesTeamWorkloadRow row;
  final int max;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final numbers = AppNumberFormatter(Localizations.localeOf(context));
    final counts = [
      [
        numbers.integer(row.activeAssignments),
        l.servicesDashboardTeamActiveSuffix,
      ].join(' '),
      [
        numbers.integer(row.todayVisits),
        l.servicesDashboardTeamTodaySuffix,
      ].join(' '),
      [
        numbers.integer(row.inProgress),
        l.servicesDashboardTeamInProgressSuffix,
      ].join(' '),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.teamName,
            style: AppTypography.of(context).bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            counts.join(' · '),
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          _Bar(value: row.activeAssignments, max: max, status: AppStatus.brand),
          const SizedBox(height: AppSpacing.xxs),
          _Bar(value: row.inProgress, max: max, status: AppStatus.success),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.max, required this.status});
  final int value, max;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Semantics(
      label: value.toString(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        child: Container(
          height: 6,
          color: AppColors.surfaceSubtle,
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: fraction,
            child: Container(color: status.color),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------ workflow overview

class _WorkflowSection extends StatelessWidget {
  const _WorkflowSection({required this.snapshot});
  final ServicesDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (snapshot.workflowStages.isEmpty) return const SizedBox.shrink();
    var max = 1;
    for (final stage in snapshot.workflowStages) {
      if (stage.count > max) max = stage.count;
    }
    final numbers = AppNumberFormatter(Localizations.localeOf(context));
    final total = snapshot.workflowStages.fold<int>(
      0,
      (sum, stage) => sum + stage.count,
    );
    return AppDashboardSection(
      title: l.servicesDashboardWorkflowOverview,
      subtitle: l.servicesOverviewWorkflowTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < snapshot.workflowStages.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _WorkflowStageRow(
              stage: snapshot.workflowStages[i],
              max: max,
              valueLabel: numbers.integer(snapshot.workflowStages[i].count),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            [
              l.servicesDashboardKpiScheduledJobsContext,
              numbers.integer(total),
            ].join(' '),
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _WorkflowStageRow extends StatelessWidget {
  const _WorkflowStageRow({
    required this.stage,
    required this.max,
    required this.valueLabel,
  });
  final ServicesWorkflowStageCount stage;
  final int max;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final optional = stage.stage.isOptional;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    serviceWorkflowStageIcon(stage.stage),
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      serviceWorkflowStageLabel(stage.stage, l),
                      style: AppTypography.of(context).caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (optional) ...[
                    AppStatusBadge(
                      label: l.servicesWorkflowOptional,
                      status: AppStatus.neutral,
                      isPill: true,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    valueLabel,
                    style: AppTypography.of(context).bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              _Bar(value: stage.count, max: max, status: AppStatus.brand),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------- recent activity

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.snapshot});
  final ServicesDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context);
    return AppDashboardSection(
      title: l.servicesDashboardRecentActivity,
      child: snapshot.recentActivity.isEmpty
          ? _CompactEmpty(message: l.servicesDashboardNoActivity)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final event in snapshot.recentActivity)
                  AppActivityItem(
                    icon: Icons.history_outlined,
                    title: [
                      serviceActivityEntityTypeLabel(event.entityType, l),
                      if (event.reference.isNotEmpty) event.reference,
                    ].join(' '),
                    description: serviceActivityEventLabel(event.eventType, l),
                    timestamp: AppDateFormatter(
                      locale,
                    ).relative(event.occurredAt, l, now: snapshot.today),
                  ),
              ],
            ),
    );
  }
}

// ----------------------------------------------------------- quick actions

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.auth});
  final AuthContext auth;

  bool _can(AppPermission permission) =>
      auth.user.permissions.contains(permission);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final actions = <Widget>[
      if (_can(AppPermission.serviceEnquiryCreate))
        AppQuickActionCard(
          label: l.servicesOverviewNewEnquiry,
          icon: Icons.add,
          onPressed: () => context.go(ServicesRoutes.enquiriesNew),
        ),
      if (_can(AppPermission.serviceJobAssignmentCreate))
        AppQuickActionCard(
          label: l.servicesDashboardQuickCreateAssignment,
          icon: Icons.assignment_ind_outlined,
          onPressed: () => context.go(ServicesRoutes.assignmentsNew),
        ),
      if (_can(AppPermission.serviceInspectionCreate))
        AppQuickActionCard(
          label: l.servicesDashboardQuickNewInspection,
          icon: Icons.fact_check_outlined,
          onPressed: () => context.go(ServicesRoutes.inspectionsNew),
        ),
      if (_can(AppPermission.serviceMaterialRequestCreate))
        AppQuickActionCard(
          label: l.servicesDashboardQuickNewMaterialRequest,
          icon: Icons.request_quote_outlined,
          onPressed: () => context.go(ServicesRoutes.materialRequestsNew),
        ),
      if (_can(AppPermission.serviceWorkExecutionCreate))
        AppQuickActionCard(
          label: l.servicesDashboardQuickNewWorkExecution,
          icon: Icons.engineering_outlined,
          onPressed: () => context.go(ServicesRoutes.workExecutionsNew),
        ),
    ];
    if (actions.isEmpty) return const SizedBox.shrink();
    return AppDashboardSection(
      title: l.servicesDashboardQuickActions,
      card: false,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: actions,
      ),
    );
  }
}

// ----------------------------------------------------------------- empty

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.snapshot});
  final ServicesDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final assignedOnly =
        snapshot.scope == ServicesDashboardScope.assigned &&
        !snapshot.canCreateEnquiry;
    return AppEmptyState(
      title: assignedOnly
          ? l.servicesDashboardEmptyAssignedTitle
          : l.servicesDashboardEmptyTitle,
      message: assignedOnly
          ? l.servicesDashboardEmptyAssignedMessage
          : l.servicesDashboardEmptyMessage,
      icon: Icons.cleaning_services_outlined,
      actionLabel: snapshot.canCreateEnquiry
          ? l.servicesOverviewNewEnquiry
          : null,
      onAction: snapshot.canCreateEnquiry
          ? () => context.go(ServicesRoutes.enquiriesNew)
          : null,
    );
  }
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Text(
      message,
      style: AppTypography.of(
        context,
      ).caption.copyWith(color: AppColors.textMuted),
    ),
  );
}
