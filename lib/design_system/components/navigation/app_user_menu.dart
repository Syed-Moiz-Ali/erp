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

  PopupMenuItem<AppUserMenuAction> _item(
    BuildContext context, {
    required AppUserMenuAction value,
    required IconData icon,
    required LocalizedText label,
    WidgetBuilder? trailing,
  }) => PopupMenuItem<AppUserMenuAction>(
    value: value,
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Builder(
      builder: (context) {
        final theme = AppTypography.of(context);
        return Row(
          children: [
            Icon(icon, size: 17, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label(context.l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) trailing(context),
          ],
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppUserMenuAction>(
      enabled: !busy,
      tooltip: context.l10n.shellAccountMenu,
      position: PopupMenuPosition.under,
      offset: const Offset(0, AppSpacing.xs),
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusLg),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
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
        PopupMenuItem<AppUserMenuAction>(
          enabled: false,
          height: 0,
          padding: EdgeInsets.zero,
          child: Builder(
            builder: (context) {
              final theme = AppTypography.of(context);
              return Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    AppAvatar(name: name, radius: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.caption.copyWith(fontSize: 11.5),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            roleLabel(context.l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const PopupMenuDivider(),
        _item(
          context,
          value: AppUserMenuAction.profile,
          icon: Icons.person_outline,
          label: (l) => l.shellProfile,
        ),
        _item(
          context,
          value: AppUserMenuAction.password,
          icon: Icons.lock_outline,
          label: (l) => l.authChangePassword,
        ),
        _item(
          context,
          value: AppUserMenuAction.language,
          icon: Icons.language_outlined,
          label: (l) => l.language,
          trailing: (context) => Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? context.l10n.arabicNativeName
                : context.l10n.englishNativeName,
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textMuted),
          ),
        ),
        const PopupMenuDivider(),
        _item(
          context,
          value: AppUserMenuAction.logout,
          icon: Icons.logout,
          label: (l) => l.logout,
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
}
