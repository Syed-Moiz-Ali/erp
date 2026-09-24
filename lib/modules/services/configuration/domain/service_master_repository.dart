import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_master.dart';

abstract interface class ServiceMasterRepository {
  Stream<Result<ServiceMasterPage>> watchList(
    ServiceMasterKind kind,
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  });
  Stream<Result<ServiceMasterRecord?>> watchDetails(
    ServiceMasterKind kind,
    AuthContext context,
    String id,
  );
  Future<Result<ServiceMasterRecord?>> getById(
    ServiceMasterKind kind,
    AuthContext context,
    String id,
  );
  Future<Result<ServiceMasterRecord>> save(
    ServiceMasterKind kind,
    AuthContext context,
    ServiceMasterDraft draft, {
    String? id,
  });
  Future<Result<void>> setActive(
    ServiceMasterKind kind,
    AuthContext context,
    String id,
    bool active,
  );
}
