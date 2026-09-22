import '../../../domain/policies/account_role_templates.dart';
import '../../../domain/entities/demo_credential_info.dart';
import '../../../../../core/security/app_permission.dart';
import '../../../domain/entities/auth_context.dart';
import '../../../../../core/auth/auth_identifier.dart';

class DemoAccount {
  const DemoAccount(this.context, this.password);
  final AuthContext context;
  final String password;
  @override
  String toString() => 'DemoAccount([redacted])';
}

/// Development fixtures only; no persistence of passwords.
class DemoAuthSource {
  DemoAuthSource() {
    for (final role in AppRole.values) {
      final username = switch (role) {
        AppRole.superAdmin => 'admin',
        AppRole.companyAdmin => 'company',
        AppRole.hr => 'hr',
        AppRole.manager => 'manager',
        AppRole.employee => 'employee',
      };
      final name = switch (role) {
        AppRole.superAdmin => 'Ahmed Hassan',
        AppRole.companyAdmin => 'Sara Khalid',
        AppRole.hr => 'Layla Omar',
        AppRole.manager => 'Omar Farooq',
        AppRole.employee => 'Noor Ali',
      };
      final password = switch (role) {
        AppRole.superAdmin => 'Admin@123',
        AppRole.companyAdmin => 'Company@123',
        AppRole.hr => 'Hr@123',
        AppRole.manager => 'Manager@123',
        AppRole.employee => 'Employee@123',
      };
      final user = UserAccount(
        id: 'demo-$username',
        displayName: name,
        email: '$username@erp.demo',
        phone: '+1555000100${role.index + 1}',
        companyId: 'demo-company',
        role: role,
        permissions: demoPermissions(role),
        status: AccountStatus.active,
      );
      _accounts[user.id] = DemoAccount(
        AuthContext(
          user: user,
          company: const CompanyContext(
            id: 'demo-company',
            name: 'Demo ERP Company',
            code: 'DEMO',
            timezone: 'Asia/Dubai',
            defaultLocale: 'en',
            enabledModules: {
              'dashboard',
              'employees',
              'attendance',
              'leave',
              'reports',
              'settings',
            },
          ),
          employeeReference:
              role == AppRole.superAdmin || role == AppRole.companyAdmin
              ? null
              : EmployeeReference(
                  id: 'employee-$username',
                  userAccountId: user.id,
                  companyId: user.companyId,
                ),
        ),
        password,
      );
    }
  }
  final Map<String, DemoAccount> _accounts = {};
  List<DemoAccount> get accounts => List.unmodifiable(_accounts.values);
  List<DemoCredentialInfo> get credentials => accounts
      .map(
        (a) => DemoCredentialInfo(
          role: a.context.user.role,
          email: a.context.user.email,
          phone: a.context.user.phone!,
          password: a.password,
        ),
      )
      .toList(growable: false);
  DemoAccount? findUser(String id) => _accounts[id];
  DemoAccount? authenticate(AuthIdentifier identifier, String password) {
    for (final account in _accounts.values) {
      final user = account.context.user;
      final matches = identifier.type == AuthIdentifierType.email
          ? user.email == identifier.value
          : user.phone?.replaceFirst('+', '') ==
                identifier.value.replaceFirst('+', '');
      if (matches &&
          account.password == password &&
          user.status == AccountStatus.active) {
        return account;
      }
    }
    return null;
  }

  bool changePassword(String id, String current, String replacement) {
    final account = _accounts[id];
    if (account == null || account.password != current) return false;
    _accounts[id] = DemoAccount(account.context, replacement);
    return true;
  }
}

PermissionSet demoPermissions(AppRole role) => permissionsForRole(role);
