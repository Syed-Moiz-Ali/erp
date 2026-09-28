import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution.dart';
import 'package:modular_erp/modules/services/work_executions/domain/service_work_execution_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

class CreateServiceWorkExecution {
  const CreateServiceWorkExecution(this.repository);
  final ServiceWorkExecutionRepository repository;
  Future<Result<ServiceWorkExecution>> call(
    AuthContext context,
    ServiceWorkExecutionDraft draft, {
    String? requestId,
  }) => repository.createExecution(context, draft, requestId: requestId);
}

class UpdateServiceWorkExecution {
  const UpdateServiceWorkExecution(this.repository);
  final ServiceWorkExecutionRepository repository;
  Future<Result<ServiceWorkExecution>> call(
    AuthContext context,
    String id,
    ServiceWorkExecutionDraft draft, {
    String? requestId,
  }) => repository.updateExecution(context, id, draft, requestId: requestId);
}

class StartServiceWork {
  const StartServiceWork(this.repository);
  final ServiceWorkExecutionRepository repository;
  Future<Result<ServiceWorkExecution>> call(
    AuthContext context,
    String executionId,
    String lineId, {
    String? requestId,
  }) => repository.startWorkLine(
    context,
    executionId,
    lineId,
    requestId: requestId,
  );
}

class EndServiceWork {
  const EndServiceWork(this.repository);
  final ServiceWorkExecutionRepository repository;
  Future<Result<ServiceWorkExecution>> call(
    AuthContext context,
    String executionId,
    String lineId, {
    String? requestId,
  }) => repository.endWorkLine(
    context,
    executionId,
    lineId,
    requestId: requestId,
  );
}

class CompleteServiceWorkExecution {
  const CompleteServiceWorkExecution(this.repository);
  final ServiceWorkExecutionRepository repository;
  Future<Result<ServiceWorkExecution>> call(
    AuthContext context,
    String id, {
    String? requestId,
  }) => repository.completeExecution(context, id, requestId: requestId);
}

class CancelServiceWorkExecution {
  const CancelServiceWorkExecution(this.repository);
  final ServiceWorkExecutionRepository repository;
  Future<Result<ServiceWorkExecution>> call(
    AuthContext context,
    String id, {
    String? requestId,
  }) => repository.cancelExecution(context, id, requestId: requestId);
}

class WatchServiceWorkExecutions {
  const WatchServiceWorkExecutions(this.repository);
  final ServiceWorkExecutionRepository repository;
  Stream<Result<ServiceWorkExecutionPage>> call(
    AuthContext context, {
    String query = '',
    ServiceWorkExecutionStatus? status,
    String? employeeId,
    String? teamId,
    String? inspectionId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 0,
    int pageSize = 10,
  }) => repository.watchExecutions(
    context,
    query: query,
    status: status,
    employeeId: employeeId,
    teamId: teamId,
    inspectionId: inspectionId,
    dateFrom: dateFrom,
    dateTo: dateTo,
    page: page,
    pageSize: pageSize,
  );
}

class GetServiceWorkExecution {
  const GetServiceWorkExecution(this.repository);
  final ServiceWorkExecutionRepository repository;
  Future<Result<ServiceWorkExecutionView?>> call(
    AuthContext context,
    String id,
  ) => repository.getExecution(context, id);
}
