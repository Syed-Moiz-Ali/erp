import 'dart:convert';
import 'attendance_models.dart';

enum AttendanceCorrectionStatus { pending, approved, rejected, cancelled }

enum AttendanceCorrectionType {
  missingPunchIn,
  missingPunchOut,
  changePunchIn,
  changePunchOut,
  missingBreakStart,
  missingBreakEnd,
  changeBreakStart,
  changeBreakEnd,
  custom,
}

enum AttendanceCorrectionChangeType { add, replace }

class AttendanceCorrectionChange {
  const AttendanceCorrectionChange({
    required this.eventType,
    required this.requestedTimestamp,
    this.originalEventId,
    this.originalTimestamp,
    this.changeType = AttendanceCorrectionChangeType.add,
    this.breakIndex,
  });
  final AttendanceEventType eventType;
  final String? originalEventId;
  final DateTime? originalTimestamp;
  final DateTime requestedTimestamp;
  final AttendanceCorrectionChangeType changeType;
  final int? breakIndex;
  Map<String, Object?> toJson() => {
    'eventType': eventType.name,
    'originalEventId': originalEventId,
    'originalTimestamp': originalTimestamp?.toUtc().toIso8601String(),
    'requestedTimestamp': requestedTimestamp.toUtc().toIso8601String(),
    'changeType': changeType.name,
    'breakIndex': breakIndex,
  };
  factory AttendanceCorrectionChange.fromJson(Map<String, dynamic> j) =>
      AttendanceCorrectionChange(
        eventType: AttendanceEventType.values.byName(j['eventType'] as String),
        originalEventId: j['originalEventId'] as String?,
        originalTimestamp: j['originalTimestamp'] == null
            ? null
            : DateTime.parse(j['originalTimestamp'] as String),
        requestedTimestamp: DateTime.parse(j['requestedTimestamp'] as String),
        changeType: AttendanceCorrectionChangeType.values.byName(
          j['changeType'] as String? ?? 'add',
        ),
        breakIndex: j['breakIndex'] as int?,
      );
}

class AttendanceCorrectionRequest {
  const AttendanceCorrectionRequest({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.attendanceDayId,
    required this.requestType,
    required this.status,
    required this.reason,
    required this.originalSnapshot,
    required this.changes,
    required this.requestedByUserId,
    required this.requestedAt,
    this.reviewedByUserId,
    this.reviewedAt,
    this.reviewNote,
    this.employeeName,
    this.employeeCode,
    this.departmentName,
    this.syncStatus = AttendanceSyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id,
      companyId,
      employeeId,
      attendanceDayId,
      requestedByUserId,
      reason,
      originalSnapshot;
  final AttendanceCorrectionType requestType;
  final AttendanceCorrectionStatus status;
  final List<AttendanceCorrectionChange> changes;
  final DateTime requestedAt, createdAt, updatedAt;
  final String? reviewedByUserId, reviewNote;
  final String? employeeName, employeeCode, departmentName;
  final DateTime? reviewedAt;
  final AttendanceSyncStatus syncStatus;
  String get changesJson =>
      jsonEncode(changes.map((e) => e.toJson()).toList(growable: false));
}

class EffectiveAttendanceEvent {
  const EffectiveAttendanceEvent({
    required this.eventType,
    required this.effectiveTimestamp,
    this.originalTimestamp,
    this.correctionRequestId,
    this.approvedBy,
  });
  final AttendanceEventType eventType;
  final DateTime effectiveTimestamp;
  final DateTime? originalTimestamp;
  final String? correctionRequestId, approvedBy;
  bool get isCorrected => correctionRequestId != null;
}
