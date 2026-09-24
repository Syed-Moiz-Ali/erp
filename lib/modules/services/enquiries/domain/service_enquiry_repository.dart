import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_enquiry.dart';

/// Service Enquiry persistence contract.
///
/// Read methods require `services.enquiries.view`; mutations require the matching
/// action permission. The restricted Customer/Site reference lookups are
/// authorized by Enquiry Create/Edit capability, **not** by the full Customer or
/// Site directory View capability, so an Enquiry operator never gains directory
/// access indirectly.
abstract interface class ServiceEnquiryRepository {
  Stream<Result<ServiceEnquiryPage>> watchEnquiries(
    AuthContext context, {
    String query = '',
    ServiceEnquiryStatus? status,
    String? serviceTypeId,
    String? complaintTypeId,
    String? priorityId,
    String? ticketTypeId,
    DateTime? createdFrom,
    DateTime? createdTo,
    int page = 0,
    int pageSize = 10,
  });

  Stream<Result<ServiceEnquiryView?>> watchEnquiry(
    AuthContext context,
    String id,
  );

  Future<Result<ServiceEnquiryView?>> getEnquiry(
    AuthContext context,
    String id,
  );

  /// Idempotent create: reusing [requestId] returns the existing Enquiry instead
  /// of creating a duplicate.
  Future<Result<ServiceEnquiry>> createEnquiry(
    AuthContext context,
    ServiceEnquiryDraft draft, {
    String? requestId,
  });

  Future<Result<ServiceEnquiry>> updateEnquiry(
    AuthContext context,
    String id,
    ServiceEnquiryDraft draft, {
    String? requestId,
  });

  Future<Result<void>> cancelEnquiry(
    AuthContext context,
    String id, {
    String? requestId,
    String? reason,
  });

  /// Restricted Customer reference search for the Enquiry form (create/edit).
  Future<Result<List<ServiceCustomerRef>>> searchCustomerRefsForEnquiry(
    AuthContext context, {
    String query = '',
    int limit = 30,
  });

  /// Restricted Site reference search limited to the selected Customer (create/edit).
  Future<Result<List<ServiceEnquirySiteRef>>> searchSiteRefsForEnquiry(
    AuthContext context, {
    required String customerId,
    String query = '',
    int limit = 30,
  });

  /// Restricted single-Customer reference (used after in-context creation).
  Future<Result<ServiceCustomerRef?>> getCustomerRefForEnquiry(
    AuthContext context,
    String id,
  );

  /// Restricted single-Site reference (used after in-context creation).
  Future<Result<ServiceEnquirySiteRef?>> getSiteRefForEnquiry(
    AuthContext context,
    String id,
  );

  Future<Result<ServiceEnquirySummary>> summary(AuthContext context);

  Stream<Result<List<ServiceEnquiryListItem>>> watchRecentEnquiries(
    AuthContext context, {
    int limit = 5,
  });

  Stream<Result<List<ServiceEnquiryListItem>>> watchEnquiriesForCustomer(
    AuthContext context,
    String customerId, {
    int limit = 5,
  });

  Stream<Result<List<ServiceEnquiryListItem>>> watchEnquiriesForSite(
    AuthContext context,
    String siteId, {
    int limit = 5,
  });
}
