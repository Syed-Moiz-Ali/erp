import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';

/// MassERP authentication datasource built on the shared Phase 1 [ApiClient].
///
/// Login, refresh and logout are **authentication-free** requests
/// (`requiresAuth: false`), which also disables the refresh/retry interceptor
/// for them — so a refresh call can never recursively trigger another refresh.
class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  DioAuthRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<Result<LoginResponseDto>> login(LoginRequestDto request) =>
      _client.post<LoginResponseDto>(
        ApiEndpoints.auth.login,
        body: request,
        requiresAuth: false,
        fromJson: _decode,
      );

  @override
  Future<Result<LoginResponseDto>> refresh(RefreshRequestDto request) =>
      _client.post<LoginResponseDto>(
        ApiEndpoints.auth.refresh,
        body: request,
        requiresAuth: false,
        fromJson: _decode,
      );

  @override
  Future<Result<void>> logout(LogoutRequestDto request) => _client.requestVoid(
    'POST',
    ApiEndpoints.auth.logout,
    body: request,
    requiresAuth: false,
  );

  static LoginResponseDto _decode(Object? json) =>
      LoginResponseDto.fromJson((json as Map).cast<String, dynamic>());
}
