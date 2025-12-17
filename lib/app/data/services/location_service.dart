import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// LocationService: wrapper ringan di sekitar geolocator
/// Menyediakan API yang digunakan oleh controller di modul location
class LocationService {
  LocationService();

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request permission. Jika [requireGps] true maka juga memeriksa service enabled
  /// Mengembalikan `true` jika permission diberikan (whileInUse/always)
  Future<bool> requestPermission({bool requireGps = false}) async {
    if (requireGps) {
      final enabled = await isLocationServiceEnabled();
      if (!enabled) {
        throw LocationServiceDisabledException();
      }
    }

    LocationPermission status = await Geolocator.requestPermission();
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  Future<bool> isPermissionGranted() async {
    final status = await checkPermission();
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  Future<Position?> getCurrentPosition({
    bool useGps = true,
    Duration? timeout,
  }) async {
    final desired = useGps ? LocationAccuracy.high : LocationAccuracy.medium;
    try {
      final future = Geolocator.getCurrentPosition(desiredAccuracy: desired);
      if (timeout != null) {
        return await future.timeout(timeout);
      }
      return await future;
    } on TimeoutException {
      rethrow;
    }
  }

  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  Stream<Position>? getPositionStream({
    bool useGps = true,
    int distanceFilter = 0,
  }) {
    final accuracy = useGps ? LocationAccuracy.high : LocationAccuracy.low;
    try {
      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        ),
      );
    } catch (e) {
      // Jika platform tidak mendukung streaming, kembalikan null
      return null;
    }
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Tidak ada API untuk menghentikan stream global di geolocator karena
  /// stream dikontrol oleh pemanggil yang menerima Stream dan membuat
  /// subscription sendiri. Sediakan method ini sebagai no-op agar controller
  /// bisa memanggilnya tanpa error.
  void stopPositionStream() {
    // no-op
  }
}
