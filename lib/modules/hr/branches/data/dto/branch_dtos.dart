class BranchDto {
  const BranchDto({
    required this.branchId,
    required this.branchName,
    this.branchCode,
    this.contactPerson,
    this.mobileNo,
    this.landLine,
    this.address,
    this.email,
    this.inventoryAlerts,
    this.multiInventory,
    this.divisionId,
    this.divisionName,
    this.statusId,
    this.status = '',
    this.timeZoneId = '',
  });

  final int branchId;
  final String branchName;
  final String? branchCode;
  final String? contactPerson;
  final String? mobileNo;
  final String? landLine;
  final String? address;
  final String? email;
  final String? inventoryAlerts;
  final String? multiInventory;
  final int? divisionId;
  final String? divisionName;
  final int? statusId;
  final String status;
  final String timeZoneId;

  factory BranchDto.fromJson(Map<String, dynamic> json) => BranchDto(
    branchId: _int(json['branchId']),
    branchName: json['branchName'] as String? ?? '',
    branchCode: _stringOrNull(json['branchCode']),
    contactPerson: _stringOrNull(json['contactPerson']),
    mobileNo: _stringOrNull(json['mobileNo']),
    landLine: _stringOrNull(json['landLine']),
    address: _stringOrNull(json['address']),
    email: _stringOrNull(json['email']),
    inventoryAlerts: _stringOrNull(json['inventoryAlerts']),
    multiInventory: _stringOrNull(json['multiInventory']),
    divisionId: _intOrNull(json['divisionId']),
    divisionName: _stringOrNull(json['divisionName']),
    statusId: _intOrNull(json['statusId']),
    status: json['status'] as String? ?? '',
    timeZoneId: json['timeZoneId'] as String? ?? '',
  );
}

class BranchUpsertDto {
  const BranchUpsertDto({
    required this.branchName,
    required this.timeZoneId,
    this.branchCode,
    this.contactPerson,
    this.mobileNo,
    this.landLine,
    this.address,
    this.email,
    this.inventoryAlerts,
    this.multiInventory,
    this.divisionId,
    this.status,
  });

  final String branchName;
  final String timeZoneId;
  final String? branchCode;
  final String? contactPerson;
  final String? mobileNo;
  final String? landLine;
  final String? address;
  final String? email;
  final String? inventoryAlerts;
  final String? multiInventory;
  final int? divisionId;
  final String? status;

  Map<String, dynamic> toJson() => {
    'branchName': branchName.trim(),
    if (_hasValue(branchCode)) 'branchCode': branchCode!.trim(),
    if (_hasValue(contactPerson)) 'contactPerson': contactPerson!.trim(),
    if (_hasValue(mobileNo)) 'mobileNo': mobileNo!.trim(),
    if (_hasValue(landLine)) 'landLine': landLine!.trim(),
    if (_hasValue(address)) 'address': address!.trim(),
    if (_hasValue(email)) 'email': email!.trim(),
    if (_hasValue(inventoryAlerts)) 'inventoryAlerts': inventoryAlerts!.trim(),
    if (_hasValue(multiInventory)) 'multiInventory': multiInventory!.trim(),
    if (divisionId != null) 'divisionId': divisionId,
    if (_hasValue(status)) 'status': status!.trim(),
    'timeZoneId': timeZoneId.trim(),
  };
}

class BranchLookupOptionDto {
  const BranchLookupOptionDto({required this.id, required this.name});

  final int id;
  final String name;

  factory BranchLookupOptionDto.fromJson(Map<String, dynamic> json) =>
      BranchLookupOptionDto(
        id: _int(json['id']),
        name: json['name'] as String? ?? '',
      );
}

class BranchTimeZoneDto {
  const BranchTimeZoneDto({
    required this.id,
    required this.name,
    required this.utcOffset,
  });

  final String id;
  final String name;
  final String utcOffset;

  factory BranchTimeZoneDto.fromJson(Map<String, dynamic> json) =>
      BranchTimeZoneDto(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        utcOffset: json['utcOffset'] as String? ?? '',
      );
}

class BranchLookupsDto {
  const BranchLookupsDto({
    required this.divisions,
    required this.statuses,
    required this.yesNo,
    required this.timeZones,
  });

  final List<BranchLookupOptionDto> divisions;
  final List<String> statuses;
  final List<String> yesNo;
  final List<BranchTimeZoneDto> timeZones;

  factory BranchLookupsDto.fromJson(Map<String, dynamic> json) =>
      BranchLookupsDto(
        divisions: _list(
          json['divisions'],
          (item) => BranchLookupOptionDto.fromJson(item),
        ),
        statuses: _strings(json['statuses']),
        yesNo: _strings(json['yesNo']),
        timeZones: _list(
          json['timeZones'],
          (item) => BranchTimeZoneDto.fromJson(item),
        ),
      );
}

int _int(dynamic value) => (value as num?)?.toInt() ?? 0;

int? _intOrNull(dynamic value) => (value as num?)?.toInt();

String? _stringOrNull(dynamic value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) decode) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map) decode(item.cast<String, dynamic>()),
  ];
}

List<String> _strings(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is String) item,
  ];
}
