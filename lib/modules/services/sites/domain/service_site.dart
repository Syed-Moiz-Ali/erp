import 'package:modular_erp/core/models/configuration_record.dart';

class ServiceSite {
  const ServiceSite({
    required this.id,
    required this.companyId,
    required this.customerId,
    required this.siteCode,
    required this.siteName,
    required this.addressLine1,
    required this.city,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    this.tenantName,
    this.buildingName,
    this.unitNumber,
    this.contactName,
    this.contactMobile,
    this.contactEmail,
    this.addressLine2,
    this.area,
    this.state,
    this.postalCode,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.notes,
  });
  final String id, companyId, customerId, siteCode, siteName;
  final String addressLine1, city;
  final String? tenantName, buildingName, unitNumber;
  final String? contactName, contactMobile, contactEmail;
  final String? addressLine2, area, state, postalCode, countryCode;
  final double? latitude, longitude;
  final String? notes;
  final ConfigurationStatus status;
  final RecordSyncStatus syncStatus;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
}

class ServiceSiteDraft {
  const ServiceSiteDraft({
    this.customerId,
    this.siteName = '',
    this.tenantName = '',
    this.buildingName = '',
    this.unitNumber = '',
    this.contactName = '',
    this.contactMobile = '',
    this.contactEmail = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.area = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.countryCode = '',
    this.latitude = '',
    this.longitude = '',
    this.notes = '',
  });
  final String? customerId;
  final String siteName, tenantName, buildingName, unitNumber;
  final String contactName, contactMobile, contactEmail;
  final String addressLine1, addressLine2, area, city, state, postalCode;
  final String countryCode, latitude, longitude, notes;

  ServiceSiteDraft copyWith({
    String? customerId,
    String? siteName,
    String? tenantName,
    String? buildingName,
    String? unitNumber,
    String? contactName,
    String? contactMobile,
    String? contactEmail,
    String? addressLine1,
    String? addressLine2,
    String? area,
    String? city,
    String? state,
    String? postalCode,
    String? countryCode,
    String? latitude,
    String? longitude,
    String? notes,
  }) => ServiceSiteDraft(
    customerId: customerId ?? this.customerId,
    siteName: siteName ?? this.siteName,
    tenantName: tenantName ?? this.tenantName,
    buildingName: buildingName ?? this.buildingName,
    unitNumber: unitNumber ?? this.unitNumber,
    contactName: contactName ?? this.contactName,
    contactMobile: contactMobile ?? this.contactMobile,
    contactEmail: contactEmail ?? this.contactEmail,
    addressLine1: addressLine1 ?? this.addressLine1,
    addressLine2: addressLine2 ?? this.addressLine2,
    area: area ?? this.area,
    city: city ?? this.city,
    state: state ?? this.state,
    postalCode: postalCode ?? this.postalCode,
    countryCode: countryCode ?? this.countryCode,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    notes: notes ?? this.notes,
  );
}

class ServiceSiteListItem {
  const ServiceSiteListItem({
    required this.id,
    required this.siteCode,
    required this.siteName,
    required this.customerId,
    required this.customerName,
    required this.city,
    required this.status,
    required this.updatedAt,
    this.buildingName,
    this.unitNumber,
    this.contactName,
  });
  final String id, siteCode, siteName, customerId, customerName, city;
  final String? buildingName, unitNumber, contactName;
  final ConfigurationStatus status;
  final DateTime updatedAt;
}

class ServiceSitePage {
  ServiceSitePage(List<ServiceSiteListItem> items, this.total, this.filtered)
    : items = List.unmodifiable(items);
  final List<ServiceSiteListItem> items;
  final int total, filtered;
}

class ServiceSiteRef {
  const ServiceSiteRef({
    required this.id,
    required this.siteCode,
    required this.displayName,
    required this.customerId,
    required this.customerName,
    this.locationSummary,
  });
  final String id, siteCode, displayName, customerId, customerName;
  final String? locationSummary;
}
