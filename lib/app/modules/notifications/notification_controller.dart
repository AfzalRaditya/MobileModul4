import 'package:get/get.dart';
import 'notification_model.dart';

class NotificationController extends GetxController {
  final RxList<NotificationItem> _items = <NotificationItem>[].obs;

  List<NotificationItem> get items => _items;

  int get unreadCount => _items.where((e) => !e.read).length;

  @override
  void onInit() {
    super.onInit();
    // Seed some demo notifications (replace with real data later)
    if (_items.isEmpty) {
      _items.addAll([
        NotificationItem(
          id: '1',
          title: 'Welcome',
          body: 'Selamat datang di aplikasi kami!',
        ),
        NotificationItem(
          id: '2',
          title: 'Promo Packing',
          body: 'Diskon 10% untuk order kardus hari ini.',
        ),
      ]);
    }
  }

  void markRead(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      _items[idx].read = true;
      _items.refresh();
    }
  }

  void markAllRead() {
    for (final it in _items) {
      it.read = true;
    }
    _items.refresh();
  }

  void addNotification(NotificationItem item) {
    _items.insert(0, item);
  }
}
