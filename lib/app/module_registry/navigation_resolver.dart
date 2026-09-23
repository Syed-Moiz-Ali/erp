import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/auth_context.dart';
import '../../features/auth/domain/policies/user_capability.dart';
import '../../core/security/app_permission.dart';
import '../router/app_routes.dart';
import 'module_registry.dart';

enum RouteAccess { allowed, moduleUnavailable, unauthorized, unknown }

class ResolvedNavigation {
  ResolvedNavigation(List<ErpModule> destinations)
    : destinations = List.unmodifiable(destinations) {
    desktop = List.unmodifiable(destinations.where((d) => d.desktopVisible));
    final mobile = destinations.where((d) => d.mobileVisible).toList();
    final prioritized = mobile.where((d) => d.mobilePriority != null).toList()
      ..sort((a, b) {
        final p = a.mobilePriority!.compareTo(b.mobilePriority!);
        return p == 0 ? a.order.compareTo(b.order) : p;
      });
    mobilePrimary = List.unmodifiable(
      prioritized.take(3),
    ); // Explicit priorities reserve one slot for More.
    mobileMore = List.unmodifiable(
      mobile.where((d) => !mobilePrimary.contains(d)),
    );
    mobileDestinations = List.unmodifiable([
      ...mobilePrimary,
      if (mobileMore.isNotEmpty)
        ErpModule(
          id: 'more',
          name: (l) => l.shellMore,
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view,
          route: AppRoutes.more,
        ),
    ]);
  }
  final List<ErpModule> destinations;
  late final List<ErpModule> desktop,
      mobilePrimary,
      mobileMore,
      mobileDestinations;
  Map<NavigationGroup, List<ErpModule>> groupsFor(Iterable<ErpModule> items) {
    final result = <NavigationGroup, List<ErpModule>>{};
    for (final item in items) {
      result.putIfAbsent(item.navigationGroup, () => []).add(item);
    }
    return Map.unmodifiable(
      result.map(
        (key, value) => MapEntry(key, List<ErpModule>.unmodifiable(value)),
      ),
    );
  }
}

class NavigationResolver {
  const NavigationResolver(this.registry);
  final ModuleRegistry registry;
  RouteAccess access(
    ErpModule item,
    CompanyContext company,
    PermissionSet permissions, [
    UserCapabilityContext? capabilities,
  ]) {
    final module = registry.module(item.moduleId);
    if (!item.enabled ||
        module?.enabled == false ||
        (module?.alwaysAvailable != true &&
            !company.enabledModules.contains(item.moduleId))) {
      return RouteAccess.moduleUnavailable;
    }
    final checker = PermissionChecker(permissions);
    if (!checker.canAll(item.requiredPermissions) ||
        (item.anyPermissions.isNotEmpty &&
            !checker.canAny(item.anyPermissions))) {
      return RouteAccess.unauthorized;
    }
    if (item.requiredCapabilities.isNotEmpty &&
        (capabilities == null ||
            !capabilities.hasAny(item.requiredCapabilities))) {
      return RouteAccess.unauthorized;
    }
    if (item.anyCapabilities.isNotEmpty &&
        (capabilities == null || !capabilities.hasAny(item.anyCapabilities))) {
      return RouteAccess.unauthorized;
    }
    return RouteAccess.allowed;
  }

  RouteAccess routeAccess(String path, AuthContext context) {
    final owner = registry.ownerOf(path);
    final capabilities = const UserCapabilityResolver().forAuthContext(context);
    final configurationManage = switch (owner?.id) {
      'shifts' => AppPermission.shiftManage,
      'work-locations' => AppPermission.workLocationManage,
      'attendance-policies' => AppPermission.attendancePolicyManage,
      'leave-types' => AppPermission.leaveTypeManage,
      'leave-policies' => AppPermission.leavePolicyManage,
      'holidays' => AppPermission.holidayManage,
      _ => null,
    };
    if (configurationManage != null &&
        (path.endsWith('/new') || path.endsWith('/edit'))) {
      final base = access(
        owner!,
        context.company,
        context.user.permissions,
        capabilities,
      );
      if (base == RouteAccess.moduleUnavailable) return base;
      return context.user.permissions.contains(configurationManage)
          ? RouteAccess.allowed
          : RouteAccess.unauthorized;
    }
    if (owner?.id == 'employees' && path != AppRoutes.employees) {
      final base = access(
        owner!,
        context.company,
        context.user.permissions,
        capabilities,
      );
      if (base == RouteAccess.moduleUnavailable) return base;
      final p = PermissionChecker(context.user.permissions),
          segments = Uri.parse(path).pathSegments;
      if (path == AppRoutes.employeeNew) {
        return p.can(AppPermission.employeeCreate)
            ? RouteAccess.allowed
            : RouteAccess.unauthorized;
      }
      final viewing = p.canAny([
        AppPermission.employeeViewAll,
        AppPermission.employeeViewTeam,
        AppPermission.employeeViewSelf,
      ]);
      if (!viewing) return RouteAccess.unauthorized;
      if (path.endsWith('/edit') && !p.can(AppPermission.employeeUpdate)) {
        return RouteAccess.unauthorized;
      }
      if (!p.canAny([
            AppPermission.employeeViewAll,
            AppPermission.employeeViewTeam,
          ]) &&
          segments.length >= 3 &&
          segments[2] != context.employeeReference?.id) {
        return RouteAccess.unauthorized;
      }
      return RouteAccess.allowed;
    }
    return owner == null
        ? RouteAccess.unknown
        : access(
            owner,
            context.company,
            context.user.permissions,
            capabilities,
          );
  }

  ResolvedNavigation resolve(
    CompanyContext company,
    PermissionSet permissions, {
    EmployeeReference? employee,
  }) {
    final capabilities = const UserCapabilityResolver().resolve(
      company: company,
      permissions: permissions,
      employee: employee,
    );
    final items =
        registry.destinations
            .where(
              (d) =>
                  access(d, company, permissions, capabilities) ==
                  RouteAccess.allowed,
            )
            .toList()
          ..sort((a, b) {
            final order = a.order.compareTo(b.order);
            return order == 0 ? a.id.compareTo(b.id) : order;
          });
    return ResolvedNavigation(items);
  }
}

class DefaultLandingResolver {
  const DefaultLandingResolver(this.navigation);
  final NavigationResolver navigation;
  String resolve(AuthContext context) =>
      navigation
          .resolve(
            context.company,
            context.user.permissions,
            employee: context.employeeReference,
          )
          .destinations
          .firstOrNull
          ?.route ??
      AppRoutes.noDestinations;
}
