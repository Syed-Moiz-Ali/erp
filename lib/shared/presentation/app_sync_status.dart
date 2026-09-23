import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';

enum _SyncTone { quiet, syncing, pending, attention, offline }

class AppSyncIndicator extends StatefulWidget {
  const AppSyncIndicator({super.key, required this.cubit});
  final AppSyncStatusCubit? cubit;
  @override
  State<AppSyncIndicator> createState() => _AppSyncIndicatorState();
}

class _AppSyncIndicatorState extends State<AppSyncIndicator> {
  StreamSubscription<AppSyncStatusState>? _subscription;
  AppSyncStatusState _state = const AppSyncStatusState();

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant AppSyncIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cubit != widget.cubit) _bind();
  }

  void _bind() {
    _subscription?.cancel();
    final cubit = widget.cubit;
    if (cubit == null) {
      _state = const AppSyncStatusState();
      return;
    }
    _state = cubit.state;
    _subscription = cubit.stream.listen((value) {
      if (mounted) setState(() => _state = value);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  _SyncTone get _tone {
    if (_state.offline) return _SyncTone.offline;
    if (_state.counts.needsAttention > 0) return _SyncTone.attention;
    if (_state.syncing || _state.counts.processing > 0) {
      return _SyncTone.syncing;
    }
    if (_state.counts.waiting > 0) return _SyncTone.pending;
    return _SyncTone.quiet;
  }

  (IconData, String, Color) _present(AppLocalizations l) => switch (_tone) {
    _SyncTone.offline => (
      Icons.cloud_off_outlined,
      l.syncOfflineTitle,
      AppColors.warning,
    ),
    _SyncTone.attention => (
      Icons.error_outline,
      l.syncNeedsAttention,
      AppColors.danger,
    ),
    _SyncTone.syncing => (Icons.sync, l.syncSyncing, AppColors.brandPrimary),
    _SyncTone.pending => (
      Icons.cloud_upload_outlined,
      l.syncPending,
      AppColors.textSecondary,
    ),
    _SyncTone.quiet => (
      Icons.cloud_done_outlined,
      l.syncAllChangesSynced,
      AppColors.textMuted,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (icon, tooltip, color) = _present(l);
    return IconButton(
      tooltip: tooltip,
      onPressed: () => _showDetails(context),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      icon: Icon(icon, size: 20, color: color),
    );
  }

  Future<void> _showDetails(BuildContext context) => AppBottomSheet.show<void>(
    context,
    builder: (sheet) => Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: context.l10n.syncStatusTitle),
          const SizedBox(height: AppSpacing.md),
          _row(context, context.l10n.syncPending, _state.counts.waiting),
          _row(
            context,
            context.l10n.syncFailedOperations,
            _state.counts.needsAttention,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _state.lastSyncedAt == null
                ? context.l10n.syncNever
                : '${context.l10n.syncLastSync}: '
                      '${AppDateFormatter(Localizations.localeOf(context)).relative(_state.lastSyncedAt!, context.l10n)}',
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textSecondary),
          ),
          if (_state.offline) ...[
            const SizedBox(height: AppSpacing.sm),
            AppNotice(
              title: context.l10n.syncOfflineMessage,
              status: AppStatus.info,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (widget.cubit?.onSyncNow != null)
            AppPrimaryButton(
              label: context.l10n.syncRetryNow,
              onPressed: _state.syncing
                  ? null
                  : () {
                      Navigator.pop(sheet);
                      unawaited(widget.cubit!.syncNow());
                    },
            ),
        ],
      ),
    ),
  );

  Widget _row(BuildContext context, String label, int value) => Padding(
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

/// Thin app-wide banner. Normal state is silent; only meaningful states show.
class AppSyncStatusBanner extends StatefulWidget {
  const AppSyncStatusBanner({
    super.key,
    required this.cubit,
    required this.child,
  });
  final AppSyncStatusCubit? cubit;
  final Widget child;
  @override
  State<AppSyncStatusBanner> createState() => _AppSyncStatusBannerState();
}

class _AppSyncStatusBannerState extends State<AppSyncStatusBanner> {
  StreamSubscription<AppSyncStatusState>? _subscription;
  AppSyncStatusState _state = const AppSyncStatusState();

  @override
  void initState() {
    super.initState();
    _subscription = widget.cubit?.stream.listen((value) {
      if (mounted) setState(() => _state = value);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final show = _state.offline || _state.counts.needsAttention > 0;
    return Column(
      children: [
        AnimatedSize(
          duration: AppMotion.fast,
          child: show
              ? AppNotice(
                  title: _state.offline
                      ? l.syncOfflineMessage
                      : l.syncNeedsAttention,
                  status: _state.offline ? AppStatus.info : AppStatus.warning,
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
