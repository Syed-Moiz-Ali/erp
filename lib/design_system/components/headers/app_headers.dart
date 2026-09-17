import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_spacing.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.of(context).pageTitle),
          if (subtitle != null)
            Text(subtitle!, style: AppTypography.of(context).caption),
        ],
      );
      final controls = Wrap(
        alignment: WrapAlignment.end,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: actions,
      );
      if (AppBreakpoints.classify(constraints.maxWidth) == AppSize.compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              controls,
            ],
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: heading),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xxl),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: controls,
              ),
            ),
          ],
        ],
      );
    },
  );
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTypography.of(context).sectionTitle),
      if (subtitle != null)
        Text(subtitle!, style: AppTypography.of(context).caption),
    ],
  );
}
