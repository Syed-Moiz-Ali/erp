import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';

/// Phase 3 Job Assignment transaction lifecycle.
///
/// V1: ACTIVE or CANCELLED. Cancellation is historical (no hard delete).
enum ServiceJobAssignmentStatus { active, cancelled }

extension ServiceJobAssignmentStatusX on ServiceJobAssignmentStatus {
  String get wire => name;
  bool get isActive => this == ServiceJobAssignmentStatus.active;
  bool get isCancelled => this == ServiceJobAssignmentStatus.cancelled;

  static ServiceJobAssignmentStatus fromWire(String value) =>
      ServiceJobAssignmentStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceJobAssignmentStatus.active,
      );
}

/// Per work-line status from the client reference.
///
/// TBD — CLIENT CONFIRMATION: the client screenshot shows a Status selector per
/// row but does not reveal the allowed values. Only a minimal, non-workflow
/// `pending` default is modelled; it must not drive Inspection/Work Execution.
enum ServiceJobAssignmentLineStatus { pending }

extension ServiceJobAssignmentLineStatusX on ServiceJobAssignmentLineStatus {
  String get wire => name;

  static ServiceJobAssignmentLineStatus fromWire(String value) =>
      ServiceJobAssignmentLineStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ServiceJobAssignmentLineStatus.pending,
      );
}

/// A single work item inside a [ServiceJobAssignment] aggregate.
///
/// May target an Employee, a Service Team, or both (at least one normally).
class ServiceJobAssignmentLine {
  const ServiceJobAssignmentLine({
    required this.id,
    required this.companyId,
    required this.assignmentId,
    required this.lineNumber,
    required this.work,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.syncStatus,
    this.descriptionForWork = '',
    this.assignedEmployeeId,
    this.assignedTeamId,
  });
  final String id, companyId, assignmentId;
  final int lineNumber;
  final String work;
  final String? assignedEmployeeId, assignedTeamId;
  final ServiceJobAssignmentLineStatus status;
  final String descriptionForWork;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
  final RecordSyncStatus syncStatus;
}

/// The Job Assignment aggregate (header + work lines).
class ServiceJobAssignment {
  const ServiceJobAssignment({
    required this.id,
    required this.companyId,
    required this.assignmentNumber,
    required this.assignmentDate,
    required this.sourceEnquiryId,
    required this.scheduledVisitDate,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.syncStatus,
    this.lines = const [],
    this.requestId,
  });
  final String id, companyId, assignmentNumber;
  final DateTime assignmentDate;
  final String sourceEnquiryId;
  final DateTime scheduledVisitDate;
  final ServiceJobAssignmentStatus status;
  final List<ServiceJobAssignmentLine> lines;
  final int version;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
  final String? requestId;
  final RecordSyncStatus syncStatus;

  bool get isActive => status.isActive;
  bool get isCancelled => status.isCancelled;
  bool get isEditable => status.isActive;
  int get lineCount => lines.length;
}

/// A user-editable work line. [id] is always client-generated so the aggregate
/// can be reconciled by id on save.
class ServiceJobAssignmentLineDraft {
  const ServiceJobAssignmentLineDraft({
    required this.id,
    this.work = '',
    this.assignedEmployeeId,
    this.assignedTeamId,
    this.status = ServiceJobAssignmentLineStatus.pending,
    this.descriptionForWork = '',
  });
  final String id;
  final String work;
  final String? assignedEmployeeId, assignedTeamId;
  final ServiceJobAssignmentLineStatus status;
  final String descriptionForWork;

  ServiceJobAssignmentLineDraft copyWith({
    String? work,
    String? assignedEmployeeId,
    bool clearEmployee = false,
    String? assignedTeamId,
    bool clearTeam = false,
    ServiceJobAssignmentLineStatus? status,
    String? descriptionForWork,
  }) => ServiceJobAssignmentLineDraft(
    id: id,
    work: work ?? this.work,
    assignedEmployeeId: clearEmployee
        ? null
        : (assignedEmployeeId ?? this.assignedEmployeeId),
    assignedTeamId: clearTeam ? null : (assignedTeamId ?? this.assignedTeamId),
    status: status ?? this.status,
    descriptionForWork: descriptionForWork ?? this.descriptionForWork,
  );
}

/// User-editable form data only. The UI never builds Drift companions directly.
class ServiceJobAssignmentDraft {
  const ServiceJobAssignmentDraft({
    this.sourceEnquiryId,
    this.scheduledVisitDate,
    this.lines = const [],
  });
  final String? sourceEnquiryId;
  final DateTime? scheduledVisitDate;
  final List<ServiceJobAssignmentLineDraft> lines;

  ServiceJobAssignmentDraft copyWith({
    String? sourceEnquiryId,
    bool clearSourceEnquiry = false,
    DateTime? scheduledVisitDate,
    bool clearVisitDate = false,
    List<ServiceJobAssignmentLineDraft>? lines,
  }) => ServiceJobAssignmentDraft(
    sourceEnquiryId: clearSourceEnquiry
        ? null
        : (sourceEnquiryId ?? this.sourceEnquiryId),
    scheduledVisitDate: clearVisitDate
        ? null
        : (scheduledVisitDate ?? this.scheduledVisitDate),
    lines: lines ?? this.lines,
  );
}

/// Optimized list read model (no per-row repository calls).
class ServiceJobAssignmentListItem {
  const ServiceJobAssignmentListItem({
    required this.id,
    required this.assignmentNumber,
    required this.createdAt,
    required this.scheduledVisitDate,
    required this.status,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    required this.priorityName,
    required this.priorityRank,
    required this.assignedSummary,
    this.customerMobile,
  });
  final String id, assignmentNumber;
  final DateTime createdAt, scheduledVisitDate;
  final ServiceJobAssignmentStatus status;
  final String enquiryNumber, customerName, siteSummary;
  final String? customerMobile;
  final String priorityName;
  final int priorityRank;

  /// Compact "Ahmed Khan + HVAC Team +2 more" summary; never explodes width.
  final String assignedSummary;
}

class ServiceJobAssignmentPage {
  ServiceJobAssignmentPage(
    List<ServiceJobAssignmentListItem> items,
    this.total,
    this.filtered,
  ) : items = List.unmodifiable(items);
  final List<ServiceJobAssignmentListItem> items;
  final int total, filtered;
}

/// A resolved work line for display (employee/team names come from the
/// WorkforceDirectory / Service Team directory, never duplicated).
class ServiceJobAssignmentLineView {
  const ServiceJobAssignmentLineView({
    required this.line,
    this.employeeName,
    this.employeeCode,
    this.teamName,
  });
  final ServiceJobAssignmentLine line;
  final String? employeeName, employeeCode, teamName;
}

/// Detail read model: the aggregate plus the source Enquiry context (customer/
/// site snapshot, classification, material received and enquiry issue lines).
class ServiceJobAssignmentView {
  const ServiceJobAssignmentView({
    required this.assignment,
    required this.lines,
    required this.enquiryNumber,
    required this.customerName,
    required this.priorityName,
    required this.priorityRank,
    required this.complaintTypeName,
    required this.materialReceived,
    required this.partySnapshot,
    this.customerMobile,
    this.enquiryDetails = const [],
  });
  final ServiceJobAssignment assignment;
  final List<ServiceJobAssignmentLineView> lines;
  final String enquiryNumber, customerName;
  final String? customerMobile;
  final String priorityName, complaintTypeName;
  final int priorityRank;
  final MaterialReceived materialReceived;
  final ServiceEnquiryPartySnapshot partySnapshot;
  final List<ServiceEnquiryDetailLine> enquiryDetails;
}

/// Lightweight reference for the next phase (Inspection) — read-only.
class ServiceJobAssignmentRef {
  const ServiceJobAssignmentRef({
    required this.id,
    required this.assignmentNumber,
    required this.sourceEnquiryId,
    required this.customerName,
    required this.siteSummary,
    required this.scheduledVisitDate,
    required this.assignedSummary,
    required this.priorityName,
  });
  final String id, assignmentNumber, sourceEnquiryId;
  final String customerName, siteSummary, assignedSummary, priorityName;
  final DateTime scheduledVisitDate;
}

/// Aggregate metrics for the Services Overview.
class ServiceJobAssignmentSummary {
  const ServiceJobAssignmentSummary({
    required this.activeCount,
    required this.todayCount,
    required this.upcomingCount,
    required this.totalCount,
  });
  final int activeCount, todayCount, upcomingCount, totalCount;
}

/// Restricted, eligible Enquiry reference for the Job Assignment selector.
class ServiceAssignableEnquiryRef {
  const ServiceAssignableEnquiryRef({
    required this.id,
    required this.enquiryNumber,
    required this.customerName,
    required this.siteSummary,
    required this.complaintTypeName,
    required this.priorityName,
    required this.priorityRank,
    this.customerMobile,
  });
  final String id, enquiryNumber, customerName, siteSummary;
  final String? customerMobile;
  final String complaintTypeName, priorityName;
  final int priorityRank;
}

/// Restricted source-Enquiry context for the assignment form/detail (customer/
/// site snapshot, classification, material received and issue lines). Loaded
/// through the Job Assignment reference authorization, never the full Enquiry
/// directory capability.
class ServiceAssignableEnquiryContext {
  const ServiceAssignableEnquiryContext({
    required this.enquiryId,
    required this.enquiryNumber,
    required this.customerName,
    required this.priorityName,
    required this.priorityRank,
    required this.complaintTypeName,
    required this.materialReceived,
    required this.partySnapshot,
    this.customerMobile,
    this.details = const [],
  });
  final String enquiryId, enquiryNumber, customerName;
  final String? customerMobile;
  final String priorityName, complaintTypeName;
  final int priorityRank;
  final MaterialReceived materialReceived;
  final ServiceEnquiryPartySnapshot partySnapshot;
  final List<ServiceEnquiryDetailLine> details;
}
