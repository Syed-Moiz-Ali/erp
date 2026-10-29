import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';
part 'api_error.g.dart';

/// Wire-level error entry from the backend envelope `errors[]` array.
///
/// This is a transport model only. It never carries user-facing copy into
/// domain code; [ApiErrorCodes] maps [code] to a safe `Failure`.
@freezed
abstract class ApiError with _$ApiError {
  const factory ApiError({
    required String code,
    required String message,
    String? field,
  }) = _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}
