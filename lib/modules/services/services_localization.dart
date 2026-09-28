import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

/// Shared Services presentation helpers.

AppStatus serviceStatus(ConfigurationStatus status) =>
    status == ConfigurationStatus.active
    ? AppStatus.success
    : AppStatus.neutral;

String serviceStatusLabel(ConfigurationStatus status, AppLocalizations l) =>
    status == ConfigurationStatus.active ? l.active : l.inactive;

AppStatus serviceEnquiryStatus(ServiceEnquiryStatus status) => switch (status) {
  ServiceEnquiryStatus.open => AppStatus.info,
  ServiceEnquiryStatus.assigned => AppStatus.brand,
  ServiceEnquiryStatus.cancelled => AppStatus.neutral,
};

String serviceEnquiryStatusLabel(
  ServiceEnquiryStatus status,
  AppLocalizations l,
) => switch (status) {
  ServiceEnquiryStatus.open => l.servicesEnquiryStatusOpen,
  ServiceEnquiryStatus.assigned => l.servicesEnquiryStatusAssigned,
  ServiceEnquiryStatus.cancelled => l.servicesEnquiryStatusCancelled,
};

AppStatus serviceJobAssignmentStatus(ServiceJobAssignmentStatus status) =>
    status.isActive ? AppStatus.info : AppStatus.neutral;

String serviceJobAssignmentStatusLabel(
  ServiceJobAssignmentStatus status,
  AppLocalizations l,
) => status.isActive
    ? l.servicesJobAssignmentStatusActive
    : l.servicesJobAssignmentStatusCancelled;

/// Priority is understandable without color: the semantic status is derived from
/// the configured rank (>=2 = high/urgent) and always paired with the label.
AppStatus servicePriorityStatus(int rank) => switch (rank) {
  >= 3 => AppStatus.danger,
  2 => AppStatus.warning,
  _ => AppStatus.neutral,
};

String serviceEnquiryDetailStatusLabel(
  ServiceEnquiryDetailStatus status,
  AppLocalizations l,
) => status.isOpen
    ? l.servicesEnquiryDetailStatusOpen
    : l.servicesEnquiryDetailStatusClosed;

String serviceMaterialReceivedLabel(
  MaterialReceived value,
  AppLocalizations l,
) => value.isYes
    ? l.servicesEnquiryMaterialReceivedYes
    : l.servicesEnquiryMaterialReceivedNo;

AppStatus attachmentUploadStatus(AttachmentUploadStatus status) =>
    switch (status) {
      AttachmentUploadStatus.uploaded => AppStatus.success,
      AttachmentUploadStatus.failed => AppStatus.danger,
      AttachmentUploadStatus.pendingUpload => AppStatus.info,
      AttachmentUploadStatus.localOnly => AppStatus.warning,
      AttachmentUploadStatus.pendingDelete ||
      AttachmentUploadStatus.deleted => AppStatus.neutral,
    };

String attachmentUploadStatusLabel(
  AttachmentUploadStatus status,
  AppLocalizations l,
) => switch (status) {
  AttachmentUploadStatus.uploaded => l.attachmentUploaded,
  AttachmentUploadStatus.failed => l.attachmentFailed,
  AttachmentUploadStatus.pendingUpload => l.attachmentPendingUpload,
  AttachmentUploadStatus.pendingDelete => l.attachmentPendingDelete,
  AttachmentUploadStatus.deleted => l.attachmentDeleted,
  AttachmentUploadStatus.localOnly => l.attachmentLocalOnly,
};

/// Localizes a Services activity event type key (for example
/// `services.customer.created`) without persisting English sentences.
String serviceActivityEventLabel(String eventType, AppLocalizations l) {
  if (eventType.contains('members')) {
    return l.servicesActivityMembersUpdated;
  }
  return switch (eventType.split('.').last) {
    'created' => l.servicesActivityCreated,
    'updated' => l.servicesActivityUpdated,
    'activated' => l.servicesActivityActivated,
    'deactivated' => l.servicesActivityDeactivated,
    'cancelled' => l.servicesActivityCancelled,
    'assigned' => l.servicesActivityAssigned,
    'reopened' => l.servicesActivityReopened,
    'completed' => l.servicesActivityCompleted,
    'linesChanged' => l.servicesActivityLinesChanged,
    'workStarted' => l.servicesActivityWorkStarted,
    'workEnded' => l.servicesActivityWorkEnded,
    'materialUsedAdded' => l.servicesActivityMaterialUsedAdded,
    'materialUsedRemoved' => l.servicesActivityMaterialUsedRemoved,
    'photoAdded' => l.servicesActivityPhotoAdded,
    'photoUpdated' => l.servicesActivityPhotoUpdated,
    'photoRemoved' => l.servicesActivityPhotoRemoved,
    _ => l.servicesActivityUnknown,
  };
}

/// Localizes a Services activity event (see [serviceActivityEventLabel]).
String serviceActivityLabel(BusinessActivityEvent event, AppLocalizations l) =>
    serviceActivityEventLabel(event.eventType, l);

/// Localizes an activity entity type (`serviceJobAssignment` → nav label).
String serviceActivityEntityTypeLabel(String entityType, AppLocalizations l) =>
    switch (entityType) {
      'serviceCustomer' => l.servicesNavCustomers,
      'serviceSite' => l.servicesNavSites,
      'serviceTeam' => l.servicesNavTeams,
      'serviceEnquiry' => l.servicesNavEnquiries,
      'serviceJobAssignment' => l.servicesNavJobAssignments,
      'serviceInspection' => l.servicesNavInspections,
      'serviceMaterialRequest' => l.servicesNavMaterialRequests,
      'serviceMaterialRequestPurpose' => l.servicesMaterialRequestPurposesTitle,
      'serviceWorkExecution' => l.servicesNavWorkExecution,
      _ => l.servicesPermModuleServices,
    };

String serviceActivityEntityLabel(
  BusinessActivityEvent event,
  AppLocalizations l,
) => serviceActivityEntityTypeLabel(event.entityType, l);

AppStatus serviceInspectionStatus(ServiceInspectionStatus status) =>
    switch (status) {
      ServiceInspectionStatus.pending => AppStatus.info,
      ServiceInspectionStatus.completed => AppStatus.success,
      ServiceInspectionStatus.cancelled => AppStatus.neutral,
    };

String serviceInspectionStatusLabel(
  ServiceInspectionStatus status,
  AppLocalizations l,
) => switch (status) {
  ServiceInspectionStatus.pending => l.servicesInspectionStatusPending,
  ServiceInspectionStatus.completed => l.servicesInspectionStatusCompleted,
  ServiceInspectionStatus.cancelled => l.servicesInspectionStatusCancelled,
};

String serviceInspectionChecklistStatusLabel(
  ServiceInspectionChecklistStatus status,
  AppLocalizations l,
) => l.servicesInspectionChecklistStatusPending;

String serviceInspectionMaterialStatusLabel(
  ServiceInspectionMaterialStatus status,
  AppLocalizations l,
) => switch (status) {
  ServiceInspectionMaterialStatus.waiting =>
    l.servicesInspectionMaterialStatusWaiting,
  ServiceInspectionMaterialStatus.requested =>
    l.servicesInspectionMaterialStatusRequested,
};

AppStatus serviceMaterialRequestStatus(ServiceMaterialRequestStatus status) =>
    status.isOpen ? AppStatus.info : AppStatus.neutral;

String serviceMaterialRequestStatusLabel(
  ServiceMaterialRequestStatus status,
  AppLocalizations l,
) => status.isOpen
    ? l.servicesMaterialRequestStatusOpen
    : l.servicesMaterialRequestStatusCancelled;

/// Localizes a Services repository failure code. Returns `null` for unknown or
/// generic codes so the caller can fall back to a generic storage message.
String? serviceFailureMessage(String? code, AppLocalizations l) =>
    switch (code) {
      'servicesCustomerDuplicateMobile' => l.servicesCustomerDuplicateMobile,
      'servicesCustomerDuplicateEmail' => l.servicesCustomerDuplicateEmail,
      'servicesCustomerInvalidMobile' => l.servicesCustomerInvalidMobile,
      'servicesCustomerInvalidEmail' => l.servicesCustomerInvalidEmail,
      'servicesCustomerRequired' => l.servicesCustomerRequired,
      'servicesCustomerNotFound' => l.servicesCustomerNotFound,
      'servicesSiteCustomerRequired' => l.servicesSiteCustomerRequired,
      'servicesSiteRequired' => l.servicesSiteRequired,
      'servicesSiteNotFound' => l.servicesSiteNotFound,
      'servicesTeamRequired' => l.servicesTeamRequired,
      'servicesTeamNotFound' => l.servicesTeamNotFound,
      'servicesCustomerDenied' ||
      'servicesSiteDenied' ||
      'servicesTeamDenied' => l.servicesDenied,
      _ => null,
    };

/// Maps a Services failure code to the form field it should highlight.
String? serviceFieldForFailure(String? code) => switch (code) {
  'servicesCustomerDuplicateMobile' ||
  'servicesCustomerInvalidMobile' => 'mobile',
  'servicesCustomerDuplicateEmail' || 'servicesCustomerInvalidEmail' => 'email',
  'servicesCustomerRequired' => 'name',
  'servicesSiteCustomerRequired' => 'customer',
  'servicesSiteRequired' => 'siteName',
  'servicesTeamRequired' => 'name',
  _ => null,
};

/// Localizes a Service Enquiry failure code (returns null for generic codes so
/// the caller can fall back to a storage message).
String? serviceEnquiryFailureMessage(
  String? code,
  AppLocalizations l,
) => switch (code) {
  'servicesEnquiryDenied' => l.servicesEnquiryDenied,
  'servicesEnquiryNotFound' => l.servicesEnquiryNotFound,
  'servicesEnquiryNotEditable' => l.servicesEnquiryNotEditable,
  'servicesEnquiryAlreadyCancelled' => l.servicesEnquiryAlreadyCancelled,
  'servicesEnquiryCustomerRequired' => l.servicesEnquiryCustomerRequired,
  'servicesEnquiryCustomerNotFound' => l.servicesEnquiryCustomerNotFound,
  'servicesEnquiryCustomerInactive' => l.servicesEnquiryCustomerInactive,
  'servicesEnquirySiteRequired' => l.servicesEnquirySiteRequired,
  'servicesEnquirySiteNotFound' => l.servicesEnquirySiteNotFound,
  'servicesEnquirySiteInactive' => l.servicesEnquirySiteInactive,
  'servicesEnquirySiteCustomerMismatch' =>
    l.servicesEnquirySiteCustomerMismatch,
  'servicesEnquiryServiceTypeRequired' => l.servicesEnquiryServiceTypeRequired,
  'servicesEnquiryServiceTypeInvalid' => l.servicesEnquiryServiceTypeInvalid,
  'servicesEnquiryComplaintTypeRequired' =>
    l.servicesEnquiryComplaintTypeRequired,
  'servicesEnquiryComplaintTypeInvalid' =>
    l.servicesEnquiryComplaintTypeInvalid,
  'servicesEnquiryComplaintTypeMismatch' =>
    l.servicesEnquiryComplaintTypeMismatch,
  'servicesEnquiryPriorityRequired' => l.servicesEnquiryPriorityRequired,
  'servicesEnquiryPriorityInvalid' => l.servicesEnquiryPriorityInvalid,
  'servicesEnquiryTicketTypeRequired' => l.servicesEnquiryTicketTypeRequired,
  'servicesEnquiryTicketTypeInvalid' => l.servicesEnquiryTicketTypeInvalid,
  'servicesEnquiryDescriptionRequired' => l.servicesEnquiryDescriptionRequired,
  'servicesEnquiryDescriptionTooLong' => l.servicesEnquiryDescriptionTooLong,
  'servicesEnquiryDetailsRequired' => l.servicesEnquiryDetailsRequired,
  'servicesEnquiryDetailDescriptionRequired' =>
    l.servicesEnquiryDetailDescriptionRequired,
  'servicesEnquiryAttachmentUnsupportedType' ||
  'attachmentUnsupportedType' ||
  'attachmentEmptyFile' => l.servicesEnquiryAttachmentUnsupportedType,
  'servicesEnquiryAttachmentTooLarge' ||
  'attachmentTooLarge' => l.servicesEnquiryAttachmentTooLarge,
  'servicesEnquiryAttachmentLimitReached' ||
  'attachmentLimitReached' => l.servicesEnquiryAttachmentLimitReached,
  'servicesEnquiryAttachmentFailure' ||
  'attachmentFailure' => l.servicesEnquiryAttachmentFailure,
  'servicesEnquirySequenceFailed' => l.servicesEnquirySequenceFailed,
  _ => null,
};

/// Maps an Enquiry failure code to the form field it should highlight.
String? serviceEnquiryFieldForFailure(String? code) => switch (code) {
  'servicesEnquiryCustomerRequired' ||
  'servicesEnquiryCustomerNotFound' ||
  'servicesEnquiryCustomerInactive' => 'customer',
  'servicesEnquirySiteRequired' ||
  'servicesEnquirySiteNotFound' ||
  'servicesEnquirySiteInactive' ||
  'servicesEnquirySiteCustomerMismatch' => 'site',
  'servicesEnquiryServiceTypeRequired' ||
  'servicesEnquiryServiceTypeInvalid' => 'serviceType',
  'servicesEnquiryComplaintTypeRequired' ||
  'servicesEnquiryComplaintTypeInvalid' ||
  'servicesEnquiryComplaintTypeMismatch' => 'complaintType',
  'servicesEnquiryPriorityRequired' ||
  'servicesEnquiryPriorityInvalid' => 'priority',
  'servicesEnquiryTicketTypeRequired' ||
  'servicesEnquiryTicketTypeInvalid' => 'ticketType',
  'servicesEnquiryDescriptionRequired' ||
  'servicesEnquiryDescriptionTooLong' => 'description',
  _ => null,
};

/// Localizes a Job Assignment failure code (null for generic codes).
String? serviceJobAssignmentFailureMessage(
  String? code,
  AppLocalizations l,
) => switch (code) {
  'servicesJobAssignmentDenied' => l.servicesJobAssignmentDenied,
  'servicesJobAssignmentNotFound' => l.servicesJobAssignmentNotFound,
  'servicesJobAssignmentNotEditable' => l.servicesJobAssignmentNotEditable,
  'servicesJobAssignmentAlreadyCancelled' =>
    l.servicesJobAssignmentAlreadyCancelled,
  'servicesJobAssignmentEnquiryRequired' =>
    l.servicesJobAssignmentEnquiryRequired,
  'servicesJobAssignmentEnquiryNotFound' =>
    l.servicesJobAssignmentEnquiryNotFound,
  'servicesJobAssignmentEnquiryNotOpen' =>
    l.servicesJobAssignmentEnquiryNotOpen,
  'servicesJobAssignmentAlreadyActive' => l.servicesJobAssignmentAlreadyActive,
  'servicesJobAssignmentVisitDateRequired' =>
    l.servicesJobAssignmentVisitDateRequired,
  'servicesJobAssignmentLinesRequired' => l.servicesJobAssignmentLinesRequired,
  'servicesJobAssignmentWorkRequired' => l.servicesJobAssignmentWorkRequired,
  'servicesJobAssignmentWorkTooLong' => l.servicesJobAssignmentWorkTooLong,
  'servicesJobAssignmentDescriptionTooLong' =>
    l.servicesJobAssignmentDescriptionTooLong,
  'servicesJobAssignmentTargetRequired' =>
    l.servicesJobAssignmentTargetRequired,
  'servicesJobAssignmentEmployeeInvalid' =>
    l.servicesJobAssignmentEmployeeInvalid,
  'servicesJobAssignmentTeamInvalid' => l.servicesJobAssignmentTeamInvalid,
  'servicesJobAssignmentEmployeeNotInTeam' =>
    l.servicesJobAssignmentEmployeeNotInTeam,
  'servicesJobAssignmentSequenceFailed' =>
    l.servicesJobAssignmentSequenceFailed,
  _ => null,
};

/// Localizes a Job Assignment failure code (null for generic codes).
String? serviceInspectionFailureMessage(
  String? code,
  AppLocalizations l,
) => switch (code) {
  'servicesInspectionDenied' => l.servicesInspectionDenied,
  'servicesInspectionNotFound' => l.servicesInspectionNotFound,
  'servicesInspectionNotEditable' => l.servicesInspectionNotEditable,
  'servicesInspectionNotCompletable' => l.servicesInspectionNotCompletable,
  'servicesInspectionAlreadyCancelled' => l.servicesInspectionAlreadyCancelled,
  'servicesInspectionNotCancellable' => l.servicesInspectionNotCancellable,
  'servicesInspectionAssignmentRequired' =>
    l.servicesInspectionAssignmentRequired,
  'servicesInspectionAssignmentInvalid' =>
    l.servicesInspectionAssignmentInvalid,
  'servicesInspectionAlreadyActive' => l.servicesInspectionAlreadyActive,
  'servicesInspectionVisitDateRequired' =>
    l.servicesInspectionVisitDateRequired,
  'servicesInspectionVisitTimeRequired' =>
    l.servicesInspectionVisitTimeRequired,
  'servicesInspectionTechnicianRequired' =>
    l.servicesInspectionTechnicianRequired,
  'servicesInspectionTechnicianInvalid' =>
    l.servicesInspectionTechnicianInvalid,
  'servicesInspectionRootCauseRequired' =>
    l.servicesInspectionRootCauseRequired,
  'servicesInspectionRootCauseInvalid' => l.servicesInspectionRootCauseInvalid,
  'servicesInspectionChargeResponsibilityRequired' =>
    l.servicesInspectionChargeResponsibilityRequired,
  'servicesInspectionChargeResponsibilityInvalid' =>
    l.servicesInspectionChargeResponsibilityInvalid,
  'servicesInspectionAssessmentRequired' =>
    l.servicesInspectionAssessmentRequired,
  'servicesInspectionWorkTypeRequired' => l.servicesInspectionWorkTypeRequired,
  'servicesInspectionPointRequired' => l.servicesInspectionPointRequired,
  'servicesInspectionMaterialCodeRequired' =>
    l.servicesInspectionMaterialCodeRequired,
  'servicesInspectionMaterialDescriptionRequired' =>
    l.servicesInspectionMaterialDescriptionRequired,
  'servicesInspectionSequenceFailed' => l.servicesInspectionSequenceFailed,
  _ => null,
};

/// Localizes a Material Request failure code (null for generic codes).
String? serviceMaterialRequestFailureMessage(
  String? code,
  AppLocalizations l,
) => switch (code) {
  'servicesMaterialRequestDenied' => l.servicesMaterialRequestDenied,
  'servicesMaterialRequestNotFound' => l.servicesMaterialRequestNotFound,
  'servicesMaterialRequestNotEditable' => l.servicesMaterialRequestNotEditable,
  'servicesMaterialRequestAlreadyCancelled' =>
    l.servicesMaterialRequestAlreadyCancelled,
  'servicesMaterialRequestInspectionRequired' =>
    l.servicesMaterialRequestInspectionRequired,
  'servicesMaterialRequestInspectionInvalid' =>
    l.servicesMaterialRequestInspectionInvalid,
  'servicesMaterialRequestPurposeInvalid' =>
    l.servicesMaterialRequestPurposeInvalid,
  'servicesMaterialRequestLinesRequired' =>
    l.servicesMaterialRequestLinesRequired,
  'servicesMaterialRequestCodeRequired' =>
    l.servicesMaterialRequestCodeRequired,
  'servicesMaterialRequestDescriptionRequired' =>
    l.servicesMaterialRequestDescriptionRequired,
  'servicesMaterialRequestQuantityRequired' =>
    l.servicesMaterialRequestQuantityRequired,
  'servicesMaterialRequestRequirementLinked' =>
    l.servicesMaterialRequestRequirementLinked,
  'servicesMaterialRequestSequenceFailed' =>
    l.servicesMaterialRequestSequenceFailed,
  _ => null,
};

/// Work Execution overall status presentation.
AppStatus serviceWorkExecutionStatus(ServiceWorkExecutionStatus status) =>
    switch (status) {
      ServiceWorkExecutionStatus.pending => AppStatus.info,
      ServiceWorkExecutionStatus.inProgress => AppStatus.brand,
      ServiceWorkExecutionStatus.completed => AppStatus.success,
      ServiceWorkExecutionStatus.cancelled => AppStatus.neutral,
    };

String serviceWorkExecutionStatusLabel(
  ServiceWorkExecutionStatus status,
  AppLocalizations l,
) => switch (status) {
  ServiceWorkExecutionStatus.pending => l.servicesWorkExecutionStatusPending,
  ServiceWorkExecutionStatus.inProgress =>
    l.servicesWorkExecutionStatusInProgress,
  ServiceWorkExecutionStatus.completed =>
    l.servicesWorkExecutionStatusCompleted,
  ServiceWorkExecutionStatus.cancelled =>
    l.servicesWorkExecutionStatusCancelled,
};

/// Derived work line execution state presentation.
AppStatus serviceWorkLineStateStatus(ServiceWorkLineState state) =>
    switch (state) {
      ServiceWorkLineState.notStarted => AppStatus.neutral,
      ServiceWorkLineState.inProgress => AppStatus.brand,
      ServiceWorkLineState.finished => AppStatus.success,
    };

String serviceWorkLineStateLabel(
  ServiceWorkLineState state,
  AppLocalizations l,
) => switch (state) {
  ServiceWorkLineState.notStarted => l.servicesWorkExecutionLineStateNotStarted,
  ServiceWorkLineState.inProgress => l.servicesWorkExecutionLineStateInProgress,
  ServiceWorkLineState.finished => l.servicesWorkExecutionLineStateFinished,
};

String serviceWorkMaterialRequestStatusLabel(
  String status,
  AppLocalizations l,
) => status == 'cancelled'
    ? l.servicesMaterialRequestStatusCancelled
    : l.servicesMaterialRequestStatusOpen;

/// Localizes a Work Execution failure code (null for generic codes).
String? serviceWorkExecutionFailureMessage(
  String? code,
  AppLocalizations l,
) => switch (code) {
  'servicesWorkExecutionDenied' => l.servicesWorkExecutionDenied,
  'servicesWorkExecutionNotFound' => l.servicesWorkExecutionNotFound,
  'servicesWorkExecutionNotEditable' => l.servicesWorkExecutionNotEditable,
  'servicesWorkExecutionNotCompletable' =>
    l.servicesWorkExecutionNotCompletable,
  'servicesWorkExecutionAlreadyCompleted' =>
    l.servicesWorkExecutionAlreadyCompleted,
  'servicesWorkExecutionCancelled' => l.servicesWorkExecutionCancelled,
  'servicesWorkExecutionLineAlreadyStarted' =>
    l.servicesWorkExecutionLineAlreadyStarted,
  'servicesWorkExecutionLineNotStarted' =>
    l.servicesWorkExecutionLineNotStarted,
  'servicesWorkExecutionLineAlreadyEnded' =>
    l.servicesWorkExecutionLineAlreadyEnded,
  'servicesWorkExecutionInvalidTimeRange' =>
    l.servicesWorkExecutionInvalidTimeRange,
  'servicesWorkExecutionInspectionRequired' =>
    l.servicesWorkExecutionInspectionRequired,
  'servicesWorkExecutionInspectionNotEligible' =>
    l.servicesWorkExecutionInspectionNotEligible,
  'servicesWorkExecutionAlreadyActive' => l.servicesWorkExecutionAlreadyActive,
  'servicesWorkExecutionSequenceFailed' =>
    l.servicesWorkExecutionSequenceFailed,
  'servicesWorkExecutionLinesRequired' => l.servicesWorkExecutionLinesRequired,
  'servicesWorkExecutionWorkRequired' => l.servicesWorkExecutionWorkRequired,
  'servicesWorkExecutionCodeRequired' => l.servicesWorkExecutionCodeRequired,
  'servicesWorkExecutionDescriptionRequired' =>
    l.servicesWorkExecutionDescriptionRequired,
  'servicesWorkExecutionPhotoDescriptionRequired' =>
    l.servicesWorkExecutionPhotoDescriptionRequired,
  'servicesWorkExecutionTeamInvalid' => l.servicesWorkExecutionTeamInvalid,
  'servicesWorkExecutionEmployeeInvalid' =>
    l.servicesWorkExecutionEmployeeInvalid,
  'servicesWorkExecutionMaterialRequestLineInvalid' =>
    l.servicesWorkExecutionMaterialRequestLineInvalid,
  _ => null,
};

/// Maps a Work Execution failure code to the form field it should highlight.
String? serviceWorkExecutionFieldForFailure(String? code) => switch (code) {
  'servicesWorkExecutionLinesRequired' ||
  'servicesWorkExecutionWorkRequired' => 'workLines',
  'servicesWorkExecutionCodeRequired' ||
  'servicesWorkExecutionDescriptionRequired' => 'materialsUsed',
  'servicesWorkExecutionPhotoDescriptionRequired' => 'photos',
  _ => null,
};
