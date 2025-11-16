// lib/app/modules/katalog/katalog_controller.dart
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // Import ini dibutuhkan untuk debugPrint
import '../../data/models/product_model.dart';
import '../../data/services/api_service.dart';

class KatalogController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxBool isLoading = true.obs;
  final RxList<ProductModel> produkList = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKatalogData();
  }

  Future<void> fetchKatalogData() async {
    try {
      isLoading.value = true;
      
      final products = await _apiService.fetchProductsDio(); 
      produkList.assignAll(products);
      
    } catch (e) {
      // Mengganti print() dengan debugPrint() untuk debugging yang lebih bersih
      debugPrint("Error fetching data: $e"); 
      Get.snackbar("Error", "Gagal memuat katalog. Cek koneksi.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> runHttpComparison() async {
    try {
      await _apiService.fetchProductsHttp();
      await _apiService.fetchProductsDio();
      Get.snackbar("Uji Performa", "Cek console untuk perbandingan Http vs Dio.");
    } catch (e) {
      // Mengganti print() dengan debugPrint() jika ada error pada perbandingan
      debugPrint("Error running comparison: $e");
    }
  }
}