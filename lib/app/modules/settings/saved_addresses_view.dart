import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/delivery_address.dart';
import '../../data/services/local_storage_service.dart';

class SavedAddressesView extends StatefulWidget {
  const SavedAddressesView({super.key});

  @override
  State<SavedAddressesView> createState() => _SavedAddressesViewState();
}

class _SavedAddressesViewState extends State<SavedAddressesView> {
  late final LocalStorageService _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = Get.find<LocalStorageService>();
  }

  List<DeliveryAddress> _addresses() => _localStorage.getSavedAddresses();

  DeliveryAddress? _defaultAddr() => _localStorage.getDefaultSavedAddress();

  Future<void> _addFromMap() async {
    final result = await Get.toNamed<dynamic>('/location-picker');
    final picked = result is DeliveryAddress ? result : null;
    if (picked == null) return;

    await _localStorage.addSavedAddress(picked);
    await _localStorage.setDefaultSavedAddress(picked);

    if (!mounted) return;
    setState(() {});
    Get.snackbar('Alamat', 'Alamat berhasil disimpan');
  }

  Future<void> _setDefault(DeliveryAddress addr) async {
    await _localStorage.setDefaultSavedAddress(addr);
    if (!mounted) return;
    setState(() {});
    Get.snackbar('Alamat', 'Alamat utama diperbarui');
  }

  Future<void> _deleteAt(int index) async {
    await _localStorage.removeSavedAddressAt(index);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final addrs = _addresses();
    final def = _defaultAddr();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        actions: [
          IconButton(
            onPressed: _addFromMap,
            icon: const Icon(Icons.add),
            tooltip: 'Tambah alamat',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Tambah alamat dari map'),
              subtitle: Text(
                'Pilih lokasi, lalu simpan sebagai alamat.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _addFromMap,
            ),
          ),
          const SizedBox(height: 12),
          if (addrs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'Belum ada alamat tersimpan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          else
            ...List.generate(addrs.length, (i) {
              final a = addrs[i];
              final isDefault = def != null &&
                  def.latitude == a.latitude &&
                  def.longitude == a.longitude &&
                  def.addressLine == a.addressLine;

              return Card(
                child: ListTile(
                  leading: Icon(
                    isDefault ? Icons.star : Icons.location_on_outlined,
                    color: isDefault ? scheme.primary : null,
                  ),
                  title: Text(a.addressLine),
                  subtitle: Text(
                    [a.city, a.postalCode].where((e) => (e ?? '').isNotEmpty).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteAt(i),
                    tooltip: 'Hapus',
                  ),
                  onTap: () => _setDefault(a),
                ),
              );
            }),
        ],
      ),
    );
  }
}
