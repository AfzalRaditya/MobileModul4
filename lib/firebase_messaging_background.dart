import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

/// Top-level background message handler required by firebase_messaging.
/// It must be a top-level function.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // You can perform background work here (e.g., database writes).
  developer.log('Background message received: ${message.messageId}');
  developer.log('Background message data: ${message.data}');
}
