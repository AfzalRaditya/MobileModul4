class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  bool read;
}
