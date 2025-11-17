// lib/app/modules/keranjang/keranjang_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'keranjang_controller.dart';

class KeranjangView extends GetView<KeranjangController> {
  const KeranjangView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang & Sinkronisasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Implementasi Hive (Lokal)
            const Text('Data Lokal (Hive):', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Column(
                  children: controller.itemsLokal.map((item) => Text('${item.productName} x${item.quantity}')).toList(),
                )),
            
            const Divider(),

            // Implementasi Supabase (Cloud)
            const Text('Data Cloud (Supabase):', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Column(
                  children: controller.itemsCloud.map((item) => Text('${item.productName} x${item.quantity}')).toList(),
                )),

            const SizedBox(height: 20),

            // Tombol untuk Eksperimen Sinkronisasi
            ElevatedButton(
              onPressed: controller.syncLocalToCloud,
              child: const Text('Sinkronisasi ke Cloud (Uji Multi-Device)'),
            ),
          ],
        ),
      ),
    );
  }
}