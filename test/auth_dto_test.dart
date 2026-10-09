import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';

void main() {
  group('login request', () {
    test('serializes exactly loginId and password', () {
      const request = LoginRequestDto(loginId: 'Admin', password: 'secret');
      expect(request.toJson(), {'loginId': 'Admin', 'password': 'secret'});
    });
  });

  group('refresh and logout requests', () {
    test('serialize refreshToken', () {
      expect(const RefreshRequestDto(refreshToken: 'r').toJson(), {
        'refreshToken': 'r',
      });
      expect(const LogoutRequestDto(refreshToken: 'r').toJson(), {
        'refreshToken': 'r',
      });
    });
  });

  group('login response', () {
    Map<String, dynamic> json({Object? empId = 9}) => {
      'tokenType': 'Bearer',
      'accessToken': 'access',
      'expiresIn': 3600,
      'accessTokenExpiresAtUtc': '2026-10-08T11:48:34.2854478Z',
      'refreshToken': 'refresh',
      'refreshTokenExpiresAtUtc': '2026-11-07T10:48:34.2319364Z',
      'user': {
        'userId': 8,
        'loginId': 'Admin',
        'name': 'Test Employee',
        'userType': 'Director',
        'empId': empId,
        'orgId': 1,
        'branchName': 'Mass Technologies',
        'timeZone': 'Asia/Dubai',
        'orgCount': 9,
        'transactionAccess': true,
        'reportAccess': true,
        'branches': [
          {'orgId': 2, 'branchName': 'Bitlogix'},
          {'orgId': 1, 'branchName': 'Mass Technologies'},
        ],
      },
    };

    test('decodes tokens, integers, dates and nested branches', () {
      final dto = LoginResponseDto.fromJson(json());
      expect(dto.accessToken, 'access');
      expect(dto.refreshToken, 'refresh');
      expect(dto.tokenType, 'Bearer');
      expect(dto.expiresIn, 3600);
      expect(dto.accessTokenExpiresAtUtc.isUtc, isTrue);
      expect(dto.user.userId, 8);
      expect(dto.user.orgId, 1);
      expect(dto.user.empId, 9);
      expect(dto.user.userType, 'Director');
      expect(dto.user.branches, hasLength(2));
      expect(dto.user.branches.first.branchName, 'Bitlogix');
    });

    test('treats a null employee id as absent', () {
      final dto = LoginResponseDto.fromJson(json(empId: null));
      expect(dto.user.empId, isNull);
    });

    test('round-trips through JSON', () {
      final dto = LoginResponseDto.fromJson(json());
      final decoded = LoginResponseDto.fromJson(
        jsonDecode(jsonEncode(dto)) as Map<String, dynamic>,
      );
      expect(decoded, dto);
    });

    test('throws on a missing required token field', () {
      final broken = json()..remove('accessToken');
      expect(() => LoginResponseDto.fromJson(broken), throwsA(anything));
    });

    test('rejects an unexpected structure', () {
      expect(
        () => LoginResponseDto.fromJson({'accessToken': 'x'}),
        throwsA(anything),
      );
    });
  });
}
