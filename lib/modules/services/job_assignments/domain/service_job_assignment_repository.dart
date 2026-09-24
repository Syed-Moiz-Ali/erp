import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_job_assignment.dart';

/// Service Job Assignment persistence contract.
///
/// Reads require `services.jobAssignments.view` **and** a record scope
/// (ASSIGNED/TEAM/ALL); mutations require the matching action permission. The
/// restricted enquiry reference lookup is authorized by Job Assignment
/// Create/Edit, never by the full Enquiry directory capability.
abstract interface class ServiceJobAssignmentRepository {
  Stream<Result<ServiceJobAssignmentPage>> watchAssignments(
    AuthContext context, {
    String query = '',
    ServiceJobAssignmentStatus? status,
    String? priorityId,
    String? teamId,
    String? employeeId,
    DateTime? visitFrom,
    DateTime? visitTo,
    int page = 0,
    int pageSize = 10,
  });

  Stream<Result<ServiceJobAssignmentView?>> watchAssignment(
    AuthContext context,
    String id,
  );

  Future<Result<ServiceJobAssignmentView?>> getAssignment(
    AuthContext context,
    String id,
  );

  /// Idempotent create: reusing [requestId] returns the existing assignment and
  /// does not duplicate lines or repeat the Enquiry transition.
  Future<Result<ServiceJobAssignment>> createAssignment(
    AuthContext context,
    ServiceJobAssignmentDraft draft, {
    String? requestId,
  });

  Future<Result<ServiceJobAssignment>> updateAssignment(
    AuthContext context,
    String id,
    ServiceJobAssignmentDraft draft, {
    String? requestId,
  });

  Future<Result<void>> cancelAssignment(
    AuthContext context,
    String id, {
    String? requestId,
    String? reason,
  });

  /// Restricted eligible-Enquiry reference search for the assignment selector.
  Future<Result<List<ServiceAssignableEnquiryRef>>> searchAssignableEnquiries(
    AuthContext context, {
    String query = '',
    int limit = 30,
  });

  /// Restricted source-Enquiry context (customer/site snapshot, classification,
  /// material received and issue lines) for the assignment form.
  Future<Result<ServiceAssignableEnquiryContext?>> getAssignableEnquiryContext(
    AuthContext context,
    String enquiryId,
  );

  /// The active assignment for an enquiry (for the Enquiry detail integration).
  Future<Result<ServiceJobAssignmentRef?>> getAssignmentForEnquiry(
    AuthContext context,
    String enquiryId,
  );

  Stream<Result<ServiceJobAssignmentRef?>> watchAssignmentForEnquiry(
    AuthContext context,
    String enquiryId,
  );

  Future<Result<ServiceJobAssignmentSummary>> summary(AuthContext context);

  Stream<Result<List<ServiceJobAssignmentListItem>>> watchUpcomingAssignments(
    AuthContext context, {
    int limit = 5,
  });
}
