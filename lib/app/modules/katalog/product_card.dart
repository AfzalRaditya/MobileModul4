// lib/app/modules/katalog/product_card.dart

import 'package:flutter/material.dart';
import '../../data/models/product_model.dart'; 

// =========================================================
// WIDGET: AnimatedBuyButton 
// =========================================================

class AnimatedBuyButton extends StatefulWidget {
  final VoidCallback onTap; // <-- Wajib ada
  const AnimatedBuyButton({required this.onTap, super.key}); 

  @override
  AnimatedBuyButtonState createState() => AnimatedBuyButtonState();
}

class AnimatedBuyButtonState extends State<AnimatedBuyButton> {
  Color _color = Colors.blue;
  double _height = 40.0;
  String _text = "Tambahkan ke Keranjang";

  void _handleBuy() {
    widget.onTap(); 
    
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
// WIDGET: ProductCard (Widget Utama Kartu)
// =========================================================

class ProductCard extends StatelessWidget {
  final ProductModel produk;
  final VoidCallback onBuy; 
  
  const ProductCard({required this.produk, required this.onBuy, super.key}); 

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Image.network(
              produk.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50)),
            ),
          ),
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

                Text(
                  "Rp ${produk.harga.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: AnimatedBuyButton(onTap: onBuy), 
          ),
        ],
      ),
    );
  }
}