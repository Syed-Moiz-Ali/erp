import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modular_erp/core/api/models/api_error.dart';

part 'api_envelope.freezed.dart';
part 'api_envelope.g.dart';

/// Typed representation of the backend response envelope:
/// `{ success, message, data, errors }`.
///
/// [T] is the shape of `data` (a DTO, a `List<Dto>`, a `PagedResult<Dto>`, or
/// `Object?` when the caller only needs the envelope). This model is a transport
/// DTO and must never be exposed to the UI.
@Freezed(genericArgumentFactories: true)
abstract class ApiEnvelope<T> with _$ApiEnvelope<T> {
  const factory ApiEnvelope({
    required bool success,
    @Default('') String message,
    T? data,
    @Default(<ApiError>[]) List<ApiError> errors,
  }) = _ApiEnvelope<T>;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiEnvelopeFromJson(json, fromJsonT);
}
