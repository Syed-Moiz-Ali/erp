import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
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

/// Localizes a Services activity event key (for example
/// `services.customer.created`) without persisting English sentences.
String serviceActivityLabel(BusinessActivityEvent event, AppLocalizations l) {
  if (event.eventType.contains('members')) {
    return l.servicesActivityMembersUpdated;
  }
  return switch (event.eventType.split('.').last) {
    'created' => l.servicesActivityCreated,
    'updated' => l.servicesActivityUpdated,
    'activated' => l.servicesActivityActivated,
    'deactivated' => l.servicesActivityDeactivated,
    'cancelled' => l.servicesActivityCancelled,
    'assigned' => l.servicesActivityAssigned,
    'reopened' => l.servicesActivityReopened,
    _ => l.servicesActivityUnknown,
  };
}

String serviceActivityEntityLabel(
  BusinessActivityEvent event,
  AppLocalizations l,
) => switch (event.entityType) {
  'serviceCustomer' => l.servicesNavCustomers,
  'serviceSite' => l.servicesNavSites,
  'serviceTeam' => l.servicesNavTeams,
  'serviceEnquiry' => l.servicesNavEnquiries,
  'serviceJobAssignment' => l.servicesNavJobAssignments,
  _ => l.servicesPermModuleServices,
};

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
