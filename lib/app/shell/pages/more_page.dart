import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

/// Compact/mobile secondary navigation: the destinations that did not fit the
/// bottom bar, presented with company context and module grouping through the
/// shared [AppMobileNavigation] component. Never a squeezed desktop sidebar.
class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.navigation});
  final ResolvedNavigation navigation;
  @override
  Widget build(BuildContext context) {
    final items = navigation.mobileMore.isEmpty
        ? navigation.destinations
        : navigation.mobileMore;
    final company = context.watch<AuthBloc>().state.context?.company.name;
    return AppPage(
      header: AppPageHeader(
        title: context.l10n.shellMore,
        subtitle: context.l10n.shellMoreDescription,
      ),
      child: AppMobileNavigation(
        modules: items,
        selectedRoute: GoRouterState.of(context).uri.path,
        companyName: company,
        onNavigate: (route) => context.go(route),
      ),
    );
  }
}
