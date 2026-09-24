import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';

/// Development-only fixture display; never part of session or auth state. The
/// [scenario] is a demo persona label used to describe what the account can
/// access — it is not authorization.
class DemoCredentialInfo {
  const DemoCredentialInfo({
    required this.scenario,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.password,
  });
  final DemoScenario scenario;
  final String displayName, email, phone, password;
  @override
  String toString() => 'DemoCredentialInfo([redacted])';
}
