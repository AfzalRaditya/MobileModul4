// lib/app/modules/katalog/katalog_view.dart (FINAL FIX)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'katalog_controller.dart';
import 'rotating_logo.dart'; 
import 'product_card.dart';
import '../auth/auth_controller.dart'; 

class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Ambil instance AuthController di awal build()
    final AuthController authController = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Katalog Muktijaya1"),
        actions: [
           // Tombol Login/Logout menggunakan Obx yang aman
           Obx(() => IconButton(
            // Menggunakan getter isLoggedIn dari AuthController
            icon: Icon(authController.isLoggedIn ? Icons.logout : Icons.login),
            onPressed: () {
              if (authController.isLoggedIn) {
                authController.signOut();
              } else {
                Get.toNamed("/login");
              }
            },
          )),
          // ... (Tombol Refresh dan Cart tetap sama)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchKatalogData(),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Get.toNamed("/keranjang"),
          ),
        ],
      ),
      
      // BODY: Satu Obx untuk mengendalikan Loading dan List (Struktur yang Aman)
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: RotatingLogo()); 
        }

        if (controller.produkList.isEmpty) {
          return Center(
            // ... (Empty State Logic)
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Katalog Kosong", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () => controller.fetchKatalogData(),
                  child: const Text("Refresh Data"),
                )
              ],
            ),
          );
        }

        // GRID LIST
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