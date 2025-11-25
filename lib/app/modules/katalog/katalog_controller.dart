// lib/app/modules/katalog/katalog_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
// Tambahkan import Supabase Provider
import '../../data/providers/supabase_provider.dart';

class KatalogController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final RxBool isLoading = true.obs;
  final RxList<ProductModel> produkList = <ProductModel>[].obs;

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
      final products = await _apiService.fetchProductsDio();
      produkList.assignAll(products);
    } catch (e) {
      debugPrint("Error fetching data: $e");
      Get.snackbar("Error", "Gagal memuat katalog.");
    } finally {
      isLoading.value = false;
    }
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
