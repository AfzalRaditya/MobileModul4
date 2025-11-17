// lib/app/data/models/cart_model.dart
import 'package:hive/hive.dart';

// part ini yang akan di-generate oleh build_runner
part 'cart_model.g.dart'; 

@HiveType(typeId: 0) // typeId harus unik
class CartItemModel {
  @HiveField(0)
  final String productId;
  @HiveField(1)
  final String productName;
  @HiveField(2)
  final double price;
  @HiveField(3)
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  // Metode untuk konversi ke format Map (untuk Supabase)
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
    };
  }
}