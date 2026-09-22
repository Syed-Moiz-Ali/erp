import '../../../../design_system/theme/app_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../shared/navigation/app_navigation.dart';
import '../../../../core/security/app_permission.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/localization/app_formatters.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_history.dart';
import '../../domain/attendance_models.dart';
import '../../domain/attendance_summary_calculator.dart';
import '../attendance_history_presentation.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_day_details_bloc.dart';
import '../widgets/attendance_history_components.dart';
import '../widgets/attendance_timeline.dart';
import 'attendance_correction_pages.dart';

class AttendanceDayDetailsPage extends StatelessWidget {
  const AttendanceDayDetailsPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AttendanceDayDetailsBloc, AttendanceDayDetailsState>(
    builder: (context, state) {
      final l = context.l10n, bloc = context.read<AttendanceDayDetailsBloc>();
      return AppPage(
        header: AppPageHeader(
          title: l.historyDetails,
          compactActionsInline: true,
          breadcrumbs: AppBreakpoints.of(context) == AppSize.compact
              ? null
              : AppBreadcrumbs(
                  items: [
                    AppBreadcrumbItem(
                      label: l.shellAttendance,
                      route: AppRoutes.attendance,
                    ),
                    AppBreadcrumbItem(
                      label: l.historyNav,
                      route: AppRoutes.attendanceHistory,
                    ),
                    AppBreadcrumbItem(label: l.historyDetails),
                  ],
                  onNavigate: (route) => context.go(route),
                ),
          actions: [
            AppTextButton(
              label: l.historyNav,
              icon: Icons.arrow_back,
              onPressed: () => context.popOrGo(AppRoutes.attendanceHistory),
            ),
            AppIconButton(
              icon: Icons.refresh,
              tooltip: l.historyRetry,
              onPressed: () =>
                  bloc.add(const AttendanceDayDetailsRefreshRequested()),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.failure != null)
              AppNotice(
                title: AttendancePresentation.failure(context, state.failure!),
                status: AppStatus.danger,
              ),
            if (state.loading && state.data == null)
              const AttendanceHistorySkeleton(),
            if (state.notFound)
              AppEmptyState(
                title: l.historyNotFound,
                message: l.historyNotFoundNote,
                icon: Icons.event_busy_outlined,
              ),
            if (state.data case final details?) _Record(details: details),
          ],
        ),
      );
    },
  );
}

class _Record extends StatelessWidget {
  const _Record({required this.details});
  final AttendanceDayDetails details;
  @override
  Widget build(BuildContext context) {
    final d = details.day, l = context.l10n, status = details.status;
    final calculated = const AttendanceSummaryCalculator().calculate(
      details.events,
      details.asOf,
    );
    final breaks = calculated is Success<AttendanceSummary>
        ? calculated.value.breaks
        : <BreakSession>[];
    final completed =
        d.state == AttendanceWorkdayState.completed && d.punchOutAt != null;
    String total(Duration value) => completed
        ? AttendancePresentation.duration(context, value)
        : l.historyIncomplete;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              AppDateFormatter(
                Localizations.localeOf(context),
              ).fullDate(d.attendanceDate),
              style: AppTypography.of(context).sectionTitle,
            ),
            AttendanceHistoryPresentation.badge(context, status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(d.snapshot.shift.name, style: AppTypography.of(context).body),
        const SizedBox(height: AppSpacing.xl),
        if (!completed) ...[
          AppNotice(
            title: status == AttendanceHistoryStatus.incomplete
                ? l.historyMissingOut
                : l.attendanceWorking,
            message: status == AttendanceHistoryStatus.incomplete
                ? l.historyIncompleteNote
                : l.historyActiveNote,
            status: AppStatus.warning,
            action: status == AttendanceHistoryStatus.working
                ? AppTextButton(
                    label: l.historyGoToday,
                    onPressed: () => context.go(AppRoutes.attendance),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (d.syncStatus == AttendanceSyncStatus.rejected) ...[
          AppNotice(
            title: l.historyVerificationIssue,
            message: l.historyContactHr,
            status: AppStatus.danger,
          ),
          const SizedBox(height: AppSpacing.lg),
        ] else if (d.syncStatus != AttendanceSyncStatus.synced) ...[
          AppNotice(
            title: AttendancePresentation.sync(context, d.syncStatus),
            status: d.syncStatus == AttendanceSyncStatus.failed
                ? AppStatus.danger
                : AppStatus.info,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (context.read<AuthBloc?>()?.state.context?.user.permissions.contains(
                  AppPermission.attendanceRequestCorrection,
                ) ==
                true &&
            d.snapshot.policy.allowEmployeeCorrectionRequest) ...[
          AppSecondaryButton(
            label: l.correctionRequest,
            onPressed: () =>
                context.push(AppRoutes.attendanceCorrectionForm(d.id)),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (details.corrections.isNotEmpty) ...[
          for (final correction in details.corrections) ...[
            AppDetailsSection(
              title: correctionTypeLabel(context, correction.requestType),
              details: {l.correctionApproved: correction.reason},
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final change in correction.changes)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppChangeComparison(
                  title: correctionTypeLabel(context, correction.requestType),
                  beforeLabel: l.correctionOriginal,
                  before: AttendanceHistoryPresentation.time(
                    context,
                    d,
                    change.originalTimestamp,
                    includeDate: true,
                  ),
                  afterLabel: l.correctionRequested,
                  after: AttendanceHistoryPresentation.time(
                    context,
                    d,
                    change.requestedTimestamp,
                    includeDate: true,
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
        AppOperationalLayout(
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppFormSection(
                title: l.historyDailySummary,
                child: AppDetailsGrid(
                  compact: true,
                  fields: [
                    AppDetailField(
                      label: l.attendancePunchIn,
                      value: AttendanceHistoryPresentation.time(
                        context,
                        d,
                        d.punchInAt,
                        includeDate: true,
                      ),
                    ),
                    AppDetailField(
                      label: l.attendancePunchOut,
                      value: AttendanceHistoryPresentation.time(
                        context,
                        d,
                        d.punchOutAt,
                        includeDate: true,
                      ),
                    ),
                    AppDetailField(
                      label: l.attendanceElapsedTime,
                      value: total(d.totalElapsedDuration),
                    ),
                    AppDetailField(
                      label: l.attendanceWorkedTime,
                      value: total(d.totalWorkDuration),
                    ),
                    AppDetailField(
                      label: l.attendanceTotalBreak,
                      value: total(d.totalBreakDuration),
                    ),
                    AppDetailField(
                      label: l.historyStatus,
                      value: AttendanceHistoryPresentation.label(
                        context,
                        status,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppFormSection(
                title: l.historyTimeline,
                child: AttendanceTimeline(
                  day: d,
                  events: details.events,
                  breaks: breaks,
                  includeDates: true,
                ),
              ),
            ],
          ),
          supporting: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppFormSection(
                title: l.dashboardShift,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      d.snapshot.shift.name,
                      style: AppTypography.of(context).cardTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AttendanceHistoryPresentation.range(
                        context,
                        AttendanceHistoryPresentation.time(
                          context,
                          d,
                          d.snapshot.scheduledStart,
                          includeDate: true,
                        ),
                        AttendanceHistoryPresentation.time(
                          context,
                          d,
                          d.snapshot.scheduledEnd,
                          includeDate: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDetailField(
                      label: l.historyExpected,
                      value: AttendancePresentation.duration(
                        context,
                        d.snapshot.scheduledEnd.difference(
                          d.snapshot.scheduledStart,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppDetailField(
                      label: l.historyGrace,
                      value: AttendancePresentation.duration(
                        context,
                        Duration(minutes: d.snapshot.shift.gracePeriodMinutes),
                      ),
                    ),
                    if (d.snapshot.shift.isOvernight) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppStatusBadge(
                        label: l.historyOvernight,
                        status: AppStatus.info,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppDetailField(
                      label: l.empPolicy,
                      value: d.snapshot.policy.name,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (d.snapshot.workLocation != null) ...[
                AppFormSection(
                  title: l.attendanceWorkLocation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        d.snapshot.workLocation!.name,
                        style: AppTypography.of(context).cardTitle,
                      ),
                      for (final e in details.events.where(
                        (e) =>
                            e.eventType == AttendanceEventType.punchIn ||
                            e.eventType == AttendanceEventType.punchOut,
                      ))
                        if (e.locationValidation.state ==
                                AttendanceLocationState.insideAllowedArea ||
                            e.locationValidation.state ==
                                AttendanceLocationState
                                    .outsideAllowedAreaAllowed)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: AppDetailField(
                              label: AttendancePresentation.event(
                                context,
                                e.eventType,
                              ),
                              value:
                                  e.locationValidation.state ==
                                      AttendanceLocationState.insideAllowedArea
                                  ? l.historyWithinArea
                                  : l.historyOutsideAllowed,
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppFormSection(
                title: l.historyBreaks,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (breaks.isEmpty)
                      Text(
                        l.historyNoBreaks,
                        style: AppTypography.of(context).bodySmall,
                      ),
                    for (final b in breaks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AttendanceHistoryPresentation.range(
                                context,
                                AttendanceHistoryPresentation.time(
                                  context,
                                  d,
                                  b.startedAt,
                                  includeDate: true,
                                ),
                                AttendanceHistoryPresentation.time(
                                  context,
                                  d,
                                  b.endedAt,
                                  includeDate: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            if (b.isOpen)
                              AppNotice(
                                title: status == AttendanceHistoryStatus.working
                                    ? l.attendanceOnBreak
                                    : l.historyOpenBreak,
                                message:
                                    status == AttendanceHistoryStatus.working
                                    ? l.historyActiveNote
                                    : l.historyOpenBreakNote,
                                status: AppStatus.warning,
                              )
                            else
                              Text(
                                AttendancePresentation.duration(
                                  context,
                                  b.duration,
                                ),
                                style: AppTypography.of(context).bodySmall,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
