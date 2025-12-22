// lib/app/modules/katalog/katalog_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'katalog_controller.dart';
import 'rotating_logo.dart';
import 'product_card.dart';
import '../keranjang/keranjang_controller.dart';
import '../notifications/notification_binding.dart';
import '../notifications/notification_view.dart';
import '../notifications/notification_controller.dart';
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

          return CustomScrollView(
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
                              Icon(Icons.inventory_2, color: scheme.onPrimary),
                              const SizedBox(width: 8),
                              Text(
                                'Muktijaya1',
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
                              Obx(() {
                                final notifCtrl =
                                    Get.find<NotificationController>();
                                final unread = notifCtrl.unreadCount;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Get.to(
                                        () => const NotificationView(),
                                        binding: NotificationBinding(),
                                      ),
                                    ),
                                    if (unread > 0)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 18,
                                            minHeight: 18,
                                          ),
                                          child: Text(
                                            unread > 99 ? '99+' : '$unread',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }),
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
                        'Welcome to Muktijaya1',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your one-stop solution for premium packaging materials. High quality, durable, and eco-friendly options available.',
                        style: TextStyle(color: scheme.onPrimary.withAlpha(220)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                filled: true,
                                fillColor: scheme.surface,
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.filter_list),
                            label: const Text('All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.surface,
                              foregroundColor: scheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final produk = controller.produkList[index];
                    return ProductCard(
                      produk: produk,
                      onBuy: () => keranjangController.addToLocalCart(produk),
                    );
                  }, childCount: controller.produkList.length),
                ),
              ),
            ],
          );
      }),
      // Bottom nav sesuai screenshot (Home/Orders/Profile)
      bottomNavigationBar: const AppBottomNav(current: AppTab.home),
    );
  }
}
