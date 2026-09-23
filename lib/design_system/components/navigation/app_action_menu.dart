import 'package:flutter/material.dart';
import 'package:modular_erp/l10n/l10n.dart';

class AppMenuAction {
  const AppMenuAction({required this.label, required this.onPressed});
  final LocalizedText label;
  final VoidCallback onPressed;
}

class AppActionMenu extends StatelessWidget {
  const AppActionMenu({
    super.key,
    required this.tooltip,
    required this.actions,
    this.enabled = true,
  });
  final String tooltip;
  final bool enabled;
  final List<AppMenuAction> actions;
  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
    tooltip: tooltip,
    enabled: enabled,
    onSelected: (i) => actions[i].onPressed(),
    itemBuilder: (c) => [
      for (var i = 0; i < actions.length; i++)
        PopupMenuItem(
          value: i,
          child: Builder(builder: (c) => Text(actions[i].label(c.l10n))),
        ),
    ],
  );
}
