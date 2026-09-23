import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_dimensions.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

/// Small count badge for shell actions (notifications, pending items).
/// Renders nothing at zero and caps large counts to keep layout stable.
class AppCountBadge extends StatelessWidget {
  const AppCountBadge({super.key, required this.count, this.max = 99});
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = count > max ? '$max+' : '$count';
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: AppDimensions.iconSm),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.of(
          context,
        ).caption.copyWith(color: AppColors.surface, height: 1.2),
      ),
    );
  }
}
