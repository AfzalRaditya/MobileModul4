// lib/app/modules/keranjang/keranjang_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/cart_model.dart'; 
import '../../data/services/local_storage_service.dart';
import '../../data/models/product_model.dart'; 

class KeranjangController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  
  SupabaseClient get _supabaseClient => Supabase.instance.client;
  
  RxList<CartItemModel> itemsLokal = <CartItemModel>[].obs; 
  RxList<CartItemModel> itemsCloud = <CartItemModel>[].obs;
  
  final String dummyUserId = 'dummy_user_id'; 
  
  String? get currentUserId {
    try {
      return _supabaseClient.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  String get userIdentifier => currentUserId ?? dummyUserId;
  double get totalHarga => itemsLokal.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  
  // =========================================================
  // HELPER: SINKRONISASI HIVE YANG AMAN
  // =========================================================
  void _syncHiveSafely() {
    if (_localStorage.cartBox == null) {
      debugPrint("Error: Hive Box belum terbuka.");
      return;
    }
    
    try {
      final box = _localStorage.cartBox!; 
      
      box.clear(); 
      box.addAll(itemsLokal);
      itemsLokal.refresh();

    } catch (e) {
      debugPrint("FATAL HIVE SYNC ERROR: $e");
      Get.snackbar("Error Data", "Kesalahan penulisan data lokal. Mohon restart aplikasi.");
    }
  }
  
  // =========================================================
  // R: READ & INITIALIZATION
  // =========================================================
  
  @override
  void onReady() {
    if (_localStorage.cartBox?.isOpen == true) { 
      itemsLokal.assignAll(_localStorage.cartBox!.values); 
    }
    fetchCloudCart(); 
    super.onReady();
  }
  
  Future<void> fetchCloudCart() async {
    final userIdentifier = currentUserId ?? dummyUserId; 
    
    if (userIdentifier == dummyUserId) { 
      debugPrint("Pengguna belum login. Melewati sinkronisasi cloud.");
      itemsCloud.clear();
      return;
    }
    
    try {
      final List<Map<String, dynamic>> rawData = await _supabaseClient 
          .from('carts') 
          .select()
          .eq('user_id', userIdentifier); 

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
      itemsLokal.add(newItem); 
      
      _syncHiveSafely(); 
      
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
      
      _syncHiveSafely(); 
      debugPrint("Hive Updated: $productId quantity to $newQuantity");
    }
  }

  // =========================================================
  // D: DELETE (Menghapus Item - Lokal & Cloud)
  // =========================================================
  
  void deleteLocalItem(String productId) {
    itemsLokal.removeWhere((item) => item.productId == productId);
    
    _syncHiveSafely(); 
    debugPrint("Hive Deleted: $productId");
  }

  Future<void> deleteCloudItem(String productId) async {
    final userIdentifier = currentUserId ?? dummyUserId;
    
    if (userIdentifier == dummyUserId) {
        Get.snackbar("Error", "Tidak bisa menghapus data Cloud tanpa autentikasi.");
        return;
    }

    try {
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