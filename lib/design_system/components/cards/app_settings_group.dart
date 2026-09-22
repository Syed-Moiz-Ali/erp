import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../cards/app_cards.dart';
import '../headers/app_headers.dart';

/// Grouped settings surface: a section header followed by a single bordered
/// surface of rows separated by hairlines. Preferred over one card per row.
class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({
    super.key,
    required this.title,
    this.description,
    required this.children,
  });
  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSectionHeader(title: title, subtitle: description),
      const SizedBox(height: AppSpacing.sm),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderSubtle,
                ),
              children[i],
            ],
          ],
        ),
      ),
    ],
  );
}

/// A single navigable settings row: leading icon, title, optional description
/// and trailing value, with a direction-aware chevron.
class AppSettingsRow extends StatelessWidget {
  const AppSettingsRow({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.description,
    this.trailing,
    this.danger = false,
  });
  final String title;
  final String? description, trailing;
  final IconData icon;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final typography = AppTypography.of(context);
    return InkWell(
      onTap: onPressed,
      hoverColor: AppColors.surfaceHover,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: danger ? AppColors.danger : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.label.copyWith(
                      color: danger ? AppColors.danger : AppColors.textPrimary,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description!,
                      style: typography.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(trailing!, style: typography.caption),
            ],
            const SizedBox(width: AppSpacing.xs),
            Icon(
              isRtl ? Icons.chevron_left : Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
