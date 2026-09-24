import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/services/enquiries/data/local_service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

AuthContext context({
  required Set<AppPermission> permissions,
  String companyId = 'c1',
  String userId = 'u1',
}) => AuthContext(
  user: UserAccount(
    id: userId,
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
);

const _all = {
  AppPermission.serviceEnquiryView,
  AppPermission.serviceEnquiryCreate,
  AppPermission.serviceEnquiryEdit,
  AppPermission.serviceEnquiryCancel,
};

void main() {
  late AppDatabase db;
  late LocalServiceEnquiryRepository repo;
  late LocalAttachmentRepository attachments;
  const clock = SystemAppClock();
  final now = DateTime.utc(2026, 1, 10, 9);
  var seq = 0;
  String nextId() => 'id-${seq++}';

  Future<void> seed() async {
    Future<void> customer(String id, String code, String name, String status) =>
        db
            .into(db.serviceCustomers)
            .insert(
              ServiceCustomersCompanion.insert(
                id: id,
                companyId: 'c1',
                customerCode: code,
                name: name,
                mobile: '+97150000000$id',
                status: status,
                createdAt: now,
                updatedAt: now,
                createdByUserId: 'u1',
                updatedByUserId: 'u1',
                syncStatus: 'synced',
              ),
              mode: InsertMode.insertOrIgnore,
            );
    Future<void> site(
      String id,
      String code,
      String customerId,
      String status,
    ) => db
        .into(db.serviceSites)
        .insert(
          ServiceSitesCompanion.insert(
            id: id,
            companyId: 'c1',
            customerId: customerId,
            siteCode: code,
            siteName: 'Site $id',
            buildingName: const Value('Tower'),
            unitNumber: const Value('101'),
            addressLine1: 'Main Road',
            city: 'Dubai',
            status: status,
            createdAt: now,
            updatedAt: now,
            createdByUserId: 'u1',
            updatedByUserId: 'u1',
            syncStatus: 'synced',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await customer('cus1', 'CUS-1', 'ABC Properties', 'active');
    await customer('cus2', 'CUS-2', 'Gulf Facility', 'active');
    await customer('cus3', 'CUS-3', 'Inactive Co', 'inactive');
    await site('site1', 'SITE-1', 'cus1', 'active');
    await site('site2', 'SITE-2', 'cus2', 'active');
    await site('site3', 'SITE-3', 'cus1', 'inactive');
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
            name: 'Power Issue',
            serviceTypeId: const Value('st1'),
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
  }

  ServiceEnquiryDraftDetail line({
    String? id,
    String description = 'Power outage',
    ServiceEnquiryDetailStatus status = ServiceEnquiryDetailStatus.open,
    List<AttachmentRef> attachments = const [],
  }) => ServiceEnquiryDraftDetail(
    id: id ?? nextId(),
    description: description,
    status: status,
    attachments: attachments,
  );

  ServiceEnquiryDraft draft({
    String? customerId = 'cus1',
    String? siteId = 'site1',
    String? serviceTypeId = 'st1',
    String? complaintTypeId = 'ct1',
    String? priorityId = 'pr1',
    String? ticketTypeId = 'tt1',
    MaterialReceived materialReceived = MaterialReceived.no,
    List<ServiceEnquiryDraftDetail>? details,
  }) => ServiceEnquiryDraft(
    customerId: customerId,
    siteId: siteId,
    serviceTypeId: serviceTypeId,
    complaintTypeId: complaintTypeId,
    priorityId: priorityId,
    ticketTypeId: ticketTypeId,
    materialReceived: materialReceived,
    details: details ?? [line()],
  );

  AttachmentRef photo(
    String id, {
    String mime = 'image/jpeg',
    int size = 2048,
  }) => AttachmentRef(
    id: id,
    companyId: 'c1',
    ownerType: 'serviceEnquiryDetail',
    ownerId: 'draft',
    category: AttachmentCategory.problemPhoto,
    fileName: 'photo.jpg',
    displayName: 'photo.jpg',
    mimeType: mime,
    sizeBytes: size,
    uploadStatus: AttachmentUploadStatus.localOnly,
    syncStatus: 'pending',
    createdByUserId: 'u1',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final numbers = LocalDocumentNumberService(db, clock);
    attachments = LocalAttachmentRepository(db, clock);
    repo = LocalServiceEnquiryRepository(
      db,
      clock,
      numbers,
      LocalActivityRepository(db),
      attachments,
    );
    await seed();
  });
  tearDown(() => db.close());

  test(
    'create produces an OPEN enquiry with details, number and snapshot',
    () async {
      final result = await repo.createEnquiry(
        context(permissions: _all),
        draft(
          materialReceived: MaterialReceived.yes,
          details: [
            line(description: 'Warm air'),
            line(description: 'Noise'),
          ],
        ),
      );
      final enquiry = (result as Success<ServiceEnquiry>).value;
      expect(enquiry.status, ServiceEnquiryStatus.open);
      expect(enquiry.enquiryNumber, 'ENQ-000001');
      expect(enquiry.version, 1);
      expect(enquiry.materialReceived, MaterialReceived.yes);
      expect(enquiry.details, hasLength(2));
      expect(enquiry.details.first.lineNumber, 1);
      expect(enquiry.details.first.description, 'Warm air');
      expect(enquiry.details.last.lineNumber, 2);
      expect(enquiry.partySnapshot.customerName, 'ABC Properties');
      expect(enquiry.partySnapshot.buildingName, 'Tower');
    },
  );

  test('create requires at least one detail with a description', () async {
    final ctx = context(permissions: _all);
    expect(
      ((await repo.createEnquiry(ctx, draft(details: const [])))
              as Failed<ServiceEnquiry>)
          .failure
          .code,
      'servicesEnquiryDetailsRequired',
    );
    expect(
      ((await repo.createEnquiry(
                ctx,
                draft(details: [line(description: '  ')]),
              ))
              as Failed<ServiceEnquiry>)
          .failure
          .code,
      'servicesEnquiryDetailDescriptionRequired',
    );
    expect(await db.select(db.serviceEnquiries).get(), isEmpty);
  });

  test(
    'sequence is unique and idempotent retry does not duplicate details',
    () async {
      final ctx = context(permissions: _all);
      final first =
          (await repo.createEnquiry(
                ctx,
                draft(details: [line(id: 'line-1')]),
                requestId: 'req-1',
              ))
              as Success<ServiceEnquiry>;
      final retry =
          (await repo.createEnquiry(
                ctx,
                draft(details: [line(id: 'line-1')]),
                requestId: 'req-1',
              ))
              as Success<ServiceEnquiry>;
      expect(retry.value.id, first.value.id);
      final second =
          (await repo.createEnquiry(ctx, draft())) as Success<ServiceEnquiry>;
      expect(second.value.enquiryNumber, 'ENQ-000002');
      expect(await db.select(db.serviceEnquiries).get(), hasLength(2));
      expect(
        await (db.select(
          db.serviceEnquiryDetails,
        )..where((t) => t.enquiryId.equals(first.value.id))).get(),
        hasLength(1),
      );
    },
  );

  test('cross-customer site and inactive references are rejected', () async {
    final ctx = context(permissions: _all);
    expect(
      ((await repo.createEnquiry(ctx, draft(siteId: 'site2')))
              as Failed<ServiceEnquiry>)
          .failure
          .code,
      'servicesEnquirySiteCustomerMismatch',
    );
    expect(
      ((await repo.createEnquiry(
                ctx,
                draft(customerId: 'cus3', siteId: 'site3'),
              ))
              as Failed<ServiceEnquiry>)
          .failure
          .code,
      'servicesEnquiryCustomerInactive',
    );
    expect(
      ((await repo.createEnquiry(ctx, draft(siteId: 'site3')))
              as Failed<ServiceEnquiry>)
          .failure
          .code,
      'servicesEnquirySiteInactive',
    );
    expect(await db.select(db.serviceEnquiries).get(), isEmpty);
  });

  test('edit reconciles detail lines (update, add, soft-remove)', () async {
    final ctx = context(permissions: _all);
    final created =
        (await repo.createEnquiry(
              ctx,
              draft(
                details: [
                  line(id: 'keep', description: 'First'),
                  line(id: 'drop', description: 'Second'),
                ],
              ),
            ))
            as Success<ServiceEnquiry>;
    final updated =
        (await repo.updateEnquiry(
              ctx,
              created.value.id,
              draft(
                details: [
                  line(id: 'keep', description: 'First updated'),
                  line(id: 'new', description: 'Third'),
                ],
              ),
            ))
            as Success<ServiceEnquiry>;
    expect(updated.value.version, 2);
    expect(updated.value.details.map((d) => d.id).toSet(), {'keep', 'new'});
    expect(
      updated.value.details.firstWhere((d) => d.id == 'keep').description,
      'First updated',
    );
    // The removed line is soft-removed, never hard-deleted.
    final allRows = await db.select(db.serviceEnquiryDetails).get();
    expect(allRows, hasLength(3));
    expect(allRows.firstWhere((r) => r.id == 'drop').removedAt, isNotNull);
    // Only the active lines are returned.
    final view =
        (await repo.getEnquiry(ctx, created.value.id))
            as Success<ServiceEnquiryView?>;
    expect(view.value!.enquiry.details, hasLength(2));
  });

  test(
    'attachments reconcile with detail lines and appear in the view',
    () async {
      final ctx = context(permissions: _all);
      final created =
          (await repo.createEnquiry(
                ctx,
                draft(
                  details: [
                    line(id: 'line-1', attachments: [photo('a1'), photo('a2')]),
                  ],
                ),
              ))
              as Success<ServiceEnquiry>;
      final view =
          (await repo.getEnquiry(ctx, created.value.id))
              as Success<ServiceEnquiryView?>;
      expect(view.value!.enquiry.details.single.attachments, hasLength(2));

      // Removing one attachment on update soft-removes it.
      await repo.updateEnquiry(
        ctx,
        created.value.id,
        draft(
          details: [
            line(id: 'line-1', attachments: [photo('a1')]),
          ],
        ),
      );
      final after =
          (await repo.getEnquiry(ctx, created.value.id))
              as Success<ServiceEnquiryView?>;
      expect(after.value!.enquiry.details.single.attachments, hasLength(1));
      expect(after.value!.enquiry.details.single.attachments.single.id, 'a1');
    },
  );

  test('invalid attachment is rejected and aborts the transaction', () async {
    final ctx = context(permissions: _all);
    final result = await repo.createEnquiry(
      ctx,
      draft(
        details: [
          line(
            id: 'line-1',
            attachments: [photo('bad', mime: 'text/plain')],
          ),
        ],
      ),
    );
    expect(result, isA<Failed<ServiceEnquiry>>());
    expect(await db.select(db.serviceEnquiries).get(), isEmpty);
    expect(await db.select(db.serviceEnquiryDetails).get(), isEmpty);
    expect(await db.select(db.attachmentRecords).get(), isEmpty);
  });

  test(
    'mutations record activity and outbox with the detail structure',
    () async {
      final ctx = context(permissions: _all);
      final created =
          (await repo.createEnquiry(
                ctx,
                draft(
                  details: [
                    line(id: 'line-1', attachments: [photo('a1')]),
                  ],
                ),
              ))
              as Success<ServiceEnquiry>;
      await repo.updateEnquiry(ctx, created.value.id, draft());
      await repo.cancelEnquiry(ctx, created.value.id);

      final events = await db.select(db.businessActivityEvents).get();
      expect(events.map((e) => e.eventType).toSet(), {
        'services.enquiry.created',
        'services.enquiry.updated',
        'services.enquiry.cancelled',
      });

      final create =
          await (db.select(db.syncOutbox)
                ..where((t) => t.operation.equals('SERVICES_ENQUIRY_CREATE')))
              .getSingle();
      expect(create.payload, contains('"details"'));
      expect(create.payload, contains('"line-1"'));
      expect(create.payload, contains('"a1"'));
      expect(create.payload, isNot(contains('base64')));
    },
  );

  test('cancel is terminal and never deletes the row', () async {
    final ctx = context(permissions: _all);
    final created =
        (await repo.createEnquiry(ctx, draft())) as Success<ServiceEnquiry>;
    expect(
      await repo.cancelEnquiry(ctx, created.value.id, reason: 'Duplicate'),
      isA<Success<void>>(),
    );
    final again = await repo.cancelEnquiry(ctx, created.value.id);
    expect(
      (again as Failed<void>).failure.code,
      'servicesEnquiryAlreadyCancelled',
    );
    expect(await db.select(db.serviceEnquiries).get(), hasLength(1));
  });

  test(
    'view permission gates reads; create/edit gate restricted references',
    () async {
      final viewOnly = context(permissions: {AppPermission.serviceEnquiryView});
      final created =
          (await repo.createEnquiry(context(permissions: _all), draft()))
              as Success<ServiceEnquiry>;
      expect(
        await repo.watchEnquiries(viewOnly).first,
        isA<Success<ServiceEnquiryPage>>(),
      );
      expect(
        (await repo
                    .watchEnquiries(
                      context(
                        permissions: {AppPermission.serviceEnquiryCreate},
                      ),
                    )
                    .first
                as Failed<ServiceEnquiryPage>)
            .failure
            .code,
        'servicesEnquiryDenied',
      );
      expect(
        await repo.getEnquiry(viewOnly, created.value.id),
        isA<Success<ServiceEnquiryView?>>(),
      );

      final createOnly = context(
        permissions: {AppPermission.serviceEnquiryCreate},
      );
      expect(
        await repo.searchCustomerRefsForEnquiry(createOnly),
        isA<Success<List<dynamic>>>(),
      );
      expect(
        (await repo.searchCustomerRefsForEnquiry(viewOnly)
                as Failed<List<dynamic>>)
            .failure
            .code,
        'servicesEnquiryDenied',
      );
    },
  );

  test('company isolation and summary counts', () async {
    final ctx = context(permissions: _all);
    await repo.createEnquiry(ctx, draft());
    await repo.createEnquiry(ctx, draft());
    final cancelled =
        (await repo.createEnquiry(ctx, draft())) as Success<ServiceEnquiry>;
    await repo.cancelEnquiry(ctx, cancelled.value.id);

    final summary = (await repo.summary(ctx)) as Success<ServiceEnquirySummary>;
    expect(summary.value.openCount, 2);
    expect(summary.value.totalCount, 3);
    expect(summary.value.highUrgentOpenCount, 2);

    final other = context(permissions: _all, companyId: 'c2');
    final page =
        (await repo.watchEnquiries(other).first) as Success<ServiceEnquiryPage>;
    expect(page.value.items, isEmpty);
    final foreign = await repo.getEnquiry(other, cancelled.value.id);
    expect((foreign as Success<ServiceEnquiryView?>).value, isNull);
    final foreignDetails = await db
        .customSelect(
          'SELECT * FROM service_enquiry_details WHERE company_id=?',
          variables: [const Variable('c2')],
        )
        .get();
    expect(foreignDetails, isEmpty);
  });

  test('recent and per-customer/site read models resolve', () async {
    final ctx = context(permissions: _all);
    await repo.createEnquiry(ctx, draft());
    await repo.createEnquiry(ctx, draft(customerId: 'cus2', siteId: 'site2'));
    final recent =
        (await repo.watchRecentEnquiries(ctx).first)
            as Success<List<ServiceEnquiryListItem>>;
    expect(recent.value, hasLength(2));
    final forCustomer =
        (await repo.watchEnquiriesForCustomer(ctx, 'cus1').first)
            as Success<List<ServiceEnquiryListItem>>;
    expect(forCustomer.value, hasLength(1));
  });

  test(
    'v14 migration preserves Phase 2 enquiries by copying the description',
    () async {
      final folder = Directory.systemTemp.createTempSync('erp_enq_migration_');
      final file = File('${folder.path}/erp.sqlite');
      try {
        final old = AppDatabase(NativeDatabase(file));
        await old
            .into(old.serviceEnquiries)
            .insert(
              ServiceEnquiriesCompanion.insert(
                id: 'legacy',
                companyId: 'c1',
                enquiryNumber: 'ENQ-LEGACY',
                customerId: 'cus1',
                siteId: 'site1',
                serviceTypeId: 'st1',
                complaintTypeId: 'ct1',
                priorityId: 'pr1',
                ticketTypeId: 'tt1',
                description: 'Legacy complaint text',
                status: 'open',
                partySnapshot: '{}',
                createdAt: now,
                updatedAt: now,
                createdByUserId: 'u1',
                updatedByUserId: 'u1',
                syncStatus: 'synced',
              ),
            );
        await old.customStatement('DROP TABLE service_enquiry_details');
        // Simulate the pre-2.1 schema: no material_received column on old rows.
        await old.customStatement(
          'ALTER TABLE service_enquiries DROP COLUMN material_received',
        );
        await old.customStatement('PRAGMA user_version=13');
        await old.close();

        final upgraded = AppDatabase(NativeDatabase(file));
        final details = await upgraded
            .select(upgraded.serviceEnquiryDetails)
            .get();
        expect(details, hasLength(1));
        expect(details.single.enquiryId, 'legacy');
        expect(details.single.description, 'Legacy complaint text');
        // The added column is repaired to its default, never left NULL.
        final header = await upgraded
            .select(upgraded.serviceEnquiries)
            .getSingle();
        expect(header.materialReceived, 'no');
        expect(
          (await upgraded.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          15,
        );
        await upgraded.close();
      } finally {
        folder.deleteSync(recursive: true);
      }
    },
  );
}
