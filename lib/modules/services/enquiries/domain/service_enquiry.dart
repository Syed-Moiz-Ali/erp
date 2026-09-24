import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

/// Phase 2/3 Service Enquiry lifecycle.
///
/// An Enquiry is created OPEN, becomes ASSIGNED when a Job Assignment is created
/// for it, and may be CANCELLED (terminal). Cancelling the last active Job
/// Assignment returns an ASSIGNED enquiry to OPEN.
enum ServiceEnquiryStatus { open, assigned, cancelled }

extension ServiceEnquiryStatusX on ServiceEnquiryStatus {
  /// Stable wire/persistence value (never a translated label).
  String get wire => name;
  bool get isOpen => this == ServiceEnquiryStatus.open;
  bool get isAssigned => this == ServiceEnquiryStatus.assigned;
  bool get isCancelled => this == ServiceEnquiryStatus.cancelled;

  static ServiceEnquiryStatus fromWire(String value) =>
      ServiceEnquiryStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceEnquiryStatus.open,
      );
}

/// Header-level "Material Received" flag from the client Enquiry reference.
///
/// TBD — the exact business meaning at Enquiry stage requires client
/// confirmation. Modelled conservatively as a two-value flag; no inventory,
/// quantity, store or valuation semantics are introduced.
enum MaterialReceived { no, yes }

extension MaterialReceivedX on MaterialReceived {
  String get wire => name;
  bool get isYes => this == MaterialReceived.yes;

  static MaterialReceived fromWire(String value) => MaterialReceived.values
      .firstWhere((m) => m.name == value, orElse: () => MaterialReceived.no);
}

/// Per-detail-line business status from the client reference.
///
/// TBD — CLIENT CONFIRMATION: the exact status vocabulary could not be derived
/// from the provided reference. Only a minimal, non-workflow-driving set is
/// modelled so lines can persist; these values must not drive future workflow
/// transitions until confirmed.
enum ServiceEnquiryDetailStatus { open, closed }

extension ServiceEnquiryDetailStatusX on ServiceEnquiryDetailStatus {
  String get wire => name;
  bool get isOpen => this == ServiceEnquiryDetailStatus.open;

  static ServiceEnquiryDetailStatus fromWire(String value) =>
      ServiceEnquiryDetailStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceEnquiryDetailStatus.open,
      );
}

/// Transaction-time display snapshot of the selected Customer/Site.
///
/// Persisted as typed JSON. Kept so renaming/deactivating a Customer or editing
/// a Site later never makes a historical Enquiry misleading. Customer/Site ids
/// remain the authoritative relationship.
class ServiceEnquiryPartySnapshot {
  const ServiceEnquiryPartySnapshot({
    this.customerName,
    this.customerCode,
    this.customerMobile,
    this.siteName,
    this.tenantName,
    this.buildingName,
    this.unitNumber,
    this.addressSummary,
    this.siteContactName,
    this.siteContactMobile,
  });
  final String? customerName, customerCode, customerMobile;
  final String? siteName, tenantName, buildingName, unitNumber;
  final String? addressSummary, siteContactName, siteContactMobile;

  Map<String, Object?> toJson() => {
    if (customerName != null) 'customerName': customerName,
    if (customerCode != null) 'customerCode': customerCode,
    if (customerMobile != null) 'customerMobile': customerMobile,
    if (siteName != null) 'siteName': siteName,
    if (tenantName != null) 'tenantName': tenantName,
    if (buildingName != null) 'buildingName': buildingName,
    if (unitNumber != null) 'unitNumber': unitNumber,
    if (addressSummary != null) 'addressSummary': addressSummary,
    if (siteContactName != null) 'siteContactName': siteContactName,
    if (siteContactMobile != null) 'siteContactMobile': siteContactMobile,
  };

  factory ServiceEnquiryPartySnapshot.fromJson(Map<String, dynamic> json) =>
      ServiceEnquiryPartySnapshot(
        customerName: json['customerName'] as String?,
        customerCode: json['customerCode'] as String?,
        customerMobile: json['customerMobile'] as String?,
        siteName: json['siteName'] as String?,
        tenantName: json['tenantName'] as String?,
        buildingName: json['buildingName'] as String?,
        unitNumber: json['unitNumber'] as String?,
        addressSummary: json['addressSummary'] as String?,
        siteContactName: json['siteContactName'] as String?,
        siteContactMobile: json['siteContactMobile'] as String?,
      );
}

/// A single enquiry detail line (a child of the [ServiceEnquiry] aggregate).
///
/// Normalized, not an untyped map: each line has a stable UUID identity,
/// a description, its own status and zero-or-more photo attachments.
class ServiceEnquiryDetailLine {
  const ServiceEnquiryDetailLine({
    required this.id,
    required this.companyId,
    required this.enquiryId,
    required this.lineNumber,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.syncStatus,
    this.attachments = const [],
  });
  final String id, companyId, enquiryId;
  final int lineNumber;
  final String description;
  final ServiceEnquiryDetailStatus status;
  final List<AttachmentRef> attachments;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
  final RecordSyncStatus syncStatus;
}

/// The Service Enquiry aggregate (a business transaction, not master data).
class ServiceEnquiry {
  const ServiceEnquiry({
    required this.id,
    required this.companyId,
    required this.enquiryNumber,
    required this.customerId,
    required this.siteId,
    required this.serviceTypeId,
    required this.complaintTypeId,
    required this.priorityId,
    required this.ticketTypeId,
    required this.materialReceived,
    required this.status,
    required this.partySnapshot,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.syncStatus,
    this.details = const [],
    this.cancelReason,
    this.cancelledAt,
    this.requestId,
  });
  final String id, companyId, enquiryNumber;
  final String customerId, siteId;
  final String serviceTypeId, complaintTypeId, priorityId, ticketTypeId;
  final MaterialReceived materialReceived;
  final ServiceEnquiryStatus status;
  final ServiceEnquiryPartySnapshot partySnapshot;
  final List<ServiceEnquiryDetailLine> details;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final int version;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
  final String? requestId;
  final RecordSyncStatus syncStatus;

  bool get isOpen => status.isOpen;
  bool get isCancelled => status.isCancelled;
  bool get isEditable => status.isOpen;
  int get detailCount => details.length;
}

/// A user-editable enquiry detail line. [id] is always client-generated so
/// photos can be attached to a not-yet-saved line and reconciled by id on save.
class ServiceEnquiryDraftDetail {
  const ServiceEnquiryDraftDetail({
    required this.id,
    this.description = '',
    this.status = ServiceEnquiryDetailStatus.open,
    this.attachments = const [],
  });
  final String id;
  final String description;
  final ServiceEnquiryDetailStatus status;
  final List<AttachmentRef> attachments;

  ServiceEnquiryDraftDetail copyWith({
    String? description,
    ServiceEnquiryDetailStatus? status,
    List<AttachmentRef>? attachments,
  }) => ServiceEnquiryDraftDetail(
    id: id,
    description: description ?? this.description,
    status: status ?? this.status,
    attachments: attachments ?? this.attachments,
  );
}

/// User-editable form data only. The UI never builds Drift companions directly.
class ServiceEnquiryDraft {
  const ServiceEnquiryDraft({
    this.customerId,
    this.siteId,
    this.serviceTypeId,
    this.complaintTypeId,
    this.priorityId,
    this.ticketTypeId,
    this.materialReceived = MaterialReceived.no,
    this.details = const [],
  });
  final String? customerId, siteId;
  final String? serviceTypeId, complaintTypeId, priorityId, ticketTypeId;
  final MaterialReceived materialReceived;
  final List<ServiceEnquiryDraftDetail> details;

  ServiceEnquiryDraft copyWith({
    String? customerId,
    bool clearCustomer = false,
    String? siteId,
    bool clearSite = false,
    String? serviceTypeId,
    bool clearServiceType = false,
    String? complaintTypeId,
    bool clearComplaintType = false,
    String? priorityId,
    bool clearPriority = false,
    String? ticketTypeId,
    bool clearTicketType = false,
    MaterialReceived? materialReceived,
    List<ServiceEnquiryDraftDetail>? details,
  }) => ServiceEnquiryDraft(
    customerId: clearCustomer ? null : (customerId ?? this.customerId),
    siteId: clearSite ? null : (siteId ?? this.siteId),
    serviceTypeId: clearServiceType
        ? null
        : (serviceTypeId ?? this.serviceTypeId),
    complaintTypeId: clearComplaintType
        ? null
        : (complaintTypeId ?? this.complaintTypeId),
    priorityId: clearPriority ? null : (priorityId ?? this.priorityId),
    ticketTypeId: clearTicketType ? null : (ticketTypeId ?? this.ticketTypeId),
    materialReceived: materialReceived ?? this.materialReceived,
    details: details ?? this.details,
  );
}

/// Optimized list read model (no full aggregate, no per-row repository calls).
class ServiceEnquiryListItem {
  const ServiceEnquiryListItem({
    required this.id,
    required this.enquiryNumber,
    required this.createdAt,
    required this.customerName,
    required this.siteName,
    required this.serviceTypeName,
    required this.complaintTypeName,
    required this.priorityName,
    required this.priorityRank,
    required this.ticketTypeName,
    required this.status,
    this.customerMobile,
  });
  final String id, enquiryNumber;
  final DateTime createdAt;
  final String customerName, siteName;
  final String? customerMobile;
  final String serviceTypeName, complaintTypeName, priorityName;
  final int priorityRank;
  final String ticketTypeName;
  final ServiceEnquiryStatus status;
}

class ServiceEnquiryPage {
  ServiceEnquiryPage(
    List<ServiceEnquiryListItem> items,
    this.total,
    this.filtered,
  ) : items = List.unmodifiable(items);
  final List<ServiceEnquiryListItem> items;
  final int total, filtered;
}

/// Detail read model: the aggregate (header + detail lines with attachments)
/// plus resolved (active or historical) master labels. Customer/Site context is
/// read from the persisted snapshot.
class ServiceEnquiryView {
  const ServiceEnquiryView({
    required this.enquiry,
    required this.serviceTypeName,
    required this.complaintTypeName,
    required this.priorityName,
    required this.ticketTypeName,
    this.priorityRank = 0,
  });
  final ServiceEnquiry enquiry;
  final String serviceTypeName, complaintTypeName, priorityName;
  final int priorityRank;
  final String ticketTypeName;
}

/// Aggregate metrics for the Services Overview (never computed by counting a
/// full list in a widget).
class ServiceEnquirySummary {
  const ServiceEnquirySummary({
    required this.openCount,
    required this.todayCount,
    required this.highUrgentOpenCount,
    required this.totalCount,
  });
  final int openCount, todayCount, highUrgentOpenCount, totalCount;
}

/// Restricted Site reference for the Enquiry form: enough context to preview the
/// Site without granting full Site-directory access.
class ServiceEnquirySiteRef {
  const ServiceEnquirySiteRef({
    required this.id,
    required this.siteCode,
    required this.siteName,
    required this.customerId,
    this.tenantName,
    this.buildingName,
    this.unitNumber,
    this.addressSummary,
    this.contactName,
    this.contactMobile,
  });
  final String id, siteCode, siteName, customerId;
  final String? tenantName, buildingName, unitNumber;
  final String? addressSummary, contactName, contactMobile;
}
