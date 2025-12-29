// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/local_storage_service.dart';
import 'app/data/providers/supabase_provider.dart';
import 'app/modules/katalog/katalog_binding.dart';
import 'app/modules/katalog/katalog_view.dart';
import 'app/modules/keranjang/keranjang_binding.dart';
import 'app/modules/keranjang/keranjang_view.dart';
import 'app/modules/auth/auth_binding.dart';
import 'app/modules/auth/auth_view.dart';
// --- 1. IMPORT REGISTER VIEW (Ditambahkan) ---
import 'app/modules/auth/register_view.dart';
import 'firebase_messaging_background.dart';
// Additional views to match new UI flows
import 'app/modules/checkout/checkout_view.dart';
import 'app/modules/profile/profile_view.dart';
import 'app/modules/checkout/order_confirmed_view.dart';
import 'app/modules/orders/orders_view.dart';
import 'app/modules/orders/orders_binding.dart';
import 'app/modules/location/views/location_picker_view.dart';
import 'app/shared/app_theme_controller.dart';
import 'app/modules/settings/settings_view.dart';
import 'app/modules/settings/saved_addresses_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Daftarkan handler background SEBELUM Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Initialize Firebase (requires google-services.json / GoogleService-Info.plist)
  await Firebase.initializeApp();

  // Initialize notification service (FCM + local notifications)
  await NotificationService().init();

  // Init locale data for intl (date/number formatting)
  await initializeDateFormatting('id_ID', null);

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

  // Theme controller (reactive theme switching via Settings)
  Get.put(AppThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil service untuk cek theme & status login
    final LocalStorageService localStorage = Get.find<LocalStorageService>();
    final theme = Get.find<AppThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: "Muktijaya1 - Packaging Kardus",
        debugShowCheckedModeBanner: false,

        themeMode: theme.themeMode.value,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1ABC9C), // Teal color from logo
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF16A085), // Darker teal for dark mode
            brightness: Brightness.dark,
          ),
        ),

        // --- LOGIC SESSION DISINI ---
        // Jika isLoggedIn() true -> Masuk ke Katalog (Home)
        // Jika false -> Masuk ke Login
        initialRoute: localStorage.isLoggedIn() ? "/katalog" : "/login",

        // ----------------------------
        getPages: [
          GetPage(
            name: "/login",
            page: () => const AuthView(),
            binding: AuthBinding(),
          ),

          // --- 2. ROUTE REGISTER (Ditambahkan) ---
          GetPage(
            name: "/register",
            page: () => const RegisterView(),
            binding: AuthBinding(), // Tetap pakai AuthBinding
          ),

          GetPage(
            name: "/katalog",
            page: () => const KatalogView(),
            binding: KatalogBinding(),
          ),

          GetPage(
            name: "/orders",
            page: () => const OrdersView(),
            binding: OrdersBinding(),
          ),

          GetPage(
            name: "/keranjang",
            page: () => const KeranjangView(),
            binding: KeranjangBinding(),
          ),
          // Checkout view (new)
          GetPage(
            name: "/checkout",
            page: () => const CheckoutView(),
            // reuse KeranjangBinding if needed or none
          ),
          // Profile view (new)
          GetPage(
            name: "/profile",
            page: () => const ProfileView(),
            // can reuse AuthBinding to access auth controller if needed
            binding: AuthBinding(),
          ),

          GetPage(
            name: "/settings",
            page: () => const SettingsView(),
          ),
          GetPage(
            name: "/saved-addresses",
            page: () => const SavedAddressesView(),
          ),

          GetPage(
            name: "/location-picker",
            page: () => const LocationPickerView(),
          ),
          // Order confirmed view (new)
          GetPage(
            name: "/order-confirmed",
            page: () => const OrderConfirmedView(),
          ),
        ],
      ),
    );
  }
}
