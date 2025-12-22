import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppTab { home, orders, profile }

class AppBottomNav extends StatelessWidget {
  final AppTab current;

  const AppBottomNav({super.key, required this.current});

  int get _index {
    switch (current) {
      case AppTab.home:
        return 0;
      case AppTab.orders:
        return 1;
      case AppTab.profile:
        return 2;
    }
  }

  void _go(int index) {
    switch (index) {
      case 0:
        if (Get.currentRoute != '/katalog') Get.offAllNamed('/katalog');
        return;
      case 1:
        if (Get.currentRoute != '/orders') Get.offAllNamed('/orders');
        return;
      case 2:
        if (Get.currentRoute != '/profile') Get.offAllNamed('/profile');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: _go,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
