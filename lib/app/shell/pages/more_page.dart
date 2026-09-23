import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.navigation});
  final ResolvedNavigation navigation;
  @override
  Widget build(BuildContext context) {
    final items = navigation.mobileMore.isEmpty
        ? navigation.destinations
        : navigation.mobileMore;
    final groups = navigation.groupsFor(items);
    return AppPage(
      maxWidth: AppDimensions.details,
      header: AppPageHeader(
        title: context.l10n.shellMore,
        subtitle: context.l10n.shellMoreDescription,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final group in groups.entries) ...[
            AppSectionHeader(title: group.key.label(context.l10n)),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < group.value.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: AppSpacing.md,
                          end: AppSpacing.md,
                        ),
                        child: Divider(height: 1),
                      ),
                    AppSidebarItem(
                      item: group.value[i],
                      selected: false,
                      onPressed: () => context.go(group.value[i].route),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }
}
