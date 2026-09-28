import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

class CreateServiceInspection {
  const CreateServiceInspection(this.repository);
  final ServiceInspectionRepository repository;
  Future<Result<ServiceInspection>> call(
    AuthContext context,
    ServiceInspectionDraft draft, {
    String? requestId,
  }) => repository.createInspection(context, draft, requestId: requestId);
}

class UpdateServiceInspection {
  const UpdateServiceInspection(this.repository);
  final ServiceInspectionRepository repository;
  Future<Result<ServiceInspection>> call(
    AuthContext context,
    String id,
    ServiceInspectionDraft draft, {
    String? requestId,
  }) => repository.updateInspection(context, id, draft, requestId: requestId);
}

class CompleteServiceInspection {
  const CompleteServiceInspection(this.repository);
  final ServiceInspectionRepository repository;
  Future<Result<ServiceInspection>> call(
    AuthContext context,
    String id, {
    String? requestId,
  }) => repository.completeInspection(context, id, requestId: requestId);
}

class CancelServiceInspection {
  const CancelServiceInspection(this.repository);
  final ServiceInspectionRepository repository;
  Future<Result<void>> call(
    AuthContext context,
    String id, {
    String? requestId,
  }) => repository.cancelInspection(context, id, requestId: requestId);
}

class GetServiceInspection {
  const GetServiceInspection(this.repository);
  final ServiceInspectionRepository repository;
  Future<Result<ServiceInspectionView?>> call(AuthContext context, String id) =>
      repository.getInspection(context, id);
}

class WatchServiceInspections {
  const WatchServiceInspections(this.repository);
  final ServiceInspectionRepository repository;
  Stream<Result<ServiceInspectionPage>> call(
    AuthContext context, {
    String query = '',
    ServiceInspectionStatus? status,
    String? technicianEmployeeId,
    String? rootCauseId,
    String? priorityId,
    DateTime? visitFrom,
    DateTime? visitTo,
    int page = 0,
    int pageSize = 10,
  }) => repository.watchInspections(
    context,
    query: query,
    status: status,
    technicianEmployeeId: technicianEmployeeId,
    rootCauseId: rootCauseId,
    priorityId: priorityId,
    visitFrom: visitFrom,
    visitTo: visitTo,
    page: page,
    pageSize: pageSize,
  );
}
