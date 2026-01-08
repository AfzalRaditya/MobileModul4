// lib/app/modules/katalog/katalog_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
// Tambahkan import Supabase Provider
import '../../data/providers/supabase_provider.dart';

enum SearchScope {
  nama,
  id,
  harga,
}

enum SortOption {
  terbaru, // default order from fetch
  namaAsc,
  namaDesc,
  hargaAsc,
  hargaDesc,
}

class KatalogController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final RxBool isLoading = true.obs;
  final RxList<ProductModel> produkList = <ProductModel>[].obs;
  // Query pencarian (untuk filter realtime)
  final RxString searchQuery = ''.obs;
  final searchController = TextEditingController();

  // Scoped Search (default: Nama)
  final Rx<SearchScope> searchScope = SearchScope.nama.obs;

  // Onscreen Sort (default: terbaru)
  final Rx<SortOption> sortOption = SortOption.terbaru.obs;

  // Filters
  // Note: ProductModel currently only has id, nama, harga, imageUrl
  // so filters are implemented as price range.
  final RxnInt minHarga = RxnInt();
  final RxnInt maxHarga = RxnInt();

  Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    themeMode.value = _localStorage.getThemeMode();
    super.onInit();
    fetchKatalogData();
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;

    _localStorage.setThemeMode(newMode);
    themeMode.value = newMode;
    Get.changeThemeMode(newMode);

    debugPrint("Theme changed to: $newMode");
  }

  // --- FUNGSI LOGOUT (DITAMBAHKAN) ---
  void logout() async {
    try {
      // 1. Logout dari Supabase (Server Side)
      // Kita perlu cari providernya dulu
      if (Get.isRegistered<SupabaseProvider>()) {
        final supabase = Get.find<SupabaseProvider>();
        await supabase.client.value?.auth.signOut();
      }

      // 2. Hapus Session Lokal (Local Side)
      await _localStorage.removeSession();

      // 3. Lempar balik ke Login
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint("Error saat logout: $e");
      // Fallback: Kalau server error, tetap paksa hapus sesi lokal & keluar
      await _localStorage.removeSession();
      Get.offAllNamed('/login');
    }
  }
  // -----------------------------------

  Future<void> fetchKatalogData() async {
    try {
      isLoading.value = true;
      
      // Fetch dari Supabase products table
      final supabase = Get.find<SupabaseProvider>();
      final response = await supabase.client.value
          ?.from('products')
          .select()
          .order('id', ascending: true);
      
      if (response != null) {
        final products = (response as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        produkList.assignAll(products);
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      Get.snackbar("Error", "Gagal memuat katalog: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data katalog
  Future<void> refreshKatalog() async {
    await fetchKatalogData();
  }

  // Set query pencarian
  void setSearch(String value) {
    searchQuery.value = value;
  }

  // Explicit search: dipanggil saat user menekan tombol cari / submit keyboard
  void submitSearch() {
    final q = searchController.text.trim();
    searchQuery.value = q;
    // Force notify so explicit action (arrow) always triggers a refresh,
    // even when the query text didn't change.
    searchQuery.refresh();
  }

  void setScope(SearchScope scope) {
    if (searchScope.value == scope) return;
    searchScope.value = scope;
  }

  void setSort(SortOption option) {
    if (sortOption.value == option) return;
    sortOption.value = option;
  }

  void setMinHarga(int? value) {
    minHarga.value = value;
  }

  void setMaxHarga(int? value) {
    maxHarga.value = value;
  }

  void clearFilters() {
    minHarga.value = null;
    maxHarga.value = null;
  }

  bool get hasActiveFilters =>
      minHarga.value != null || maxHarga.value != null;

  void applySuggestion(String value) {
    searchController.text = value;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
    submitSearch();
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Daftar produk yang sudah difilter berdasarkan pencarian
  List<ProductModel> get filteredProduk {
    final q = searchQuery.value.trim().toLowerCase();
    final List<ProductModel> base;

    if (q.isEmpty) {
      base = produkList.toList(growable: false);
    } else {
      switch (searchScope.value) {
        case SearchScope.nama:
          base = produkList.where((p) => p.nama.toLowerCase().contains(q)).toList();
          break;
        case SearchScope.id:
          base = produkList.where((p) => p.id.toLowerCase().contains(q)).toList();
          break;
        case SearchScope.harga:
          final digits = q.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.isEmpty) return <ProductModel>[];

          base = produkList.where((p) {
            final priceInt = p.harga.round().toString();
            return priceInt.contains(digits);
          }).toList();
          break;
      }
    }

    // Apply filters after search
    final int? min = minHarga.value;
    final int? max = maxHarga.value;
    final List<ProductModel> filteredByPrice;
    if (min == null && max == null) {
      filteredByPrice = base;
    } else {
      filteredByPrice = base.where((p) {
        final price = p.harga;
        if (min != null && price < min) return false;
        if (max != null && price > max) return false;
        return true;
      }).toList(growable: false);
    }

    if (filteredByPrice.length <= 1) return filteredByPrice;

    // Apply sorting after filtering
    final sorted = filteredByPrice.toList(growable: false);
    switch (sortOption.value) {
      case SortOption.terbaru:
        // keep original fetch order
        return sorted;
      case SortOption.namaAsc:
        sorted.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
        return sorted;
      case SortOption.namaDesc:
        sorted.sort((a, b) => b.nama.toLowerCase().compareTo(a.nama.toLowerCase()));
        return sorted;
      case SortOption.hargaAsc:
        sorted.sort((a, b) => a.harga.compareTo(b.harga));
        return sorted;
      case SortOption.hargaDesc:
        sorted.sort((a, b) => b.harga.compareTo(a.harga));
        return sorted;
    }
  }

  // Auto-complete suggestions
  List<String> get suggestions {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.length < 2) return const <String>[];

    final List<String> items;
    switch (searchScope.value) {
      case SearchScope.nama:
        items = produkList.map((p) => p.nama).toList(growable: false);
        break;
      case SearchScope.id:
        items = produkList.map((p) => p.id).toList(growable: false);
        break;
      case SearchScope.harga:
        items = produkList
            .map((p) => p.harga.round().toString())
            .toSet()
            .toList(growable: false);
        break;
    }

    final filtered = items
        .where((s) => s.toLowerCase().contains(q))
        .toSet()
        .toList(growable: false);
    filtered.sort((a, b) => a.length.compareTo(b.length));
    return filtered.take(6).toList(growable: false);
  }

  Future<void> runHttpComparison() async {
    try {
      await _apiService.fetchProductsHttp();
      await _apiService.fetchProductsDio();
      Get.snackbar(
        "Uji Performa",
        "Cek console untuk perbandingan Http vs Dio.",
      );
    } catch (_) {}
  }
}
