import 'package:modular_erp/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';

abstract final class AppFeedback {
  static void showMessage(
    BuildContext context, {
    required LocalizedText message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Builder(builder: (context) => Text(message(context.l10n))),
      ),
    );
  }
}

class AppAlert extends StatelessWidget {
  const AppAlert({
    super.key,
    required this.message,
    this.status = AppStatus.info,
  });
  final String message;
  final AppStatus status;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? status.color.withValues(alpha: 0.16)
            : status.subtleColor,
        border: Border.all(
          color: isDark
              ? status.color.withValues(alpha: 0.35)
              : status.borderColor,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            switch (status) {
              AppStatus.success => Icons.check_circle_outline,
              AppStatus.warning => Icons.warning_amber_rounded,
              AppStatus.danger => Icons.error_outline,
              AppStatus.info => Icons.info_outline,
              AppStatus.neutral => Icons.info_outline,
              AppStatus.brand => Icons.info_outline,
            },
            color: status.color,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.of(context).body.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.label});
  final String? label;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                label ?? context.l10n.loadingRecords,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    required this.title,
    this.message,
    this.action,
    this.status = AppStatus.info,
    this.icon,
  });
  final String title;
  final String? message;
  final Widget? action;
  final AppStatus status;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: status.subtleColor,
        border: Border.all(color: status.borderColor),
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ??
                switch (status) {
                  AppStatus.success => Icons.check_circle_outline,
                  AppStatus.warning => Icons.warning_amber_rounded,
                  AppStatus.danger => Icons.error_outline,
                  AppStatus.info => Icons.info_outline,
                  AppStatus.neutral => Icons.info_outline,
                  AppStatus.brand => Icons.info_outline,
                },
            size: 20,
            color: status.color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.of(
                    context,
                  ).label.copyWith(fontWeight: FontWeight.w600),
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message!,
                    style: AppTypography.of(
                      context,
                    ).bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
