// lib/app/data/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = "https://69197f959ccba073ee931916.mockapi.io/api/v1"; 
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final String productEndpoint = "/Products"; // Pastikan kapitalisasi

  // --- Eksperimen Perbandingan 1: Dio ---
  Future<List<ProductModel>> fetchProductsDio() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get(productEndpoint); 
      
      if (kDebugMode) {
        print("Dio Response Time: ${stopwatch.elapsedMilliseconds}ms");
      }

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        print("Dio Error (Better Logging): ${e.message}");
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  // --- Eksperimen Perbandingan 2: http ---
  Future<List<ProductModel>> fetchProductsHttp() async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse("$_baseUrl$productEndpoint");
      final response = await http.get(uri);
      
      if (kDebugMode) {
        print("Http Response Time: ${stopwatch.elapsedMilliseconds}ms");
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("Http Manual Error: $e");
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  // Fungsi fetchTopBestSeller() telah dihapus.
}