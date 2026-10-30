import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/presentation/branch_configuration_repository.dart';
import 'package:modular_erp/modules/hr/branches/presentation/bloc/branch_form_bloc.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

import 'support/branch_test_doubles.dart';
import 'support/department_test_doubles.dart';

Branch branch({
  int id = 1,
  String name = 'Head Office',
  String? code = 'BR-1',
  int statusId = 1,
  String status = 'Active',
  String timeZoneId = 'Asia/Dubai',
  int? divisionId = 1,
  String? divisionName = 'Division 1',
}) => Branch(
  branchId: id,
  branchName: name,
  branchCode: code,
  contactPerson: 'Contact',
  mobileNo: '000',
  landLine: '111',
  address: 'Address',
  email: 'branch@example.test',
  inventoryAlerts: 'Yes',
  multiInventory: 'No',
  divisionId: divisionId,
  divisionName: divisionName,
  statusId: statusId,
  status: status,
  timeZoneId: timeZoneId,
);

AuthContext context() => departmentAuthContext(
  permissions: const <AppPermission>{
    AppPermission.companyBranchView,
    AppPermission.companyBranchManage,
  },
);

void main() {
  test('list maps paging, search, status and the record projection', () async {
    final repository = InMemoryBranchRepository(
      branches: [
        branch(id: 1, name: 'Head Office'),
        branch(id: 2, name: 'Warehouse', statusId: 2, status: 'InActive'),
      ],
    );
    final adapter = BranchConfigurationRepository(repository);
    addTearDown(adapter.dispose);

    final result = await adapter
        .watchList(
          context(),
          query: 'Head',
          status: ConfigurationStatus.active,
          page: 1,
          pageSize: 25,
        )
        .first;

    final page = (result as Success<ConfigurationPageData<BranchRecord>>).value;
    expect(page.items, hasLength(1));
    expect(page.items.single.assignedEmployees, 0);
    expect(page.items.single.record.id, '1');
    expect(page.items.single.record.name, 'Head Office');
    expect(page.items.single.record.status, ConfigurationStatus.active);
    expect(
      page.items.single.record.createdAt.toUtc(),
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
    expect(repository.lastSearch, 'Head');
    expect(repository.lastStatus, BranchStatus.active);
    expect(repository.lastPage, 2);
    expect(repository.lastPageSize, 25);
  });

  test('inactive records project the inactive status', () async {
    final adapter = BranchConfigurationRepository(
      InMemoryBranchRepository(
        branches: [branch(id: 2, statusId: 2, status: 'InActive')],
      ),
    );
    addTearDown(adapter.dispose);

    final result = await adapter.watchDetails(context(), '2').first;
    final item = (result as Success<ConfigurationItem<BranchRecord>?>).value!;
    expect(item.record.status, ConfigurationStatus.inactive);
  });

  test('missing detail becomes a safe null', () async {
    final adapter = BranchConfigurationRepository(InMemoryBranchRepository());
    addTearDown(adapter.dispose);

    final result = await adapter.watchDetails(context(), '999').first;
    expect(result, isA<Success<ConfigurationItem<BranchRecord>?>>());
    expect((result as Success<ConfigurationItem<BranchRecord>?>).value, isNull);
  });

  test(
    'save validates before writing and supports create and update',
    () async {
      final repository = InMemoryBranchRepository(branches: [branch()]);
      final adapter = BranchConfigurationRepository(repository);
      addTearDown(adapter.dispose);

      final invalid = await adapter.save(
        context(),
        const BranchDraft(branchName: '   ', timeZoneId: 'Asia/Dubai'),
      );
      expect(invalid, isA<Failed<BranchRecord>>());
      expect((invalid as Failed<BranchRecord>).failure.code, 'required');
      expect(repository.createCalls, 0);

      final created = await adapter.save(
        context(),
        const BranchDraft(
          branchName: 'New Branch',
          timeZoneId: 'Asia/Kolkata',
          divisionId: 2,
          status: BranchStatus.active,
        ),
      );
      expect(created, isA<Success<BranchRecord>>());
      expect((created as Success<BranchRecord>).value.id, '2');
      expect(repository.createCalls, 1);
      expect(repository.lastCreate!.timeZoneId, 'Asia/Kolkata');

      final updated = await adapter.save(
        context(),
        const BranchDraft(
          branchName: 'Head Office Updated',
          timeZoneId: 'Asia/Dubai',
          status: BranchStatus.inactive,
        ),
        id: '1',
      );
      expect(updated, isA<Success<BranchRecord>>());
      final updatedRecord = (updated as Success<BranchRecord>).value;
      expect(updatedRecord.name, 'Head Office Updated');
      expect(updatedRecord.status, ConfigurationStatus.inactive);
      expect(repository.updateCalls, 1);
      expect(repository.lastUpdateId, 1);
    },
  );

  test('successful writes re-fetch active watchers', () async {
    final repository = InMemoryBranchRepository(branches: [branch()]);
    final adapter = BranchConfigurationRepository(repository);
    addTearDown(adapter.dispose);

    final values = <int>[];
    final subscription = adapter.watchList(context()).listen((result) {
      if (result is Success<ConfigurationPageData<BranchRecord>>) {
        values.add(result.value.filtered);
      }
    });
    addTearDown(subscription.cancel);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await adapter.save(
      context(),
      const BranchDraft(branchName: 'Second', timeZoneId: 'Asia/Dubai'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(values, [1, 2]);
  });

  test('setActive calls the repository and bumps the revision', () async {
    final repository = InMemoryBranchRepository(branches: [branch()]);
    final adapter = BranchConfigurationRepository(repository);
    addTearDown(adapter.dispose);

    final result = await adapter.setActive(context(), '1', false);
    expect(result, isA<Success<void>>());
    expect(repository.deactivateCalls, 1);
    expect(repository.lastActiveId, 1);
    expect(repository.lastActive, isFalse);
  });

  test('form bloc surfaces the invalid time zone field', () async {
    final adapter = BranchConfigurationRepository(InMemoryBranchRepository());
    addTearDown(adapter.dispose);
    final bloc = BranchFormBloc(adapter, context());
    addTearDown(bloc.close);

    final ready = bloc.stream.firstWhere((state) => state.ready);
    bloc.add(const RecordFormInitialized<BranchDraft>());
    await ready;
    bloc.add(
      RecordDraftChanged<BranchDraft>(
        (draft) =>
            draft.copyWith(branchName: 'Branch', timeZoneId: 'Not/AZone!'),
      ),
    );
    bloc.add(const RecordSubmitted<BranchDraft>());
    final state = await bloc.stream.firstWhere(
      (state) => state.fieldErrors.isNotEmpty,
    );
    expect(state.fieldErrors['timeZoneId'], 'invalidTimeZone');
  });
}
