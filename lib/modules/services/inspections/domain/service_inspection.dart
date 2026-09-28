import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

/// Phase 4 Inspection lifecycle.
///
/// PENDING is directly confirmed by the client reference. COMPLETED/CANCELLED
/// are the minimal modern workflow states required for safe handoff/history.
enum ServiceInspectionStatus { pending, completed, cancelled }

extension ServiceInspectionStatusX on ServiceInspectionStatus {
  String get wire => name;
  bool get isPending => this == ServiceInspectionStatus.pending;
  bool get isCompleted => this == ServiceInspectionStatus.completed;
  bool get isCancelled => this == ServiceInspectionStatus.cancelled;

  static ServiceInspectionStatus fromWire(String value) =>
      ServiceInspectionStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceInspectionStatus.pending,
      );
}

/// Per-checklist-line status.
///
/// TBD — CLIENT CONFIRMATION: the client shows a Status per checklist row but
/// not its values. Only a minimal, non-workflow `pending` default is modelled.
enum ServiceInspectionChecklistStatus { pending }

extension ServiceInspectionChecklistStatusX
    on ServiceInspectionChecklistStatus {
  String get wire => name;
  static ServiceInspectionChecklistStatus fromWire(String value) =>
      ServiceInspectionChecklistStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceInspectionChecklistStatus.pending,
      );
}

/// Material requirement status. WAITING is source-confirmed by the client.
enum ServiceInspectionMaterialStatus { waiting }

extension ServiceInspectionMaterialStatusX on ServiceInspectionMaterialStatus {
  String get wire => name;
  static ServiceInspectionMaterialStatus fromWire(String value) =>
      ServiceInspectionMaterialStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceInspectionMaterialStatus.waiting,
      );
}

class ServiceInspectionChecklistItem {
  const ServiceInspectionChecklistItem({
    required this.id,
    required this.companyId,
    required this.inspectionId,
    required this.lineNumber,
    required this.workType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.sourceJobAssignmentLineId,
    this.descriptionForWork = '',
    this.attachments = const [],
  });
  final String id, companyId, inspectionId;
  final String? sourceJobAssignmentLineId;
  final int lineNumber;
  final String workType;
  final String descriptionForWork;
  final ServiceInspectionChecklistStatus status;
  final List<AttachmentRef> attachments;
  final DateTime createdAt, updatedAt;
}

class ServiceInspectionPoint {
  const ServiceInspectionPoint({
    required this.id,
    required this.companyId,
    required this.inspectionId,
    required this.lineNumber,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id, companyId, inspectionId;
  final int lineNumber;
  final String description;
  final DateTime createdAt, updatedAt;
}

class ServiceInspectionMaterialRequirement {
  const ServiceInspectionMaterialRequirement({
    required this.id,
    required this.companyId,
    required this.inspectionId,
    required this.lineNumber,
    required this.code,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id, companyId, inspectionId;
  final int lineNumber;
  final String code, description;
  final ServiceInspectionMaterialStatus status;
  final DateTime createdAt, updatedAt;
}

class ServiceInspection {
  const ServiceInspection({
    required this.id,
    required this.companyId,
    required this.inspectionNumber,
    required this.inspectionDate,
    required this.sourceJobAssignmentId,
    required this.sourceEnquiryId,
    required this.visitDate,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.syncStatus,
    this.visitMinutes,
    this.technicianEmployeeId,
    this.rootCauseId,
    this.chargeResponsibilityId,
    this.checklistItems = const [],
    this.inspectedPoints = const [],
    this.materialRequirements = const [],
    this.requestId,
  });
  final String id, companyId, inspectionNumber;
  final DateTime inspectionDate;
  final String sourceJobAssignmentId, sourceEnquiryId;
  final DateTime visitDate;
  final int? visitMinutes;
  final String? technicianEmployeeId, rootCauseId, chargeResponsibilityId;
  final ServiceInspectionStatus status;
  final List<ServiceInspectionChecklistItem> checklistItems;
  final List<ServiceInspectionPoint> inspectedPoints;
  final List<ServiceInspectionMaterialRequirement> materialRequirements;
  final int version;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
  final String? requestId;
  final RecordSyncStatus syncStatus;

  bool get isPending => status.isPending;
  bool get isCompleted => status.isCompleted;
  bool get isCancelled => status.isCancelled;
  bool get isEditable => status.isPending;
}

class ServiceInspectionChecklistItemDraft {
  const ServiceInspectionChecklistItemDraft({
    required this.id,
    this.sourceJobAssignmentLineId,
    this.workType = '',
    this.descriptionForWork = '',
    this.status = ServiceInspectionChecklistStatus.pending,
    this.attachments = const [],
  });
  final String id;
  final String? sourceJobAssignmentLineId;
  final String workType, descriptionForWork;
  final ServiceInspectionChecklistStatus status;
  final List<AttachmentRef> attachments;

  ServiceInspectionChecklistItemDraft copyWith({
    String? workType,
    String? descriptionForWork,
    ServiceInspectionChecklistStatus? status,
    List<AttachmentRef>? attachments,
  }) => ServiceInspectionChecklistItemDraft(
    id: id,
    sourceJobAssignmentLineId: sourceJobAssignmentLineId,
    workType: workType ?? this.workType,
    descriptionForWork: descriptionForWork ?? this.descriptionForWork,
    status: status ?? this.status,
    attachments: attachments ?? this.attachments,
  );
}

class ServiceInspectionPointDraft {
  const ServiceInspectionPointDraft({required this.id, this.description = ''});
  final String id;
  final String description;

  ServiceInspectionPointDraft copyWith({String? description}) =>
      ServiceInspectionPointDraft(
        id: id,
        description: description ?? this.description,
      );
}

class ServiceInspectionMaterialRequirementDraft {
  const ServiceInspectionMaterialRequirementDraft({
    required this.id,
    this.code = '',
    this.description = '',
    this.status = ServiceInspectionMaterialStatus.waiting,
  });
  final String id;
  final String code, description;
  final ServiceInspectionMaterialStatus status;

  ServiceInspectionMaterialRequirementDraft copyWith({
    String? code,
    String? description,
  }) => ServiceInspectionMaterialRequirementDraft(
    id: id,
    code: code ?? this.code,
    description: description ?? this.description,
    status: status,
  );
}

class ServiceInspectionDraft {
  const ServiceInspectionDraft({
    this.sourceJobAssignmentId,
    this.visitDate,
    this.visitMinutes,
    this.technicianEmployeeId,
    this.rootCauseId,
    this.chargeResponsibilityId,
    this.checklistItems = const [],
    this.inspectedPoints = const [],
    this.materialRequirements = const [],
  });
  final String? sourceJobAssignmentId;
  final DateTime? visitDate;
  final int? visitMinutes;
  final String? technicianEmployeeId, rootCauseId, chargeResponsibilityId;
  final List<ServiceInspectionChecklistItemDraft> checklistItems;
  final List<ServiceInspectionPointDraft> inspectedPoints;
  final List<ServiceInspectionMaterialRequirementDraft> materialRequirements;

  ServiceInspectionDraft copyWith({
    String? sourceJobAssignmentId,
    bool clearSourceAssignment = false,
    DateTime? visitDate,
    int? visitMinutes,
    bool clearVisitTime = false,
    String? technicianEmployeeId,
    bool clearTechnician = false,
    String? rootCauseId,
    bool clearRootCause = false,
    String? chargeResponsibilityId,
    bool clearChargeResponsibility = false,
    List<ServiceInspectionChecklistItemDraft>? checklistItems,
    List<ServiceInspectionPointDraft>? inspectedPoints,
    List<ServiceInspectionMaterialRequirementDraft>? materialRequirements,
  }) => ServiceInspectionDraft(
    sourceJobAssignmentId: clearSourceAssignment
        ? null
        : (sourceJobAssignmentId ?? this.sourceJobAssignmentId),
    visitDate: visitDate ?? this.visitDate,
    visitMinutes: clearVisitTime ? null : (visitMinutes ?? this.visitMinutes),
    technicianEmployeeId: clearTechnician
        ? null
        : (technicianEmployeeId ?? this.technicianEmployeeId),
    rootCauseId: clearRootCause ? null : (rootCauseId ?? this.rootCauseId),
    chargeResponsibilityId: clearChargeResponsibility
        ? null
        : (chargeResponsibilityId ?? this.chargeResponsibilityId),
    checklistItems: checklistItems ?? this.checklistItems,
    inspectedPoints: inspectedPoints ?? this.inspectedPoints,
    materialRequirements: materialRequirements ?? this.materialRequirements,
  );
}

class ServiceInspectionListItem {
  const ServiceInspectionListItem({
    required this.id,
    required this.inspectionNumber,
    required this.createdAt,
    required this.visitDate,
    required this.status,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    this.visitMinutes,
    this.technicianName,
    this.rootCauseName,
  });
  final String id, inspectionNumber;
  final DateTime createdAt, visitDate;
  final int? visitMinutes;
  final ServiceInspectionStatus status;
  final String assignmentNumber, enquiryNumber, customerName, siteSummary;
  final String? technicianName, rootCauseName;
}

class ServiceInspectionPage {
  ServiceInspectionPage(
    List<ServiceInspectionListItem> items,
    this.total,
    this.filtered,
  ) : items = List.unmodifiable(items);
  final List<ServiceInspectionListItem> items;
  final int total, filtered;
}

class ServiceInspectionView {
  const ServiceInspectionView({
    required this.inspection,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.priorityName,
    required this.priorityRank,
    required this.complaintTypeName,
    required this.materialReceived,
    required this.partySnapshot,
    this.customerMobile,
    this.technicianName,
    this.technicianCode,
    this.rootCauseName,
    this.chargeResponsibilityName,
  });
  final ServiceInspection inspection;
  final String assignmentNumber, enquiryNumber, customerName;
  final String? customerMobile;
  final String priorityName, complaintTypeName;
  final int priorityRank;
  final MaterialReceived materialReceived;
  final ServiceEnquiryPartySnapshot partySnapshot;
  final String? technicianName, technicianCode, rootCauseName;
  final String? chargeResponsibilityName;
}

class ServiceInspectionSummary {
  const ServiceInspectionSummary({
    required this.pendingCount,
    required this.todayCount,
    required this.completedCount,
    required this.totalCount,
  });
  final int pendingCount, todayCount, completedCount, totalCount;
}

/// Restricted eligible Job Assignment reference for the Inspection selector.
class ServiceAssignableJobAssignmentRef {
  const ServiceAssignableJobAssignmentRef({
    required this.id,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    required this.scheduledVisitDate,
    this.customerMobile,
    this.priorityName,
  });
  final String id, assignmentNumber, enquiryNumber, customerName, siteSummary;
  final DateTime scheduledVisitDate;
  final String? customerMobile, priorityName;
}

/// Source context for the Inspection form/detail, loaded from the selected Job
/// Assignment (customer/site/classification, source work lines, eligible
/// technicians, scheduled visit date). Read-only; never re-typed.
class ServiceInspectionSourceContext {
  const ServiceInspectionSourceContext({
    required this.jobAssignmentId,
    required this.assignmentNumber,
    required this.enquiryId,
    required this.enquiryNumber,
    required this.customerName,
    required this.priorityName,
    required this.priorityRank,
    required this.complaintTypeName,
    required this.materialReceived,
    required this.partySnapshot,
    required this.scheduledVisitDate,
    required this.workLines,
    required this.eligibleTechnicians,
    this.customerMobile,
    this.assignedSummary = '',
  });
  final String jobAssignmentId, assignmentNumber;
  final String enquiryId, enquiryNumber, customerName;
  final String? customerMobile;
  final String priorityName, complaintTypeName;
  final int priorityRank;
  final MaterialReceived materialReceived;
  final ServiceEnquiryPartySnapshot partySnapshot;
  final DateTime scheduledVisitDate;
  final List<ServiceJobAssignmentLine> workLines;
  final List<ServiceInspectionTechnicianRef> eligibleTechnicians;
  final String assignedSummary;
}

/// A technician candidate derived from the source Job Assignment (direct
/// employees + active members of assigned Service Teams).
class ServiceInspectionTechnicianRef {
  const ServiceInspectionTechnicianRef({
    required this.id,
    required this.name,
    required this.employeeCode,
  });
  final String id, name, employeeCode;
}
