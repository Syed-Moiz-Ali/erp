import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../status/app_status_badge.dart';

class AppMobileRecordCard extends StatelessWidget {
  const AppMobileRecordCard({
    super.key,
    required this.title,
    this.subtitle,
    this.tertiary,
    this.leading,
    this.status,
    this.statusLabel,
    this.metrics = const [],
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? tertiary;
  final Widget? leading;
  final AppStatus? status;
  final String? statusLabel;
  final List<({String label, String value})> metrics;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: const BorderSide(color: AppColors.borderDefault),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      hoverColor: AppColors.surfaceHover,
      splashColor: AppColors.brandPrimary.withValues(alpha: .06),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.of(context).label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: AppTypography.of(context).caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (tertiary != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          tertiary!,
                          style: AppTypography.of(
                            context,
                          ).bodySmall.copyWith(color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (status != null && statusLabel != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AppStatusBadge(label: statusLabel!, status: status!),
                ],
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  trailing!,
                ],
              ],
            ),
            if (metrics.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final m in metrics)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          m.label,
                          style: AppTypography.of(
                            context,
                          ).caption.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          m.value,
                          style: AppTypography.of(context).caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
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
