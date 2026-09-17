import 'package:freezed_annotation/freezed_annotation.dart';
part 'result.freezed.dart';

enum FailureKind {
  invalidCredentials,
  sessionStorage,
  demoDisabled,
  currentPassword,
  passwordPolicy,
  server,
  unknown,
  timeout,
  offline,
  cancelled,
  sessionExpired,
  request,
  invalidData,
  locationDisabled,
  locationPermission,
  locationUnavailable,
  storageWrite,
  storageUpdate,
  sync,
  preferencesRead,
  preferencesWrite,
}

@freezed
sealed class Failure with _$Failure {
  const factory Failure({
    required String code,
    @Default(FailureKind.unknown) FailureKind kind,
    @Default(false) bool retryable,
  }) = _Failure;
}

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;
}
