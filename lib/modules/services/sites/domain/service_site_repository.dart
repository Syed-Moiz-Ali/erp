import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_site.dart';

abstract interface class ServiceSiteRepository {
  Stream<Result<ServiceSitePage>> watchSites(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    String? customerId,
    int page = 0,
    int pageSize = 10,
  });
  Stream<Result<List<ServiceSite>>> watchSitesForCustomer(
    AuthContext context,
    String customerId,
  );
  Stream<Result<ServiceSite?>> watchSite(AuthContext context, String id);
  Future<Result<ServiceSite?>> getSite(AuthContext context, String id);
  Future<Result<ServiceSite>> saveSite(
    AuthContext context,
    ServiceSiteDraft draft, {
    String? id,
  });
  Future<Result<void>> setActive(AuthContext context, String id, bool active);
  Future<Result<List<ServiceSiteRef>>> searchReferences(
    AuthContext context, {
    String query = '',
    String? customerId,
    int limit = 50,
  });
}
