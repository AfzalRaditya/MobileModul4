import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/katalog/katalog_view.dart';
import 'app/modules/katalog/katalog_binding.dart';

// Hindari menumpuk seluruh logika di main.dart (Wajib Modul 3)
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Wajib tambahkan key parameter untuk praktik terbaik Flutter
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Muktijaya1 - Packaging Kardus",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
      ),
      
      // Definisikan rute dan binding awal
      initialRoute: "/katalog",
      getPages: [
        GetPage(
          name: "/katalog",
          page: () => KatalogView(),
          binding: KatalogBinding(),
        ),
      ],
      // Di sini nanti kita akan tambahkan Modul 4 (misalnya, tema dari shared_preferences)
    );
  }
}