import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/app_theme_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Get.find<AppThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Obx(
            () => Card(
              child: SwitchListTile(
                value: theme.isDarkMode,
                onChanged: (v) => theme.setDarkMode(v),
                title: const Text('Dark Mode'),
                subtitle: Text(
                  theme.isDarkMode ? 'Tema gelap aktif' : 'Tema cerah aktif',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                secondary: const Icon(Icons.brightness_6_outlined),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Personal Details'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed('/personal-details'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Saved Addresses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed('/saved-addresses'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Support', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed('/help-support'),
            ),
          ),
        ],
      ),
    );
  }
}
