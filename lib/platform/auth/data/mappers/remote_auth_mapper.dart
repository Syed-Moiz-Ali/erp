import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/backend_session_policy.dart';

/// Anti-corruption boundary between the MassERP wire contract and the app's
/// domain session models.
///
/// Backend integer identifiers are carried as their decimal string form so they
/// remain **stable across restarts** and are never parsed as UUIDs or replaced
/// by random local identities. No password is ever retained.
abstract final class RemoteAuthMapper {
  const RemoteAuthMapper._();

  static AuthSession fromLogin(LoginResponseDto dto) {
    final AuthUserDto u = dto.user;
    final companyId = u.orgId.toString();
    final userId = u.userId.toString();

    final company = CompanyContext(
      id: companyId,
      name: u.branchName ?? 'Branch $companyId',
      code: 'ORG-$companyId',
      timezone: u.timeZone ?? '',
      defaultLocale: BackendSessionPolicy.defaultLocale,
      enabledModules: BackendSessionPolicy.enabledModules,
    );
    final user = UserAccount(
      id: userId,
      displayName: u.name,
      loginId: u.loginId,
      // The MassERP login contract does not expose an email address. Keep it
      // absent rather than silently storing the login id in an email field.
      email: null,
      phone: null,
      avatarUrl: null,
      companyId: companyId,
      permissions: BackendSessionPolicy.permissions,
      status: AccountStatus.active,
    );
    final employeeReference = u.empId == null
        ? null
        : EmployeeReference(
            id: u.empId!.toString(),
            userAccountId: userId,
            companyId: companyId,
          );
    return AuthSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      expiresAt: dto.accessTokenExpiresAtUtc.toUtc(),
      refreshTokenExpiresAt: dto.refreshTokenExpiresAtUtc.toUtc(),
      tokenType: dto.tokenType,
      context: AuthContext(
        user: user,
        company: company,
        employeeReference: employeeReference,
        branches: [
          for (final branch in u.branches)
            CompanyBranch(id: branch.orgId.toString(), name: branch.branchName),
        ],
        settings: {
          'userType': u.userType,
          if (u.branchName != null) 'branchName': u.branchName!,
        },
      ),
    );
  }
}
