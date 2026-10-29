import 'package:modular_erp/core/errors/result.dart';

class LiveEmployee {
  const LiveEmployee({
    required this.id,
    required this.code,
    required this.name,
    required this.raw,
    this.branchId,
    this.branchName,
    this.departmentId,
    this.departmentName,
    this.nationalityId,
    this.nationalityName,
    this.statusId,
    this.statusName,
    this.designation,
    this.joiningDate,
    this.email,
    this.phone,
    this.basicSalary,
    this.dateOfBirth,
    this.maritalStatus,
    this.employeeType,
    this.gratuity,
    this.workingHours,
    this.transportation,
    this.accommodation,
    this.totalSalary,
    this.loginEnabled = false,
    this.canLogin = false,
    this.loginId,
    this.loginMobile,
    this.loginUserId,
  });

  final int id;
  final String code, name;
  final Map<String, dynamic> raw;
  final int? branchId, departmentId, nationalityId, statusId;
  final String? branchName, departmentName, nationalityName, statusName;
  final String? designation;
  final String? joiningDate;
  final String? email;
  final String? phone;
  final double? basicSalary;
  final String? dateOfBirth, maritalStatus, employeeType, gratuity;
  final double? workingHours, transportation, accommodation, totalSalary;
  final bool loginEnabled, canLogin;
  final String? loginId, loginMobile;
  final int? loginUserId;

  bool get isActive => statusId == 1;
}

class LiveEmployeeDraft {
  const LiveEmployeeDraft({
    this.name = '',
    this.branchId,
    this.departmentId,
    this.nationalityId,
    this.statusId = 1,
    this.designation = '',
    this.joiningDate,
    this.email = '',
    this.phone = '',
    this.basicSalary = 0,
    this.dateOfBirth = '',
    this.maritalStatus = '',
    this.employeeType = '',
    this.gratuity = '',
    this.workingHours = 0,
    this.transportation = 0,
    this.accommodation = 0,
    this.loginEnabled = false,
    this.loginId = '',
    this.loginMobile = '',
    this.loginPassword = '',
    this.loginBranchIds = const [],
  });

  final String name, designation, email, phone;
  final int? branchId, departmentId, nationalityId, statusId;
  final String? joiningDate;
  final double basicSalary;
  final String dateOfBirth, maritalStatus, employeeType, gratuity;
  final double workingHours, transportation, accommodation;
  final bool loginEnabled;
  final String loginId, loginMobile, loginPassword;
  final List<int> loginBranchIds;

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['employeeName'] = 'required';
    if (branchId == null) errors['branchId'] = 'required';
    if (departmentId == null) errors['departmentId'] = 'required';
    if (nationalityId == null) errors['nationalityId'] = 'required';
    if (joiningDate == null || joiningDate!.isEmpty) {
      errors['joiningDate'] = 'required';
    }
    if (loginEnabled) {
      if (loginId.trim().isEmpty) errors['login.loginId'] = 'required';
      if (loginMobile.trim().isEmpty) errors['login.mobileNo'] = 'required';
      if (loginPassword.isNotEmpty && loginPassword.length < 6) {
        errors['login.password'] = 'password';
      }
      if (loginBranchIds.isEmpty) errors['login.branchIds'] = 'required';
    }
    return Map.unmodifiable(errors);
  }

  Map<String, dynamic> toBody({Map<String, dynamic>? base}) {
    final body = <String, dynamic>{...?base};
    body['employeeName'] = name.trim();
    body['branchId'] = branchId;
    body['departmentId'] = departmentId;
    body['nationalityId'] = nationalityId;
    body['statusId'] = statusId;
    body['designation'] = designation.trim().isEmpty
        ? null
        : designation.trim();
    body['joiningDate'] = joiningDate;
    body['email'] = email.trim().isEmpty ? null : email.trim();
    body['uaeContactNumber'] = phone.trim().isEmpty ? null : phone.trim();
    body['basicSalary'] = basicSalary;
    body['dateOfBirth'] = dateOfBirth.trim().isEmpty
        ? null
        : dateOfBirth.trim();
    body['maritalStatus'] = maritalStatus.trim().isEmpty
        ? null
        : maritalStatus.trim();
    body['employeeType'] = employeeType.trim().isEmpty
        ? null
        : employeeType.trim();
    body['gratuity'] = gratuity.trim().isEmpty ? null : gratuity.trim();
    body['workingHours'] = workingHours;
    body['transportation'] = transportation;
    body['accommodation'] = accommodation;
    if (loginEnabled) {
      final login = <String, dynamic>{
        ...?(base?['login'] as Map?)?.cast<String, dynamic>(),
      }..remove('userType');
      login['enabled'] = true;
      login['loginId'] =
          (base?['login'] as Map?)?['loginId'] as String? ?? email.trim();
      login['mobileNo'] = loginMobile.trim();
      login['branchIds'] = loginBranchIds;
      if (loginPassword.isNotEmpty) login['password'] = loginPassword;
      body['login'] = login;
    }
    return body;
  }
}

class LiveEmployeeLookups {
  const LiveEmployeeLookups({
    required this.branches,
    required this.departments,
    required this.nationalities,
    required this.statuses,
    this.maritalStatuses = const [],
    this.employeeTypes = const [],
    this.gratuityTypes = const [],
  });
  final List<Lookup> branches, departments, nationalities, statuses;
  final List<String> maritalStatuses, employeeTypes, gratuityTypes;
}

class Lookup {
  const Lookup(this.id, this.name);
  final int id;
  final String name;
}

/// Maps backend employee write failures to form field keys. Unknown failures
/// return an empty map so the UI can show a general message.
Map<String, String> mapEmployeeServerError(Failure failure) {
  final field = failure.field;
  if (field != null && field.isNotEmpty) {
    return {field: failure.serverMessage ?? failure.code};
  }
  if (failure.code == 'USER_DUPLICATE_LOGINID') {
    return {'login.loginId': failure.serverMessage ?? failure.code};
  }
  if (failure.code == 'USER_DUPLICATE_MOBILE') {
    return {'login.mobileNo': failure.serverMessage ?? failure.code};
  }
  return const {};
}
