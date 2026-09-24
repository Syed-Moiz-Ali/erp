import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_customer.dart';

abstract interface class ServiceCustomerRepository {
  Stream<Result<ServiceCustomerPage>> watchCustomers(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  });
  Stream<Result<ServiceCustomer?>> watchCustomer(
    AuthContext context,
    String id,
  );
  Future<Result<ServiceCustomer?>> getCustomer(AuthContext context, String id);
  Future<Result<ServiceCustomer>> saveCustomer(
    AuthContext context,
    ServiceCustomerDraft draft, {
    String? id,
  });
  Future<Result<void>> setActive(AuthContext context, String id, bool active);
  Future<Result<List<ServiceCustomerRef>>> searchReferences(
    AuthContext context, {
    String query = '',
    int limit = 50,
  });

  /// Returns true when another active customer already uses [mobile] or [email].
  Future<Result<bool>> hasDuplicate(
    AuthContext context, {
    required String mobile,
    String? email,
    String? excludingId,
  });
}
