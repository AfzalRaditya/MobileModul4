// lib/app/data/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart'; 
import '../models/cart_model.dart'; 

class LocalStorageService {
  // FIX: Hapus 'late' dan jadikan Nullable (diinisialisasi dengan null secara implisit)
  SharedPreferences? prefs; 
  Box<CartItemModel>? cartBox; // FIX: Hapus 'late' dan jadikan nullable
  
  static const String kThemeKey = 'app_theme';

  Future<void> init() async {
    // Inisialisasi prefs
    prefs = await SharedPreferences.getInstance();
    
    // Inisialisasi Hive
    await Hive.initFlutter();
    Hive.registerAdapter(CartItemModelAdapter()); 
    // cartBox diinisialisasi
    cartBox = await Hive.openBox<CartItemModel>('cartBox'); 
  }

  // getThemeMode dan setThemeMode menggunakan ?. untuk null safety
  ThemeMode getThemeMode() {
    final themeIndex = prefs?.getInt(kThemeKey); 
    if (themeIndex == 1) {
      return ThemeMode.light;
    }
    if (themeIndex == 2) {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    int index;
    if (mode == ThemeMode.light) {
      index = 1;
    }
    else if (mode == ThemeMode.dark) {
      index = 2;
    }
    else {
      index = 0;
    }
    await prefs?.setInt(kThemeKey, index); 
  }
}