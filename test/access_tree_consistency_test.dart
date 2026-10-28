import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/app_environment.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/bootstrap/core_dependencies.dart';
import 'package:modular_erp/bootstrap/dependencies.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/security/access_tree.dart';
import 'package:modular_erp/modules/hr/module/hr_dependencies.dart';
import 'package:modular_erp/modules/services/module/services_dependencies.dart';
import 'package:modular_erp/platform/access/access_dependencies.dart';
import 'package:modular_erp/platform/module/platform_dependencies.dart';
import 'package:modular_erp/shared/transactions/transactions_dependencies.dart';

Set<String> _registeredPaths(ModuleRegistry registry) {
  final paths = <String>{};
  void walk(RouteBase route, String parent) {
    switch (route) {
      case GoRoute():
        final path = route.path.startsWith('/')
            ? route.path
            : '$parent/${route.path}';
        paths.add(path);
        for (final child in route.routes) {
          walk(child, path);
        }
      case ShellRouteBase():
        for (final child in route.routes) {
          walk(child, parent);
        }
    }
  }

  for (final registration in registry.registrations) {
    for (final route in registration.routes) {
      walk(route, '');
    }
  }
  return paths;
}

void main() {
  setUp(AppConfig.reset);
  tearDown(AppConfig.reset);

  test('every live in-scope route is represented in the access tree', () {
    AppConfig.configure(
      const AppEnvironment(
        name: EnvironmentConfig.developmentName,
        apiBaseUrl: 'https://dev.example.test',
        authMode: AuthMode.backend,
        allowInsecureHttp: false,
      ),
    );
    final services = GetIt.asNewInstance();
    addTearDown(services.reset);
    configureCoreDependencies(services);
    services.unregister<AppDatabase>();
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    services.registerSingleton<AppDatabase>(database);
    configureTransactionDependencies(services);
    configurePlatformDependencies(services);
    configureAccessDependencies(services);
    configureHrDependencies(services);
    configureServicesDependencies(services);
    configureApplicationComposition(services);

    final registry = services<ModuleRegistry>();
    final paths = _registeredPaths(registry);

    const liveInScopeDestinations = {
      'shifts',
      'departments',
      'access-users',
      'live-employees',
      'employee-shifts',
      'live-attendance',
      'branches',
    };
    final liveIds = registry.destinations
        .map((destination) => destination.id)
        .toSet();
    expect(liveIds, containsAll(liveInScopeDestinations));
    expect(liveIds, isNot(contains('settings')));
    expect(liveIds, isNot(contains('company-modules')));

    for (final id in liveInScopeDestinations) {
      final destination = registry.destinations.firstWhere(
        (item) => item.id == id,
      );
      expect(
        accessTree.screenForPath(destination.route),
        isNotNull,
        reason: '$id is registered without an access-tree screen',
      );
    }

    for (final screen in accessTree.screens) {
      expect(
        paths.contains(screen.route),
        isTrue,
        reason: '${screen.id} route ${screen.route} is not registered',
      );
      expect(
        accessTree.screenForPath(screen.route)?.id,
        screen.id,
        reason: '${screen.route} does not resolve to ${screen.id}',
      );
    }
  });
}
