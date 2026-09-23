import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';

sealed class EmployeeFormEvent {
  const EmployeeFormEvent();
}

class EmployeeFormInitialized extends EmployeeFormEvent {
  const EmployeeFormInitialized();
}

class EmployeeDraftChanged extends EmployeeFormEvent {
  const EmployeeDraftChanged(this.update);
  final EmployeeDraft Function(EmployeeDraft) update;
}

class EmployeeSubmitted extends EmployeeFormEvent {
  const EmployeeSubmitted();
}

class EmployeeFormState {
  const EmployeeFormState({
    this.draft = const EmployeeDraft(),
    this.original = const EmployeeDraft(),
    this.references,
    this.employeeCode,
    this.account,
    this.loading = true,
    this.saving = false,
    this.validationRequested = false,
    this.failure,
    this.savedId,
  });
  final EmployeeDraft draft, original;
  final EmployeeReferences? references;
  final bool loading, saving, validationRequested;
  final Failure? failure;
  final String? savedId, employeeCode;
  final EmployeeAccountAccess? account;
  Map<String, String> get fieldErrors {
    if (!validationRequested) return const {};
    final errors = <String, String>{};
    if (draft.firstName.trim().isEmpty) errors['firstName'] = 'required';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(draft.email.trim())) {
      errors['email'] = 'email';
    }
    final digits = draft.phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7 || digits.length > 15) errors['phone'] = 'phone';
    if (draft.departmentId == null) errors['departmentId'] = 'required';
    if (draft.designationId == null) errors['designationId'] = 'required';
    if (draft.joiningDate == null ||
        draft.joiningDate!.isAfter(DateTime.now())) {
      errors['joiningDate'] = 'required';
    }
    if (failure?.code == 'duplicateEmail') errors['email'] = 'duplicateEmail';
    if (failure?.code == 'duplicatePhone') errors['phone'] = 'duplicatePhone';
    if (failure?.code == 'manager') errors['managerId'] = 'manager';
    if (failure?.code == 'accountRole') errors['accountRole'] = 'accountRole';
    return Map.unmodifiable(errors);
  }

  bool get dirty => draft != original && savedId == null;
}

class EmployeeFormBloc extends Bloc<EmployeeFormEvent, EmployeeFormState> {
  EmployeeFormBloc(this.repository, this.context, {this.id})
    : super(const EmployeeFormState()) {
    on<EmployeeFormEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final EmployeeRepository repository;
  final AuthContext context;
  final String? id;
  bool _submissionQueued = false;
  @override
  void add(EmployeeFormEvent event) {
    if (isClosed) return;
    if (event is EmployeeSubmitted) {
      if (_submissionQueued) return;
      _submissionQueued = true;
    }
    super.add(event);
  }

  Future<void> _handle(
    EmployeeFormEvent event,
    Emitter<EmployeeFormState> emit,
  ) async {
    switch (event) {
      case EmployeeFormInitialized():
        final refs = await repository.getReferences(context, excludingId: id);
        EmployeeDraft draft = const EmployeeDraft();
        String? employeeCode;
        EmployeeAccountAccess? linkedAccount;
        if (id != null) {
          final existing = await repository.getEmployeeById(context, id!);
          if (existing is! Success<Employee?> || existing.value == null) {
            emit(
              EmployeeFormState(
                loading: false,
                failure: existing is Failed<Employee?>
                    ? existing.failure
                    : const Failure(code: 'notFound'),
              ),
            );
            return;
          }
          final e = existing.value!,
              account = await repository.getLinkedAccount(context, id!);
          employeeCode = e.employeeCode;
          linkedAccount = account is Success<EmployeeAccountAccess?>
              ? account.value
              : null;
          draft = EmployeeDraft(
            firstName: e.firstName,
            middleName: e.middleName,
            lastName: e.lastName,
            email: e.email,
            phone: e.phone,
            departmentId: e.departmentId,
            designationId: e.designationId,
            managerId: e.managerId,
            shiftId: e.shiftId,
            workLocationId: e.workLocationId,
            attendancePolicyId: e.attendancePolicyId,
            joiningDate: e.joiningDate,
            employmentType: e.employmentType,
            status: e.status,
            loginEnabled: e.loginEnabled,
            accountRole: account is Success<EmployeeAccountAccess?>
                ? account.value?.user.role ?? AppRole.employee
                : AppRole.employee,
          );
        }
        emit(
          EmployeeFormState(
            draft: draft,
            original: draft,
            employeeCode: employeeCode,
            account: linkedAccount,
            loading: false,
            references: refs is Success<EmployeeReferences> ? refs.value : null,
            failure: refs is Failed<EmployeeReferences> ? refs.failure : null,
          ),
        );
      case EmployeeDraftChanged(:final update):
        final draft = update(state.draft);
        if (state.saving || state.loading) return;
        emit(
          EmployeeFormState(
            draft: draft,
            original: state.original,
            employeeCode: state.employeeCode,
            account: state.account,
            references: state.references,
            loading: false,
            validationRequested: state.validationRequested,
          ),
        );
      case EmployeeSubmitted():
        if (state.loading || state.savedId != null) {
          _submissionQueued = false;
          return;
        }
        emit(
          EmployeeFormState(
            draft: state.draft,
            original: state.original,
            employeeCode: state.employeeCode,
            account: state.account,
            references: state.references,
            loading: false,
            saving: true,
            validationRequested: true,
          ),
        );
        final result = await repository.saveEmployee(
          context,
          state.draft,
          id: id,
        );
        emit(
          EmployeeFormState(
            draft: state.draft,
            original: state.original,
            employeeCode: state.employeeCode,
            account: state.account,
            references: state.references,
            loading: false,
            validationRequested: true,
            failure: result is Failed<Employee> ? result.failure : null,
            savedId: result is Success<Employee> ? result.value.id : null,
          ),
        );
        _submissionQueued = false;
    }
  }
}
