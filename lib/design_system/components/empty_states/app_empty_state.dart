import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';
import 'package:modular_erp/design_system/components/buttons/app_buttons.dart';
import 'package:modular_erp/l10n/l10n.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });
  final String title, message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typography = AppTypography.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceMuted
                  : AppColors.surfaceSubtle,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorderSubtle
                    : AppColors.borderSubtle,
              ),
            ),
            child: Icon(
              icon,
              size: 26,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: typography.cardTitle, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              message,
              style: typography.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppSecondaryButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: context.l10n.unableToLoadRecords,
    message: message,
    icon: Icons.error_outline,
    actionLabel: onRetry == null ? null : context.l10n.retry,
    onAction: onRetry,
  );
}

/// Full-page permission-denied state (access restricted to this area).
class AppPermissionDeniedState extends StatelessWidget {
  const AppPermissionDeniedState({super.key, this.onGoBack});

  final VoidCallback? onGoBack;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: context.l10n.shellAccessRestricted,
    message: context.l10n.shellAccessMessage,
    icon: Icons.lock_outline,
    actionLabel: onGoBack == null ? null : context.l10n.shellGoBack,
    onAction: onGoBack,
  );
}

/// Full-page not-found state.
class AppNotFoundState extends StatelessWidget {
  const AppNotFoundState({super.key, this.onGoBack});

  final VoidCallback? onGoBack;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: context.l10n.shellNotFound,
    message: context.l10n.shellNotFoundMessage,
    icon: Icons.search_off_outlined,
    actionLabel: onGoBack == null ? null : context.l10n.shellReturnToWorkspace,
    onAction: onGoBack,
  );
}

/// Compact inline section error: a quiet bordered row with an optional retry
/// action, used inside cards/sections without taking over the page.
class AppInlineError extends StatelessWidget {
  const AppInlineError({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final danger = isDark ? AppColors.darkDanger : AppColors.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.dangerSubtle,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        border: Border.all(color: danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.of(context).bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            AppTextButton(
              label: retryLabel ?? context.l10n.retry,
              size: AppButtonSize.small,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
