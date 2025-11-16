// lib/app/modules/katalog/katalog_view.dart
import '../../data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'katalog_controller.dart';
import 'rotating_logo.dart';
import 'product_card.dart';

class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});
  @override
  Widget build(BuildContext context) {
    // 1. Menggunakan MediaQuery (Global) untuk responsivitas grid (Wajib Modul 2)
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 kolom untuk tablet, 2 untuk ponsel

    return Scaffold(
      appBar: AppBar(
        title: const Text("Katalog Muktijaya1"),
        actions: [
          IconButton(
            icon: const Icon(Icons.speed),
            onPressed: controller.runHttpComparison, // Trigger pengujian Dio vs http
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // Menampilkan animasi Loading Eksplisit (Untuk Analisis CPU/GPU Modul 2)
          return Center(child: RotatingLogo()); 
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, 
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7, 
          ),
          itemCount: controller.produkList.length,
          itemBuilder: (context, index) {
            final produk = controller.produkList[index];
            return ProductCard(produk: produk);
          },
        );
      }),
    );
  }
}

// Widget untuk setiap item produk
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
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
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
                // 2. Menggunakan LayoutBuilder (Lokal) untuk menyesuaikan dimensi teks (Wajib Modul 2)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 120;
                    return Text(
                      "Rp ${produk.harga.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: isNarrow ? 10 : 12, color: Colors.grey[600]),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${produk.harga.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Tombol Beli dengan Animasi Implisit (Untuk Analisis CPU/GPU Modul 2)
          Expanded(
            flex: 1,
            child: AnimatedBuyButton(), 
          ),
        ],
      ),
    );
  }
}