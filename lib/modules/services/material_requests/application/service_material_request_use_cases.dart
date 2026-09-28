import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

class CreateServiceMaterialRequest {
  const CreateServiceMaterialRequest(this.repository);
  final ServiceMaterialRequestRepository repository;
  Future<Result<ServiceMaterialRequest>> call(
    AuthContext context,
    ServiceMaterialRequestDraft draft, {
    String? requestId,
  }) => repository.createRequest(context, draft, requestId: requestId);
}

class UpdateServiceMaterialRequest {
  const UpdateServiceMaterialRequest(this.repository);
  final ServiceMaterialRequestRepository repository;
  Future<Result<ServiceMaterialRequest>> call(
    AuthContext context,
    String id,
    ServiceMaterialRequestDraft draft, {
    String? requestId,
  }) => repository.updateRequest(context, id, draft, requestId: requestId);
}

class CancelServiceMaterialRequest {
  const CancelServiceMaterialRequest(this.repository);
  final ServiceMaterialRequestRepository repository;
  Future<Result<void>> call(
    AuthContext context,
    String id, {
    String? requestId,
  }) => repository.cancelRequest(context, id, requestId: requestId);
}

class GetServiceMaterialRequest {
  const GetServiceMaterialRequest(this.repository);
  final ServiceMaterialRequestRepository repository;
  Future<Result<ServiceMaterialRequestView?>> call(
    AuthContext context,
    String id,
  ) => repository.getRequest(context, id);
}

class WatchServiceMaterialRequests {
  const WatchServiceMaterialRequests(this.repository);
  final ServiceMaterialRequestRepository repository;
  Stream<Result<ServiceMaterialRequestPage>> call(
    AuthContext context, {
    String query = '',
    ServiceMaterialRequestStatus? status,
    String? purposeId,
    String? inspectionId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 0,
    int pageSize = 10,
  }) => repository.watchRequests(
    context,
    query: query,
    status: status,
    purposeId: purposeId,
    inspectionId: inspectionId,
    dateFrom: dateFrom,
    dateTo: dateTo,
    page: page,
    pageSize: pageSize,
  );
}
