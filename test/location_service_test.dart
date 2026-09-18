import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/core/errors/result.dart';

class ControlledLocationPlatform extends GeolocatorPlatform {
  bool enabled = true, settingsAvailable = true;
  int permissionRequests = 0, positionRequests = 0;
  LocationPermission permission = LocationPermission.denied,
      requested = LocationPermission.whileInUse;
  Object? captureError;
  LocationSettings? capturedSettings;
  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async {
    permissionRequests++;
    return permission = requested;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    positionRequests++;
    capturedSettings = locationSettings;
    if (captureError != null) throw captureError!;
    return Position(
      latitude: 17.4,
      longitude: 78.4,
      timestamp: DateTime.now(),
      accuracy: 18,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  @override
  Future<bool> openAppSettings() async => settingsAvailable;
  @override
  Future<bool> openLocationSettings() async => settingsAvailable;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GeolocatorPlatform original;
  late ControlledLocationPlatform platform;
  final service = DeviceLocationService();
  setUp(() {
    original = GeolocatorPlatform.instance;
    platform = ControlledLocationPlatform();
    GeolocatorPlatform.instance = platform;
  });
  tearDown(() {
    GeolocatorPlatform.instance = original;
  });
  test(
    'permission-free check never requests denied permission; explicit capture requests once',
    () async {
      expect(
        (await service.currentPosition() as Failed<Position>).failure.code,
        'location_permission',
      );
      expect(platform.permissionRequests, 0);
      expect(platform.positionRequests, 0);
      final captured = await service.currentPosition(requestPermission: true);
      expect(captured, isA<Success<Position>>());
      expect(platform.permissionRequests, 1);
      expect(platform.positionRequests, 1);
      expect(platform.capturedSettings!.timeLimit, const Duration(seconds: 15));
      expect((captured as Success<Position>).value.accuracy, 18);
    },
  );
  test(
    'disabled GPS and permanent permission do not repeatedly prompt',
    () async {
      platform.enabled = false;
      expect(
        (await service.currentPosition(requestPermission: true)
                as Failed<Position>)
            .failure
            .code,
        'location_disabled',
      );
      expect(platform.permissionRequests, 0);
      platform.enabled = true;
      platform.permission = LocationPermission.deniedForever;
      expect(
        (await service.currentPosition(requestPermission: true)
                as Failed<Position>)
            .failure
            .code,
        'location_permanent',
      );
      expect(platform.permissionRequests, 0);
      expect(platform.positionRequests, 0);
    },
  );
  test(
    'capture timeout, revoked permission and disabled-service errors remain distinguishable',
    () async {
      platform.permission = LocationPermission.whileInUse;
      for (final failure in [
        (error: TimeoutException('controlled'), code: 'location_timeout'),
        (
          error: PermissionDeniedException('controlled'),
          code: 'location_permission',
        ),
        (error: LocationServiceDisabledException(), code: 'location_disabled'),
        (error: StateError('controlled'), code: 'location_unavailable'),
      ]) {
        platform.captureError = failure.error;
        expect(
          (await service.currentPosition(requestPermission: true)
                  as Failed<Position>)
              .failure
              .code,
          failure.code,
        );
      }
    },
  );
  test(
    'unsupported settings launch reports failure rather than claiming it opened',
    () async {
      platform.settingsAvailable = false;
      expect(await service.openSettings(), isA<Failed<bool>>());
      expect(
        await service.openSettings(locationSettings: true),
        isA<Failed<bool>>(),
      );
      platform.settingsAvailable = true;
      expect(await service.openSettings(), isA<Success<bool>>());
    },
  );
}
