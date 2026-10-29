enum AuthIdentifierType { email, phone, loginId }

/// A normalized sign-in identifier.
///
/// The backend authenticates with a `loginId` (for example `Admin`), so a plain
/// login id is accepted in addition to the email/phone forms used by demo mode.
class AuthIdentifier {
  const AuthIdentifier._(this.value, this.type);
  final String value;
  final AuthIdentifierType type;

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phone = RegExp(r'^\+?[0-9]{7,15}$');

  /// Backend login ids: no whitespace, 3-100 characters, letters/digits and
  /// `._@-`. This intentionally does not overlap email or phone parsing.
  static final RegExp _loginId = RegExp(r'^[A-Za-z0-9._@-]{3,100}$');

  static AuthIdentifier? parse(String input) {
    final value = input.trim();
    if (value.isEmpty) return null;
    if (_email.hasMatch(value)) {
      return AuthIdentifier._(value.toLowerCase(), AuthIdentifierType.email);
    }
    final digits = value.replaceAll(RegExp(r'[\s()\-]'), '');
    if (_phone.hasMatch(digits)) {
      return AuthIdentifier._(digits, AuthIdentifierType.phone);
    }
    if (_loginId.hasMatch(value)) {
      // Login ids are case-sensitive; preserve the value verbatim.
      return AuthIdentifier._(value, AuthIdentifierType.loginId);
    }
    return null;
  }

  @override
  String toString() => 'AuthIdentifier([redacted])';
}
