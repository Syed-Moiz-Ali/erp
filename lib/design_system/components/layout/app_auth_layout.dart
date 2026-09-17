import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../design_system.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_motion.dart';

class AppProductIdentity extends StatelessWidget {
  const AppProductIdentity({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: AppSpacing.wide,
        height: AppSpacing.wide,
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: const Icon(
          Icons.layers_outlined,
          color: AppColors.surface,
          size: AppSpacing.xxl,
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Flexible(
        child: Text(
          context.l10n.appName,
          style: AppTypography.of(context).cardTitle,
        ),
      ),
    ],
  );
}

/// Public and account forms share bounded widths, responsive composition and motion.
class AppAuthLayout extends StatelessWidget {
  const AppAuthLayout({
    super.key,
    required this.child,
    this.showBrandPanel = true,
  });
  final Widget child;
  final bool showBrandPanel;
  @override
  Widget build(BuildContext context) {
    final size = AppBreakpoints.of(context);
    final expanded =
        showBrandPanel && (size == AppSize.expanded || size == AppSize.large);
    final inset = size == AppSize.compact ? AppSpacing.xxl : AppSpacing.page;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            key: const ValueKey('auth-scroll'),
            padding: EdgeInsets.all(inset),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - inset * 2).clamp(
                  0,
                  double.infinity,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: expanded
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: AppSpacing.page,
                                ),
                                child: _BrandPanel(),
                              ),
                            ),
                            Expanded(
                              child: Center(child: _FormContent(child: child)),
                            ),
                          ],
                        )
                      : _FormContent(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 460),
    child: AppMotion.entrance(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppProductIdentity(),
          const SizedBox(height: AppSpacing.wide),
          child,
          const SizedBox(height: AppSpacing.xxl),
          FocusTraversalOrder(
            order: const NumericFocusOrder(5),
            child: const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppLanguageSelector(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.wide),
    decoration: BoxDecoration(
      color: AppColors.brand.withValues(alpha: .05),
      borderRadius: BorderRadius.circular(AppRadius.panel),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.business_outlined,
          size: AppSpacing.section,
          color: AppColors.brand,
        ),
        const SizedBox(height: AppSpacing.page),
        Text(
          context.l10n.authWorkspaceLabel,
          style: AppTypography.of(
            context,
          ).label.copyWith(color: AppColors.brand),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.l10n.authBrandStatement,
          style: AppTypography.of(context).display,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          context.l10n.authBrandDescription,
          style: AppTypography.of(context).bodyLarge,
        ),
        const SizedBox(height: AppSpacing.page),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.l10n.authSessionNote,
          style: AppTypography.of(context).bodySmall,
        ),
      ],
    ),
  );
}
