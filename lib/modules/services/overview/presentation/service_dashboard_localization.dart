import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/overview/domain/services_dashboard.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';

/// Localizes the Services dashboard read model. Presentation only: no English
/// sentence is stored anywhere in the model.

String servicesDashboardScopeLabel(
  ServicesDashboardScope scope,
  AppLocalizations l,
) => switch (scope) {
  ServicesDashboardScope.assigned => l.servicesDashboardScopeAssigned,
  ServicesDashboardScope.team => l.servicesDashboardScopeTeam,
  ServicesDashboardScope.all => l.servicesDashboardScopeAll,
  ServicesDashboardScope.none => l.servicesDashboardScopeNone,
};

String servicesDashboardKpiLabel(
  ServicesDashboardKpiKind kind,
  AppLocalizations l,
) => switch (kind) {
  ServicesDashboardKpiKind.openEnquiries => l.servicesDashboardKpiOpenEnquiries,
  ServicesDashboardKpiKind.scheduledAssignments =>
    l.servicesDashboardKpiScheduledJobs,
  ServicesDashboardKpiKind.pendingInspections =>
    l.servicesDashboardKpiPendingInspections,
  ServicesDashboardKpiKind.openMaterialRequests =>
    l.servicesDashboardKpiOpenMaterialRequests,
  ServicesDashboardKpiKind.workInProgress =>
    l.servicesDashboardKpiWorkInProgress,
  ServicesDashboardKpiKind.completedToday =>
    l.servicesDashboardKpiCompletedToday,
};

String servicesDashboardKpiContext(
  ServicesDashboardKpiKind kind,
  AppLocalizations l,
) => switch (kind) {
  ServicesDashboardKpiKind.openEnquiries =>
    l.servicesDashboardKpiOpenEnquiriesContext,
  ServicesDashboardKpiKind.scheduledAssignments =>
    l.servicesDashboardKpiScheduledJobsContext,
  ServicesDashboardKpiKind.pendingInspections =>
    l.servicesDashboardKpiPendingInspectionsContext,
  ServicesDashboardKpiKind.openMaterialRequests =>
    l.servicesDashboardKpiOpenMaterialRequestsContext,
  ServicesDashboardKpiKind.workInProgress =>
    l.servicesDashboardKpiWorkInProgressContext,
  ServicesDashboardKpiKind.completedToday =>
    l.servicesDashboardKpiCompletedTodayContext,
};

IconData servicesDashboardKpiIcon(ServicesDashboardKpiKind kind) =>
    switch (kind) {
      ServicesDashboardKpiKind.openEnquiries => Icons.support_agent_outlined,
      ServicesDashboardKpiKind.scheduledAssignments =>
        Icons.assignment_ind_outlined,
      ServicesDashboardKpiKind.pendingInspections => Icons.fact_check_outlined,
      ServicesDashboardKpiKind.openMaterialRequests =>
        Icons.request_quote_outlined,
      ServicesDashboardKpiKind.workInProgress => Icons.play_circle_outline,
      ServicesDashboardKpiKind.completedToday => Icons.task_alt_outlined,
    };

String servicesDashboardAttentionReason(
  ServicesAttentionKind kind,
  AppLocalizations l,
) => switch (kind) {
  ServicesAttentionKind.openEnquiryUnassigned =>
    l.servicesDashboardAttentionOpenEnquiry,
  ServicesAttentionKind.visitTodayWithoutInspection =>
    l.servicesDashboardAttentionVisitNoInspection,
  ServicesAttentionKind.pendingInspectionToday =>
    l.servicesDashboardAttentionInspectionToday,
  ServicesAttentionKind.inspectionWaitingMaterials =>
    l.servicesDashboardAttentionWaitingMaterials,
  ServicesAttentionKind.openMaterialRequest =>
    l.servicesDashboardAttentionOpenMaterialRequest,
  ServicesAttentionKind.activeWorkLine =>
    l.servicesDashboardAttentionActiveWork,
};

ServiceWorkflowStage servicesDashboardAttentionStage(
  ServicesAttentionKind kind,
) => switch (kind) {
  ServicesAttentionKind.openEnquiryUnassigned => ServiceWorkflowStage.enquiry,
  ServicesAttentionKind.visitTodayWithoutInspection =>
    ServiceWorkflowStage.jobAssignment,
  ServicesAttentionKind.pendingInspectionToday ||
  ServicesAttentionKind.inspectionWaitingMaterials =>
    ServiceWorkflowStage.inspection,
  ServicesAttentionKind.openMaterialRequest =>
    ServiceWorkflowStage.materialRequest,
  ServicesAttentionKind.activeWorkLine => ServiceWorkflowStage.workExecution,
};

AppStatus servicesDashboardAttentionStatus(ServicesAttentionKind kind) =>
    switch (kind) {
      ServicesAttentionKind.openEnquiryUnassigned => AppStatus.warning,
      ServicesAttentionKind.visitTodayWithoutInspection => AppStatus.warning,
      ServicesAttentionKind.pendingInspectionToday => AppStatus.info,
      ServicesAttentionKind.inspectionWaitingMaterials => AppStatus.warning,
      ServicesAttentionKind.openMaterialRequest => AppStatus.info,
      ServicesAttentionKind.activeWorkLine => AppStatus.brand,
    };

String servicesDashboardMyWorkActionLabel(
  ServicesMyWorkAction action,
  AppLocalizations l,
) => switch (action) {
  ServicesMyWorkAction.viewAssignment =>
    l.servicesDashboardActionViewAssignment,
  ServicesMyWorkAction.openInspection =>
    l.servicesDashboardActionOpenInspection,
  ServicesMyWorkAction.startWork => l.servicesDashboardActionStartWork,
  ServicesMyWorkAction.continueWork => l.servicesDashboardActionContinueWork,
  ServicesMyWorkAction.viewExecution => l.servicesDashboardActionOpenWork,
};

IconData servicesDashboardMyWorkActionIcon(ServicesMyWorkAction action) =>
    switch (action) {
      ServicesMyWorkAction.viewAssignment => Icons.assignment_ind_outlined,
      ServicesMyWorkAction.openInspection => Icons.fact_check_outlined,
      ServicesMyWorkAction.startWork => Icons.play_circle_outline,
      ServicesMyWorkAction.continueWork => Icons.play_circle_outline,
      ServicesMyWorkAction.viewExecution => Icons.engineering_outlined,
    };
