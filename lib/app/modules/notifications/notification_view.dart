import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_controller.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      setState(() => _fcmToken = token);
    } catch (e) {
      setState(() => _fcmToken = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark all read',
            onPressed: controller.markAllRead,
          ),
        ],
      ),
      body: Obx(() {
              if (controller.items.isEmpty) {
                return const Center(child: Text('No notifications'));
              }

              return ListView.separated(
                itemCount: controller.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final n = controller.items[index];
                  return ListTile(
                    leading: Icon(
                      n.read
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: n.read
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(n.title),
                    subtitle: Text(n.body),
                    trailing: n.read
                        ? null
                        : TextButton(
                            onPressed: () => controller.markRead(n.id),
                            child: const Text('Mark read'),
                          ),
                    onTap: () {
                      if (!n.read) controller.markRead(n.id);
                      // Optionally navigate to related content
                    },
                  );
                },
              );
            }),
    );
  }
}
