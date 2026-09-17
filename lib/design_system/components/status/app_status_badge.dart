import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

enum AppStatus { success, warning, danger, info, neutral }

extension AppStatusColor on AppStatus {
  Color get color => switch (this) {
    AppStatus.success => AppColors.success,
    AppStatus.warning => AppColors.warning,
    AppStatus.danger => AppColors.danger,
    AppStatus.info => AppColors.info,
    AppStatus.neutral => AppColors.textSecondary,
  };
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.status = AppStatus.neutral,
  });
  final String label;
  final AppStatus status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: status.color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(AppRadius.small),
    ),
    child: Text(
      label,
      style: AppTypography.of(
        context,
      ).caption.copyWith(color: status.color, fontWeight: FontWeight.w600),
    ),
  );
}
