import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- Import Layanan (Services & Providers) ---
import 'app/data/services/local_storage_service.dart';
import 'app/data/providers/supabase_provider.dart';

// --- Import Modul Aplikasi ---
import 'app/modules/katalog/katalog_binding.dart';
import 'app/modules/katalog/katalog_view.dart';
import 'app/modules/keranjang/keranjang_binding.dart';
import 'app/modules/keranjang/keranjang_view.dart';
import 'app/modules/auth/auth_binding.dart';
import 'app/modules/auth/auth_view.dart';

Future<void> main() async {
  // Wajib: Pastikan binding Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  
  // ---------------------------------------------------------
  // 1. INISIALISASI SERVICE (DATABASE & LOCAL STORAGE)
  // Menggunakan Get.putAsync dengan logika 'await' yang ketat
  // ---------------------------------------------------------

  // Init Local Storage (Hive & SharedPrefs)
  await Get.putAsync(() async {
    final service = LocalStorageService();
    await service.init(); // Tunggu sampai Hive Box terbuka
    return service;
  });

  // Init Supabase (Cloud)
  await Get.putAsync(() async {
    final provider = SupabaseProvider();
    await provider.init(); // Tunggu sampai koneksi Supabase stabil
    return provider;
  });
  
  // Setelah semua service siap, jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    // Ambil instance service untuk pengaturan tema
    final LocalStorageService localStorage = Get.find<LocalStorageService>();
    
    return GetMaterialApp(
      title: "Muktijaya1 - Packaging Kardus",
      debugShowCheckedModeBanner: false,
      
      // Pengaturan Tema (diambil dari Shared Preferences)
      themeMode: localStorage.getThemeMode(), 
      theme: ThemeData(
        primarySwatch: Colors.brown, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown, 
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark(), 
      
      // Rute Awal: Login (Agar User ID tersedia untuk Supabase)
      initialRoute: "/login", 
      
      // Daftar Halaman (Routes)
      getPages: [
        // Halaman Login
        GetPage(
          name: "/login", 
          page: () => const AuthView(),
          binding: AuthBinding(),
        ),
        // Halaman Katalog Produk
        GetPage(
          name: "/katalog",
          page: () => const KatalogView(),
          binding: KatalogBinding(),
        ),
        // Halaman Keranjang & Sinkronisasi
        GetPage(
          name: "/keranjang",
          page: () => const KeranjangView(),
          binding: KeranjangBinding(),
        ),
      ],
    );
  }
}