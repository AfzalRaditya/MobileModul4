// lib/app/data/providers/supabase_provider.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart'; 
import 'package:flutter/foundation.dart';

class SupabaseProvider extends GetxService {
  
  static const String kSupabaseUrl = 'https://kyvouonzilkohektxvkn.supabase.co'; 
  static const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5dm91b256aWxrb2hla3R4dmtuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMDE5MzcsImV4cCI6MjA3ODg3NzkzN30.xN-gWyXMZSRUqkIQd-1gq1-nba5Mho3GEHZ5Kvtm61Q';
  
  Rx<SupabaseClient?> client = Rx<SupabaseClient?>(null); 
  
  RxString initializationError = ''.obs; 

  Future<void> init() async {
    try {
        await Supabase.initialize(
            url: kSupabaseUrl,
            anonKey: kSupabaseAnonKey, 
            debug: true,
        );
        client.value = Supabase.instance.client; 
        initializationError.value = ''; 
    } catch (e) {
        debugPrint("FATAL SUPABASE ERROR DURING INIT: $e"); 
        initializationError.value = e.toString();
    }
  }
}