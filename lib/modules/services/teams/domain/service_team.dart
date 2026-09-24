import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';

class ServiceTeam {
  const ServiceTeam({
    required this.id,
    required this.companyId,
    required this.teamCode,
    required this.name,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    this.description,
    this.leadEmployeeId,
  });
  final String id, companyId, teamCode, name;
  final String? description, leadEmployeeId;
  final ConfigurationStatus status;
  final RecordSyncStatus syncStatus;
  final DateTime createdAt, updatedAt;
  final String createdByUserId, updatedByUserId;
}

class ServiceTeamDraft {
  const ServiceTeamDraft({
    this.name = '',
    this.description = '',
    this.leadEmployeeId,
    this.memberIds = const [],
  });
  final String name, description;
  final String? leadEmployeeId;
  final List<String> memberIds;

  ServiceTeamDraft copyWith({
    String? name,
    String? description,
    String? leadEmployeeId,
    bool clearLead = false,
    List<String>? memberIds,
  }) => ServiceTeamDraft(
    name: name ?? this.name,
    description: description ?? this.description,
    leadEmployeeId: clearLead ? null : (leadEmployeeId ?? this.leadEmployeeId),
    memberIds: memberIds ?? this.memberIds,
  );
}

class ServiceTeamMember {
  const ServiceTeamMember({
    required this.id,
    required this.companyId,
    required this.teamId,
    required this.employeeId,
    required this.status,
    required this.createdAt,
    required this.createdByUserId,
  });
  final String id, companyId, teamId, employeeId, status;
  final DateTime createdAt;
  final String createdByUserId;
}

class ServiceTeamListItem {
  const ServiceTeamListItem({
    required this.id,
    required this.teamCode,
    required this.name,
    required this.memberCount,
    required this.status,
    required this.updatedAt,
    this.leadName,
  });
  final String id, teamCode, name;
  final String? leadName;
  final int memberCount;
  final ConfigurationStatus status;
  final DateTime updatedAt;
}

class ServiceTeamPage {
  ServiceTeamPage(List<ServiceTeamListItem> items, this.total, this.filtered)
    : items = List.unmodifiable(items);
  final List<ServiceTeamListItem> items;
  final int total, filtered;
}

class ServiceTeamRef {
  const ServiceTeamRef({
    required this.id,
    required this.teamCode,
    required this.displayName,
  });
  final String id, teamCode, displayName;
}

/// A resolved team member for display (employee data comes from
/// [WorkforceDirectory], never duplicated).
class ServiceTeamMemberView {
  const ServiceTeamMemberView({
    required this.employeeId,
    required this.name,
    required this.employeeCode,
    this.designationId,
    this.departmentId,
    this.isActive = true,
  });
  final String employeeId, name, employeeCode;
  final String? designationId, departmentId;
  final bool isActive;
}

ServiceTeamMemberView memberView(WorkforcePersonRef ref) =>
    ServiceTeamMemberView(
      employeeId: ref.id,
      name: ref.name,
      employeeCode: ref.employeeCode,
      designationId: ref.designationId,
      departmentId: ref.departmentId,
      isActive: ref.isActive,
    );
