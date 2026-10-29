import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remote_data_source.dart';
import 'package:modular_erp/platform/access/data/dto/my_permissions_dto.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_effective_access_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

class _FakeAccessDataSource implements AccessRemoteDataSource {
  _FakeAccessDataSource(this.result);
  Result<MyPermissionsDto> result;

  @override
  Future<Result<MyPermissionsDto>> myPermissions({
    CancelToken? cancelToken,
  }) async => result;
}

AuthContext _context({String userId = '8'}) => AuthContext(
  user: UserAccount(
    id: userId,
    displayName: 'Test User',
    email: 'test',
    companyId: '1',
    permissions: PermissionSet(const []),
    status: AccountStatus.active,
  ),
  company: const CompanyContext(
    id: '1',
    name: 'Company',
    code: 'ORG-1',
    timezone: 'Asia/Dubai',
    defaultLocale: 'en',
    enabledModules: <String>{},
  ),
);

void main() {
  test('maps backend keys and derives modules', () async {
    final data = _FakeAccessDataSource(
      const Success(
        MyPermissionsDto(
          userId: 8,
          employeeId: 1,
          permissions: ['hr.employees.view', 'hr.attendance.shifts.view'],
        ),
      ),
    );
    final repository = RemoteEffectiveAccessRepository(data);

    final result = await repository.load(_context());
    expect(result, isA<Success>());
    final access = (result as Success).value;
    expect(access.permissions.contains(AppPermission.employeeViewAll), isTrue);
    expect(access.permissions.contains(AppPermission.shiftView), isTrue);
    expect(access.enabledModules, containsAll(['employees', 'settings']));
  });

  test('fails closed when the backend call fails', () async {
    final data = _FakeAccessDataSource(
      const Failed(
        Failure(code: 'offline', kind: FailureKind.offline, retryable: true),
      ),
    );
    final repository = RemoteEffectiveAccessRepository(data);

    final result = await repository.load(_context());
    expect(result, isA<Failed>());
    expect((result as Failed).failure.kind, FailureKind.offline);
  });

  test('rejects a payload for a different user', () async {
    final data = _FakeAccessDataSource(
      const Success(
        MyPermissionsDto(userId: 99, employeeId: 1, permissions: []),
      ),
    );
    final repository = RemoteEffectiveAccessRepository(data);

    final result = await repository.load(_context(userId: '8'));
    expect(result, isA<Failed>());
    expect((result as Failed).failure.code, 'permissions_user_mismatch');
  });
}
