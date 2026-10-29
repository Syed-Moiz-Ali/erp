import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';

/// Typed remote authentication boundary. Implementations submit documented
/// requests and decode the `data` payload; transport failures are already
/// mapped to safe [Failure]s by the shared API client.
abstract interface class AuthRemoteDataSource {
  Future<Result<LoginResponseDto>> login(LoginRequestDto request);
  Future<Result<LoginResponseDto>> refresh(RefreshRequestDto request);
  Future<Result<void>> logout(LogoutRequestDto request);
}
