import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modular_erp/core/security/app_permission.dart';
part 'auth_context.freezed.dart';

enum AppRole { superAdmin, companyAdmin, hr, manager, employee }

enum AccountStatus { active, suspended, inactive }

@freezed
abstract class UserAccount with _$UserAccount {
  const factory UserAccount({
    required String id,
    required String displayName,
    required String email,
    String? phone,
    String? avatarUrl,
    required String companyId,
    required AppRole role,
    required PermissionSet permissions,
    required AccountStatus status,
  }) = _UserAccount;
}

@freezed
abstract class CompanyContext with _$CompanyContext {
  const factory CompanyContext({
    required String id,
    required String name,
    String? logoUrl,
    required String code,
    required String timezone,
    required String defaultLocale,
    required Set<String> enabledModules,
  }) = _CompanyContext;
}

/// A relationship only. Employment records belong to a future employee module.
@freezed
abstract class EmployeeReference with _$EmployeeReference {
  const factory EmployeeReference({
    required String id,
    required String userAccountId,
    required String companyId,
  }) = _EmployeeReference;
}

/// Safe context shared with presentation; deliberately contains no tokens.
@freezed
abstract class AuthContext with _$AuthContext {
  const factory AuthContext({
    required UserAccount user,
    required CompanyContext company,
    EmployeeReference? employeeReference,
    @Default({}) Map<String, String> settings,
  }) = _AuthContext;
}

/// Sensitive repository/data-only session. Never place this in Bloc state.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.context,
  });
  final String accessToken, refreshToken;
  final DateTime expiresAt;
  final AuthContext context;
  @override
  String toString() => 'AuthSession([redacted])';
}
