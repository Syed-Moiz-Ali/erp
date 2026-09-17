import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../design_system.dart';

enum AppUserMenuAction { profile, password, language, logout }

class AppUserMenu extends StatelessWidget {
  const AppUserMenu({
    super.key,
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.onProfile,
    required this.onPassword,
    required this.onLanguage,
    required this.onLogout,
    this.busy = false,
  });
  final String name, email;
  final LocalizedText roleLabel;
  final VoidCallback onProfile, onPassword, onLanguage, onLogout;
  final bool busy;
  @override
  Widget build(BuildContext context) => PopupMenuButton<AppUserMenuAction>(
    enabled: !busy,
    tooltip: context.l10n.shellAccountMenu,
    onSelected: (action) {
      switch (action) {
        case AppUserMenuAction.profile:
          onProfile();
        case AppUserMenuAction.password:
          onPassword();
        case AppUserMenuAction.language:
          onLanguage();
        case AppUserMenuAction.logout:
          onLogout();
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        enabled: false,
        child: Builder(
          builder: (context) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.of(context).label),
                Text(email, style: AppTypography.of(context).caption),
                Text(
                  roleLabel(context.l10n),
                  style: AppTypography.of(context).caption,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: AppUserMenuAction.profile,
        child: Builder(builder: (context) => Text(context.l10n.shellProfile)),
      ),
      PopupMenuItem(
        value: AppUserMenuAction.password,
        child: Builder(
          builder: (context) => Text(context.l10n.authChangePassword),
        ),
      ),
      PopupMenuItem(
        value: AppUserMenuAction.language,
        child: Builder(builder: (context) => Text(context.l10n.language)),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: AppUserMenuAction.logout,
        child: Builder(builder: (context) => Text(context.l10n.logout)),
      ),
    ],
    child: Semantics(
      button: true,
      label: context.l10n.shellAccountMenu,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: AppAvatar(name: name),
      ),
    ),
  );
}
