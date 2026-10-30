import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_form_bloc.dart';

EmployeeReferences _references({required bool backend}) => EmployeeReferences(
  departments: const [WorkforceReference('2', 'accounts')],
  designations: const [WorkforceReference('tech', 'Technician')],
  managers: const [],
  branches: backend ? const [WorkforceReference('1', 'Bitlogix')] : const [],
  nationalities: backend ? const [WorkforceReference('99', 'INDIA')] : const [],
  maritalStatuses: backend ? const ['Single', 'Married'] : const [],
  gratuityTypes: backend ? const ['Limited Contract'] : const [],
);

void main() {
  test('backend lookups require branch and nationality', () {
    final state = EmployeeFormState(
      draft: EmployeeDraft(
        firstName: 'QA',
        email: 'qa@example.com',
        phone: '0500000000',
        departmentId: '2',
        designationId: 'tech',
        joiningDate: DateTime(2026, 10, 1),
      ),
      original: const EmployeeDraft(),
      references: _references(backend: true),
      loading: false,
      validationRequested: true,
    );

    expect(state.fieldErrors['branchId'], 'required');
    expect(state.fieldErrors['nationalityId'], 'required');
  });

  test('backend login requires id, mobile, password policy and branches', () {
    final state = EmployeeFormState(
      draft: EmployeeDraft(
        firstName: 'QA',
        email: 'qa@example.com',
        phone: '0500000000',
        departmentId: '2',
        designationId: 'tech',
        joiningDate: DateTime(2026, 10, 1),
        branchId: '1',
        nationalityId: '99',
        loginEnabled: true,
        loginPassword: '123',
      ),
      original: const EmployeeDraft(),
      references: _references(backend: true),
      loading: false,
      validationRequested: true,
    );

    expect(state.fieldErrors['login.loginId'], 'required');
    expect(state.fieldErrors['login.mobileNo'], 'required');
    expect(state.fieldErrors['login.password'], 'password');
    expect(state.fieldErrors['login.branchIds'], 'required');
  });

  test('demo references keep the original form requirements', () {
    final state = EmployeeFormState(
      draft: EmployeeDraft(
        firstName: 'QA',
        email: 'qa@example.com',
        phone: '0500000000',
        departmentId: '2',
        designationId: 'tech',
        joiningDate: DateTime(2026, 10, 1),
      ),
      original: const EmployeeDraft(),
      references: _references(backend: false),
      loading: false,
      validationRequested: true,
    );

    expect(state.fieldErrors.containsKey('branchId'), isFalse);
    expect(state.fieldErrors.containsKey('nationalityId'), isFalse);
    expect(state.references!.hasBackendProfileLookups, isFalse);
  });
}
