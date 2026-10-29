import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/live/data/datasources/live_employee_data_source.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';

LiveEmployeeDto employeeDto(Map<String, dynamic> json) =>
    LiveEmployeeDto.fromJson(json);

PagedResult<LiveEmployeeDto> employeePage(
  List<LiveEmployeeDto> items, {
  int page = 1,
  int pageSize = 25,
  int? totalItems,
}) => PagedResult(
  items: items,
  page: page,
  pageSize: pageSize,
  totalItems: totalItems ?? items.length,
  totalPages: 1,
);

/// In-memory employee transport double. No network is touched.
class FakeLiveEmployeeRemoteDataSource implements LiveEmployeeRemoteDataSource {
  Future<Result<PagedResult<LiveEmployeeDto>>> Function(
    String search,
    int? statusId,
    int? departmentId,
    int? branchId,
    String sort,
    int page,
    int pageSize,
  )?
  onList;
  Future<Result<LiveEmployeeDto>> Function(int id)? onGet;
  Future<Result<LiveEmployeeDto>> Function(Map<String, dynamic> body)? onCreate;
  Future<Result<LiveEmployeeDto>> Function(int id, Map<String, dynamic> body)?
  onUpdate;
  Future<Result<LiveEmployeeDto>> Function(int id, bool active)? onSetActive;
  Future<Result<LiveEmployeeLookups>> Function()? onLookups;

  int listCalls = 0, getCalls = 0, createCalls = 0, updateCalls = 0;
  int setActiveCalls = 0, lookupsCalls = 0;
  String? lastSearch, lastSort;
  int? lastStatusId, lastDepartmentId, lastBranchId, lastPage, lastPageSize;
  int? lastGetId, lastUpdateId, lastSetActiveId;
  bool? lastActive;
  Map<String, dynamic>? lastCreateBody, lastUpdateBody;

  @override
  Future<Result<PagedResult<LiveEmployeeDto>>> list({
    String search = '',
    int? statusId,
    int? departmentId,
    int? branchId,
    String sort = 'nameAsc',
    int page = 1,
    int pageSize = 25,
    CancelToken? cancelToken,
  }) async {
    listCalls++;
    lastSearch = search;
    lastStatusId = statusId;
    lastDepartmentId = departmentId;
    lastBranchId = branchId;
    lastSort = sort;
    lastPage = page;
    lastPageSize = pageSize;
    return (onList ?? (_, _, _, _, _, _, _) async => Success(employeePage([])))(
      search,
      statusId,
      departmentId,
      branchId,
      sort,
      page,
      pageSize,
    );
  }

  @override
  Future<Result<LiveEmployeeDto>> getById(
    int id, {
    CancelToken? cancelToken,
  }) async {
    getCalls++;
    lastGetId = id;
    return (onGet ??
        (id) async => Success(
          employeeDto({
            'employeeId': id,
            'employeeCode': 'EMP-$id',
            'employeeName': 'Employee $id',
            'statusId': 1,
          }),
        ))(id);
  }

  @override
  Future<Result<LiveEmployeeDto>> create(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    createCalls++;
    lastCreateBody = body;
    return (onCreate ??
        (body) async => Success(
          employeeDto({
            'employeeId': 1,
            'employeeCode': 'EMP-1',
            'employeeName': body['employeeName'] ?? '',
            'statusId': body['statusId'] ?? 1,
          }),
        ))(body);
  }

  @override
  Future<Result<LiveEmployeeDto>> update(
    int id,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    updateCalls++;
    lastUpdateId = id;
    lastUpdateBody = body;
    return (onUpdate ??
        (id, body) async => Success(
          employeeDto({...body, 'employeeId': id, 'employeeCode': 'EMP-$id'}),
        ))(id, body);
  }

  @override
  Future<Result<LiveEmployeeDto>> setActive(
    int id, {
    required bool active,
    CancelToken? cancelToken,
  }) async {
    setActiveCalls++;
    lastSetActiveId = id;
    lastActive = active;
    return (onSetActive ??
        (id, active) async => Success(
          employeeDto({
            'employeeId': id,
            'employeeCode': 'EMP-$id',
            'employeeName': 'Employee $id',
            'statusId': active ? 1 : 2,
          }),
        ))(id, active);
  }

  @override
  Future<Result<LiveEmployeeLookups>> lookups({
    CancelToken? cancelToken,
  }) async {
    lookupsCalls++;
    return (onLookups ??
        () async => Success(
          const LiveEmployeeLookups(
            branches: [],
            departments: [],
            nationalities: [],
            statuses: [],
          ),
        ))();
  }
}
