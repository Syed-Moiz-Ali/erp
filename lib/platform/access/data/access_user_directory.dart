import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';

/// Source of company users for the Users & Access list.
abstract interface class AccessUserDirectory {
  Stream<List<AccessUserListItem>> watchUsers({required String companyId});
}

/// Persistent directory backed by company accounts + linked employees.
class LocalAccessUserDirectory implements AccessUserDirectory {
  LocalAccessUserDirectory(this.database);
  final AppDatabase database;

  @override
  Stream<List<AccessUserListItem>> watchUsers({required String companyId}) {
    final query = database.select(database.workforceAccounts)
      ..where((a) => a.companyId.equals(companyId));
    return query.watch().asyncMap((accounts) async {
      final employees = await (database.select(
        database.workforceEmployees,
      )..where((e) => e.companyId.equals(companyId))).get();
      final byUserId = {
        for (final employee in employees)
          if (employee.linkedUserId != null) employee.linkedUserId!: employee,
      };
      return [
        for (final account in accounts)
          AccessUserListItem(
            userId: account.id,
            displayName: account.displayName,
            email: account.email,
            hasLogin: !account.credentialPending,
            accountStatus: account.status,
            employeeId: byUserId[account.id]?.id,
            employeeCode: byUserId[account.id]?.employeeCode,
            isEmployeeActive:
                (byUserId[account.id]?.status ?? 'active') == 'active',
          ),
      ];
    });
  }
}
