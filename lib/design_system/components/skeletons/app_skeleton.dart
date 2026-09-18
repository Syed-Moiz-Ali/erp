import '../../design_system.dart';
import '../../../l10n/l10n.dart';
import 'package:flutter/material.dart';

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

class AppConfigurationSkeleton extends StatelessWidget {
  const AppConfigurationSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 3; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(width: 160, height: 24),
                const SizedBox(height: AppSpacing.lg),
                const AppSkeleton(),
                const SizedBox(height: AppSpacing.md),
                const AppSkeleton(width: 220),
              ],
            ),
          ),
        ),
    ],
  );
}
