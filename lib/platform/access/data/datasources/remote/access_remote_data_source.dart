import 'package:dio/dio.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/dto/my_permissions_dto.dart';

abstract interface class AccessRemoteDataSource {
  Future<Result<MyPermissionsDto>> myPermissions({CancelToken? cancelToken});
}
