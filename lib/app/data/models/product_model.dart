// lib/app/data/models/product_model.dart
class ProductModel {
  final String id; // Berisi String dari konversi
  final String nama;
  final double harga;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    
    return ProductModel(
      // FIX KRITIS: Konversi ID (int) ke String
      // Menggunakan toString() untuk mengatasi Type Mismatch dari int8/bigint SQL
      id: json['id']?.toString() ?? '0', 
      
      // Menggunakan 'namaProduk' dari Supabase/MockAPI
      nama: json['namaProduk'] as String? ?? 'Nama Kardus Default', 
      
      // Harga (aman dengan konversi toDouble)
      harga: (json['harga'] is num) 
             ? (json['harga'] as num).toDouble() 
             : double.tryParse(json['harga'].toString()) ?? 0.0,
             
      // URL Gambar
      imageUrl: json['gambarUrl'] as String? ?? 'https://placehold.co/400x300', 
    );
  }
}