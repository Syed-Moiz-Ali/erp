import '../../../core/errors/result.dart';
import 'attendance_correction.dart';
import 'attendance_models.dart';
import 'attendance_summary_calculator.dart';

/// Projects adjustments over immutable source events for preview and approval.
class AttendanceCorrectionValidator {
  const AttendanceCorrectionValidator();

  Result<List<AttendanceEvent>> project(
    List<AttendanceEvent> original,
    List<AttendanceCorrectionChange> changes,
    DateTime now, {
    String requestId = 'preview',
  }) {
    if (changes.isEmpty || changes.length > 8 || original.isEmpty) {
      return _failure('correctionInvalidChanges');
    }
    final projected = [...original];
    for (var i = 0; i < changes.length; i++) {
      final change = changes[i];
      final timestamp = change.requestedTimestamp.toUtc();
      if (timestamp.isAfter(now.toUtc().add(const Duration(days: 1)))) {
        return _failure('correctionFutureTime');
      }
      if (change.changeType == AttendanceCorrectionChangeType.replace) {
        final matching = projected
            .where(
              (event) =>
                  event.id == change.originalEventId &&
                  event.eventType == change.eventType,
            )
            .toList();
        if (matching.length != 1 ||
            (change.originalTimestamp != null &&
                matching.single.effectiveTimestamp !=
                    change.originalTimestamp!.toUtc())) {
          return _failure('correctionOriginalChanged');
        }
        final index = projected.indexOf(matching.single);
        projected[index] = matching.single.copyWith(
          deviceTimestamp: timestamp,
          serverTimestamp: null,
        );
      } else {
        if (change.originalEventId != null) {
          return _failure('correctionInvalidChanges');
        }
        projected.add(
          AttendanceEvent(
            id: 'adjustment-$requestId-$i',
            attendanceDayId: original.first.attendanceDayId,
            companyId: original.first.companyId,
            employeeId: original.first.employeeId,
            eventType: change.eventType,
            deviceTimestamp: timestamp,
            sequence: original.length + i + 1,
            locationValidation: const AttendanceLocationValidation(
              state: AttendanceLocationState.notRequired,
            ),
            requestId: '$requestId-$i',
            source: AttendanceEventSource.manual,
            // An adjustment is an effective read projection, not an outbox event.
            syncStatus: AttendanceSyncStatus.synced,
            createdAt: now.toUtc(),
          ),
        );
      }
    }
    projected.sort((a, b) {
      final order = a.effectiveTimestamp.compareTo(b.effectiveTimestamp);
      return order == 0 ? a.sequence.compareTo(b.sequence) : order;
    });
    if (projected.first.eventType != AttendanceEventType.punchIn ||
        projected.last.effectiveTimestamp.difference(
              projected.first.effectiveTimestamp,
            ) >
            const Duration(hours: 36)) {
      return _failure('correctionInvalidSequence');
    }
    final calculated = const AttendanceSummaryCalculator().calculate(
      projected,
      now,
    );
    if (calculated is Failed<AttendanceSummary>) {
      return _failure('correctionInvalidSequence');
    }
    return Success(List.unmodifiable(projected));
  }

  Result<AttendanceSummary> validate(
    List<AttendanceEvent> events,
    List<AttendanceCorrectionChange> changes,
    DateTime now,
  ) {
    final result = project(events, changes, now);
    if (result is Failed<List<AttendanceEvent>>) return Failed(result.failure);
    return const AttendanceSummaryCalculator().calculate(
      (result as Success<List<AttendanceEvent>>).value,
      now,
    );
  }

  Failed<T> _failure<T>(String code) =>
      Failed(Failure(code: code, kind: FailureKind.invalidData));
}
