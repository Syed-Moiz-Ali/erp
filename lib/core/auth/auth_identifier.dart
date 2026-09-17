enum AuthIdentifierType { email, phone }

class AuthIdentifier {
  const AuthIdentifier._(this.value, this.type);
  final String value;
  final AuthIdentifierType type;
  static AuthIdentifier? parse(String input) {
    final value = input.trim();
    if (RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return AuthIdentifier._(value.toLowerCase(), AuthIdentifierType.email);
    }
    final digits = value.replaceAll(RegExp(r'[\s()\-]'), '');
    if (RegExp(r'^\+?[0-9]{7,15}$').hasMatch(digits)) {
      return AuthIdentifier._(digits, AuthIdentifierType.phone);
    }
    return null;
  }

  @override
  String toString() => 'AuthIdentifier([redacted])';
}
