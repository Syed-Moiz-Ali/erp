import 'package:flutter/material.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard_repository.dart';
import 'package:modular_erp/modules/services/overview/presentation/service_dashboard_localization.dart';
import 'package:modular_erp/modules/services/services_localization.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/presentation/service_workflow_localization.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';

/// Services' public dashboard contribution.
///
/// Reuses the existing Phase 9 Services read projection
/// ([ServicesDashboardRepository]) so there is exactly one copy of the logic.
/// Every item is already permission/scope-filtered by the repository.
class ServicesDashboardContributor implements DashboardContributor {
  const ServicesDashboardContributor({required this.repository});

  final ServicesDashboardRepository repository;

  @override
  String get id => 'services';

  @override
  String get moduleId => 'services';

  @override
  int get order => 20;

  static const _viewPermissions = <AppPermission>{
    AppPermission.serviceEnquiryView,
    AppPermission.serviceEnquiryCreate,
    AppPermission.serviceJobAssignmentViewAssigned,
    AppPermission.serviceJobAssignmentViewTeam,
    AppPermission.serviceJobAssignmentViewAll,
    AppPermission.serviceJobAssignmentCreate,
    AppPermission.serviceInspectionViewAssigned,
    AppPermission.serviceInspectionViewTeam,
    AppPermission.serviceInspectionViewAll,
    AppPermission.serviceInspectionCreate,
    AppPermission.serviceMaterialRequestViewAssigned,
    AppPermission.serviceMaterialRequestViewTeam,
    AppPermission.serviceMaterialRequestViewAll,
    AppPermission.serviceMaterialRequestCreate,
    AppPermission.serviceWorkExecutionViewAssigned,
    AppPermission.serviceWorkExecutionViewTeam,
    AppPermission.serviceWorkExecutionViewAll,
    AppPermission.serviceWorkExecutionCreate,
  };

  @override
  bool isVisible(DashboardCapabilityContext context) =>
      context.moduleEnabled('services') && context.anyCan(_viewPermissions);

  @override
  Future<DashboardContribution> load(DashboardCapabilityContext context) async {
    final l = context.l10n;
    final snapshot = await repository.load(context.auth);
    final locale = Locale(l.localeName);
    final date = AppDateFormatter(locale);
    final time = AppTimeFormatter(locale);
    final numbers = AppNumberFormatter(locale);

    String? due(DateTime? value) {
      if (value == null) return null;
      final day = snapshot.today;
      final isToday =
          day != null &&
          value.year == day.year &&
          value.month == day.month &&
          value.day == day.day;
      return isToday
          ? time.time(value)
          : '${date.date(value)} · ${time.time(value)}';
    }

    String party(String customer, String site) =>
        [customer, site].where((s) => s.trim().isNotEmpty).join(' · ');

    return DashboardContribution(
      moduleId: moduleId,
      order: order,
      scopeLabel: snapshot.scope == ServicesDashboardScope.none
          ? ''
          : servicesDashboardScopeLabel(snapshot.scope, l),
      kpis: [
        if (snapshot.canViewEnquiries)
          DashboardKpi(
            id: 'services-open-enquiries',
            moduleId: moduleId,
            label: servicesDashboardKpiLabel(
              ServicesDashboardKpiKind.openEnquiries,
              l,
            ),
            value: numbers.integer(snapshot.openEnquiriesCount),
            detail: servicesDashboardKpiContext(
              ServicesDashboardKpiKind.openEnquiries,
              l,
            ),
            icon: servicesDashboardKpiIcon(
              ServicesDashboardKpiKind.openEnquiries,
            ),
            rank: 6,
            route: '${ServicesRoutes.enquiries}?status=open',
          ),
        if (snapshot.canViewAssignments)
          DashboardKpi(
            id: 'services-scheduled-assignments',
            moduleId: moduleId,
            label: servicesDashboardKpiLabel(
              ServicesDashboardKpiKind.scheduledAssignments,
              l,
            ),
            value: numbers.integer(snapshot.scheduledAssignmentsCount),
            detail: servicesDashboardKpiContext(
              ServicesDashboardKpiKind.scheduledAssignments,
              l,
            ),
            icon: servicesDashboardKpiIcon(
              ServicesDashboardKpiKind.scheduledAssignments,
            ),
            rank: 14,
            route: ServicesRoutes.assignments,
          ),
        if (snapshot.canViewInspections)
          DashboardKpi(
            id: 'services-pending-inspections',
            moduleId: moduleId,
            label: servicesDashboardKpiLabel(
              ServicesDashboardKpiKind.pendingInspections,
              l,
            ),
            value: numbers.integer(snapshot.pendingInspectionsCount),
            detail: servicesDashboardKpiContext(
              ServicesDashboardKpiKind.pendingInspections,
              l,
            ),
            icon: servicesDashboardKpiIcon(
              ServicesDashboardKpiKind.pendingInspections,
            ),
            rank: 22,
            route: '${ServicesRoutes.inspections}?status=pending',
          ),
        if (snapshot.canViewWorkExecutions)
          DashboardKpi(
            id: 'services-work-in-progress',
            moduleId: moduleId,
            label: servicesDashboardKpiLabel(
              ServicesDashboardKpiKind.workInProgress,
              l,
            ),
            value: numbers.integer(snapshot.workInProgressCount),
            detail: servicesDashboardKpiContext(
              ServicesDashboardKpiKind.workInProgress,
              l,
            ),
            icon: servicesDashboardKpiIcon(
              ServicesDashboardKpiKind.workInProgress,
            ),
            rank: 26,
            route: '${ServicesRoutes.workExecutions}?status=in_progress',
          ),
        if (snapshot.canViewMaterialRequests)
          DashboardKpi(
            id: 'services-open-material-requests',
            moduleId: moduleId,
            label: servicesDashboardKpiLabel(
              ServicesDashboardKpiKind.openMaterialRequests,
              l,
            ),
            value: numbers.integer(snapshot.openMaterialRequestsCount),
            detail: servicesDashboardKpiContext(
              ServicesDashboardKpiKind.openMaterialRequests,
              l,
            ),
            icon: servicesDashboardKpiIcon(
              ServicesDashboardKpiKind.openMaterialRequests,
            ),
            rank: 34,
            route: '${ServicesRoutes.materialRequests}?status=open',
          ),
        if (snapshot.canViewWorkExecutions)
          DashboardKpi(
            id: 'services-completed-today',
            moduleId: moduleId,
            label: servicesDashboardKpiLabel(
              ServicesDashboardKpiKind.completedToday,
              l,
            ),
            value: numbers.integer(snapshot.completedTodayCount),
            detail: servicesDashboardKpiContext(
              ServicesDashboardKpiKind.completedToday,
              l,
            ),
            icon: servicesDashboardKpiIcon(
              ServicesDashboardKpiKind.completedToday,
            ),
            rank: 50,
          ),
      ],
      attention: [
        for (final item in snapshot.attentionItems)
          DashboardAttentionItem(
            id: 'services-attention-${item.kind.name}-${item.entityId}',
            moduleId: moduleId,
            type: item.kind.name,
            title: [
              item.reference,
              servicesDashboardAttentionReason(item.kind, l),
            ].where((s) => s.trim().isNotEmpty).join(' · '),
            subtitle: [
              party(item.customerName, item.siteSummary),
              if (item.waitingMaterialCount > 0)
                '${numbers.integer(item.waitingMaterialCount)} ${l.servicesDashboardWaitingMaterials}',
              if (due(item.dueAt) != null) due(item.dueAt)!,
            ].where((s) => s.trim().isNotEmpty).join(' · '),
            icon: serviceWorkflowStageIcon(
              servicesDashboardAttentionStage(item.kind),
            ),
            tone: _tone(servicesDashboardAttentionStatus(item.kind)),
            priority: _attentionPriority(item.kind),
            date: item.dueAt,
            route: _attentionRoute(item),
          ),
      ],
      schedule: [
        for (final item in snapshot.todaySchedule)
          DashboardScheduleItem(
            id: 'services-schedule-${item.kind.name}-${item.entityId}',
            moduleId: moduleId,
            title: item.reference,
            subtitle: party(item.customerName, item.siteSummary),
            statusLabel: item.kind == ServicesScheduleKind.inspection
                ? serviceInspectionStatusLabel(
                    ServiceInspectionStatusX.fromWire(item.statusKey),
                    l,
                  )
                : l.servicesJobAssignmentStatusActive,
            icon: serviceWorkflowStageIcon(
              item.kind == ServicesScheduleKind.inspection
                  ? ServiceWorkflowStage.inspection
                  : ServiceWorkflowStage.jobAssignment,
            ),
            time: item.at ?? item.visitDate,
            dateOnly: item.at == null,
            route: item.kind == ServicesScheduleKind.inspection
                ? ServicesRoutes.inspection(item.entityId)
                : ServicesRoutes.assignment(item.entityId),
          ),
      ],
      myWork: [
        for (final item in snapshot.myWork)
          DashboardWorkItem(
            id: 'services-work-${item.kind.name}-${item.entityId}',
            moduleId: moduleId,
            title: item.reference,
            subtitle: [
              party(item.customerName, item.siteSummary),
              item.summary,
            ].where((s) => s.trim().isNotEmpty).join(' · '),
            statusLabel: _workStatus(item, l),
            actionText: item.action == null
                ? ''
                : servicesDashboardMyWorkActionLabel(item.action!, l),
            icon: item.action == null
                ? Icons.assignment_outlined
                : servicesDashboardMyWorkActionIcon(item.action!),
            route: _workRoute(item),
          ),
      ],
      team: [
        for (final row in snapshot.teamWorkload.where((row) => !row.isEmpty))
          DashboardTeamRow(
            id: 'services-team-${row.teamId}',
            moduleId: moduleId,
            label: row.teamName,
            detail: [
              '${numbers.integer(row.activeAssignments)} ${l.servicesDashboardTeamActiveSuffix}',
              '${numbers.integer(row.todayVisits)} ${l.servicesDashboardTeamTodaySuffix}',
              '${numbers.integer(row.inProgress)} ${l.servicesDashboardTeamInProgressSuffix}',
            ].join(' · '),
          ),
      ],
      breakdowns: [
        if (snapshot.workflowStages.isNotEmpty)
          DashboardBreakdown(
            moduleId: moduleId,
            title: l.servicesDashboardWorkflowOverview,
            rows: [
              for (final stage in snapshot.workflowStages)
                DashboardBreakdownRow(
                  label: serviceWorkflowStageLabel(stage.stage, l),
                  value: stage.count,
                ),
            ],
          ),
      ],
      activity: [
        for (final event in snapshot.recentActivity)
          DashboardActivityItem(
            id: 'services-activity-${event.entityType}-${event.entityId}-${event.eventType}',
            moduleId: moduleId,
            title: [
              serviceActivityEntityTypeLabel(event.entityType, l),
              event.reference,
            ].where((s) => s.trim().isNotEmpty).join(' '),
            description: serviceActivityEventLabel(event.eventType, l),
            icon: Icons.history_outlined,
            occurredAt: event.occurredAt,
          ),
      ],
      quickActions: _quickActions(context, l),
      viewAll: {
        if (snapshot.canViewInspections)
          DashboardSection.attention: ServicesRoutes.inspections
        else if (snapshot.canViewAssignments)
          DashboardSection.attention: ServicesRoutes.assignments
        else if (snapshot.canViewEnquiries)
          DashboardSection.attention: ServicesRoutes.enquiries,
        if (snapshot.canViewAssignments) ...{
          DashboardSection.schedule: ServicesRoutes.assignments,
          DashboardSection.myWork: ServicesRoutes.assignments,
        },
        if (snapshot.canViewEnquiries)
          DashboardSection.activity: ServicesRoutes.enquiries,
      },
    );
  }

  int _attentionPriority(ServicesAttentionKind kind) => switch (kind) {
    ServicesAttentionKind.visitTodayWithoutInspection => 35,
    ServicesAttentionKind.pendingInspectionToday => 25,
    ServicesAttentionKind.activeWorkLine => 30,
    ServicesAttentionKind.inspectionWaitingMaterials => 45,
    ServicesAttentionKind.openMaterialRequest => 50,
    ServicesAttentionKind.openEnquiryUnassigned => 55,
  };

  String? _attentionRoute(ServicesAttentionItem item) => switch (item.kind) {
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

  String _workStatus(ServicesMyWorkItem item, AppLocalizations l) =>
      switch (item.kind) {
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

  String _workRoute(ServicesMyWorkItem item) => switch (item.kind) {
    ServicesMyWorkKind.assignment => ServicesRoutes.assignment(item.entityId),
    ServicesMyWorkKind.inspection => ServicesRoutes.inspection(item.entityId),
    ServicesMyWorkKind.execution => ServicesRoutes.workExecution(item.entityId),
  };

  List<DashboardQuickAction> _quickActions(
    DashboardCapabilityContext context,
    AppLocalizations l,
  ) => [
    if (context.can(AppPermission.serviceEnquiryCreate))
      DashboardQuickAction(
        id: 'services-new-enquiry',
        moduleId: moduleId,
        label: l.servicesOverviewNewEnquiry,
        icon: Icons.add,
        route: ServicesRoutes.enquiriesNew,
      ),
    if (context.can(AppPermission.serviceJobAssignmentCreate))
      DashboardQuickAction(
        id: 'services-new-assignment',
        moduleId: moduleId,
        label: l.servicesDashboardQuickCreateAssignment,
        icon: Icons.assignment_ind_outlined,
        route: ServicesRoutes.assignmentsNew,
      ),
    if (context.can(AppPermission.serviceInspectionCreate))
      DashboardQuickAction(
        id: 'services-new-inspection',
        moduleId: moduleId,
        label: l.servicesDashboardQuickNewInspection,
        icon: Icons.fact_check_outlined,
        route: ServicesRoutes.inspectionsNew,
      ),
    if (context.can(AppPermission.serviceMaterialRequestCreate))
      DashboardQuickAction(
        id: 'services-new-material-request',
        moduleId: moduleId,
        label: l.servicesDashboardQuickNewMaterialRequest,
        icon: Icons.request_quote_outlined,
        route: ServicesRoutes.materialRequestsNew,
      ),
    if (context.can(AppPermission.serviceWorkExecutionCreate))
      DashboardQuickAction(
        id: 'services-new-work-execution',
        moduleId: moduleId,
        label: l.servicesDashboardQuickNewWorkExecution,
        icon: Icons.engineering_outlined,
        route: ServicesRoutes.workExecutionsNew,
      ),
  ];
}

DashboardTone _tone(AppStatus status) => switch (status) {
  AppStatus.success => DashboardTone.success,
  AppStatus.warning => DashboardTone.warning,
  AppStatus.danger => DashboardTone.danger,
  AppStatus.info => DashboardTone.info,
  AppStatus.brand => DashboardTone.brand,
  AppStatus.neutral => DashboardTone.neutral,
};
