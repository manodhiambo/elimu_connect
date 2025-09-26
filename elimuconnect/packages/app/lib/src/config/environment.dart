// File: packages/app/lib/src/config/environment.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum BuildMode {
  development,
  staging,
  production,
}

class Environment {
  Environment._();

  static late BuildMode _buildMode;
  static late String _apiBaseUrl;
  static late String _webSocketUrl;
  static late bool _enableLogging;
  static late bool _enableAnalytics;
  static late String _sentryDsn;
  static late String _googleApiKey;
  static late String _firebaseApiKey;
  static late int _cacheTimeout;
  static late int _networkTimeout;

  static Future<void> initialize() async {
    await dotenv.load();
    
    // Determine build mode
    _buildMode = _getBuildMode();
    
    // Set configuration based on build mode
    switch (_buildMode) {
      case BuildMode.development:
        _initializeDevelopment();
        break;
      case BuildMode.staging:
        _initializeStaging();
        break;
      case BuildMode.production:
        _initializeProduction();
        break;
    }
  }

  static BuildMode _getBuildMode() {
    if (kDebugMode) return BuildMode.development;
    
    const String? flavor = String.fromEnvironment('FLAVOR');
    switch (flavor) {
      case 'staging':
        return BuildMode.staging;
      case 'production':
        return BuildMode.production;
      default:
        return BuildMode.development;
    }
  }

  static void _initializeDevelopment() {
    _apiBaseUrl = dotenv.env['DEV_API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
    _webSocketUrl = dotenv.env['DEV_WEBSOCKET_URL'] ?? 'ws://localhost:8080/ws';
    _enableLogging = true;
    _enableAnalytics = false;
    _sentryDsn = '';
    _googleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    _firebaseApiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
    _cacheTimeout = 300; // 5 minutes
    _networkTimeout = 30000; // 30 seconds
  }

  static void _initializeStaging() {
    _apiBaseUrl = dotenv.env['STAGING_API_BASE_URL'] ?? 'https://api-staging.elimuconnect.co.ke/api/v1';
    _webSocketUrl = dotenv.env['STAGING_WEBSOCKET_URL'] ?? 'wss://api-staging.elimuconnect.co.ke/ws';
    _enableLogging = true;
    _enableAnalytics = true;
    _sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
    _googleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    _firebaseApiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
    _cacheTimeout = 600; // 10 minutes
    _networkTimeout = 30000; // 30 seconds
  }

  static void _initializeProduction() {
    _apiBaseUrl = dotenv.env['PROD_API_BASE_URL'] ?? 'https://api.elimuconnect.co.ke/api/v1';
    _webSocketUrl = dotenv.env['PROD_WEBSOCKET_URL'] ?? 'wss://api.elimuconnect.co.ke/ws';
    _enableLogging = false;
    _enableAnalytics = true;
    _sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
    _googleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    _firebaseApiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
    _cacheTimeout = 3600; // 1 hour
    _networkTimeout = 30000; // 30 seconds
  }

  // Getters
  static BuildMode get buildMode => _buildMode;
  static String get apiBaseUrl => _apiBaseUrl;
  static String get webSocketUrl => _webSocketUrl;
  static bool get enableLogging => _enableLogging;
  static bool get enableAnalytics => _enableAnalytics;
  static String get sentryDsn => _sentryDsn;
  static String get googleApiKey => _googleApiKey;
  static String get firebaseApiKey => _firebaseApiKey;
  static int get cacheTimeout => _cacheTimeout;
  static int get networkTimeout => _networkTimeout;

  // Computed properties
  static bool get isDevelopment => _buildMode == BuildMode.development;
  static bool get isStaging => _buildMode == BuildMode.staging;
  static bool get isProduction => _buildMode == BuildMode.production;
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;

  // Platform checks
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  // API Configuration
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Platform': _getPlatformName(),
        'X-App-Version': appVersion,
        'X-Build-Mode': _buildMode.name,
      };

  static String _getPlatformName() {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (isMacOS) return 'macos';
    if (isWindows) return 'windows';
    if (isLinux) return 'linux';
    return 'unknown';
  }

  // App Information
  static String get appName => 'ElimuConnect';
  static String get appVersion => '1.0.0';
  static String get appBuildNumber => '1';
  static String get packageName => 'com.elimuconnect.app';

  // Feature Flags
  static bool get enableOfflineMode => true;
  static bool get enableBiometricAuth => isMobile;
  static bool get enablePushNotifications => true;
  static bool get enableVideoStreaming => true;
  static bool get enableFileDownload => true;
  static bool get enableSocialFeatures => true;
  static bool get enableGamification => true;
  static bool get enableAIFeatures => isProduction || isStaging;

  // Storage Configuration
  static String get databaseName => 'elimuconnect_${_buildMode.name}.db';
  static int get databaseVersion => 1;
  static String get cacheDirectoryName => 'elimuconnect_cache';
  static int get maxCacheSize => 100 * 1024 * 1024; // 100MB

  // Network Configuration
  static Duration get connectTimeout => Duration(milliseconds: _networkTimeout);
  static Duration get receiveTimeout => Duration(milliseconds: _networkTimeout);
  static Duration get sendTimeout => Duration(milliseconds: _networkTimeout);
  static int get maxRetries => 3;
  static Duration get retryDelay => const Duration(seconds: 1);

  // Notification Configuration
  static String get notificationChannelId => 'elimuconnect_notifications';
  static String get notificationChannelName => 'ElimuConnect Notifications';
  static String get notificationChannelDescription => 'Notifications from ElimuConnect app';

  // Kenya-specific Configuration
  static String get countryCode => 'KE';
  static String get currencyCode => 'KES';
  static String get timeZone => 'Africa/Nairobi';
  static String get defaultLanguage => 'en';
  static List<String> get supportedLanguages => ['en', 'sw', 'ki'];
  static String get phoneNumberPrefix => '+254';

  // Educational Configuration
  static List<String> get educationLevels => [
        'Pre-Primary',
        'Primary',
        'Secondary',
        'University',
      ];

  static List<String> get primaryGrades => [
        'PP1',
        'PP2',
        'Grade 1',
        'Grade 2',
        'Grade 3',
        'Grade 4',
        'Grade 5',
        'Grade 6',
        'Grade 7',
        'Grade 8',
      ];

  static List<String> get secondaryForms => [
        'Form 1',
        'Form 2',
        'Form 3',
        'Form 4',
      ];

  // Content Configuration
  static List<String> get supportedFileTypes => [
        'pdf',
        'doc',
        'docx',
        'txt',
        'mp4',
        'mp3',
        'wav',
        'jpg',
        'jpeg',
        'png',
        'gif',
        'svg',
      ];

  static int get maxFileUploadSize => 50 * 1024 * 1024; // 50MB
  static int get maxVideoUploadSize => 100 * 1024 * 1024; // 100MB
  static int get maxImageUploadSize => 10 * 1024 * 1024; // 10MB

  // Security Configuration
  static Duration get tokenRefreshThreshold => const Duration(minutes: 15);
  static Duration get sessionTimeout => const Duration(hours: 24);
  static int get maxLoginAttempts => 5;
  static Duration get lockoutDuration => const Duration(minutes: 15);

  // Development & Testing
  static bool get enableTestMode => isDevelopment;
  static bool get enableMockData => isDevelopment;
  static bool get skipOnboarding => isDevelopment;
  static bool get autoLogin => isDevelopment;

  // Validation Methods
  static bool isValidEnvironment() {
    try {
      return _apiBaseUrl.isNotEmpty && 
             _webSocketUrl.isNotEmpty &&
             _buildMode != null;
    } catch (e) {
      return false;
    }
  }

  // Debug Information
  static Map<String, dynamic> get debugInfo => {
        'buildMode': _buildMode.name,
        'apiBaseUrl': _apiBaseUrl,
        'webSocketUrl': _webSocketUrl,
        'platform': _getPlatformName(),
        'isDevelopment': isDevelopment,
        'isProduction': isProduction,
        'enableLogging': enableLogging,
        'enableAnalytics': enableAnalytics,
        'appVersion': appVersion,
        'buildNumber': appBuildNumber,
      };

  // Print environment info (development only)
  static void printEnvironmentInfo() {
    if (!isDevelopment) return;
    
    print('🌍 Environment Configuration:');
    debugInfo.forEach((key, value) {
      print('   $key: $value');
    });
  }
}
