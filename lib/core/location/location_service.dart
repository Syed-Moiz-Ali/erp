import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../errors/result.dart';

abstract interface class LocationService {
  Future<Result<Position>> currentPosition({bool requestPermission = false});
  Future<Result<bool>> openSettings({bool locationSettings = false});
}

class DeviceLocationService implements LocationService {
  @override
  Future<Result<Position>> currentPosition({
    bool requestPermission = false,
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Failed(
          Failure(
            code: 'location_disabled',
            kind: FailureKind.locationDisabled,
          ),
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const Failed(
          Failure(
            code: 'location_permanent',
            kind: FailureKind.locationPermission,
          ),
        );
      }
      if (permission == LocationPermission.denied) {
        return const Failed(
          Failure(
            code: 'location_permission',
            kind: FailureKind.locationPermission,
          ),
        );
      }
      return Success(
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        ),
      );
    } on TimeoutException {
      return const Failed(
        Failure(
          code: 'location_timeout',
          kind: FailureKind.timeout,
          retryable: true,
        ),
      );
    } catch (_) {
      return const Failed(
        Failure(
          code: 'location_unavailable',
          kind: FailureKind.locationUnavailable,
          retryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> openSettings({bool locationSettings = false}) async {
    try {
      return Success(
        await (locationSettings
            ? Geolocator.openLocationSettings()
            : Geolocator.openAppSettings()),
      );
    } catch (_) {
      return const Failed(
        Failure(
          code: 'location_unavailable',
          kind: FailureKind.locationUnavailable,
          retryable: true,
        ),
      );
    }
  }
}
