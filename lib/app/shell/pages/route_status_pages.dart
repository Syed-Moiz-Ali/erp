import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';

class RouteStatusPage extends StatelessWidget {
  const RouteStatusPage({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.landing,
  });
  final LocalizedText title, message;
  final IconData icon;
  final String landing;
  @override
  Widget build(BuildContext context) => AppPage(
    child: AppCard(
      child: Column(
        children: [
          AppEmptyState(
            title: title(context.l10n),
            message: message(context.l10n),
            icon: icon,
            actionLabel: context.l10n.shellReturnToWorkspace,
            onAction: () => context.go(landing),
          ),
          if (context.canPop())
            AppTextButton(
              label: context.l10n.shellGoBack,
              onPressed: () => context.pop(),
            ),
        ],
      ),
    ),
  );
}

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key, required this.landing});
  final String landing;
  @override
  Widget build(BuildContext context) => RouteStatusPage(
    title: (l) => l.shellAccessRestricted,
    message: (l) => l.shellAccessMessage,
    icon: Icons.lock_outline,
    landing: landing,
  );
}

class ModuleUnavailablePage extends StatelessWidget {
  const ModuleUnavailablePage({super.key, required this.landing});
  final String landing;
  @override
  Widget build(BuildContext context) => RouteStatusPage(
    title: (l) => l.shellModuleUnavailable,
    message: (l) => l.shellModuleUnavailableMessage,
    icon: Icons.extension_outlined,
    landing: landing,
  );
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, required this.landing});
  final String landing;
  @override
  Widget build(BuildContext context) => RouteStatusPage(
    title: (l) => l.shellNotFound,
    message: (l) => l.shellNotFoundMessage,
    icon: Icons.find_in_page_outlined,
    landing: landing,
  );
}

class NoDestinationsPage extends StatelessWidget {
  const NoDestinationsPage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    child: AppCard(
      child: AppEmptyState(
        title: context.l10n.shellNoDestinations,
        message: context.l10n.shellNoDestinationsMessage,
        icon: Icons.lock_outline,
      ),
    ),
  );
}
