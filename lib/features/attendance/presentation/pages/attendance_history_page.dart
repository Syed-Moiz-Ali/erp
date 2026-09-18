import '../../../../design_system/theme/app_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/localization/app_formatters.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_history.dart';
import '../attendance_history_presentation.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_history_bloc.dart';
import '../widgets/attendance_history_components.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AttendanceHistoryBloc, AttendanceHistoryState>(
    builder: (context, state) {
      final bloc = context.read<AttendanceHistoryBloc>(),
          l = context.l10n,
          q = state.query;
      return RefreshIndicator(
        onRefresh: () async {
          bloc.add(const AttendanceHistoryRefreshRequested());
          await bloc.stream.firstWhere(
            (s) => !s.loading,
            orElse: () => bloc.state,
          );
        },
        child: AppPage(
          scrollPhysics: const AlwaysScrollableScrollPhysics(),
          header: AppPageHeader(
            title: l.historyTitle,
            compactActionsInline: true,
            actions: [
              AppIconButton(
                icon: Icons.refresh,
                tooltip: l.historyRetry,
                onPressed: state.loading
                    ? null
                    : () => bloc.add(const AttendanceHistoryRefreshRequested()),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (q != null)
                AttendanceMonthSelector(
                  month: q.start,
                  current: state.currentMonth!,
                  onChanged: (d) => bloc.add(AttendanceHistoryMonthChanged(d)),
                ),
              const SizedBox(height: AppSpacing.xl),
              if (state.failure != null) ...[
                AppNotice(
                  title: AttendancePresentation.failure(
                    context,
                    state.failure!,
                  ),
                  status: AppStatus.danger,
                  action: AppTextButton(
                    label: l.historyRetry,
                    onPressed: () =>
                        bloc.add(const AttendanceHistoryRefreshRequested()),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (state.loading && state.data == null)
                const AttendanceHistorySkeleton(),
              if (q != null && (state.data != null || !state.loading)) ...[
                if (state.data != null) ...[
                  AttendanceMonthlySummary(summary: state.data!.summary),
                  const SizedBox(height: AppSpacing.xl),
                ],
                LayoutBuilder(
                  builder: (context, c) {
                    final compact =
                        AppBreakpoints.classify(c.maxWidth) == AppSize.compact;
                    return AppFilterBar(
                      children: [
                        if (compact)
                          AppSecondaryButton(
                            label: l.historyFilterCount(
                              AppNumberFormatter(
                                Localizations.localeOf(context),
                              ).integer(q.statuses.length),
                            ),
                            icon: Icons.filter_list,
                            onPressed: () async {
                              final values =
                                  await AppBottomSheet.show<
                                    Set<AttendanceHistoryStatus>
                                  >(
                                    context,
                                    builder: (_) => BlocProvider(
                                      create: (_) =>
                                          AttendanceHistoryFilterDraft(
                                            q.statuses,
                                          ),
                                      child:
                                          const AttendanceHistoryFilterSheet(),
                                    ),
                                  );
                              if (values != null && !bloc.isClosed) {
                                bloc.add(
                                  AttendanceHistoryFilterChanged(values),
                                );
                              }
                            },
                          )
                        else ...[
                          AppFilterChip(
                            label: l.historyAllStatuses,
                            selected: q.statuses.isEmpty,
                            onSelected: (_) =>
                                bloc.add(AttendanceHistoryFilterChanged({})),
                          ),
                          for (final s in AttendanceHistoryStatus.values)
                            AppFilterChip(
                              label: AttendanceHistoryPresentation.label(
                                context,
                                s,
                              ),
                              selected: q.statuses.contains(s),
                              onSelected: (v) => bloc.add(
                                AttendanceHistoryFilterChanged(
                                  {...q.statuses}
                                    ..remove(s)
                                    ..addAll(v ? [s] : []),
                                ),
                              ),
                            ),
                        ],
                        if (q.statuses.isNotEmpty)
                          AppTextButton(
                            label: l.historyClearFilters,
                            onPressed: () =>
                                bloc.add(AttendanceHistoryFilterChanged({})),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.data case final data?) ...[
                  if (data.items.isEmpty)
                    AppEmptyState(
                      title: data.summary.records == 0
                          ? l.historyEmpty
                          : l.historyFilteredEmpty,
                      message: data.summary.records == 0
                          ? l.historyEmptyNote
                          : l.historyFilteredNote,
                      icon: Icons.event_note_outlined,
                    ),
                  if (data.items.isNotEmpty)
                    LayoutBuilder(
                      builder: (context, c) {
                        void open(AttendanceHistoryItem day) {
                          if (day.status == AttendanceHistoryStatus.working) {
                            context.go(AppRoutes.attendance);
                          } else {
                            context.push(
                              AppRoutes.attendanceDayDetails(day.id),
                            );
                          }
                        }

                        final size = AppBreakpoints.classify(c.maxWidth);
                        return size == AppSize.compact || size == AppSize.medium
                            ? AttendanceHistoryList(data: data, onOpen: open)
                            : AppCard(
                                padding: EdgeInsets.zero,
                                child: AttendanceHistoryTable(
                                  data: data,
                                  onOpen: open,
                                ),
                              );
                      },
                    ),
                  AppTablePagination(
                    page: q.page,
                    pageSize: q.pageSize,
                    total: data.total,
                    onPageChanged: (p) =>
                        bloc.add(AttendanceHistoryPageChanged(p)),
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    },
  );
}
