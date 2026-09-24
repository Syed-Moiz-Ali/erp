import 'employee_attendance_catalog.dart';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';

import 'employee_dao.dart';
import 'account_provisioning_repository.dart';

class LocalEmployeeRepository implements EmployeeRepository {
  LocalEmployeeRepository(this.dao, this.accounts);
  final EmployeeDao dao;
  final AccountProvisioningRepository accounts;
  AppDatabase get db => dao.db;
  Future<void>? _writes;
  Future<T> serial<T>(Future<T> Function() work) {
    final next = (_writes ?? Future<void>.value()).then((_) => work());
    _writes = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Failure fail(String code) => Failure(
    code: code,
    kind: FailureKind.invalidData,
    retryable: code == 'storage',
  );
  @override
  Stream<Result<EmployeePageData>> watchEmployees(
    AuthContext context, {
    String query = '',
    EmployeeFilter filter = const EmployeeFilter(),
    EmployeeSort sort = EmployeeSort.nameAscending,
    int page = 0,
    int pageSize = 10,
  }) => dao.changes().asyncMap((_) async {
    try {
      return Success(
        await dao.page(
          context,
          query: query,
          filter: filter,
          sort: sort,
          page: page,
          pageSize: pageSize,
        ),
      );
    } catch (_) {
      return Failed<EmployeePageData>(fail('storage'));
    }
  });
  @override
  Stream<Result<Employee?>> watchEmployee(AuthContext context, String id) =>
      dao.changes().asyncMap((_) => getEmployeeById(context, id));

  @override
  Future<Result<Employee?>> getEmployeeById(
    AuthContext context,
    String id,
  ) async {
    try {
      final employee = await dao.get(context, id);
      if (employee == null && await dao.raw(context.company.id, id) != null) {
        return Failed(fail('denied'));
      }
      return Success(employee);
    } catch (_) {
      return Failed(fail('storage'));
    }
  }

  @override
  Future<Result<List<Employee>>> searchAssignableCompanyEmployees(
    AuthContext context, {
    String query = '',
    int limit = 50,
  }) async {
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id) {
      return Failed(fail('denied'));
    }
    try {
      return Success(
        await dao.searchAssignable(
          context.company.id,
          query: query,
          limit: limit,
        ),
      );
    } catch (_) {
      return Failed(fail('storage'));
    }
  }

  @override
  Future<Result<Employee?>> getCompanyEmployee(
    AuthContext context,
    String id,
  ) async {
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id) {
      return Failed(fail('denied'));
    }
    try {
      return Success(await dao.raw(context.company.id, id));
    } catch (_) {
      return Failed(fail('storage'));
    }
  }

  @override
  Future<Result<List<Employee>>> getCompanyEmployees(
    AuthContext context,
    Iterable<String> ids,
  ) async {
    if (context.user.status != AccountStatus.active ||
        context.user.companyId != context.company.id) {
      return Failed(fail('denied'));
    }
    try {
      return Success(await dao.getMany(context.company.id, ids.toList()));
    } catch (_) {
      return Failed(fail('storage'));
    }
  }

  @override
  Future<Result<bool>> checkEmailAvailability(
    AuthContext context,
    String email, {
    String? excludingId,
  }) async {
    try {
      return Success(
        await dao.available(
          context.company.id,
          'email',
          email.trim().toLowerCase(),
          excludingId,
        ),
      );
    } catch (_) {
      return Failed(fail('storage'));
    }
  }

  @override
  Future<Result<bool>> checkPhoneAvailability(
    AuthContext context,
    String phone, {
    String? excludingId,
  }) async {
    try {
      return Success(
        await dao.available(
          context.company.id,
          'phone',
          normalizeEmployeePhone(phone),
          excludingId,
        ),
      );
    } catch (_) {
      return Failed(fail('storage'));
    }
  }

  @override
  Future<Result<EmployeeAccountAccess?>> getLinkedAccount(
    AuthContext context,
    String employeeId,
  ) async {
    try {
      final e = await dao.get(context, employeeId);
      if (e?.linkedUserId == null) return const Success(null);
      final a = await (db.select(
        db.workforceAccounts,
      )..where((t) => t.id.equals(e!.linkedUserId!))).getSingleOrNull();
      if (a == null) return const Success(null);
      return Success(
        EmployeeAccountAccess(
          UserAccount(
            id: a.id,
            displayName: a.displayName,
            email: a.email,
            phone: a.phone,
            companyId: a.companyId,
            permissions: PermissionSet(
              (jsonDecode(a.grants) as List).map(
                (p) => AppPermission.values.byName(p as String),
              ),
            ),
            status: AccountStatus.values.byName(a.status),
          ),
          credentialPending: a.credentialPending,
        ),
      );
    } catch (_) {
      return Failed(fail('storage'));
    }
  }

  @override
  Future<Result<EmployeeReferences>> getReferences(
    AuthContext context, {
    String? excludingId,
  }) async {
    try {
      final departments =
          await (db.select(db.workforceDepartments)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.active.equals(true),
              ))
              .get();
      final designations =
          await (db.select(db.workforceDesignations)..where(
                (t) =>
                    t.companyId.equals(context.company.id) &
                    t.active.equals(true),
              ))
              .get();
      final clause = dao.where(
        context,
        filter: const EmployeeFilter(status: EmploymentStatus.active),
      );
      final managers = await db
          .customSelect(
            'SELECT id, first_name, middle_name, last_name FROM workforce_employees WHERE ${clause.sql} ORDER BY first_name',
            variables: clause.variables,
          )
          .get();
      final scope = dao.where(context);
      final relatedManagers = await db
          .customSelect(
            'SELECT id, first_name, middle_name, last_name FROM workforce_employees WHERE company_id=? AND id IN (SELECT manager_id FROM workforce_employees WHERE ${scope.sql})',
            variables: [Variable(context.company.id), ...scope.variables],
          )
          .get();
      final attendance = await EmployeeAttendanceCatalog(db).load(
        context,
        existing: excludingId == null
            ? null
            : await dao.get(context, excludingId),
      );
      return Success(
        EmployeeReferences(
          shifts: attendance.shifts,
          workLocations: attendance.locations,
          attendancePolicies: attendance.policies,
          managerLabels: relatedManagers
              .map(
                (m) => WorkforceReference(
                  m.read('id'),
                  [
                    m.read<String>('first_name'),
                    m.read<String>('middle_name'),
                    m.read<String>('last_name'),
                  ].where((s) => s.isNotEmpty).join(' '),
                ),
              )
              .toList(),
          departments: departments
              .map((d) => WorkforceReference(d.id, d.name))
              .toList(),
          designations: designations
              .map((d) => WorkforceReference(d.id, d.name))
              .toList(),
          managers: managers
              .where((m) => m.read<String>('id') != excludingId)
              .map(
                (m) => WorkforceReference(
                  m.read('id'),
                  [
                    m.read<String>('first_name'),
                    m.read<String>('middle_name'),
                    m.read<String>('last_name'),
                  ].where((n) => n.isNotEmpty).join(' '),
                ),
              )
              .toList(),
        ),
      );
    } catch (_) {
      return Failed(fail('storage'));
    }
  }

  @override
  Future<Result<Employee>> saveEmployee(
    AuthContext context,
    EmployeeDraft draft, {
    String? id,
  }) => serial(() async {
    try {
      return Success(
        await db.transaction(() async {
          final permission = id == null
              ? AppPermission.employeeCreate
              : AppPermission.employeeUpdate;
          if (!context.company.enabledModules.contains('employees') ||
              !PermissionChecker(context.user.permissions).can(permission)) {
            throw const EmployeeWriteException('denied');
          }
          final previous = id == null ? null : await dao.get(context, id);
          if (id != null && previous == null) {
            throw const EmployeeWriteException('denied');
          }
          final d = draft.copyWith(
            firstName: draft.firstName.trim(),
            middleName: draft.middleName.trim(),
            lastName: draft.lastName.trim(),
            email: draft.email.trim().toLowerCase(),
            phone: normalizeEmployeePhone(draft.phone),
          );
          if (d.firstName.isEmpty ||
              d.joiningDate == null ||
              d.departmentId == null ||
              d.designationId == null ||
              d.joiningDate!.isAfter(DateTime.now())) {
            throw const EmployeeWriteException('required');
          }
          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(d.email)) {
            throw const EmployeeWriteException('email');
          }
          if (!RegExp(r'^\+[0-9]{7,15}$').hasMatch(d.phone)) {
            throw const EmployeeWriteException('phone');
          }
          if (!await dao.available(context.company.id, 'email', d.email, id)) {
            throw const EmployeeWriteException('duplicateEmail');
          }
          if (!await dao.available(context.company.id, 'phone', d.phone, id)) {
            throw const EmployeeWriteException('duplicatePhone');
          }
          if (previous != null &&
              previous.status != d.status &&
              !context.user.permissions.contains(
                AppPermission.employeeDeactivate,
              )) {
            throw const EmployeeWriteException('denied');
          }
          for (final table in [
            'workforce_departments',
            'workforce_designations',
          ]) {
            final ref = table == 'workforce_departments'
                ? d.departmentId
                : d.designationId;
            final result = await db
                .customSelect(
                  'SELECT id FROM $table WHERE id=? AND company_id=? AND active=1',
                  variables: [Variable(ref), Variable(context.company.id)],
                )
                .get();
            if (result.isEmpty) throw const EmployeeWriteException('reference');
          }
          if (d.managerId != null) {
            final manager = await dao.raw(context.company.id, d.managerId!);
            if (manager == null ||
                manager.status != EmploymentStatus.active ||
                manager.id == id) {
              throw const EmployeeWriteException('manager');
            }
            final visited = <String>{};
            String? cursor = d.managerId;
            while (cursor != null) {
              if (cursor == id || !visited.add(cursor)) {
                throw const EmployeeWriteException('manager');
              }
              cursor = (await dao.raw(context.company.id, cursor))?.managerId;
            }
          }
          if (!await EmployeeAttendanceCatalog(
            db,
          ).valid(context, d, previous)) {
            throw const EmployeeWriteException('assignment');
          }
          final next =
              (await db
                      .customSelect(
                        'SELECT COALESCE(MAX(CAST(SUBSTR(employee_code,5) AS INTEGER)),0)+1 AS n FROM workforce_employees WHERE company_id=?',
                        variables: [Variable(context.company.id)],
                      )
                      .getSingle())
                  .read<int>('n');
          final now = DateTime.now();
          final employeeId = id ?? const Uuid().v4();
          final linked = await accounts.provision(
            context,
            d,
            [
              d.firstName,
              d.middleName,
              d.lastName,
            ].where((n) => n.isNotEmpty).join(' '),
            existingId: previous?.linkedUserId,
          );
          final employee = Employee(
            id: employeeId,
            companyId: context.company.id,
            employeeCode:
                previous?.employeeCode ??
                'EMP-${next.toString().padLeft(4, '0')}',
            firstName: d.firstName,
            middleName: d.middleName,
            lastName: d.lastName,
            email: d.email,
            phone: d.phone,
            departmentId: d.departmentId!,
            designationId: d.designationId!,
            managerId: d.managerId,
            joiningDate: d.joiningDate!,
            employmentType: d.employmentType,
            status: d.status,
            linkedUserId: linked,
            loginEnabled: d.loginEnabled,
            createdAt: previous?.createdAt ?? now,
            updatedAt: now,
            avatarUrl: previous?.avatarUrl,
            shiftId: d.shiftId,
            workLocationId: d.workLocationId,
            attendancePolicyId: d.attendancePolicyId,
          );
          await dao.put(employee);
          await enqueue(employee, id == null ? 'create' : 'update');
          return employee;
        }),
      );
    } on EmployeeWriteException catch (e) {
      return Failed(fail(e.code));
    } catch (_) {
      return Failed(fail('storage'));
    }
  });
  Future<void> enqueue(Employee e, String operation) async {
    final account = e.linkedUserId == null
        ? null
        : await (db.select(
            db.workforceAccounts,
          )..where((t) => t.id.equals(e.linkedUserId!))).getSingleOrNull();
    final payload = <String, Object?>{
      ...e.toJson(),
      if (account != null)
        'accountConfiguration': {
          'id': account.id,
          'permissions': jsonDecode(account.grants),
          'status': account.status,
          'email': account.email,
          'phone': account.phone,
        },
    };
    await db
        .into(db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            id: const Uuid().v4(),
            moduleId: 'employees',
            entityId: e.id,
            operation: operation,
            payload: jsonEncode(payload),
            createdAt: e.updatedAt,
          ),
        );
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) => serial(() async {
    try {
      await db.transaction(() async {
        if (!context.user.permissions.contains(
          AppPermission.employeeDeactivate,
        )) {
          throw const EmployeeWriteException('denied');
        }
        final e = await dao.get(context, id);
        if (e == null) throw const EmployeeWriteException('denied');
        final updated = e.copyWith(
          status: active ? EmploymentStatus.active : EmploymentStatus.inactive,
          updatedAt: DateTime.now(),
          syncStatus: EmployeeSyncStatus.pending,
        );
        await dao.put(updated);
        if (e.linkedUserId != null) {
          await accounts.setEnabled(e.linkedUserId!, active && e.loginEnabled);
        }
        await enqueue(updated, active ? 'activate' : 'deactivate');
      });
      return const Success(null);
    } on EmployeeWriteException catch (e) {
      return Failed(fail(e.code));
    } catch (_) {
      return Failed(fail('storage'));
    }
  });
}
