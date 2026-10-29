import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

abstract final class BranchMapper {
  const BranchMapper._();

  static Branch toDomain(BranchDto dto) {
    final status = dto.status.trim().isEmpty
        ? (dto.statusId == 2
              ? BranchStatus.inactive.wire
              : BranchStatus.active.wire)
        : dto.status;
    final parsedStatus = BranchStatus.fromWire(status);
    final statusId =
        dto.statusId ?? (parsedStatus == BranchStatus.inactive ? 2 : 1);
    return Branch(
      branchId: dto.branchId,
      branchName: dto.branchName,
      branchCode: dto.branchCode,
      contactPerson: dto.contactPerson,
      mobileNo: dto.mobileNo,
      landLine: dto.landLine,
      address: dto.address,
      email: dto.email,
      inventoryAlerts: dto.inventoryAlerts,
      multiInventory: dto.multiInventory,
      divisionId: dto.divisionId,
      divisionName: dto.divisionName,
      statusId: statusId,
      status: status,
      timeZoneId: dto.timeZoneId,
    );
  }

  static BranchUpsertDto toUpsert(BranchDraft draft) => BranchUpsertDto(
    branchName: draft.branchName.trim(),
    timeZoneId: draft.timeZoneId?.trim() ?? '',
    branchCode: draft.branchCode,
    contactPerson: draft.contactPerson,
    mobileNo: draft.mobileNo,
    landLine: draft.landLine,
    address: draft.address,
    email: draft.email,
    inventoryAlerts: draft.inventoryAlerts,
    multiInventory: draft.multiInventory,
    divisionId: draft.divisionId,
    status: draft.status?.wire,
  );

  static BranchLookups toLookups(BranchLookupsDto dto) => BranchLookups(
    divisions: [
      for (final division in dto.divisions)
        BranchLookupOption(id: division.id, name: division.name),
    ],
    statuses: dto.statuses,
    yesNo: dto.yesNo,
    timeZones: [
      for (final timeZone in dto.timeZones)
        BranchTimeZoneLookup(
          id: timeZone.id,
          name: timeZone.name,
          utcOffset: timeZone.utcOffset,
        ),
    ],
  );
}
