import 'package:freezed_annotation/freezed_annotation.dart';

part 'paged_result.freezed.dart';
part 'paged_result.g.dart';

/// Reusable paged payload matching the backend list contract:
/// `{ items, page, pageSize, totalItems, totalPages }`.
///
/// Used as the `data` type of [ApiEnvelope] for list endpoints. This model is a
/// transport DTO; module layers map [items] into domain entities.
@Freezed(genericArgumentFactories: true)
abstract class PagedResult<T> with _$PagedResult<T> {
  const PagedResult._();

  const factory PagedResult({
    required List<T> items,
    @Default(1) int page,
    @Default(0) int pageSize,
    @Default(0) int totalItems,
    @Default(0) int totalPages,
  }) = _PagedResult<T>;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PagedResultFromJson(json, fromJsonT);

  bool get isEmpty => items.isEmpty;
  bool get hasMore => page < totalPages;
}
