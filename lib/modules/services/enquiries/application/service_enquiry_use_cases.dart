import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Services Phase 2 application use cases.
///
/// Thin orchestrators over [ServiceEnquiryRepository]: they keep transaction
/// rules out of widgets and give callers a stable, testable entry point. The
/// repository owns authorization, reference validation, sequence allocation,
/// activity and outbox inside one database transaction.
class CreateServiceEnquiry {
  const CreateServiceEnquiry(this.repository);
  final ServiceEnquiryRepository repository;

  Future<Result<ServiceEnquiry>> call(
    AuthContext context,
    ServiceEnquiryDraft draft, {
    String? requestId,
  }) => repository.createEnquiry(context, draft, requestId: requestId);
}

class UpdateServiceEnquiry {
  const UpdateServiceEnquiry(this.repository);
  final ServiceEnquiryRepository repository;

  Future<Result<ServiceEnquiry>> call(
    AuthContext context,
    String id,
    ServiceEnquiryDraft draft, {
    String? requestId,
  }) => repository.updateEnquiry(context, id, draft, requestId: requestId);
}

class CancelServiceEnquiry {
  const CancelServiceEnquiry(this.repository);
  final ServiceEnquiryRepository repository;

  Future<Result<void>> call(
    AuthContext context,
    String id, {
    String? requestId,
    String? reason,
  }) => repository.cancelEnquiry(
    context,
    id,
    requestId: requestId,
    reason: reason,
  );
}

class GetServiceEnquiry {
  const GetServiceEnquiry(this.repository);
  final ServiceEnquiryRepository repository;

  Future<Result<ServiceEnquiryView?>> call(AuthContext context, String id) =>
      repository.getEnquiry(context, id);
}

class WatchServiceEnquiries {
  const WatchServiceEnquiries(this.repository);
  final ServiceEnquiryRepository repository;

  Stream<Result<ServiceEnquiryPage>> call(
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
  }) => repository.watchEnquiries(
    context,
    query: query,
    status: status,
    serviceTypeId: serviceTypeId,
    complaintTypeId: complaintTypeId,
    priorityId: priorityId,
    ticketTypeId: ticketTypeId,
    createdFrom: createdFrom,
    createdTo: createdTo,
    page: page,
    pageSize: pageSize,
  );
}
