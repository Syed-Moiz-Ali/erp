import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/api_endpoints.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remote_data_source.dart';
import 'package:modular_erp/platform/access/data/dto/my_permissions_dto.dart';

class DioAccessRemoteDataSource implements AccessRemoteDataSource {
  DioAccessRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<Result<MyPermissionsDto>> myPermissions({CancelToken? cancelToken}) =>
      _client.get<MyPermissionsDto>(
        ApiEndpoints.me.permissions,
        cancelToken: cancelToken,
        skipPermissionRefresh: true,
        fromJson: (json) =>
            MyPermissionsDto.fromJson((json as Map).cast<String, dynamic>()),
      );
}
