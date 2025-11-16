// lib/app/data/models/product_model.dart
class ProductModel {
  final String id;
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
      // Menggunakan 'id' dari MockAPI (diberi default '0' jika null)
      id: json['id'] as String? ?? '0', 
      
      // Menggunakan 'namaProduk' dari MockAPI (diberi default jika null)
      nama: json['namaProduk'] as String? ?? 'Nama Kardus Default', 
      
      // Harga (dikonversi ke double, diberi default 0.0 jika null)
      harga: (json['harga'] is num) 
             ? (json['harga'] as num).toDouble() 
             : double.tryParse(json['harga'].toString()) ?? 0.0,
    
      // Menggunakan 'gambarUrl' dari MockAPI
      imageUrl: json['gambarUrl'] as String? ?? 'https://placehold.co/400x300', 
    );
  }
}