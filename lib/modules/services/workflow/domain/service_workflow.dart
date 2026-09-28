import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';

/// The five Services business transactions, in authoritative workflow order.
///
/// This is a presentation/read-model concept only: there is deliberately no
/// database column or entity that stores a workflow stage. Every stage resolves
/// to an existing, independently auditable transaction.
enum ServiceWorkflowStage {
  enquiry,
  jobAssignment,
  inspection,
  materialRequest,
  workExecution,
}

extension ServiceWorkflowStageX on ServiceWorkflowStage {
  /// Stable key used for structured (localized) presentation.
  String get key => name;

  bool get isOptional => this == ServiceWorkflowStage.materialRequest;

  static ServiceWorkflowStage fromKey(String value) =>
      ServiceWorkflowStage.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceWorkflowStage.enquiry,
      );
}

/// A **derived, presentation-only** workflow status.
///
/// It is never persisted; it is recomputed from the underlying transaction
/// records on every read so it cannot drift out of sync (Phase 7 §26). Each
/// aggregate keeps its own authoritative lifecycle.
enum ServiceWorkflowStatus {
  awaitingAssignment,
  scheduled,
  inspectionPending,
  inspectionCompleted,
  materialsRequested,
  workInProgress,
  workCompleted,
  cancelled,
  unknown,
}

extension ServiceWorkflowStatusX on ServiceWorkflowStatus {
  String get key => name;
}

/// A single resolved node in the workflow chain.
///
/// [present] is true only when a real record exists **and** the signed-in user
/// is authorized to view it. Restricted records are therefore indistinguishable
/// from absent ones, so no restricted transaction data is leaked through the
/// timeline (Phase 7 §16).
class ServiceWorkflowNode {
  const ServiceWorkflowNode({
    required this.stage,
    required this.present,
    this.id,
    this.reference,
    this.statusKey,
    this.cancelled = false,
    this.waitingMaterialCount = 0,
    this.recordCount = 0,
    this.allLinesComplete = false,
  });

  final ServiceWorkflowStage stage;
  final bool present;

  /// The real record id (null when the node is not present).
  final String? id;

  /// The real display number (ENQ/JA/INS/MR/WE); never fabricated.
  final String? reference;

  /// The underlying aggregate's own raw status wire value (not localized here).
  final String? statusKey;
  final bool cancelled;

  /// Waiting material requirements on the Inspection node (0 when not applicable).
  final int waitingMaterialCount;

  /// Number of linked Material Requests for the (optional) Material Request node.
  final int recordCount;

  /// Whether every Work Execution line has started and ended (header-level gate).
  final bool allLinesComplete;

  bool get hasRecord => present && id != null;

  /// The optional Material Request node is explicitly "not created" rather than
  /// "missing", so the workflow is never shown as broken (Phase 7 §15).
  bool get optionalAbsent => stage.isOptional && !hasRecord;

  static ServiceWorkflowNode absent(
    ServiceWorkflowStage stage, {
    int waitingMaterialCount = 0,
  }) => ServiceWorkflowNode(
    stage: stage,
    present: false,
    waitingMaterialCount: waitingMaterialCount,
  );
}

/// The complete Enquiry → Assignment → Inspection → Material Request → Work
/// Execution read model assembled from existing transactions.
///
/// It stores nothing: every accessor delegates to the resolved nodes.
class ServiceWorkflowChain {
  ServiceWorkflowChain({
    required this.enquiryId,
    required this.status,
    required List<ServiceWorkflowNode> nodes,
    this.enquiryNumber,
    this.focus,
  }) : nodes = List.unmodifiable(nodes);

  final String enquiryId;
  final String? enquiryNumber;
  final ServiceWorkflowStatus status;
  final List<ServiceWorkflowNode> nodes;
  final ServiceWorkflowStage? focus;

  ServiceWorkflowNode nodeFor(ServiceWorkflowStage stage) => nodes.firstWhere(
    (n) => n.stage == stage,
    orElse: () => ServiceWorkflowNode.absent(stage),
  );

  bool get hasMaterialRequest =>
      nodeFor(ServiceWorkflowStage.materialRequest).hasRecord;

  bool get hasWorkExecution =>
      nodeFor(ServiceWorkflowStage.workExecution).hasRecord;

  bool get inspectionHasWaitingMaterials =>
      nodeFor(ServiceWorkflowStage.inspection).waitingMaterialCount > 0;

  bool get isCancelled => status == ServiceWorkflowStatus.cancelled;
}

/// Aggregate, permission/scope-aware workflow projection for dashboards.
///
/// Assembled from the same authoritative per-transaction summaries used
/// elsewhere; it is never a second source of truth.
class ServiceWorkflowSummary {
  const ServiceWorkflowSummary({
    required this.openEnquiries,
    required this.scheduledAssignments,
    required this.pendingInspections,
    required this.openMaterialRequests,
    required this.workInProgress,
    required this.completedWorkToday,
  });
  final int openEnquiries;
  final int scheduledAssignments;
  final int pendingInspections;
  final int openMaterialRequests;
  final int workInProgress;
  final int completedWorkToday;
}

/// A merged workflow-level activity entry (Phase 7 §54–56).
///
/// Only structured event keys + metadata are carried; no English sentences are
/// stored. [entityType] identifies the owning transaction so the presentation
/// can link back to the correct detail route.
class ServiceWorkflowActivityEntry {
  const ServiceWorkflowActivityEntry({
    required this.entityType,
    required this.entityId,
    required this.eventType,
    required this.occurredAt,
    required this.actorUserId,
    this.actorEmployeeId,
    this.reference,
    this.metadata = const {},
  });
  final String entityType, entityId, eventType;
  final DateTime occurredAt;
  final String actorUserId;
  final String? actorEmployeeId;
  final String? reference;
  final Map<String, Object?> metadata;

  ServiceWorkflowStage? get stage => switch (entityType) {
    'serviceEnquiry' => ServiceWorkflowStage.enquiry,
    'serviceJobAssignment' => ServiceWorkflowStage.jobAssignment,
    'serviceInspection' => ServiceWorkflowStage.inspection,
    'serviceMaterialRequest' => ServiceWorkflowStage.materialRequest,
    'serviceWorkExecution' => ServiceWorkflowStage.workExecution,
    _ => null,
  };
}

/// Derives the presentation-only workflow status from resolved node states.
///
/// The optional Material Request never makes the chain look broken: when there
/// are no waiting requirements and no request, the Inspection → Work Execution
/// path simply continues (Phase 7 §15, §22).
ServiceWorkflowStatus deriveServiceWorkflowStatus({
  required ServiceWorkflowNode enquiry,
  required ServiceWorkflowNode assignment,
  required ServiceWorkflowNode inspection,
  required ServiceWorkflowNode materialRequest,
  required ServiceWorkflowNode workExecution,
}) {
  if (enquiry.present && enquiry.cancelled) {
    return ServiceWorkflowStatus.cancelled;
  }
  if (!assignment.present || assignment.cancelled) {
    return ServiceWorkflowStatus.awaitingAssignment;
  }
  if (!inspection.present || inspection.cancelled) {
    return ServiceWorkflowStatus.scheduled;
  }
  final inspectionStatus = inspection.statusKey == null
      ? null
      : ServiceInspectionStatusX.fromWire(inspection.statusKey!);
  if (inspectionStatus == ServiceInspectionStatus.pending) {
    return ServiceWorkflowStatus.inspectionPending;
  }
  // Inspection completed.
  if (workExecution.present && !workExecution.cancelled) {
    final executionStatus = workExecution.statusKey == null
        ? null
        : ServiceWorkExecutionStatusX.fromWire(workExecution.statusKey!);
    if (executionStatus == ServiceWorkExecutionStatus.completed) {
      return ServiceWorkflowStatus.workCompleted;
    }
    if (executionStatus == ServiceWorkExecutionStatus.inProgress) {
      return ServiceWorkflowStatus.workInProgress;
    }
    // Pending execution: if materials were requested, surface that first.
  }
  if (materialRequest.present && !materialRequest.cancelled) {
    return ServiceWorkflowStatus.materialsRequested;
  }
  if (inspection.waitingMaterialCount > 0) {
    return ServiceWorkflowStatus.materialsRequested;
  }
  return ServiceWorkflowStatus.inspectionCompleted;
}

/// Structured activity grouping helper (never localizes here).
String serviceWorkflowActivityKey(ServiceWorkflowActivityEntry entry) =>
    entry.eventType;

/// Localizes a workflow activity entry's owning transaction, reusing the
/// existing entity labels. Kept here so the timeline and the activity feed
/// agree on one mapping.
String serviceWorkflowActivityEntityType(ServiceWorkflowActivityEntry entry) =>
    entry.entityType;

/// Maps a raw Material Request status wire value for defensive display.
ServiceMaterialRequestStatus materialRequestStatusFromWire(String? value) {
  if (value == null) return ServiceMaterialRequestStatus.open;
  return ServiceMaterialRequestStatusX.fromWire(value);
}

/// Maps a raw Enquiry status wire value for defensive display.
ServiceEnquiryStatus enquiryStatusFromWire(String? value) {
  if (value == null) return ServiceEnquiryStatus.open;
  return ServiceEnquiryStatusX.fromWire(value);
}

/// Maps a raw Job Assignment status wire value for defensive display.
String assignmentStatusLabelKey(String? value) => value ?? 'active';

/// Re-exported sync status marker (keeps the workflow file self-documenting).
typedef WorkflowSyncStatus = RecordSyncStatus;
