import 'package:modular_erp/core/models/configuration_record.dart';

enum ServiceMasterKind { serviceType, complaintType, priority, ticketType }

extension ServiceMasterKindX on ServiceMasterKind {
  String get table => switch (this) {
    ServiceMasterKind.serviceType => 'service_types',
    ServiceMasterKind.complaintType => 'complaint_types',
    ServiceMasterKind.priority => 'service_priorities',
    ServiceMasterKind.ticketType => 'service_ticket_types',
  };
  String get entityType => switch (this) {
    ServiceMasterKind.serviceType => 'serviceType',
    ServiceMasterKind.complaintType => 'complaintType',
    ServiceMasterKind.priority => 'servicePriority',
    ServiceMasterKind.ticketType => 'serviceTicketType',
  };
  String get createOperation => switch (this) {
    ServiceMasterKind.serviceType => 'SERVICES_SERVICE_TYPE_CREATE',
    ServiceMasterKind.complaintType => 'SERVICES_COMPLAINT_TYPE_CREATE',
    ServiceMasterKind.priority => 'SERVICES_PRIORITY_CREATE',
    ServiceMasterKind.ticketType => 'SERVICES_TICKET_TYPE_CREATE',
  };
}

class ServiceMasterRecord {
  const ServiceMasterRecord({
    required this.id,
    required this.companyId,
    required this.code,
    required this.name,
    required this.status,
    required this.syncStatus,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.serviceTypeId,
    this.rank = 0,
    this.isDefault = false,
  });
  final String id, companyId, code, name;
  final String? description, serviceTypeId;
  final int sortOrder, rank;
  final bool isDefault;
  final ConfigurationStatus status;
  final RecordSyncStatus syncStatus;
  final DateTime createdAt, updatedAt;
}

class ServiceMasterDraft {
  const ServiceMasterDraft({
    this.code = '',
    this.name = '',
    this.description = '',
    this.sortOrder = '0',
    this.serviceTypeId,
    this.rank = '0',
    this.isDefault = false,
  });
  final String code, name, description, sortOrder, rank;
  final String? serviceTypeId;
  final bool isDefault;

  ServiceMasterDraft copyWith({
    String? code,
    String? name,
    String? description,
    String? sortOrder,
    String? serviceTypeId,
    bool clearServiceType = false,
    String? rank,
    bool? isDefault,
  }) => ServiceMasterDraft(
    code: code ?? this.code,
    name: name ?? this.name,
    description: description ?? this.description,
    sortOrder: sortOrder ?? this.sortOrder,
    serviceTypeId: clearServiceType
        ? null
        : (serviceTypeId ?? this.serviceTypeId),
    rank: rank ?? this.rank,
    isDefault: isDefault ?? this.isDefault,
  );
}

class ServiceMasterPage {
  ServiceMasterPage(List<ServiceMasterRecord> items, this.total, this.filtered)
    : items = List.unmodifiable(items);
  final List<ServiceMasterRecord> items;
  final int total, filtered;
}
