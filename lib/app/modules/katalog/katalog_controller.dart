import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_model.dart'; 
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart'; 
import '../../data/providers/supabase_provider.dart'; 

class KatalogController extends GetxController {
  // 1. Ambil Service & Provider
  final ApiService _apiService = Get.find<ApiService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  final SupabaseProvider _supabaseProvider = Get.find<SupabaseProvider>();
  
  // State UI
  final RxBool isLoading = true.obs;
  final RxList<ProductModel> produkList = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Panggil fungsi ini saat halaman dibuka
    fetchKatalogData();
  }

  // --- FUNGSI FETCH DATA DARI SUPABASE (Membuat import terpakai) ---
  Future<void> fetchKatalogData() async {
    try {
      isLoading.value = true;
      
      // Ambil client dari Provider
      final client = _supabaseProvider.client.value;
      
      // Cek apakah client siap
      if (client == null) {
        // Jika null, coba inisialisasi ulang atau lempar error
        throw Exception("Supabase Client belum siap. Cek main.dart.");
      }

      // QUERY KE TABEL 'products'
      // Pastikan Anda sudah membuat tabel 'products' di dashboard Supabase
      final response = await client
          .from('products') // Nama tabel
          .select();        // Ambil semua data
      
      // Mapping data dari JSON Supabase ke ProductModel
      final List<ProductModel> products = (response as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Masukkan ke list untuk ditampilkan di UI
      produkList.assignAll(products);
      
    } catch (e) {
      debugPrint("Error fetching data from Supabase: $e"); 
      // Tampilkan snackbar jika error, tapi jangan memblokir aplikasi
      Get.snackbar("Info", "Gagal memuat data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Fungsi Tambah ke Keranjang (Hive - Modul 4) ---
  void addToCart(ProductModel produk) {
    final newItem = CartItemModel(
        productId: produk.id,
        productName: produk.nama,
        price: produk.harga,
        quantity: 1, 
    );
    // Simpan ke Hive
    _localStorage.cartBox?.add(newItem);
    
    Get.snackbar(
      "Sukses", 
      "${produk.nama} masuk keranjang lokal!",
      snackPosition: SnackPosition.BOTTOM
    );
  }

  // --- Fitur Perbandingan (Modul 3 - Opsional) ---
  Future<void> runHttpComparison() async {
    try {
      await _apiService.fetchProductsHttp();
      await _apiService.fetchProductsDio();
      Get.snackbar("Info", "Cek console untuk hasil uji performa.");
    } catch (e) {
      debugPrint("Error comparison: $e");
    }
  }
}