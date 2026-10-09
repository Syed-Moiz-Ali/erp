import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/departments/data/repositories/remote_department_repository.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_details_bloc.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_form_bloc.dart';
import 'package:modular_erp/modules/hr/departments/presentation/bloc/department_list_bloc.dart';

import 'support/department_test_doubles.dart';

void main() {
  late FakeDepartmentRemoteDataSource dataSource;
  late RemoteDepartmentRepository repository;
  final context = departmentAuthContext();

  setUp(() {
    dataSource = FakeDepartmentRemoteDataSource();
    repository = RemoteDepartmentRepository(dataSource);
  });

  tearDown(() => repository.dispose());

  test('list emits loading then the mapped data', () async {
    dataSource.onList = (page, pageSize, search) async => Success(
      departmentPage([departmentDto(2, 'accounts', employeeCount: 1)]),
    );
    final bloc = DepartmentListBloc(repository, context);
    addTearDown(bloc.close);
    bloc.add(const RecordListStarted());
    final state = await bloc.stream.firstWhere((s) => s.data != null);
    expect(state.data!.items.single.record.name, 'accounts');
    expect(state.loading, isFalse);
  });

  test('list surfaces an empty result distinctly from an error', () async {
    dataSource.onList = (page, pageSize, search) async =>
        Success(departmentPage(const []));
    final bloc = DepartmentListBloc(repository, context);
    addTearDown(bloc.close);
    bloc.add(const RecordListStarted());
    final state = await bloc.stream.firstWhere((s) => s.data != null);
    expect(state.data!.total, 0);
    expect(state.failure, isNull);
  });

  test('list surfaces a failure for retry', () async {
    dataSource.onList = (page, pageSize, search) async =>
        const Failed(Failure(code: 'offline', kind: FailureKind.offline));
    final bloc = DepartmentListBloc(repository, context);
    addTearDown(bloc.close);
    bloc.add(const RecordListStarted());
    final state = await bloc.stream.firstWhere((s) => s.failure != null);
    expect(state.failure!.kind, FailureKind.offline);
  });

  test('form create saves and reports the new id', () async {
    final bloc = DepartmentFormBloc(repository, context);
    addTearDown(bloc.close);
    bloc.add(const RecordFormInitialized<DepartmentDraft>());
    await bloc.stream.firstWhere((s) => s.ready);
    bloc.add(
      RecordDraftChanged<DepartmentDraft>((d) => d.copyWith(name: 'Finance')),
    );
    bloc.add(const RecordSubmitted<DepartmentDraft>());
    final state = await bloc.stream.firstWhere((s) => s.savedId != null);
    expect(state.savedId, isNotNull);
    expect(dataSource.createCalls, 1);
  });

  test('form validation blocks submission until the name is valid', () async {
    final bloc = DepartmentFormBloc(repository, context);
    addTearDown(bloc.close);
    bloc.add(const RecordFormInitialized<DepartmentDraft>());
    await bloc.stream.firstWhere((s) => s.ready);
    bloc.add(const RecordSubmitted<DepartmentDraft>());
    final state = await bloc.stream.firstWhere(
      (s) => s.validationRequested && s.fieldErrors.isNotEmpty,
    );
    expect(state.fieldErrors['name'], 'required');
    expect(state.savedId, isNull);
    expect(dataSource.createCalls, 0);
  });

  test('form shows the duplicate field error', () async {
    dataSource.onRename = (id, request) async => const Failed(
      Failure(code: 'DEPARTMENT_DUPLICATE_NAME', kind: FailureKind.conflict),
    );
    final bloc = DepartmentFormBloc(repository, context, id: '4');
    addTearDown(bloc.close);
    dataSource.onGet = (id) async => Success(departmentDto(4, 'Sales'));
    bloc.add(const RecordFormInitialized<DepartmentDraft>());
    await bloc.stream.firstWhere((s) => s.ready);
    bloc.add(
      RecordDraftChanged<DepartmentDraft>((d) => d.copyWith(name: 'dup')),
    );
    bloc.add(const RecordSubmitted<DepartmentDraft>());
    final state = await bloc.stream.firstWhere(
      (s) => s.fieldErrors['name'] == 'duplicateName',
    );
    expect(state.fieldErrors['name'], 'duplicateName');
  });

  test('details loads the record', () async {
    dataSource.onGet = (id) async =>
        Success(departmentDto(7, 'Operations', employeeCount: 4));
    final bloc = DepartmentDetailsBloc(repository, context, '7');
    addTearDown(bloc.close);
    bloc.add(const RecordDetailsStarted());
    final state = await bloc.stream.firstWhere((s) => s.detail != null);
    expect(state.detail!.record.name, 'Operations');
    expect(state.detail!.assignedEmployees, 4);
  });
}
