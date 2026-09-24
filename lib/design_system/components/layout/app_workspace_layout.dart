import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/theme/app_dimensions.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';

class AppContentMaxWidth extends StatelessWidget {
  const AppContentMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = AppDimensions.contentMaxWidth,
  });
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class AppToolbar extends StatelessWidget {
  const AppToolbar({
    super.key,
    this.search,
    this.filters = const [],
    this.actions = const [],
  });
  final Widget? search;
  final List<Widget> filters, actions;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final controls = Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [...filters, ...actions],
      );
      if (AppBreakpoints.classify(constraints.maxWidth) == AppSize.compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (search != null) ...[
              search!,
              const SizedBox(height: AppSpacing.md),
            ],
            controls,
          ],
        );
      }
      return Row(
        children: [
          if (search != null) ...[
            Expanded(child: search!),
            const SizedBox(width: AppSpacing.lg),
          ],
          Flexible(child: controls),
        ],
      );
    },
  );
}

class AppSplitView extends StatelessWidget {
  const AppSplitView({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth = 320,
  });
  final Widget master, detail;
  final double masterWidth;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = AppBreakpoints.classify(constraints.maxWidth);
      if (size == AppSize.compact || size == AppSize.medium) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            master,
            const SizedBox(height: AppSpacing.xxl),
            detail,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: masterWidth, child: master),
          const SizedBox(width: AppSpacing.xxl),
          Expanded(child: detail),
        ],
      );
    },
  );
}

/// Operational page layout: stacked compact panels, balanced medium columns,
/// and a two-thirds main column on expanded canvases.
class AppOperationalLayout extends StatelessWidget {
  const AppOperationalLayout({
    super.key,
    required this.main,
    required this.supporting,
    this.trailingMain,
  });
  final Widget main, supporting;

  /// Follows support on compact screens, stays in the main column on desktop.
  final Widget? trailingMain;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final size = AppBreakpoints.classify(c.maxWidth);
      if (size == AppSize.compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            main,
            const SizedBox(height: AppSpacing.xl),
            supporting,
            if (trailingMain != null) ...[
              const SizedBox(height: AppSpacing.xl),
              trailingMain!,
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: size == AppSize.medium ? 3 : 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                main,
                if (trailingMain != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  trailingMain!,
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(flex: size == AppSize.medium ? 2 : 1, child: supporting),
        ],
      );
    },
  );
}
