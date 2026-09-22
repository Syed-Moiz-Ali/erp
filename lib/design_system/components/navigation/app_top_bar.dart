import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../design_system.dart';
import '../../theme/app_breakpoints.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    required this.accountMenu,
    required this.onSearch,
    required this.onNotifications,
    this.notificationsButton,
    this.syncIndicator,
    this.breadcrumbs,
  });
  final String? title;
  final Widget accountMenu;
  final Widget? breadcrumbs;
  final Widget? notificationsButton;
  final Widget? syncIndicator;
  final VoidCallback onSearch, onNotifications;
  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.topBar);
  @override
  Widget build(BuildContext context) {
    final size = AppBreakpoints.of(context);
    final desktop = size == AppSize.expanded || size == AppSize.large;
    // Desktop pages render their own heading; the top bar avoids duplicating
    // it and only shows a breadcrumb/context when one is explicitly supplied.
    final Widget titleWidget;
    if (desktop) {
      titleWidget = breadcrumbs ?? const SizedBox.shrink();
    } else {
      titleWidget = Text(
        title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.of(context).cardTitle,
      );
    }
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: AppDimensions.topBar,
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
      title: titleWidget,
      actions: [
        if (syncIndicator != null) syncIndicator!,
        AppIconButton(
          icon: Icons.search,
          tooltip: context.l10n.shellSearchTitle,
          onPressed: onSearch,
        ),
        notificationsButton ??
            AppIconButton(
              icon: Icons.notifications_none_outlined,
              tooltip: context.l10n.shellNotifications,
              onPressed: onNotifications,
            ),
        if (desktop) const AppLanguageSelector(compact: true),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
          child: accountMenu,
        ),
      ],
    );
  }
}

class AppCommandPalette {
  static Future<void> show(BuildContext context) => AppDialog.show<void>(
    context,
    (context) => AppDialog(
      title: context.l10n.shellSearchTitle,
      actions: [
        AppTextButton(
          label: context.l10n.close,
          onPressed: () => Navigator.pop(context),
        ),
      ],
      child: AppEmptyState(
        title: context.l10n.shellSearchTitle,
        message: context.l10n.shellSearchMessage,
        icon: Icons.search,
      ),
    ),
  );
}

class AppNotificationPanel {
  static Future<void> show(BuildContext context) => AppDialog.show<void>(
    context,
    (context) => AppDialog(
      title: context.l10n.shellNotifications,
      actions: [
        AppTextButton(
          label: context.l10n.close,
          onPressed: () => Navigator.pop(context),
        ),
      ],
      child: AppEmptyState(
        title: context.l10n.shellNoNotifications,
        message: context.l10n.shellNotificationsMessage,
        icon: Icons.notifications_none_outlined,
      ),
    ),
  );
}
