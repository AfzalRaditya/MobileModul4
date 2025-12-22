import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/local_storage_service.dart';

class PersonalDetailsView extends StatefulWidget {
  const PersonalDetailsView({super.key});

  @override
  State<PersonalDetailsView> createState() => _PersonalDetailsViewState();
}

class _PersonalDetailsViewState extends State<PersonalDetailsView> {
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();

  late final LocalStorageService _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = Get.find<LocalStorageService>();
    _nameC.text = _localStorage.getProfileName() ?? '';
    _phoneC.text = _localStorage.getProfilePhone() ?? '';
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _localStorage.setProfileName(_nameC.text.trim());
    await _localStorage.setProfilePhone(_phoneC.text.trim());

    if (!mounted) return;
    Get.snackbar('Berhasil', 'Personal details tersimpan');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Akun Terdaftar'),
              subtitle: Text(email),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Nama',
            child: TextField(
              controller: _nameC,
              decoration: _decoration('Nama Anda', scheme),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'No. HP',
            child: TextField(
              controller: _phoneC,
              keyboardType: TextInputType.phone,
              decoration: _decoration('08xxxxxxxxxx', scheme),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint, ColorScheme scheme) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
