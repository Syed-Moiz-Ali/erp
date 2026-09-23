import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';

class SyncSettingsPage extends StatelessWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AppSyncStatusCubit, AppSyncStatusState>(
    builder: (context, state) {
      final l = context.l10n;
      final cubit = context.read<AppSyncStatusCubit>();
      final formatter = AppDateFormatter(Localizations.localeOf(context));
      final statusLabel = state.offline
          ? l.syncOfflineTitle
          : state.counts.needsAttention > 0
          ? l.syncNeedsAttention
          : state.syncing
          ? l.syncSyncing
          : state.counts.waiting > 0
          ? l.syncChangesWaiting
          : l.syncAllChangesSynced;
      return AppPage(
        maxWidth: AppDimensions.details,
        header: AppPageHeader(title: l.syncDataAndSync),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusLabel, style: AppTypography.of(context).cardTitle),
                  const SizedBox(height: AppSpacing.sm),
                  _line(context, l.syncPendingOperations, state.counts.waiting),
                  _line(
                    context,
                    l.syncFailedOperations,
                    state.counts.needsAttention,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    state.lastSyncedAt == null
                        ? l.syncNever
                        : '${l.syncLastSync}: '
                              '${formatter.relative(state.lastSyncedAt!, l)}',
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textSecondary),
                  ),
                  if (cubit.onSyncNow != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppSecondaryButton(
                      label: l.syncRetryNow,
                      onPressed: state.syncing ? null : cubit.syncNow,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _line(BuildContext context, String label, int value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          AppNumberFormatter(Localizations.localeOf(context)).integer(value),
        ),
      ],
    ),
  );
}
