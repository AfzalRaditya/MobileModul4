import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/delivery_address.dart';
import '../../../data/services/location_service.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final _mapController = MapController();
  final _locationService = LocationService();

  LatLng _center = const LatLng(-6.200000, 106.816666); // default Jakarta
  bool _loading = false;
  String? _hint;

  @override
  void initState() {
    super.initState();
    _hint = 'Mengambil lokasi GPS Anda...';
    _initializeWithCurrentLocation();
  }

  Future<void> _initializeWithCurrentLocation() async {
    try {
      // Try to get current GPS location
      final pos = await _locationService.getCurrentPosition(
        useGps: true,
        timeout: const Duration(seconds: 8),
      );
      
      if (pos != null && mounted) {
        setState(() {
          _center = LatLng(pos.latitude, pos.longitude);
          _hint = 'Geser peta untuk memilih lokasi';
        });
        
        // Move map to current location
        _mapController.move(_center, 16);
      }
    } catch (e) {
      // Fallback to default if GPS fails
      if (mounted) {
        setState(() => _hint = 'Geser peta untuk memilih lokasi');
      }
    }
  }

  Future<void> _useCenter() async {
    setState(() => _loading = true);
    try {
      final place = await _locationService.reverseGeocode(
        latitude: _center.latitude,
        longitude: _center.longitude,
      );

      final addr = DeliveryAddress(
        addressLine: (place?.addressLine.isNotEmpty ?? false)
            ? place!.addressLine
            : 'Lat ${_center.latitude}, Lon ${_center.longitude}',
        latitude: _center.latitude,
        longitude: _center.longitude,
        city: place?.city,
        postalCode: place?.postalCode,
      );

      if (!mounted) return;
      Get.back(result: addr);
    } catch (e) {
      if (!mounted) return;
      setState(() => _hint = 'Gagal reverse geocode: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _useCenter,
            icon: const Icon(Icons.check),
            tooltip: 'Pakai lokasi ini',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _center,
              zoom: 16,
              onPositionChanged: (pos, _) {
                final c = pos.center;
                if (c == null) return;
                _center = c;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'griya_daster_ayu',
              ),
            ],
          ),
          const IgnorePointer(
            child: Center(
              child: Icon(Icons.location_pin, size: 44, color: Colors.red),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hint != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_hint!, textAlign: TextAlign.center),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _useCenter,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(_loading ? 'Memproses...' : 'Pakai lokasi ini'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
