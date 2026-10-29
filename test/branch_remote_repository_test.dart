import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/data/repositories/remote_branch_repository.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

import 'support/branch_test_doubles.dart';

const _draft = BranchDraft(
  branchName: 'Branch QA',
  branchCode: 'QA-1',
  divisionId: 1,
  status: BranchStatus.active,
  timeZoneId: 'Asia/Dubai',
);

void main() {
  late FakeBranchRemoteDataSource dataSource;
  late RemoteBranchRepository repository;

  setUp(() {
    dataSource = FakeBranchRemoteDataSource();
    repository = RemoteBranchRepository(dataSource);
  });

  test('list forwards every filter and keeps the server paging', () async {
    dataSource.onList =
        (search, status, divisionId, sort, page, pageSize) async => Success(
          branchPage(
            [branchDto(branchId: 1), branchDto(branchId: 2)],
            page: 2,
            pageSize: 5,
            totalItems: 12,
            totalPages: 3,
          ),
        );

    final result = await repository.list(
      search: 'Branch',
      status: BranchStatus.inactive,
      divisionId: 1,
      sort: 'nameAsc',
      page: 2,
      pageSize: 5,
    );

    expect(result, isA<Success<BranchPage>>());
    final page = (result as Success<BranchPage>).value;
    expect(page.items, hasLength(2));
    expect(page.page, 2);
    expect(page.pageSize, 5);
    expect(page.totalItems, 12);
    expect(page.totalPages, 3);
    expect(page.hasMore, isTrue);

    expect(dataSource.lastSearch, 'Branch');
    expect(dataSource.lastStatus, BranchStatus.inactive);
    expect(dataSource.lastDivisionId, 1);
    expect(dataSource.lastSort, 'nameAsc');
    expect(dataSource.lastPage, 2);
    expect(dataSource.lastPageSize, 5);
  });

  test('list defaults to page 1 and pageSize 25 with no filters', () async {
    await repository.list();
    expect(dataSource.lastSearch, isNull);
    expect(dataSource.lastStatus, isNull);
    expect(dataSource.lastDivisionId, isNull);
    expect(dataSource.lastSort, isNull);
    expect(dataSource.lastPage, 1);
    expect(dataSource.lastPageSize, 25);
  });

  test('lookups maps the payload', () async {
    dataSource.onLookups = () async => Success(
      const BranchLookupsDto(
        divisions: [BranchLookupOptionDto(id: 1, name: 'Division')],
        statuses: ['Active', 'InActive'],
        yesNo: ['Yes', 'No'],
        timeZones: [
          BranchTimeZoneDto(
            id: 'Asia/Dubai',
            name: 'Dubai',
            utcOffset: '+04:00',
          ),
        ],
      ),
    );
    final result = await repository.lookups();
    final lookups = (result as Success<BranchLookups>).value;
    expect(lookups.divisions.single.name, 'Division');
    expect(lookups.statuses, ['Active', 'InActive']);
    expect(lookups.timeZones.single.id, 'Asia/Dubai');
    expect(dataSource.lookupsCalls, 1);
  });

  test('getById maps a successful detail', () async {
    dataSource.onGet = (id) async =>
        Success(branchDto(branchId: id, branchName: 'Branch Ops'));
    final result = await repository.getById(7);
    expect((result as Success<Branch>).value.branchName, 'Branch Ops');
    expect(dataSource.lastGetId, 7);
  });

  test('create sends validated documented fields', () async {
    final result = await repository.create(_draft);
    expect(result, isA<Success<Branch>>());
    expect(dataSource.createCalls, 1);
    expect(dataSource.lastCreate!.toJson(), {
      'branchName': 'Branch QA',
      'branchCode': 'QA-1',
      'divisionId': 1,
      'status': 'Active',
      'timeZoneId': 'Asia/Dubai',
    });
  });

  test(
    'update sends the same body without inventing optional fields',
    () async {
      await repository.update(
        5,
        const BranchDraft(
          branchName: ' Branch QA ',
          timeZoneId: ' Asia/Kolkata ',
        ),
      );
      expect(dataSource.lastUpdateId, 5);
      expect(dataSource.lastUpdate!.toJson(), {
        'branchName': 'Branch QA',
        'timeZoneId': 'Asia/Kolkata',
      });
    },
  );

  test('setActive selects activate and deactivate', () async {
    await repository.setActive(6, true);
    expect(dataSource.activateCalls, 1);
    expect(dataSource.lastActivateId, 6);

    await repository.setActive(6, false);
    expect(dataSource.deactivateCalls, 1);
    expect(dataSource.lastDeactivateId, 6);
  });

  test('documented errors map to stable kinds', () async {
    final cases = <String, FailureKind>{
      'BRANCH_DUPLICATE_NAME': FailureKind.conflict,
      'BRANCH_ALREADY_ACTIVE': FailureKind.conflict,
      'BRANCH_ALREADY_INACTIVE': FailureKind.conflict,
      'VALIDATION_ERROR': FailureKind.validation,
      'BRANCH_NOT_FOUND': FailureKind.notFound,
      'ACCESS_DENIED': FailureKind.forbidden,
    };

    for (final entry in cases.entries) {
      dataSource.onUpdate = (_, _) async => Failed(
        Failure(
          code: entry.key,
          kind: FailureKind.unknown,
          serverMessage: 'Safe server message.',
        ),
      );
      final result = await repository.update(5, _draft);
      final failure = (result as Failed).failure;
      expect(failure.code, entry.key);
      expect(failure.kind, entry.value);
      expect(failure.serverMessage, 'Safe server message.');
    }
  });

  test('duplicate name maps to the branchName field', () async {
    dataSource.onCreate = (_) async => const Failed(
      Failure(code: 'BRANCH_DUPLICATE_NAME', kind: FailureKind.unknown),
    );
    final result = await repository.create(_draft);
    final failure = (result as Failed).failure;
    expect(failure.kind, FailureKind.conflict);
    expect(failure.field, 'branchName');
  });

  test('already active or inactive is not silent success', () async {
    dataSource.onActivate = (_) async => const Failed(
      Failure(code: 'BRANCH_ALREADY_ACTIVE', kind: FailureKind.unknown),
    );
    expect(
      (await repository.setActive(6, true) as Failed).failure.kind,
      FailureKind.conflict,
    );

    dataSource.onDeactivate = (_) async => const Failed(
      Failure(code: 'BRANCH_ALREADY_INACTIVE', kind: FailureKind.unknown),
    );
    expect(
      (await repository.setActive(6, false) as Failed).failure.kind,
      FailureKind.conflict,
    );
  });

  test('client validation rejects invalid drafts without a request', () async {
    final missingName = await repository.create(
      const BranchDraft(timeZoneId: 'Asia/Dubai'),
    );
    final nameFailure = (missingName as Failed).failure;
    expect(nameFailure.kind, FailureKind.validation);
    expect(nameFailure.code, 'required');
    expect(nameFailure.field, 'branchName');

    final longName = await repository.create(
      BranchDraft(branchName: 'x' * 101, timeZoneId: 'Asia/Dubai'),
    );
    final longFailure = (longName as Failed).failure;
    expect(longFailure.kind, FailureKind.validation);
    expect(longFailure.code, 'tooLong');
    expect(longFailure.field, 'branchName');

    final missingTimeZone = await repository.create(
      const BranchDraft(branchName: 'Branch QA'),
    );
    final timeZoneFailure = (missingTimeZone as Failed).failure;
    expect(timeZoneFailure.kind, FailureKind.validation);
    expect(timeZoneFailure.code, 'required');
    expect(timeZoneFailure.field, 'timeZoneId');

    final invalidTimeZone = await repository.update(
      5,
      const BranchDraft(branchName: 'Branch QA', timeZoneId: 'Not/AZone!'),
    );
    final invalidFailure = (invalidTimeZone as Failed).failure;
    expect(invalidFailure.kind, FailureKind.validation);
    expect(invalidFailure.code, 'invalidTimeZone');
    expect(invalidFailure.field, 'timeZoneId');

    expect(dataSource.createCalls, 0);
    expect(dataSource.updateCalls, 0);
  });

  test('status values map to the documented wire strings', () {
    expect(BranchStatus.active.wire, 'Active');
    expect(BranchStatus.inactive.wire, 'InActive');
    expect(BranchStatus.fromWire('InActive'), BranchStatus.inactive);
    expect(BranchStatus.fromWire('Active'), BranchStatus.active);
    expect(BranchStatus.fromWireOrNull('Other'), isNull);
  });
}
