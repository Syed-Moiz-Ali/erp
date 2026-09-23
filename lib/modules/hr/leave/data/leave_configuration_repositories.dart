import 'dart:async';

import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';

/// Adapts the leave configuration surface (types, policies, holidays) onto the
/// shared [ConfigurationRepository] contract so the generic configuration
/// list/form/details workflow and layouts can be reused unchanged.
class LeaveConfigurationRepository<T extends ConfigurationRecord, D>
    implements ConfigurationRepository<T, D> {
  LeaveConfigurationRepository({
    required this.leaveRepository,
    required this.watchAll,
    required this.saveRecord,
    required this.toggleStatus,
    required this.viewPermission,
    required this.managePermission,
    this.countAssigned,
  });
  final LeaveRepository leaveRepository;
  final Stream<Result<List<T>>> Function(
    AuthContext context, {
    required bool includeInactive,
  })
  watchAll;
  final Future<Result<T>> Function(AuthContext context, D draft, {String? id})
  saveRecord;
  final Future<Result<void>> Function(
    AuthContext context,
    String id,
    bool active,
  )
  toggleStatus;
  final Future<Result<int>> Function(AuthContext context, String id)?
  countAssigned;
  final AppPermission viewPermission, managePermission;

  Failure? _access(AuthContext context, {bool manage = false}) {
    final permitted = PermissionChecker(
      context.user.permissions,
    ).can(manage ? managePermission : viewPermission);
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id ||
        !context.company.enabledModules.contains('settings') ||
        !permitted) {
      return const Failure(code: 'denied');
    }
    return null;
  }

  @override
  Stream<Result<ConfigurationPageData<T>>> watchList(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) {
    final failure = _access(context);
    if (failure != null) {
      return Stream.value(Failed<ConfigurationPageData<T>>(failure));
    }
    final safeSize = pageSize.clamp(1, 100);
    return watchAll(context, includeInactive: true).asyncMap((result) async {
      if (result is Failed<List<T>>) {
        return Failed<ConfigurationPageData<T>>(result.failure);
      }
      final all = (result as Success<List<T>>).value;
      final normalized = query.trim().toLowerCase();
      var filtered = all;
      if (status != null) {
        filtered = filtered.where((r) => r.status == status).toList();
      }
      if (normalized.isNotEmpty) {
        filtered = filtered
            .where(
              (r) =>
                  r.name.toLowerCase().contains(normalized) ||
                  (r is LeaveType &&
                      r.code.toLowerCase().contains(normalized)) ||
                  (r is LeavePolicy &&
                      r.code.toLowerCase().contains(normalized)),
            )
            .toList();
      }
      final start = page.clamp(0, 1000000) * safeSize;
      final pageItems = start >= filtered.length
          ? <T>[]
          : filtered.sublist(
              start,
              (start + safeSize).clamp(0, filtered.length),
            );
      final counter = countAssigned;
      final items = <ConfigurationItem<T>>[];
      for (final record in pageItems) {
        final assigned = counter == null
            ? 0
            : switch (await counter(context, record.id)) {
                Success<int>(:final value) => value,
                _ => 0,
              };
        items.add(ConfigurationItem(record, assigned));
      }
      return Success(ConfigurationPageData(items, all.length, filtered.length));
    });
  }

  @override
  Stream<Result<ConfigurationItem<T>?>> watchDetails(
    AuthContext context,
    String id,
  ) {
    final failure = _access(context);
    if (failure != null) {
      return Stream.value(Failed<ConfigurationItem<T>?>(failure));
    }
    return watchAll(context, includeInactive: true).asyncMap((result) async {
      if (result is Failed<List<T>>) {
        return Failed<ConfigurationItem<T>?>(result.failure);
      }
      final match = (result as Success<List<T>>).value
          .where((r) => r.id == id)
          .firstOrNull;
      if (match == null) return const Success(null);
      final assigned = countAssigned == null
          ? 0
          : switch (await countAssigned!(context, id)) {
              Success<int>(:final value) => value,
              _ => 0,
            };
      return Success(ConfigurationItem(match, assigned));
    });
  }

  @override
  Future<Result<T?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  }) async {
    final failure = _access(context, manage: forEditing);
    if (failure != null) return Failed(failure);
    final result = await watchAll(context, includeInactive: true).first;
    if (result is Failed<List<T>>) return Failed(result.failure);
    return Success(
      (result as Success<List<T>>).value.where((r) => r.id == id).firstOrNull,
    );
  }

  @override
  Future<Result<T>> save(AuthContext context, D draft, {String? id}) async {
    final failure = _access(context, manage: true);
    if (failure != null) return Failed(failure);
    return saveRecord(context, draft, id: id);
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) async {
    final failure = _access(context, manage: true);
    if (failure != null) return Failed(failure);
    return toggleStatus(context, id, active);
  }

  @override
  Future<Result<int>> assignedEmployeeCount(
    AuthContext context,
    String id,
  ) async {
    if (_access(context) != null && _access(context, manage: true) != null) {
      return const Failed(Failure(code: 'denied'));
    }
    if (countAssigned == null) return const Success(0);
    return countAssigned!(context, id);
  }
}

ConfigurationRepository<LeaveType, LeaveTypeDraft> leaveTypeConfiguration(
  LeaveRepository repository,
) => LeaveConfigurationRepository<LeaveType, LeaveTypeDraft>(
  leaveRepository: repository,
  watchAll: (context, {required includeInactive}) =>
      repository.watchLeaveTypes(context, includeInactive: includeInactive),
  saveRecord: (context, draft, {id}) =>
      repository.saveLeaveType(context, draft, id: id),
  toggleStatus: (context, id, active) =>
      repository.setLeaveTypeStatus(context, id, active),
  viewPermission: AppPermission.leaveTypeView,
  managePermission: AppPermission.leaveTypeManage,
);

ConfigurationRepository<LeavePolicy, LeavePolicyDraft> leavePolicyConfiguration(
  LeaveRepository repository,
) => LeaveConfigurationRepository<LeavePolicy, LeavePolicyDraft>(
  leaveRepository: repository,
  watchAll: (context, {required includeInactive}) =>
      repository.watchLeavePolicies(context, includeInactive: includeInactive),
  saveRecord: (context, draft, {id}) =>
      repository.saveLeavePolicy(context, draft, id: id),
  toggleStatus: (context, id, active) =>
      repository.setLeavePolicyStatus(context, id, active),
  viewPermission: AppPermission.leavePolicyView,
  managePermission: AppPermission.leavePolicyManage,
);

ConfigurationRepository<Holiday, HolidayDraft> holidayConfiguration(
  LeaveRepository repository,
) => LeaveConfigurationRepository<Holiday, HolidayDraft>(
  leaveRepository: repository,
  watchAll: (context, {required includeInactive}) =>
      repository.watchHolidays(context, includeInactive: includeInactive),
  saveRecord: (context, draft, {id}) =>
      repository.saveHoliday(context, draft, id: id),
  toggleStatus: (context, id, active) =>
      repository.setHolidayStatus(context, id, active),
  viewPermission: AppPermission.holidayView,
  managePermission: AppPermission.holidayManage,
);
