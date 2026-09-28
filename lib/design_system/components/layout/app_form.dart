import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/components/buttons/app_buttons.dart';
import 'package:modular_erp/design_system/components/cards/app_cards.dart';
import 'package:modular_erp/design_system/components/feedback/app_feedback.dart';
import 'package:modular_erp/design_system/components/headers/app_headers.dart';
import 'package:modular_erp/design_system/components/layout/app_page.dart';
import 'package:modular_erp/design_system/components/skeletons/app_skeleton.dart';
import 'package:modular_erp/design_system/components/status/app_status_badge.dart';
import 'package:modular_erp/design_system/theme/app_colors.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';

/// Standard Create/Edit form shell.
///
/// Every Services form (masters, directories, transactions) composes the same
/// one-page shell: a mode-aware [AppPageHeader] (title + optional subtitle +
/// top-right secondary Cancel and primary Save/Create actions), an optional
/// danger [AppAlert] for storage failures, and a loading skeleton while an
/// existing record is fetched. The outer bounds are always the one global
/// [AppPage] content width — forms never choose their own width.
class AppFormPage extends StatelessWidget {
  const AppFormPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.error,
    this.loading = false,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;

  /// Optional localized storage failure shown above the form.
  final String? error;

  /// When true the body is replaced by a skeleton (loading an existing record).
  final bool loading;

  @override
  Widget build(BuildContext context) => AppPage(
    header: AppPageHeader(title: title, subtitle: subtitle, actions: actions),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null && error!.isNotEmpty) ...[
          AppAlert(message: error!, status: AppStatus.danger),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (loading) const AppFormSkeleton() else child,
      ],
    ),
  );
}

/// Neutral loading placeholder for a form with several sections.
class AppFormSkeleton extends StatelessWidget {
  const AppFormSkeleton({super.key, this.sections = 3});
  final int sections;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < sections; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(width: 160, height: 20),
                const SizedBox(height: AppSpacing.xl),
                const AppSkeleton(height: 44),
                const SizedBox(height: AppSpacing.lg),
                const AppSkeleton(height: 44),
              ],
            ),
          ),
        ),
    ],
  );
}

/// A boolean settings row: label + optional description + aligned toggle.
///
/// The whole row is an accessible tap target (the switch label is tappable),
/// mirrors correctly under RTL, and supports disabled and loading states.
class AppBooleanSettingRow extends StatelessWidget {
  const AppBooleanSettingRow({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.description,
    this.enabled = true,
    this.loading = false,
  });
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled, loading;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final interactive = enabled && !loading && onChanged != null;
    final semanticLabel = [
      label,
      if (description != null) description!,
    ].join('. ');
    return Semantics(
      toggled: value,
      enabled: interactive,
      label: semanticLabel,
      child: InkWell(
        onTap: interactive ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: typography.label.copyWith(
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        description!,
                        style: typography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              if (loading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                ExcludeSemantics(
                  child: Switch.adaptive(
                    value: value,
                    onChanged: interactive ? onChanged : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Repeatable section header + items. Renders a section title with a compact
/// "+ Add ..." action in the header, then the item cards. Centralizes the
/// Add/empty UX so every repeatable editor (enquiry issues, work items,
/// inspection checklist, MR lines, work execution lines/photos) matches.
class AppRepeatableSection extends StatelessWidget {
  const AppRepeatableSection({
    super.key,
    required this.title,
    required this.addLabel,
    required this.onAdd,
    required this.children,
    this.subtitle,
    this.emptyText,
    this.addIcon = Icons.add,
    this.card = true,
  });
  final String title;
  final String? subtitle;
  final String addLabel;
  final VoidCallback? onAdd;
  final IconData addIcon;
  final List<Widget> children;
  final String? emptyText;
  final bool card;

  @override
  Widget build(BuildContext context) => AppFormSection(
    title: title,
    subtitle: subtitle,
    card: card,
    action: AppSecondaryButton(
      label: addLabel,
      icon: addIcon,
      size: AppButtonSize.small,
      onPressed: onAdd,
    ),
    child: children.isEmpty
        ? Text(
            emptyText ?? '',
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textSecondary),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                children[i],
              ],
            ],
          ),
  );
}

/// A single repeatable item card: number/title, optional status chip, a subtle
/// remove icon with tooltip, then the item's fields/attachments.
class AppRepeatableItemCard extends StatelessWidget {
  const AppRepeatableItemCard({
    super.key,
    required this.title,
    required this.children,
    this.statusLabel,
    this.status = AppStatus.neutral,
    this.onRemove,
    this.removeTooltip,
    this.trailing,
  });
  final String title;
  final AppStatus status;
  final String? statusLabel, removeTooltip;
  final VoidCallback? onRemove;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.of(
                  context,
                ).label.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (statusLabel != null)
              AppStatusBadge(label: statusLabel!, status: status, isPill: true),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
            if (onRemove != null) ...[
              const SizedBox(width: AppSpacing.xs),
              AppIconButton(
                icon: Icons.delete_outline,
                tooltip:
                    removeTooltip ??
                    MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: onRemove,
              ),
            ],
          ],
        ),
        for (final child in children) ...[
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ],
    ),
  );
}
