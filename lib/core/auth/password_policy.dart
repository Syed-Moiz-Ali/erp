abstract final class PasswordPolicy {
  static const minimumLength = 8;
  static bool accepts(String value) =>
      value.length >= minimumLength &&
      RegExp(r'[A-Za-z\u0621-\u064A]').hasMatch(value) &&
      RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]').hasMatch(value);
}
