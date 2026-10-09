import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_remote_dtos.freezed.dart';
part 'auth_remote_dtos.g.dart';

/// Wire DTOs for the MassERP authentication contract. These are transport-only
/// models and must never be handed to presentation; [RemoteAuthMapper] converts
/// them into domain `AuthSession`/`AuthContext` values.

@freezed
abstract class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String loginId,
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}

@freezed
abstract class RefreshRequestDto with _$RefreshRequestDto {
  const factory RefreshRequestDto({required String refreshToken}) =
      _RefreshRequestDto;

  factory RefreshRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestDtoFromJson(json);
}

@freezed
abstract class LogoutRequestDto with _$LogoutRequestDto {
  const factory LogoutRequestDto({required String refreshToken}) =
      _LogoutRequestDto;

  factory LogoutRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestDtoFromJson(json);
}

/// A branch the authenticated user can access.
@freezed
abstract class AuthBranchDto with _$AuthBranchDto {
  const factory AuthBranchDto({
    required int orgId,
    required String branchName,
  }) = _AuthBranchDto;

  factory AuthBranchDto.fromJson(Map<String, dynamic> json) =>
      _$AuthBranchDtoFromJson(json);
}

/// Identity block returned by login and refresh.
@freezed
abstract class AuthUserDto with _$AuthUserDto {
  const factory AuthUserDto({
    required int userId,
    required String loginId,
    required String name,
    required String userType,
    int? empId,
    required int orgId,
    String? branchName,
    String? timeZone,
    int? orgCount,
    @Default(false) bool transactionAccess,
    @Default(false) bool reportAccess,
    @Default(<AuthBranchDto>[]) List<AuthBranchDto> branches,
  }) = _AuthUserDto;

  factory AuthUserDto.fromJson(Map<String, dynamic> json) =>
      _$AuthUserDtoFromJson(json);
}

/// The `data` payload of both `/api/auth/login` and `/api/auth/refresh`.
@freezed
abstract class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    @Default('Bearer') String tokenType,
    required String accessToken,
    required int expiresIn,
    required DateTime accessTokenExpiresAtUtc,
    required String refreshToken,
    required DateTime refreshTokenExpiresAtUtc,
    required AuthUserDto user,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
