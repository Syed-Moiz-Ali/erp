import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';

class LiveEmployeeDto {
  const LiveEmployeeDto(this.json);
  final Map<String, dynamic> json;

  factory LiveEmployeeDto.fromJson(Map<String, dynamic> json) =>
      LiveEmployeeDto(json);

  LiveEmployee toDomain() {
    final login = json['login'] is Map
        ? (json['login'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final loginBranchIds = (login['branchIds'] as List? ?? const [])
        .whereType<num>()
        .map((value) => value.toInt())
        .toList();
    return LiveEmployee(
      id: (json['employeeId'] as num).toInt(),
      code: json['employeeCode'] as String? ?? '',
      name: json['employeeName'] as String? ?? '',
      raw: json,
      branchId: (json['branchId'] as num?)?.toInt(),
      branchName: json['branchName'] as String?,
      departmentId: (json['departmentId'] as num?)?.toInt(),
      departmentName: json['departmentName'] as String?,
      nationalityId: (json['nationalityId'] as num?)?.toInt(),
      nationalityName: json['nationalityName'] as String?,
      statusId: (json['statusId'] as num?)?.toInt(),
      statusName: json['statusName'] as String?,
      designation: json['designation'] as String?,
      reportingManager: json['reportingManager'] as String?,
      joiningDate: json['joiningDate'] as String?,
      resignationDate: json['resignationDate'] as String?,
      organization: json['organization'] as String?,
      email: json['email'] as String?,
      phone: json['uaeContactNumber'] as String?,
      additionalUaeContactNumber: json['additionalUaeContactNumber'] as String?,
      uaeAddress: json['uaeAddress'] as String?,
      homeCountryContactNumber: json['homeCountryContactNumber'] as String?,
      additionalHomeCountryContactNumber:
          json['additionalHomeCountryContactNumber'] as String?,
      homeCountryAirport: json['homeCountryAirport'] as String?,
      emergencyContactNumber: json['emergencyContactNumber'] as String?,
      basicSalary: (json['basicSalary'] as num?)?.toDouble(),
      dateOfBirth: json['dateOfBirth'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      genderBloodGroup: json['genderBloodGroup'] as String?,
      employeeType: json['employeeType'] as String?,
      gratuity: json['gratuity'] as String?,
      ticket: (json['ticket'] as num?)?.toDouble(),
      workingHours: (json['workingHours'] as num?)?.toDouble(),
      noOfWorkHours: (json['noOfWorkHours'] as num?)?.toDouble(),
      noOfDays: (json['noOfDays'] as num?)?.toDouble(),
      transportation: (json['transportation'] as num?)?.toDouble(),
      accommodation: (json['accommodation'] as num?)?.toDouble(),
      insurance: (json['insurance'] as num?)?.toDouble(),
      others: (json['others'] as num?)?.toDouble(),
      standard: (json['standard'] as num?)?.toDouble(),
      skill: (json['skill'] as num?)?.toDouble(),
      fuel: (json['fuel'] as num?)?.toDouble(),
      hardship: (json['hardship'] as num?)?.toDouble(),
      education: (json['education'] as num?)?.toDouble(),
      site: (json['site'] as num?)?.toDouble(),
      telephone: (json['telephone'] as num?)?.toDouble(),
      totalSalary: (json['totalSalary'] as num?)?.toDouble(),
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      wpsDebitCardNumber: json['wpsDebitCardNumber'] as String?,
      wpsExpiry: json['wpsExpiry'] as String?,
      labourCode: json['labourCode'] as String?,
      labourCardExpiry: json['labourCardExpiry'] as String?,
      personalCode: json['personalCode'] as String?,
      passportNumber: json['passportNumber'] as String?,
      passportIssueDate: json['passportIssueDate'] as String?,
      passportExpiryDate: json['passportExpiryDate'] as String?,
      emiratesId: json['emiratesId'] as String?,
      emiratesIdExpiryDate: json['emiratesIdExpiryDate'] as String?,
      visaUidNumber: json['visaUidNumber'] as String?,
      visaExpiryDate: json['visaExpiryDate'] as String?,
      workPermitNumber: json['workPermitNumber'] as String?,
      workPermitExpiry: json['workPermitExpiry'] as String?,
      immigrationId: json['immigrationId'] as String?,
      insuranceCompanyName: json['insuranceCompanyName'] as String?,
      insuranceNumber: json['insuranceNumber'] as String?,
      insuranceExpiryDate: json['insuranceExpiryDate'] as String?,
      photoPath: json['photoPath'] as String?,
      emiratesIdCopyPath: json['emiratesIdCopyPath'] as String?,
      passportCopyPath: json['passportCopyPath'] as String?,
      healthInsuranceCardCopyPath:
          json['healthInsuranceCardCopyPath'] as String?,
      labourCardCopyPath: json['labourCardCopyPath'] as String?,
      loginEnabled: login['enabled'] as bool? ?? false,
      canLogin: login['canLogin'] as bool? ?? false,
      loginId: login['loginId'] as String?,
      loginMobile: login['mobileNo'] as String?,
      loginUserId: (login['userId'] as num?)?.toInt(),
      loginStatus: login['status'] as String?,
      loginStartDate: login['startDate'] as String?,
      loginBranchIds: loginBranchIds,
      loginBranchNames: login['branchNames'] as String?,
    );
  }

  LiveEmployeeDraft toDraft() {
    final employee = toDomain();
    return LiveEmployeeDraft(
      name: employee.name,
      branchId: employee.branchId,
      departmentId: employee.departmentId,
      nationalityId: employee.nationalityId,
      statusId: employee.statusId ?? 1,
      designation: employee.designation ?? '',
      joiningDate: employee.joiningDate,
      email: employee.email ?? '',
      phone: employee.phone ?? '',
      basicSalary: employee.basicSalary ?? 0,
      dateOfBirth: employee.dateOfBirth ?? '',
      maritalStatus: employee.maritalStatus ?? '',
      employeeType: employee.employeeType ?? '',
      gratuity: employee.gratuity ?? '',
      workingHours: employee.workingHours ?? 0,
      transportation: employee.transportation ?? 0,
      accommodation: employee.accommodation ?? 0,
      loginEnabled: employee.loginEnabled,
      loginId: employee.loginId ?? '',
      loginMobile: employee.loginMobile ?? '',
      loginBranchIds: employee.loginBranchIds,
    );
  }
}

LiveEmployeeLookups mapLookups(Map<String, dynamic> json) {
  List<Lookup> list(String key) => [
    for (final item in (json[key] as List? ?? const []))
      if (item is Map)
        Lookup((item['id'] as num).toInt(), item['name'] as String? ?? '')
      else
        Lookup(0, '$item'),
  ];
  List<String> strings(String key) => [
    for (final item in (json[key] as List? ?? const [])) '$item',
  ];
  return LiveEmployeeLookups(
    branches: list('branches'),
    departments: list('departments'),
    nationalities: list('nationalities'),
    statuses: list('statuses'),
    maritalStatuses: strings('maritalStatuses'),
    employeeTypes: strings('employeeTypes'),
    gratuityTypes: strings('gratuityTypes'),
  );
}

Map<String, dynamic> employeeListQuery({
  String search = '',
  int? statusId,
  int? departmentId,
  int? branchId,
  String sort = 'nameAsc',
  int page = 1,
  int pageSize = 25,
}) => {
  'page': page,
  'pageSize': pageSize,
  'sort': sort,
  if (search.trim().isNotEmpty) 'search': search.trim(),
  if (statusId != null) 'statusId': statusId,
  if (departmentId != null) 'departmentId': departmentId,
  if (branchId != null) 'branchId': branchId,
};
