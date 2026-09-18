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
    this.breadcrumbs,
    this.overflowActions = const [],
    this.compactActionsInline = false,
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? breadcrumbs;
  final List<AppPageOverflowAction> overflowActions;
  final bool compactActionsInline;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (breadcrumbs != null) breadcrumbs!,
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
        children: [
          ...actions,
          if (overflowActions.isNotEmpty)
            PopupMenuButton<int>(
              tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
              onSelected: (index) => overflowActions[index].onPressed(),
              itemBuilder: (context) => [
                for (var i = 0; i < overflowActions.length; i++)
                  PopupMenuItem(
                    value: i,
                    child: Text(overflowActions[i].label),
                  ),
              ],
            ),
        ],
      );
      if (AppBreakpoints.classify(constraints.maxWidth) == AppSize.compact) {
        if (compactActionsInline) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: heading),
              const SizedBox(width: AppSpacing.sm),
              controls,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading,
            if (actions.isNotEmpty || overflowActions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              controls,
            ],
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: heading),
          if (actions.isNotEmpty || overflowActions.isNotEmpty) ...[
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
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTypography.of(context).sectionTitle),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(subtitle!, style: AppTypography.of(context).caption),
        ],
      ],
    );

    if (action == null) return textColumn;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: textColumn),
        action!,
      ],
    );
  }
}

class AppPageOverflowAction {
  const AppPageOverflowAction({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
}
