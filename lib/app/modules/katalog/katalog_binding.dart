// lib/app/modules/katalog/katalog_binding.dart
import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../auth/auth_controller.dart'; // Wajib: Import AuthController
import 'katalog_controller.dart';

class KatalogBinding extends Bindings {
  @override
  void dependencies() {
    // Inject API Service
    Get.lazyPut<ApiService>(() => ApiService()); 
    
    // Inject LocalStorageService
    Get.lazyPut<LocalStorageService>(() => Get.find<LocalStorageService>());

    // FIX KRITIS: Inject AuthController di sini
    // Membuat AuthController tersedia di KatalogView
    Get.lazyPut<AuthController>(() => AuthController()); 
    
    // Inject Katalog Controller
    Get.lazyPut<KatalogController>(
      () => KatalogController(),
    );
  }
}