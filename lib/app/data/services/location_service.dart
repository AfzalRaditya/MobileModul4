import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/delivery_address.dart';

/// LocationService: wrapper ringan di sekitar geolocator
/// Menyediakan API yang digunakan oleh controller di modul location
class LocationService {
  LocationService();

  /// Reverse geocode menggunakan OpenStreetMap Nominatim.
  /// Mengembalikan `DeliveryAddress` minimal (addressLine + lat/lon) jika berhasil.
  Future<DeliveryAddress?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'zoom': '18',
      'addressdetails': '1',
    });

    final res = await http.get(
      uri,
      headers: const {
        // Nominatim meminta user-agent yang jelas.
        'User-Agent': 'MobileModul4/1.0 (Flutter)',
        'Accept-Language': 'id-ID,id;q=0.9,en;q=0.8',
      },
    );

    if (res.statusCode != 200) return null;
    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;

    final displayName = (json['display_name'] as String?)?.trim();
    final address = (json['address'] is Map)
        ? (json['address'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final city = (address['city'] as String?) ??
        (address['town'] as String?) ??
        (address['village'] as String?) ??
        (address['county'] as String?) ??
        (address['state'] as String?);

    final postal = (address['postcode'] as String?);

    return DeliveryAddress(
      addressLine: displayName ?? '',
      latitude: latitude,
      longitude: longitude,
      city: city,
      postalCode: postal,
    );
  }

  /// Ambil lokasi saat ini lalu ubah menjadi alamat (untuk Checkout).
  Future<DeliveryAddress?> getDeliveryAddress({
    bool useGps = true,
  }) async {
    // Pastikan service & permission.
    final hasPermission = await isPermissionGranted();
    if (!hasPermission) {
      final granted = await requestPermission(requireGps: useGps);
      if (!granted) return null;
    }

    Position? pos;
    try {
      pos = await getCurrentPosition(
        useGps: useGps,
        timeout: const Duration(seconds: 10),
      );
    } catch (_) {
      // ignore and fallback
    }
    pos ??= await getLastKnownPosition();
    if (pos == null) return null;

    final place = await reverseGeocode(
      latitude: pos.latitude,
      longitude: pos.longitude,
    );

    // Jika reverse gagal, tetap kembalikan koordinat.
    return place ??
        DeliveryAddress(
          addressLine: 'Lat ${pos.latitude}, Lon ${pos.longitude}',
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
  }

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
