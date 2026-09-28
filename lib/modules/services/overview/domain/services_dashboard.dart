import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';

/// The effective operational scope shown in the Services dashboard header.
///
/// This is informational only: it is derived from the broadest granted record
/// scope across the workflow domains and never lets a user select a scope they
/// were not granted.
enum ServicesDashboardScope { assigned, team, all, none }

/// The six permission/scope-gated KPI cards.
enum ServicesDashboardKpiKind {
  openEnquiries,
  scheduledAssignments,
  pendingInspections,
  openMaterialRequests,
  workInProgress,
  completedToday,
}

/// Why an attention item needs action. Each value is derived from the real
/// workflow (no SLA timers, no invented rules).
enum ServicesAttentionKind {
  openEnquiryUnassigned,
  visitTodayWithoutInspection,
  pendingInspectionToday,
  inspectionWaitingMaterials,
  openMaterialRequest,
  activeWorkLine,
}

/// A derived "Needs attention" row. Presentation localizes [kind]; nothing in
/// this model is a stored English sentence.
class ServicesAttentionItem {
  const ServicesAttentionItem({
    required this.kind,
    required this.entityId,
    required this.reference,
    required this.customerName,
    required this.siteSummary,
    this.dueAt,
    this.waitingMaterialCount = 0,
    this.priorityName = '',
    this.priorityRank = 0,
  });
  final ServicesAttentionKind kind;
  final String entityId, reference, customerName, siteSummary;

  /// Company-local date/time of the relevant event (visit or inspection time).
  final DateTime? dueAt;
  final int waitingMaterialCount;
  final String priorityName;
  final int priorityRank;
}

/// Today's schedule comes from `JobAssignment.scheduledVisitDate` plus
/// `Inspection.visitDate`/`visitMinutes`.
enum ServicesScheduleKind { assignment, inspection }

class ServicesScheduleItem {
  const ServicesScheduleItem({
    required this.kind,
    required this.entityId,
    required this.reference,
    required this.customerName,
    required this.siteSummary,
    required this.assignedSummary,
    required this.visitDate,
    required this.statusKey,
    this.complaint = '',
    this.minutes,
    this.priorityName = '',
    this.priorityRank = 0,
  });
  final ServicesScheduleKind kind;
  final String entityId, reference, customerName, siteSummary, assignedSummary;
  final String complaint;

  /// Company-local date (UTC midnight) of the visit.
  final DateTime visitDate;

  /// Minutes past midnight for inspections (null for date-only assignments).
  final int? minutes;
  final String statusKey;
  final String priorityName;
  final int priorityRank;

  DateTime? get at =>
      minutes == null ? null : visitDate.add(Duration(minutes: minutes!));
}

enum ServicesMyWorkKind { assignment, inspection, execution }

/// The single primary next action offered on a "My work" row.
enum ServicesMyWorkAction {
  viewAssignment,
  openInspection,
  startWork,
  continueWork,
  viewExecution,
}

class ServicesMyWorkItem {
  const ServicesMyWorkItem({
    required this.kind,
    required this.entityId,
    required this.reference,
    required this.customerName,
    required this.siteSummary,
    required this.summary,
    required this.statusKey,
    this.date,
    this.action,
  });
  final ServicesMyWorkKind kind;
  final String entityId, reference, customerName, siteSummary, summary;
  final String statusKey;
  final DateTime? date;
  final ServicesMyWorkAction? action;
}

/// A compact, real team-workload row (no fake capacity percentage).
class ServicesTeamWorkloadRow {
  const ServicesTeamWorkloadRow({
    required this.teamId,
    required this.teamName,
    required this.activeAssignments,
    required this.todayVisits,
    required this.inProgress,
  });
  final String teamId, teamName;
  final int activeAssignments, todayVisits, inProgress;

  bool get isEmpty =>
      activeAssignments == 0 && todayVisits == 0 && inProgress == 0;
}

/// One stage of the operational workflow distribution. Material Request is an
/// optional branch and is never presented as mandatory.
class ServicesWorkflowStageCount {
  const ServicesWorkflowStageCount({required this.stage, required this.count});
  final ServiceWorkflowStage stage;
  final int count;
}

/// A structured recent-activity event. Only records the user may view are
/// included; the event key is localized at render time.
class ServicesRecentActivityItem {
  const ServicesRecentActivityItem({
    required this.entityType,
    required this.entityId,
    required this.eventType,
    required this.reference,
    required this.occurredAt,
  });
  final String entityType, entityId, eventType, reference;
  final DateTime occurredAt;
}

/// Permission/scope-aware, read-only Services dashboard projection.
///
/// Every count and list is present only when the signed-in user may view that
/// domain: the repository never loads all-company data and hides it later.
class ServicesDashboardSnapshot {
  const ServicesDashboardSnapshot({
    required this.scope,
    required this.canViewEnquiries,
    required this.canViewAssignments,
    required this.canViewInspections,
    required this.canViewMaterialRequests,
    required this.canViewWorkExecutions,
    required this.canCreateEnquiry,
    this.openEnquiriesCount = 0,
    this.scheduledAssignmentsCount = 0,
    this.pendingInspectionsCount = 0,
    this.openMaterialRequestsCount = 0,
    this.workInProgressCount = 0,
    this.completedTodayCount = 0,
    this.attentionItems = const [],
    this.todaySchedule = const [],
    this.myWork = const [],
    this.teamWorkload = const [],
    this.workflowStages = const [],
    this.recentActivity = const [],
    this.today,
  });

  final ServicesDashboardScope scope;
  final bool canViewEnquiries,
      canViewAssignments,
      canViewInspections,
      canViewMaterialRequests,
      canViewWorkExecutions,
      canCreateEnquiry;
  final int openEnquiriesCount,
      scheduledAssignmentsCount,
      pendingInspectionsCount,
      openMaterialRequestsCount,
      workInProgressCount,
      completedTodayCount;
  final List<ServicesAttentionItem> attentionItems;
  final List<ServicesScheduleItem> todaySchedule;
  final List<ServicesMyWorkItem> myWork;
  final List<ServicesTeamWorkloadRow> teamWorkload;
  final List<ServicesWorkflowStageCount> workflowStages;
  final List<ServicesRecentActivityItem> recentActivity;

  /// Company-local "today" (UTC midnight) used for the header and filtering.
  final DateTime? today;

  int get kpiCount =>
      (canViewEnquiries ? 1 : 0) +
      (canViewAssignments ? 1 : 0) +
      (canViewInspections ? 1 : 0) +
      (canViewMaterialRequests ? 1 : 0) +
      (canViewWorkExecutions ? 2 : 0);

  bool get hasAnyData =>
      openEnquiriesCount +
              scheduledAssignmentsCount +
              pendingInspectionsCount +
              openMaterialRequestsCount +
              workInProgressCount +
              completedTodayCount >
          0 ||
      attentionItems.isNotEmpty ||
      todaySchedule.isNotEmpty ||
      myWork.isNotEmpty ||
      teamWorkload.any((row) => !row.isEmpty) ||
      recentActivity.isNotEmpty;

  static const empty = ServicesDashboardSnapshot(
    scope: ServicesDashboardScope.none,
    canViewEnquiries: false,
    canViewAssignments: false,
    canViewInspections: false,
    canViewMaterialRequests: false,
    canViewWorkExecutions: false,
    canCreateEnquiry: false,
  );
}
