import 'package:dio/dio.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remote_data_source.dart';
import 'package:modular_erp/platform/access/data/dto/my_permissions_dto.dart';
import 'package:modular_erp/platform/access/domain/effective_access.dart';
import 'package:modular_erp/platform/access/domain/effective_access_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Loads the authoritative backend access for a session.
class RemoteEffectiveAccessRepository implements EffectiveAccessSource {
  RemoteEffectiveAccessRepository(this._dataSource);

  final AccessRemoteDataSource _dataSource;

  @override
  Future<Result<EffectiveAccess>> load(
    AuthContext context, {
    CancelToken? cancelToken,
  }) async {
    final result = await _dataSource.myPermissions(cancelToken: cancelToken);
    switch (result) {
      case Failed<MyPermissionsDto>(:final failure):
        return Failed<EffectiveAccess>(failure);
      case Success<MyPermissionsDto>(:final value):
        if (value.userId.toString() != context.user.id) {
          return const Failed(
            Failure(
              code: 'permissions_user_mismatch',
              kind: FailureKind.invalidData,
            ),
          );
        }
        return Success(BackendAccessPolicy.resolve(value.permissions));
    }
  }
}
