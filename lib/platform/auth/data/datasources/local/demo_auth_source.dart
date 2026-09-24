import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/domain/entities/demo_credential_info.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';

class DemoAccount {
  const DemoAccount(this.scenario, this.context, this.password);
  final DemoScenario scenario;
  final AuthContext context;
  final String password;
  @override
  String toString() => 'DemoAccount([redacted])';
}

/// Development fixtures only; no persistence of passwords. Accounts are keyed by
/// a [DemoScenario] used purely to seed distinct grant sets — never for
/// authorization.
class DemoAuthSource {
  DemoAuthSource() {
    for (final scenario in DemoScenario.values) {
      final username = switch (scenario) {
        DemoScenario.platformAdmin => 'admin',
        DemoScenario.companyAdmin => 'company',
        DemoScenario.hr => 'hr',
        DemoScenario.manager => 'manager',
        DemoScenario.employee => 'employee',
      };
      final name = switch (scenario) {
        DemoScenario.platformAdmin => 'Ahmed Hassan',
        DemoScenario.companyAdmin => 'Sara Khalid',
        DemoScenario.hr => 'Layla Omar',
        DemoScenario.manager => 'Omar Farooq',
        DemoScenario.employee => 'Noor Ali',
      };
      final password = switch (scenario) {
        DemoScenario.platformAdmin => 'Admin@123',
        DemoScenario.companyAdmin => 'Company@123',
        DemoScenario.hr => 'Hr@123',
        DemoScenario.manager => 'Manager@123',
        DemoScenario.employee => 'Employee@123',
      };
      final user = UserAccount(
        id: 'demo-$username',
        displayName: name,
        email: '$username@erp.demo',
        phone: '+1555000100${scenario.index + 1}',
        companyId: 'demo-company',
        permissions: demoScenarioGrants(scenario),
        status: AccountStatus.active,
      );
      _accounts[user.id] = DemoAccount(
        scenario,
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
              'services',
            },
          ),
          employeeReference:
              scenario == DemoScenario.platformAdmin ||
                  scenario == DemoScenario.companyAdmin
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
          scenario: a.scenario,
          displayName: a.context.user.displayName,
          email: a.context.user.email,
          phone: a.context.user.phone!,
          password: a.password,
        ),
      )
      .toList(growable: false);
  DemoAccount? findByScenario(DemoScenario scenario) {
    for (final account in _accounts.values) {
      if (account.scenario == scenario) return account;
    }
    return null;
  }

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
    _accounts[id] = DemoAccount(account.scenario, account.context, replacement);
    return true;
  }
}
