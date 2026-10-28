import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';

abstract interface class LiveEmployeeRepository {
  Future<Result<LiveEmployeePage>> list({
    String search = '',
    int? statusId,
    int? departmentId,
    int? branchId,
    String sort = 'nameAsc',
    int page = 1,
    int pageSize = 25,
  });
  Future<Result<LiveEmployee>> getById(int id);
  Future<Result<LiveEmployee>> create(LiveEmployeeDraft draft);
  Future<Result<LiveEmployee>> update(
    LiveEmployee current,
    LiveEmployeeDraft draft,
  );
  Future<Result<LiveEmployee>> setActive(int id, bool active);
  Future<Result<LiveEmployeeLookups>> lookups();
}

class LiveEmployeePage {
  const LiveEmployeePage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });
  final List<LiveEmployee> items;
  final int page, pageSize, totalItems, totalPages;
}
