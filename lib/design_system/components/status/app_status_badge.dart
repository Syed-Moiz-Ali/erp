import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

enum AppStatus { success, warning, danger, info, neutral, brand }

extension AppStatusColor on AppStatus {
  Color get color => switch (this) {
    AppStatus.success => AppColors.success,
    AppStatus.warning => AppColors.warning,
    AppStatus.danger => AppColors.danger,
    AppStatus.info => AppColors.info,
    AppStatus.neutral => AppColors.neutral,
    AppStatus.brand => AppColors.brandPrimary,
  };

  Color get subtleColor => switch (this) {
    AppStatus.success => AppColors.successSubtle,
    AppStatus.warning => AppColors.warningSubtle,
    AppStatus.danger => AppColors.dangerSubtle,
    AppStatus.info => AppColors.infoSubtle,
    AppStatus.neutral => AppColors.neutralSubtle,
    AppStatus.brand => AppColors.brandSubtle,
  };

  Color get borderColor => switch (this) {
    AppStatus.success => AppColors.success.withValues(alpha: .28),
    AppStatus.warning => AppColors.warning.withValues(alpha: .30),
    AppStatus.danger => AppColors.danger.withValues(alpha: .28),
    AppStatus.info => AppColors.info.withValues(alpha: .28),
    AppStatus.neutral => AppColors.borderDefault,
    AppStatus.brand => AppColors.brandBorder.withValues(alpha: .35),
  };
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.status = AppStatus.neutral,
    this.showDot = false,
    this.icon,
    this.isPill = false,
  });

  final String label;
  final AppStatus status;
  final bool showDot;
  final IconData? icon;
  final bool isPill;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: status.subtleColor,
      border: Border.all(color: status.borderColor, width: 1),
      borderRadius: BorderRadius.circular(
        isPill ? AppRadius.radiusFull : AppRadius.badge,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showDot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
        ] else if (icon != null) ...[
          Icon(icon, size: 12, color: status.color),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.of(context).caption.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ],
    ),
  );
}
