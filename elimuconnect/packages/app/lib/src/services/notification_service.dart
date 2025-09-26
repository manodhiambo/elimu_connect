// File: packages/app/lib/src/services/notification_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../config/app_config.dart';
import '../config/environment.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _initialized = false;

  NotificationService(this._notificationsPlugin);

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      // Notifications not supported on web by this plugin
      _initialized = true;
      return;
    }

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false,
        requestProvisionalPermission: false,
      );

      const macosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationTap,
      );

      await _requestPermissions();

      if (Environment.isAndroid) {
        await _createNotificationChannels();
      }

      _initialized = true;

      if (AppConfig.isDebugMode) {
        print('✅ NotificationService initialized successfully');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ NotificationService initialization failed: $e');
      }
    }
  }

  bool isInitialized() => _initialized;

  Future<bool> _requestPermissions() async {
    if (Environment.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      if (androidVersion >= 33) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true;
    }

    if (Environment.isIOS || Environment.isMacOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }

    return true;
  }

  Future<int> _getAndroidVersion() async {
    if (!Environment.isAndroid) return 0;
    try {
      return 33; // stubbed
    } catch (_) {
      return 33;
    }
  }

  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'general',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'messages',
        'Messages',
        description: 'New message notifications',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'assignments',
        'Assignments',
        description: 'Assignment and quiz notifications',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'announcements',
        'Announcements',
        description: 'School announcements',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'reminders',
        'Reminders',
        description: 'Study reminders and schedule alerts',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
      ),
    ];

    for (final channel in channels) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'general',
    NotificationPriority priority = NotificationPriority.defaultPriority,
    bool enableVibration = true,
    bool playSound = true,
  }) async {
    if (!_initialized) await initialize();

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: _mapPriorityToImportance(priority),
        priority: _mapToAndroidPriority(priority),
        enableVibration: enableVibration,
        playSound: playSound,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF1E88E5),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to show notification: $e');
      }
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'reminders',
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    if (!_initialized) await initialize();

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: _mapPriorityToImportance(priority),
        priority: _mapToAndroidPriority(priority),
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to schedule notification: $e');
      }
    }
  }

  Future<void> showBigTextNotification({
    required int id,
    required String title,
    required String body,
    required String bigText,
    String? payload,
    String channelId = 'general',
  }) async {
    if (!_initialized) await initialize();

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: BigTextStyleInformation(
          bigText,
          htmlFormatBigText: true,
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: 'ElimuConnect',
          htmlFormatSummaryText: true,
        ),
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notificationsPlugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed big text notification: $e');
      }
    }
  }

  Future<void> showNotificationWithActions({
    required int id,
    required String title,
    required String body,
    required List<NotificationAction> actions,
    String? payload,
    String channelId = 'messages',
  }) async {
    if (!_initialized) await initialize();

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        actions: actions
            .map((a) => AndroidNotificationAction(
                  a.id,
                  a.title,
                  titleColor: const Color(0xFF1E88E5),
                  icon: a.icon != null
                      ? DrawableResourceAndroidBitmap(a.icon!)
                      : null,
                ))
            .toList(),
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notificationsPlugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed action notification: $e');
      }
    }
  }

  Future<void> cancelNotification(int id) async =>
      _notificationsPlugin.cancel(id);

  Future<void> cancelAllNotifications() async =>
      _notificationsPlugin.cancelAll();

  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      _notificationsPlugin.pendingNotificationRequests();

  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (Environment.isAndroid) {
      final plugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await plugin?.getActiveNotifications() ?? [];
    }
    return [];
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      if (Environment.isAndroid) {
        final plugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await plugin?.areNotificationsEnabled() ?? false;
      }

      if (Environment.isIOS || Environment.isMacOS) {
        final plugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final perms = await plugin?.checkPermissions();
        return perms?.isAuthorized ?? false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // Helpers

  String _getChannelName(String id) {
    switch (id) {
      case 'messages':
        return 'Messages';
      case 'assignments':
        return 'Assignments';
      case 'announcements':
        return 'Announcements';
      case 'reminders':
        return 'Reminders';
      default:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(String id) {
    switch (id) {
      case 'messages':
        return 'New message notifications';
      case 'assignments':
        return 'Assignment and quiz notifications';
      case 'announcements':
        return 'School announcements';
      case 'reminders':
        return 'Study reminders and schedule alerts';
      default:
        return 'General app notifications';
    }
  }

  Importance _mapPriorityToImportance(NotificationPriority p) {
    switch (p) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _mapToAndroidPriority(NotificationPriority p) {
    switch (p) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
      default:
        return Priority.defaultPriority;
    }
  }

  static void _onNotificationTap(NotificationResponse r) {
    if (AppConfig.isDebugMode) {
      print('📱 Notification tapped: ${r.payload}');
    }
    _handleNotificationAction(r);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse r) {
    if (AppConfig.isDebugMode) {
      print('📱 Background tap: ${r.payload}');
    }
    _handleNotificationAction(r);
  }

  static void _handleNotificationAction(NotificationResponse r) {
    if (r.payload == null) return;
    try {
      final payload = jsonDecode(r.payload!);
      final type = payload['type'] as String?;
      final data = payload['data'] as Map<String, dynamic>?;

      switch (type) {
        case 'message':
          _handleMessageNotification(data);
          break;
        case 'assignment':
          _handleAssignmentNotification(data);
          break;
        case 'announcement':
          _handleAnnouncementNotification(data);
          break;
        case 'reminder':
          _handleReminderNotification(data);
          break;
        default:
          _handleGenericNotification(data);
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Handle notification error: $e');
      }
    }
  }

  static void _handleMessageNotification(Map<String, dynamic>? d) =>
      print('💬 Handling message notification: $d');

  static void _handleAssignmentNotification(Map<String, dynamic>? d) =>
      print('📝 Handling assignment notification: $d');

  static void _handleAnnouncementNotification(Map<String, dynamic>? d) =>
      print('📢 Handling announcement notification: $d');

  static void _handleReminderNotification(Map<String, dynamic>? d) =>
      print('⏰ Handling reminder notification: $d');

  static void _handleGenericNotification(Map<String, dynamic>? d) =>
      print('📬 Handling generic notification: $d');
}

enum NotificationPriority { low, defaultPriority, high, max }

class NotificationAction {
  final String id;
  final String title;
  final String? icon;

  const NotificationAction({required this.id, required this.title, this.icon});
}

extension NotificationHelpers on NotificationService {
  Future<void> showMessageNotification({
    required int id,
    required String senderName,
    required String message,
    String? conversationId,
  }) async {
    final payload = jsonEncode({
      'type': 'message',
      'data': {
        'conversation_id': conversationId,
        'sender_name': senderName,
      }
    });

    await showNotification(
      id: id,
      title: 'New message from $senderName',
      body: message,
      payload: payload,
      channelId: 'messages',
      priority: NotificationPriority.high,
    );
  }

  Future<void> showAssignmentNotification({
    required int id,
    required String assignmentTitle,
    required String teacherName,
    required DateTime dueDate,
    String? assignmentId,
  }) async {
    final payload = jsonEncode({
      'type': 'assignment',
      'data': {
        'assignment_id': assignmentId,
        'due_date': dueDate.toIso8601String(),
      }
    });

    await showNotification(
      id: id,
      title: 'New Assignment: $assignmentTitle',
      body: 'From $teacherName • Due: ${_formatDate(dueDate)}',
      payload: payload,
      channelId: 'assignments',
      priority: NotificationPriority.high,
    );
  }

  Future<void> showStudyReminder({
    required int id,
    required String subject,
    required String topic,
    DateTime? scheduledTime,
  }) async {
    final payload = jsonEncode({
      'type': 'reminder',
      'data': {'subject': subject, 'topic': topic}
    });

    if (scheduledTime != null) {
      await scheduleNotification(
        id: id,
        title: 'Study Reminder: $subject',
        body: 'Time to study $topic',
        scheduledDate: scheduledTime,
        payload: payload,
        channelId: 'reminders',
      );
    } else {
      await showNotification(
        id: id,
        title: 'Study Reminder: $subject',
        body: 'Time to study $topic',
        payload: payload,
        channelId: 'reminders',
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return '${diff.inDays} days';
    return '${date.day}/${date.month}/${date.year}';
  }
}
