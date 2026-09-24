import 'package:json_annotation/json_annotation.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/core/security/app_permission.dart';
part 'auth_session_dto.g.dart';

/// Wire boundary. Backend codes never escape into presentation.
@JsonSerializable()
class AuthSessionDto {
  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
    required this.company,
    this.employee,
    this.settings = const {},
    this.version = 1,
  });
  final int version;
  final String accessToken, refreshToken;
  final DateTime expiresAt;
  final Map<String, dynamic> user, company;
  final Map<String, dynamic>? employee;
  final Map<String, String> settings;
  factory AuthSessionDto.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AuthSessionDtoToJson(this);
  @override
  String toString() => 'AuthSessionDto([redacted])';
}

abstract final class AuthSessionMapper {
  static AuthSession decode(AuthSessionDto dto) {
    if (dto.version != 1 ||
        dto.accessToken.isEmpty ||
        dto.refreshToken.isEmpty) {
      throw const FormatException('Invalid session');
    }
    final u = dto.user, c = dto.company, e = dto.employee;
    final company = CompanyContext(
      id: c['id'] as String,
      name: c['name'] as String,
      code: c['code'] as String,
      timezone: c['timezone'] as String,
      defaultLocale: c['defaultLocale'] as String,
      logoUrl: c['logoUrl'] as String?,
      enabledModules: (c['enabledModules'] as List).cast<String>().toSet(),
    );
    final user = UserAccount(
      id: u['id'] as String,
      displayName: u['displayName'] as String,
      email: u['email'] as String,
      phone: u['phone'] as String?,
      avatarUrl: u['avatarUrl'] as String?,
      companyId: u['companyId'] as String,
      permissions: PermissionSet(
        (u['permissions'] as List)
            .cast<String>()
            .map(permissionFromCode)
            .whereType<AppPermission>(),
      ),
      status: AccountStatus.values.byName(u['status'] as String),
    );
    if (user.id.isEmpty || company.id.isEmpty || user.companyId != company.id) {
      throw const FormatException('Invalid context');
    }
    final employee = e == null
        ? null
        : EmployeeReference(
            id: e['id'] as String,
            userAccountId: e['userAccountId'] as String,
            companyId: e['companyId'] as String,
          );
    if (employee != null &&
        (employee.userAccountId != user.id ||
            employee.companyId != company.id)) {
      throw const FormatException('Invalid relationship');
    }
    return AuthSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      expiresAt: dto.expiresAt.toUtc(),
      context: AuthContext(
        user: user,
        company: company,
        employeeReference: employee,
        settings: dto.settings,
      ),
    );
  }

  static AuthSessionDto encode(AuthSession session) {
    final ctx = session.context,
        u = ctx.user,
        c = ctx.company,
        e = ctx.employeeReference;
    return AuthSessionDto(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      user: {
        'id': u.id,
        'displayName': u.displayName,
        'email': u.email,
        'phone': u.phone,
        'avatarUrl': u.avatarUrl,
        'companyId': u.companyId,
        'status': u.status.name,
        'permissions': u.permissions.values.map((p) => p.name).toList(),
      },
      company: {
        'id': c.id,
        'name': c.name,
        'code': c.code,
        'timezone': c.timezone,
        'logoUrl': c.logoUrl,
        'defaultLocale': c.defaultLocale,
        'enabledModules': c.enabledModules.toList(),
      },
      employee: e == null
          ? null
          : {
              'id': e.id,
              'userAccountId': e.userAccountId,
              'companyId': e.companyId,
            },
      settings: ctx.settings,
    );
  }

  static AppPermission? permissionFromCode(String code) {
    for (final permission in AppPermission.values) {
      if (permission.name == code) return permission;
    }
    return null; // Unknown grants fail closed, allowing newer server versions.
  }
}
