import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/datasources/dio_branch_remote_data_source.dart';
import 'package:modular_erp/modules/hr/branches/data/repositories/remote_branch_repository.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/branches/$name').readAsStringSync())
        as Map<String, dynamic>;

const _draft = BranchDraft(
  branchName: 'Branch QA',
  branchCode: 'QA-1',
  contactPerson: 'Sanitized Name',
  mobileNo: 'SANITIZED_MOBILE',
  landLine: 'SANITIZED_LANDLINE',
  address: 'Sanitized Address',
  email: 'sanitized@example.com',
  inventoryAlerts: 'Yes',
  multiInventory: 'No',
  divisionId: 1,
  status: BranchStatus.inactive,
  timeZoneId: 'Asia/Kolkata',
);

void main() {
  late FakeDioAdapter adapter;
  late ApiClient client;
  late RemoteBranchRepository repository;

  setUp(() {
    adapter = FakeDioAdapter(
      (_) => jsonResponse(_fixture('branches_list.json'), 200),
    );
    client = buildClient(adapter: adapter, storage: MemorySessionStorage());
    repository = RemoteBranchRepository(DioBranchRemoteDataSource(client));
  });

  tearDown(() => client.close());

  test(
    'list sends status as Active/InActive plus filters and paging',
    () async {
      final result = await repository.list(
        search: '  Branch  ',
        status: BranchStatus.active,
        divisionId: 1,
        sort: 'nameAsc',
        page: 2,
        pageSize: 5,
      );

      expect(result, isA<Success<BranchPage>>());
      final page = (result as Success<BranchPage>).value;
      expect(page.items, hasLength(6));
      expect(page.page, 1);
      expect(page.pageSize, 25);
      expect(page.totalItems, 6);
      expect(page.totalPages, 1);

      expect(adapter.last.method, 'GET');
      expect(adapter.last.uri.path, '/api/branches');
      expect(adapter.last.uri.queryParameters, {
        'page': '2',
        'pageSize': '5',
        'search': 'Branch',
        'status': 'Active',
        'divisionId': '1',
        'sort': 'nameAsc',
      });

      await repository.list(status: BranchStatus.inactive);
      expect(adapter.last.uri.queryParameters['status'], 'InActive');
    },
  );

  test('list omits empty filters and keeps only paging', () async {
    await repository.list(search: '   ', sort: '  ');
    expect(adapter.last.uri.queryParameters, {'page': '1', 'pageSize': '25'});
  });

  test('lookups reads /api/branches/lookups and maps the payload', () async {
    adapter.handler = (_) => jsonResponse(_fixture('branch_lookups.json'), 200);
    final result = await repository.lookups();
    expect(result, isA<Success<BranchLookups>>());
    final lookups = (result as Success<BranchLookups>).value;
    expect(lookups.statuses, ['Active', 'InActive']);
    expect(lookups.yesNo, ['Yes', 'No']);
    expect(lookups.divisions.single.id, 1);
    expect(
      lookups.timeZones.any((timeZone) => timeZone.id == 'Asia/Kolkata'),
      isTrue,
    );
    expect(adapter.last.method, 'GET');
    expect(adapter.last.uri.path, '/api/branches/lookups');
  });

  test('getById targets GET /api/branches/{id}', () async {
    adapter.handler = (_) => jsonResponse(_fixture('branch_detail.json'), 200);
    final result = await repository.getById(2);
    expect(result, isA<Success<Branch>>());
    final branch = (result as Success<Branch>).value;
    expect(branch.branchId, 2);
    expect(branch.branchName, 'Branch 2');
    expect(branch.timeZoneId, 'Asia/Kolkata');
    expect(adapter.last.method, 'GET');
    expect(adapter.last.uri.path, '/api/branches/2');
  });

  test('getById maps BRANCH_NOT_FOUND to notFound', () async {
    adapter.handler = (_) =>
        jsonResponse(_fixture('branch_not_found.json'), 404);
    final result = await repository.getById(999999);
    final failure = (result as Failed).failure;
    expect(failure.code, 'BRANCH_NOT_FOUND');
    expect(failure.kind, FailureKind.notFound);
    expect(failure.serverMessage, 'Company not found.');
  });

  test('create posts the documented full body', () async {
    adapter.handler = (_) => jsonResponse(_fixture('branch_detail.json'), 201);
    final result = await repository.create(_draft);
    expect(result, isA<Success<Branch>>());

    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/branches');
    expect(jsonDecode(adapter.lastBody!), {
      'branchName': 'Branch QA',
      'branchCode': 'QA-1',
      'contactPerson': 'Sanitized Name',
      'mobileNo': 'SANITIZED_MOBILE',
      'landLine': 'SANITIZED_LANDLINE',
      'address': 'Sanitized Address',
      'email': 'sanitized@example.com',
      'inventoryAlerts': 'Yes',
      'multiInventory': 'No',
      'divisionId': 1,
      'status': 'InActive',
      'timeZoneId': 'Asia/Kolkata',
    });
  });

  test(
    'update PUTs the same full body and omits blank optional fields',
    () async {
      adapter.handler = (_) =>
          jsonResponse(_fixture('branch_detail.json'), 200);
      await repository.update(
        2,
        const BranchDraft(
          branchName: 'Branch QA',
          branchCode: '  ',
          timeZoneId: 'Asia/Dubai',
        ),
      );

      expect(adapter.last.method, 'PUT');
      expect(adapter.last.uri.path, '/api/branches/2');
      expect(jsonDecode(adapter.lastBody!), {
        'branchName': 'Branch QA',
        'timeZoneId': 'Asia/Dubai',
      });
    },
  );

  test('activate and deactivate POST their endpoints with no body', () async {
    adapter.handler = (_) => jsonResponse(envelope(data: null), 200);

    final activated = await repository.setActive(4, true);
    expect(activated, isA<Success<void>>());
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/branches/4/activate');
    expect(adapter.lastBody, isNull);

    final deactivated = await repository.setActive(4, false);
    expect(deactivated, isA<Success<void>>());
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/api/branches/4/deactivate');
    expect(adapter.lastBody, isNull);
  });

  test('BRANCH_DUPLICATE_NAME is a branchName conflict', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        errors: [
          errorEntry(
            'BRANCH_DUPLICATE_NAME',
            message: 'Branch name already exists.',
            field: 'branchName',
          ),
        ],
      ),
      409,
    );
    final result = await repository.create(_draft);
    final failure = (result as Failed).failure;
    expect(failure.code, 'BRANCH_DUPLICATE_NAME');
    expect(failure.kind, FailureKind.conflict);
    expect(failure.field, 'branchName');
    expect(failure.serverMessage, 'Branch name already exists.');
  });

  test('BRANCH_ALREADY_ACTIVE/INACTIVE stay conflicts', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        errors: [
          errorEntry(
            'BRANCH_ALREADY_ACTIVE',
            message: 'Branch is already active.',
          ),
        ],
      ),
      409,
    );
    final active = await repository.setActive(4, true);
    final activeFailure = (active as Failed).failure;
    expect(activeFailure.code, 'BRANCH_ALREADY_ACTIVE');
    expect(activeFailure.kind, FailureKind.conflict);
    expect(activeFailure.serverMessage, 'Branch is already active.');

    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        errors: [
          errorEntry(
            'BRANCH_ALREADY_INACTIVE',
            message: 'Branch is already inactive.',
          ),
        ],
      ),
      409,
    );
    final inactive = await repository.setActive(4, false);
    final inactiveFailure = (inactive as Failed).failure;
    expect(inactiveFailure.code, 'BRANCH_ALREADY_INACTIVE');
    expect(inactiveFailure.kind, FailureKind.conflict);
  });

  test('VALIDATION_ERROR preserves field and server message', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        errors: [
          errorEntry(
            'VALIDATION_ERROR',
            message: 'Time zone is required.',
            field: 'timeZoneId',
          ),
        ],
      ),
      400,
    );
    final result = await repository.update(2, _draft);
    final failure = (result as Failed).failure;
    expect(failure.code, 'VALIDATION_ERROR');
    expect(failure.kind, FailureKind.validation);
    expect(failure.field, 'timeZoneId');
    expect(failure.serverMessage, 'Time zone is required.');
  });

  test('forbidden list maps ACCESS_DENIED to forbidden', () async {
    adapter.handler = (_) =>
        jsonResponse(_fixture('branches_forbidden.json'), 403);
    final result = await repository.list();
    final failure = (result as Failed).failure;
    expect(failure.code, 'ACCESS_DENIED');
    expect(failure.kind, FailureKind.forbidden);
  });

  test('invalid drafts never reach the transport', () async {
    final missingName = await repository.create(
      const BranchDraft(timeZoneId: 'Asia/Dubai'),
    );
    expect((missingName as Failed).failure.field, 'branchName');

    final longName = await repository.create(
      BranchDraft(branchName: 'x' * 101, timeZoneId: 'Asia/Dubai'),
    );
    expect((longName as Failed).failure.field, 'branchName');

    final missingTimeZone = await repository.create(
      const BranchDraft(branchName: 'Branch QA'),
    );
    expect((missingTimeZone as Failed).failure.field, 'timeZoneId');

    final invalidTimeZone = await repository.update(
      2,
      const BranchDraft(branchName: 'Branch QA', timeZoneId: 'not a timezone'),
    );
    expect((invalidTimeZone as Failed).failure.field, 'timeZoneId');

    expect(adapter.callCount, 0);
  });
}
