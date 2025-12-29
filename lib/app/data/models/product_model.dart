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
    // Coba beberapa kemungkinan key gambar dari API/Supabase
    final rawImage = json['gambarUrl'] ?? json['imageUrl'] ?? json['image'] ?? json['gambar'] ?? '';
    final image = (rawImage is String && rawImage.isNotEmpty)
        ? rawImage
        : 'https://placehold.co/400x300';
    
    return ProductModel( 
      id: json['id']?.toString() ?? '0', 
      
      nama: json['namaProduk'] as String? ?? 'Nama Kardus Default', 
      
      harga: (json['harga'] is num) 
             ? (json['harga'] as num).toDouble() 
             : double.tryParse(json['harga'].toString()) ?? 0.0,
      imageUrl: image,
    );
  }
}