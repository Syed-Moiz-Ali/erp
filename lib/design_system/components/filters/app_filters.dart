import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(
      label,
      style: AppTypography.of(context).caption.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? AppColors.brandPrimary : AppColors.textPrimary,
      ),
    ),
    selected: selected,
    onSelected: onSelected,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      side: BorderSide(
        color: selected ? AppColors.brandPrimary : AppColors.borderDefault,
      ),
    ),
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.brandSubtle,
    showCheckmark: false,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs,
    ),
  );
}

class AppFilterBar extends StatelessWidget {
  const AppFilterBar({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
}
