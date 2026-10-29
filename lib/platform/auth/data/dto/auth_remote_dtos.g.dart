// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_remote_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginRequestDto _$LoginRequestDtoFromJson(Map<String, dynamic> json) =>
    _LoginRequestDto(
      loginId: json['loginId'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestDtoToJson(_LoginRequestDto instance) =>
    <String, dynamic>{
      'loginId': instance.loginId,
      'password': instance.password,
    };

_RefreshRequestDto _$RefreshRequestDtoFromJson(Map<String, dynamic> json) =>
    _RefreshRequestDto(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshRequestDtoToJson(_RefreshRequestDto instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

_LogoutRequestDto _$LogoutRequestDtoFromJson(Map<String, dynamic> json) =>
    _LogoutRequestDto(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$LogoutRequestDtoToJson(_LogoutRequestDto instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

_AuthBranchDto _$AuthBranchDtoFromJson(Map<String, dynamic> json) =>
    _AuthBranchDto(
      orgId: (json['orgId'] as num).toInt(),
      branchName: json['branchName'] as String,
    );

Map<String, dynamic> _$AuthBranchDtoToJson(_AuthBranchDto instance) =>
    <String, dynamic>{
      'orgId': instance.orgId,
      'branchName': instance.branchName,
    };

_AuthUserDto _$AuthUserDtoFromJson(Map<String, dynamic> json) => _AuthUserDto(
  userId: (json['userId'] as num).toInt(),
  loginId: json['loginId'] as String,
  name: json['name'] as String,
  userType: json['userType'] as String,
  empId: (json['empId'] as num?)?.toInt(),
  orgId: (json['orgId'] as num).toInt(),
  branchName: json['branchName'] as String?,
  timeZone: json['timeZone'] as String?,
  orgCount: (json['orgCount'] as num?)?.toInt(),
  transactionAccess: json['transactionAccess'] as bool? ?? false,
  reportAccess: json['reportAccess'] as bool? ?? false,
  branches:
      (json['branches'] as List<dynamic>?)
          ?.map((e) => AuthBranchDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AuthBranchDto>[],
);

Map<String, dynamic> _$AuthUserDtoToJson(_AuthUserDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'loginId': instance.loginId,
      'name': instance.name,
      'userType': instance.userType,
      'empId': instance.empId,
      'orgId': instance.orgId,
      'branchName': instance.branchName,
      'timeZone': instance.timeZone,
      'orgCount': instance.orgCount,
      'transactionAccess': instance.transactionAccess,
      'reportAccess': instance.reportAccess,
      'branches': instance.branches,
    };

_LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    _LoginResponseDto(
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      accessToken: json['accessToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      accessTokenExpiresAtUtc: DateTime.parse(
        json['accessTokenExpiresAtUtc'] as String,
      ),
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAtUtc: DateTime.parse(
        json['refreshTokenExpiresAtUtc'] as String,
      ),
      user: AuthUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseDtoToJson(
  _LoginResponseDto instance,
) => <String, dynamic>{
  'tokenType': instance.tokenType,
  'accessToken': instance.accessToken,
  'expiresIn': instance.expiresIn,
  'accessTokenExpiresAtUtc': instance.accessTokenExpiresAtUtc.toIso8601String(),
  'refreshToken': instance.refreshToken,
  'refreshTokenExpiresAtUtc': instance.refreshTokenExpiresAtUtc
      .toIso8601String(),
  'user': instance.user,
};
