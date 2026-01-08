// lib/app/modules/checkout/checkout_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/location_service.dart';
import '../../data/models/delivery_address.dart';
import '../../data/models/order_model.dart';
import '../../shared/formatters.dart';
import '../../shared/app_bottom_nav.dart';
import '../keranjang/keranjang_controller.dart';
import '../orders/orders_controller.dart';

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
  final _cityC = TextEditingController();
  String? _city;
  bool _locating = false;
  final _locationService = LocationService();

  // Common Indonesian cities for autocomplete
  final List<String> _indonesianCities = [
    'Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Semarang', 'Makassar', 'Palembang',
    'Tangerang', 'Depok', 'Bekasi', 'Bogor', 'Batam', 'Pekanbaru', 'Bandar Lampung',
    'Padang', 'Malang', 'Denpasar', 'Samarinda', 'Tasikmalaya', 'Banjarmasin',
    'Pontianak', 'Cimahi', 'Balikpapan', 'Jambi', 'Surakarta', 'Serang', 'Mataram',
    'Manado', 'Yogyakarta', 'Cilegon', 'Kupang', 'Palu', 'Ambon', 'Sukabumi',
    'Cirebon', 'Pekalongan', 'Kediri', 'Madiun', 'Jayapura', 'Bengkulu',
    'Dumai', 'Magelang', 'Probolinggo', 'Salatiga', 'Tegal', 'Binjai',
    'Banda Aceh', 'Bitung', 'Banjarbaru', 'Tarakan', 'Lubuklinggau', 'Tanjungpinang',
    'Pangkalpinang', 'Batu', 'Singkawang', 'Parepare', 'Palangkaraya', 'Bontang',
    'Mojokerto', 'Pasuruan', 'Marabahan', 'Sorong', 'Ternate', 'Gorontalo',
    'Baubau', 'Kendari', 'Tidore', 'Blitar', 'Bukittinggi', 'Solok', 'Padang Panjang',
    'Payakumbuh', 'Sawahlunto', 'Tanjungbalai', 'Tebing Tinggi', 'Pematangsiantar',
    'Sibolga', 'Gunungsitoli', 'Pangkal Pinang', 'Lubuklinggau', 'Prabumulih',
    'Metro', 'Kotabumi', 'Cirebon', 'Purwokerto', 'Banyumas', 'Cilacap'
  ];

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      // Check if location service is enabled
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        Get.snackbar(
          'GPS Tidak Aktif',
          'Silakan aktifkan GPS/Location Service terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _locating = false);
        return;
      }

      // Check and request permission
      final hasPermission = await _locationService.isPermissionGranted();
      if (!hasPermission) {
        final granted = await _locationService.requestPermission(requireGps: true);
        if (!granted) {
          if (!mounted) return;
          Get.snackbar(
            'Izin Ditolak',
            'Aplikasi memerlukan izin lokasi untuk menggunakan fitur ini',
            snackPosition: SnackPosition.BOTTOM,
          );
          setState(() => _locating = false);
          return;
        }
      }

      // Get current GPS position with high accuracy
      final DeliveryAddress? addr = await _locationService.getDeliveryAddress(
        useGps: true,
      );

      if (!mounted) return;
      if (addr == null) {
        Get.snackbar(
          'Lokasi Gagal',
          'Tidak dapat mendapatkan lokasi. Pastikan GPS aktif dan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _locating = false);
        return;
      }

      _addressC.text = addr.addressLine;
      if ((addr.postalCode ?? '').isNotEmpty) {
        _postalC.text = addr.postalCode!;
      }
      if ((addr.city ?? '').isNotEmpty) {
        _cityC.text = addr.city!;
        _city = addr.city;
      }
      
      Get.snackbar(
        'Berhasil',
        'Lokasi GPS berhasil didapatkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  Future<void> _placeOrder(double subtotal, double shipping) async {
    // Validate inputs
    if (_nameC.text.trim().isEmpty) {
      Get.snackbar('Error', 'Nama harus diisi');
      return;
    }
    if (_emailC.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email harus diisi');
      return;
    }
    if (_addressC.text.trim().isEmpty) {
      Get.snackbar('Error', 'Alamat harus diisi');
      return;
    }
    if (_city == null) {
      Get.snackbar('Error', 'Pilih kota terlebih dahulu');
      return;
    }

    // Get current user
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      Get.snackbar('Error', 'Anda harus login untuk melakukan pemesanan');
      return;
    }

    // Get cart items
    final cart = Get.isRegistered<KeranjangController>()
        ? Get.find<KeranjangController>()
        : null;
    if (cart == null || cart.itemsLokal.isEmpty) {
      Get.snackbar('Error', 'Keranjang kosong');
      return;
    }

    // Create order items from cart
    final orderItems = cart.itemsLokal.map((cartItem) {
      return OrderItemModel(
        orderId: '', // Will be set after order creation
        productId: cartItem.productId,
        productName: cartItem.productName,
        price: cartItem.price,
        quantity: cartItem.quantity,
      );
    }).toList();

    // Create order
    final order = OrderModel(
      userId: userId,
      customerName: _nameC.text.trim(),
      customerEmail: _emailC.text.trim(),
      shippingAddress: _addressC.text.trim(),
      city: _city,
      postalCode: _postalC.text.trim().isEmpty ? null : _postalC.text.trim(),
      subtotal: subtotal,
      shippingCost: shipping,
      total: subtotal + shipping,
      items: orderItems,
      status: 'pending',
    );

    // Save order
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Initialize orders controller if not already
      if (!Get.isRegistered<OrdersController>()) {
        Get.put(OrdersController());
      }
      final ordersController = Get.find<OrdersController>();
      
      final orderId = await ordersController.createOrder(order);
      
      Get.back(); // Close loading dialog
      
      if (orderId != null) {
        // Clear cart after successful order
        cart.clearLocalCart();
        
        // Navigate to confirmation
        Get.offAllNamed(
          '/order-confirmed',
          arguments: {
            'orderId': orderId,
            'city': _city,
            'subtotal': subtotal,
            'shipping': shipping,
          },
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Gagal membuat pesanan: $e');
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
                if ((picked.city ?? '').isNotEmpty) {
                  _cityC.text = picked.city!;
                  setState(() => _city = picked.city);
                }
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Atur di Map'),
            ),
          ),
          const SizedBox(height: 12),

          _LabeledField(
            label: 'Daerah',
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _indonesianCities.where((String city) {
                  return city.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                setState(() {
                  _city = selection;
                  _cityC.text = selection;
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                // Sync with our controller
                if (_cityC.text.isNotEmpty && controller.text.isEmpty) {
                  controller.text = _cityC.text;
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: _decoration('Ketik nama daerah', scheme),
                  onChanged: (value) {
                    setState(() {
                      _city = value.trim().isEmpty ? null : value.trim();
                      _cityC.text = value;
                    });
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 300,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
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
                      onPressed: () => _placeOrder(subtotal, shipping),
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
