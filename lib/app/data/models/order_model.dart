// lib/app/data/models/order_model.dart

class OrderModel {
  final String? id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String shippingAddress;
  final String? city;
  final String? postalCode;
  final double subtotal;
  final double shippingCost;
  final double total;
  final List<OrderItemModel> items;
  final String status;
  final DateTime createdAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.shippingAddress,
    this.city,
    this.postalCode,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.items,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'shipping_address': shippingAddress,
      'city': city,
      'postal_code': postalCode,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'total': total,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString(),
      userId: map['user_id'] as String? ?? '',
      customerName: map['customer_name'] as String? ?? '',
      customerEmail: map['customer_email'] as String? ?? '',
      shippingAddress: map['shipping_address'] as String? ?? '',
      city: map['city'] as String?,
      postalCode: map['postal_code'] as String?,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (map['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      items: [], // Items loaded separately from order_items table
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class OrderItemModel {
  final String? id;
  final String orderId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id']?.toString(),
      orderId: map['order_id'] as String? ?? '',
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 0,
    );
  }
}
