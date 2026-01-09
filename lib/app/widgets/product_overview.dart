// lib/app/widgets/product_overview.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../data/models/product_model.dart';
import '../data/providers/supabase_provider.dart';

/// Format angka ke Rupiah (tanpa desimal)
String formatRupiah(double value) {
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatter.format(value);
}

/// Tampilkan Product Detail Overview sebagai modal bottom sheet.
Future<void> showProductOverview(BuildContext context, ProductModel product) async {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  Future<Map<String, dynamic>?> _fetchDetailsFromSupabase() async {
    try {
      if (!Get.isRegistered<SupabaseProvider>()) return null;
      final supabaseClient = Get.find<SupabaseProvider>().client.value;
      if (supabaseClient == null) return null;

      final res = await supabaseClient
          .from('products')
          .select('stock, description')
          .eq('id', product.id)
          .maybeSingle();
      if (res == null) return null;
      return Map<String, dynamic>.from(res as Map);
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      return null;
    }
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final maxHeight = MediaQuery.of(ctx).size.height * 0.85;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: _fetchDetailsFromSupabase(),
            builder: (context, snap) {
              int? stock;
              String? description;

              if (snap.hasData && snap.data != null) {
                final data = snap.data!;
                final rawStock = data['stock'];
                if (rawStock != null) {
                  if (rawStock is num) stock = rawStock.toInt();
                  else stock = int.tryParse(rawStock.toString());
                }
                description = data['description']?.toString();
              }

              final priceText = formatRupiah(product.harga);

              Color stockColor = Colors.grey;
              String stockLabel = '-';
              if (stock != null) {
                if (stock <= 0) {
                  stockColor = Colors.red.shade700;
                  stockLabel = 'Habis';
                } else if (stock < 5) {
                  stockColor = Colors.orange.shade800;
                  stockLabel = 'Sedikit ($stock)';
                } else {
                  stockColor = scheme.primary;
                  stockLabel = 'Tersedia ($stock)';
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, st) => Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              loadingBuilder: (c, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.nama,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onBackground,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    priceText,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: scheme.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: stockColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    stockLabel,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'Deskripsi Produk',
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),

                        if (snap.connectionState == ConnectionState.waiting)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator(color: scheme.primary)),
                          )
                        else
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                (description != null && description.trim().isNotEmpty)
                  ? description
                                    : 'Tidak ada deskripsi tersedia untuk produk ini.',
                                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: scheme.primary,
                                  side: BorderSide(color: scheme.primary.withOpacity(0.12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Tutup'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.add_shopping_cart_outlined),
                                label: const Text('Tambah ke Keranjang'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
