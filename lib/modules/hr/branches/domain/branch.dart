class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.status,
    this.code,
    this.contactPerson,
    this.mobileNo,
    this.landLine,
    this.address,
    this.email,
    this.inventoryAlerts,
    this.multiInventory,
    this.divisionId,
    this.divisionName,
    this.timeZoneId,
  });

  final int id;
  final String name;
  final String status;
  final String? code;
  final String? contactPerson;
  final String? mobileNo;
  final String? landLine;
  final String? address;
  final String? email;
  final String? inventoryAlerts;
  final String? multiInventory;
  final int? divisionId;
  final String? divisionName;
  final String? timeZoneId;

  bool get isActive => status.toLowerCase() == 'active';
}

class BranchLookup {
  const BranchLookup({required this.id, required this.name, this.utcOffset});
  final String id;
  final String name;
  final String? utcOffset;
}

class BranchLookups {
  const BranchLookups({
    required this.divisions,
    required this.statuses,
    required this.yesNo,
    required this.timeZones,
  });
  final List<BranchLookup> divisions;
  final List<String> statuses;
  final List<String> yesNo;
  final List<BranchLookup> timeZones;
}

class BranchDraft {
  const BranchDraft({
    this.name = '',
    this.code = '',
    this.contactPerson = '',
    this.mobileNo = '',
    this.landLine = '',
    this.address = '',
    this.email = '',
    this.inventoryAlerts = 'Yes',
    this.multiInventory = 'No',
    this.divisionId,
    this.status = 'Active',
    this.timeZoneId,
  });

  final String name, code, contactPerson, mobileNo, landLine, address, email;
  final String inventoryAlerts, multiInventory, status;
  final int? divisionId;
  final String? timeZoneId;

  BranchDraft copyWith({
    String? name,
    String? code,
    String? contactPerson,
    String? mobileNo,
    String? landLine,
    String? address,
    String? email,
    String? inventoryAlerts,
    String? multiInventory,
    int? divisionId,
    String? status,
    String? timeZoneId,
  }) => BranchDraft(
    name: name ?? this.name,
    code: code ?? this.code,
    contactPerson: contactPerson ?? this.contactPerson,
    mobileNo: mobileNo ?? this.mobileNo,
    landLine: landLine ?? this.landLine,
    address: address ?? this.address,
    email: email ?? this.email,
    inventoryAlerts: inventoryAlerts ?? this.inventoryAlerts,
    multiInventory: multiInventory ?? this.multiInventory,
    divisionId: divisionId ?? this.divisionId,
    status: status ?? this.status,
    timeZoneId: timeZoneId ?? this.timeZoneId,
  );

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['branchName'] = 'required';
    if (name.trim().length > 100) errors['branchName'] = 'tooLong';
    if ((timeZoneId ?? '').trim().isEmpty) errors['timeZoneId'] = 'required';
    return Map.unmodifiable(errors);
  }
}

class BranchPageData {
  const BranchPageData({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });
  final List<Branch> items;
  final int page, pageSize, totalItems, totalPages;
}
