/// Wire DTO for `GET /api/me/permissions`.
///
/// Transport-only: the domain mapper converts backend keys into runtime
/// permissions and derived module entitlement.
class MyPermissionsDto {
  const MyPermissionsDto({
    required this.userId,
    required this.employeeId,
    required this.permissions,
  });

  final int userId;
  final int? employeeId;
  final List<String> permissions;

  factory MyPermissionsDto.fromJson(Map<String, dynamic> json) {
    final raw = json['permissions'];
    return MyPermissionsDto(
      userId: (json['userId'] as num).toInt(),
      employeeId: (json['employeeId'] as num?)?.toInt(),
      permissions: raw is List
          ? raw.whereType<String>().toList(growable: false)
          : const [],
    );
  }
}
