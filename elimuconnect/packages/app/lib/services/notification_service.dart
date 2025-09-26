// packages/app/lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    // macOS initialization settings
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // Request permissions
    await _requestNotificationPermissions();
    
    _isInitialized = true;
    print('✅ NotificationService initialized');
  }
  
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // Handle iOS foreground notifications
    print('Received iOS foreground notification: $title - $body');
  }
  
  static void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification payload: $payload');
      _handleNotificationPayload(payload);
    }
  }
  
  static void _handleNotificationPayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;
      
      switch (type) {
        case 'assignment':
          // Navigate to assignment details
          break;
        case 'message':
          // Navigate to messages
          break;
        case 'quiz':
          // Navigate to quiz
          break;
        case 'announcement':
          // Navigate to announcements
          break;
        default:
          // Handle unknown notification type
          break;
      }
    } catch (e) {
      print('Error handling notification payload: $e');
    }
  }
  
  Future<void> _requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      // Request Android 13+ notification permission
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print('Notification permission denied');
      }
    } else if (Platform.isIOS) {
      // Request iOS permissions
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      
      if (result != true) {
        print('iOS notification permissions denied');
      }
    }
  }
  
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }
  
  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
    String channelId = 'default_channel',
    String channelName = 'Default Notifications',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'ElimuConnect notifications',
      importance: _getImportance(priority),
      priority: _getPriority(priority),
      ticker: 'ticker',
    );
    
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
    String channelId = 'scheduled_channel',
    String channelName = 'Scheduled Notifications',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'ElimuConnect scheduled notifications',
      importance: _getImportance(priority),
      priority: _getPriority(priority),
    );
    
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
  
  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
  
  // Educational notifications helpers
  Future<void> showAssignmentNotification({
    required String assignmentTitle,
    required DateTime dueDate,
    required String assignmentId,
  }) async {
    final payload = jsonEncode({
      'type': 'assignment',
      'id': assignmentId,
    });
    
    await showNotification(
      id: assignmentId.hashCode,
      title: 'Assignment Due Soon',
      body: '$assignmentTitle is due ${_formatDueDate(dueDate)}',
      payload: payload,
      priority: NotificationPriority.high,
      channelId: 'assignments',
      channelName: 'Assignments',
    );
  }
  
  Future<void> showQuizNotification({
    required String quizTitle,
    required String subject,
    required String quizId,
  }) async {
    final payload = jsonEncode({
      'type': 'quiz',
      'id': quizId,
    });
    
    await showNotification(
      id: quizId.hashCode,
      title: 'New Quiz Available',
      body: '$quizTitle in $subject is ready for you!',
      payload: payload,
      channelId: 'quizzes',
      channelName: 'Quizzes',
    );
  }
  
  Future<void> showMessageNotification({
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    final payload = jsonEncode({
      'type': 'message',
      'id': conversationId,
    });
    
    await showNotification(
      id: conversationId.hashCode,
      title: 'Message from $senderName',
      body: message,
      payload: payload,
      priority: NotificationPriority.high,
      channelId: 'messages',
      channelName: 'Messages',
    );
  }
  
  Future<void> showAnnouncementNotification({
    required String title,
    required String content,
    required String announcementId,
  }) async {
    final payload = jsonEncode({
      'type': 'announcement',
      'id': announcementId,
    });
    
    await showNotification(
      id: announcementId.hashCode,
      title: 'School Announcement',
      body: content,
      payload: payload,
      channelId: 'announcements',
      channelName: 'Announcements',
    );
  }
  
  // Schedule study reminders
  Future<void> scheduleStudyReminder({
    required String subject,
    required DateTime reminderTime,
    String? customMessage,
  }) async {
    final message = customMessage ?? 'Time to study $subject!';
    
    await scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch + subject.hashCode,
      title: 'Study Reminder',
      body: message,
      scheduledDate: reminderTime,
      channelId: 'study_reminders',
      channelName: 'Study Reminders',
    );
  }
  
  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays > 1) {
      return 'in ${difference.inDays} days';
    } else if (difference.inDays == 1) {
      return 'tomorrow';
    } else if (difference.inHours > 1) {
      return 'in ${difference.inHours} hours';
    } else if (difference.inHours == 1) {
      return 'in 1 hour';
    } else {
      return 'soon';
    }
  }
  
  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Importance.min;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }
  
  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Priority.min;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }
}

enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}
