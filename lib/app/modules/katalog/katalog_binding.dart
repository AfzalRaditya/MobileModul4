// lib/app/modules/katalog/katalog_binding.dart
import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import 'katalog_controller.dart';

class KatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService()); // Inject Service
    Get.put<KatalogController>(KatalogController());
  }
}