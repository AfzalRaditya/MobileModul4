// lib/app/modules/profile/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';
import '../../shared/app_bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;

    final email = Supabase.instance.client.auth.currentUser?.email;
    final username = (email != null && email.contains('@'))
      ? email.split('@').first
      : (email ?? 'User');

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.onSurface,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(email ?? '-'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _SectionHeader('Account'),
          _ListTile(
            title: 'Saved Addresses',
            onTap: () => Get.toNamed('/saved-addresses'),
          ),
          _ListTile(
            title: 'Order History',
            onTap: () => Get.toNamed('/orders'),
          ),
          const SizedBox(height: 12),
          const _SectionHeader('General'),
          _ListTile(
            title: 'Settings',
            onTap: () => Get.toNamed('/settings'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () async {
                if (auth != null) {
                  await auth.signOut();
                } else {
                  Get.offAllNamed('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w700));
  }
}

class _ListTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _ListTile({required this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
