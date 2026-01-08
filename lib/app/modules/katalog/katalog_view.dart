// lib/app/modules/katalog/katalog_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'katalog_controller.dart';
import 'rotating_logo.dart';
import 'product_card.dart';
import '../keranjang/keranjang_controller.dart';
import '../../shared/app_bottom_nav.dart';
import '../../shared/formatters.dart';

class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});

  KeranjangController get keranjangController =>
      Get.find<KeranjangController>();

  void _openFilterOverlay(BuildContext context, ColorScheme scheme) {
    final currentMin = controller.minHarga.value;
    final currentMax = controller.maxHarga.value;

    String minText = currentMin == null ? '' : currentMin.toString();
    String maxText = currentMax == null ? '' : currentMax.toString();

    int? parseInt(String raw) {
      final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isEmpty) return null;
      return int.tryParse(digits);
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rentang harga',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: minText,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => minText = v),
                          decoration: InputDecoration(
                            labelText: 'Min',
                            filled: true,
                            fillColor: scheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: maxText,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => maxText = v),
                          decoration: InputDecoration(
                            labelText: 'Max',
                            filled: true,
                            fillColor: scheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          controller.clearFilters();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          final min = parseInt(minText);
                          final max = parseInt(maxText);

                          controller.setMinHarga(min);
                          controller.setMaxHarga(max);

                          Navigator.of(context).pop();
                        },
                        child: const Text('Terapkan'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/keranjang'),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Keranjang'),
      ),
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
                                errorBuilder: (context, error, stack) => Icon(
                                  Icons.inventory_2,
                                  color: scheme.onPrimary,
                                ),
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
                        style: TextStyle(
                          color: scheme.onPrimary.withAlpha(220),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Scoped Search
                      Obx(() {
                        final scope = controller.searchScope.value;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Nama'),
                              selected: scope == SearchScope.nama,
                              onSelected: (_) =>
                                  controller.setScope(SearchScope.nama),
                              selectedColor: scheme.surface,
                              backgroundColor: scheme.primary.withAlpha(40),
                              side: BorderSide(
                                color: scheme.onPrimary.withAlpha(120),
                              ),
                              labelStyle: TextStyle(
                                color: scope == SearchScope.nama
                                    ? scheme.onSurface
                                    : scheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('ID'),
                              selected: scope == SearchScope.id,
                              onSelected: (_) =>
                                  controller.setScope(SearchScope.id),
                              selectedColor: scheme.surface,
                              backgroundColor: scheme.primary.withAlpha(40),
                              side: BorderSide(
                                color: scheme.onPrimary.withAlpha(120),
                              ),
                              labelStyle: TextStyle(
                                color: scope == SearchScope.id
                                    ? scheme.onSurface
                                    : scheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('Harga'),
                              selected: scope == SearchScope.harga,
                              onSelected: (_) =>
                                  controller.setScope(SearchScope.harga),
                              selectedColor: scheme.surface,
                              backgroundColor: scheme.primary.withAlpha(40),
                              side: BorderSide(
                                color: scheme.onPrimary.withAlpha(120),
                              ),
                              labelStyle: TextStyle(
                                color: scope == SearchScope.harga
                                    ? scheme.onSurface
                                    : scheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 12),

                      // Implicit (onChanged) + Explicit (submit)
                      TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          filled: true,
                          fillColor: scheme.surface,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller.searchController,
                            builder: (context, value, _) {
                              final hasText = value.text.trim().isNotEmpty;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasText)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      tooltip: 'Clear',
                                      onPressed: controller.clearSearch,
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    tooltip: 'Cari',
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      controller.submitSearch();
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: controller.setSearch,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                          controller.submitSearch();
                        },
                      ),

                      // Auto-complete
                      Obx(() {
                        final suggestions = controller.suggestions;
                        if (suggestions.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Material(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: suggestions
                                  .map(
                                    (s) => ListTile(
                                      dense: true,
                                      leading: Icon(
                                        Icons.search,
                                        color: scheme.onSurfaceVariant,
                                        size: 18,
                                      ),
                                      title: Text(
                                        s,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        controller.applySuggestion(s);
                                      },
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // Onscreen Sort
                      Obx(() {
                        final current = controller.sortOption.value;
                        return Row(
                          children: [
                            Icon(
                              Icons.sort,
                              size: 18,
                              color: scheme.onPrimary.withAlpha(220),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<SortOption>(
                                value: current,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: scheme.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                iconEnabledColor: scheme.onSurfaceVariant,
                                dropdownColor: scheme.surface,
                                onChanged: (v) {
                                  if (v == null) return;
                                  controller.setSort(v);
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: SortOption.terbaru,
                                    child: Text('Urutkan: Default'),
                                  ),
                                  DropdownMenuItem(
                                    value: SortOption.namaAsc,
                                    child: Text('Nama (A–Z)'),
                                  ),
                                  DropdownMenuItem(
                                    value: SortOption.namaDesc,
                                    child: Text('Nama (Z–A)'),
                                  ),
                                  DropdownMenuItem(
                                    value: SortOption.hargaAsc,
                                    child: Text('Harga (Termurah)'),
                                  ),
                                  DropdownMenuItem(
                                    value: SortOption.hargaDesc,
                                    child: Text('Harga (Termahal)'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Obx(() {
                              final active = controller.hasActiveFilters;
                              final bg = active
                                  ? scheme.secondaryContainer
                                  : scheme.surface;
                              final fg = active
                                  ? scheme.onSecondaryContainer
                                  : scheme.onSurface;

                              return IconButton.filled(
                                onPressed: () =>
                                    _openFilterOverlay(context, scheme),
                                style: IconButton.styleFrom(
                                  backgroundColor: bg,
                                  foregroundColor: fg,
                                ),
                                icon: Icon(
                                  active
                                      ? Icons.filter_alt
                                      : Icons.tune,
                                ),
                                tooltip: active
                                    ? 'Filter (aktif)'
                                    : 'Filter',
                              );
                            }),
                          ],
                        );
                      }),

                      // Onscreen Filter (active chips)
                      Obx(() {
                        final min = controller.minHarga.value;
                        final max = controller.maxHarga.value;
                        if (min == null && max == null) {
                          return const SizedBox.shrink();
                        }

                        String labelForMin(int v) => 'Min: ${formatIdr(v.toDouble())}';
                        String labelForMax(int v) => 'Max: ${formatIdr(v.toDouble())}';

                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (min != null)
                                InputChip(
                                  label: Text(labelForMin(min)),
                                  onDeleted: () => controller.setMinHarga(null),
                                  deleteIconColor: scheme.onSurfaceVariant,
                                  backgroundColor: scheme.surface,
                                ),
                              if (max != null)
                                InputChip(
                                  label: Text(labelForMax(max)),
                                  onDeleted: () => controller.setMaxHarga(null),
                                  deleteIconColor: scheme.onSurfaceVariant,
                                  backgroundColor: scheme.surface,
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Search Results
              Obx(() {
                final filtered = controller.filteredProduk;
                if (filtered.isEmpty &&
                    controller.searchQuery.value.isNotEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: scheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
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
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
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
      bottomNavigationBar: const AppBottomNav(current: AppTab.home),
    );
  }
}
