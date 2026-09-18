import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../status/app_status_badge.dart';

enum AppCardVariant { surface, interactive, subtle, bordered }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
    this.variant = AppCardVariant.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppCardVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (variant) {
      AppCardVariant.surface => (AppColors.surface, AppColors.borderDefault),
      AppCardVariant.interactive => (
        AppColors.surface,
        AppColors.borderDefault,
      ),
      AppCardVariant.subtle => (
        AppColors.surfaceSubtle,
        AppColors.borderSubtle,
      ),
      AppCardVariant.bordered => (AppColors.surface, AppColors.borderStrong),
    };

    final content = SizedBox(
      width: double.infinity,
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null || variant == AppCardVariant.interactive) {
      return Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.surfaceHover,
          splashColor: AppColors.brandPrimary.withValues(alpha: .08),
          child: content,
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: border),
      ),
      child: content,
    );
  }
}

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.detail = '',
    this.icon = Icons.insights_outlined,
    this.status = AppStatus.neutral,
    this.trend,
    this.trendPositive = true,
    this.onTap,
  });

  final String label, value, detail;
  final IconData icon;
  final AppStatus status;
  final String? trend;
  final bool trendPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semanticParts = [
      label,
      value,
      if (detail.isNotEmpty) detail,
      if (trend != null) trend!,
    ];
    final semanticSummary = semanticParts.join(', ');
    return Semantics(
      label: semanticSummary,
      child: ExcludeSemantics(
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          onTap: onTap,
          variant: onTap != null
              ? AppCardVariant.interactive
              : AppCardVariant.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.of(context).caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    icon,
                    size: 18,
                    color: status == AppStatus.neutral
                        ? AppColors.textMuted
                        : status.color,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                value,
                style: AppTypography.of(
                  context,
                ).pageTitle.copyWith(fontWeight: FontWeight.w700, height: 1.2),
              ),
              if (detail.isNotEmpty || trend != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (trend != null) ...[
                      Icon(
                        trendPositive ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: trendPositive
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        trend!,
                        style: AppTypography.of(context).caption.copyWith(
                          color: trendPositive
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (detail.isNotEmpty)
                        const SizedBox(width: AppSpacing.sm),
                    ],
                    if (detail.isNotEmpty)
                      Expanded(
                        child: Text(
                          detail,
                          style: AppTypography.of(
                            context,
                          ).caption.copyWith(color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.action,
  });

  final String title, message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x1F38BDF8) : AppColors.infoSubtle,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark
              ? const Color(0x4038BDF8)
              : AppColors.info.withValues(alpha: .2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isDark ? const Color(0xFF38BDF8) : AppColors.info,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.of(context).cardTitle.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: AppTypography.of(context).bodySmall.copyWith(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
