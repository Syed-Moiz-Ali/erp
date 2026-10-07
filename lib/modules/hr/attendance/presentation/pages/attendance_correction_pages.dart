import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
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

  String _statusChipLabel(
    BuildContext context,
    AttendanceCorrectionStatus status,
  ) => '${context.l10n.status}: ${correctionStatusLabel(context, status)}';

  AppStatus _statusOf(AttendanceCorrectionStatus status) => switch (status) {
    AttendanceCorrectionStatus.approved => AppStatus.success,
    AttendanceCorrectionStatus.rejected => AppStatus.danger,
    AttendanceCorrectionStatus.cancelled => AppStatus.neutral,
    AttendanceCorrectionStatus.pending => AppStatus.warning,
  };

  Future<void> _openStatusFilter(BuildContext context) async {
    final l = context.l10n;
    var draft = filter;
    final result = await AppBottomSheet.show<AttendanceCorrectionStatus?>(
      context,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, set) => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSectionHeader(title: l.status),
              const SizedBox(height: AppSpacing.lg),
              AppFilterBar(
                children: [
                  AppFilterChip(
                    label: l.historyAllStatuses,
                    selected: draft == null,
                    onSelected: (_) => set(() => draft = null),
                  ),
                  for (final status in AttendanceCorrectionStatus.values)
                    AppFilterChip(
                      label: correctionStatusLabel(sheet, status),
                      selected: draft == status,
                      onSelected: (_) => set(() => draft = status),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                label: l.historyApply,
                onPressed: () => Navigator.pop(sheet, draft),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) {
      setState(() {
        search.clear();
        filter = result;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AttendanceCorrectionBloc, AttendanceCorrectionState>(
    builder: (context, state) {
      final l = context.l10n;
      final locale = Localizations.localeOf(context);
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
      final compact = AppBreakpoints.of(context) == AppSize.compact;
      final dates = AppDateFormatter(locale);
      final time = AppTimeFormatter(locale);

      String changeSummary(AttendanceCorrectionRequest request) {
        if (request.changes.isEmpty) return '—';
        final change = request.changes.first;
        final original = change.originalTimestamp == null
            ? l.historyNotRecorded
            : time.time(change.originalTimestamp!);
        final summary = l.timeRange(
          original,
          time.time(change.requestedTimestamp),
        );
        return request.changes.length > 1
            ? '$summary (+${request.changes.length - 1})'
            : summary;
      }

      void open(AttendanceCorrectionRequest request) => context.push(
        widget.review
            ? AppRoutes.attendanceReviewDetails(request.id)
            : AppRoutes.attendanceCorrectionDetails(request.id),
      );

      Widget actionMenu(AttendanceCorrectionRequest request) => AppActionMenu(
        tooltip: l.actions,
        actions: [
          AppMenuAction(
            label: (l) => widget.review ? l.correctionReview : l.correctionView,
            onPressed: () => open(request),
          ),
        ],
      );

      Widget body;
      if (state.loading && state.items.isEmpty) {
        body = const AppCollectionSkeleton();
      } else if (state.failure != null && state.items.isEmpty) {
        body = AppErrorState(
          message: l.somethingWentWrong,
          onRetry: () => context.read<AttendanceCorrectionBloc>().add(
            widget.review
                ? const CorrectionQueueStarted()
                : const CorrectionMyStarted(),
          ),
        );
      } else if (state.items.isEmpty) {
        body = AppCollectionEmptyState.noData(
          title: l.correctionEmptyTitle,
          message: l.correctionEmptyNote,
          icon: Icons.fact_check_outlined,
        );
      } else if (items.isEmpty) {
        body = AppCollectionEmptyState.noResults(
          title: l.correctionNoResultsTitle,
          message: l.correctionNoResultsNote,
          icon: Icons.fact_check_outlined,
          onClearFilters: () => setState(() {
            search.clear();
            filter = null;
          }),
        );
      } else if (compact) {
        body = Column(
          children: [
            for (final request in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppMobileRecordCard(
                  title: widget.review
                      ? (request.employeeName ?? l.historyNotRecorded)
                      : correctionTypeLabel(context, request.requestType),
                  subtitle: widget.review
                      ? (request.employeeCode ?? changeSummary(request))
                      : dates.date(request.requestedAt),
                  tertiary: widget.review
                      ? '${correctionTypeLabel(context, request.requestType)} · ${changeSummary(request)}'
                      : changeSummary(request),
                  status: _statusOf(request.status),
                  statusLabel: correctionStatusLabel(context, request.status),
                  onTap: () => open(request),
                  trailing: actionMenu(request),
                ),
              ),
          ],
        );
      } else {
        body = AppCollectionSurface(
          child: AppDataTable(
            columns: [
              if (widget.review) DataColumn(label: Text(l.reportEmployee)),
              DataColumn(label: Text(l.date)),
              DataColumn(label: Text(l.correctionType)),
              DataColumn(label: Text(l.correctionChange)),
              DataColumn(label: Text(l.status)),
              DataColumn(
                label: Semantics(
                  label: l.actions,
                  child: const Icon(Icons.more_horiz),
                ),
              ),
            ],
            rows: [
              for (final request in items)
                DataRow(
                  onSelectChanged: (_) => open(request),
                  cells: [
                    if (widget.review)
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(request.employeeName ?? l.historyNotRecorded),
                            if (request.employeeCode != null)
                              Text(
                                request.employeeCode!,
                                textDirection: TextDirection.ltr,
                                style: AppTypography.of(context).caption,
                              ),
                          ],
                        ),
                      ),
                    DataCell(Text(dates.date(request.requestedAt))),
                    DataCell(
                      Text(correctionTypeLabel(context, request.requestType)),
                    ),
                    DataCell(Text(changeSummary(request))),
                    DataCell(
                      AppStatusBadge(
                        label: correctionStatusLabel(context, request.status),
                        status: _statusOf(request.status),
                      ),
                    ),
                    DataCell(actionMenu(request)),
                  ],
                ),
            ],
          ),
        );
      }

      return AppPage(
        header: AppPageHeader(
          title: widget.review
              ? l.correctionReviewQueue
              : l.correctionMyRequests,
        ),
        filters: AppCollectionToolbar(
          search: widget.review
              ? AppSearchField(
                  controller: search,
                  hint: l.workforceSearch,
                  onChanged: (_) => setState(() {}),
                )
              : null,
          filterButton: AppFilterButton(
            activeCount: filter == null ? 0 : 1,
            onPressed: () => _openStatusFilter(context),
          ),
          resultCount: state.loading && state.items.isEmpty
              ? null
              : AppResultCount(
                  filtered: items.length,
                  total: state.items.length,
                ),
          activeFilters: filter == null
              ? null
              : AppActiveFilters(
                  filters: [
                    AppActiveFilter(
                      label: _statusChipLabel(context, filter!),
                      onRemove: () => setState(() => filter = null),
                    ),
                  ],
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.loading && state.items.isNotEmpty)
              const LinearProgressIndicator(minHeight: 2),
            if (state.failure != null && state.items.isNotEmpty) ...[
              AppAlert(
                message: l.somethingWentWrong,
                status: AppStatus.warning,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            body,
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
          header: AppDetailHeader(title: l.correctionReviewQueue),
          child: const AppLoadingState(),
        );
      }
      if (request == null) {
        return AppPage(
          header: AppDetailHeader(title: l.correctionReviewQueue),
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
        header: AppDetailHeader(
          title: review ? l.correctionReviewQueue : l.correctionMyRequests,
          status: AppDetailStatus(
            label: correctionStatusLabel(context, request.status),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
