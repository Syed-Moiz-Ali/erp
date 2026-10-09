import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/domain/department_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Demo/local department repository.
///
/// Deliberately reuses the existing `workforce_departments` lookup table (the
/// one the Employees feature reads) instead of introducing a second department
/// table or a destructive migration. This keeps demo department management and
/// employee department selection consistent, and leaves the richer shared
/// configuration table shape (audit columns, sync status) out of scope. Remote
/// (backend) departments do not use this table at all.
class LocalDepartmentRepository implements DepartmentRepository {
  LocalDepartmentRepository(this.db);

  final AppDatabase db;
  Future<void>? _writes;

  static final DateTime _sentinel = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  Failure get _storageFailure => const Failure(
    code: 'databaseFailure',
    kind: FailureKind.storageWrite,
    retryable: true,
  );

  Future<R> _serial<R>(Future<R> Function() work) {
    final next = (_writes ?? Future<void>.value()).then((_) => work());
    _writes = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Failure? _access(AuthContext context, {bool manage = false}) {
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id ||
        !context.company.enabledModules.contains('settings') ||
        !PermissionChecker(context.user.permissions).can(
          manage
              ? AppPermission.departmentManage
              : AppPermission.departmentView,
        )) {
      return const Failure(code: 'denied');
    }
    return null;
  }

  Department _map(WorkforceDepartment row) => Department(
    id: row.id,
    companyId: row.companyId,
    name: row.name,
    status: row.active
        ? ConfigurationStatus.active
        : ConfigurationStatus.inactive,
    createdAt: _sentinel,
    updatedAt: _sentinel,
    syncStatus: RecordSyncStatus.synced,
  );

  SimpleSelectStatement<$WorkforceDepartmentsTable, WorkforceDepartment> _query(
    AuthContext context,
  ) => db.select(db.workforceDepartments)
    ..where((t) => t.companyId.equals(context.company.id))
    ..orderBy([(t) => OrderingTerm(expression: t.name)]);

  Future<Map<String, int>> _counts(AuthContext context) async {
    final rows = await db
        .customSelect(
          'SELECT department_id AS id, COUNT(*) AS n FROM workforce_employees '
          'WHERE company_id=? GROUP BY department_id',
          variables: [Variable(context.company.id)],
        )
        .get();
    return {for (final row in rows) row.read<String>('id'): row.read<int>('n')};
  }

  List<WorkforceDepartment> _filter(
    List<WorkforceDepartment> rows,
    String query,
    ConfigurationStatus? status,
  ) {
    final needle = query.trim().toLowerCase();
    return rows.where((row) {
      if (status != null) {
        final active = status == ConfigurationStatus.active;
        if (row.active != active) return false;
      }
      if (needle.isNotEmpty && !row.name.toLowerCase().contains(needle)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Stream<Result<ConfigurationPageData<Department>>> watchList(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return _query(context).watch().asyncMap((rows) async {
      try {
        final counts = await _counts(context);
        final filtered = _filter(rows, query, status);
        final size = pageSize.clamp(1, 100);
        final pageRows = filtered
            .skip(page.clamp(0, 1000000) * size)
            .take(size);
        return Success(
          ConfigurationPageData<Department>(
            pageRows
                .map((row) => ConfigurationItem(_map(row), counts[row.id] ?? 0))
                .toList(),
            rows.length,
            filtered.length,
          ),
        );
      } catch (_) {
        return Failed<ConfigurationPageData<Department>>(_storageFailure);
      }
    });
  }

  @override
  Stream<Result<ConfigurationItem<Department>?>> watchDetails(
    AuthContext context,
    String id,
  ) {
    final failure = _access(context);
    if (failure != null) return Stream.value(Failed(failure));
    return _query(context).watch().asyncMap((rows) async {
      try {
        final row = rows.where((r) => r.id == id).firstOrNull;
        if (row == null) {
          return const Success<ConfigurationItem<Department>?>(null);
        }
        final counts = await _counts(context);
        return Success<ConfigurationItem<Department>?>(
          ConfigurationItem(_map(row), counts[id] ?? 0),
        );
      } catch (_) {
        return Failed<ConfigurationItem<Department>?>(_storageFailure);
      }
    });
  }

  @override
  Future<Result<Department?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  }) async {
    final failure = _access(context, manage: forEditing);
    if (failure != null) return Failed(failure);
    try {
      final row =
          await (db.select(db.workforceDepartments)..where(
                (t) => t.companyId.equals(context.company.id) & t.id.equals(id),
              ))
              .getSingleOrNull();
      return Success(row == null ? null : _map(row));
    } catch (_) {
      return Failed(_storageFailure);
    }
  }

  @override
  Future<Result<Department>> save(
    AuthContext context,
    DepartmentDraft draft, {
    String? id,
  }) => _serial(() async {
    final failure = _access(context, manage: true);
    if (failure != null) return Failed(failure);
    final normalized = draft.normalized();
    final errors = normalized.validate();
    if (errors.isNotEmpty) {
      return Failed(
        Failure(code: errors.values.first, kind: FailureKind.validation),
      );
    }
    try {
      final newId = id ?? const Uuid().v4();
      final duplicate = await db
          .customSelect(
            'SELECT id FROM workforce_departments WHERE company_id=? AND '
            'active=1 AND lower(name)=lower(?) AND id<>? LIMIT 1',
            variables: [
              Variable(context.company.id),
              Variable(normalized.name),
              Variable(newId),
            ],
          )
          .getSingleOrNull();
      if (duplicate != null) {
        return const Failed(
          Failure(code: 'duplicateName', kind: FailureKind.validation),
        );
      }
      await db
          .into(db.workforceDepartments)
          .insertOnConflictUpdate(
            WorkforceDepartmentsCompanion.insert(
              id: newId,
              companyId: context.company.id,
              name: normalized.name,
              active: Value(draft.status == ConfigurationStatus.active),
            ),
          );
      final row = await (db.select(
        db.workforceDepartments,
      )..where((t) => t.id.equals(newId))).getSingle();
      return Success(_map(row));
    } catch (_) {
      return Failed(_storageFailure);
    }
  });

  @override
  Future<Result<void>> setActive(AuthContext context, String id, bool active) =>
      _serial(() async {
        final failure = _access(context, manage: true);
        if (failure != null) return Failed(failure);
        try {
          final row =
              await (db.select(db.workforceDepartments)..where(
                    (t) =>
                        t.companyId.equals(context.company.id) &
                        t.id.equals(id),
                  ))
                  .getSingleOrNull();
          if (row == null) return const Failed(Failure(code: 'notFound'));
          if (!active) {
            final counts = await _counts(context);
            if ((counts[id] ?? 0) > 0) {
              return const Failed(
                Failure(code: 'inUse', kind: FailureKind.conflict),
              );
            }
          }
          await (db.update(db.workforceDepartments)
                ..where((t) => t.id.equals(id)))
              .write(WorkforceDepartmentsCompanion(active: Value(active)));
          return const Success(null);
        } catch (_) {
          return Failed(_storageFailure);
        }
      });

  @override
  Future<Result<int>> assignedEmployeeCount(
    AuthContext context,
    String id,
  ) async {
    final failure = _access(context);
    if (failure != null && _access(context, manage: true) != null) {
      return Failed(failure);
    }
    try {
      final row =
          await (db.select(db.workforceDepartments)..where(
                (t) => t.companyId.equals(context.company.id) & t.id.equals(id),
              ))
              .getSingleOrNull();
      if (row == null) return const Failed(Failure(code: 'notFound'));
      final counts = await _counts(context);
      return Success(counts[id] ?? 0);
    } catch (_) {
      return Failed(_storageFailure);
    }
  }
}
