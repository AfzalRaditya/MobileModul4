// lib/app/modules/auth/auth_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/providers/supabase_provider.dart';
import '../../data/services/local_storage_service.dart'; // Import service lokal
import '../../data/services/notification_service.dart';
import '../keranjang/keranjang_controller.dart';

class AuthController extends GetxController {
  final SupabaseProvider _supabaseProvider = Get.find<SupabaseProvider>();
  // Ambil instance LocalStorageService
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  SupabaseClient get _supabaseClient {
    if (_supabaseProvider.client.value == null) {
      throw Exception("Supabase Client belum siap.");
    }
    return _supabaseProvider.client.value!;
  }

  RxBool isLoading = false.obs;

  final RxBool _isLoggedInRx = false.obs;
  bool get isLoggedIn => _isLoggedInRx.value;

  @override
  void onInit() {
    super.onInit();
    _updateLoginStatus();

    _supabaseProvider.client.value?.auth.onAuthStateChange.listen((data) {
      _updateLoginStatus();
    });
  }

  void _updateLoginStatus() {
    _isLoggedInRx.value = _supabaseClient.auth.currentUser != null;

    if (Get.isRegistered<KeranjangController>()) {
      Get.find<KeranjangController>().fetchCloudCart();
    }
  }

  // --- FUNGSI LOGIN ---
  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    try {
      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (response.session != null) {
        // --- SIMPAN SESSION LOKAL ---
        await _localStorage.saveSession(response.session!.accessToken);

        // Tampilkan popup notifikasi dengan suara kustom
        await NotificationService().showLocal(
          title: 'Login Berhasil',
          body:
              'Selamat datang, ${response.user?.email ?? 'pengguna'}! Pesanan siap dibantu.',
          data: {'route': '/katalog', 'arguments': null},
        );

        // Delay agar suara notifikasi sempat keluar sebelum navigasi
        await Future.delayed(const Duration(milliseconds: 800));

        Get.offAllNamed("/katalog");
        Get.snackbar(
          "Sukses!",
          "Login berhasil",
        );
        _updateLoginStatus();
      } else {
        throw Exception("Gagal mendapatkan sesi.");
      }
    } on AuthException catch (e) {
      debugPrint("Auth Error: ${e.message}");
      // Tampilkan snackbar dengan pesan "Email atau password salah"
      Get.snackbar(
        "Error Login",
        "Email atau password salah",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI REGISTER (DITAMBAHKAN) ---
  Future<void> signUp(String email, String password) async {
    isLoading.value = true;
    try {
      // Kirim data pendaftaran ke Supabase
      await _supabaseClient.auth.signUp(email: email, password: password);

      // Jika berhasil, beri notifikasi dan arahkan ke login
      Get.snackbar("Berhasil Daftar", "Akun berhasil dibuat. Silakan Login.");

      // Balik ke halaman Login
      Get.offNamed("/login");
    } on AuthException catch (e) {
      Get.snackbar("Gagal Daftar", e.message);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _supabaseClient.auth.signOut();

      // --- HAPUS SESSION LOKAL ---
      await _localStorage.removeSession();

      Get.offAllNamed("/login");
      _updateLoginStatus();
    } catch (e) {
      Get.snackbar("Error Logout", "Gagal Logout: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
