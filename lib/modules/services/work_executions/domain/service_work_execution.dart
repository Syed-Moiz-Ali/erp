import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

/// Phase 6 Work Execution lifecycle.
///
/// PENDING is directly visible in the client reference. IN_PROGRESS,
/// COMPLETED and CANCELLED are the minimal modern system states required to
/// support start/end/finalization safely. No larger guessed workflow is
/// modelled.
enum ServiceWorkExecutionStatus { pending, inProgress, completed, cancelled }

extension ServiceWorkExecutionStatusX on ServiceWorkExecutionStatus {
  String get wire => name;
  bool get isPending => this == ServiceWorkExecutionStatus.pending;
  bool get isInProgress => this == ServiceWorkExecutionStatus.inProgress;
  bool get isCompleted => this == ServiceWorkExecutionStatus.completed;
  bool get isCancelled => this == ServiceWorkExecutionStatus.cancelled;

  /// PENDING and IN_PROGRESS are the editable/open states.
  bool get isOpen => isPending || isInProgress;

  static ServiceWorkExecutionStatus fromWire(String value) =>
      ServiceWorkExecutionStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceWorkExecutionStatus.pending,
      );
}

/// Derived per-line execution state.
///
/// The client reference only shows "WORK START". Rather than invent a guessed
/// status vocabulary, the operational line state is derived from the captured
/// timestamps.
enum ServiceWorkLineState { notStarted, inProgress, finished }

extension ServiceWorkLineStateX on ServiceWorkLineState {
  bool get isNotStarted => this == ServiceWorkLineState.notStarted;
  bool get isInProgress => this == ServiceWorkLineState.inProgress;
  bool get isFinished => this == ServiceWorkLineState.finished;
}

/// Derives the line state from the persisted timestamps (never stored).
ServiceWorkLineState serviceWorkLineState({
  required DateTime? startedAtUtc,
  required DateTime? endedAtUtc,
}) {
  if (endedAtUtc != null) return ServiceWorkLineState.finished;
  if (startedAtUtc != null) return ServiceWorkLineState.inProgress;
  return ServiceWorkLineState.notStarted;
}

/// Optional presentational duration. Never persisted; negative ranges are
/// clamped to null so an invalid range cannot render a negative duration.
Duration? serviceWorkLineDuration({
  required DateTime? startedAtUtc,
  required DateTime? endedAtUtc,
}) {
  if (startedAtUtc == null || endedAtUtc == null) return null;
  final duration = endedAtUtc.difference(startedAtUtc);
  return duration.isNegative ? null : duration;
}

/// A single work item inside a [ServiceWorkExecution].
///
/// May target an Employee, a Service Team, or both. When prefilled from the
/// source Job Assignment the [sourceJobAssignmentLineId] is retained so lineage
/// is never lost.
class ServiceWorkExecutionLine {
  const ServiceWorkExecutionLine({
    required this.id,
    required this.companyId,
    required this.workExecutionId,
    required this.lineNumber,
    required this.work,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.sourceJobAssignmentLineId,
    this.serviceTeamId,
    this.employeeId,
    this.startedAtUtc,
    this.endedAtUtc,
  });
  final String id, companyId, workExecutionId;
  final String? sourceJobAssignmentLineId;
  final int lineNumber;
  final String work, description;
  final String? serviceTeamId, employeeId;
  final DateTime? startedAtUtc, endedAtUtc;
  final DateTime createdAt, updatedAt;

  ServiceWorkLineState get state =>
      serviceWorkLineState(startedAtUtc: startedAtUtc, endedAtUtc: endedAtUtc);
  bool get isStarted => startedAtUtc != null;
  bool get isFinished => endedAtUtc != null;

  /// A captured range is invalid when the end precedes the start.
  bool get hasInvalidRange =>
      startedAtUtc != null &&
      endedAtUtc != null &&
      endedAtUtc!.isBefore(startedAtUtc!);
}

/// A single "Material Used" record. Intentionally carries only Code and
/// Description: the client reference shows no Qty/Batch/UOM/Cost and none is
/// invented. This is an execution record, not an inventory or stock movement.
class ServiceWorkExecutionMaterialUsed {
  const ServiceWorkExecutionMaterialUsed({
    required this.id,
    required this.companyId,
    required this.workExecutionId,
    required this.lineNumber,
    required this.code,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.sourceMaterialRequestLineId,
  });
  final String id, companyId, workExecutionId;
  final String? sourceMaterialRequestLineId;
  final int lineNumber;
  final String code, description;
  final DateTime createdAt, updatedAt;
}

/// A single "Photos After Work" evidence entry. The description is a real
/// business field; the images themselves are shared [AttachmentRef] metadata.
class ServiceWorkExecutionPhotoEntry {
  const ServiceWorkExecutionPhotoEntry({
    required this.id,
    required this.companyId,
    required this.workExecutionId,
    required this.lineNumber,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.attachments = const [],
  });
  final String id, companyId, workExecutionId;
  final int lineNumber;
  final String description;
  final List<AttachmentRef> attachments;
  final DateTime createdAt, updatedAt;
}

/// The Work Execution aggregate (header + work lines + materials used +
/// after-work photo entries).
class ServiceWorkExecution {
  const ServiceWorkExecution({
    required this.id,
    required this.companyId,
    required this.executionNumber,
    required this.executionDate,
    required this.sourceInspectionId,
    required this.sourceJobAssignmentId,
    required this.sourceEnquiryId,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.syncStatus,
    this.jobOrderReference,
    this.quotationReference,
    this.workLines = const [],
    this.materialsUsed = const [],
    this.afterWorkPhotoEntries = const [],
    this.requestId,
  });
  final String id, companyId, executionNumber;
  final DateTime executionDate;
  final String sourceInspectionId, sourceJobAssignmentId, sourceEnquiryId;

  /// Optional free-text compatibility references. There is intentionally NO
  /// JobOrder/Quotation entity: the client reference does not establish their
  /// ownership (TBD — authoritative owner/source).
  final String? jobOrderReference, quotationReference;
  final ServiceWorkExecutionStatus status;
  final List<ServiceWorkExecutionLine> workLines;
  final List<ServiceWorkExecutionMaterialUsed> materialsUsed;
  final List<ServiceWorkExecutionPhotoEntry> afterWorkPhotoEntries;
  final int version;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
  final String? requestId;
  final RecordSyncStatus syncStatus;

  bool get isPending => status.isPending;
  bool get isInProgress => status.isInProgress;
  bool get isCompleted => status.isCompleted;
  bool get isCancelled => status.isCancelled;
  bool get isEditable => status.isOpen;
  int get workLineCount => workLines.length;
  int get materialUsedCount => materialsUsed.length;
  int get photoEntryCount => afterWorkPhotoEntries.length;

  /// True when at least one line exists and every line has started and ended
  /// with a valid range.
  bool get allLinesComplete =>
      workLines.isNotEmpty &&
      workLines.every((line) => line.isStarted && line.isFinished) &&
      !hasInvalidRange;

  bool get hasInvalidRange => workLines.any((line) => line.hasInvalidRange);
}

/// A user-editable work line. [id] is always client-generated so the aggregate
/// can be reconciled by identity on save.
class ServiceWorkExecutionLineDraft {
  const ServiceWorkExecutionLineDraft({
    required this.id,
    this.sourceJobAssignmentLineId,
    this.work = '',
    this.description = '',
    this.serviceTeamId,
    this.employeeId,
    this.startedAtUtc,
    this.endedAtUtc,
  });
  final String id;
  final String? sourceJobAssignmentLineId;
  final String work, description;
  final String? serviceTeamId, employeeId;
  final DateTime? startedAtUtc, endedAtUtc;

  ServiceWorkExecutionLineDraft copyWith({
    String? work,
    String? description,
    String? serviceTeamId,
    bool clearTeam = false,
    String? employeeId,
    bool clearEmployee = false,
  }) => ServiceWorkExecutionLineDraft(
    id: id,
    sourceJobAssignmentLineId: sourceJobAssignmentLineId,
    work: work ?? this.work,
    description: description ?? this.description,
    serviceTeamId: clearTeam ? null : (serviceTeamId ?? this.serviceTeamId),
    employeeId: clearEmployee ? null : (employeeId ?? this.employeeId),
    startedAtUtc: startedAtUtc,
    endedAtUtc: endedAtUtc,
  );
}

class ServiceWorkExecutionMaterialUsedDraft {
  const ServiceWorkExecutionMaterialUsedDraft({
    required this.id,
    this.sourceMaterialRequestLineId,
    this.code = '',
    this.description = '',
  });
  final String id;
  final String? sourceMaterialRequestLineId;
  final String code, description;

  ServiceWorkExecutionMaterialUsedDraft copyWith({
    String? code,
    String? description,
  }) => ServiceWorkExecutionMaterialUsedDraft(
    id: id,
    sourceMaterialRequestLineId: sourceMaterialRequestLineId,
    code: code ?? this.code,
    description: description ?? this.description,
  );
}

class ServiceWorkExecutionPhotoEntryDraft {
  const ServiceWorkExecutionPhotoEntryDraft({
    required this.id,
    this.description = '',
    this.attachments = const [],
  });
  final String id;
  final String description;
  final List<AttachmentRef> attachments;

  ServiceWorkExecutionPhotoEntryDraft copyWith({
    String? description,
    List<AttachmentRef>? attachments,
  }) => ServiceWorkExecutionPhotoEntryDraft(
    id: id,
    description: description ?? this.description,
    attachments: attachments ?? this.attachments,
  );
}

/// User-editable form data only. The UI never builds Drift companions directly.
class ServiceWorkExecutionDraft {
  const ServiceWorkExecutionDraft({
    this.sourceInspectionId,
    this.jobOrderReference = '',
    this.quotationReference = '',
    this.workLines = const [],
    this.materialsUsed = const [],
    this.afterWorkPhotoEntries = const [],
  });
  final String? sourceInspectionId;
  final String jobOrderReference, quotationReference;
  final List<ServiceWorkExecutionLineDraft> workLines;
  final List<ServiceWorkExecutionMaterialUsedDraft> materialsUsed;
  final List<ServiceWorkExecutionPhotoEntryDraft> afterWorkPhotoEntries;

  ServiceWorkExecutionDraft copyWith({
    String? sourceInspectionId,
    bool clearSourceInspection = false,
    String? jobOrderReference,
    String? quotationReference,
    List<ServiceWorkExecutionLineDraft>? workLines,
    List<ServiceWorkExecutionMaterialUsedDraft>? materialsUsed,
    List<ServiceWorkExecutionPhotoEntryDraft>? afterWorkPhotoEntries,
  }) => ServiceWorkExecutionDraft(
    sourceInspectionId: clearSourceInspection
        ? null
        : (sourceInspectionId ?? this.sourceInspectionId),
    jobOrderReference: jobOrderReference ?? this.jobOrderReference,
    quotationReference: quotationReference ?? this.quotationReference,
    workLines: workLines ?? this.workLines,
    materialsUsed: materialsUsed ?? this.materialsUsed,
    afterWorkPhotoEntries: afterWorkPhotoEntries ?? this.afterWorkPhotoEntries,
  );
}

/// Optimized list read model (no per-row repository calls).
class ServiceWorkExecutionListItem {
  const ServiceWorkExecutionListItem({
    required this.id,
    required this.executionNumber,
    required this.executionDate,
    required this.createdAt,
    required this.status,
    required this.inspectionNumber,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    required this.assignedSummary,
    this.startedAtUtc,
    this.endedAtUtc,
  });
  final String id, executionNumber;
  final DateTime executionDate, createdAt;
  final ServiceWorkExecutionStatus status;
  final String inspectionNumber, assignmentNumber, enquiryNumber;
  final String customerName, siteSummary;

  /// Compact "Ahmed Khan + HVAC Team +2 more" summary; never explodes width.
  final String assignedSummary;
  final DateTime? startedAtUtc, endedAtUtc;
}

class ServiceWorkExecutionPage {
  ServiceWorkExecutionPage(
    List<ServiceWorkExecutionListItem> items,
    this.total,
    this.filtered,
  ) : items = List.unmodifiable(items);
  final List<ServiceWorkExecutionListItem> items;
  final int total, filtered;
}

/// Detail read model: the aggregate plus the read-only service context derived
/// through the Inspection → Job Assignment → Enquiry lineage. None of this is
/// independently editable here.
class ServiceWorkExecutionView {
  const ServiceWorkExecutionView({
    required this.execution,
    required this.inspectionNumber,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.complaintTypeName,
    required this.priorityName,
    required this.materialReceived,
    required this.partySnapshot,
    required this.checklistItems,
    required this.inspectedPoints,
    required this.materialRequirements,
    required this.linkedMaterialRequests,
    this.customerMobile,
    this.rootCauseName,
    this.chargeResponsibilityName,
    this.technicianName,
  });
  final ServiceWorkExecution execution;
  final String inspectionNumber, assignmentNumber, enquiryNumber;
  final String customerName, complaintTypeName, priorityName;
  final String? customerMobile, rootCauseName, chargeResponsibilityName;
  final String? technicianName;
  final MaterialReceived materialReceived;
  final ServiceEnquiryPartySnapshot partySnapshot;
  final List<ServiceInspectionChecklistItem> checklistItems;
  final List<ServiceInspectionPoint> inspectedPoints;
  final List<ServiceInspectionMaterialRequirement> materialRequirements;
  final List<ServiceWorkMaterialRequestRef> linkedMaterialRequests;
}

class ServiceWorkExecutionSummary {
  const ServiceWorkExecutionSummary({
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedTodayCount,
    required this.totalCount,
  });
  final int pendingCount, inProgressCount, completedTodayCount, totalCount;
}

/// Restricted eligible Inspection reference for the Work Execution selector.
///
/// Exposes only the fields needed to choose an eligible completed Inspection.
/// It does not grant full Inspection navigation or Customer/HR access.
class ServiceWorkEligibleInspectionRef {
  const ServiceWorkEligibleInspectionRef({
    required this.id,
    required this.inspectionNumber,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    required this.visitDate,
    this.technicianName,
  });
  final String id, inspectionNumber, assignmentNumber, enquiryNumber;
  final String customerName, siteSummary;
  final DateTime visitDate;
  final String? technicianName;
}

/// A linked Material Request line available to copy into Material Used. The
/// request itself is never mutated.
class ServiceWorkMaterialRequestLineRef {
  const ServiceWorkMaterialRequestLineRef({
    required this.id,
    required this.requestNumber,
    required this.code,
    required this.description,
  });
  final String id, requestNumber, code, description;
}

/// A linked Material Request summary for read-only workflow context.
class ServiceWorkMaterialRequestRef {
  const ServiceWorkMaterialRequestRef({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.itemCount,
  });
  final String id, requestNumber;
  final String status;
  final int itemCount;
}

/// Source context for the Work Execution form/detail, resolved from the
/// selected completed Inspection. Read-only; never re-typed.
class ServiceWorkExecutionSourceContext {
  const ServiceWorkExecutionSourceContext({
    required this.inspectionId,
    required this.inspectionNumber,
    required this.inspectionStatus,
    required this.jobAssignmentId,
    required this.assignmentNumber,
    required this.enquiryId,
    required this.enquiryNumber,
    required this.customerName,
    required this.complaintTypeName,
    required this.priorityName,
    required this.materialReceived,
    required this.partySnapshot,
    required this.jobAssignmentLines,
    required this.checklistItems,
    required this.inspectedPoints,
    required this.materialRequirements,
    required this.linkedMaterialRequests,
    required this.materialRequestLines,
    this.customerMobile,
    this.rootCauseName,
    this.chargeResponsibilityName,
    this.technicianName,
  });
  final String inspectionId, inspectionNumber;
  final ServiceInspectionStatus inspectionStatus;
  final String jobAssignmentId, assignmentNumber;
  final String enquiryId, enquiryNumber, customerName;
  final String? customerMobile, rootCauseName, chargeResponsibilityName;
  final String? technicianName;
  final String complaintTypeName, priorityName;
  final MaterialReceived materialReceived;
  final ServiceEnquiryPartySnapshot partySnapshot;
  final List<ServiceJobAssignmentLine> jobAssignmentLines;
  final List<ServiceInspectionChecklistItem> checklistItems;
  final List<ServiceInspectionPoint> inspectedPoints;
  final List<ServiceInspectionMaterialRequirement> materialRequirements;
  final List<ServiceWorkMaterialRequestRef> linkedMaterialRequests;
  final List<ServiceWorkMaterialRequestLineRef> materialRequestLines;
}

/// Lightweight Work Execution reference for the Inspection/Job Assignment
/// detail integrations.
class ServiceWorkExecutionRef {
  const ServiceWorkExecutionRef({
    required this.id,
    required this.executionNumber,
    required this.status,
    required this.executionDate,
    required this.workLineCount,
    required this.allLinesComplete,
    this.startedAtUtc,
    this.endedAtUtc,
  });
  final String id, executionNumber;
  final ServiceWorkExecutionStatus status;
  final DateTime executionDate;
  final int workLineCount;
  final bool allLinesComplete;
  final DateTime? startedAtUtc, endedAtUtc;
}
