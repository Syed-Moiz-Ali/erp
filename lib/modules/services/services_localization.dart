import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';

/// Shared Services presentation helpers.

AppStatus serviceStatus(ConfigurationStatus status) =>
    status == ConfigurationStatus.active
    ? AppStatus.success
    : AppStatus.neutral;

String serviceStatusLabel(ConfigurationStatus status, AppLocalizations l) =>
    status == ConfigurationStatus.active ? l.active : l.inactive;

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
