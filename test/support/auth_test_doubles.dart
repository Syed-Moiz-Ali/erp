import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';

/// Scriptable remote auth datasource. No network is touched.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  Future<Result<LoginResponseDto>> Function(LoginRequestDto request)? onLogin;
  Future<Result<LoginResponseDto>> Function(RefreshRequestDto request)?
  onRefresh;
  Future<Result<void>> Function(LogoutRequestDto request)? onLogout;

  int loginCalls = 0;
  int refreshCalls = 0;
  int logoutCalls = 0;
  LoginRequestDto? lastLogin;
  RefreshRequestDto? lastRefresh;
  LogoutRequestDto? lastLogout;

  @override
  Future<Result<LoginResponseDto>> login(LoginRequestDto request) async {
    loginCalls++;
    lastLogin = request;
    final handler = onLogin;
    if (handler == null) return Success(sampleLoginResponse());
    return handler(request);
  }

  @override
  Future<Result<LoginResponseDto>> refresh(RefreshRequestDto request) async {
    refreshCalls++;
    lastRefresh = request;
    final handler = onRefresh;
    if (handler == null) return Success(sampleLoginResponse());
    return handler(request);
  }

  @override
  Future<Result<void>> logout(LogoutRequestDto request) async {
    logoutCalls++;
    lastLogout = request;
    final handler = onLogout;
    if (handler == null) return const Success(null);
    return handler(request);
  }
}

LoginResponseDto sampleLoginResponse({
  String access = 'access-1',
  String refresh = 'refresh-1',
  DateTime? accessExpiry,
  DateTime? refreshExpiry,
  int userId = 5,
  int orgId = 3,
  int? empId = 7,
  String userType = 'Director',
  String loginId = 'Admin',
}) => LoginResponseDto(
  accessToken: access,
  expiresIn: 3600,
  accessTokenExpiresAtUtc:
      accessExpiry ?? DateTime.now().toUtc().add(const Duration(minutes: 60)),
  refreshToken: refresh,
  refreshTokenExpiresAtUtc:
      refreshExpiry ?? DateTime.now().toUtc().add(const Duration(days: 30)),
  user: AuthUserDto(
    userId: userId,
    loginId: loginId,
    name: 'Admin User',
    userType: userType,
    empId: empId,
    orgId: orgId,
    branchName: 'Head Office',
    timeZone: 'Asia/Dubai',
    transactionAccess: true,
    reportAccess: true,
    branches: const [AuthBranchDto(orgId: 3, branchName: 'Head Office')],
  ),
);
