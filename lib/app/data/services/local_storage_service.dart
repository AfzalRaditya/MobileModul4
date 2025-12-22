import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/cart_model.dart';
import '../models/delivery_address.dart';

class LocalStorageService {
  SharedPreferences? prefs;
  Box<CartItemModel>? cartBox;

  static const String kThemeKey = 'app_theme';
  static const String _isLoginKey = 'is_login';
  static const String _tokenKey = 'auth_token';

  static const String _profileNameKey = 'profile_name';
  static const String _profilePhoneKey = 'profile_phone';
  static const String _savedAddressesKey = 'saved_addresses';
  static const String _defaultSavedAddressKey = 'default_saved_address';

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CartItemModelAdapter());
    }

    cartBox = await Hive.openBox<CartItemModel>('cartBox');
  }

  ThemeMode getThemeMode() {
    final themeIndex = prefs?.getInt(kThemeKey);
    if (themeIndex == 1) {
      return ThemeMode.light;
    }
    if (themeIndex == 2) {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    int index;
    if (mode == ThemeMode.light) {
      index = 1;
    } else if (mode == ThemeMode.dark) {
      index = 2;
    } else {
      index = 0;
    }
    await prefs?.setInt(kThemeKey, index);
  }

  Future<void> saveSession(String token) async {
    await prefs?.setBool(_isLoginKey, true);
    await prefs?.setString(_tokenKey, token);
  }

  bool isLoggedIn() {
    return prefs?.getBool(_isLoginKey) ?? false;
  }

  String? getToken() {
    return prefs?.getString(_tokenKey);
  }

  Future<void> removeSession() async {
    await prefs?.remove(_isLoginKey);
    await prefs?.remove(_tokenKey);
  }

  String? getProfileName() => prefs?.getString(_profileNameKey);

  Future<void> setProfileName(String value) async {
    if (value.trim().isEmpty) {
      await prefs?.remove(_profileNameKey);
      return;
    }
    await prefs?.setString(_profileNameKey, value.trim());
  }

  String? getProfilePhone() => prefs?.getString(_profilePhoneKey);

  Future<void> setProfilePhone(String value) async {
    if (value.trim().isEmpty) {
      await prefs?.remove(_profilePhoneKey);
      return;
    }
    await prefs?.setString(_profilePhoneKey, value.trim());
  }

  List<DeliveryAddress> getSavedAddresses() {
    final raw = prefs?.getString(_savedAddressesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((m) => DeliveryAddress.fromJson(
                m.map((k, v) => MapEntry(k.toString(), v)),
              ))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<void> _setSavedAddresses(List<DeliveryAddress> addresses) async {
    final list = addresses.map((e) => e.toJson()).toList(growable: false);
    await prefs?.setString(_savedAddressesKey, jsonEncode(list));
  }

  Future<void> addSavedAddress(DeliveryAddress address) async {
    final addresses = getSavedAddresses().toList(growable: true);

    // Avoid duplicates by lat/lon + addressLine
    final exists = addresses.any((a) =>
        a.latitude == address.latitude &&
        a.longitude == address.longitude &&
        a.addressLine == address.addressLine);
    if (!exists) {
      addresses.insert(0, address);
      await _setSavedAddresses(addresses);
    }
  }

  Future<void> removeSavedAddressAt(int index) async {
    final addresses = getSavedAddresses().toList(growable: true);
    if (index < 0 || index >= addresses.length) return;

    final removed = addresses.removeAt(index);
    await _setSavedAddresses(addresses);

    final def = getDefaultSavedAddress();
    if (def != null &&
        def.latitude == removed.latitude &&
        def.longitude == removed.longitude &&
        def.addressLine == removed.addressLine) {
      await prefs?.remove(_defaultSavedAddressKey);
    }
  }

  DeliveryAddress? getDefaultSavedAddress() {
    final raw = prefs?.getString(_defaultSavedAddressKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return DeliveryAddress.fromJson(
        decoded.map((k, v) => MapEntry(k.toString(), v)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setDefaultSavedAddress(DeliveryAddress address) async {
    await prefs?.setString(
      _defaultSavedAddressKey,
      jsonEncode(address.toJson()),
    );
  }
}
