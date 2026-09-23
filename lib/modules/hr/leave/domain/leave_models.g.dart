// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaveType _$LeaveTypeFromJson(Map<String, dynamic> json) => _LeaveType(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  description: json['description'] as String? ?? '',
  compensation:
      $enumDecodeNullable(
        _$LeaveCompensationTypeEnumMap,
        json['compensation'],
      ) ??
      LeaveCompensationType.paid,
  requiresApproval: json['requiresApproval'] as bool? ?? true,
  allowsHalfDay: json['allowsHalfDay'] as bool? ?? true,
  requiresReason: json['requiresReason'] as bool? ?? true,
  requiresAttachment: json['requiresAttachment'] as bool? ?? false,
  colorKey: json['colorKey'] as String? ?? 'annual',
  status:
      $enumDecodeNullable(_$ConfigurationStatusEnumMap, json['status']) ??
      ConfigurationStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$RecordSyncStatusEnumMap, json['syncStatus']) ??
      RecordSyncStatus.pending,
);

Map<String, dynamic> _$LeaveTypeToJson(_LeaveType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'compensation': _$LeaveCompensationTypeEnumMap[instance.compensation]!,
      'requiresApproval': instance.requiresApproval,
      'allowsHalfDay': instance.allowsHalfDay,
      'requiresReason': instance.requiresReason,
      'requiresAttachment': instance.requiresAttachment,
      'colorKey': instance.colorKey,
      'status': _$ConfigurationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$RecordSyncStatusEnumMap[instance.syncStatus]!,
    };

const _$LeaveCompensationTypeEnumMap = {
  LeaveCompensationType.paid: 'paid',
  LeaveCompensationType.unpaid: 'unpaid',
  LeaveCompensationType.informational: 'informational',
};

const _$ConfigurationStatusEnumMap = {
  ConfigurationStatus.active: 'active',
  ConfigurationStatus.inactive: 'inactive',
};

const _$RecordSyncStatusEnumMap = {
  RecordSyncStatus.synced: 'synced',
  RecordSyncStatus.pending: 'pending',
  RecordSyncStatus.failed: 'failed',
};

_LeavePolicy _$LeavePolicyFromJson(Map<String, dynamic> json) => _LeavePolicy(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  leaveTypeId: json['leaveTypeId'] as String,
  annualEntitlementDays:
      (json['annualEntitlementDays'] as num?)?.toDouble() ?? 0,
  allowHalfDay: json['allowHalfDay'] as bool? ?? true,
  minimumRequestDays: (json['minimumRequestDays'] as num?)?.toDouble() ?? 0.5,
  maximumConsecutiveDays: (json['maximumConsecutiveDays'] as num?)?.toInt(),
  advanceNoticeDays: (json['advanceNoticeDays'] as num?)?.toInt() ?? 0,
  allowPastRequest: json['allowPastRequest'] as bool? ?? false,
  pastRequestWindowDays: (json['pastRequestWindowDays'] as num?)?.toInt() ?? 0,
  requiresAttachmentAfterDays: (json['requiresAttachmentAfterDays'] as num?)
      ?.toInt(),
  allowNegativeBalance: json['allowNegativeBalance'] as bool? ?? false,
  carryForwardEnabled: json['carryForwardEnabled'] as bool? ?? false,
  carryForwardLimitDays: (json['carryForwardLimitDays'] as num?)?.toDouble(),
  applicableEmploymentTypes:
      (json['applicableEmploymentTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$EmploymentTypeEnumMap, e))
          .toSet() ??
      const <EmploymentType>{},
  status:
      $enumDecodeNullable(_$ConfigurationStatusEnumMap, json['status']) ??
      ConfigurationStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$RecordSyncStatusEnumMap, json['syncStatus']) ??
      RecordSyncStatus.pending,
);

Map<String, dynamic> _$LeavePolicyToJson(_LeavePolicy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'code': instance.code,
      'leaveTypeId': instance.leaveTypeId,
      'annualEntitlementDays': instance.annualEntitlementDays,
      'allowHalfDay': instance.allowHalfDay,
      'minimumRequestDays': instance.minimumRequestDays,
      'maximumConsecutiveDays': instance.maximumConsecutiveDays,
      'advanceNoticeDays': instance.advanceNoticeDays,
      'allowPastRequest': instance.allowPastRequest,
      'pastRequestWindowDays': instance.pastRequestWindowDays,
      'requiresAttachmentAfterDays': instance.requiresAttachmentAfterDays,
      'allowNegativeBalance': instance.allowNegativeBalance,
      'carryForwardEnabled': instance.carryForwardEnabled,
      'carryForwardLimitDays': instance.carryForwardLimitDays,
      'applicableEmploymentTypes': instance.applicableEmploymentTypes
          .map((e) => _$EmploymentTypeEnumMap[e]!)
          .toList(),
      'status': _$ConfigurationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$RecordSyncStatusEnumMap[instance.syncStatus]!,
    };

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 'fullTime',
  EmploymentType.partTime: 'partTime',
  EmploymentType.contract: 'contract',
  EmploymentType.intern: 'intern',
  EmploymentType.temporary: 'temporary',
};

_Holiday _$HolidayFromJson(Map<String, dynamic> json) => _Holiday(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  date: DateTime.parse(json['date'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  type:
      $enumDecodeNullable(_$HolidayTypeEnumMap, json['type']) ??
      HolidayType.companyHoliday,
  scope:
      $enumDecodeNullable(_$HolidayScopeEnumMap, json['scope']) ??
      HolidayScope.companyWide,
  workLocationIds:
      (json['workLocationIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ??
      const <String>{},
  description: json['description'] as String? ?? '',
  isOptional: json['isOptional'] as bool? ?? false,
  source:
      $enumDecodeNullable(_$HolidaySourceEnumMap, json['source']) ??
      HolidaySource.manual,
  calendarId: json['calendarId'] as String?,
  countryCode: json['countryCode'] as String?,
  regionCode: json['regionCode'] as String?,
  status:
      $enumDecodeNullable(_$ConfigurationStatusEnumMap, json['status']) ??
      ConfigurationStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$RecordSyncStatusEnumMap, json['syncStatus']) ??
      RecordSyncStatus.pending,
);

Map<String, dynamic> _$HolidayToJson(_Holiday instance) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'name': instance.name,
  'date': instance.date.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'type': _$HolidayTypeEnumMap[instance.type]!,
  'scope': _$HolidayScopeEnumMap[instance.scope]!,
  'workLocationIds': instance.workLocationIds.toList(),
  'description': instance.description,
  'isOptional': instance.isOptional,
  'source': _$HolidaySourceEnumMap[instance.source]!,
  'calendarId': instance.calendarId,
  'countryCode': instance.countryCode,
  'regionCode': instance.regionCode,
  'status': _$ConfigurationStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': _$RecordSyncStatusEnumMap[instance.syncStatus]!,
};

const _$HolidayTypeEnumMap = {
  HolidayType.publicHoliday: 'publicHoliday',
  HolidayType.festivalHoliday: 'festivalHoliday',
  HolidayType.regionalHoliday: 'regionalHoliday',
  HolidayType.companyHoliday: 'companyHoliday',
  HolidayType.specialClosure: 'specialClosure',
};

const _$HolidayScopeEnumMap = {
  HolidayScope.companyWide: 'companyWide',
  HolidayScope.specificWorkLocations: 'specificWorkLocations',
};

const _$HolidaySourceEnumMap = {
  HolidaySource.manual: 'manual',
  HolidaySource.copiedFromPreviousYear: 'copiedFromPreviousYear',
  HolidaySource.imported: 'imported',
  HolidaySource.companyTemplate: 'companyTemplate',
};

_LeaveTypeSnapshot _$LeaveTypeSnapshotFromJson(Map<String, dynamic> json) =>
    _LeaveTypeSnapshot(
      typeId: json['typeId'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      compensation:
          $enumDecodeNullable(
            _$LeaveCompensationTypeEnumMap,
            json['compensation'],
          ) ??
          LeaveCompensationType.paid,
      requiresReason: json['requiresReason'] as bool? ?? true,
      requiresAttachment: json['requiresAttachment'] as bool? ?? false,
      allowsHalfDay: json['allowsHalfDay'] as bool? ?? true,
    );

Map<String, dynamic> _$LeaveTypeSnapshotToJson(_LeaveTypeSnapshot instance) =>
    <String, dynamic>{
      'typeId': instance.typeId,
      'name': instance.name,
      'code': instance.code,
      'compensation': _$LeaveCompensationTypeEnumMap[instance.compensation]!,
      'requiresReason': instance.requiresReason,
      'requiresAttachment': instance.requiresAttachment,
      'allowsHalfDay': instance.allowsHalfDay,
    };

_LeavePolicySnapshot _$LeavePolicySnapshotFromJson(Map<String, dynamic> json) =>
    _LeavePolicySnapshot(
      policyId: json['policyId'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      annualEntitlementDays:
          (json['annualEntitlementDays'] as num?)?.toDouble() ?? 0,
      allowHalfDay: json['allowHalfDay'] as bool? ?? true,
      allowNegativeBalance: json['allowNegativeBalance'] as bool? ?? false,
    );

Map<String, dynamic> _$LeavePolicySnapshotToJson(
  _LeavePolicySnapshot instance,
) => <String, dynamic>{
  'policyId': instance.policyId,
  'name': instance.name,
  'code': instance.code,
  'annualEntitlementDays': instance.annualEntitlementDays,
  'allowHalfDay': instance.allowHalfDay,
  'allowNegativeBalance': instance.allowNegativeBalance,
};

_LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) =>
    _LeaveRequest(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      employeeId: json['employeeId'] as String,
      typeSnapshot: LeaveTypeSnapshot.fromJson(
        json['typeSnapshot'] as Map<String, dynamic>,
      ),
      policySnapshot: json['policySnapshot'] == null
          ? null
          : LeavePolicySnapshot.fromJson(
              json['policySnapshot'] as Map<String, dynamic>,
            ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      startPortion:
          $enumDecodeNullable(_$LeaveDayPortionEnumMap, json['startPortion']) ??
          LeaveDayPortion.fullDay,
      endPortion:
          $enumDecodeNullable(_$LeaveDayPortionEnumMap, json['endPortion']) ??
          LeaveDayPortion.fullDay,
      requestedDays: (json['requestedDays'] as num).toDouble(),
      reason: json['reason'] as String? ?? '',
      attachmentName: json['attachmentName'] as String?,
      status:
          $enumDecodeNullable(_$LeaveRequestStatusEnumMap, json['status']) ??
          LeaveRequestStatus.pending,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      reviewNote: json['reviewNote'] as String?,
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      cancelledBy: json['cancelledBy'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      requestId: json['requestId'] as String,
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$LeaveRequestToJson(_LeaveRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'employeeId': instance.employeeId,
      'typeSnapshot': instance.typeSnapshot.toJson(),
      'policySnapshot': instance.policySnapshot?.toJson(),
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'startPortion': _$LeaveDayPortionEnumMap[instance.startPortion]!,
      'endPortion': _$LeaveDayPortionEnumMap[instance.endPortion]!,
      'requestedDays': instance.requestedDays,
      'reason': instance.reason,
      'attachmentName': instance.attachmentName,
      'status': _$LeaveRequestStatusEnumMap[instance.status]!,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewedBy': instance.reviewedBy,
      'reviewNote': instance.reviewNote,
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancelledBy': instance.cancelledBy,
      'cancellationReason': instance.cancellationReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'requestId': instance.requestId,
      'syncStatus': instance.syncStatus,
    };

const _$LeaveDayPortionEnumMap = {
  LeaveDayPortion.fullDay: 'fullDay',
  LeaveDayPortion.firstHalf: 'firstHalf',
  LeaveDayPortion.secondHalf: 'secondHalf',
};

const _$LeaveRequestStatusEnumMap = {
  LeaveRequestStatus.pending: 'pending',
  LeaveRequestStatus.approved: 'approved',
  LeaveRequestStatus.rejected: 'rejected',
  LeaveRequestStatus.cancelled: 'cancelled',
};

_LeaveBalanceTransaction _$LeaveBalanceTransactionFromJson(
  Map<String, dynamic> json,
) => _LeaveBalanceTransaction(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  employeeId: json['employeeId'] as String,
  leaveTypeId: json['leaveTypeId'] as String,
  leaveYear: (json['leaveYear'] as num).toInt(),
  type: $enumDecode(_$LeaveBalanceTransactionTypeEnumMap, json['type']),
  quantityDays: (json['quantityDays'] as num).toDouble(),
  leaveRequestId: json['leaveRequestId'] as String?,
  reason: json['reason'] as String? ?? '',
  createdBy: json['createdBy'] as String,
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  requestId: json['requestId'] as String,
  syncStatus: json['syncStatus'] as String? ?? 'pending',
);

Map<String, dynamic> _$LeaveBalanceTransactionToJson(
  _LeaveBalanceTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'employeeId': instance.employeeId,
  'leaveTypeId': instance.leaveTypeId,
  'leaveYear': instance.leaveYear,
  'type': _$LeaveBalanceTransactionTypeEnumMap[instance.type]!,
  'quantityDays': instance.quantityDays,
  'leaveRequestId': instance.leaveRequestId,
  'reason': instance.reason,
  'createdBy': instance.createdBy,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'requestId': instance.requestId,
  'syncStatus': instance.syncStatus,
};

const _$LeaveBalanceTransactionTypeEnumMap = {
  LeaveBalanceTransactionType.entitlement: 'entitlement',
  LeaveBalanceTransactionType.adjustmentAdd: 'adjustmentAdd',
  LeaveBalanceTransactionType.adjustmentSubtract: 'adjustmentSubtract',
  LeaveBalanceTransactionType.leaveReserved: 'leaveReserved',
  LeaveBalanceTransactionType.leaveReleased: 'leaveReleased',
  LeaveBalanceTransactionType.leaveConsumed: 'leaveConsumed',
  LeaveBalanceTransactionType.carryForward: 'carryForward',
  LeaveBalanceTransactionType.expiry: 'expiry',
  LeaveBalanceTransactionType.migration: 'migration',
};
