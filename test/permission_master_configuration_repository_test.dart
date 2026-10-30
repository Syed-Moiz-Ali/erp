import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_permission_master_repository.dart';
import 'package:modular_erp/platform/access/presentation/bloc/permission_catalog_form_bloc.dart';
import 'package:modular_erp/platform/access/presentation/permission_master_configuration_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

import 'support/access_admin_fake.dart';
import 'support/department_test_doubles.dart';

PermissionDto _dto({
  int id = 18,
  String key = 'company.access.users.view',
  String name = 'View access users',
  int statusId = 1,
  String? description = 'See company users and their access.',
}) => PermissionDto(
  permissionId: id,
  permissionKey: key,
  permissionName: name,
  statusId: statusId,
  description: description,
  status: statusId == 1 ? 'Active' : 'InActive',
  createdOn: DateTime.utc(2026, 1, 2),
  modifiedOn: DateTime.utc(2026, 1, 3),
);

AuthContext _context() => departmentAuthContext(
  permissions: const <AppPermission>{
    AppPermission.accessUsersView,
    AppPermission.accessPermissionsManage,
  },
);

void main() {
  late FakeAccessAdminRemoteDataSource data;
  late RemotePermissionMasterRepository repository;
  late PermissionMasterConfigurationRepository adapter;

  setUp(() {
    data = FakeAccessAdminRemoteDataSource();
    repository = RemotePermissionMasterRepository(data);
    adapter = PermissionMasterConfigurationRepository(repository);
  });

  tearDown(() => adapter.dispose());

  test('list maps paging, search, status and the record projection', () async {
    data.permissionsCatalog = [
      _dto(),
      _dto(id: 19, key: 'company.access.users.edit', name: 'Edit access users'),
      _dto(
        id: 20,
        key: 'company.access.users.view2',
        statusId: 2,
        description: null,
      ),
    ];

    final result = await adapter
        .watchList(
          _context(),
          query: ' company ',
          status: ConfigurationStatus.active,
          page: 0,
          pageSize: 5,
        )
        .first;

    final page =
        (result as Success<ConfigurationPageData<PermissionMasterRecord>>)
            .value;
    expect(page.total, 2);
    expect(page.filtered, 2);
    expect(page.items, hasLength(2));
    expect(page.items.first.assignedEmployees, 0);
    expect(page.items.first.record.id, '18');
    expect(page.items.first.record.name, 'View access users');
    expect(page.items.first.record.key, 'company.access.users.view');
    expect(page.items.first.record.status, ConfigurationStatus.active);
    expect(page.items.first.record.createdAt.toUtc(), DateTime.utc(2026, 1, 2));
    expect(page.items.first.record.updatedAt.toUtc(), DateTime.utc(2026, 1, 3));
    expect(
      page.items.first.record.toJson()['permissionKey'],
      'company.access.users.view',
    );
    expect(data.lastPermissionsPage, 1);
    expect(data.lastPermissionsPageSize, 5);
    expect(data.lastPermissionsSearch, 'company');
    expect(data.lastPermissionsStatusId, 1);
  });

  test('inactive filter sends statusId 2', () async {
    data.permissionsCatalog = [_dto(statusId: 2)];

    final result = await adapter
        .watchList(_context(), status: ConfigurationStatus.inactive)
        .first;

    expect(
      result,
      isA<Success<ConfigurationPageData<PermissionMasterRecord>>>(),
    );
    expect(data.lastPermissionsStatusId, 2);
    expect(data.lastPermissionsPage, 1);
  });

  test('missing detail becomes a safe null', () async {
    data.permissionByIdFailure = const Failure(
      code: 'PERMISSION_NOT_FOUND',
      kind: FailureKind.notFound,
    );

    final result = await adapter.watchDetails(_context(), '999').first;

    expect(result, isA<Success<ConfigurationItem<PermissionMasterRecord>?>>());
    expect(
      (result as Success<ConfigurationItem<PermissionMasterRecord>?>).value,
      isNull,
    );
  });

  test('detail projects the backend permission', () async {
    data.permissionsCatalog = [_dto()];

    final result = await adapter.watchDetails(_context(), '18').first;
    final item =
        (result as Success<ConfigurationItem<PermissionMasterRecord>?>).value!;

    expect(item.record.name, 'View access users');
    expect(item.record.key, 'company.access.users.view');
    expect(item.record.description, 'See company users and their access.');
  });

  test('create sends the normalized body', () async {
    data.createResult = Success(_dto());

    final result = await adapter.save(
      _context(),
      const PermissionMasterDraft(
        key: ' company.access.roles.view ',
        name: ' View roles ',
        description: ' See roles. ',
      ),
    );

    expect(result, isA<Success<PermissionMasterRecord>>());
    expect(data.lastCreateBody, {
      'permissionKey': 'company.access.roles.view',
      'permissionName': 'View roles',
      'description': 'See roles.',
    });
  });

  test('create inactive deactivates the new permission', () async {
    data.createResult = Success(_dto());
    data.setActiveResult = Success(_dto(statusId: 2));

    final result = await adapter.save(
      _context(),
      const PermissionMasterDraft(
        key: 'company.access.roles.view',
        name: 'View roles',
        status: ConfigurationStatus.inactive,
      ),
    );

    expect(result, isA<Success<PermissionMasterRecord>>());
    expect(
      (result as Success<PermissionMasterRecord>).value.status,
      ConfigurationStatus.inactive,
    );
    expect(data.lastActiveId, 18);
    expect(data.lastActive, isFalse);
  });

  test('invalid and over-long keys fail before any request', () async {
    final invalid = await adapter.save(
      _context(),
      const PermissionMasterDraft(key: 'bad key', name: 'Name'),
    );
    expect(invalid, isA<Failed<PermissionMasterRecord>>());
    expect(
      (invalid as Failed<PermissionMasterRecord>).failure.field,
      'permissionKey',
    );
    expect(invalid.failure.code, 'invalidPermissionKey');
    expect(data.lastCreateBody, isNull);

    final tooLong = await adapter.save(
      _context(),
      PermissionMasterDraft(key: '${'a' * 51}.${'b' * 50}', name: 'Name'),
    );
    expect(tooLong, isA<Failed<PermissionMasterRecord>>());
    expect(
      (tooLong as Failed<PermissionMasterRecord>).failure.code,
      'permissionKeyTooLong',
    );
    expect(data.lastCreateBody, isNull);
  });

  test('a missing name fails before any request', () async {
    final result = await adapter.save(
      _context(),
      const PermissionMasterDraft(key: 'company.access.roles.view', name: ' '),
    );

    expect(result, isA<Failed<PermissionMasterRecord>>());
    expect(
      (result as Failed<PermissionMasterRecord>).failure.field,
      'permissionName',
    );
    expect(result.failure.code, 'required');
    expect(data.lastCreateBody, isNull);
  });

  test('update refreshes first and only toggles a changed status', () async {
    data.permissionsCatalog = [_dto()];
    data.updateResult = Success(_dto(name: 'Renamed'));

    final result = await adapter.save(
      _context(),
      const PermissionMasterDraft(
        key: 'company.access.users.view',
        name: 'Renamed',
        description: 'Updated',
      ),
      id: '18',
    );

    expect(result, isA<Success<PermissionMasterRecord>>());
    expect(data.lastUpdateId, 18);
    expect(data.lastUpdateBody, {
      'permissionKey': 'company.access.users.view',
      'permissionName': 'Renamed',
      'description': 'Updated',
    });
    expect(data.lastActiveId, isNull);
  });

  test('update deactivates when the draft status changed', () async {
    data.permissionsCatalog = [_dto()];
    data.updateResult = Success(_dto());
    data.setActiveResult = Success(_dto(statusId: 2));

    final result = await adapter.save(
      _context(),
      const PermissionMasterDraft(
        key: 'company.access.users.view',
        name: 'View access users',
        status: ConfigurationStatus.inactive,
      ),
      id: '18',
    );

    expect(result, isA<Success<PermissionMasterRecord>>());
    expect(
      (result as Success<PermissionMasterRecord>).value.status,
      ConfigurationStatus.inactive,
    );
    expect(data.lastActiveId, 18);
    expect(data.lastActive, isFalse);
  });

  test('setActive forwards the requested state', () async {
    data.setActiveResult = Success(_dto(statusId: 2));

    final result = await adapter.setActive(_context(), '18', false);

    expect(result, isA<Success<void>>());
    expect(data.lastActiveId, 18);
    expect(data.lastActive, isFalse);
    expect(
      await adapter.assignedEmployeeCount(_context(), '18'),
      isA<Success<int>>(),
    );
  });

  test('duplicate keys and already-active conflicts stay conflicts', () async {
    data.createResult = const Failed(
      Failure(code: 'PERMISSION_DUPLICATE_KEY', kind: FailureKind.unknown),
    );
    final duplicate = await adapter.save(
      _context(),
      const PermissionMasterDraft(key: 'x.y', name: 'X'),
    );
    expect(duplicate, isA<Failed<PermissionMasterRecord>>());
    final duplicateFailure =
        (duplicate as Failed<PermissionMasterRecord>).failure;
    expect(duplicateFailure.kind, FailureKind.conflict);
    expect(duplicateFailure.field, 'permissionKey');

    data.setActiveResult = const Failed(
      Failure(code: 'PERMISSION_ALREADY_ACTIVE', kind: FailureKind.conflict),
    );
    final active = await adapter.setActive(_context(), '18', true);
    expect(active, isA<Failed<void>>());
    expect((active as Failed<void>).failure.code, 'PERMISSION_ALREADY_ACTIVE');
    expect(active.failure.kind, FailureKind.conflict);
  });

  test('form bloc maps duplicate keys onto the permission key field', () async {
    data.createResult = const Failed(
      Failure(code: 'PERMISSION_DUPLICATE_KEY', kind: FailureKind.unknown),
    );
    final bloc = PermissionCatalogFormBloc(adapter, _context());
    addTearDown(bloc.close);

    final ready = bloc.stream.firstWhere((state) => state.ready);
    bloc.add(const RecordFormInitialized<PermissionMasterDraft>());
    await ready;

    bloc.add(const RecordDraftChanged<PermissionMasterDraft>(_validDraft));
    final failed = bloc.stream.firstWhere((state) => state.failure != null);
    bloc.add(const RecordSubmitted<PermissionMasterDraft>());
    final state = await failed;

    expect(state.fieldErrors['permissionKey'], 'duplicatePermissionKey');
  });
}

PermissionMasterDraft _validDraft(PermissionMasterDraft draft) =>
    draft.copyWith(key: 'company.access.roles.view', name: 'View roles');
