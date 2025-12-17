// lib/app/modules/katalog/katalog_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'katalog_controller.dart';
import 'rotating_logo.dart';
import 'product_card.dart';
import '../keranjang/keranjang_controller.dart';
import '../location/bindings/location_binding.dart';
import '../location/views/location_view.dart';

class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});

  KeranjangController get keranjangController =>
      Get.find<KeranjangController>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text("Katalog Kardus Muktijaya1"),
          actions: [
            // 1. Tombol Ganti Tema
            IconButton(
              icon: Icon(
                controller.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              ),
              onPressed: controller.toggleTheme,
            ),

            // 2. Tombol Keranjang
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Get.toNamed("/keranjang"),
            ),

            // 3. Tombol Cek Speed (Optional)
            IconButton(
              icon: const Icon(Icons.speed),
              onPressed: controller.runHttpComparison,
            ),

            // --- 4. TOMBOL LOGOUT (BARU) ---
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ), // Saya kasih warna merah biar beda
              tooltip: "Logout",
              onPressed: () {
                // Panggil fungsi logout dari controller
                controller.logout();
              },
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
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
              return ProductCard(
                produk: produk,
                onBuy: () => keranjangController.addToLocalCart(produk),
              );
            },
          );
        }),
        // Tombol lokasi (floating) untuk membuka halaman Location
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'katalog_get_location',
          icon: const Icon(Icons.my_location),
          label: const Text('Lokasi'),
          onPressed: () {
            try {
              // Buka halaman Location dan pastikan binding dijalankan
              Get.to(() => const LocationView(), binding: LocationBinding());
            } catch (e) {
              if (kDebugMode) print('Error membuka LocationView: $e');
            }
          },
        ),
      ),
    );
  }
}
