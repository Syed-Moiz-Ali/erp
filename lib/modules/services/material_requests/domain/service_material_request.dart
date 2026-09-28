import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';

/// Phase 5 Material Request lifecycle.
///
/// Client evidence confirms only two states: OPEN (editable/printable) and
/// CANCELLED (historical, read-only). No approval/issue/receive workflow is
/// modelled because the client reference does not establish one.
enum ServiceMaterialRequestStatus { open, cancelled }

extension ServiceMaterialRequestStatusX on ServiceMaterialRequestStatus {
  String get wire => name;
  bool get isOpen => this == ServiceMaterialRequestStatus.open;
  bool get isCancelled => this == ServiceMaterialRequestStatus.cancelled;

  static ServiceMaterialRequestStatus fromWire(String value) =>
      ServiceMaterialRequestStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceMaterialRequestStatus.open,
      );
}

/// A single requested material line inside a [ServiceMaterialRequest].
///
/// Manual lines (added through "Add material") carry a null
/// [sourceInspectionMaterialRequirementId]; lines generated from an Inspection
/// keep durable source lineage. `lineNumber` is display order only; identity is
/// the stable [id] UUID.
class ServiceMaterialRequestLine {
  const ServiceMaterialRequestLine({
    required this.id,
    required this.companyId,
    required this.materialRequestId,
    required this.lineNumber,
    required this.code,
    required this.description,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.sourceInspectionMaterialRequirementId,
    this.batchNumber,
    this.remark,
  });
  final String id, companyId, materialRequestId;
  final String? sourceInspectionMaterialRequirementId;
  final int lineNumber;
  final String code, description;
  final String? batchNumber, remark;
  final double quantity;
  final DateTime createdAt, updatedAt;
}

/// The Material Request aggregate (header + requested lines).
class ServiceMaterialRequest {
  const ServiceMaterialRequest({
    required this.id,
    required this.companyId,
    required this.requestNumber,
    required this.requestDate,
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
    this.purposeId,
    this.acknowledgement,
    this.receivedBy,
    this.remarks,
    this.lines = const [],
    this.requestId,
  });
  final String id, companyId, requestNumber;
  final DateTime requestDate;
  final String sourceInspectionId, sourceJobAssignmentId, sourceEnquiryId;

  /// Optional free-text business reference. There is intentionally NO JobOrder
  /// entity: the client reference does not establish its ownership.
  final String? jobOrderReference;
  final String? purposeId;

  /// Safe optional metadata. Exact client semantics are still TBD; this value
  /// never drives an approval/issue/receive workflow.
  final String? acknowledgement;

  /// Safe optional free text. The client reference does not prove whether this
  /// is an Employee, store user, tenant or customer, so it is not a relationship.
  final String? receivedBy;
  final String? remarks;
  final ServiceMaterialRequestStatus status;
  final List<ServiceMaterialRequestLine> lines;
  final int version;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
  final String? requestId;
  final RecordSyncStatus syncStatus;

  bool get isOpen => status.isOpen;
  bool get isCancelled => status.isCancelled;
  bool get isEditable => status.isOpen;
  int get itemCount => lines.length;

  /// Derived total quantity. Never stored authoritatively and never entered by
  /// hand; it is always the sum of the current line quantities.
  double get totalQuantity =>
      lines.fold<double>(0, (sum, line) => sum + line.quantity);
}

/// A user-editable material line. [id] is always client-generated so the
/// aggregate can be reconciled by identity on save. Quantity is kept as raw
/// input text and parsed/validated in the repository (never in widgets).
class ServiceMaterialRequestLineDraft {
  const ServiceMaterialRequestLineDraft({
    required this.id,
    this.sourceInspectionMaterialRequirementId,
    this.code = '',
    this.description = '',
    this.batchNumber = '',
    this.quantity = '',
    this.remark = '',
  });
  final String id;
  final String? sourceInspectionMaterialRequirementId;
  final String code, description, batchNumber, quantity, remark;

  ServiceMaterialRequestLineDraft copyWith({
    String? code,
    String? description,
    String? batchNumber,
    String? quantity,
    String? remark,
  }) => ServiceMaterialRequestLineDraft(
    id: id,
    sourceInspectionMaterialRequirementId:
        sourceInspectionMaterialRequirementId,
    code: code ?? this.code,
    description: description ?? this.description,
    batchNumber: batchNumber ?? this.batchNumber,
    quantity: quantity ?? this.quantity,
    remark: remark ?? this.remark,
  );
}

/// User-editable form data only. The UI never builds Drift companions directly.
class ServiceMaterialRequestDraft {
  const ServiceMaterialRequestDraft({
    this.sourceInspectionId,
    this.jobOrderReference = '',
    this.purposeId,
    this.acknowledgement = '',
    this.receivedBy = '',
    this.remarks = '',
    this.lines = const [],
  });
  final String? sourceInspectionId;
  final String jobOrderReference, acknowledgement, receivedBy, remarks;
  final String? purposeId;
  final List<ServiceMaterialRequestLineDraft> lines;

  ServiceMaterialRequestDraft copyWith({
    String? sourceInspectionId,
    bool clearSourceInspection = false,
    String? jobOrderReference,
    String? purposeId,
    bool clearPurpose = false,
    String? acknowledgement,
    String? receivedBy,
    String? remarks,
    List<ServiceMaterialRequestLineDraft>? lines,
  }) => ServiceMaterialRequestDraft(
    sourceInspectionId: clearSourceInspection
        ? null
        : (sourceInspectionId ?? this.sourceInspectionId),
    jobOrderReference: jobOrderReference ?? this.jobOrderReference,
    purposeId: clearPurpose ? null : (purposeId ?? this.purposeId),
    acknowledgement: acknowledgement ?? this.acknowledgement,
    receivedBy: receivedBy ?? this.receivedBy,
    remarks: remarks ?? this.remarks,
    lines: lines ?? this.lines,
  );
}

/// Formats a material quantity consistently (no trailing zeros beyond 3 dp).
String formatMaterialQuantity(double value) {
  final fixed = value.toStringAsFixed(3);
  final trimmed = fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
  return trimmed.isEmpty ? '0' : trimmed;
}

/// Parses a raw quantity input. Returns null when it is not a positive number.
double? parseMaterialRequestQuantity(String value) {
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed <= 0) return null;
  return double.parse(parsed.toStringAsFixed(3));
}

/// Derived total quantity for an in-progress draft (valid lines only). Lives in
/// the domain so no widget duplicates the summing rule.
double materialRequestDraftTotal(
  Iterable<ServiceMaterialRequestLineDraft> lines,
) => lines.fold<double>(
  0,
  (sum, line) => sum + (parseMaterialRequestQuantity(line.quantity) ?? 0),
);

/// Optimized list read model (no per-row repository calls).
class ServiceMaterialRequestListItem {
  const ServiceMaterialRequestListItem({
    required this.id,
    required this.requestNumber,
    required this.requestDate,
    required this.createdAt,
    required this.status,
    required this.inspectionNumber,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    required this.preparedByUserId,
    required this.itemCount,
    required this.totalQuantity,
    this.purposeName,
  });
  final String id, requestNumber;
  final DateTime requestDate, createdAt;
  final ServiceMaterialRequestStatus status;
  final String inspectionNumber, assignmentNumber, enquiryNumber;
  final String customerName, siteSummary;
  final String preparedByUserId;
  final int itemCount;
  final double totalQuantity;
  final String? purposeName;
}

class ServiceMaterialRequestPage {
  ServiceMaterialRequestPage(
    List<ServiceMaterialRequestListItem> items,
    this.total,
    this.filtered,
  ) : items = List.unmodifiable(items);
  final List<ServiceMaterialRequestListItem> items;
  final int total, filtered;
}

/// Detail read model: the aggregate plus the source service context inherited
/// through the Inspection → Job Assignment → Enquiry lineage.
///
/// [materialReceived] is READ-ONLY and resolved from the source Enquiry. It is
/// never a field of the Material Request and is never editable here.
class ServiceMaterialRequestView {
  const ServiceMaterialRequestView({
    required this.request,
    required this.inspectionNumber,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.complaintTypeName,
    required this.priorityName,
    required this.materialReceived,
    required this.partySnapshot,
    this.customerMobile,
    this.purposeName,
    this.technicianName,
  });
  final ServiceMaterialRequest request;
  final String inspectionNumber, assignmentNumber, enquiryNumber;
  final String customerName, complaintTypeName, priorityName;
  final String? customerMobile, purposeName, technicianName;
  final MaterialReceived materialReceived;
  final ServiceEnquiryPartySnapshot partySnapshot;
}

class ServiceMaterialRequestSummary {
  const ServiceMaterialRequestSummary({
    required this.openCount,
    required this.todayCount,
    required this.lineCount,
    required this.totalCount,
  });
  final int openCount, todayCount, lineCount, totalCount;
}

/// Restricted eligible Inspection reference for the Material Request selector.
///
/// Exposes only the fields needed to choose and prefill a request. It does not
/// grant full Inspection data access.
class ServiceEligibleInspectionRef {
  const ServiceEligibleInspectionRef({
    required this.id,
    required this.inspectionNumber,
    required this.assignmentNumber,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    required this.visitDate,
    required this.waitingRequirementCount,
  });
  final String id, inspectionNumber, assignmentNumber, enquiryNumber;
  final String customerName, siteSummary;
  final DateTime visitDate;
  final int waitingRequirementCount;
}

/// Source context for the Material Request form/detail, resolved from the
/// selected completed Inspection. Read-only; never re-typed.
class ServiceMaterialRequestSourceContext {
  const ServiceMaterialRequestSourceContext({
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
    required this.waitingRequirements,
    this.customerMobile,
    this.technicianName,
  });
  final String inspectionId, inspectionNumber;
  final ServiceInspectionStatus inspectionStatus;
  final String jobAssignmentId, assignmentNumber;
  final String enquiryId, enquiryNumber, customerName;
  final String? customerMobile, technicianName;
  final String complaintTypeName, priorityName;
  final MaterialReceived materialReceived;
  final ServiceEnquiryPartySnapshot partySnapshot;
  final List<ServiceInspectionMaterialRequirement> waitingRequirements;
}

/// Lightweight Material Request reference for the Inspection detail integration.
class ServiceMaterialRequestRef {
  const ServiceMaterialRequestRef({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.requestDate,
    required this.itemCount,
    required this.totalQuantity,
  });
  final String id, requestNumber;
  final ServiceMaterialRequestStatus status;
  final DateTime requestDate;
  final int itemCount;
  final double totalQuantity;
}
