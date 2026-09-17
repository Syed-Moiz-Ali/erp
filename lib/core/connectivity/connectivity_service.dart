import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityService {
  Future<bool> get isConnected;
  Stream<bool> get changes;
}

class DeviceConnectivityService implements ConnectivityService {
  DeviceConnectivityService(this.connectivity);
  final Connectivity connectivity;
  bool _available(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
  @override
  Future<bool> get isConnected async =>
      _available(await connectivity.checkConnectivity());
  @override
  Stream<bool> get changes =>
      connectivity.onConnectivityChanged.map(_available).distinct();
  // Network availability is a hint, never proof of server reachability.
}
