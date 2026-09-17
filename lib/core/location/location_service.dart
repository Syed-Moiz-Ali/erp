import 'package:geolocator/geolocator.dart';
import '../errors/result.dart';

abstract interface class LocationService {
  Future<Result<Position>> currentPosition();
}

class DeviceLocationService implements LocationService {
  @override
  Future<Result<Position>> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const Failed(
          Failure(
            code: 'location_disabled',
            kind: FailureKind.locationDisabled,
          ),
        );
      }
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
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

  // Permission requests must follow a user action in the future attendance flow.
}
