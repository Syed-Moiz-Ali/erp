enum BranchStatus {
  active('Active'),
  inactive('InActive');

  const BranchStatus(this.wire);

  final String wire;

  static BranchStatus fromWire(String? value) =>
      value?.trim().toLowerCase() == 'inactive'
      ? BranchStatus.inactive
      : BranchStatus.active;

  static BranchStatus? fromWireOrNull(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'active') return BranchStatus.active;
    if (normalized == 'inactive') return BranchStatus.inactive;
    return null;
  }
}

class Branch {
  const Branch({
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.contactPerson,
    required this.mobileNo,
    required this.landLine,
    required this.address,
    required this.email,
    required this.inventoryAlerts,
    required this.multiInventory,
    required this.divisionId,
    required this.divisionName,
    required this.statusId,
    required this.status,
    required this.timeZoneId,
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
  final int statusId;
  final String status;
  final String timeZoneId;

  bool get isActive => statusId == 1;

  BranchStatus get branchStatus => BranchStatus.fromWire(status);
}

class BranchDraft {
  const BranchDraft({
    this.branchName = '',
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
    this.timeZoneId,
  });

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
  final BranchStatus? status;
  final String? timeZoneId;

  BranchDraft normalized() => BranchDraft(
    branchName: branchName.trim(),
    branchCode: branchCode?.trim(),
    contactPerson: contactPerson?.trim(),
    mobileNo: mobileNo?.trim(),
    landLine: landLine?.trim(),
    address: address?.trim(),
    email: email?.trim(),
    inventoryAlerts: inventoryAlerts?.trim(),
    multiInventory: multiInventory?.trim(),
    divisionId: divisionId,
    status: status,
    timeZoneId: timeZoneId?.trim(),
  );

  BranchDraft copyWith({
    String? branchName,
    String? branchCode,
    String? contactPerson,
    String? mobileNo,
    String? landLine,
    String? address,
    String? email,
    String? inventoryAlerts,
    String? multiInventory,
    int? divisionId,
    BranchStatus? status,
    String? timeZoneId,
    bool clearDivisionId = false,
    bool clearTimeZoneId = false,
  }) => BranchDraft(
    branchName: branchName ?? this.branchName,
    branchCode: branchCode ?? this.branchCode,
    contactPerson: contactPerson ?? this.contactPerson,
    mobileNo: mobileNo ?? this.mobileNo,
    landLine: landLine ?? this.landLine,
    address: address ?? this.address,
    email: email ?? this.email,
    inventoryAlerts: inventoryAlerts ?? this.inventoryAlerts,
    multiInventory: multiInventory ?? this.multiInventory,
    divisionId: clearDivisionId ? null : divisionId ?? this.divisionId,
    status: status ?? this.status,
    timeZoneId: clearTimeZoneId ? null : timeZoneId ?? this.timeZoneId,
  );

  static final _ianaTimeZone = RegExp(
    r'^[A-Za-z][A-Za-z0-9_+\-]*(/[A-Za-z0-9_+\-]+)*$',
  );

  /// Backend rule: `branchName` is required, max 100 characters, and
  /// `timeZoneId` is a required IANA identifier.
  Map<String, String> validate() {
    final errors = <String, String>{};
    final name = branchName.trim();
    if (name.isEmpty) {
      errors['branchName'] = 'required';
    } else if (name.length > 100) {
      errors['branchName'] = 'tooLong';
    }
    final zone = timeZoneId?.trim() ?? '';
    if (zone.isEmpty) {
      errors['timeZoneId'] = 'required';
    } else if (!_ianaTimeZone.hasMatch(zone)) {
      errors['timeZoneId'] = 'invalidTimeZone';
    }
    return Map.unmodifiable(errors);
  }

  factory BranchDraft.fromBranch(Branch branch) => BranchDraft(
    branchName: branch.branchName,
    branchCode: branch.branchCode,
    contactPerson: branch.contactPerson,
    mobileNo: branch.mobileNo,
    landLine: branch.landLine,
    address: branch.address,
    email: branch.email,
    inventoryAlerts: branch.inventoryAlerts,
    multiInventory: branch.multiInventory,
    divisionId: branch.divisionId,
    status: branch.branchStatus,
    timeZoneId: branch.timeZoneId,
  );
}

class BranchPage {
  const BranchPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<Branch> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  bool get isEmpty => items.isEmpty;
  bool get hasMore => page < totalPages;
}

class BranchLookupOption {
  const BranchLookupOption({required this.id, required this.name});

  final int id;
  final String name;
}

class BranchTimeZoneLookup {
  const BranchTimeZoneLookup({
    required this.id,
    required this.name,
    required this.utcOffset,
  });

  final String id;
  final String name;
  final String utcOffset;
}

class BranchLookups {
  const BranchLookups({
    required this.divisions,
    required this.statuses,
    required this.yesNo,
    required this.timeZones,
  });

  final List<BranchLookupOption> divisions;
  final List<String> statuses;
  final List<String> yesNo;
  final List<BranchTimeZoneLookup> timeZones;
}
