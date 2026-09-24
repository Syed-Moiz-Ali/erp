import 'package:modular_erp/core/models/configuration_record.dart';

enum ServiceCustomerKind { individual, organization }

class ServiceCustomer {
  const ServiceCustomer({
    required this.id,
    required this.companyId,
    required this.customerCode,
    required this.name,
    required this.kind,
    required this.mobile,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    this.alternateMobile,
    this.email,
    this.notes,
  });
  final String id, companyId, customerCode, name, mobile;
  final ServiceCustomerKind kind;
  final String? alternateMobile, email, notes;
  final ConfigurationStatus status;
  final RecordSyncStatus syncStatus;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
}

class ServiceCustomerDraft {
  const ServiceCustomerDraft({
    this.name = '',
    this.kind = ServiceCustomerKind.individual,
    this.mobile = '',
    this.alternateMobile = '',
    this.email = '',
    this.notes = '',
  });
  final String name, mobile, alternateMobile, email, notes;
  final ServiceCustomerKind kind;

  ServiceCustomerDraft copyWith({
    String? name,
    ServiceCustomerKind? kind,
    String? mobile,
    String? alternateMobile,
    String? email,
    String? notes,
  }) => ServiceCustomerDraft(
    name: name ?? this.name,
    kind: kind ?? this.kind,
    mobile: mobile ?? this.mobile,
    alternateMobile: alternateMobile ?? this.alternateMobile,
    email: email ?? this.email,
    notes: notes ?? this.notes,
  );
}

class ServiceCustomerListItem {
  const ServiceCustomerListItem({
    required this.id,
    required this.customerCode,
    required this.name,
    required this.mobile,
    required this.status,
    required this.siteCount,
    required this.updatedAt,
  });
  final String id, customerCode, name, mobile;
  final ConfigurationStatus status;
  final int siteCount;
  final DateTime updatedAt;
}

class ServiceCustomerPage {
  ServiceCustomerPage(
    List<ServiceCustomerListItem> items,
    this.total,
    this.filtered,
  ) : items = List.unmodifiable(items);
  final List<ServiceCustomerListItem> items;
  final int total, filtered;
}

/// Lightweight reference for selectors (sites, future enquiries).
class ServiceCustomerRef {
  const ServiceCustomerRef({
    required this.id,
    required this.customerCode,
    required this.displayName,
    this.mobile,
  });
  final String id, customerCode, displayName;
  final String? mobile;
}
