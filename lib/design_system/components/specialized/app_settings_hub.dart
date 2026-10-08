import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/components/cards/app_settings_group.dart';
import 'package:modular_erp/design_system/components/empty_states/app_empty_state.dart';
import 'package:modular_erp/design_system/theme/app_spacing.dart';

/// UI-7 compact settings navigation.
///
/// A settings landing page helps users locate configuration quickly: compact
/// groups of navigable rows with an icon, a short description and an optional
/// meaningful count — never giant marketing cards, a raw route dump or a KPI
/// dashboard. Callers include only the items the current user may view
/// (page discovery follows View; mutation stays Manage-gated).

/// One navigable settings item. [count] must be a meaningful number (for
/// example "configured record count") or omitted entirely.
class AppSettingsItem {
  const AppSettingsItem({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.description,
    this.count,
    this.danger = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final String? description;
  final String? count;
  final bool danger;
}

/// A settings group (for example "Attendance" → Shifts / Work locations /
/// Attendance policies). Groups with no items are not rendered by
/// [AppSettingsHub], which keeps the hub honest when permissions hide items.
class AppSettingsGroup {
  const AppSettingsGroup({
    required this.title,
    required this.items,
    this.description,
  });

  final String title;
  final String? description;
  final List<AppSettingsItem> items;
}

/// Grouped, compact settings navigation.
class AppSettingsHub extends StatelessWidget {
  const AppSettingsHub({
    super.key,
    required this.groups,
    this.intro,
    this.emptyMessage,
  });

  final List<AppSettingsGroup> groups;
  final Widget? intro;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final group in groups)
        if (group.items.isNotEmpty) group,
    ];
    if (visible.isEmpty) {
      final emptyTitle = '';
      final emptyBody = emptyMessage ?? '';
      return AppEmptyState(
        title: emptyTitle,
        message: emptyBody,
        icon: Icons.tune_outlined,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (intro != null) ...[intro!, const SizedBox(height: AppSpacing.xxl)],
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xxl),
          AppSettingsSection(
            title: visible[i].title,
            description: visible[i].description,
            children: [
              for (final item in visible[i].items)
                AppSettingsRow(
                  title: item.title,
                  description: item.description,
                  icon: item.icon,
                  trailing: item.count,
                  danger: item.danger,
                  onPressed: item.onPressed,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
