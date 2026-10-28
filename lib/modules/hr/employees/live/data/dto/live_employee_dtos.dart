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
      joiningDate: json['joiningDate'] as String?,
      email: json['email'] as String?,
      phone: json['uaeContactNumber'] as String?,
      basicSalary: (json['basicSalary'] as num?)?.toDouble(),
      loginEnabled: login['enabled'] as bool? ?? false,
      canLogin: login['canLogin'] as bool? ?? false,
      loginId: login['loginId'] as String?,
      loginMobile: login['mobileNo'] as String?,
      loginUserId: (login['userId'] as num?)?.toInt(),
    );
  }

  LiveEmployeeDraft toDraft() {
    final employee = toDomain();
    final rawLogin = json['login'] is Map
        ? (json['login'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final branchIds = (rawLogin['branchIds'] as List? ?? const [])
        .whereType<num>()
        .map((value) => value.toInt())
        .toList();
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
      loginEnabled: employee.loginEnabled,
      loginId: employee.loginId ?? '',
      loginMobile: employee.loginMobile ?? '',
      loginBranchIds: branchIds,
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
  return LiveEmployeeLookups(
    branches: list('branches'),
    departments: list('departments'),
    nationalities: list('nationalities'),
    statuses: list('statuses'),
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
