import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

void main() {
  test('maps branch detail including IANA zone', () {
    final branch = BranchDto.fromJson(const {
      'branchId': 6,
      'branchName': 'QA Company',
      'branchCode': 'QA6',
      'status': 'Active',
      'divisionId': 1,
      'divisionName': 'Mass Technologies',
      'timeZoneId': 'Asia/Dubai',
      'inventoryAlerts': 'Yes',
      'multiInventory': 'No',
    }).toDomain();
    expect(branch.id, 6);
    expect(branch.name, 'QA Company');
    expect(branch.isActive, isTrue);
    expect(branch.timeZoneId, 'Asia/Dubai');
    expect(branch.divisionName, 'Mass Technologies');
  });

  test('create/update body always sends the required IANA time zone', () {
    const draft = BranchDraft(
      name: 'QA Company',
      timeZoneId: 'Asia/Dubai',
      divisionId: 1,
    );
    final body = branchBody(draft);
    expect(body['branchName'], 'QA Company');
    expect(body['timeZoneId'], 'Asia/Dubai');
    expect(body['divisionId'], 1);
    expect(body['status'], 'Active');
  });

  test('draft validation requires name and time zone', () {
    const draft = BranchDraft();
    final errors = draft.validate();
    expect(errors['branchName'], 'required');
    expect(errors['timeZoneId'], 'required');
  });
}
