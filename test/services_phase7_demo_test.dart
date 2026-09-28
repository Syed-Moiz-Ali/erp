import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/services/demo/services_demo_seed.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/data/local_service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/inspections/data/local_service_inspection_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/data/local_service_job_assignment_repository.dart';
import 'package:modular_erp/modules/services/material_requests/data/local_service_material_request_repository.dart';
import 'package:modular_erp/modules/services/work_executions/data/local_service_work_execution_repository.dart';
import 'package:modular_erp/modules/services/workflow/data/local_service_workflow_repository.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow.dart';
import 'package:modular_erp/modules/services/workflow/domain/service_workflow_validator.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';

class _EmptyDirectory implements WorkforceDirectory {
  const _EmptyDirectory();
  @override
  Future<WorkforcePersonRef?> getEmployeeReference(
    String id, {
    bool includeInactive = false,
  }) async => null;
  @override
  Future<List<WorkforcePersonRef>> getEmployees(Iterable<String> ids) async =>
      const [];
  @override
  Future<List<WorkforcePersonRef>> searchAssignable({
    String query = '',
    int limit = 50,
  }) async => const [];
  @override
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  }) => Stream.value(const []);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late LocalServiceWorkflowRepository workflow;
  late ServiceWorkflowValidator validator;
  late AuthContext admin;

  const clock = SystemAppClock();

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedEmployees(db);
    final source = DemoAuthSource();
    final context = source.findByScenario(DemoScenario.platformAdmin)!.context;
    admin = context;
    await seedServicesDemoData(db, context, clock);
    await seedServiceEnquiriesDemoData(db, context, clock);
    await seedServiceJobAssignmentDemoData(db, context, clock);
    await seedServiceInspectionDemoData(db, context, clock);
    await seedServiceMaterialRequestDemoData(db, context, clock);
    await seedServiceWorkExecutionDemoData(db, context, clock);

    final numbers = LocalDocumentNumberService(db, clock);
    final activity = LocalActivityRepository(db);
    final attachments = LocalAttachmentRepository(db, clock);
    const directory = _EmptyDirectory();
    const time = FixedOffsetCompanyTimeService();
    workflow = LocalServiceWorkflowRepository(
      db: db,
      enquiries: LocalServiceEnquiryRepository(
        db,
        clock,
        numbers,
        activity,
        attachments,
      ),
      jobAssignments: LocalServiceJobAssignmentRepository(
        db,
        clock,
        numbers,
        activity,
        attachments,
        directory,
        time,
      ),
      inspections: LocalServiceInspectionRepository(
        db,
        clock,
        numbers,
        activity,
        attachments,
        directory,
        time,
      ),
      materialRequests: LocalServiceMaterialRequestRepository(
        db,
        clock,
        numbers,
        activity,
        directory,
        time,
      ),
      workExecutions: LocalServiceWorkExecutionRepository(
        db,
        clock,
        numbers,
        activity,
        attachments,
        directory,
        time,
      ),
      activity: activity,
    );
    validator = ServiceWorkflowValidator(db);
  });
  tearDown(() => db.close());

  Future<ServiceWorkflowChain> chain(String enquiryId) async =>
      (await workflow.loadChain(admin, enquiryId)
              as Success<ServiceWorkflowChain?>)
          .value!;

  test(
    'Example A: enquiry → assignment → inspection → MR → work in progress',
    () async {
      final c = await chain('demo-enq-1');
      expect(c.status, ServiceWorkflowStatus.workInProgress);
      expect(c.nodeFor(ServiceWorkflowStage.materialRequest).hasRecord, isTrue);
      expect(c.nodeFor(ServiceWorkflowStage.workExecution).hasRecord, isTrue);
    },
  );

  test(
    'Example B: completed work execution with no material request',
    () async {
      final c = await chain('demo-enq-5');
      expect(c.status, ServiceWorkflowStatus.workCompleted);
      expect(
        c.nodeFor(ServiceWorkflowStage.materialRequest).hasRecord,
        isFalse,
      );
      expect(c.nodeFor(ServiceWorkflowStage.workExecution).hasRecord, isTrue);
    },
  );

  test('Example C: open enquiry awaiting assignment', () async {
    final c = await chain('demo-enq-2');
    expect(c.status, ServiceWorkflowStatus.awaitingAssignment);
    expect(c.nodeFor(ServiceWorkflowStage.jobAssignment).hasRecord, isFalse);
  });

  test('Example D: scheduled assignment awaiting inspection', () async {
    final c = await chain('demo-enq-4');
    expect(c.status, ServiceWorkflowStatus.scheduled);
    expect(c.nodeFor(ServiceWorkflowStage.jobAssignment).hasRecord, isTrue);
    expect(c.nodeFor(ServiceWorkflowStage.inspection).hasRecord, isFalse);
  });

  test('seeded workflow is internally consistent', () async {
    final issues = await validator.validate(admin.company.id);
    expect(issues, isEmpty);
  });
}
