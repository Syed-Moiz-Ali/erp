import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Phase 3 application use cases. Thin orchestrators over
/// [ServiceJobAssignmentRepository]; transaction rules live in the repository.
class CreateServiceJobAssignment {
  const CreateServiceJobAssignment(this.repository);
  final ServiceJobAssignmentRepository repository;

  Future<Result<ServiceJobAssignment>> call(
    AuthContext context,
    ServiceJobAssignmentDraft draft, {
    String? requestId,
  }) => repository.createAssignment(context, draft, requestId: requestId);
}

class UpdateServiceJobAssignment {
  const UpdateServiceJobAssignment(this.repository);
  final ServiceJobAssignmentRepository repository;

  Future<Result<ServiceJobAssignment>> call(
    AuthContext context,
    String id,
    ServiceJobAssignmentDraft draft, {
    String? requestId,
  }) => repository.updateAssignment(context, id, draft, requestId: requestId);
}

class CancelServiceJobAssignment {
  const CancelServiceJobAssignment(this.repository);
  final ServiceJobAssignmentRepository repository;

  Future<Result<void>> call(
    AuthContext context,
    String id, {
    String? requestId,
    String? reason,
  }) => repository.cancelAssignment(
    context,
    id,
    requestId: requestId,
    reason: reason,
  );
}

class GetServiceJobAssignment {
  const GetServiceJobAssignment(this.repository);
  final ServiceJobAssignmentRepository repository;

  Future<Result<ServiceJobAssignmentView?>> call(
    AuthContext context,
    String id,
  ) => repository.getAssignment(context, id);
}

class WatchServiceJobAssignments {
  const WatchServiceJobAssignments(this.repository);
  final ServiceJobAssignmentRepository repository;

  Stream<Result<ServiceJobAssignmentPage>> call(
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
  }) => repository.watchAssignments(
    context,
    query: query,
    status: status,
    priorityId: priorityId,
    teamId: teamId,
    employeeId: employeeId,
    visitFrom: visitFrom,
    visitTo: visitTo,
    page: page,
    pageSize: pageSize,
  );
}
