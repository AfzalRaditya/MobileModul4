// lib/app/modules/katalog/katalog_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'katalog_controller.dart';
import 'rotating_logo.dart'; 
import 'product_card.dart';
import '../keranjang/keranjang_controller.dart'; 

class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});
  
  KeranjangController get keranjangController => Get.find<KeranjangController>(); 

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2; 

    return Obx(() => Scaffold(
      appBar: AppBar(
        title: const Text("Katalog Kardus Muktijaya1"),
        actions: [
          IconButton(
            icon: Icon(
              controller.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
            ),
            onPressed: controller.toggleTheme, 
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Get.toNamed("/keranjang"),
          ),
          IconButton(
            icon: const Icon(Icons.speed),
            onPressed: controller.runHttpComparison,
          )
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
    ));
  }
}