import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_validator.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_history.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_correction_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/attendance_presentation.dart';

String correctionTypeLabel(
  BuildContext context,
  AttendanceCorrectionType type,
) {
  final l = context.l10n;
  return switch (type) {
    AttendanceCorrectionType.missingPunchIn => l.correctionMissingPunchIn,
    AttendanceCorrectionType.missingPunchOut => l.correctionMissingPunchOut,
    AttendanceCorrectionType.changePunchIn => l.correctionChangePunchIn,
    AttendanceCorrectionType.changePunchOut => l.correctionChangePunchOut,
    AttendanceCorrectionType.missingBreakStart => l.correctionMissingBreakStart,
    AttendanceCorrectionType.missingBreakEnd => l.correctionMissingBreakEnd,
    AttendanceCorrectionType.changeBreakStart => l.correctionChangeBreakStart,
    AttendanceCorrectionType.changeBreakEnd => l.correctionChangeBreakEnd,
    AttendanceCorrectionType.custom => l.correctionType,
  };
}

String correctionStatusLabel(
  BuildContext context,
  AttendanceCorrectionStatus status,
) {
  final l = context.l10n;
  return switch (status) {
    AttendanceCorrectionStatus.pending => l.correctionPending,
    AttendanceCorrectionStatus.approved => l.correctionApproved,
    AttendanceCorrectionStatus.rejected => l.correctionRejected,
    AttendanceCorrectionStatus.cancelled => l.correctionCancelled,
  };
}

String correctionEmployeeLabel(AttendanceCorrectionRequest request) =>
    '${request.employeeName} · ${request.employeeCode ?? ''}';

class MyAttendanceCorrectionsPage extends StatelessWidget {
  const MyAttendanceCorrectionsPage({super.key});
  @override
  Widget build(BuildContext context) => const _CorrectionList(review: false);
}

class AttendanceCorrectionQueuePage extends StatelessWidget {
  const AttendanceCorrectionQueuePage({super.key});
  @override
  Widget build(BuildContext context) => const _CorrectionList(review: true);
}

class _CorrectionList extends StatefulWidget {
  const _CorrectionList({required this.review});
  final bool review;
  @override
  State<_CorrectionList> createState() => _CorrectionListState();
}

class _CorrectionListState extends State<_CorrectionList> {
  AttendanceCorrectionStatus? filter;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AttendanceCorrectionBloc, AttendanceCorrectionState>(
    builder: (context, state) {
      final l = context.l10n;
      final query = search.text.trim().toLowerCase();
      final items = state.items.where((r) {
        if (filter != null && r.status != filter) return false;
        if (query.isEmpty) return true;
        return (r.employeeName ?? '').toLowerCase().contains(query) ||
            (r.employeeCode ?? '').toLowerCase().contains(query) ||
            correctionTypeLabel(
              context,
              r.requestType,
            ).toLowerCase().contains(query);
      }).toList();
      return AppPage(
        header: AppPageHeader(
          title: widget.review
              ? l.correctionReviewQueue
              : l.correctionMyRequests,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.review) ...[
              AppTextField(
                label: l.workforceSearch,
                controller: search,
                prefixIcon: Icons.search,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppFilterChip(
                  label: l.historyAllStatuses,
                  selected: filter == null,
                  onSelected: (_) => setState(() => filter = null),
                ),
                for (final status in AttendanceCorrectionStatus.values)
                  AppFilterChip(
                    label: correctionStatusLabel(context, status),
                    selected: filter == status,
                    onSelected: (_) => setState(() => filter = status),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (state.failure != null)
              AppNotice(title: l.historyRetry, status: AppStatus.danger),
            if (state.loading) const AppLoadingState(),
            if (!state.loading && items.isEmpty)
              AppEmptyState(
                title: l.correctionNoRequests,
                message: l.correctionNoRequests,
              ),
            for (final request in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  variant: AppCardVariant.interactive,
                  onTap: () => context.push(
                    widget.review
                        ? AppRoutes.attendanceReviewDetails(request.id)
                        : AppRoutes.attendanceCorrectionDetails(request.id),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            correctionTypeLabel(context, request.requestType),
                            style: AppTypography.of(context).cardTitle,
                          ),
                          if (widget.review && request.employeeName != null)
                            Text(correctionEmployeeLabel(request)),
                          Text(
                            AppDateFormatter(
                              Localizations.localeOf(context),
                            ).date(request.requestedAt),
                          ),
                        ],
                      ),
                      AppStatusBadge(
                        label: correctionStatusLabel(context, request.status),
                        status:
                            request.status ==
                                AttendanceCorrectionStatus.approved
                            ? AppStatus.success
                            : request.status ==
                                  AttendanceCorrectionStatus.rejected
                            ? AppStatus.danger
                            : AppStatus.neutral,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class AttendanceCorrectionFormPage extends StatefulWidget {
  const AttendanceCorrectionFormPage({
    super.key,
    required this.dayId,
    required this.attendanceRepository,
  });
  final String dayId;
  final AttendanceRepository attendanceRepository;
  @override
  State<AttendanceCorrectionFormPage> createState() =>
      _AttendanceCorrectionFormPageState();
}

class _AttendanceCorrectionFormPageState
    extends State<AttendanceCorrectionFormPage> {
  late final Future<Result<AttendanceDayDetails?>> future = widget
      .attendanceRepository
      .getAttendanceDayById(widget.dayId);
  final reason = TextEditingController();
  AttendanceCorrectionType? type;
  String? eventId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool preview = false;
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  AttendanceEventType eventType(AttendanceCorrectionType t) => switch (t) {
    AttendanceCorrectionType.missingPunchIn ||
    AttendanceCorrectionType.changePunchIn => AttendanceEventType.punchIn,
    AttendanceCorrectionType.missingPunchOut ||
    AttendanceCorrectionType.changePunchOut => AttendanceEventType.punchOut,
    AttendanceCorrectionType.missingBreakStart ||
    AttendanceCorrectionType.changeBreakStart => AttendanceEventType.breakStart,
    _ => AttendanceEventType.breakEnd,
  };
  bool isChange(AttendanceCorrectionType t) => t.name.startsWith('change');

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<Result<AttendanceDayDetails?>>(
    future: future,
    builder: (context, snapshot) {
      final l = context.l10n;
      if (!snapshot.hasData) {
        return AppPage(
          header: AppPageHeader(title: l.correctionRequest),
          child: const AppLoadingState(),
        );
      }
      final result = snapshot.data;
      if (result is! Success<AttendanceDayDetails?> || result.value == null) {
        return AppPage(
          header: AppPageHeader(title: l.correctionRequest),
          child: AppEmptyState(
            title: l.historyNotFound,
            message: l.historyNotFoundNote,
          ),
        );
      }
      final details = result.value!;
      final actor = context.read<AuthBloc>().state.context;
      if (actor == null ||
          !actor.user.permissions.contains(
            AppPermission.attendanceRequestCorrection,
          ) ||
          !details.day.snapshot.policy.allowEmployeeCorrectionRequest) {
        return AppPage(
          header: AppPageHeader(title: l.correctionRequest),
          child: AppEmptyState(
            title: l.attendanceUnavailableTitle,
            message: l.attendanceUnavailableTitle,
          ),
        );
      }
      final options = AttendanceCorrectionType.values
          .where((e) => e != AttendanceCorrectionType.custom)
          .toList();
      type ??= details.issues.contains(AttendanceRecordIssue.missingPunchOut)
          ? AttendanceCorrectionType.missingPunchOut
          : details.issues.contains(AttendanceRecordIssue.openBreak)
          ? AttendanceCorrectionType.missingBreakEnd
          : AttendanceCorrectionType.changePunchIn;
      final target = eventType(type!);
      final candidates = details.events
          .where((e) => e.eventType == target)
          .toList();
      if (isChange(type!) && eventId == null && candidates.isNotEmpty) {
        eventId = candidates.first.id;
      }
      final original = candidates.where((e) => e.id == eventId).firstOrNull;
      final defaultTime =
          original?.effectiveTimestamp ??
          (target == AttendanceEventType.punchOut
              ? details.day.snapshot.scheduledEnd
              : details.day.snapshot.scheduledStart);
      final wall = const FixedOffsetCompanyTimeService().localWallTime(
        defaultTime,
        details.day.snapshot.timezone,
      );
      final initial = wall is Success<DateTime>
          ? wall.value
          : details.day.attendanceDate;
      selectedDate ??= DateTime(initial.year, initial.month, initial.day);
      selectedTime ??= TimeOfDay.fromDateTime(initial);
      final wallRequested = DateTime.utc(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      final resolved = const FixedOffsetCompanyTimeService().toInstant(
        wallRequested,
        details.day.snapshot.timezone,
      );
      final change = resolved is Success<DateTime>
          ? AttendanceCorrectionChange(
              eventType: target,
              requestedTimestamp: resolved.value,
              changeType: isChange(type!)
                  ? AttendanceCorrectionChangeType.replace
                  : AttendanceCorrectionChangeType.add,
              originalEventId: isChange(type!) ? eventId : null,
              originalTimestamp: isChange(type!)
                  ? original?.effectiveTimestamp
                  : null,
            )
          : null;
      final validation = change == null
          ? null
          : const AttendanceCorrectionValidator().validate(details.events, [
              change,
            ], details.asOf);
      final summary = validation is Success<AttendanceSummary>
          ? validation.value
          : null;
      final formatter = AppTimeFormatter(Localizations.localeOf(context));
      String display(DateTime? value) =>
          value == null ? l.historyNotRecorded : formatter.time(value);
      return BlocConsumer<AttendanceCorrectionBloc, AttendanceCorrectionState>(
        listener: (context, state) {
          if (state.completed) {
            context.go(AppRoutes.attendanceCorrections);
          }
        },
        builder: (context, state) => AppPage(
          header: AppPageHeader(title: l.correctionRequest),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDetailsSection(
                title: l.historyDetails,
                details: {
                  l.workforceDate: AppDateFormatter(
                    Localizations.localeOf(context),
                  ).date(details.day.attendanceDate),
                  l.workforceShift: details.day.snapshot.shift.name,
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              AppFormSection(
                title: l.correctionRequested,
                child: Column(
                  children: [
                    AppDropdown<AttendanceCorrectionType>(
                      label: l.correctionType,
                      value: type,
                      items: [
                        for (final option in options)
                          DropdownMenuItem(
                            value: option,
                            child: Text(correctionTypeLabel(context, option)),
                          ),
                      ],
                      onChanged: (value) => setState(() {
                        type = value;
                        eventId = null;
                        selectedDate = null;
                        selectedTime = null;
                        preview = false;
                      }),
                    ),
                    if (isChange(type!) && candidates.length > 1)
                      AppDropdown<String>(
                        label: l.correctionOriginal,
                        value: eventId,
                        items: [
                          for (final event in candidates)
                            DropdownMenuItem(
                              value: event.id,
                              child: Text(display(event.effectiveTimestamp)),
                            ),
                        ],
                        onChanged: (value) => setState(() => eventId = value),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    AppDateField(
                      label: l.workforceDate,
                      value: selectedDate,
                      onChanged: (value) =>
                          setState(() => selectedDate = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTimeField(
                      label: l.correctionRequestedTime,
                      value: selectedTime,
                      onChanged: (value) =>
                          setState(() => selectedTime = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l.correctionReason,
                      controller: reason,
                      maxLines: 3,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (change != null)
                AppChangeComparison(
                  title: correctionTypeLabel(context, type!),
                  beforeLabel: l.correctionOriginal,
                  before: display(original?.effectiveTimestamp),
                  afterLabel: l.correctionRequested,
                  after: display(change.requestedTimestamp),
                ),
              if (preview && summary != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: AppDetailsSection(
                    title: l.correctionPreview,
                    details: {
                      l.attendancePunchInTime: display(summary.punchInTime),
                      l.attendancePunchOutTime: display(summary.punchOutTime),
                      l.attendanceWorkedTime: formatter.duration(
                        summary.workDuration,
                        l,
                      ),
                      l.historyBreaks: formatter.duration(
                        summary.breakDuration,
                        l,
                      ),
                    },
                  ),
                ),
              if (validation is Failed<AttendanceSummary> ||
                  (isChange(type!) && original == null))
                AppNotice(title: l.correctionInvalid, status: AppStatus.danger),
              if (state.failure != null)
                AppNotice(title: l.correctionInvalid, status: AppStatus.danger),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                label: preview ? l.correctionSubmit : l.correctionPreview,
                loading: state.busy,
                onPressed:
                    summary == null ||
                        reason.text.trim().isEmpty ||
                        (isChange(type!) && original == null)
                    ? null
                    : () {
                        if (!preview) {
                          setState(() => preview = true);
                          return;
                        }
                        final now = DateTime.now().toUtc();
                        context.read<AttendanceCorrectionBloc>().add(
                          CorrectionSubmitted(
                            AttendanceCorrectionRequest(
                              id: '',
                              companyId: actor.company.id,
                              employeeId: details.day.employeeId,
                              attendanceDayId: details.day.id,
                              requestType: type!,
                              status: AttendanceCorrectionStatus.pending,
                              reason: reason.text.trim(),
                              originalSnapshot: '',
                              changes: [change!],
                              requestedByUserId: actor.user.id,
                              requestedAt: now,
                              createdAt: now,
                              updatedAt: now,
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class AttendanceCorrectionDetailsPage extends StatelessWidget {
  const AttendanceCorrectionDetailsPage({super.key, required this.review});
  final bool review;
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AttendanceCorrectionBloc, AttendanceCorrectionState>(
    builder: (context, state) {
      final l = context.l10n, request = state.detail;
      if (state.loading) {
        return AppPage(
          header: AppPageHeader(title: l.correctionReviewQueue),
          child: const AppLoadingState(),
        );
      }
      if (request == null) {
        return AppPage(
          header: AppPageHeader(title: l.correctionReviewQueue),
          child: AppEmptyState(
            title: l.historyNotFound,
            message: l.historyNotFoundNote,
          ),
        );
      }
      final format = AppTimeFormatter(Localizations.localeOf(context));
      final date = AppDateFormatter(Localizations.localeOf(context));
      final frozen =
          jsonDecode(request.originalSnapshot) as Map<String, dynamic>;
      final rawDay = frozen['day'] as Map<String, dynamic>?;
      final day = rawDay == null ? null : AttendanceDay.fromJson(rawDay);
      final originalEvents = (frozen['events'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                AttendanceEvent.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(growable: false);
      final preview = const AttendanceCorrectionValidator().validate(
        originalEvents,
        request.changes,
        DateTime.now().toUtc(),
      );
      final effective = preview is Success<AttendanceSummary>
          ? preview.value
          : null;
      String display(DateTime? instant) {
        if (instant == null) return l.historyNotRecorded;
        final wall = const FixedOffsetCompanyTimeService().localWallTime(
          instant,
          day?.snapshot.timezone ?? 'UTC',
        );
        final value = wall is Success<DateTime> ? wall.value : instant;
        return l.dateTimeValue(date.date(value), format.time(value));
      }

      final actor = context.read<AuthBloc>().state.context;
      return AppPage(
        header: AppPageHeader(
          title: review ? l.correctionReviewQueue : l.correctionMyRequests,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppStatusBadge(
              label: correctionStatusLabel(context, request.status),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppDetailsSection(
              title: correctionTypeLabel(context, request.requestType),
              details: {
                if (request.employeeName != null)
                  l.shellEmployees: request.employeeName!,
                if (request.employeeCode != null)
                  l.empCode: request.employeeCode!,
                l.workforceDate: day == null
                    ? '—'
                    : date.date(day.attendanceDate),
                if (day != null) l.workforceShift: day.snapshot.shift.name,
                l.correctionReason: request.reason,
                l.correctionRequested: date.date(request.requestedAt),
                if (request.reviewNote != null)
                  l.correctionReviewNote: request.reviewNote!,
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final change in request.changes)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppChangeComparison(
                  title: correctionTypeLabel(context, request.requestType),
                  beforeLabel: l.correctionOriginal,
                  before: display(change.originalTimestamp),
                  afterLabel: l.correctionRequested,
                  after: display(change.requestedTimestamp),
                ),
              ),
            if (originalEvents.isNotEmpty)
              AppDetailsSection(
                title: l.correctionOriginal,
                details: {
                  for (var i = 0; i < originalEvents.length; i++)
                    '${i + 1}. ${AttendancePresentation.event(context, originalEvents[i].eventType)}':
                        display(originalEvents[i].effectiveTimestamp),
                },
              ),
            if (effective != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppDetailsSection(
                title: l.correctionPreview,
                details: {
                  l.attendancePunchInTime: display(effective.punchInTime),
                  l.attendancePunchOutTime: display(effective.punchOutTime),
                  l.attendanceWorkedTime: format.duration(
                    effective.workDuration,
                    l,
                  ),
                  l.attendanceBreakTime: format.duration(
                    effective.breakDuration,
                    l,
                  ),
                },
              ),
            ],
            if (state.failure != null)
              AppNotice(title: l.correctionInvalid, status: AppStatus.danger),
            const SizedBox(height: AppSpacing.xl),
            if (!review && request.status == AttendanceCorrectionStatus.pending)
              AppSecondaryButton(
                label: l.correctionCancel,
                onPressed: state.busy
                    ? null
                    : () => context.read<AttendanceCorrectionBloc>().add(
                        CorrectionCancelled(request.id),
                      ),
              ),
            if (review &&
                request.status == AttendanceCorrectionStatus.pending &&
                actor != null) ...[
              AppPrimaryButton(
                label: l.correctionApprove,
                loading: state.busy,
                onPressed: () => context.read<AttendanceCorrectionBloc>().add(
                  CorrectionReviewed(
                    request.id,
                    approve: true,
                    reviewerId: actor.user.id,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSecondaryButton(
                label: l.correctionReject,
                onPressed: state.busy
                    ? null
                    : () async {
                        final controller = TextEditingController();
                        final note = await AppDialog.show<String>(
                          context,
                          (dialog) => AppDialog(
                            title: l.correctionReject,
                            actions: [
                              AppTextButton(
                                label: l.cancel,
                                onPressed: () => Navigator.pop(dialog),
                              ),
                              AppPrimaryButton(
                                label: l.correctionReject,
                                onPressed: () =>
                                    Navigator.pop(dialog, controller.text),
                              ),
                            ],
                            child: AppTextField(
                              label: l.correctionReviewNote,
                              controller: controller,
                              maxLines: 3,
                            ),
                          ),
                        );
                        if (note != null &&
                            note.trim().isNotEmpty &&
                            context.mounted) {
                          context.read<AttendanceCorrectionBloc>().add(
                            CorrectionReviewed(
                              request.id,
                              approve: false,
                              reviewerId: actor.user.id,
                              note: note,
                            ),
                          );
                        }
                        controller.dispose();
                      },
              ),
            ],
          ],
        ),
      );
    },
  );
}
