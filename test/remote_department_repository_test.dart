import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/departments/data/datasources/dio_department_remote_data_source.dart';
import 'package:modular_erp/modules/hr/departments/data/repositories/remote_department_repository.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_form_bloc.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

import 'support/api_test_harness.dart';
import 'support/memory_session_storage.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(
          File('test/fixtures/departments/$name').readAsStringSync(),
        )
        as Map<String, dynamic>;

AuthContext context() => AuthContext(
  user: UserAccount(
    id: '8',
    displayName: 'Admin',
    email: 'admin',
    companyId: '3',
    permissions: PermissionSet(const <AppPermission>[
      AppPermission.departmentView,
      AppPermission.departmentManage,
    ]),
    status: AccountStatus.active,
  ),
  company: const CompanyContext(
    id: '3',
    name: 'Company',
    code: 'ORG-3',
    timezone: 'Asia/Dubai',
    defaultLocale: 'en',
    enabledModules: {'settings'},
  ),
);

void main() {
  late FakeDioAdapter adapter;
  late ApiClient client;
  late RemoteDepartmentRepository repository;

  setUp(() {
    adapter = FakeDioAdapter(
      (_) => jsonResponse(fixture('departments_list.json'), 200),
    );
    client = buildClient(adapter: adapter, storage: MemorySessionStorage());
    repository = RemoteDepartmentRepository(
      DioDepartmentRemoteDataSource(client),
    );
  });

  tearDown(() async {
    await repository.dispose();
    client.close();
  });

  test('list decodes the live fixture with paging and search', () async {
    final result = await repository
        .watchList(context(), query: 'Department', pageSize: 25)
        .first;

    expect(result, isA<Success<ConfigurationPageData<Department>>>());
    final page = (result as Success<ConfigurationPageData<Department>>).value;
    expect(page.items, hasLength(5));
    expect(page.total, 5);
    expect(page.items.first.record.id, '2');
    expect(page.items.first.record.name, 'Department 2');
    expect(page.items.first.assignedEmployees, 4);
    expect(adapter.last.uri.path, '/api/departments');
    expect(adapter.last.uri.queryParameters['page'], '1');
    expect(adapter.last.uri.queryParameters['pageSize'], '25');
    expect(adapter.last.uri.queryParameters['sort'], 'nameAsc');
    expect(adapter.last.uri.queryParameters['search'], 'Department');
  });

  test('filtered list keeps the fixture paging totals', () async {
    adapter.handler = (_) => jsonResponse(
      fixture('departments_list_filtered.json'),
      200,
    );
    final result = await repository
        .watchList(context(), query: 'Department', pageSize: 5)
        .first;

    final page = (result as Success<ConfigurationPageData<Department>>).value;
    expect(page.items, hasLength(4));
    expect(page.total, 4);
    expect(adapter.last.uri.queryParameters['pageSize'], '5');
  });

  test('detail maps the live fixture without timestamps or metadata', () async {
    adapter.handler = (_) =>
        jsonResponse(fixture('department_detail.json'), 200);
    final result = await repository.watchDetails(context(), '2').first;

    expect(result, isA<Success<ConfigurationItem<Department>?>>());
    final item = (result as Success<ConfigurationItem<Department>?>).value!;
    expect(item.record.id, '2');
    expect(item.record.name, 'Department 2');
    expect(item.assignedEmployees, 4);
    expect(item.record.status, ConfigurationStatus.active);
    expect(item.record.syncStatus, RecordSyncStatus.synced);
    expect(item.record.createdAt.toUtc(), DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
    expect(item.record.updatedAt.toUtc(), DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
  });

  test('404 detail becomes a safe null, not an error', () async {
    adapter.handler = (_) => jsonResponse(
      fixture('department_not_found.json'),
      404,
    );
    final result = await repository.getById(context(), '999');
    expect(result, isA<Success<Department?>>());
    expect((result as Success<Department?>).value, isNull);
  });

  test('403 negative fails closed with forbidden', () async {
    adapter.handler = (_) =>
        jsonResponse(fixture('departments_forbidden.json'), 403);
    final result = await repository.watchList(context()).first;
    expect(result, isA<Failed<ConfigurationPageData<Department>>>());
    expect(
      (result as Failed<ConfigurationPageData<Department>>).failure.kind,
      FailureKind.forbidden,
    );
  });

  test('duplicate 400 maps to the name field on the form bloc', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Duplicate department name.',
        errors: [
          errorEntry(
            'DEPARTMENT_DUPLICATE_NAME',
            message: 'Duplicate department name.',
            field: 'departmentName',
          ),
        ],
      ),
      400,
    );

    final bloc = DepartmentFormBloc(repository, context());
    addTearDown(bloc.close);
    final ready = bloc.stream.firstWhere((state) => state.ready);
    bloc.add(const RecordFormInitialized<DepartmentDraft>());
    await ready;

    final failed = bloc.stream.firstWhere(
      (state) => state.fieldErrors.isNotEmpty,
    );
    bloc.add(
      RecordDraftChanged<DepartmentDraft>(
        (draft) => draft.copyWith(name: 'Department 2'),
      ),
    );
    bloc.add(const RecordSubmitted<DepartmentDraft>());
    final state = await failed;

    expect(state.fieldErrors['name'], 'duplicateName');
  });

  test('duplicate name on 409 also maps to the name field', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Duplicate department name.',
        errors: [
          errorEntry(
            'DEPARTMENT_DUPLICATE_NAME',
            message: 'Duplicate department name.',
            field: 'departmentName',
          ),
        ],
      ),
      409,
    );
    final result = await repository.save(
      context(),
      const DepartmentDraft(name: 'Department 2'),
    );
    expect(result, isA<Failed<Department>>());
    final failure = (result as Failed<Department>).failure;
    expect(failure.code, 'duplicateName');
    expect(failure.field, 'departmentName');
    expect(failure.kind, FailureKind.validation);
  });
  test('in-use 409 keeps the conflict mapping', () async {
    adapter.handler = (_) => jsonResponse(
      envelope(
        success: false,
        message: 'Department is in use.',
        errors: [
          errorEntry('DEPARTMENT_IN_USE', message: 'Department is in use.'),
        ],
      ),
      409,
    );
    final result = await repository.setActive(context(), '2', false);
    expect(result, isA<Failed<void>>());
    final failure = (result as Failed<void>).failure;
    expect(failure.code, 'inUse');
    expect(failure.kind, FailureKind.conflict);
  });
}
