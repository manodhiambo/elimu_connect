// File: packages/app/lib/src/services/notification_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';
import '../config/environment.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _initialized = false;

  NotificationService(this._notificationsPlugin);

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize platform-specific settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
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

      // Initialize with callback for notification taps
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
      );

      // Request permissions
      await _requestPermissions();

      // Create notification channels for Android
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

  /// Check if service is initialized
  bool isInitialized() => _initialized;

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    if (Environment.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      if (androidVersion >= 33) {
        // Android 13+ requires explicit permission request
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true; // Earlier Android versions don't require explicit permission
    }

    if (Environment.isIOS || Environment.isMacOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
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

  /// Get Android version (simplified)
  Future<int> _getAndroidVersion() async {
    if (!Environment.isAndroid) return 0;
    
    try {
      // This is a simplified version - in production you'd use device_info_plus
      return 33; // Assume Android 13+ for now
    } catch (e) {
      return 33;
    }
  }

  /// Create notification channels for Android
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
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    if (AppConfig.isDebugMode) {
      print('📱 Created ${channels.length} notification channels');
    }
  }

  /// Show a simple notification
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
    if (!_initialized) {
      await initialize();
    }

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
        color: const Color(0xFF1E88E5), // Primary color
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      if (AppConfig.isDebugMode) {
        print('📬 Notification shown: $title');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to show notification: $e');
      }
    }
  }

  /// Show a scheduled notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'reminders',
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    if (!_initialized) {
      await initialize();
    }

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

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      // Use zonedSchedule instead of schedule for newer versions
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      if (AppConfig.isDebugMode) {
        print('⏰ Notification scheduled for $scheduledDate: $title');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to schedule notification: $e');
      }
    }
  }

  /// Show notification with big text (Android) or expanded content
  Future<void> showBigTextNotification({
    required int id,
    required String title,
    required String body,
    required String bigText,
    String? payload,
    String channelId = 'general',
  }) async {
    if (!_initialized) {
      await initialize();
    }

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

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to show big text notification: $e');
      }
    }
  }

  /// Show notification with action buttons
  Future<void> showNotificationWithActions({
    required int id,
    required String title,
    required String body,
    required List<NotificationAction> actions,
    String? payload,
    String channelId = 'messages',
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        actions: actions.map((action) => AndroidNotificationAction(
          action.id,
          action.title,
          titleColor: const Color(0xFF1E88E5),
          icon: action.icon != null ? DrawableResourceAndroidBitmap(action.icon!) : null,
        )).toList(),
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to show notification with actions: $e');
      }
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      
      if (AppConfig.isDebugMode) {
        print('🚫 Cancelled notification: $id');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to cancel notification: $e');
      }
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      
      if (AppConfig.isDebugMode) {
        print('🚫 Cancelled all notifications');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to cancel all notifications: $e');
      }
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to get pending notifications: $e');
      }
      return [];
    }
  }

  /// Get active notifications (Android only)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      if (Environment.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.getActiveNotifications() ?? [];
      }
      return [];
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to get active notifications: $e');
      }
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Environment.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.areNotificationsEnabled() ?? false;
      }
      
      if (Environment.isIOS || Environment.isMacOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        return await iosPlugin?.checkPermissions().then((permissions) =>
            permissions?.alert == true || permissions?.badge == true) ?? false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper methods

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'general':
        return 'General Notifications';
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

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'general':
        return 'General app notifications';
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

  Importance _mapPriorityToImportance(NotificationPriority priority) {
    switch (priority) {
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

  Priority _mapToAndroidPriority(NotificationPriority priority) {
    switch (priority) {
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

  // Callback handlers

  static void _onNotificationTap(NotificationResponse response) {
    if (AppConfig.isDebugMode) {
      print('📱 Notification tapped: ${response.payload}');
    }
    
    _handleNotificationAction(response);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    if (AppConfig.isDebugMode) {
      print('📱 Background notification tapped: ${response.payload}');
    }
    
    _handleNotificationAction(response);
  }

  static void _handleNotificationAction(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final payload = jsonDecode(response.payload!);
      final type = payload['type'] as String?;
      final data = payload['data'] as Map<String, dynamic>?;

      switch (type) {
        case 'message':
          // Handle message notification
          _handleMessageNotification(data);
          break;
        case 'assignment':
          // Handle assignment notification
          _handleAssignmentNotification(data);
          break;
        case 'announcement':
          // Handle announcement notification
          _handleAnnouncementNotification(data);
          break;
        case 'reminder':
          // Handle reminder notification
          _handleReminderNotification(data);
          break;
        default:
          // Handle generic notification
          _handleGenericNotification(data);
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Failed to handle notification action: $e');
      }
    }
  }

  static void _handleMessageNotification(Map<String, dynamic>? data) {
    // Navigate to messages or specific conversation
    if (AppConfig.isDebugMode) {
      print('💬 Handling message notification: $data');
    }
  }

  static void _handleAssignmentNotification(Map<String, dynamic>? data) {
    // Navigate to assignment or quiz
    if (AppConfig.isDebugMode) {
      print('📝 Handling assignment notification: $data');
    }
  }

  static void _handleAnnouncementNotification(Map<String, dynamic>? data) {
    // Navigate to announcements
    if (AppConfig.isDebugMode) {
      print('📢 Handling announcement notification: $data');
    }
  }

  static void _handleReminderNotification(Map<String, dynamic>? data) {
    // Handle reminder (could be study reminder, schedule alert, etc.)
    if (AppConfig.isDebugMode) {
      print('⏰ Handling reminder notification: $data');
    }
  }

  static void _handleGenericNotification(Map<String, dynamic>? data) {
    // Handle generic notification
    if (AppConfig.isDebugMode) {
      print('📬 Handling generic notification: $data');
    }
  }
}

// Enums and Models

enum NotificationPriority {
  low,
  defaultPriority,
  high,
  max,
}

class NotificationAction {
  final String id;
  final String title;
  final String? icon;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
  });
}

// Common notification helpers
extension NotificationHelpers on NotificationService {
  /// Show a message notification
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

  /// Show an assignment notification
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

  /// Show a reminder notification
  Future<void> showStudyReminder({
    required int id,
    required String subject,
    required String topic,
    DateTime? scheduledTime,
  }) async {
    final payload = jsonEncode({
      'type': 'reminder',
      'data': {
        'subject': subject,
        'topic': topic,
      }
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
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
