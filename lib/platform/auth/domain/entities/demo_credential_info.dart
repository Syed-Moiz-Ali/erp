import 'auth_context.dart';

/// Development-only fixture display; never part of session or auth state.
class DemoCredentialInfo {
  const DemoCredentialInfo({
    required this.role,
    required this.email,
    required this.phone,
    required this.password,
  });
  final AppRole role;
  final String email, phone, password;
  @override
  String toString() => 'DemoCredentialInfo([redacted])';
}
