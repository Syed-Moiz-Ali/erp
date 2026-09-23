import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/validation/app_validation.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

sealed class PasswordEvent {
  const PasswordEvent();
}

final class PasswordResetRequested extends PasswordEvent {
  const PasswordResetRequested(this.identifier);
  final String identifier;
}

final class PasswordChangeRequested extends PasswordEvent {
  const PasswordChangeRequested(
    this.current,
    this.replacement,
    this.confirmation,
  );
  final String current, replacement, confirmation;
  @override
  String toString() => 'PasswordChangeRequested([redacted])';
}

enum PasswordStatus { idle, submitting, success, failure }

class PasswordState {
  const PasswordState(this.status, {this.failure});
  final PasswordStatus status;
  final Failure? failure;
}

/// Page-scoped business workflows; authentication remains owned by AuthBloc.
class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  PasswordBloc(this.repository)
    : super(const PasswordState(PasswordStatus.idle)) {
    on<PasswordEvent>((event, emit) async {
      emit(const PasswordState(PasswordStatus.submitting));
      Result<void> result;
      switch (event) {
        case PasswordResetRequested(:final identifier):
          final parsed = AuthIdentifier.parse(identifier);
          result = parsed == null
              ? const Failed(
                  Failure(
                    code: 'invalid_identifier',
                    kind: FailureKind.invalidData,
                  ),
                )
              : await repository.requestPasswordReset(parsed);
        case PasswordChangeRequested(
          :final current,
          :final replacement,
          :final confirmation,
        ):
          if (AppValidation.password(current) != null ||
              AppValidation.newPassword(replacement, current) != null ||
              AppValidation.confirmPassword(confirmation, replacement) !=
                  null) {
            result = const Failed(
              Failure(
                code: 'password_policy',
                kind: FailureKind.passwordPolicy,
              ),
            );
          } else {
            result = await repository.changePassword(current, replacement);
          }
      }
      switch (result) {
        case Success<void>():
          emit(const PasswordState(PasswordStatus.success));
        case Failed<void>(:final failure):
          emit(PasswordState(PasswordStatus.failure, failure: failure));
      }
    }, transformer: (events, mapper) => events.asyncExpand(mapper));
  }
  final AuthRepository repository;
  bool _queued = false;
  @override
  void add(PasswordEvent event) {
    if (_queued) return;
    _queued = true;
    super.add(event);
  }

  @override
  void onTransition(Transition<PasswordEvent, PasswordState> transition) {
    if (transition.nextState.status != PasswordStatus.submitting) {
      _queued = false;
    }
    super.onTransition(transition);
  }
}
