import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../auth/data/datasources/local/demo_auth_source.dart';
import '../domain/employee.dart';
import 'employee_dao.dart';

Future<void> seedEmployees(AppDatabase db) => db.transaction(() async {
  final marker = await (db.select(
    db.workforceSeeds,
  )..where((t) => t.companyId.equals('demo-company'))).getSingleOrNull();
  if (marker != null) return;
  const departments = [
    'Human Resources',
    'Operations',
    'Sales',
    'Finance',
    'الخدمات',
  ];
  const designations = [
    'HR Executive',
    'Team Lead',
    'Developer',
    'Technician',
    'Accountant',
  ];
  for (var i = 0; i < 5; i++) {
    await db
        .into(db.workforceDepartments)
        .insert(
          WorkforceDepartmentsCompanion.insert(
            id: 'dept-$i',
            companyId: 'demo-company',
            name: departments[i],
          ),
        );
    await db
        .into(db.workforceDesignations)
        .insert(
          WorkforceDesignationsCompanion.insert(
            id: 'designation-$i',
            companyId: 'demo-company',
            name: designations[i],
          ),
        );
  }
  for (final a in DemoAuthSource().accounts) {
    final u = a.context.user;
    await db
        .into(db.workforceAccounts)
        .insert(
          WorkforceAccountsCompanion.insert(
            id: u.id,
            companyId: u.companyId,
            displayName: u.displayName,
            email: u.email,
            phone: u.phone!,
            role: u.role.name,
            grants: jsonEncode(
              u.permissions.values.map((p) => p.name).toList(),
            ),
            status: u.status.name,
            credentialPending: const Value(false),
          ),
        );
  }
  const names = [
    'Layla Omar',
    'Omar Farooq',
    'Noor Ali',
    'Ahmed Khan',
    'Sara Rahman',
    'Fatima Zahra',
    'Ali Abbas',
    'Zain Malik',
    'Hana Yusuf',
    'Bilal Ahmed',
    'Ayesha Noor',
    'Imran Syed',
    'Mariam Hassan',
    'Usman Raza',
    'أحمد محمود',
    'سارة حسن',
    'علي يوسف',
    'Nadia Farooq',
    'Danish Shah',
    'Sana Iqbal',
    'Rayan Khan',
    'Farah Ali',
    'Tariq Aziz',
    'Leena Omar',
    'Yusuf Ahmed',
  ];
  final dao = EmployeeDao(db), date = DateTime(2026, 1, 1);
  for (var i = 0; i < names.length; i++) {
    final id = i == 0
        ? 'employee-hr'
        : i == 1
        ? 'employee-manager'
        : i == 2
        ? 'employee-employee'
        : 'employee-${i + 1}';
    final parts = names[i].split(' ');
    final user = i < 3 ? ['hr', 'manager', 'employee'][i] : null;
    await dao.put(
      Employee(
        id: id,
        companyId: 'demo-company',
        employeeCode: 'EMP-${(i + 1).toString().padLeft(4, '0')}',
        firstName: parts.first,
        lastName: parts.skip(1).join(' '),
        email: user != null
            ? '$user@erp.demo'
            : 'person${i + 1}@workforce.demo',
        phone: user != null
            ? ['+15550001003', '+15550001004', '+15550001005'][i]
            : '+1555100${(i + 1).toString().padLeft(4, '0')}',
        departmentId: 'dept-${i % 5}',
        designationId: 'designation-${i % 5}',
        managerId: i >= 2 && i < 12
            ? 'employee-manager'
            : i >= 12
            ? 'employee-hr'
            : null,
        joiningDate: DateTime(2024 + i % 2, 1 + i % 12, 1),
        employmentType: EmploymentType.values[i % 5],
        status: i > 20 ? EmploymentStatus.inactive : EmploymentStatus.active,
        linkedUserId: user == null ? null : 'demo-$user',
        loginEnabled: user != null,
        createdAt: date,
        updatedAt: date,
        syncStatus: EmployeeSyncStatus.synced,
      ),
    );
  }
  await db
      .into(db.workforceSeeds)
      .insert(
        WorkforceSeedsCompanion.insert(companyId: 'demo-company', version: 1),
      );
});
