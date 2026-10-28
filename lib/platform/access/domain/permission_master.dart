/// Backend permission master record (`/api/permissions`).
class PermissionMaster {
  const PermissionMaster({
    required this.id,
    required this.key,
    required this.name,
    required this.statusId,
    this.description,
    this.status,
    this.createdOn,
    this.modifiedOn,
  });

  final int id;
  final String key;
  final String name;
  final int statusId;
  final String? description;
  final String? status;
  final DateTime? createdOn;
  final DateTime? modifiedOn;

  bool get isActive => statusId == 1;
}
