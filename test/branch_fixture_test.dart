import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';

Map<String, dynamic> load(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> items(String path) {
  final data = load(path)['data'] as Map<String, dynamic>;
  return [
    for (final item in data['items'] as List)
      (item as Map).cast<String, dynamic>(),
  ];
}

void main() {
  test('branch list keeps paging, statuses and IANA zones', () {
    final envelope = load('test/fixtures/branches/branches_list.json');
    expect(envelope['message'], 'Companies retrieved.');
    final data = envelope['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 25);
    expect(data['totalItems'], 6);
    expect(data['totalPages'], 1);

    final branches = items(
      'test/fixtures/branches/branches_list.json',
    ).map(BranchDto.fromJson).map((dto) => dto.toDomain()).toList();
    expect(branches, hasLength(6));
    expect(branches.every((branch) => branch.timeZoneId != null), isTrue);
    expect(branches.any((branch) => !branch.isActive), isTrue);
    expect(branches.map((branch) => branch.id), contains(2));

    final filtered =
        load('test/fixtures/branches/branches_list_filtered.json')['data']
            as Map;
    expect(filtered['totalItems'], 5);
    expect((filtered['items'] as List), hasLength(5));
  });

  test('branch detail models creator/modifier and nullable extras', () {
    final dto = BranchDto.fromJson(
      (load('test/fixtures/branches/branch_detail.json')['data'] as Map).cast(),
    );
    final branch = dto.toDomain();
    expect(branch.id, 2);
    expect(branch.timeZoneId, 'Asia/Kolkata');
    expect(branch.divisionName, isNotNull);
    expect(branch.trn, isNull);
    expect(branch.logoPath, isNull);
    expect(branch.tradeLicense, isNull);
    expect(branch.createdBy, 8);
    expect(branch.createdOn, isNotNull);
    expect(branch.updatedBy, 8);
    expect(branch.updatedOn, isNotNull);
  });

  test('branch lookups expose IANA time zones and statuses', () {
    final data =
        load('test/fixtures/branches/branch_lookups.json')['data']
            as Map<String, dynamic>;
    expect(data['divisions'], isA<List>());
    expect(data['statuses'], containsAll(['Active', 'InActive']));
    expect(data['yesNo'], containsAll(['Yes', 'No']));
    final zones = data['timeZones'] as List;
    expect(zones, isNotEmpty);
    expect(
      zones.whereType<Map>().map((zone) => zone['id']),
      contains('Asia/Dubai'),
    );
    expect(
      zones.whereType<Map>().every((zone) => (zone['id'] as String).isNotEmpty),
      isTrue,
    );
  });

  test('branch 404 and employee 403 keep the error envelope', () {
    final notFound = load('test/fixtures/branches/branch_not_found.json');
    expect(notFound['success'], isFalse);
    expect((notFound['errors'] as List).single['code'], 'BRANCH_NOT_FOUND');
    final forbidden = load('test/fixtures/branches/branches_forbidden.json');
    expect(forbidden['success'], isFalse);
    expect((forbidden['errors'] as List).single['code'], 'ACCESS_DENIED');
  });

  test(
    'login branches equal the current branch list, while orgCount is larger',
    () {
      final login = load('test/fixtures/auth/login_admin_success.json');
      final user = (login['data'] as Map)['user'] as Map;
      final loginIds = {
        for (final branch in user['branches'] as List)
          (branch as Map)['orgId'] as int,
      };
      final listIds = {
        for (final branch in items('test/fixtures/branches/branches_list.json'))
          branch['branchId'] as int,
      };
      expect(loginIds, listIds);
      expect(user['orgCount'] as int, greaterThan(listIds.length));
    },
  );
}
