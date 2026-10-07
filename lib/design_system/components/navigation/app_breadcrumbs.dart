import 'package:flutter/material.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/design_system/theme/app_typography.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';
import 'package:modular_erp/design_system/theme/app_radius.dart';
import 'package:modular_erp/design_system/theme/app_dimensions.dart';

class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label, this.route});
  final String label;
  final String? route;
}

/// Compact context trail. Ancestors are clickable where a route is provided,
/// the current item is stronger, and the separator mirrors under RTL.
class AppBreadcrumbs extends StatelessWidget {
  const AppBreadcrumbs({super.key, required this.items, this.onNavigate});
  final List<AppBreadcrumbItem> items;
  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final separator = rtl ? Icons.chevron_left : Icons.chevron_right;
    final separatorColor = Theme.of(context).colorScheme.onSurfaceVariant;
    const itemPadding = EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.xs,
      vertical: AppSpacing.xxs,
    );
    return Semantics(
      label: context.l10n.shellBreadcrumbs,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xxs,
        runSpacing: AppSpacing.xxs,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i != 0)
              Icon(
                separator,
                size: AppDimensions.iconSm,
                color: separatorColor,
              ),
            if (items[i].route != null && onNavigate != null)
              InkWell(
                onTap: () => onNavigate!(items[i].route!),
                borderRadius: BorderRadius.circular(AppRadius.radiusXs),
                child: Padding(
                  padding: itemPadding,
                  child: Text(items[i].label, style: typography.caption),
                ),
              )
            else
              Padding(
                padding: itemPadding,
                child: Text(
                  items[i].label,
                  style: i == items.length - 1
                      ? typography.labelMedium
                      : typography.caption,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
