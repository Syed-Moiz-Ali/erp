/// Builds request paths safely from templates with `{name}` placeholders.
///
/// Values are URL-encoded so identifiers can never break out of a path segment
/// or inject query/fragment characters. Missing placeholders fail fast.
abstract final class ApiPath {
  const ApiPath._();

  static final RegExp _placeholder = RegExp(r'\{(\w+)\}');

  static String resolve(
    String template, [
    Map<String, Object?> params = const {},
  ]) {
    return template.replaceAllMapped(_placeholder, (match) {
      final name = match.group(1)!;
      if (!params.containsKey(name) || params[name] == null) {
        throw ArgumentError.value(
          template,
          'path',
          'Missing path parameter "$name"',
        );
      }
      return Uri.encodeComponent(params[name].toString());
    });
  }
}
