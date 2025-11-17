import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/cart_model.dart'; 
import '../../data/services/local_storage_service.dart';

class KeranjangController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  
  // BYPASS PROVIDER: Akses langsung ke instance global
  SupabaseClient get _supabaseClient => Supabase.instance.client;
  
  RxList<CartItemModel> itemsLokal = <CartItemModel>[].obs; 
  RxList<CartItemModel> itemsCloud = <CartItemModel>[].obs;
  
  String? get userId {
    try {
      return _supabaseClient.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }
  
  @override
  void onReady() {
    if (_localStorage.cartBox != null) {
      itemsLokal.assignAll(_localStorage.cartBox!.values); 
    }
    fetchCloudCart(); 
    super.onReady();
  }
  
  void addToLocalCart(CartItemModel item) {
    _localStorage.cartBox?.add(item); 
    itemsLokal.assignAll(_localStorage.cartBox!.values); 
    Get.snackbar("Lokal", "${item.productName} ditambahkan (Hive)");
  }

  Future<void> fetchCloudCart() async {
    final currentUserId = userId;
    
    if (currentUserId == null) {
      debugPrint("Pengguna belum login. Melewati sinkronisasi cloud.");
      itemsCloud.clear();
      return;
    }
    
    try {
      final List<Map<String, dynamic>> rawData = await _supabaseClient 
          .from('carts') 
          .select()
          .eq('user_id', currentUserId); 

      itemsCloud.assignAll(rawData.map((e) => CartItemModel(
        productId: e['product_id'], 
        productName: e['product_name'], 
        price: (e['price'] as num).toDouble(), 
        quantity: e['quantity']
      )).toList());
      
      debugPrint("Sinkronisasi Cloud BERHASIL.");
      
    } catch (e) {
      debugPrint("Gagal sinkronisasi cloud: $e");
    }
  }

  Future<void> syncLocalToCloud() async {
    final currentUserId = userId;

    if (currentUserId == null) {
      Get.snackbar("Error", "Login diperlukan untuk sinkronisasi cloud.");
      return;
    }
    
    final data = itemsLokal.map((item) => item.toMap()..['user_id'] = currentUserId).toList();
    
    try {
      await _supabaseClient.from('carts').upsert(data);
      
      fetchCloudCart();
      Get.snackbar("Sukses", "Keranjang berhasil disinkronkan ke Cloud!");
      
    } catch (e) {
      debugPrint("Error saat menulis ke Supabase: $e");
    }
  }
}