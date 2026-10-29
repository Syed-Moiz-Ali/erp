import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/branches/data/branch_mapper.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('test/fixtures/branches/$name').readAsStringSync())
        as Map<String, dynamic>;

List<Map<String, dynamic>> items(String name) {
  final data = load(name)['data'] as Map<String, dynamic>;
  return [
    for (final item in data['items'] as List)
      (item as Map).cast<String, dynamic>(),
  ];
}

void main() {
  test('list fixture keeps paging and maps every row', () {
    final data = load('branches_list.json')['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 25);
    expect(data['totalItems'], 6);
    expect(data['totalPages'], 1);

    final rows = items(
      'branches_list.json',
    ).map(BranchDto.fromJson).map(BranchMapper.toDomain).toList();
    expect(rows, hasLength(6));

    final first = rows.firstWhere((row) => row.branchId == 2);
    expect(first.branchName, 'Branch 2');
    expect(first.branchCode, 'BT');
    expect(first.contactPerson, 'Sanitized Name');
    expect(first.mobileNo, 'SANITIZED_MOBILE');
    expect(first.landLine, 'SANITIZED_MOBILE');
    expect(first.address, 'Sanitized Address');
    expect(first.email, 'sanitized@example.com');
    expect(first.inventoryAlerts, 'Yes');
    expect(first.multiInventory, 'Yes');
    expect(first.divisionId, 1);
    expect(first.divisionName, 'Mass Technologies');
    expect(first.statusId, 1);
    expect(first.status, 'Active');
    expect(first.timeZoneId, 'Asia/Kolkata');
    expect(first.isActive, isTrue);
    expect(first.branchStatus, BranchStatus.active);

    final inactive = rows.firstWhere((row) => row.branchId == 6);
    expect(inactive.status, 'InActive');
    expect(inactive.statusId, 2);
    expect(inactive.isActive, isFalse);
    expect(inactive.branchStatus, BranchStatus.inactive);
  });

  test('filtered list fixture keeps the requested page size', () {
    final data =
        load('branches_list_filtered.json')['data'] as Map<String, dynamic>;
    expect(data['page'], 1);
    expect(data['pageSize'], 5);
    expect(data['totalItems'], 5);
    expect(data['totalPages'], 1);

    final rows = items(
      'branches_list_filtered.json',
    ).map(BranchDto.fromJson).map(BranchMapper.toDomain).toList();
    expect(rows, hasLength(5));
    expect(rows.every((row) => row.status == 'Active'), isTrue);
  });

  test('detail fixture maps the IANA time zone', () {
    final dto = BranchDto.fromJson(
      (load('branch_detail.json')['data'] as Map).cast<String, dynamic>(),
    );
    final branch = BranchMapper.toDomain(dto);
    expect(branch.branchId, 2);
    expect(branch.branchName, 'Branch 2');
    expect(branch.timeZoneId, 'Asia/Kolkata');
    expect(branch.status, 'Active');
  });

  test('lookups fixture maps divisions, statuses, yes/no and time zones', () {
    final dto = BranchLookupsDto.fromJson(
      (load('branch_lookups.json')['data'] as Map).cast<String, dynamic>(),
    );
    final lookups = BranchMapper.toLookups(dto);

    expect(lookups.divisions.single.id, 1);
    expect(lookups.divisions.single.name, 'Sanitized Name');
    expect(lookups.statuses, ['Active', 'InActive']);
    expect(lookups.yesNo, ['Yes', 'No']);
    expect(lookups.timeZones, isNotEmpty);
    expect(lookups.timeZones.first.id, 'Etc/GMT+12');
    expect(lookups.timeZones.first.utcOffset, '-12:00');
    expect(
      lookups.timeZones.any((timeZone) => timeZone.id == 'Asia/Kolkata'),
      isTrue,
    );
    expect(
      lookups.timeZones.every(
        (timeZone) =>
            timeZone.id.isNotEmpty &&
            timeZone.name.isNotEmpty &&
            timeZone.utcOffset.isNotEmpty,
      ),
      isTrue,
    );
  });

  test('not found envelope keeps BRANCH_NOT_FOUND', () {
    final envelope = load('branch_not_found.json');
    expect(envelope['success'], isFalse);
    expect(envelope['data'], isNull);
    final error = (envelope['errors'] as List).single as Map;
    expect(error['code'], 'BRANCH_NOT_FOUND');
    expect(error['message'], 'Company not found.');
  });

  test('forbidden envelope keeps ACCESS_DENIED', () {
    final envelope = load('branches_forbidden.json');
    expect(envelope['success'], isFalse);
    expect(envelope['data'], isNull);
    final error = (envelope['errors'] as List).single as Map;
    expect(error['code'], 'ACCESS_DENIED');
  });
}
