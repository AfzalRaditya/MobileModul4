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

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10), 
      receiveTimeout: const Duration(seconds: 10), 
      headers: {
        'User-Agent': 'GriyaDasterAyuApp/1.0', 
        'Accept': 'application/json',
      },
    ));
   
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true, 
        responseHeader: true,
        error: true,
      ),
    );
  }

  Future<List<ProductModel>> fetchProductsDio() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get(productEndpoint);
     
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

  Future<List<ProductModel>> fetchProductsHttp() async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse("$_baseUrl$productEndpoint");
      final response = await http.get(uri);

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

