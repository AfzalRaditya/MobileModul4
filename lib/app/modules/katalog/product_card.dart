// lib/app/modules/katalog/product_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import 'katalog_controller.dart'; 

// =========================================================
// WIDGET: AnimatedBuyButton (Modifikasi: menerima produk)
// =========================================================

class AnimatedBuyButton extends StatefulWidget {
  final ProductModel produk; // Terima data produk
  const AnimatedBuyButton({required this.produk, super.key});

  @override
  AnimatedBuyButtonState createState() => AnimatedBuyButtonState();
}

class AnimatedBuyButtonState extends State<AnimatedBuyButton> {
  Color _color = Colors.blue;
  double _height = 40.0;
  String _text = "Tambahkan ke Keranjang";
  final KatalogController _controller = Get.find<KatalogController>(); // Ambil Controller

  void _handleBuy() {
    // 1. Panggil fungsi penyimpanan ke Hive (Modul 4)
    _controller.addToCart(widget.produk); 

    // 2. Animasi Umpan Balik (Modul 2)
    setState(() {
      _color = Colors.green; 
      _height = 50.0;
      _text = "Tersimpan!";
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _color = Colors.blue;
          _height = 40.0;
          _text = "Tambahkan ke Keranjang";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleBuy,
      child: AnimatedContainer( 
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _height,
        color: _color,
        alignment: Alignment.center,
        child: Text(
          _text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// =========================================================
// WIDGET: ProductCard (Meneruskan produk ke AnimatedBuyButton)
// =========================================================

class ProductCard extends StatelessWidget {
  final ProductModel produk;
  const ProductCard({required this.produk, super.key}); 

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar Produk
          Expanded(
            flex: 4,
            child: Image.network(
              produk.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50)),
            ),
          ),
          // Detail dan Harga
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Harga Utama
                Text(
                  "Rp ${produk.harga.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // Tombol Tambah Keranjang (Implementasi Modul 4)
          Expanded(
            flex: 1,
            child: AnimatedBuyButton(produk: produk), // <-- Meneruskan produk
          ),
        ],
      ),
    );
  }
}