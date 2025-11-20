// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/services/local_storage_service.dart';
import 'app/data/providers/supabase_provider.dart';
import 'app/modules/katalog/katalog_binding.dart';
import 'app/modules/katalog/katalog_view.dart';
import 'app/modules/keranjang/keranjang_binding.dart';
import 'app/modules/keranjang/keranjang_view.dart';
import 'app/modules/auth/auth_binding.dart';
import 'app/modules/auth/auth_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ---------------------------------------------------------
  // 1. INISIALISASI SERVICE (DATABASE & LOCAL STORAGE)
  // ---------------------------------------------------------

  await Get.putAsync<LocalStorageService>(() async { 
    final service = LocalStorageService();
    await service.init(); 
    return service;
  });

  await Get.putAsync<SupabaseProvider>(() async {
    final provider = SupabaseProvider();
    await provider.init(); 
    return provider;
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    final LocalStorageService localStorage = Get.find<LocalStorageService>();
    
    return GetMaterialApp(
      title: "Muktijaya1 - Packaging Kardus",
      debugShowCheckedModeBanner: false,
    
      themeMode: localStorage.getThemeMode(), 
      theme: ThemeData(
        primarySwatch: Colors.brown, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown, 
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark(), 
      
      initialRoute: "/login", 
      
      getPages: [

        GetPage(
          name: "/login", 
          page: () => const AuthView(),
          binding: AuthBinding(),
        ),
        
        GetPage(
          name: "/katalog",
          page: () => const KatalogView(),
          binding: KatalogBinding(),
        ),
        
        GetPage(
          name: "/keranjang",
          page: () => const KeranjangView(),
          binding: KeranjangBinding(),
        ),
      ],
    );
  }
}