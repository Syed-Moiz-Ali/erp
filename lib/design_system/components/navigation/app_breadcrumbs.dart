import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label, this.route});
  final String label;
  final String? route;
}

class AppBreadcrumbs extends StatelessWidget {
  const AppBreadcrumbs({super.key, required this.items, this.onNavigate});
  final List<AppBreadcrumbItem> items;
  final ValueChanged<String>? onNavigate;
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.shellBreadcrumbs,
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i != 0) const Icon(Icons.chevron_right, size: AppSpacing.lg),
          if (items[i].route != null && onNavigate != null)
            TextButton(
              onPressed: () => onNavigate!(items[i].route!),
              child: Text(items[i].label),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                items[i].label,
                style: AppTypography.of(context).caption,
              ),
            ),
        ],
      ],
    ),
  );
}
