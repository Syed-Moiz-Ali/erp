import '../../core/models/configuration_record.dart';
import '../../core/errors/result.dart';
import '../../features/auth/domain/entities/auth_context.dart';

abstract interface class ConfigurationRepository<
  T extends ConfigurationRecord,
  D
> {
  Stream<Result<ConfigurationPageData<T>>> watchList(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  });
  Stream<Result<ConfigurationItem<T>?>> watchDetails(
    AuthContext context,
    String id,
  );
  Future<Result<T?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  });
  Future<Result<T>> save(AuthContext context, D draft, {String? id});
  Future<Result<void>> setActive(AuthContext context, String id, bool active);
  Future<Result<int>> assignedEmployeeCount(AuthContext context, String id);
}
