import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/configuration/data/local_service_master_repository.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/modules/services/inspections/data/local_service_inspection_repository.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/modules/services/material_requests/application/service_material_request_print.dart';
import 'package:modular_erp/modules/services/material_requests/data/local_service_material_request_repository.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';
import 'package:modular_erp/modules/services/material_requests/presentation/bloc/service_material_request_blocs.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';

class _FixedClock implements AppClock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

class _FakeDirectory implements WorkforceDirectory {
  _FakeDirectory(this.refs);
  final Map<String, WorkforcePersonRef> refs;
  @override
  Future<WorkforcePersonRef?> getEmployeeReference(
    String id, {
    bool includeInactive = false,
  }) async {
    final ref = refs[id];
    if (ref == null) return null;
    if (!includeInactive && !ref.isActive) return null;
    return ref;
  }

  @override
  Future<List<WorkforcePersonRef>> getEmployees(Iterable<String> ids) async => [
    for (final id in ids)
      if (refs[id] != null) refs[id]!,
  ];
  @override
  Future<List<WorkforcePersonRef>> searchAssignable({
    String query = '',
    int limit = 50,
  }) async => refs.values.where((r) => r.isActive).toList();
  @override
  Stream<List<AssignableEmployeeSummary>> watchAssignableEmployees({
    String query = '',
  }) => Stream.value(const []);
}

AuthContext context({
  required Set<AppPermission> permissions,
  String companyId = 'c1',
  String? employeeId,
}) => AuthContext(
  user: UserAccount(
    id: 'u1',
    displayName: 'Operator',
    email: 'op@erp.demo',
    companyId: companyId,
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: companyId,
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: const {'services'},
  ),
  employeeReference: employeeId == null
      ? null
      : EmployeeReference(
          id: employeeId,
          userAccountId: 'u-$employeeId',
          companyId: companyId,
        ),
);

const _all = {
  AppPermission.serviceInspectionViewAll,
  AppPermission.serviceInspectionViewAssigned,
  AppPermission.serviceInspectionViewTeam,
  AppPermission.serviceInspectionCreate,
  AppPermission.serviceInspectionEdit,
  AppPermission.serviceInspectionComplete,
  AppPermission.serviceInspectionCancel,
  AppPermission.serviceMaterialRequestViewAll,
  AppPermission.serviceMaterialRequestViewAssigned,
  AppPermission.serviceMaterialRequestViewTeam,
  AppPermission.serviceMaterialRequestCreate,
  AppPermission.serviceMaterialRequestEdit,
  AppPermission.serviceMaterialRequestCancel,
  AppPermission.serviceMaterialRequestPrint,
  AppPermission.serviceMaterialRequestPurposeView,
  AppPermission.serviceMaterialRequestPurposeManage,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late LocalServiceMaterialRequestRepository repo;
  late LocalServiceInspectionRepository inspections;
  late LocalServiceMasterRepository masters;
  final now = DateTime.utc(2026, 2, 10, 9);
  final clock = _FixedClock(DateTime.utc(2026, 2, 10, 9));

  Future<void> master(
    TableInfo table,
    String id,
    String code,
    String name, {
    String status = 'active',
  }) async {
    final columns = await db
        .customSelect('PRAGMA table_info(${table.actualTableName})')
        .get();
    final names = columns.map((r) => r.read<String>('name')).toSet();
    final row = {
      'id': id,
      'company_id': 'c1',
      'code': code,
      'name': name,
      'status': status,
      'sort_order': 0,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'synced',
    };
    final filtered = {
      for (final e in row.entries)
        if (names.contains(e.key)) e.key: e.value,
    };
    await db.customInsert(
      'INSERT OR IGNORE INTO ${table.actualTableName} '
      '(${filtered.keys.join(',')}) VALUES (${filtered.keys.map((_) => '?').join(',')})',
      variables: [for (final v in filtered.values) Variable(v)],
    );
  }

  Future<void> enquiry(
    String id,
    String number,
    MaterialReceived received,
  ) => db
      .into(db.serviceEnquiries)
      .insert(
        ServiceEnquiriesCompanion.insert(
          id: id,
          companyId: 'c1',
          enquiryNumber: number,
          customerId: 'cus1',
          siteId: 'site1',
          serviceTypeId: 'st1',
          complaintTypeId: 'ct1',
          priorityId: 'pr1',
          ticketTypeId: 'tt1',
          description: '',
          status: 'assigned',
          materialReceived: Value(received.wire),
          partySnapshot:
              '{"customerName":"ABC Properties","customerMobile":"+971500000001","siteName":"Tower 1","buildingName":"Tower","unitNumber":"101"}',
          searchText: const Value('abc'),
          createdAt: now,
          updatedAt: now,
          createdByUserId: 'u1',
          updatedByUserId: 'u1',
          syncStatus: 'synced',
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> assignment(String id, String number, String enquiryId) async {
    await db
        .into(db.serviceJobAssignments)
        .insert(
          ServiceJobAssignmentsCompanion.insert(
            id: id,
            companyId: 'c1',
            assignmentNumber: number,
            assignmentDate: now,
            sourceEnquiryId: enquiryId,
            scheduledVisitDate: DateTime.utc(2026, 2, 12),
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await db
        .into(db.serviceJobAssignmentLines)
        .insert(
          ServiceJobAssignmentLinesCompanion.insert(
            id: '$id-l1',
            companyId: 'c1',
            assignmentId: id,
            lineNumber: 1,
            work: 'Inspect',
            assignedEmployeeId: const Value('e1'),
            assignedTeamId: const Value('t1'),
            status: 'pending',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> seed() async {
    await db
        .into(db.serviceCustomers)
        .insert(
          ServiceCustomersCompanion.insert(
            id: 'cus1',
            companyId: 'c1',
            customerCode: 'CUS-1',
            name: 'ABC Properties',
            mobile: '+971500000001',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await db
        .into(db.serviceSites)
        .insert(
          ServiceSitesCompanion.insert(
            id: 'site1',
            companyId: 'c1',
            customerId: 'cus1',
            siteCode: 'SITE-1',
            siteName: 'Tower 1',
            buildingName: const Value('Tower'),
            unitNumber: const Value('101'),
            addressLine1: 'Main Road',
            city: 'Dubai',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await master(db.serviceTypes, 'st1', 'ELEC', 'Electrical');
    await master(db.complaintTypes, 'ct1', 'POWER', 'Power');
    await master(db.servicePriorities, 'pr1', 'HIGH', 'High');
    await master(db.serviceTicketTypes, 'tt1', 'COMPLAINT', 'Complaint');
    await master(db.serviceRootCauses, 'rc1', 'ELECTRICAL', 'Electrical fault');
    await master(db.serviceChargeResponsibilities, 'ch1', 'TENANT', 'Tenant');
    await master(
      db.serviceMaterialRequestPurposes,
      'purpose1',
      'SERVICE_WORK',
      'Service Work',
    );
    await db
        .into(db.serviceTeams)
        .insert(
          ServiceTeamsCompanion.insert(
            id: 't1',
            companyId: 'c1',
            teamCode: 'TEAM-1',
            name: 'Electrical Team',
            leadEmployeeId: const Value('e1'),
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    for (final employeeId in ['e1', 'e2']) {
      await db
          .into(db.serviceTeamMembers)
          .insert(
            ServiceTeamMembersCompanion.insert(
              id: 't1-$employeeId',
              companyId: 'c1',
              teamId: 't1',
              employeeId: employeeId,
              status: 'active',
              createdAt: now,
              createdByUserId: 'u1',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    await enquiry('enq1', 'ENQ-000001', MaterialReceived.yes);
    await enquiry('enq2', 'ENQ-000002', MaterialReceived.no);
    await assignment('ja1', 'JA-000001', 'enq1');
    await assignment('ja2', 'JA-000002', 'enq2');
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final numbers = LocalDocumentNumberService(db, clock);
    final activity = LocalActivityRepository(db);
    final directory = _FakeDirectory({
      'e1': const WorkforcePersonRef(
        id: 'e1',
        name: 'Ahmed Khan',
        employeeCode: 'EMP-1',
      ),
      'e2': const WorkforcePersonRef(
        id: 'e2',
        name: 'Sara',
        employeeCode: 'EMP-2',
      ),
      'e3': const WorkforcePersonRef(
        id: 'e3',
        name: 'Omar',
        employeeCode: 'EMP-3',
      ),
    });
    repo = LocalServiceMaterialRequestRepository(
      db,
      clock,
      numbers,
      activity,
      directory,
      const FixedOffsetCompanyTimeService(),
    );
    inspections = LocalServiceInspectionRepository(
      db,
      clock,
      numbers,
      activity,
      LocalAttachmentRepository(db, clock),
      directory,
      const FixedOffsetCompanyTimeService(),
    );
    masters = LocalServiceMasterRepository(db, clock, activity);
    await seed();
  });
  tearDown(() => db.close());

  ServiceInspectionDraft inspectionDraft({
    required String assignmentId,
    String requirementCode = 'CAP-35UF',
  }) => ServiceInspectionDraft(
    sourceJobAssignmentId: assignmentId,
    visitDate: DateTime.utc(2026, 2, 12),
    visitMinutes: 630,
    technicianEmployeeId: 'e1',
    rootCauseId: 'rc1',
    chargeResponsibilityId: 'ch1',
    checklistItems: [
      ServiceInspectionChecklistItemDraft(
        id: 'ck-$assignmentId',
        workType: 'Inspect AC',
      ),
    ],
    materialRequirements: [
      ServiceInspectionMaterialRequirementDraft(
        id: 'req-$assignmentId',
        code: requirementCode,
        description: requirementCode,
      ),
    ],
  );

  Future<ServiceInspection> completedInspection(String assignmentId) async {
    final ctx = context(permissions: _all);
    final created =
        (await inspections.createInspection(
              ctx,
              inspectionDraft(assignmentId: assignmentId),
            ))
            as Success<ServiceInspection>;
    final completed =
        (await inspections.completeInspection(ctx, created.value.id))
            as Success<ServiceInspection>;
    return completed.value;
  }

  ServiceMaterialRequestDraft requestDraft({
    required String inspectionId,
    String requirementId = 'req-ja1',
    String? purposeId = 'purpose1',
    String jobOrderReference = '',
    List<ServiceMaterialRequestLineDraft>? lines,
  }) => ServiceMaterialRequestDraft(
    sourceInspectionId: inspectionId,
    purposeId: purposeId,
    jobOrderReference: jobOrderReference,
    lines:
        lines ??
        [
          ServiceMaterialRequestLineDraft(
            id: 'line1',
            sourceInspectionMaterialRequirementId: requirementId,
            code: 'CAP-35UF',
            description: '35uF capacitor',
            quantity: '1',
          ),
        ],
  );

  test('material received is inherited read-only from the enquiry', () async {
    final yes = await completedInspection('ja1');
    final no = await completedInspection('ja2');
    final ctx = context(permissions: _all);
    final yesView =
        (await inspections.getInspection(ctx, yes.id))
            as Success<ServiceInspectionView?>;
    final noView =
        (await inspections.getInspection(ctx, no.id))
            as Success<ServiceInspectionView?>;
    expect(yesView.value!.materialReceived, MaterialReceived.yes);
    expect(noView.value!.materialReceived, MaterialReceived.no);

    final source = await repo.getSourceContext(ctx, yes.id);
    expect(
      (source as Success<ServiceMaterialRequestSourceContext?>)
          .value!
          .materialReceived,
      MaterialReceived.yes,
    );

    // No independently editable material_received column exists.
    final columns = await db
        .customSelect('PRAGMA table_info(service_material_requests)')
        .get();
    expect(
      columns.any((r) => r.read<String>('name') == 'material_received'),
      isFalse,
    );
  });

  test(
    'material received YES does not block and NO does not auto-generate',
    () async {
      final yes = await completedInspection('ja1');
      final no = await completedInspection('ja2');
      final ctx = context(permissions: _all);
      final yesRequest = await repo.createRequest(
        ctx,
        requestDraft(inspectionId: yes.id),
      );
      expect(yesRequest, isA<Success<ServiceMaterialRequest>>());
      // A NO enquiry produces no automatic request.
      expect(
        await repo.getRequestsForInspection(ctx, no.id),
        isA<Success<List<ServiceMaterialRequestRef>>>(),
      );
      final refs =
          (await repo.getRequestsForInspection(ctx, no.id)
                  as Success<List<ServiceMaterialRequestRef>>)
              .value;
      expect(refs, isEmpty);
      final created = await repo.createRequest(
        ctx,
        requestDraft(inspectionId: no.id, requirementId: 'req-ja2'),
      );
      expect(created, isA<Success<ServiceMaterialRequest>>());
    },
  );

  test(
    'WAITING requirements prefill draft lines through the form cubit',
    () async {
      final inspection = await completedInspection('ja1');
      final cubit = ServiceMaterialRequestFormCubit(
        repo,
        masters,
        context(permissions: _all),
        null,
        initialInspectionId: inspection.id,
      );
      addTearDown(cubit.close);
      await cubit.init();
      expect(cubit.state.draft.lines, hasLength(1));
      expect(
        cubit.state.draft.lines.single.sourceInspectionMaterialRequirementId,
        'req-ja1',
      );
      expect(cubit.state.draft.lines.single.code, 'CAP-35UF');
    },
  );

  test(
    'generated lines retain source lineage; manual lines are null',
    () async {
      final inspection = await completedInspection('ja1');
      final ctx = context(permissions: _all);
      final created =
          (await repo.createRequest(
                ctx,
                requestDraft(
                  inspectionId: inspection.id,
                  lines: [
                    ServiceMaterialRequestLineDraft(
                      id: 'line1',
                      sourceInspectionMaterialRequirementId: 'req-ja1',
                      code: 'CAP-35UF',
                      description: '35uF capacitor',
                      quantity: '1',
                    ),
                    ServiceMaterialRequestLineDraft(
                      id: 'line2',
                      code: 'WIRE-2.5',
                      description: '2.5mm electrical wire',
                      quantity: '3',
                    ),
                  ],
                ),
              ))
              as Success<ServiceMaterialRequest>;
      final lines = created.value.lines;
      expect(
        lines
            .firstWhere((l) => l.id == 'line1')
            .sourceInspectionMaterialRequirementId,
        'req-ja1',
      );
      expect(
        lines
            .firstWhere((l) => l.id == 'line2')
            .sourceInspectionMaterialRequirementId,
        isNull,
      );
      expect(created.value.totalQuantity, 4);
    },
  );

  test('total quantity always sums the current lines', () async {
    final inspection = await completedInspection('ja1');
    final ctx = context(permissions: _all);
    final created =
        (await repo.createRequest(
              ctx,
              requestDraft(
                inspectionId: inspection.id,
                lines: [
                  ServiceMaterialRequestLineDraft(
                    id: 'line1',
                    sourceInspectionMaterialRequirementId: 'req-ja1',
                    code: 'CAP-35UF',
                    description: '35uF capacitor',
                    quantity: '1',
                  ),
                  ServiceMaterialRequestLineDraft(
                    id: 'line2',
                    code: 'WIRE-2.5',
                    description: '2.5mm electrical wire',
                    quantity: '3',
                  ),
                ],
              ),
            ))
            as Success<ServiceMaterialRequest>;
    expect(created.value.totalQuantity, 4);
    final updated =
        (await repo.updateRequest(
              ctx,
              created.value.id,
              requestDraft(
                inspectionId: inspection.id,
                lines: [
                  ServiceMaterialRequestLineDraft(
                    id: 'line1',
                    sourceInspectionMaterialRequirementId: 'req-ja1',
                    code: 'CAP-35UF',
                    description: '35uF capacitor',
                    quantity: '2.5',
                  ),
                ],
              ),
            ))
            as Success<ServiceMaterialRequest>;
    expect(updated.value.totalQuantity, 2.5);
  });

  test('one requirement cannot be in two active requests', () async {
    final inspection = await completedInspection('ja1');
    final ctx = context(permissions: _all);
    final first = await repo.createRequest(
      ctx,
      requestDraft(inspectionId: inspection.id),
    );
    expect(first, isA<Success<ServiceMaterialRequest>>());
    final requirement = await (db.select(
      db.serviceInspectionMaterialRequirements,
    )..where((t) => t.id.equals('req-ja1'))).getSingle();
    expect(requirement.status, 'requested');

    final second = await repo.createRequest(
      ctx,
      requestDraft(
        inspectionId: inspection.id,
        lines: [
          ServiceMaterialRequestLineDraft(
            id: 'other',
            sourceInspectionMaterialRequirementId: 'req-ja1',
            code: 'CAP-35UF',
            description: '35uF capacitor',
            quantity: '1',
          ),
        ],
      ),
    );
    expect(
      (second as Failed<ServiceMaterialRequest>).failure.code,
      'servicesMaterialRequestRequirementLinked',
    );

    // Cancelling the first request releases the requirement.
    final firstId = (first as Success<ServiceMaterialRequest>).value.id;
    await repo.cancelRequest(ctx, firstId);
    final reverted = await (db.select(
      db.serviceInspectionMaterialRequirements,
    )..where((t) => t.id.equals('req-ja1'))).getSingle();
    expect(reverted.status, 'waiting');
    final third = await repo.createRequest(
      ctx,
      requestDraft(inspectionId: inspection.id),
    );
    expect(third, isA<Success<ServiceMaterialRequest>>());
  });

  test('multiple requests per inspection are supported', () async {
    final inspection = await completedInspection('ja1');
    final ctx = context(permissions: _all);
    await repo.createRequest(ctx, requestDraft(inspectionId: inspection.id));
    final manual = await repo.createRequest(
      ctx,
      requestDraft(
        inspectionId: inspection.id,
        lines: [
          ServiceMaterialRequestLineDraft(
            id: 'manual',
            code: 'WIRE-2.5',
            description: '2.5mm electrical wire',
            quantity: '3',
          ),
        ],
      ),
    );
    expect(manual, isA<Success<ServiceMaterialRequest>>());
    final refs =
        (await repo.getRequestsForInspection(ctx, inspection.id)
                as Success<List<ServiceMaterialRequestRef>>)
            .value;
    expect(refs, hasLength(2));
  });

  test(
    'cancellation is historical and reconciles REQUESTED to WAITING',
    () async {
      final inspection = await completedInspection('ja1');
      final ctx = context(permissions: _all);
      final created =
          (await repo.createRequest(
                    ctx,
                    requestDraft(inspectionId: inspection.id),
                  )
                  as Success<ServiceMaterialRequest>)
              .value;
      expect(await repo.cancelRequest(ctx, created.id), isA<Success<void>>());
      final row = await (db.select(
        db.serviceMaterialRequests,
      )..where((t) => t.id.equals(created.id))).getSingle();
      expect(row.status, 'cancelled');
      // The transaction is never hard-deleted.
      expect(await db.select(db.serviceMaterialRequests).get(), hasLength(1));
      final second = await repo.cancelRequest(ctx, created.id);
      expect(
        (second as Failed<void>).failure.code,
        'servicesMaterialRequestAlreadyCancelled',
      );
    },
  );

  test('job order reference is preserved without a JobOrder entity', () async {
    final inspection = await completedInspection('ja1');
    final ctx = context(permissions: _all);
    final created =
        (await repo.createRequest(
                  ctx,
                  requestDraft(
                    inspectionId: inspection.id,
                    jobOrderReference: 'JOB-9001',
                  ),
                )
                as Success<ServiceMaterialRequest>)
            .value;
    expect(created.jobOrderReference, 'JOB-9001');
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND lower(name) LIKE '%job_order%'",
        )
        .get();
    expect(tables, isEmpty);
  });

  test(
    'active purpose is selectable and inactive historical value resolves',
    () async {
      final inspection = await completedInspection('ja1');
      final ctx = context(permissions: _all);
      final created =
          (await repo.createRequest(
                    ctx,
                    requestDraft(inspectionId: inspection.id),
                  )
                  as Success<ServiceMaterialRequest>)
              .value;
      final view =
          (await repo.getRequest(ctx, created.id)
                  as Success<ServiceMaterialRequestView?>)
              .value!;
      expect(view.purposeName, 'Service Work');

      // Deactivate the purpose; the historical request still resolves its name.
      await db.customUpdate(
        "UPDATE service_material_request_purposes SET status='inactive' WHERE company_id='c1' AND id='purpose1'",
      );
      final resolved =
          (await repo.getRequest(ctx, created.id)
                  as Success<ServiceMaterialRequestView?>)
              .value!;
      expect(resolved.purposeName, 'Service Work');

      // A new request cannot select the now-inactive purpose.
      final second = await repo.createRequest(
        ctx,
        requestDraft(
          inspectionId: inspection.id,
          lines: [
            ServiceMaterialRequestLineDraft(
              id: 'manual2',
              code: 'WIRE-2.5',
              description: '2.5mm electrical wire',
              quantity: '3',
            ),
          ],
        ),
      );
      expect(
        (second as Failed<ServiceMaterialRequest>).failure.code,
        'servicesMaterialRequestPurposeInvalid',
      );
    },
  );

  test('print document contains the client data', () async {
    final inspection = await completedInspection('ja1');
    final ctx = context(permissions: _all);
    final created =
        (await repo.createRequest(
                  ctx,
                  requestDraft(
                    inspectionId: inspection.id,
                    jobOrderReference: 'JOB-9001',
                  ),
                )
                as Success<ServiceMaterialRequest>)
            .value;
    final view =
        (await repo.getRequest(ctx, created.id)
                as Success<ServiceMaterialRequestView?>)
            .value!;
    final document = buildMaterialRequestPrintDocument(
      view,
      companyName: 'Company',
      l: lookupAppLocalizations(const Locale('en')),
    );
    expect(document.requestNumber, 'MR-000001');
    expect(document.inspectionNumber, 'INS-000001');
    expect(document.purposeName, 'Service Work');
    expect(document.jobOrderReference, 'JOB-9001');
    expect(document.materialReceived, MaterialReceived.yes);
    expect(document.lines.single.code, 'CAP-35UF');
    expect(document.totalQuantity, 1);
  });

  test('assigned, team and all scopes restrict visibility', () async {
    final inspection = await completedInspection('ja1');
    final all = context(permissions: _all);
    final created =
        (await repo.createRequest(
                  all,
                  requestDraft(inspectionId: inspection.id),
                )
                as Success<ServiceMaterialRequest>)
            .value;

    Future<List<String>> ids(AuthContext ctx) async {
      final result = await repo.watchRequests(ctx).first;
      return (result as Success<ServiceMaterialRequestPage>).value.items
          .map((i) => i.id)
          .toList();
    }

    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceMaterialRequestViewAssigned},
          employeeId: 'e1',
        ),
      ),
      contains(created.id),
    );
    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceMaterialRequestViewAssigned},
          employeeId: 'e3',
        ),
      ),
      isEmpty,
    );
    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceMaterialRequestViewTeam},
          employeeId: 'e2',
        ),
      ),
      contains(created.id),
    );
    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceMaterialRequestViewTeam},
          employeeId: 'e3',
        ),
      ),
      isEmpty,
    );
    expect(
      await ids(
        context(permissions: {AppPermission.serviceMaterialRequestViewAll}),
      ),
      contains(created.id),
    );
    expect(
      await ids(
        context(
          permissions: {AppPermission.serviceMaterialRequestViewAll},
          companyId: 'c2',
        ),
      ),
      isEmpty,
    );
  });

  test(
    'create works without full inspection access via the restricted selector',
    () async {
      final inspection = await completedInspection('ja1');
      final restricted = context(
        permissions: {AppPermission.serviceMaterialRequestCreate},
      );
      final eligible =
          (await repo.searchEligibleInspections(restricted)
                  as Success<List<ServiceEligibleInspectionRef>>)
              .value;
      expect(eligible.map((e) => e.id), contains(inspection.id));
      final source = await repo.getSourceContext(restricted, inspection.id);
      expect(source, isA<Success<ServiceMaterialRequestSourceContext?>>());
      final created = await repo.createRequest(
        restricted,
        requestDraft(inspectionId: inspection.id),
      );
      expect(created, isA<Success<ServiceMaterialRequest>>());
      // The restricted user still cannot read the full inspection queue.
      final inspectionsRead = await inspections
          .watchInspections(restricted)
          .first;
      expect(inspectionsRead, isA<Failed<ServiceInspectionPage>>());
    },
  );

  test('permissions are enforced live without relogin', () async {
    final inspection = await completedInspection('ja1');
    final creator = context(
      permissions: {
        AppPermission.serviceMaterialRequestCreate,
        AppPermission.serviceMaterialRequestViewAssigned,
      },
      employeeId: 'e1',
    );
    final created = await repo.createRequest(
      creator,
      requestDraft(inspectionId: inspection.id),
    );
    expect(created, isA<Success<ServiceMaterialRequest>>());
    // With no material-request permission the queue is denied.
    final noPermission = context(permissions: const {});
    expect(
      await repo.watchRequests(noPermission).first,
      isA<Failed<ServiceMaterialRequestPage>>(),
    );
    // With a view scope granted, the queue resolves.
    final assigned = context(
      permissions: {AppPermission.serviceMaterialRequestViewAssigned},
      employeeId: 'e1',
    );
    expect(
      await repo.watchRequests(assigned).first,
      isA<Success<ServiceMaterialRequestPage>>(),
    );
    // A view-only user cannot create.
    final viewerOnly = context(
      permissions: {AppPermission.serviceMaterialRequestViewAssigned},
      employeeId: 'e1',
    );
    final denied = await repo.createRequest(
      viewerOnly,
      requestDraft(
        inspectionId: inspection.id,
        lines: [
          ServiceMaterialRequestLineDraft(
            id: 'manual-live',
            code: 'WIRE-2.5',
            description: '2.5mm electrical wire',
            quantity: '3',
          ),
        ],
      ),
    );
    expect(
      (denied as Failed<ServiceMaterialRequest>).failure.code,
      'servicesMaterialRequestDenied',
    );
  });

  test(
    'write operations enforce object scope through read permissions',
    () async {
      final inspection = await completedInspection('ja1');
      final all = context(permissions: _all);
      final created =
          (await repo.createRequest(
                    all,
                    requestDraft(inspectionId: inspection.id),
                  )
                  as Success<ServiceMaterialRequest>)
              .value;
      // An unrelated assigned user cannot read the request.
      final unrelated = context(
        permissions: {AppPermission.serviceMaterialRequestViewAssigned},
        employeeId: 'e3',
      );
      final read = await repo.getRequest(unrelated, created.id);
      expect((read as Success<ServiceMaterialRequestView?>).value, isNull);
    },
  );

  test('the active-requirement partial unique index exists', () async {
    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='index' AND name='service_material_request_lines_active_requirement'",
        )
        .get();
    expect(indexes, hasLength(1));
  });
}
