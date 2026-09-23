import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';
import 'bloc/reminder_settings_cubit.dart';

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ReminderSettingsCubit, ReminderSettingsState>(
        builder: (context, state) {
          final l = context.l10n;
          final cubit = context.read<ReminderSettingsCubit>();
          final prefs = state.preferences;
          return AppPage(
            maxWidth: AppDimensions.details,
            header: AppPageHeader(title: l.notificationsReminders),
            child: state.loading
                ? const AppSkeleton(height: 200)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSectionHeader(title: l.reminderAttendanceSection),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.reminderShift),
                              subtitle: Text(l.reminderNotifyBefore),
                              value: prefs.shiftReminderEnabled,
                              onChanged: state.saving
                                  ? null
                                  : cubit.setShiftEnabled,
                            ),
                            if (prefs.shiftReminderEnabled)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: AppDropdown<int>(
                                  label: l.reminderMinutesBefore,
                                  value: prefs.shiftReminderMinutesBefore,
                                  items: [
                                    for (final minutes in const [5, 10, 15, 30])
                                      DropdownMenuItem(
                                        value: minutes,
                                        child: Text(minutes.toString()),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) cubit.setMinutes(value);
                                  },
                                ),
                              ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.reminderPunchOut),
                              subtitle: Text(l.notifPunchOutBody),
                              value: prefs.punchOutReminderEnabled,
                              onChanged: state.saving
                                  ? null
                                  : cubit.setPunchOutEnabled,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.reminderNotificationPermission,
                              style: AppTypography.of(context).cardTitle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              state.permission ==
                                      DeviceNotificationPermission.granted
                                  ? l.reminderNotificationsEnabled
                                  : l.reminderNotificationsDisabled,
                              style: AppTypography.of(context).caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (state.permission !=
                                DeviceNotificationPermission.granted) ...[
                              const SizedBox(height: AppSpacing.md),
                              AppSecondaryButton(
                                label: l.reminderOpenSettings,
                                onPressed: cubit.openSettings,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (state.saved) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AppNotice(
                          title: l.reminderSaved,
                          status: AppStatus.success,
                        ),
                      ],
                      if (state.failure != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AppNotice(
                          title: l.reminderSaveFailed,
                          status: AppStatus.danger,
                        ),
                      ],
                    ],
                  ),
          );
        },
      );
}
