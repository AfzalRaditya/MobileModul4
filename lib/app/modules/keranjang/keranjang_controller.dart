// lib/app/modules/keranjang/keranjang_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/cart_model.dart'; 
import '../../data/services/local_storage_service.dart';
import '../../data/models/product_model.dart'; 

class KeranjangController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  
  // Akses langsung ke instance global Supabase
  SupabaseClient get _supabaseClient => Supabase.instance.client;
  
  // State Lokal (Hive)
  RxList<CartItemModel> itemsLokal = <CartItemModel>[].obs; 
  // State Cloud (Supabase) - Menggambarkan hasil sinkronisasi terakhir
  RxList<CartItemModel> itemsCloud = <CartItemModel>[].obs;
  
  // Variabel dummy (untuk non-auth user)
  final String dummyUserId = 'dummy_user_id'; 
  
  // Mendapatkan ID Pengguna yang sedang login (currentUserId)
  String? get currentUserId {
    try {
      return _supabaseClient.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  // Getter yang digunakan di logika bisnis (fallback ke dummy ID)
  String get userIdentifier => currentUserId ?? dummyUserId;

  // Menghitung Total Harga Lokal
  double get totalHarga => itemsLokal.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  
  // =========================================================
  // R: READ & INITIALIZATION
  // =========================================================
  
  @override
  void onReady() {
    // Memastikan cartBox sudah tersedia sebelum diakses
    if (_localStorage.cartBox?.isOpen == true) { 
      itemsLokal.assignAll(_localStorage.cartBox!.values); 
    }
    fetchCloudCart(); 
    super.onReady();
  }
  
  // Read Cloud Cart (R)
  Future<void> fetchCloudCart() async {
    final userIdentifier = currentUserId ?? dummyUserId; 
    
    if (userIdentifier == dummyUserId) { // Jika masih menggunakan dummy ID
      debugPrint("Pengguna belum login. Melewati sinkronisasi cloud.");
      itemsCloud.clear();
      return;
    }
    
    try {
      final List<Map<String, dynamic>> rawData = await _supabaseClient 
          .from('carts') // Nama tabel di Supabase
          .select()
          .eq('user_id', userIdentifier); 

      // Mapping data mentah ke CartItemModel
      itemsCloud.assignAll(rawData.map((e) => CartItemModel(
        productId: e['product_id'] as String? ?? 'n/a', 
        productName: e['product_name'] as String? ?? 'n/a', 
        price: (e['price'] as num).toDouble(), 
        quantity: e['quantity'] as int,
      )).toList());
      
      debugPrint("Sinkronisasi Cloud BERHASIL.");
      
    } on PostgrestException catch (e) {
       debugPrint("Gagal sinkronisasi cloud: ${e.message}");
    } catch (e) {
       debugPrint("Gagal sinkronisasi cloud (umum): $e");
    }
  }

  // =========================================================
  // C: CREATE (Add to Cart - Lokal)
  // =========================================================

  void addToLocalCart(ProductModel produk) {
    int index = itemsLokal.indexWhere((item) => item.productId == produk.id);
    
    if (index >= 0) {
      updateLocalQuantity(itemsLokal[index].productId, itemsLokal[index].quantity + 1);
    } else {
      final newItem = CartItemModel(
        productId: produk.id,
        productName: produk.nama,
        price: produk.harga,
        quantity: 1,
      );
      _localStorage.cartBox?.add(newItem); 
      
      itemsLokal.assignAll(_localStorage.cartBox?.values ?? []);
      Get.snackbar("Lokal", "${produk.nama} ditambahkan (Hive)");
    }
  }

  // =========================================================
  // U: UPDATE (Mengubah Kuantitas - Lokal)
  // =========================================================
  
  void updateLocalQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      deleteLocalItem(productId);
      return;
    }
    
    int index = itemsLokal.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      itemsLokal[index].quantity = newQuantity;
      
      _localStorage.cartBox?.clear(); 
      _localStorage.cartBox?.addAll(itemsLokal); 
      itemsLokal.refresh(); 
      debugPrint("Hive Updated: $productId quantity to $newQuantity");
    }
  }

  // =========================================================
  // D: DELETE (Menghapus Item - Lokal & Cloud)
  // =========================================================
  
  void deleteLocalItem(String productId) {
    itemsLokal.removeWhere((item) => item.productId == productId);
    
    _localStorage.cartBox?.clear(); 
    _localStorage.cartBox?.addAll(itemsLokal); 
    itemsLokal.refresh(); 
    debugPrint("Hive Deleted: $productId");
  }

  // DELETE CLOUD (Wajib CRUD Supabase)
  Future<void> deleteCloudItem(String productId) async {
    final userIdentifier = currentUserId ?? dummyUserId;
    
    // Jika user belum login dan masih dummy, jangan hapus.
    if (userIdentifier == dummyUserId) {
        Get.snackbar("Error", "Tidak bisa menghapus data Cloud tanpa autentikasi.");
        return;
    }

    try {
      // DELETE: Menghapus item dari keranjang di Supabase
      await _supabaseClient
          .from('carts') 
          .delete()
          .eq('user_id', userIdentifier)
          .eq('product_id', productId); 

      fetchCloudCart();
      Get.snackbar("Sukses!", "Item $productId dihapus dari Cloud.");
      
    } on PostgrestException catch (e) {
      debugPrint("Delete Cloud Error: ${e.message}");
      Get.snackbar("Error Cloud Delete", "Gagal menghapus item dari Cloud.");
    }
  }

  // =========================================================
  // SYNC: Upsert (C/U) ke Cloud (Uji Multi-Device)
  // =========================================================
  
  Future<void> syncLocalToCloud() async {
    final userIdentifier = currentUserId ?? dummyUserId;

    if (userIdentifier == dummyUserId) {
      Get.snackbar("Error", "Login diperlukan untuk sinkronisasi cloud.");
      return;
    }
    
    final data = itemsLokal.map((item) => item.toMap()..['user_id'] = userIdentifier).toList();
    
    try {
      // Supabase UPSERT
      await _supabaseClient.from('carts').upsert(data, onConflict: 'user_id, product_id'); 
      
      fetchCloudCart();
      Get.snackbar("Sukses", "Keranjang berhasil disinkronkan ke Cloud!");
      
    } on PostgrestException catch (e) {
      debugPrint("Error saat menulis ke Supabase: ${e.message}");
      Get.snackbar("Error Sinkronisasi", "Pastikan kunci 'user_id' dan 'product_id' di tabel 'carts' adalah kunci unik.");
    } catch (e) {
      debugPrint("Error umum saat sinkronisasi: $e");
    }
  }
}