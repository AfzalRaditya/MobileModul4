// lib/app/data/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import 'package:flutter/foundation.dart';


class ApiService {
  static const String _baseUrl = "https://69197f959ccba073ee931916.mockapi.io/api/v1";
  final String productEndpoint = "/Products";
  late final Dio _dio;


  // Constructor untuk menginisialisasi Dio dan Interceptor
  ApiService() {
    // Definisikan BaseOptions dengan timeout dan Header Kustom
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10), // Menambahkan Connect Timeout
      receiveTimeout: const Duration(seconds: 10), // Menambahkan Receive Timeout
      headers: {
        // --- HEADER KUSTOM (Mirip dengan Log Anda) ---
        'User-Agent': 'Muktijaya1App/1.0', // Ganti nama aplikasi Anda
        'Accept': 'application/json',
      },
    ));
   
    // --- SISIPAN LOG INTERCEPTOR (WAJIB MODUL 3) ---
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true, // Akan mencetak header kustom di atas
        responseHeader: true,
        error: true,
      ),
    );
    // ---------------------------------------------
  }


  // --- LOGIC UTAMA: Menggunakan Dio (Waktu Respons Dio akan dicatat) ---
  Future<List<ProductModel>> fetchProductsDio() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get(productEndpoint);
     
      // LOGGING WAKTU RESPONS DIO
      if (kDebugMode) {
        debugPrint("PERFORMA UJI: Dio Response Time: ${stopwatch.elapsedMilliseconds}ms");
      }


      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("Dio Error Catch: ${e.response?.statusCode} | ${e.message}");
      }
      throw Exception("Dio Request failed: ${e.message}");
    } finally {
      stopwatch.stop();
    }
  }


  // --- LOGIC PERBANDINGAN: Menggunakan http (Waktu Respons http akan dicatat) ---
  Future<List<ProductModel>> fetchProductsHttp() async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse("$_baseUrl$productEndpoint");
      final response = await http.get(uri);
     
      // LOGGING WAKTU RESPONS HTTP
      if (kDebugMode) {
        debugPrint("PERFORMA UJI: Http Response Time: ${stopwatch.elapsedMilliseconds}ms");
      }
     
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception("Http Request failed with status: ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Http Error Catch: $e");
      }
      throw Exception("Http Request failed: $e");
    } finally {
      stopwatch.stop();
    }
  }
}

