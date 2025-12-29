// lib/app/modules/orders/orders_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';

class OrdersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  String? get currentUserId {
    try {
      return _supabase.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final userId = currentUserId;
    if (userId == null) {
      debugPrint('User not logged in, cannot fetch orders');
      return;
    }

    isLoading.value = true;
    try {
      final List<Map<String, dynamic>> rawData = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final baseOrders = rawData.map((e) => OrderModel.fromMap(e)).toList();

      if (baseOrders.isNotEmpty) {
        final ids = baseOrders
            .where((o) => o.id != null)
            .map((o) => o.id!)
            .toList();

        final List<Map<String, dynamic>> itemRows = await _supabase
            .from('order_items')
            .select()
            .inFilter('order_id', ids);

        final Map<String, List<OrderItemModel>> grouped = {};
        for (final row in itemRows) {
          final item = OrderItemModel.fromMap(row);
          grouped.putIfAbsent(item.orderId, () => []).add(item);
        }

        orders.value = baseOrders.map((order) {
          final items = grouped[order.id] ?? const <OrderItemModel>[];
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
        }).toList();
      } else {
        orders.clear();
      }

      debugPrint('Fetched ${orders.length} orders');
    } on PostgrestException catch (e) {
      debugPrint('Error fetching orders: ${e.message}');
      Get.snackbar('Error', 'Gagal memuat riwayat pesanan');
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createOrder(OrderModel order) async {
    try {
      // Insert order
      final orderData = order.toMap();
      orderData.remove('id'); // Let database generate ID
      
      final List<dynamic> response = await _supabase
          .from('orders')
          .insert(orderData)
          .select();

      if (response.isEmpty) {
        throw Exception('Failed to create order');
      }

      final String orderId = response.first['id'].toString();
      debugPrint('Order created with ID: $orderId');

      // Insert order items
      if (order.items.isNotEmpty) {
        final itemsData = order.items.map((item) {
          final map = item.toMap();
          map['order_id'] = orderId;
          map.remove('id'); // Let database generate ID
          return map;
        }).toList();

        await _supabase.from('order_items').insert(itemsData);
        debugPrint('Inserted ${order.items.length} order items');
      }

      // Refresh orders list
      await fetchOrders();

      return orderId;
    } on PostgrestException catch (e) {
      debugPrint('Error creating order: ${e.message}');
      Get.snackbar('Error', 'Gagal membuat pesanan: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error creating order: $e');
      Get.snackbar('Error', 'Terjadi kesalahan saat membuat pesanan');
      return null;
    }
  }
}
