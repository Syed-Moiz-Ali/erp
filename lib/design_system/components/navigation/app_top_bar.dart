import 'package:flutter/material.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';

/// Lightweight desktop/tablet top bar.
///
/// Responsibilities are deliberately limited: optional context/breadcrumb,
/// notifications and the account control. A search affordance is rendered
/// **only** when a genuine global search is supplied via [onSearch]; the ERP
/// does not ship a decorative/fake search box (see UI-2 §28).
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    required this.accountMenu,
    this.onSearch,
    this.onNotifications,
    this.notificationsButton,
    this.syncIndicator,
    this.breadcrumbs,
  });
  final String? title;
  final Widget accountMenu;
  final Widget? breadcrumbs;
  final Widget? notificationsButton;
  final Widget? syncIndicator;
  final VoidCallback? onSearch, onNotifications;
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
      shape: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      titleSpacing: desktop ? AppSpacing.xxl : null,
      title: titleWidget,
      actions: [
        if (syncIndicator != null) syncIndicator!,
        if (onSearch != null)
          AppIconButton(
            icon: Icons.search,
            tooltip: context.l10n.shellSearchTitle,
            onPressed: onSearch!,
          ),
        notificationsButton ??
            AppNotificationButton(onPressed: onNotifications),
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
