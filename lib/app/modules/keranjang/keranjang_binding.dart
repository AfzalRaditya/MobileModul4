// lib/app/modules/keranjang/keranjang_binding.dart
import 'package:get/get.dart';
import 'keranjang_controller.dart';

class KeranjangBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeranjangController>(
      () => KeranjangController(),
    );
  }
}