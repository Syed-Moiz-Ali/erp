import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';

String employmentTypeLabel(EmploymentType type, AppLocalizations l) =>
    switch (type) {
      EmploymentType.fullTime => l.empFullTime,
      EmploymentType.partTime => l.empPartTime,
      EmploymentType.contract => l.empContract,
      EmploymentType.intern => l.empIntern,
      EmploymentType.temporary => l.empTemporary,
    };
String employeeSortLabel(EmployeeSort sort, AppLocalizations l) =>
    switch (sort) {
      EmployeeSort.nameAscending => l.empNameAsc,
      EmployeeSort.nameDescending => l.empNameDesc,
      EmployeeSort.code => l.empCode,
      EmployeeSort.newestJoined => l.empNewest,
      EmployeeSort.oldestJoined => l.empOldest,
    };
String employeeFailure(Failure failure, AppLocalizations l) =>
    switch (failure.code) {
      'required' => l.empRequired,
      'email' => l.empInvalidEmail,
      'phone' => l.empInvalidPhone,
      'duplicateEmail' => l.empDuplicateEmail,
      'duplicatePhone' => l.empDuplicatePhone,
      'manager' => l.empInvalidManager,
      'reference' => l.empInvalidReference,
      'assignment' => l.cfgAssignmentError,
      'denied' => l.shellAccessMessage,
      _ => l.empStorageError,
    };
String referenceLabel(
  List<WorkforceReference>? refs,
  String? id,
  AppLocalizations l,
) => id == null
    ? l.empUnassigned
    : refs?.where((r) => r.id == id).firstOrNull?.name ?? id;
