// lib/app/modules/keranjang/keranjang_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'keranjang_controller.dart';

class KeranjangView extends GetView<KeranjangController> {
  const KeranjangView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang & Sinkronisasi CRUD'),
      ),
      body: Column(
        children: [
          // Bagian Scrollable (Data List)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // =========================================================
                  // 1. DATA LOKAL (HIVE) - CRUD IMPLEMENTATION
                  // =========================================================
                  const Text('🛒 Data Lokal (Hive) - Keranjang Aktif (CRUD)', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  
                  // List Keranjang Lokal (menggunakan ListTile interaktif)
                  ...controller.itemsLokal.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.productName),
                    subtitle: Text('Rp ${item.price.toStringAsFixed(0)}'),
                    
                    // UI CRUD: Update Quantity (+/-) & Delete
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hapus / Kurangi Kuantitas
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
                          onPressed: () => controller.updateLocalQuantity(item.productId, item.quantity - 1), 
                        ),
                        // Tampilkan Kuantitas
                        SizedBox(width: 24, child: Text('${item.quantity}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                        // Tambah Kuantitas
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.green),
                          onPressed: () => controller.updateLocalQuantity(item.productId, item.quantity + 1),
                        ),
                        // Tombol Delete Langsung
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => controller.deleteLocalItem(item.productId),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 10),
                  const Divider(thickness: 2),
                  // Tampilkan Total Harga Lokal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TOTAL LOKAL:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Rp ${controller.totalHarga.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  // =========================================================
                  // 2. DATA CLOUD (SUPABASE) - READ & DELETE
                  // =========================================================
                  const Text('☁️ Data Cloud (Supabase) - Hasil Sinkron', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),

                  // List Keranjang Cloud (Hasil Sinkronisasi Terakhir)
                  ...controller.itemsCloud.map((item) => ListTile(
                    title: Text(item.productName),
                    subtitle: Text('Kuantitas: ${item.quantity} | Total: Rp ${(item.price * item.quantity).toStringAsFixed(0)}'),
                    
                    // Delete dari Cloud
                    trailing: IconButton(
                      icon: const Icon(Icons.cloud_off, color: Colors.blueGrey),
                      onPressed: () => controller.deleteCloudItem(item.productId), 
                    ),
                  )),
                ],
              )),
            ),
          ),
          
          // Bagian Tombol Aksi (Sinkronisasi)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
            ),
            child: Column(
              children: [
                // Tombol Sinkronisasi (Wajib Modul 4)
                ElevatedButton(
                  onPressed: controller.syncLocalToCloud,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('➡️ SINKRONKAN LOKAL KE CLOUD (UPSERT)'),
                ),
                const SizedBox(height: 10),
                // Tombol untuk Memuat Ulang Data Cloud
                ElevatedButton.icon(
                  onPressed: controller.fetchCloudCart,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat Ulang Data Cloud'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40), foregroundColor: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}