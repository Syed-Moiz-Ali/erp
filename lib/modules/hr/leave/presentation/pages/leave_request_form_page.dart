import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_blocs.dart';

class LeaveRequestFormPage extends StatelessWidget {
  const LeaveRequestFormPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<LeaveRequestFormBloc, LeaveRequestFormState>(
    listener: (c, s) {
      if (s.submitted != null) {
        AppFeedback.showMessage(c, message: (l) => l.leaveRequestSubmitted);
        c.go(AppRoutes.leaveMyRequests);
      } else if (s.failure != null) {
        AppFeedback.showMessage(
          c,
          message: (l) => configurationFailure(s.failure!, l),
        );
      }
    },
    builder: (c, s) {
      final l = c.l10n, bloc = c.read<LeaveRequestFormBloc>(), d = s.draft;
      LeaveType? selected;
      for (final type in s.types) {
        if (type.id == d.leaveTypeId) selected = type;
      }
      void change(LeaveRequestDraft Function(LeaveRequestDraft) update) =>
          bloc.add(LeaveRequestDraftChanged(update));
      return AppPage(
        maxWidth: 880,
        header: AppPageHeader(
          title: l.leaveRequestTitle,
          actions: [
            AppSecondaryButton(
              label: l.cancel,
              onPressed: s.submitting ? null : () => c.go(AppRoutes.leave),
            ),
          ],
        ),
        child: s.loadingTypes
            ? const AppLoadingState()
            : s.types.isEmpty
            ? AppEmptyState(title: l.leaveNoTypes, message: l.leaveNoTypes)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppFormSection(
                          title: l.leaveRequestTitle,
                          child: AppFormGrid(
                            children: [
                              AppSelectField<String>(
                                label: l.leaveType,
                                value: d.leaveTypeId.isEmpty
                                    ? null
                                    : d.leaveTypeId,
                                enabled: !s.submitting,
                                options: [
                                  for (final type in s.types)
                                    AppSelectOption(type.id, type.name),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    change((d) => d.copyWith(leaveTypeId: v));
                                  }
                                },
                              ),
                              AppDateField(
                                label: l.leaveStartDate,
                                value: d.startDate,
                                enabled: !s.submitting,
                                onChanged: (v) {
                                  change(
                                    (d) => d.copyWith(
                                      startDate: v,
                                      endDate: d.endDate.isBefore(v)
                                          ? v
                                          : d.endDate,
                                    ),
                                  );
                                },
                              ),
                              AppDateField(
                                label: l.leaveEndDate,
                                value: d.endDate,
                                enabled: !s.submitting,
                                onChanged: (v) =>
                                    change((d) => d.copyWith(endDate: v)),
                              ),
                              if (selected == null || selected.allowsHalfDay)
                                AppSelectField<LeaveDayPortion>(
                                  label: l.leaveStartPortion,
                                  value: d.startPortion,
                                  enabled: !s.submitting,
                                  options: [
                                    AppSelectOption(
                                      LeaveDayPortion.fullDay,
                                      l.leaveDayFull,
                                    ),
                                    AppSelectOption(
                                      LeaveDayPortion.firstHalf,
                                      l.leaveDayFirstHalf,
                                    ),
                                    AppSelectOption(
                                      LeaveDayPortion.secondHalf,
                                      l.leaveDaySecondHalf,
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      change(
                                        (d) => d.copyWith(startPortion: v),
                                      );
                                    }
                                  },
                                ),
                              if (selected == null || selected.allowsHalfDay)
                                AppSelectField<LeaveDayPortion>(
                                  label: l.leaveEndPortion,
                                  value: d.endPortion,
                                  enabled: !s.submitting,
                                  options: [
                                    AppSelectOption(
                                      LeaveDayPortion.fullDay,
                                      l.leaveDayFull,
                                    ),
                                    AppSelectOption(
                                      LeaveDayPortion.firstHalf,
                                      l.leaveDayFirstHalf,
                                    ),
                                    AppSelectOption(
                                      LeaveDayPortion.secondHalf,
                                      l.leaveDaySecondHalf,
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      change((d) => d.copyWith(endPortion: v));
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          label: l.leaveReasonLabel,
                          initialValue: d.reason,
                          enabled: !s.submitting,
                          maxLines: 3,
                          onChanged: (v) =>
                              change((d) => d.copyWith(reason: v)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (s.preview != null)
                    AppCard(
                      child: AppFormSection(
                        title: l.leavePreviewTitle,
                        child: AppDetailsGrid(
                          fields: [
                            AppDetailField(
                              label: l.leaveRequestedDays,
                              value: '${s.preview!.requestedDays} ${l.days}',
                            ),
                            AppDetailField(
                              label: l.leaveAvailableDays,
                              value: '${s.preview!.available} ${l.days}',
                            ),
                            AppDetailField(
                              label: l.leaveAfterApproval,
                              value: '${s.preview!.afterApproval} ${l.days}',
                            ),
                            AppDetailField(
                              label: l.leaveExcludedWeekends,
                              value: '${s.preview!.excludedWeekends}',
                            ),
                            AppDetailField(
                              label: l.leaveExcludedHolidays,
                              value: '${s.preview!.excludedHolidays}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppSecondaryButton(
                        label: l.cancel,
                        onPressed: s.submitting
                            ? null
                            : () => c.go(AppRoutes.leave),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppPrimaryButton(
                        label: l.leaveSubmitRequest,
                        loading: s.submitting,
                        onPressed: s.submitting
                            ? null
                            : () => bloc.add(const LeaveRequestSubmitted()),
                      ),
                    ],
                  ),
                ],
              ),
      );
    },
  );
}
