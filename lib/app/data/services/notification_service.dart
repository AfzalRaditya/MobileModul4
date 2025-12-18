import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../modules/notifications/notification_binding.dart';
import '../../modules/notifications/notification_view.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService _instance =
      NotificationService._privateConstructor();
  factory NotificationService() => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  String? _lastToken;

  /// Returns the last retrieved FCM token (may be null until init completes)
  String? get lastToken => _lastToken;

  /// Android channel id
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription =
      'This channel is used for important notifications.';

  Future<void> init() async {
    developer.log('Initializing NotificationService');

    // Request permissions (iOS and Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log('FCM permission status: ${settings.authorizationStatus}');

    // Get FCM registration token (useful for testing single-device messages).
    try {
      final token = await _fcm.getToken();
      _lastToken = token;
      // Print and log so it's visible both in flutter run console and device logs
      print('FCM token: $token');
      developer.log('FCM token: $token');
      // Subscribe this device to a development topic for easy testing from Firebase Console
      try {
        await _fcm.subscribeToTopic('dev_test');
        developer.log('Subscribed to topic: dev_test');
      } catch (e) {
        developer.log('Failed to subscribe to topic dev_test: $e');
      }
    } catch (e) {
      developer.log('Error retrieving FCM token: $e');
      print('Error retrieving FCM token: $e');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        developer.log('iOS local notification received: $payload');
      },
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        developer.log('Local notification tapped: ${response.payload}');
        _handleMessageRouting(response.payload);
      },
    );

    // Create channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('custom_notification'),
    );

    try {
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    } catch (e) {
      developer.log('Warning creating notification channel: $e');
    }

    // Foreground: show local notification for incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('onMessage payload: ${message.data}');
      _showLocalNotification(message);
    });

    // When app opened from background via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('onMessageOpenedApp payload: ${message.data}');
      _handleMessageRouting(message.data['payload'] ?? message.data);
    });

    // Handle initial message when app launched from terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      developer.log('Initial message: ${initialMessage.data}');
      // Delay navigation until app has built
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleMessageRouting(
          initialMessage.data['payload'] ?? initialMessage.data,
        );
      });
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('custom_notification'),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
      // iOS custom sound requires adding sound file to Runner project and specifying file name here
      sound: 'custom_notification.wav',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _local.show(
      notification?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification?.title ?? data['title'] ?? 'Notification',
      notification?.body ?? data['body'] ?? '',
      details,
      payload: data['payload']?.toString() ?? data.toString(),
    );
  }

  void _handleMessageRouting(dynamic payload) {
    developer.log('Routing payload: $payload');
    // Example: navigate to notifications list. You can customize to navigate to detail pages
    try {
      Get.to(() => const NotificationView(), binding: NotificationBinding());
    } catch (e) {
      developer.log('Navigation error: $e');
    }
  }
}
