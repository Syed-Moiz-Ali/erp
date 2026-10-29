// Wire DTOs for `/api/permissions` and `/api/user-permissions`.
//
// Transport-only; the remote access repository maps them to the existing
// access domain (`AccessUserListItem`, `UserPermissionGrant`).

class PermissionDto {
  const PermissionDto({
    required this.permissionId,
    required this.permissionKey,
    required this.permissionName,
    required this.statusId,
    this.description,
    this.status,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  final int permissionId;
  final String permissionKey;
  final String permissionName;
  final int statusId;
  final String? description;
  final String? status;
  final int? createdBy;
  final DateTime? createdOn;
  final int? modifiedBy;
  final DateTime? modifiedOn;

  bool get isActive => statusId == 1;

  factory PermissionDto.fromJson(Map<String, dynamic> json) => PermissionDto(
    permissionId: (json['permissionId'] as num).toInt(),
    permissionKey: json['permissionKey'] as String? ?? '',
    permissionName: json['permissionName'] as String? ?? '',
    statusId: (json['statusId'] as num?)?.toInt() ?? 0,
    description: json['description'] as String?,
    status: json['status'] as String?,
    createdBy: (json['createdBy'] as num?)?.toInt(),
    createdOn: DateTime.tryParse(json['createdOn'] as String? ?? ''),
    modifiedBy: (json['modifiedBy'] as num?)?.toInt(),
    modifiedOn: DateTime.tryParse(json['modifiedOn'] as String? ?? ''),
  );
}

class UserPermissionDto {
  const UserPermissionDto({
    required this.userPermissionId,
    required this.userId,
    required this.permissionId,
    required this.permissionStatusId,
    this.loginId,
    this.userName,
    this.employeeId,
    this.employeeCode,
    this.employeeName,
    this.permissionKey,
    this.permissionName,
    this.createdBy,
    this.createdOn,
  });

  final int userPermissionId;
  final int userId;
  final int permissionId;
  final int permissionStatusId;
  final String? loginId;
  final String? userName;
  final int? employeeId;
  final String? employeeCode;
  final String? employeeName;
  final String? permissionKey;
  final String? permissionName;
  final int? createdBy;
  final DateTime? createdOn;

  bool get isActive => permissionStatusId == 1;

  factory UserPermissionDto.fromJson(Map<String, dynamic> json) =>
      UserPermissionDto(
        userPermissionId: (json['userPermissionId'] as num).toInt(),
        userId: (json['userId'] as num).toInt(),
        permissionId: (json['permissionId'] as num).toInt(),
        permissionStatusId: (json['permissionStatusId'] as num?)?.toInt() ?? 0,
        loginId: json['loginId'] as String?,
        userName: json['userName'] as String?,
        employeeId: (json['employeeId'] as num?)?.toInt(),
        employeeCode: json['employeeCode'] as String?,
        employeeName: json['employeeName'] as String?,
        permissionKey: json['permissionKey'] as String?,
        permissionName: json['permissionName'] as String?,
        createdBy: (json['createdBy'] as num?)?.toInt(),
        createdOn: DateTime.tryParse(json['createdOn'] as String? ?? ''),
      );
}
