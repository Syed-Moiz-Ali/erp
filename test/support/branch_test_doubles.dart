import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/datasources/branch_remote_data_source.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch_repository.dart';

BranchDto branchDto({
  int branchId = 1,
  String branchName = 'Branch 1',
  String? branchCode = 'BR-1',
  String? contactPerson = 'Sanitized Name',
  String? mobileNo = 'SANITIZED_MOBILE',
  String? landLine = 'SANITIZED_LANDLINE',
  String? address = 'Sanitized Address',
  String? email = 'sanitized@example.com',
  String? inventoryAlerts = 'Yes',
  String? multiInventory = 'No',
  int? divisionId = 1,
  String? divisionName = 'Sanitized Division',
  int? statusId,
  String status = 'Active',
  String timeZoneId = 'Asia/Dubai',
}) => BranchDto(
  branchId: branchId,
  branchName: branchName,
  branchCode: branchCode,
  contactPerson: contactPerson,
  mobileNo: mobileNo,
  landLine: landLine,
  address: address,
  email: email,
  inventoryAlerts: inventoryAlerts,
  multiInventory: multiInventory,
  divisionId: divisionId,
  divisionName: divisionName,
  statusId: statusId,
  status: status,
  timeZoneId: timeZoneId,
);

PagedResult<BranchDto> branchPage(
  List<BranchDto> items, {
  int page = 1,
  int pageSize = 25,
  int? totalItems,
  int? totalPages,
}) => PagedResult(
  items: items,
  page: page,
  pageSize: pageSize,
  totalItems: totalItems ?? items.length,
  totalPages: totalPages ?? 1,
);

class FakeBranchRemoteDataSource implements BranchRemoteDataSource {
  Future<Result<PagedResult<BranchDto>>> Function(
    String? search,
    BranchStatus? status,
    int? divisionId,
    String? sort,
    int page,
    int pageSize,
  )?
  onList;
  Future<Result<BranchLookupsDto>> Function()? onLookups;
  Future<Result<BranchDto>> Function(int id)? onGet;
  Future<Result<BranchDto>> Function(BranchUpsertDto request)? onCreate;
  Future<Result<BranchDto>> Function(int id, BranchUpsertDto request)? onUpdate;
  Future<Result<void>> Function(int id)? onActivate;
  Future<Result<void>> Function(int id)? onDeactivate;

  int listCalls = 0,
      lookupsCalls = 0,
      getCalls = 0,
      createCalls = 0,
      updateCalls = 0,
      activateCalls = 0,
      deactivateCalls = 0;
  int? lastPage, lastPageSize, lastDivisionId, lastGetId;
  String? lastSearch, lastSort;
  BranchStatus? lastStatus;
  BranchUpsertDto? lastCreate, lastUpdate;
  int? lastUpdateId, lastActivateId, lastDeactivateId;

  @override
  Future<Result<PagedResult<BranchDto>>> list({
    String? search,
    BranchStatus? status,
    int? divisionId,
    String? sort,
    required int page,
    required int pageSize,
    CancelToken? cancelToken,
  }) async {
    listCalls++;
    lastSearch = search;
    lastStatus = status;
    lastDivisionId = divisionId;
    lastSort = sort;
    lastPage = page;
    lastPageSize = pageSize;
    return (onList ??
        (_, _, _, _, _, _) async => Success(branchPage(const [])))(
      search,
      status,
      divisionId,
      sort,
      page,
      pageSize,
    );
  }

  @override
  Future<Result<BranchLookupsDto>> lookups({CancelToken? cancelToken}) async {
    lookupsCalls++;
    return (onLookups ??
        () async => Success(
          const BranchLookupsDto(
            divisions: [],
            statuses: ['Active', 'InActive'],
            yesNo: ['Yes', 'No'],
            timeZones: [],
          ),
        ))();
  }

  @override
  Future<Result<BranchDto>> getById(int id, {CancelToken? cancelToken}) async {
    getCalls++;
    lastGetId = id;
    return (onGet ?? (id) async => Success(branchDto(branchId: id)))(id);
  }

  @override
  Future<Result<BranchDto>> create(
    BranchUpsertDto request, {
    CancelToken? cancelToken,
  }) async {
    createCalls++;
    lastCreate = request;
    return (onCreate ??
        (request) async => Success(
          branchDto(
            branchName: request.branchName,
            timeZoneId: request.timeZoneId,
          ),
        ))(request);
  }

  @override
  Future<Result<BranchDto>> update(
    int id,
    BranchUpsertDto request, {
    CancelToken? cancelToken,
  }) async {
    updateCalls++;
    lastUpdateId = id;
    lastUpdate = request;
    return (onUpdate ??
        (id, request) async => Success(
          branchDto(
            branchId: id,
            branchName: request.branchName,
            timeZoneId: request.timeZoneId,
          ),
        ))(id, request);
  }

  @override
  Future<Result<void>> activate(int id, {CancelToken? cancelToken}) async {
    activateCalls++;
    lastActivateId = id;
    return (onActivate ?? (id) async => const Success(null))(id);
  }

  @override
  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken}) async {
    deactivateCalls++;
    lastDeactivateId = id;
    return (onDeactivate ?? (id) async => const Success(null))(id);
  }
}

/// In-memory [BranchRepository] for presentation/adapter tests. No network and
/// no live writes; every call is recorded so tests can assert what was sent.
class InMemoryBranchRepository implements BranchRepository {
  InMemoryBranchRepository({List<Branch>? branches, BranchLookups? lookups})
    : branches = [...?branches],
      lookupsValue =
          lookups ??
          const BranchLookups(
            divisions: [
              BranchLookupOption(id: 1, name: 'Division 1'),
              BranchLookupOption(id: 2, name: 'Division 2'),
            ],
            statuses: ['Active', 'InActive'],
            yesNo: ['Yes', 'No'],
            timeZones: [
              BranchTimeZoneLookup(
                id: 'Asia/Dubai',
                name: 'Dubai',
                utcOffset: '+04:00',
              ),
              BranchTimeZoneLookup(
                id: 'Asia/Kolkata',
                name: 'Kolkata',
                utcOffset: '+05:30',
              ),
            ],
          );

  final List<Branch> branches;
  final BranchLookups lookupsValue;
  int listCalls = 0, lookupsCalls = 0, getCalls = 0, createCalls = 0;
  int updateCalls = 0, activateCalls = 0, deactivateCalls = 0;
  String? lastSearch;
  BranchStatus? lastStatus;
  int? lastPage, lastPageSize;
  BranchDraft? lastCreate, lastUpdate;
  int? lastUpdateId, lastActiveId;
  bool? lastActive;

  @override
  Future<Result<BranchPage>> list({
    String? search,
    BranchStatus? status,
    int? divisionId,
    String? sort,
    int page = 1,
    int pageSize = 25,
  }) async {
    listCalls++;
    lastSearch = search;
    lastStatus = status;
    lastPage = page;
    lastPageSize = pageSize;
    final filtered = branches
        .where((branch) {
          if (search != null &&
              search.isNotEmpty &&
              !branch.branchName.toLowerCase().contains(search.toLowerCase())) {
            return false;
          }
          if (status != null && branch.branchStatus != status) return false;
          if (divisionId != null && branch.divisionId != divisionId) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
    return Success(
      BranchPage(
        items: filtered,
        page: page,
        pageSize: pageSize,
        totalItems: filtered.length,
        totalPages: filtered.isEmpty
            ? 0
            : ((filtered.length - 1) ~/ pageSize) + 1,
      ),
    );
  }

  @override
  Future<Result<BranchLookups>> lookups() async {
    lookupsCalls++;
    return Success(lookupsValue);
  }

  @override
  Future<Result<Branch>> getById(int id) async {
    getCalls++;
    for (final branch in branches) {
      if (branch.branchId == id) return Success(branch);
    }
    return const Failed(
      Failure(code: 'BRANCH_NOT_FOUND', kind: FailureKind.notFound),
    );
  }

  @override
  Future<Result<Branch>> create(BranchDraft draft) async {
    createCalls++;
    lastCreate = draft;
    final branch = _fromDraft(draft, _nextId(), existing: null);
    branches.add(branch);
    return Success(branch);
  }

  @override
  Future<Result<Branch>> update(int id, BranchDraft draft) async {
    updateCalls++;
    lastUpdateId = id;
    lastUpdate = draft;
    final index = branches.indexWhere((branch) => branch.branchId == id);
    if (index < 0) {
      return const Failed(
        Failure(code: 'BRANCH_NOT_FOUND', kind: FailureKind.notFound),
      );
    }
    final branch = _fromDraft(draft, id, existing: branches[index]);
    branches[index] = branch;
    return Success(branch);
  }

  @override
  Future<Result<void>> setActive(int id, bool active) async {
    if (active) {
      activateCalls++;
    } else {
      deactivateCalls++;
    }
    lastActiveId = id;
    lastActive = active;
    final index = branches.indexWhere((branch) => branch.branchId == id);
    if (index < 0) {
      return const Failed(
        Failure(code: 'BRANCH_NOT_FOUND', kind: FailureKind.notFound),
      );
    }
    final current = branches[index];
    branches[index] = Branch(
      branchId: current.branchId,
      branchName: current.branchName,
      branchCode: current.branchCode,
      contactPerson: current.contactPerson,
      mobileNo: current.mobileNo,
      landLine: current.landLine,
      address: current.address,
      email: current.email,
      inventoryAlerts: current.inventoryAlerts,
      multiInventory: current.multiInventory,
      divisionId: current.divisionId,
      divisionName: current.divisionName,
      statusId: active ? 1 : 2,
      status: active ? BranchStatus.active.wire : BranchStatus.inactive.wire,
      timeZoneId: current.timeZoneId,
    );
    return const Success(null);
  }

  int _nextId() => branches.isEmpty
      ? 1
      : branches
                .map((branch) => branch.branchId)
                .reduce((a, b) => a > b ? a : b) +
            1;

  Branch _fromDraft(BranchDraft draft, int id, {Branch? existing}) {
    final status =
        draft.status ?? existing?.branchStatus ?? BranchStatus.active;
    return Branch(
      branchId: id,
      branchName: draft.branchName.trim(),
      branchCode: draft.branchCode,
      contactPerson: draft.contactPerson,
      mobileNo: draft.mobileNo,
      landLine: draft.landLine,
      address: draft.address,
      email: draft.email,
      inventoryAlerts: draft.inventoryAlerts,
      multiInventory: draft.multiInventory,
      divisionId: draft.divisionId,
      divisionName: existing?.divisionName,
      statusId: status == BranchStatus.inactive ? 2 : 1,
      status: status.wire,
      timeZoneId: draft.timeZoneId ?? existing?.timeZoneId ?? '',
    );
  }
}
