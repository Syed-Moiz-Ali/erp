import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../../core/security/app_permission.dart';
import '../domain/employee.dart';
import '../domain/employee_access.dart';

class EmployeeDao {
  EmployeeDao(this.db);
  final AppDatabase db;
  ({String sql, List<Variable> variables}) where(
    AuthContext context, {
    String query = '',
    EmployeeFilter filter = const EmployeeFilter(),
    String? id,
  }) {
    final scope = const EmployeeScopeResolver().resolve(context),
        own = context.employeeReference?.id;
    final parts = <String>['company_id = ?'];
    final variables = <Variable>[Variable(context.company.id)];
    if (scope == EmployeeScope.none ||
        scope != EmployeeScope.all && own == null) {
      parts.add('0');
    } else if (scope == EmployeeScope.self) {
      parts.add('id = ?');
      variables.add(Variable(own));
    } else if (scope == EmployeeScope.team) {
      if (id != null &&
          context.user.permissions.contains(AppPermission.employeeViewSelf)) {
        parts.add('(manager_id = ? OR id = ?)');
        variables.addAll([Variable(own), Variable(own)]);
      } else {
        parts.add('manager_id = ?');
        variables.add(Variable(own));
      }
    }
    if (id != null) {
      parts.add('id = ?');
      variables.add(Variable(id));
    }
    if (query.trim().isNotEmpty) {
      final q =
          '%${query.trim().toLowerCase().replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
      parts.add(
        "(lower(first_name || CASE WHEN middle_name<>'' THEN ' ' || middle_name ELSE '' END || ' ' || last_name) LIKE ? ESCAPE '\\' OR lower(employee_code) LIKE ? ESCAPE '\\' OR lower(email) LIKE ? ESCAPE '\\' OR phone LIKE ? ESCAPE '\\')",
      );
      variables.addAll(List.generate(4, (_) => Variable(q)));
    }
    for (final entry in <String, String?>{
      'status': filter.status?.name,
      'department_id': filter.departmentId,
      'designation_id': filter.designationId,
      'manager_id': filter.managerId,
      'employment_type': filter.employmentType?.name,
    }.entries) {
      if (entry.value != null) {
        parts.add('${entry.key} = ?');
        variables.add(Variable(entry.value!));
      }
    }
    return (sql: parts.join(' AND '), variables: variables);
  }

  Stream<void> changes() => db
      .customSelect(
        'SELECT COUNT(*) AS n FROM workforce_employees',
        readsFrom: {db.workforceEmployees, db.workforceAccounts},
      )
      .watch()
      .map((_) {});
  Future<EmployeePageData> page(
    AuthContext context, {
    String query = '',
    EmployeeFilter filter = const EmployeeFilter(),
    EmployeeSort sort = EmployeeSort.nameAscending,
    int page = 0,
    int pageSize = 10,
  }) => db.transaction(() async {
    final scope = where(context),
        filtered = where(context, query: query, filter: filter);
    Future<int> count(({String sql, List<Variable> variables}) clause) async =>
        (await db
                .customSelect(
                  'SELECT COUNT(*) AS n FROM workforce_employees WHERE ${clause.sql}',
                  variables: clause.variables,
                )
                .getSingle())
            .read<int>('n');
    final order = switch (sort) {
      EmployeeSort.nameAscending =>
        'first_name COLLATE NOCASE ASC, last_name COLLATE NOCASE ASC',
      EmployeeSort.nameDescending =>
        'first_name COLLATE NOCASE DESC, last_name COLLATE NOCASE DESC',
      EmployeeSort.code => 'employee_code ASC',
      EmployeeSort.newestJoined => 'joining_date DESC',
      EmployeeSort.oldestJoined => 'joining_date ASC',
    };
    final rows = await db
        .customSelect(
          'SELECT * FROM workforce_employees WHERE ${filtered.sql} ORDER BY $order, id ASC LIMIT ? OFFSET ?',
          variables: [
            ...filtered.variables,
            Variable(pageSize.clamp(1, 100)),
            Variable(page.clamp(0, 1000000) * pageSize.clamp(1, 100)),
          ],
        )
        .get();
    return EmployeePageData(
      rows.map(map).toList(),
      await count(scope),
      await count(filtered),
    );
  });
  Future<Employee?> get(AuthContext context, String id) async {
    final clause = where(context, id: id);
    final rows = await db
        .customSelect(
          'SELECT * FROM workforce_employees WHERE ${clause.sql}',
          variables: clause.variables,
        )
        .get();
    return rows.isEmpty ? null : map(rows.single);
  }

  Future<Employee?> raw(String company, String id) async {
    final rows = await db
        .customSelect(
          'SELECT * FROM workforce_employees WHERE company_id=? AND id=?',
          variables: [Variable(company), Variable(id)],
        )
        .get();
    return rows.isEmpty ? null : map(rows.single);
  }

  Employee map(QueryRow r) => Employee(
    id: r.read('id'),
    companyId: r.read('company_id'),
    employeeCode: r.read('employee_code'),
    firstName: r.read('first_name'),
    middleName: r.read('middle_name'),
    lastName: r.read('last_name'),
    email: r.read('email'),
    phone: r.read('phone'),
    departmentId: r.read('department_id'),
    designationId: r.read('designation_id'),
    managerId: r.readNullable('manager_id'),
    joiningDate: r.read('joining_date'),
    employmentType: EmploymentType.values.byName(r.read('employment_type')),
    status: EmploymentStatus.values.byName(r.read('status')),
    avatarUrl: r.readNullable('avatar_url'),
    shiftId: r.readNullable('shift_id'),
    workLocationId: r.readNullable('work_location_id'),
    attendancePolicyId: r.readNullable('attendance_policy_id'),
    linkedUserId: r.readNullable('linked_user_id'),
    loginEnabled: r.read('login_enabled'),
    createdAt: r.read('created_at'),
    updatedAt: r.read('updated_at'),
    syncStatus: EmployeeSyncStatus.values.byName(r.read('sync_status')),
  );
  Future<bool> available(
    String company,
    String column,
    String value,
    String? excluding,
  ) async {
    final rows = await db
        .customSelect(
          'SELECT id FROM workforce_employees WHERE company_id=? AND $column=? AND (? IS NULL OR id<>?) LIMIT 1',
          variables: [
            Variable(company),
            Variable(value),
            Variable(excluding),
            Variable(excluding),
          ],
        )
        .get();
    return rows.isEmpty;
  }

  Future<void> put(Employee employee) async {
    final e = employee;
    await db
        .into(db.workforceEmployees)
        .insertOnConflictUpdate(
          WorkforceEmployeesCompanion.insert(
            id: e.id,
            companyId: e.companyId,
            employeeCode: e.employeeCode,
            firstName: e.firstName,
            middleName: Value(e.middleName),
            lastName: Value(e.lastName),
            email: e.email,
            phone: e.phone,
            departmentId: e.departmentId,
            designationId: e.designationId,
            managerId: Value(e.managerId),
            joiningDate: e.joiningDate,
            employmentType: e.employmentType.name,
            status: e.status.name,
            linkedUserId: Value(e.linkedUserId),
            loginEnabled: Value(e.loginEnabled),
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            syncStatus: e.syncStatus.name,
            avatarUrl: Value(e.avatarUrl),
            shiftId: Value(e.shiftId),
            workLocationId: Value(e.workLocationId),
            attendancePolicyId: Value(e.attendancePolicyId),
          ),
        );
  }
}
