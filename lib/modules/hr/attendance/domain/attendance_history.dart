import 'package:modular_erp/core/errors/result.dart';
import 'shift_workday_resolver.dart';
import 'attendance_models.dart';
import 'attendance_correction.dart';

/// Read projection only; persisted engine statuses are unchanged.
enum AttendanceHistoryStatus { present, late, working, incomplete }

enum AttendanceRecordIssue {
  missingPunchOut,
  openBreak,
  syncFailed,
  serverRejected,
}

enum AttendanceHistorySort { newest, oldest }

class AttendanceHistoryQuery {
  AttendanceHistoryQuery({
    required this.year,
    required this.month,
    Set<AttendanceHistoryStatus> statuses = const {},
    this.page = 0,
    this.pageSize = 25,
    this.sort = AttendanceHistorySort.newest,
  }) : statuses = Set.unmodifiable(statuses) {
    if (year < 1 ||
        year > 9998 ||
        month < 1 ||
        month > 12 ||
        page < 0 ||
        pageSize < 1 ||
        pageSize > 100) {
      throw ArgumentError('Invalid history query');
    }
  }
  final int year, month, page, pageSize;
  final Set<AttendanceHistoryStatus> statuses;
  final AttendanceHistorySort sort;
  DateTime get start => DateTime.utc(year, month);
  DateTime get end => DateTime.utc(year, month + 1);
}

AttendanceHistoryStatus historyStatus(AttendanceDay day, DateTime now) {
  if (day.state == AttendanceWorkdayState.completed && day.punchOutAt != null) {
    return day.status == AttendanceDayStatus.late
        ? AttendanceHistoryStatus.late
        : AttendanceHistoryStatus.present;
  }
  final wall = const FixedOffsetCompanyTimeService().localWallTime(
    now,
    day.snapshot.timezone,
  );
  final historical =
      wall is Success<DateTime> &&
      DateTime.utc(
        wall.value.year,
        wall.value.month,
        wall.value.day,
      ).isAfter(day.attendanceDate);
  return historical && now.isAfter(day.snapshot.scheduledEnd)
      ? AttendanceHistoryStatus.incomplete
      : AttendanceHistoryStatus.working;
}

class AttendanceMonthSummary {
  AttendanceMonthSummary({
    required Map<AttendanceHistoryStatus, int> counts,
    required this.work,
    required this.breaks,
    required this.completed,
  }) : counts = Map.unmodifiable(counts);
  final Map<AttendanceHistoryStatus, int> counts;
  final Duration work, breaks;
  final int completed;
  int get records => counts.values.fold(0, (a, b) => a + b);
  Duration get averageWork => completed == 0
      ? Duration.zero
      : Duration(milliseconds: work.inMilliseconds ~/ completed);
}

/// Bounded list projection: no events or full configuration blobs are loaded.
class AttendanceHistoryItem {
  const AttendanceHistoryItem({
    required this.id,
    required this.attendanceDate,
    required this.shiftName,
    required this.timezone,
    required this.status,
    required this.syncStatus,
    required this.totalWorkDuration,
    required this.totalBreakDuration,
    this.locationName,
    this.punchInAt,
    this.punchOutAt,
  });
  factory AttendanceHistoryItem.fromDay(AttendanceDay day, DateTime now) =>
      AttendanceHistoryItem(
        id: day.id,
        attendanceDate: day.attendanceDate,
        shiftName: day.snapshot.shift.name,
        timezone: day.snapshot.timezone,
        status: historyStatus(day, now),
        syncStatus: day.syncStatus,
        totalWorkDuration: day.totalWorkDuration,
        totalBreakDuration: day.totalBreakDuration,
        locationName: day.snapshot.workLocation?.name,
        punchInAt: day.punchInAt,
        punchOutAt: day.punchOutAt,
      );
  final String id, shiftName, timezone;
  final String? locationName;
  final DateTime attendanceDate;
  final DateTime? punchInAt, punchOutAt;
  final Duration totalWorkDuration, totalBreakDuration;
  final AttendanceHistoryStatus status;
  final AttendanceSyncStatus syncStatus;
  bool get isCompleted =>
      status == AttendanceHistoryStatus.present ||
      status == AttendanceHistoryStatus.late;
}

class AttendanceHistoryPageData {
  AttendanceHistoryPageData(
    this.query,
    List<AttendanceHistoryItem> items,
    this.total,
    this.summary,
    this.asOf,
  ) : items = List.unmodifiable(items);
  final AttendanceHistoryQuery query;
  final List<AttendanceHistoryItem> items;
  final int total;
  final AttendanceMonthSummary summary;
  final DateTime asOf;
}

class AttendanceDayDetails {
  AttendanceDayDetails(
    this.day,
    List<AttendanceEvent> events,
    this.asOf, {
    List<AttendanceEvent>? originalEvents,
    List<AttendanceCorrectionRequest> corrections = const [],
  }) : events = List.unmodifiable(events),
       originalEvents = List.unmodifiable(originalEvents ?? events),
       corrections = List.unmodifiable(corrections);
  final AttendanceDay day;
  final List<AttendanceEvent> events;
  final List<AttendanceEvent> originalEvents;
  final List<AttendanceCorrectionRequest> corrections;
  final DateTime asOf;
  AttendanceHistoryStatus get status => historyStatus(day, asOf);
  Set<AttendanceRecordIssue> get issues => Set.unmodifiable({
    if (status == AttendanceHistoryStatus.incomplete)
      AttendanceRecordIssue.missingPunchOut,
    if (status == AttendanceHistoryStatus.incomplete &&
        day.state == AttendanceWorkdayState.onBreak)
      AttendanceRecordIssue.openBreak,
    if (day.syncStatus == AttendanceSyncStatus.failed)
      AttendanceRecordIssue.syncFailed,
    if (day.syncStatus == AttendanceSyncStatus.rejected)
      AttendanceRecordIssue.serverRejected,
  });
}
