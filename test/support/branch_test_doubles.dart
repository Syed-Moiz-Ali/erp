import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/datasources/branch_remote_data_source.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

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
