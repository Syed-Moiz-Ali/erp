import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../design_system.dart';
import '../../theme/app_breakpoints.dart';

class AppProductIdentity extends StatelessWidget {
  const AppProductIdentity({super.key, this.isDark = false});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF6B234C) : AppColors.brandPrimary,
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          boxShadow: const [
            BoxShadow(
              color: Color(0x184E1736),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Icon(Icons.layers_rounded, color: Colors.white, size: 18),
      ),
      const SizedBox(width: AppSpacing.sm),
      Flexible(
        child: Text(
          context.l10n.appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.of(context).cardTitle.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}

/// Reference-driven premium light ERP authentication layout.
/// Encapsulates top product bar and central workspace container.
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
    final isCompact = size == AppSize.compact;
    final isTablet = size == AppSize.medium;
    final horizontalPadding = isCompact ? AppSpacing.lg : AppSpacing.page;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            key: const ValueKey('auth-scroll'),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar (Product Identity & Language Selector)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppProductIdentity(),
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(5),
                          child: const AppLanguageSelector(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Centered Auth Workspace
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: expanded ? 960 : 480,
                        ),
                        child: expanded
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.panel,
                                  ),
                                  border: Border.all(
                                    color: AppColors.borderDefault,
                                  ),
                                  boxShadow: AppElevation.workspace,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Left: Form Area (380-420px usable)
                                      Expanded(
                                        flex: 50,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.xxl,
                                          ),
                                          child: Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 400,
                                              ),
                                              child: AppMotion.entrance(
                                                context,
                                                child,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Subtle Divider Line
                                      Container(
                                        width: 1,
                                        color: AppColors.borderSubtle,
                                      ),
                                      // Right: Refined ERP Product Preview
                                      const Expanded(
                                        flex: 50,
                                        child: _BrandExperience(),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : isTablet
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.panel,
                                  ),
                                  border: Border.all(
                                    color: AppColors.borderDefault,
                                  ),
                                  boxShadow: AppElevation.workspace,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (showBrandPanel)
                                      const _TabletBrandHeader(),
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.xxl,
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 400,
                                        ),
                                        child: AppMotion.entrance(
                                          context,
                                          child,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _FormContent(
                                showMobileStrip: showBrandPanel && isCompact,
                                isCard: true,
                                child: child,
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SizedBox(height: AppSpacing.xs),
                  ],
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
  const _FormContent({
    required this.child,
    this.showMobileStrip = false,
    this.isCard = true,
  });
  final Widget child;
  final bool showMobileStrip;
  final bool isCard;

  @override
  Widget build(BuildContext context) {
    Widget content = AppMotion.entrance(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [child, if (showMobileStrip) const _MobileBrandStrip()],
      ),
    );

    if (isCard) {
      content = Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.panel),
          border: Border.all(color: AppColors.borderDefault),
          boxShadow: AppElevation.workspace,
        ),
        child: content,
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: content,
    );
  }
}

class _MobileBrandStrip extends StatelessWidget {
  const _MobileBrandStrip();

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(AppRadius.radiusSm),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              size: 13,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.attendance,
              style: theme.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.successSubtle,
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.authStatusActive,
                  style: theme.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletBrandHeader extends StatelessWidget {
  const _TabletBrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSubtle,
        border: BorderDirectional(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.authWorkspaceLabel,
            style: theme.caption.copyWith(
              color: AppColors.brandPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.successSubtle,
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.authStatusActive,
                  style: theme.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandExperience extends StatelessWidget {
  const _BrandExperience();

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Container(
      decoration: const BoxDecoration(color: AppColors.surfaceSubtle),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              border: Border.all(color: const Color(0xFFE8DEE6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.brandPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.authWorkspaceLabel,
                  style: theme.caption.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.authBrandStatement,
            style: theme.pageTitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.25,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.authBrandDescription,
            style: theme.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _AttendanceSignalFragment(),
          const SizedBox(height: AppSpacing.sm),
          const _WorkforceRosterFragment(),
          const SizedBox(height: AppSpacing.sm),
          const _OperationsPipelineFragment(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.l10n.authSessionNote,
                  style: theme.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceSignalFragment extends StatelessWidget {
  const _AttendanceSignalFragment();

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: AppElevation.subtle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.brandSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.radiusSm),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.attendance,
                  style: theme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.authStatusActive,
                      style: theme.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            child: Container(
              height: 4,
              color: AppColors.borderSubtle,
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: Container(color: AppColors.brandPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkforceRosterFragment extends StatelessWidget {
  const _WorkforceRosterFragment();

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: AppElevation.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(AppRadius.radiusSm),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              size: 15,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.employees,
              style: theme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 58,
            height: 24,
            child: Stack(
              children: const [
                PositionedDirectional(
                  start: 0,
                  child: _AvatarCircle(
                    color: AppColors.brandPrimary,
                    icon: Icons.person_rounded,
                  ),
                ),
                PositionedDirectional(
                  start: 16,
                  child: _AvatarCircle(
                    color: Color(0xFF0D7A53),
                    icon: Icons.person_rounded,
                  ),
                ),
                PositionedDirectional(
                  start: 32,
                  child: _AvatarCircle(
                    color: Color(0xFF975B00),
                    icon: Icons.person_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1.5),
    ),
    child: Icon(icon, size: 13, color: Colors.white),
  );
}

class _OperationsPipelineFragment extends StatelessWidget {
  const _OperationsPipelineFragment();

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: AppElevation.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.brandSubtle,
              borderRadius: BorderRadius.circular(AppRadius.radiusSm),
            ),
            child: const Icon(
              Icons.insights_rounded,
              size: 15,
              color: AppColors.accentLavender,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.reports,
              style: theme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _MicroBar(height: 10, color: Color(0xFFD4B2D8)),
              SizedBox(width: 3),
              _MicroBar(height: 18, color: AppColors.brandPrimary),
              SizedBox(width: 3),
              _MicroBar(height: 14, color: AppColors.accentLavender),
              SizedBox(width: 3),
              _MicroBar(height: 22, color: AppColors.brandPrimary),
            ],
          ),
        ],
      ),
    );
  }
}

class _MicroBar extends StatelessWidget {
  const _MicroBar({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 4,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
