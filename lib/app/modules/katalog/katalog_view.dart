// lib/app/modules/katalog/katalog_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'katalog_controller.dart';
import 'rotating_logo.dart';
import 'product_card.dart';
import '../keranjang/keranjang_controller.dart';
import '../../shared/app_bottom_nav.dart';

class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});

  KeranjangController get keranjangController =>
      Get.find<KeranjangController>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: RotatingLogo());
          }

          return RefreshIndicator(
            onRefresh: controller.refreshKatalog,
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                width: 24,
                                height: 24,
                                color: scheme.onPrimary,
                                errorBuilder: (context, error, stack) =>
                                    Icon(Icons.inventory_2, color: scheme.onPrimary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Griya Daster Ayu',
                                style: TextStyle(
                                  color: scheme.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                                onPressed: () => Get.toNamed('/keranjang'),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                                tooltip: 'Logout',
                                onPressed: controller.logout,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to Griya Daster Ayu',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Temukan koleksi daster yang nyaman untuk sehari-hari.',
                        style: TextStyle(color: scheme.onPrimary.withAlpha(220)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          filled: true,
                          fillColor: scheme.surface,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clearSearch,
                              )
                            : const SizedBox.shrink()),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: controller.setSearch,
                      ),
                    ],
                  ),
                ),
              ),
              // Jika hasil pencarian kosong, tampilkan pesan
              Obx(() {
                final filtered = controller.filteredProduk;
                if (filtered.isEmpty && controller.searchQuery.value.isNotEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba kata kunci lain',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(10),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final produk = filtered[index];
                      return ProductCard(
                        produk: produk,
                        onBuy: () => keranjangController.addToLocalCart(produk),
                      );
                    }, childCount: filtered.length),
                  ),
                );
              }),
            ],
            ),
          );
      }),
      // Bottom nav sesuai screenshot (Home/Orders/Profile)
      bottomNavigationBar: const AppBottomNav(current: AppTab.home),
    );
  }
}
