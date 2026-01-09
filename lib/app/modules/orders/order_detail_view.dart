import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/formatters.dart';
import '../../data/models/order_model.dart';

class OrderDetailView extends StatefulWidget {
  final String orderId;

  const OrderDetailView({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<OrderModel?> _futureOrder;

  @override
  void initState() {
    super.initState();
    _futureOrder = _fetchOrderWithItems(widget.orderId);
  }

  Future<OrderModel?> _fetchOrderWithItems(String orderId) async {
    try {
      // Supabase select with nested relation: orders -> order_items -> products
      // This requires foreign keys between order_items.order_id -> orders.id
      // and order_items.product_id -> products.id. The select below requests
      // the order row plus nested order_items and nested products inside each item.
      final res = await _supabase
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('id', orderId)
          .maybeSingle();

      if (res == null) return null;

      final Map<String, dynamic> map = Map<String, dynamic>.from(res as Map);

      // Map to OrderModel. OrderModel.fromMap expects items separately, so we
      // parse items from nested 'order_items' and build OrderItemModel list.
      final order = OrderModel.fromMap(map);

      final itemsRaw = map['order_items'] as List<dynamic>?;
      if (itemsRaw != null) {
        final items = itemsRaw.map((e) {
          final itemMap = Map<String, dynamic>.from(e as Map);
          // If product relation exists inside item, attach image or other fields
          if (itemMap['products'] is Map) {
            final prod = Map<String, dynamic>.from(itemMap['products'] as Map);
            // copy image url or other useful fields into itemMap if needed
            if (prod.containsKey('image_url')) {
              itemMap['product_image'] = prod['image_url'];
            } else if (prod.containsKey('imageUrl')) {
              itemMap['product_image'] = prod['imageUrl'];
            } else if (prod.containsKey('image')) {
              itemMap['product_image'] = prod['image'];
            }
          }
          return OrderItemModel.fromMap(itemMap);
        }).toList();

        return OrderModel(
          id: order.id,
          userId: order.userId,
          customerName: order.customerName,
          customerEmail: order.customerEmail,
          shippingAddress: order.shippingAddress,
          city: order.city,
          postalCode: order.postalCode,
          subtotal: order.subtotal,
          shippingCost: order.shippingCost,
          total: order.total,
          items: items,
          status: order.status,
          createdAt: order.createdAt,
        );
      }

      return order;
    } catch (e) {
      debugPrint('Error fetching order detail: $e');
      return null;
    }
  }

  Widget _buildItemRow(OrderItemModel item) {
    final imageUrl = (item.toMap()['product_image'] as String?) ?? '';
    final subtotal = item.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.grey.shade400))
                  : Container(color: Colors.grey.shade100, child: Icon(Icons.image, color: Colors.grey.shade400)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${item.quantity} × ${formatIdr(item.price)}', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(formatIdr(subtotal), style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: FutureBuilder<OrderModel?>(
        future: _futureOrder,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data == null) {
            return Center(child: Text('Data pesanan tidak ditemukan', style: TextStyle(color: scheme.onSurfaceVariant)));
          }

          final order = snap.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID
                Text('Order ID', style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                SelectableText(order.id ?? '-', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 16),

                // Shipping details
                Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(order.shippingAddress, style: TextStyle(color: scheme.onSurfaceVariant)),
                if (order.city != null) Text('${order.city}${order.postalCode != null ? ', ' + order.postalCode! : ''}', style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 16),

                // Items list
                Text('Daftar Barang', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => _buildItemRow(order.items[index]),
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: order.items.length,
                ),
                const SizedBox(height: 12),

                // Payment summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Subtotal', style: TextStyle(color: scheme.onSurfaceVariant)), Text(formatIdr(order.subtotal))],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Ongkos Kirim', style: TextStyle(color: scheme.onSurfaceVariant)), Text(formatIdr(order.shippingCost))],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Total', style: const TextStyle(fontWeight: FontWeight.w800)), Text(formatIdr(order.total), style: const TextStyle(fontWeight: FontWeight.w900))],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: scheme.primary),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
