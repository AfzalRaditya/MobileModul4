// lib/app/modules/katalog/product_card.dart

import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../shared/formatters.dart';

// =========================================================
// WIDGET: ProductCard (Widget Utama Kartu)
// =========================================================

class ProductCard extends StatelessWidget {
  final ProductModel produk;
  final VoidCallback onBuy; 
  
  const ProductCard({required this.produk, required this.onBuy, super.key}); 

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onBuy,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Image.network(
                produk.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: scheme.onSurfaceVariant,
                    size: 48,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatIdr(produk.harga),
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton.filled(
                            onPressed: onBuy,
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            tooltip: 'Tambah ke keranjang',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}