import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

class BranchDto {
  const BranchDto(this.json);
  final Map<String, dynamic> json;

  factory BranchDto.fromJson(Map<String, dynamic> json) => BranchDto(json);

  Branch toDomain() => Branch(
    id: (json['branchId'] as num).toInt(),
    name: json['branchName'] as String? ?? '',
    status: json['status'] as String? ?? 'InActive',
    code: json['branchCode'] as String?,
    contactPerson: json['contactPerson'] as String?,
    mobileNo: json['mobileNo'] as String?,
    landLine: json['landLine'] as String?,
    address: json['address'] as String?,
    email: json['email'] as String?,
    inventoryAlerts: json['inventoryAlerts'] as String?,
    multiInventory: json['multiInventory'] as String?,
    divisionId: (json['divisionId'] as num?)?.toInt(),
    divisionName: json['divisionName'] as String?,
    timeZoneId: json['timeZoneId'] as String?,
    trn: json['trn'] as String?,
    logoPath: json['logoPath'] as String?,
    arabicLogoPath: json['arabicLogoPath'] as String?,
    labourCode: json['labourCode'] as String?,
    tradeLicense: json['tradeLicense'] as String?,
    createdBy: (json['createdBy'] as num?)?.toInt(),
    createdOn: _date(json['createdOn']),
    updatedBy: (json['updatedBy'] as num?)?.toInt(),
    updatedOn: _date(json['updatedOn']),
  );
}

Map<String, dynamic> branchBody(BranchDraft draft) => {
  'branchName': draft.name.trim(),
  'branchCode': _emptyToNull(draft.code),
  'contactPerson': _emptyToNull(draft.contactPerson),
  'mobileNo': _emptyToNull(draft.mobileNo),
  'landLine': _emptyToNull(draft.landLine),
  'address': _emptyToNull(draft.address),
  'email': _emptyToNull(draft.email),
  'inventoryAlerts': draft.inventoryAlerts,
  'multiInventory': draft.multiInventory,
  'divisionId': draft.divisionId,
  'status': draft.status,
  'timeZoneId': draft.timeZoneId,
};

String? _emptyToNull(String value) =>
    value.trim().isEmpty ? null : value.trim();

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
