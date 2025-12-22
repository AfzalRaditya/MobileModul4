import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/local_storage_service.dart';

class AppThemeController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  late final Rx<ThemeMode> themeMode;

  @override
  void onInit() {
    super.onInit();
    themeMode = _localStorage.getThemeMode().obs;

    // Force to light/dark only for the Settings toggle UX.
    if (themeMode.value == ThemeMode.system) {
      themeMode.value = ThemeMode.light;
      _localStorage.setThemeMode(ThemeMode.light);
    }
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  Future<void> setDarkMode(bool enabled) async {
    final next = enabled ? ThemeMode.dark : ThemeMode.light;
    themeMode.value = next;
    await _localStorage.setThemeMode(next);
  }
}
