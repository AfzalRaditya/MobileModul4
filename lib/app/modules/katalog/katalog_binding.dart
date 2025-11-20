// lib/app/modules/katalog/katalog_binding.dart

import 'package:get/get.dart';
import 'katalog_controller.dart';
import '../../data/services/api_service.dart';
import '../keranjang/keranjang_controller.dart'; 

class KatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService()); 
    Get.lazyPut<KatalogController>(() => KatalogController());
    Get.put<KeranjangController>(KeranjangController()); 
  }
}