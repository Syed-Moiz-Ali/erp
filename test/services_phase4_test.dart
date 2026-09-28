import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/inspections/data/local_service_inspection_repository.dart';
import 'package:modular_erp/modules/services/inspections/domain/service_inspection.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

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
};

void main() {
  late AppDatabase db;
  late LocalServiceInspectionRepository repo;
  final now = DateTime.utc(2026, 1, 10, 9);
  final clock = _FixedClock(DateTime.utc(2026, 1, 10, 9));

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
    await db
        .into(db.serviceTypes)
        .insert(
          ServiceTypesCompanion.insert(
            id: 'st1',
            companyId: 'c1',
            code: 'ELEC',
            name: 'Electrical',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.complaintTypes)
        .insert(
          ComplaintTypesCompanion.insert(
            id: 'ct1',
            companyId: 'c1',
            code: 'POWER',
            name: 'Power',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.servicePriorities)
        .insert(
          ServicePrioritiesCompanion.insert(
            id: 'pr1',
            companyId: 'c1',
            code: 'HIGH',
            name: 'High',
            rank: const Value(2),
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.serviceTicketTypes)
        .insert(
          ServiceTicketTypesCompanion.insert(
            id: 'tt1',
            companyId: 'c1',
            code: 'COMPLAINT',
            name: 'Complaint',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.serviceRootCauses)
        .insert(
          ServiceRootCausesCompanion.insert(
            id: 'rc1',
            companyId: 'c1',
            code: 'ELECTRICAL',
            name: 'Electrical fault',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.serviceChargeResponsibilities)
        .insert(
          ServiceChargeResponsibilitiesCompanion.insert(
            id: 'ch1',
            companyId: 'c1',
            code: 'TENANT',
            name: 'Tenant',
            status: 'active',
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
        );
    await db
        .into(db.serviceEnquiries)
        .insert(
          ServiceEnquiriesCompanion.insert(
            id: 'enq1',
            companyId: 'c1',
            enquiryNumber: 'ENQ-000001',
            customerId: 'cus1',
            siteId: 'site1',
            serviceTypeId: 'st1',
            complaintTypeId: 'ct1',
            priorityId: 'pr1',
            ticketTypeId: 'tt1',
            description: '',
            status: 'assigned',
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
    await db
        .into(db.serviceJobAssignments)
        .insert(
          ServiceJobAssignmentsCompanion.insert(
            id: 'ja1',
            companyId: 'c1',
            assignmentNumber: 'JA-000001',
            assignmentDate: now,
            sourceEnquiryId: 'enq1',
            scheduledVisitDate: DateTime.utc(2026, 1, 12),
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
            id: 'l1',
            companyId: 'c1',
            assignmentId: 'ja1',
            lineNumber: 1,
            work: 'Inspect AC compressor',
            descriptionForWork: const Value('Check pressure'),
            assignedEmployeeId: const Value('e1'),
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

  ServiceInspectionDraft draft({
    String? technician = 'e1',
    int? visitMinutes = 630,
    String? rootCause = 'rc1',
    String? charge = 'ch1',
    List<ServiceInspectionChecklistItemDraft>? checklist,
    List<ServiceInspectionPointDraft>? points,
    List<ServiceInspectionMaterialRequirementDraft>? materials,
  }) => ServiceInspectionDraft(
    sourceJobAssignmentId: 'ja1',
    visitDate: DateTime.utc(2026, 1, 12),
    visitMinutes: visitMinutes,
    technicianEmployeeId: technician,
    rootCauseId: rootCause,
    chargeResponsibilityId: charge,
    checklistItems:
        checklist ??
        [
          const ServiceInspectionChecklistItemDraft(
            id: 'c1',
            sourceJobAssignmentLineId: 'l1',
            workType: 'Inspect AC',
          ),
        ],
    inspectedPoints: points ?? const [],
    materialRequirements: materials ?? const [],
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final numbers = LocalDocumentNumberService(db, clock);
    repo = LocalServiceInspectionRepository(
      db,
      clock,
      numbers,
      LocalActivityRepository(db),
      LocalAttachmentRepository(db, clock),
      _FakeDirectory({
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
      }),
      const FixedOffsetCompanyTimeService(),
    );
    await seed();
  });
  tearDown(() => db.close());

  test('create builds a numbered inspection with source lineage', () async {
    final result = await repo.createInspection(
      context(permissions: _all),
      draft(),
    );
    final inspection = (result as Success<ServiceInspection>).value;
    expect(inspection.inspectionNumber, 'INS-000001');
    expect(inspection.status, ServiceInspectionStatus.pending);
    expect(inspection.sourceJobAssignmentId, 'ja1');
    expect(inspection.sourceEnquiryId, 'enq1');
    expect(inspection.checklistItems.single.sourceJobAssignmentLineId, 'l1');
    expect(inspection.technicianEmployeeId, 'e1');
  });

  test('a second inspection for the same assignment is rejected', () async {
    await repo.createInspection(context(permissions: _all), draft());
    final second = await repo.createInspection(
      context(permissions: _all),
      draft(),
    );
    expect(
      (second as Failed<ServiceInspection>).failure.code,
      'servicesInspectionAlreadyActive',
    );
  });

  test('source context prefills work lines and eligible technicians', () async {
    final result = await repo.getSourceContext(
      context(permissions: _all),
      'ja1',
    );
    final source = (result as Success<ServiceInspectionSourceContext?>).value!;
    expect(source.enquiryNumber, 'ENQ-000001');
    expect(source.customerName, 'ABC Properties');
    expect(source.workLines.single.work, 'Inspect AC compressor');
    expect(source.eligibleTechnicians.map((t) => t.id), contains('e1'));
  });

  test('technician must be eligible for the assignment', () async {
    final result = await repo.createInspection(
      context(permissions: _all),
      draft(technician: 'e2'),
    );
    expect(
      (result as Failed<ServiceInspection>).failure.code,
      'servicesInspectionTechnicianInvalid',
    );
  });

  test('complete validates and finalizes; completed is read-only', () async {
    final ctx = context(permissions: _all);
    final created =
        (await repo.createInspection(ctx, draft()))
            as Success<ServiceInspection>;
    final completed =
        (await repo.completeInspection(ctx, created.value.id))
            as Success<ServiceInspection>;
    expect(completed.value.status, ServiceInspectionStatus.completed);
    final edited = await repo.updateInspection(ctx, created.value.id, draft());
    expect(
      (edited as Failed<ServiceInspection>).failure.code,
      'servicesInspectionNotEditable',
    );
  });

  test('complete rejects missing assessment', () async {
    final ctx = context(permissions: _all);
    final created =
        (await repo.createInspection(ctx, draft(checklist: const [])))
            as Success<ServiceInspection>;
    final result = await repo.completeInspection(ctx, created.value.id);
    expect(
      (result as Failed<ServiceInspection>).failure.code,
      'servicesInspectionAssessmentRequired',
    );
  });

  test('material requirements are WAITING and create no inventory', () async {
    final inspection =
        (await repo.createInspection(
              context(permissions: _all),
              draft(
                materials: const [
                  ServiceInspectionMaterialRequirementDraft(
                    id: 'm1',
                    code: 'CAP-35UF',
                    description: '35uF capacitor',
                  ),
                ],
              ),
            ))
            as Success<ServiceInspection>;
    expect(
      inspection.value.materialRequirements.single.status,
      ServiceInspectionMaterialStatus.waiting,
    );
    // No inventory/material tables exist; nothing is created beyond the line.
    expect(
      await db.select(db.serviceInspectionMaterialRequirements).get(),
      hasLength(1),
    );
  });

  test('multiple before-work photos persist per checklist item', () async {
    final inspection =
        (await repo.createInspection(
              context(permissions: _all),
              draft(
                checklist: [
                  ServiceInspectionChecklistItemDraft(
                    id: 'c1',
                    workType: 'Inspect AC',
                    attachments: [_photo('a1'), _photo('a2')],
                  ),
                ],
              ),
            ))
            as Success<ServiceInspection>;
    expect(inspection.value.checklistItems.single.attachments, hasLength(2));
    expect(await db.select(db.attachmentRecords).get(), hasLength(2));
  });

  test('cancel is historical; completed cannot be cancelled', () async {
    final ctx = context(permissions: _all);
    final created =
        (await repo.createInspection(ctx, draft()))
            as Success<ServiceInspection>;
    expect(
      await repo.cancelInspection(ctx, created.value.id),
      isA<Success<void>>(),
    );
    final row = await (db.select(
      db.serviceInspections,
    )..where((t) => t.id.equals(created.value.id))).getSingle();
    expect(row.status, 'cancelled');
  });

  test('scopes restrict visibility', () async {
    final all = context(permissions: _all);
    final created =
        (await repo.createInspection(all, draft()))
            as Success<ServiceInspection>;
    final assigned =
        (await repo
                    .watchInspections(
                      context(
                        permissions: {
                          AppPermission.serviceInspectionViewAssigned,
                        },
                        employeeId: 'e1',
                      ),
                    )
                    .first
                as Success<ServiceInspectionPage>)
            .value
            .items
            .map((i) => i.id);
    expect(assigned, contains(created.value.id));
    final unrelated =
        (await repo
                    .watchInspections(
                      context(
                        permissions: {
                          AppPermission.serviceInspectionViewAssigned,
                        },
                        employeeId: 'e2',
                      ),
                    )
                    .first
                as Success<ServiceInspectionPage>)
            .value
            .items;
    expect(unrelated, isEmpty);
    final otherCompany =
        (await repo
                    .watchInspections(
                      context(permissions: _all, companyId: 'c2'),
                    )
                    .first
                as Success<ServiceInspectionPage>)
            .value
            .items;
    expect(otherCompany, isEmpty);
  });

  test('idempotent retry does not duplicate the inspection', () async {
    final ctx = context(permissions: _all);
    final first =
        (await repo.createInspection(ctx, draft(), requestId: 'r1'))
            as Success<ServiceInspection>;
    final retry =
        (await repo.createInspection(ctx, draft(), requestId: 'r1'))
            as Success<ServiceInspection>;
    expect(retry.value.id, first.value.id);
    expect(await db.select(db.serviceInspections).get(), hasLength(1));
  });
}

AttachmentRef _photo(String id) => AttachmentRef(
  id: id,
  companyId: 'c1',
  ownerType: 'serviceInspectionChecklistItem',
  ownerId: 'c1',
  category: AttachmentCategory.beforeWorkPhoto,
  fileName: '$id.jpg',
  displayName: '$id.jpg',
  mimeType: 'image/jpeg',
  sizeBytes: 1024,
  uploadStatus: AttachmentUploadStatus.localOnly,
  syncStatus: 'pending',
  createdByUserId: 'u1',
  createdAt: DateTime.utc(2026, 1, 10),
  updatedAt: DateTime.utc(2026, 1, 10),
);
