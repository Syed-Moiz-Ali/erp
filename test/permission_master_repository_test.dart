import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_permission_master_repository.dart';

import 'support/access_admin_fake.dart';

PermissionDto _dto({
  int id = 18,
  String key = 'hr.employees.view',
  String name = 'View employees',
  int statusId = 1,
}) => PermissionDto(
  permissionId: id,
  permissionKey: key,
  permissionName: name,
  statusId: statusId,
  status: statusId == 1 ? 'Active' : 'InActive',
);

void main() {
  late FakeAccessAdminRemoteDataSource data;
  late RemotePermissionMasterRepository repository;

  setUp(() {
    data = FakeAccessAdminRemoteDataSource();
    repository = RemotePermissionMasterRepository(data);
  });

  group('list', () {
    test('maps permission masters', () async {
      data.permissionsCatalog = [_dto()];
      final result = await repository.list();
      expect(result, isA<Success>());
      final page = (result as Success).value;
      expect(page.items.single.key, 'hr.employees.view');
      expect(page.items.single.isActive, isTrue);
      expect(page.totalItems, 1);
    });

    test('forwards paging, search, statusId and sort', () async {
      data.permissionsCatalog = [_dto()];
      await repository.list(
        search: 'hr',
        statusId: 1,
        sort: 'nameAsc',
        page: 3,
        pageSize: 5,
      );
      expect(data.lastPermissionsPage, 3);
      expect(data.lastPermissionsPageSize, 5);
      expect(data.lastPermissionsSearch, 'hr');
      expect(data.lastPermissionsStatusId, 1);
      expect(data.lastPermissionsSort, 'nameAsc');
    });

    test('defaults the backend sort to keyAsc', () async {
      await repository.list();
      expect(data.lastPermissionsSort, 'keyAsc');
    });
  });

  group('getById', () {
    test('loads a permission master', () async {
      data.permissionByIdResult = Success(_dto(name: 'Latest name'));
      final result = await repository.getById(18);
      expect(result, isA<Success>());
      expect((result as Success).value.name, 'Latest name');
    });

    test('reports PERMISSION_NOT_FOUND as notFound', () async {
      data.permissionByIdFailure = const Failure(
        code: 'PERMISSION_NOT_FOUND',
        kind: FailureKind.notFound,
      );
      final result = await repository.getById(999999);
      expect(result, isA<Failed>());
      final failure = (result as Failed).failure;
      expect(failure.code, 'PERMISSION_NOT_FOUND');
      expect(failure.kind, FailureKind.notFound);
    });
  });

  group('create', () {
    test('sends key, name and optional description', () async {
      data.createResult = Success(_dto());
      final result = await repository.create(
        key: 'hr.employees.view',
        name: 'View employees',
        description: 'See employees.',
      );
      expect(result, isA<Success>());
      expect(data.lastCreateBody, {
        'permissionKey': 'hr.employees.view',
        'permissionName': 'View employees',
        'description': 'See employees.',
      });
    });

    test('trims values and omits an empty description', () async {
      data.createResult = Success(_dto());
      await repository.create(
        key: ' hr.employees.view ',
        name: ' View employees ',
        description: '   ',
      );
      expect(data.lastCreateBody, {
        'permissionKey': 'hr.employees.view',
        'permissionName': 'View employees',
      });
    });

    test('rejects a missing name without a request', () async {
      final result = await repository.create(
        key: 'hr.employees.view',
        name: ' ',
      );
      expect(result, isA<Failed>());
      final failure = (result as Failed).failure;
      expect(failure.code, 'VALIDATION_ERROR');
      expect(failure.kind, FailureKind.validation);
      expect(failure.field, 'permissionName');
      expect(data.lastCreateBody, isNull);
    });

    final invalidKeys = <String>[
      '',
      '   ',
      'single',
      'hr employees view',
      'hr..employees',
      '.hr.employees',
      'hr.employees.',
      'hr.employees view',
      'hr.employees.view!',
      'a' * 101,
      'hr.${'a' * 98}.view',
    ];
    for (final key in invalidKeys) {
      test(
        'rejects invalid key ${key.length > 20 ? '>100 chars' : key}',
        () async {
          final result = await repository.create(key: key, name: 'Name');
          expect(result, isA<Failed>());
          final failure = (result as Failed).failure;
          expect(failure.code, 'VALIDATION_ERROR');
          expect(failure.kind, FailureKind.validation);
          expect(failure.field, 'permissionKey');
          expect(data.lastCreateBody, isNull);
        },
      );
    }

    test('accepts a 100 character key', () async {
      final key = '${'a' * 49}.${'b' * 50}';
      expect(key.length, 100);
      data.createResult = Success(_dto(key: key));
      final result = await repository.create(key: key, name: 'Name');
      expect(result, isA<Success>());
      expect(data.lastCreateBody?['permissionKey'], key);
    });
  });

  group('update', () {
    test('sends only supplied fields', () async {
      data.updateResult = Success(_dto(name: 'Renamed'));
      await repository.update(18, name: 'Renamed');
      expect(data.lastUpdateId, 18);
      expect(data.lastUpdateBody, {'permissionName': 'Renamed'});
    });

    test('sends key and description when supplied', () async {
      data.updateResult = Success(_dto());
      await repository.update(
        18,
        key: 'hr.employees.edit',
        description: ' Updated ',
      );
      expect(data.lastUpdateBody, {
        'permissionKey': 'hr.employees.edit',
        'description': 'Updated',
      });
    });

    test('validates a supplied non-empty key without a request', () async {
      final result = await repository.update(18, key: 'bad key');
      expect(result, isA<Failed>());
      final failure = (result as Failed).failure;
      expect(failure.code, 'VALIDATION_ERROR');
      expect(failure.kind, FailureKind.validation);
      expect(failure.field, 'permissionKey');
      expect(data.lastUpdateBody, isNull);
    });

    test('rejects an over-long supplied key without a request', () async {
      final result = await repository.update(18, key: 'a' * 101);
      expect(result, isA<Failed>());
      expect((result as Failed).failure.field, 'permissionKey');
      expect(data.lastUpdateBody, isNull);
    });

    test('treats a blank key as not supplied', () async {
      data.updateResult = Success(_dto());
      await repository.update(18, key: '   ', name: 'Renamed');
      expect(data.lastUpdateBody, {'permissionName': 'Renamed'});
    });
  });

  group('activate/deactivate', () {
    test('passes the requested state and id', () async {
      data.setActiveResult = Success(_dto());
      await repository.setActive(18, true);
      expect(data.lastActiveId, 18);
      expect(data.lastActive, isTrue);

      await repository.setActive(18, false);
      expect(data.lastActive, isFalse);
    });

    test('propagates PERMISSION_ALREADY_ACTIVE', () async {
      data.setActiveResult = const Failed(
        Failure(code: 'PERMISSION_ALREADY_ACTIVE', kind: FailureKind.conflict),
      );
      final result = await repository.setActive(18, true);
      final failure = (result as Failed).failure;
      expect(failure.code, 'PERMISSION_ALREADY_ACTIVE');
      expect(failure.kind, FailureKind.conflict);
    });

    test('propagates PERMISSION_ALREADY_INACTIVE', () async {
      data.setActiveResult = const Failed(
        Failure(
          code: 'PERMISSION_ALREADY_INACTIVE',
          kind: FailureKind.conflict,
        ),
      );
      final result = await repository.setActive(18, false);
      final failure = (result as Failed).failure;
      expect(failure.code, 'PERMISSION_ALREADY_INACTIVE');
      expect(failure.kind, FailureKind.conflict);
    });
  });

  group('error mapping', () {
    test('duplicate key becomes a field-aware conflict', () async {
      data.createResult = const Failed(
        Failure(code: 'PERMISSION_DUPLICATE_KEY', kind: FailureKind.unknown),
      );
      final result = await repository.create(key: 'x.y', name: 'X');
      final failure = (result as Failed).failure;
      expect(failure.code, 'PERMISSION_DUPLICATE_KEY');
      expect(failure.kind, FailureKind.conflict);
      expect(failure.field, 'permissionKey');
    });

    test('duplicate key keeps a backend-provided field', () async {
      data.createResult = const Failed(
        Failure(
          code: 'PERMISSION_DUPLICATE_KEY',
          kind: FailureKind.conflict,
          field: 'permissionKey',
          serverMessage: 'Key already exists.',
        ),
      );
      final result = await repository.create(key: 'x.y', name: 'X');
      final failure = (result as Failed).failure;
      expect(failure.field, 'permissionKey');
      expect(failure.serverMessage, 'Key already exists.');
    });

    test('VALIDATION_ERROR keeps code, kind and field', () async {
      data.createResult = const Failed(
        Failure(
          code: 'VALIDATION_ERROR',
          kind: FailureKind.validation,
          field: 'permissionName',
        ),
      );
      final result = await repository.create(key: 'x.y', name: 'X');
      final failure = (result as Failed).failure;
      expect(failure.code, 'VALIDATION_ERROR');
      expect(failure.kind, FailureKind.validation);
      expect(failure.field, 'permissionName');
    });

    test('403 ACCESS_DENIED stays forbidden', () async {
      data.createResult = const Failed(
        Failure(code: 'ACCESS_DENIED', kind: FailureKind.forbidden),
      );
      final result = await repository.create(key: 'x.y', name: 'X');
      expect((result as Failed).failure.kind, FailureKind.forbidden);
    });
  });
}
