import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/shifts/data/datasources/shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';

ShiftDto shiftDto(
  int id,
  String name, {
  String startTime = '09:00:00',
  String endTime = '12:00:00',
  int earlyPunchInMinutes = 15,
  int lateGraceMinutes = 15,
  int statusId = 1,
  int activeAssignments = 0,
  bool crossesMidnight = false,
}) => ShiftDto(
  shiftId: id,
  shiftName: name,
  startTime: startTime,
  endTime: endTime,
  earlyPunchInMinutes: earlyPunchInMinutes,
  lateGraceMinutes: lateGraceMinutes,
  statusId: statusId,
  status: statusId == 2 ? 'InActive' : 'Active',
  activeAssignments: activeAssignments,
  crossesMidnight: crossesMidnight,
);

PagedResult<ShiftDto> shiftPage(
  List<ShiftDto> items, {
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

/// Scriptable remote shift datasource. No network is touched.
class FakeShiftRemoteDataSource implements ShiftRemoteDataSource {
  Future<Result<PagedResult<ShiftDto>>> Function(
    int page,
    int pageSize,
    String search,
    int? statusId,
  )?
  onList;
  Future<Result<ShiftDto>> Function(int id)? onGet;
  Future<Result<ShiftDto>> Function(ShiftUpsertDto request)? onCreate;
  Future<Result<ShiftDto>> Function(int id, ShiftUpsertDto request)? onUpdate;
  Future<Result<void>> Function(int id)? onDeactivate;
  Future<Result<void>> Function(int id)? onActivate;

  int listCalls = 0, getCalls = 0, createCalls = 0, updateCalls = 0;
  int deactivateCalls = 0, activateCalls = 0;
  int? lastPage, lastPageSize, lastStatusId;
  String? lastSearch;
  ShiftUpsertDto? lastCreate, lastUpdate;
  int? lastUpdateId, lastGetId, lastDeactivateId, lastActivateId;

  @override
  Future<Result<PagedResult<ShiftDto>>> list({
    required int page,
    required int pageSize,
    String search = '',
    int? statusId,
    CancelToken? cancelToken,
  }) async {
    listCalls++;
    lastPage = page;
    lastPageSize = pageSize;
    lastSearch = search;
    lastStatusId = statusId;
    return (onList ?? (_, _, _, _) async => Success(shiftPage(const [])))(
      page,
      pageSize,
      search,
      statusId,
    );
  }

  @override
  Future<Result<ShiftDto>> getById(int id, {CancelToken? cancelToken}) async {
    getCalls++;
    lastGetId = id;
    return (onGet ?? (id) async => Success(shiftDto(id, 'Shift $id')))(id);
  }

  @override
  Future<Result<ShiftDto>> create(
    ShiftUpsertDto request, {
    CancelToken? cancelToken,
  }) async {
    createCalls++;
    lastCreate = request;
    return (onCreate ??
        (request) async => Success(
          shiftDto(1, request.shiftName, startTime: request.startTime),
        ))(request);
  }

  @override
  Future<Result<ShiftDto>> update(
    int id,
    ShiftUpsertDto request, {
    CancelToken? cancelToken,
  }) async {
    updateCalls++;
    lastUpdateId = id;
    lastUpdate = request;
    return (onUpdate ??
        (id, request) async => Success(
          shiftDto(id, request.shiftName, startTime: request.startTime),
        ))(id, request);
  }

  @override
  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken}) async {
    deactivateCalls++;
    lastDeactivateId = id;
    return (onDeactivate ?? (id) async => const Success(null))(id);
  }

  @override
  Future<Result<void>> activate(int id, {CancelToken? cancelToken}) async {
    activateCalls++;
    lastActivateId = id;
    return (onActivate ?? (id) async => const Success(null))(id);
  }
}
