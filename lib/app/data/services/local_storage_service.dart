// lib/app/data/services/local_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart'; 
import '../models/cart_model.dart'; 


class LocalStorageService {
  SharedPreferences? prefs; 
  Box<CartItemModel>? cartBox; 
  
  static const String kThemeKey = 'app_theme';

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) { 
        Hive.registerAdapter(CartItemModelAdapter()); 
    }

    cartBox = await Hive.openBox<CartItemModel>('cartBox'); 
  }

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