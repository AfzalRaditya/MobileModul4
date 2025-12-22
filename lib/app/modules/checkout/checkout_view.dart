// lib/app/modules/checkout/checkout_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/location_service.dart';
import '../../data/models/delivery_address.dart';
import '../../shared/formatters.dart';
import '../../shared/app_bottom_nav.dart';
import '../keranjang/keranjang_controller.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _addressC = TextEditingController();
  final _postalC = TextEditingController();
  String? _city;
  bool _locating = false;
  final _locationService = LocationService();

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      DeliveryAddress? addr;
      try {
        addr = await _locationService.getDeliveryAddress(useGps: true);
      } catch (_) {
        addr = await _locationService.getDeliveryAddress(useGps: false);
      }

      if (!mounted) return;
      if (addr == null) {
        Get.snackbar('Location', 'Gagal mendapatkan lokasi. Pastikan permission aktif.');
        return;
      }

      _addressC.text = addr.addressLine;
      if ((addr.postalCode ?? '').isNotEmpty) {
        _postalC.text = addr.postalCode!;
      }
    } catch (e) {
      Get.snackbar('Lokasi gagal', 'Tidak bisa mengambil lokasi: $e');
    } finally {
      setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      bottomNavigationBar: const AppBottomNav(current: AppTab.home),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Shipping Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your delivery address.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          _LabeledField(
            label: 'Full Name',
            child: TextField(
              controller: _nameC,
              decoration: _decoration('Your name', scheme),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Email',
            child: TextField(
              controller: _emailC,
              decoration: _decoration('you@example.com', scheme),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Address',
                  child: TextField(
                    controller: _addressC,
                    decoration: _decoration('123 Packaging St', scheme),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _locating ? null : _useMyLocation,
                icon: const Icon(Icons.my_location),
                label: Text(_locating ? 'Locating...' : 'Use My Location'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await Get.toNamed<dynamic>('/location-picker');
                final picked = result is DeliveryAddress ? result : null;
                if (picked == null) return;
                _addressC.text = picked.addressLine;
                if ((picked.postalCode ?? '').isNotEmpty) {
                  _postalC.text = picked.postalCode!;
                }
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Atur di Map'),
            ),
          ),
          const SizedBox(height: 12),

          _LabeledField(
            label: 'City (Zone)',
            child: DropdownButtonFormField<String>(
              initialValue: _city,
              items: const [
                DropdownMenuItem(value: 'Jakarta', child: Text('Jakarta')),
                DropdownMenuItem(value: 'Bogor', child: Text('Bogor')),
                DropdownMenuItem(value: 'Depok', child: Text('Depok')),
                DropdownMenuItem(value: 'Tangerang', child: Text('Tangerang')),
                DropdownMenuItem(value: 'Bekasi', child: Text('Bekasi')),
              ],
              onChanged: (v) => setState(() => _city = v),
              decoration: _decoration('Select City', scheme),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Postal Code',
            child: TextField(
              controller: _postalC,
              decoration: _decoration('12345', scheme),
              keyboardType: TextInputType.number,
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          // Hitung subtotal dari keranjang dan biaya kirim sederhana
          Builder(
            builder: (context) {
              final cart = Get.isRegistered<KeranjangController>()
                  ? Get.find<KeranjangController>()
                  : null;
              final double subtotal = cart?.totalHarga ?? 0.0;
              final double shipping = _city == null ? 0.0 : 20000.0;
              final double total = subtotal + shipping;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _summaryRow(
                    'Subtotal',
                    formatIdr(subtotal),
                    bold: true,
                    scheme: scheme,
                  ),
                  _summaryRow(
                    'Shipping',
                    _city == null
                        ? 'Select city'
                        : formatIdr(shipping),
                    bold: true,
                    scheme: scheme,
                  ),
                  const Divider(),
                  _summaryRow(
                    'Total',
                    formatIdr(total),
                    bold: true,
                    large: true,
                    scheme: scheme,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed(
                        '/order-confirmed',
                        arguments: {
                          'city': _city,
                          'subtotal': subtotal,
                          'shipping': shipping,
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Place Order'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint, ColorScheme scheme) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: scheme.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  Widget _summaryRow(
    String left,
    String right, {
    bool bold = false,
    bool large = false,
    required ColorScheme scheme,
  }) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      fontSize: large ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: style),
          Text(right, style: style.copyWith(color: scheme.primary)),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
