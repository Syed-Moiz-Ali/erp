import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/departments/data/datasources/department_remote_data_source.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

DepartmentDto departmentDto(int id, String name, {int employeeCount = 0}) =>
    DepartmentDto(
      departmentId: id,
      departmentName: name,
      employeeCount: employeeCount,
    );

PagedResult<DepartmentDto> departmentPage(
  List<DepartmentDto> items, {
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

/// Scriptable remote department datasource. No network is touched.
class FakeDepartmentRemoteDataSource implements DepartmentRemoteDataSource {
  Future<Result<PagedResult<DepartmentDto>>> Function(
    int page,
    int pageSize,
    String search,
  )?
  onList;
  Future<Result<DepartmentDto>> Function(int id)? onGet;
  Future<Result<DepartmentDto>> Function(DepartmentUpsertDto request)? onCreate;
  Future<Result<DepartmentDto>> Function(int id, DepartmentUpsertDto request)?
  onRename;
  Future<Result<void>> Function(int id)? onDeactivate;

  int listCalls = 0, getCalls = 0, createCalls = 0, renameCalls = 0;
  int deactivateCalls = 0;
  int? lastPage, lastPageSize;
  String? lastSearch;
  DepartmentUpsertDto? lastCreate;
  DepartmentUpsertDto? lastRename;
  int? lastRenameId, lastGetId, lastDeactivateId;

  @override
  Future<Result<PagedResult<DepartmentDto>>> list({
    required int page,
    required int pageSize,
    String search = '',
    CancelToken? cancelToken,
  }) async {
    listCalls++;
    lastPage = page;
    lastPageSize = pageSize;
    lastSearch = search;
    return (onList ?? (_, _, _) async => Success(departmentPage(const [])))(
      page,
      pageSize,
      search,
    );
  }

  @override
  Future<Result<DepartmentDto>> getById(
    int id, {
    CancelToken? cancelToken,
  }) async {
    getCalls++;
    lastGetId = id;
    return (onGet ??
        (id) async => Success(departmentDto(id, 'Department $id')))(id);
  }

  @override
  Future<Result<DepartmentDto>> create(
    DepartmentUpsertDto request, {
    CancelToken? cancelToken,
  }) async {
    createCalls++;
    lastCreate = request;
    return (onCreate ??
        (request) async => Success(
          DepartmentDto(
            departmentId: 1,
            departmentName: request.departmentName,
          ),
        ))(request);
  }

  @override
  Future<Result<DepartmentDto>> rename(
    int id,
    DepartmentUpsertDto request, {
    CancelToken? cancelToken,
  }) async {
    renameCalls++;
    lastRenameId = id;
    lastRename = request;
    return (onRename ??
        (id, request) async => Success(
          DepartmentDto(
            departmentId: id,
            departmentName: request.departmentName,
          ),
        ))(id, request);
  }

  @override
  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken}) async {
    deactivateCalls++;
    lastDeactivateId = id;
    return (onDeactivate ?? (id) async => const Success(null))(id);
  }
}

AuthContext departmentAuthContext({
  Set<AppPermission> permissions = const {
    AppPermission.departmentView,
    AppPermission.departmentManage,
  },
  String companyId = '3',
  bool enableSettings = true,
}) => AuthContext(
  user: UserAccount(
    id: '5',
    displayName: 'Admin',
    email: 'admin',
    companyId: companyId,
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: companyId,
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: enableSettings ? const {'settings'} : const {},
  ),
);
