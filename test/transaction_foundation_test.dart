import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/module/workforce_directory_adapter.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_attachment_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';
import 'package:modular_erp/shared/transactions/domain/document_number.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockEmployeeRepository extends Mock implements EmployeeRepository {}

const _clock = SystemAppClock();

AuthContext _context(String companyId) => AuthContext(
  user: UserAccount(
    id: 'user-1',
    displayName: 'User',
    email: 'user@erp.demo',
    companyId: companyId,
    role: AppRole.hr,
    permissions: PermissionSet(const []),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: companyId,
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: const {'employees'},
  ),
);

Employee _employee({
  String id = 'e1',
  String companyId = 'c1',
  EmploymentStatus status = EmploymentStatus.active,
}) => Employee(
  id: id,
  companyId: companyId,
  employeeCode: 'EMP-$id',
  firstName: 'Ali',
  lastName: 'Khan',
  email: '$id@erp.demo',
  phone: '000',
  departmentId: 'd1',
  designationId: 'g1',
  joiningDate: DateTime.utc(2024, 1, 1),
  status: status,
  createdAt: DateTime.utc(2024, 1, 1),
  updatedAt: DateTime.utc(2024, 1, 1),
);

void main() {
  setUpAll(() {
    registerFallbackValue(_context('c1'));
    registerFallbackValue('');
  });

  group('document numbering', () {
    late AppDatabase db;
    late LocalDocumentNumberService service;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      service = LocalDocumentNumberService(db, _clock);
    });
    tearDown(() => db.close());

    test('first and next numbers are sequential', () async {
      final first = await service.nextNumber(
        companyId: 'c1',
        type: DocumentSequenceType.serviceEnquiry,
      );
      final second = await service.nextNumber(
        companyId: 'c1',
        type: DocumentSequenceType.serviceEnquiry,
      );
      expect((first as Success<String>).value, 'ENQ-000001');
      expect((second as Success<String>).value, 'ENQ-000002');
    });

    test('different document types have independent counters', () async {
      final enq = await service.nextNumber(
        companyId: 'c1',
        type: DocumentSequenceType.serviceEnquiry,
      );
      final job = await service.nextNumber(
        companyId: 'c1',
        type: DocumentSequenceType.serviceJob,
      );
      expect((enq as Success<String>).value, 'ENQ-000001');
      expect((job as Success<String>).value, 'JOB-000001');
    });

    test('different companies have independent counters', () async {
      final a = await service.nextNumber(
        companyId: 'c1',
        type: DocumentSequenceType.serviceEnquiry,
      );
      final b = await service.nextNumber(
        companyId: 'c2',
        type: DocumentSequenceType.serviceEnquiry,
      );
      expect((a as Success<String>).value, 'ENQ-000001');
      expect((b as Success<String>).value, 'ENQ-000001');
    });

    test('concurrent reservations never duplicate a number', () async {
      final results = await Future.wait([
        for (var i = 0; i < 8; i++)
          service.nextNumber(
            companyId: 'c1',
            type: DocumentSequenceType.serviceJob,
          ),
      ]);
      final numbers = results.map((r) => (r as Success<String>).value).toSet();
      expect(numbers.length, 8);
    });

    test('server reconciliation advances the local counter', () async {
      await service.adoptServerNumber(
        companyId: 'c1',
        type: DocumentSequenceType.serviceEnquiry,
        displayNumber: 'ENQ-000500',
      );
      final next = await service.nextNumber(
        companyId: 'c1',
        type: DocumentSequenceType.serviceEnquiry,
      );
      expect((next as Success<String>).value, 'ENQ-000501');
    });

    test('formatting pads to the configured width without truncating', () {
      expect(
        DocumentNumberFormatter.format(prefix: 'ENQ', value: 9),
        'ENQ-000009',
      );
      expect(
        DocumentNumberFormatter.format(prefix: 'ENQ', value: 999999),
        'ENQ-999999',
      );
      expect(
        DocumentNumberFormatter.format(prefix: 'ENQ', value: 1000000),
        'ENQ-1000000',
      );
    });
  });

  group('attachments', () {
    late AppDatabase db;
    late LocalAttachmentRepository repository;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = LocalAttachmentRepository(db, _clock);
    });
    tearDown(() => db.close());

    AttachmentDraft draft({
      String companyId = 'c1',
      String ownerType = 'serviceEnquiry',
      String ownerId = 'o1',
      String mimeType = 'image/jpeg',
      int size = 1024,
    }) => AttachmentDraft(
      companyId: companyId,
      ownerType: ownerType,
      ownerId: ownerId,
      category: AttachmentCategory.problemPhoto,
      fileName: 'photo.jpg',
      displayName: 'Photo',
      mimeType: mimeType,
      sizeBytes: size,
      createdByUserId: 'user-1',
      localPath: '/tmp/photo.jpg',
    );

    test('adds metadata and watches by owner', () async {
      await repository.addLocalAttachment(draft());
      final rows = await repository
          .watchForOwner(
            companyId: 'c1',
            ownerType: 'serviceEnquiry',
            ownerId: 'o1',
          )
          .first;
      expect(rows, hasLength(1));
      expect(rows.single.uploadStatus, AttachmentUploadStatus.localOnly);
      expect(rows.single.localPath, '/tmp/photo.jpg');
    });

    test('watch is scoped to company and owner', () async {
      await repository.addLocalAttachment(draft());
      await repository.addLocalAttachment(draft(companyId: 'c2'));
      await repository.addLocalAttachment(draft(ownerId: 'o2'));
      final rows = await repository
          .watchForOwner(
            companyId: 'c1',
            ownerType: 'serviceEnquiry',
            ownerId: 'o1',
          )
          .first;
      expect(rows, hasLength(1));
    });

    test('lifecycle transitions and deletion', () async {
      final added =
          (await repository.addLocalAttachment(draft()))
              as Success<AttachmentRef>;
      final id = added.value.id;
      expect(
        await repository.markUploaded(
          companyId: 'c1',
          attachmentId: id,
          remoteUrl: 'https://cdn/photo.jpg',
          storageKey: 'k1',
        ),
        isA<Success<void>>(),
      );
      var rows = await repository
          .watchForOwner(
            companyId: 'c1',
            ownerType: 'serviceEnquiry',
            ownerId: 'o1',
          )
          .first;
      expect(rows.single.isUploaded, isTrue);
      expect(rows.single.remoteUrl, 'https://cdn/photo.jpg');

      await repository.markFailed(
        companyId: 'c1',
        attachmentId: id,
        failureCode: 'network',
      );
      await repository.removeAttachment(companyId: 'c1', attachmentId: id);
      rows = await repository
          .watchForOwner(
            companyId: 'c1',
            ownerType: 'serviceEnquiry',
            ownerId: 'o1',
          )
          .first;
      expect(rows, isEmpty);
    });

    test('rejects unsupported types and oversized files', () async {
      expect(
        await repository.addLocalAttachment(draft(mimeType: 'text/plain')),
        isA<Failed<AttachmentRef>>(),
      );
      expect(
        await repository.addLocalAttachment(
          draft(size: AttachmentValidation.maxFileSizeBytes + 1),
        ),
        isA<Failed<AttachmentRef>>(),
      );
    });

    test('metadata table stores no binary/blob columns', () async {
      final rows = await db
          .customSelect('PRAGMA table_info(attachment_records)')
          .get();
      final blobColumns = rows
          .where((row) => row.read<String>('type').toUpperCase() == 'BLOB')
          .toList();
      expect(blobColumns, isEmpty);
    });
  });

  group('activity events', () {
    late AppDatabase db;
    late LocalActivityRepository repository;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = LocalActivityRepository(db);
    });
    tearDown(() => db.close());

    BusinessActivityEvent event({
      String id = 'a1',
      String companyId = 'c1',
      String entityType = 'serviceEnquiry',
      String entityId = 'o1',
      String eventType = 'services.enquiry.created',
      DateTime? occurredAt,
    }) => BusinessActivityEvent(
      id: id,
      companyId: companyId,
      moduleKey: 'services',
      entityType: entityType,
      entityId: entityId,
      eventType: eventType,
      occurredAt: occurredAt ?? DateTime.utc(2024, 1, 1),
      actorUserId: 'user-1',
      syncStatus: 'pending',
      metadata: const {'toStatus': 'pending'},
    );

    test('appends structured events and returns newest first', () async {
      await repository.append(
        event(id: 'a1', occurredAt: DateTime.utc(2024, 1, 1)),
      );
      await repository.append(
        event(id: 'a2', occurredAt: DateTime.utc(2024, 2, 1)),
      );
      final rows = await repository
          .watchForEntity(
            companyId: 'c1',
            entityType: 'serviceEnquiry',
            entityId: 'o1',
          )
          .first;
      expect(rows.map((e) => e.id), ['a2', 'a1']);
      expect(rows.first.eventType, 'services.enquiry.created');
      expect(rows.first.metadata['toStatus'], 'pending');
    });

    test('company and entity isolation', () async {
      await repository.append(event(id: 'a1'));
      await repository.append(event(id: 'a2', companyId: 'c2'));
      await repository.append(event(id: 'a3', entityId: 'o2'));
      final rows = await repository
          .watchForEntity(
            companyId: 'c1',
            entityType: 'serviceEnquiry',
            entityId: 'o1',
          )
          .first;
      expect(rows.map((e) => e.id), ['a1']);
    });

    test('namespaced event keys are stable', () {
      expect(
        ActivityEventKeys.of('hr', 'leave', 'approved'),
        'hr.leave.approved',
      );
      expect(
        ActivityEventKeys.of('services', 'job', 'assigned'),
        'services.job.assigned',
      );
    });
  });

  group('workforce directory contract', () {
    late _MockAuthRepository auth;
    late _MockEmployeeRepository employees;
    late HrWorkforceDirectory directory;
    setUp(() {
      auth = _MockAuthRepository();
      employees = _MockEmployeeRepository();
      directory = HrWorkforceDirectory(auth, employees);
      when(
        () => auth.checkSession(),
      ).thenAnswer((_) async => Success<AuthContext?>(_context('c1')));
    });

    test('assignment search returns only active employees', () async {
      when(
        () => employees.watchEmployees(
          any(),
          query: any(named: 'query'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          Success(
            EmployeePageData(
              [
                _employee(id: 'e1'),
                _employee(id: 'e2', status: EmploymentStatus.inactive),
              ],
              2,
              2,
            ),
          ),
        ),
      );
      final result = await directory.searchAssignable();
      expect(result.map((r) => r.id), ['e1']);
    });

    test('inactive employees resolve only as historical references', () async {
      when(() => employees.getEmployeeById(any(), 'e2')).thenAnswer(
        (_) async => Success<Employee?>(
          _employee(id: 'e2', status: EmploymentStatus.inactive),
        ),
      );
      expect(await directory.getEmployeeReference('e2'), isNull);
      final historical = await directory.getEmployeeReference(
        'e2',
        includeInactive: true,
      );
      expect(historical, isNotNull);
      expect(historical!.isActive, isFalse);
    });

    test('cross-company employee ids do not resolve', () async {
      when(
        () => employees.getEmployeeById(any(), 'other'),
      ).thenAnswer((_) async => const Success<Employee?>(null));
      expect(await directory.getEmployeeReference('other'), isNull);
    });
  });
}
