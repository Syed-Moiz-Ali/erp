import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';
import 'leave_request_list_page.dart';

class LeaveRequestDetailsPage extends StatelessWidget {
  const LeaveRequestDetailsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LeaveRequestDetailsBloc, LeaveRequestDetailsState>(
        listener: (c, s) {
          if (s.actionCompleted) {
            AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
          } else if (s.failure != null && s.row != null) {
            AppFeedback.showMessage(
              c,
              message: (l) => configurationFailure(s.failure!, l),
            );
          }
        },
        builder: (c, s) {
          final l = c.l10n, bloc = c.read<LeaveRequestDetailsBloc>();
          if (s.loading) return const AppPage(child: AppLoadingState());
          final row = s.row;
          if (row == null) {
            return AppPage(
              child: s.failure == null
                  ? AppEmptyState(
                      title: l.leaveRequestNotFound,
                      message: l.leaveRequestNotFound,
                    )
                  : AppErrorState(
                      message: configurationFailure(s.failure!, l),
                      onRetry: () =>
                          bloc.add(const LeaveRequestDetailsStarted()),
                    ),
            );
          }
          final request = row.request;
          final perms = PermissionChecker(bloc.context.user.permissions);
          final isSelf =
              bloc.context.employeeReference?.id == request.employeeId;
          final canReview =
              request.isPending &&
              !isSelf &&
              (perms.can(AppPermission.leaveApproveTeam) ||
                  perms.can(AppPermission.leaveApproveAll));
          final canCancel = isSelf && request.isPending;
          return AppPage(
            header: AppPageHeader(
              title: request.typeSnapshot.name,
              subtitle: row.employeeName.isEmpty ? null : row.employeeName,
              actions: [
                AppStatusBadge(
                  label: leaveRequestStatusLabel(request.status, l),
                  status: leaveStatusColor(request.status),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (s.failure != null)
                  AppErrorState(
                    message: configurationFailure(s.failure!, l),
                    onRetry: () => bloc.add(const LeaveRequestDetailsStarted()),
                  ),
                if (row.employeeName.isNotEmpty)
                  AppCard(
                    child: AppDetailsGrid(
                      fields: [
                        AppDetailField(
                          label: l.leaveEmployee,
                          value: row.employeeName,
                        ),
                        AppDetailField(
                          label: l.leaveDepartment,
                          value: row.department.isEmpty
                              ? l.noSelection
                              : row.department,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: AppFormSection(
                    title: l.leaveRequestTitle,
                    child: AppDetailsGrid(
                      fields: [
                        AppDetailField(
                          label: l.leaveType,
                          value: request.typeSnapshot.name,
                        ),
                        AppDetailField(
                          label: l.leaveDateRange,
                          value:
                              '${configurationDate(c, request.startDate)} - '
                              '${configurationDate(c, request.endDate)}',
                        ),
                        AppDetailField(
                          label: l.leaveStartPortion,
                          value: leaveDayPortionLabel(request.startPortion, l),
                        ),
                        AppDetailField(
                          label: l.leaveEndPortion,
                          value: leaveDayPortionLabel(request.endPortion, l),
                        ),
                        AppDetailField(
                          label: l.leaveRequestedDays,
                          value: '${request.requestedDays} ${l.days}',
                        ),
                        AppDetailField(
                          label: l.leaveCompensation,
                          value: leaveCompensationLabel(
                            request.typeSnapshot.compensation,
                            l,
                          ),
                        ),
                        if (request.reason.isNotEmpty)
                          AppDetailField(
                            label: l.leaveReasonLabel,
                            value: request.reason,
                          ),
                        if (request.submittedAt != null)
                          AppDetailField(
                            label: l.leaveSubmittedOn,
                            value: configurationDate(c, request.submittedAt!),
                          ),
                        if (request.reviewNote != null &&
                            request.reviewNote!.isNotEmpty)
                          AppDetailField(
                            label: l.leaveReviewNote,
                            value: request.reviewNote!,
                          ),
                        if (request.cancellationReason != null &&
                            request.cancellationReason!.isNotEmpty)
                          AppDetailField(
                            label: l.leaveCancelReason,
                            value: request.cancellationReason!,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (canReview)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppSecondaryButton(
                        label: l.leaveReject,
                        onPressed: s.busy
                            ? null
                            : () async {
                                final note = await _promptText(
                                  c,
                                  title: l.leaveReject,
                                  label: l.leaveReviewNote,
                                  required: true,
                                );
                                if (note != null && c.mounted) {
                                  bloc.add(LeaveRequestRejected(note));
                                }
                              },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppPrimaryButton(
                        label: l.leaveApprove,
                        loading: s.busy,
                        onPressed: s.busy
                            ? null
                            : () async {
                                final note = await _promptText(
                                  c,
                                  title: l.leaveApprove,
                                  label: l.leaveReviewNote,
                                );
                                if (note != null && c.mounted) {
                                  bloc.add(LeaveRequestApproved(note));
                                }
                              },
                      ),
                    ],
                  ),
                if (canCancel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppSecondaryButton(
                        label: l.leaveCancelRequest,
                        onPressed: s.busy
                            ? null
                            : () async {
                                final reason = await _promptText(
                                  c,
                                  title: l.leaveCancelRequest,
                                  label: l.leaveCancelReason,
                                );
                                if (reason != null && c.mounted) {
                                  bloc.add(LeaveRequestCancelled(reason));
                                }
                              },
                      ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      );
}

Future<String?> _promptText(
  BuildContext context, {
  required String title,
  required String label,
  bool required = false,
}) async {
  final controller = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: AppTextField(label: label, controller: controller, maxLines: 3),
      actions: [
        AppTextButton(
          label: context.l10n.cancel,
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        AppPrimaryButton(
          label: context.l10n.confirm,
          onPressed: () {
            final text = controller.text.trim();
            if (required && text.isEmpty) return;
            Navigator.of(dialogContext).pop(text);
          },
        ),
      ],
    ),
  );
  controller.dispose();
  return value;
}
