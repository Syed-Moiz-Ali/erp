import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../module_registry/module_registry.dart';
import '../../module_registry/navigation_resolver.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.navigation});
  final ResolvedNavigation navigation;
  @override
  Widget build(BuildContext context) {
    final items = navigation.mobileMore.isEmpty
        ? navigation.destinations
        : navigation.mobileMore;
    return AppPage(
      maxWidth: AppDimensions.details,
      header: AppPageHeader(
        title: context.l10n.shellMore,
        subtitle: context.l10n.shellMoreDescription,
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final group in navigation.groupsFor(items).entries) ...[
              AppSectionHeader(title: group.key.label(context.l10n)),
              const SizedBox(height: AppSpacing.sm),
              for (final item in group.value)
                AppSidebarItem(
                  item: item,
                  selected: false,
                  onPressed: () => context.go(item.route),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ),
      ),
    );
  }
}
