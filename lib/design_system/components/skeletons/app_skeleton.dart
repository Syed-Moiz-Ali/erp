import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({super.key, this.width, this.height = 16});
  final double? width;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.loading,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    ),
  );
}
