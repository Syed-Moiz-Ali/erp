import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:modular_erp/bootstrap/core_dependencies.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/storage/secure_session_storage.dart';

void main() {
  test('core dependencies register a single shared refresh coordinator', () {
    final services = GetIt.asNewInstance();
    addTearDown(services.reset);
    configureCoreDependencies(services);
    expect(services.isRegistered<SessionStorage>(), isTrue);
    expect(services.isRegistered<TokenRefreshCoordinator>(), isTrue);
    expect(
      identical(
        services<TokenRefreshCoordinator>(),
        services<TokenRefreshCoordinator>(),
      ),
      isTrue,
    );
  });

  test('the shared API client registers once as a lazy singleton', () {
    final services = GetIt.asNewInstance();
    addTearDown(services.reset);
    configureCoreDependencies(services);
    registerSharedApiClient(services, baseUrl: 'https://api.example.com');
    expect(services.isRegistered<ApiClient>(), isTrue);
    expect(identical(services<ApiClient>(), services<ApiClient>()), isTrue);
  });

  test('a duplicate API client registration is rejected', () {
    final services = GetIt.asNewInstance();
    addTearDown(services.reset);
    configureCoreDependencies(services);
    registerSharedApiClient(services, baseUrl: 'https://api.example.com');
    expect(
      () => registerSharedApiClient(
        services,
        baseUrl: 'https://other.example.com',
      ),
      throwsA(anything),
    );
  });
}
