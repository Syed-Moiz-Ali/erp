import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/result.dart';
import '../../auth/domain/entities/auth_context.dart';
import '../../auth/domain/policies/user_capability.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../employees/domain/employee.dart';
import '../../employees/domain/employee_repository.dart';
import '../domain/my_profile_view_model.dart';

class MyProfileState {
  const MyProfileState({this.data, this.loading = true, this.failure});
  final MyProfileViewModel? data;
  final bool loading;
  final Failure? failure;
}

/// Aggregates account + linked employee into [MyProfileViewModel]. Reactive to
/// session and employee changes; issues no employee queries when unlinked.
class MyProfileCubit extends Cubit<MyProfileState> {
  MyProfileCubit(this.auth, this.employees) : super(const MyProfileState());

  final AuthRepository auth;
  final EmployeeRepository? employees;
  StreamSubscription<AuthContext?>? _authSub;
  StreamSubscription<Result<Employee?>>? _employeeSub;

  Future<void> start() async {
    _authSub = auth.sessionChanges.listen((_) => unawaited(_rebind()));
    await _rebind();
  }

  Future<void> refresh() => _rebind();

  Future<void> _rebind() async {
    await _employeeSub?.cancel();
    _employeeSub = null;
    if (isClosed) return;
    final session = await auth.checkSession();
    if (isClosed) return;
    final account = session is Success<AuthContext?> ? session.value : null;
    if (account == null) {
      emit(const MyProfileState(loading: false));
      return;
    }
    final capabilities = const UserCapabilityResolver().forAuthContext(account);
    final reference = account.employeeReference;
    final repository = employees;
    if (reference == null || repository == null) {
      emit(
        MyProfileState(
          loading: false,
          data: MyProfileViewModel(
            account: account,
            capabilities: capabilities,
          ),
        ),
      );
      return;
    }
    final referencesResult = await repository.getReferences(account);
    if (isClosed) return;
    final references = referencesResult is Success<EmployeeReferences>
        ? referencesResult.value
        : null;
    _employeeSub = repository
        .watchEmployee(account, reference.id)
        .listen(
          (result) {
            if (isClosed) return;
            switch (result) {
              case Success<Employee?>(:final value):
                emit(
                  MyProfileState(
                    loading: false,
                    data: MyProfileViewModel(
                      account: account,
                      capabilities: capabilities,
                      employee: value,
                      references: references,
                      employeeUnavailable: value == null,
                    ),
                  ),
                );
              case Failed<Employee?>(:final failure):
                emit(
                  MyProfileState(
                    loading: false,
                    failure: failure,
                    data: MyProfileViewModel(
                      account: account,
                      capabilities: capabilities,
                      references: references,
                    ),
                  ),
                );
            }
          },
          onError: (_) {
            if (!isClosed) {
              emit(
                MyProfileState(
                  loading: false,
                  data: MyProfileViewModel(
                    account: account,
                    capabilities: capabilities,
                    references: references,
                  ),
                ),
              );
            }
          },
        );
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    await _employeeSub?.cancel();
    return super.close();
  }
}
