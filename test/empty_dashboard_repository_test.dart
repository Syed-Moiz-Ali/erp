import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/dashboard/data/empty_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

AuthContext _context() => AuthContext(
  user: UserAccount(
    id: '8',
    displayName: 'Admin',
    email: 'admin',
    companyId: '1',
    permissions: PermissionSet(const <AppPermission>[
      AppPermission.employeeViewAll,
    ]),
    status: AccountStatus.active,
  ),
  company: const CompanyContext(
    id: '1',
    name: 'Company',
    code: 'ORG-1',
    timezone: 'Asia/Dubai',
    defaultLocale: 'en',
    enabledModules: {'employees', 'settings'},
  ),
);

void main() {
  test('backend dashboard is empty, real and never demo data', () async {
    final result = await const EmptyDashboardRepository().load(_context());
    expect(result, isA<Success<DashboardSummary>>());
    final summary = (result as Success<DashboardSummary>).value;
    expect(summary.isEmpty, isTrue);
    expect(summary.isDemo, isFalse);
    expect(summary.scope, DashboardScope.none);
    expect(summary.metrics, isEmpty);
    expect(summary.activities, isEmpty);
    expect(summary.alerts, isEmpty);
    expect(summary.status, isNull);
    expect(summary.today, isNull);
  });
}
