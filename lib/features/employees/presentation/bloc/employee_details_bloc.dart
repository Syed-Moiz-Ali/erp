import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/auth_context.dart';
import '../../domain/employee.dart';
import '../../domain/employee_repository.dart';

sealed class EmployeeDetailsEvent {
  const EmployeeDetailsEvent();
}

class EmployeeDetailsStarted extends EmployeeDetailsEvent {
  const EmployeeDetailsStarted();
}

class EmployeeDetailsStatusRequested extends EmployeeDetailsEvent {
  const EmployeeDetailsStatusRequested(this.active);
  final bool active;
}

class _Updated extends EmployeeDetailsEvent {
  const _Updated(this.result);
  final Result<Employee?> result;
}

class EmployeeDetailsState {
  const EmployeeDetailsState({
    this.employee,
    this.references,
    this.account,
    this.loading = true,
    this.busy = false,
    this.failure,
    this.saved = false,
  });
  final Employee? employee;
  final EmployeeReferences? references;
  final EmployeeAccountAccess? account;
  final bool loading, busy, saved;
  final Failure? failure;
}

class EmployeeDetailsBloc
    extends Bloc<EmployeeDetailsEvent, EmployeeDetailsState> {
  EmployeeDetailsBloc(this.repository, this.context, this.id)
    : super(const EmployeeDetailsState()) {
    on<EmployeeDetailsEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final EmployeeRepository repository;
  final AuthContext context;
  final String id;
  StreamSubscription<Result<Employee?>>? _subscription;
  Future<void> _handle(
    EmployeeDetailsEvent event,
    Emitter<EmployeeDetailsState> emit,
  ) async {
    switch (event) {
      case EmployeeDetailsStarted():
        await _subscription?.cancel();
        _subscription = repository
            .watchEmployee(context, id)
            .listen(
              (r) {
                if (!isClosed) add(_Updated(r));
              },
              onError: (Object _) {
                if (!isClosed) {
                  add(const _Updated(Failed(Failure(code: 'storage'))));
                }
              },
            );
      case _Updated(:final result):
        final refs = await repository.getReferences(context),
            account = await repository.getLinkedAccount(context, id);
        emit(
          EmployeeDetailsState(
            employee: result is Success<Employee?>
                ? result.value
                : state.employee,
            loading: false,
            references: refs is Success<EmployeeReferences>
                ? refs.value
                : state.references,
            account: account is Success<EmployeeAccountAccess?>
                ? account.value
                : null,
            failure: result is Failed<Employee?>
                ? result.failure
                : refs is Failed<EmployeeReferences>
                ? refs.failure
                : account is Failed<EmployeeAccountAccess?>
                ? account.failure
                : null,
          ),
        );
      case EmployeeDetailsStatusRequested(:final active):
        if (state.busy) return;
        emit(
          EmployeeDetailsState(
            employee: state.employee,
            references: state.references,
            account: state.account,
            loading: false,
            busy: true,
          ),
        );
        final result = await repository.setActive(context, id, active);
        emit(
          EmployeeDetailsState(
            employee: state.employee,
            references: state.references,
            account: state.account,
            loading: false,
            saved: result is Success<void>,
            failure: result is Failed<void> ? result.failure : null,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
