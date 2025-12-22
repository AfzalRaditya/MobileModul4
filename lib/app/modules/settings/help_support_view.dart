import 'package:flutter/material.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Panduan Singkat'),
              subtitle: Text(
                'Jika ada kendala, cek langkah berikut.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _FaqCard(
            title: 'Cara pemesanan',
            body:
                'Pilih produk di Katalog → buka Keranjang → Checkout → isi alamat → Place Order.',
          ),
          const _FaqCard(
            title: 'Alamat pengiriman',
            body:
                'Di halaman Checkout, gunakan “Use My Location” atau “Atur di Map” untuk mengisi alamat.',
          ),
          const _FaqCard(
            title: 'Butuh bantuan?',
            body:
                'Silakan hubungi admin/toko melalui kontak yang tersedia di informasi aplikasi.',
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final String title;
  final String body;
  const _FaqCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(body),
          ),
        ],
      ),
    );
  }
}
