// lib/app/modules/checkout/order_confirmed_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/app_bottom_nav.dart';
import '../../shared/formatters.dart';

class OrderConfirmedView extends StatelessWidget {
  const OrderConfirmedView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final args = Get.arguments is Map<String, dynamic>
        ? Get.arguments as Map<String, dynamic>
        : <String, dynamic>{};
    final String? orderId = args['orderId'] as String?;
    final String city = (args['city'] as String?) ?? 'your city';
    final double subtotal = (args['subtotal'] as double?) ?? 0.0;
    final double shipping = (args['shipping'] as double?) ?? 0.0;
    final double total = subtotal + shipping;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Get.toNamed('/keranjang'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order Confirmed!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          if (orderId != null) ...[
            const SizedBox(height: 4),
            Text(
              'Order ID: ${orderId.substring(0, 8)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: scheme.onSurfaceVariant),
              children: [
                const TextSpan(
                  text:
                      'Thank you for your purchase. We will ship your packaging materials to ',
                ),
                TextSpan(
                  text: city,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const TextSpan(text: ' soon.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Order Summary',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const Divider(),
          _row('Subtotal', formatIdr(subtotal), scheme: scheme),
          _row('Shipping', formatIdr(shipping), scheme: scheme),
          const Divider(),
          _row('Total', formatIdr(total), bold: true, scheme: scheme),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => Get.offAllNamed('/katalog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continue Shopping'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.orders),
    );
  }

  Widget _row(
    String left,
    String right, {
    bool bold = false,
    required ColorScheme scheme,
  }) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
