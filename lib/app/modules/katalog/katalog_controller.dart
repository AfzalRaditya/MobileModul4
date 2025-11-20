// lib/app/modules/katalog/katalog_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart'; 
import '../../data/models/product_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart'; 


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
      Get.snackbar("Uji Performa", "Cek console untuk perbandingan Http vs Dio.");
    } catch (_) {
    }
  }
}