// packages/app/lib/services/notification_service.dart
// Minimal notification service stub - no external dependencies

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('NotificationService initialized (stub version)');
    _isInitialized = true;
  }
  
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Stub implementation - will be replaced with proper notifications later
    print('Notification: $title - $body');
  }
  
  Future<void> cancelNotification(int id) async {
    print('Cancel notification: $id');
  }
  
  Future<void> cancelAllNotifications() async {
    print('Cancel all notifications');
  }
  
  Future<bool> areNotificationsEnabled() async {
    return true; // Stub - always return true
  }
}
