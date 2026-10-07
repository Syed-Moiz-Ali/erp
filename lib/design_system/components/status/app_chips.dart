import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

/// Selection chip (multi/single select). Distinct from filter chips (which live
/// in a filter bar) and status chips (which map a semantic status).
class AppSelectionChip extends StatelessWidget {
  const AppSelectionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkBrand : AppColors.brandPrimary;
    final subtle = isDark
        ? AppColors.darkSurfaceSelected
        : AppColors.brandPrimarySubtle;
    return FilterChip(
      label: Text(
        label,
        style: typography.labelSmall.copyWith(
          color: selected
              ? accent
              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        ),
      ),
      selected: selected,
      onSelected: enabled ? onSelected : null,
      showCheckmark: true,
      checkmarkColor: accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        side: BorderSide(
          color: selected
              ? accent
              : (isDark ? AppColors.darkBorder : AppColors.borderDefault),
        ),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      selectedColor: subtle,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    );
  }
}

/// Non-interactive metadata chip for secondary facts (IDs, counts, tags).
class AppMetadataChip extends StatelessWidget {
  const AppMetadataChip({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: typography.metadata.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
