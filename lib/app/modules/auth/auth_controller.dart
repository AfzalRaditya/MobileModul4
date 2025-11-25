// lib/app/modules/auth/auth_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../data/providers/supabase_provider.dart';
import '../../data/services/local_storage_service.dart'; // Import service lokal
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

  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    try {
      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (response.session != null) {
        // --- SIMPAN SESSION LOKAL ---
        // Kita simpan access token dari Supabase ke Shared Preferences
        await _localStorage.saveSession(response.session!.accessToken);

        Get.offAllNamed("/katalog");
        Get.snackbar(
          "Sukses!",
          "Login berhasil. User ID: ${response.user?.id ?? 'ID tidak ditemukan'}",
        );
        _updateLoginStatus();
      } else {
        throw Exception("Gagal mendapatkan sesi.");
      }
    } on AuthException catch (e) {
      debugPrint("Auth Error: ${e.message}");
      Get.snackbar("Error Login", e.message);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

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
