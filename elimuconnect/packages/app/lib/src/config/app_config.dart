// File: packages/app/lib/src/config/app_config.dart

import 'package:flutter/foundation.dart';
import 'environment.dart';

class AppConfig {
  AppConfig._();

  // App Information
  static String get appName => Environment.appName;
  static String get version => Environment.appVersion;
  static String get buildNumber => Environment.appBuildNumber;
  static String get packageName => Environment.packageName;

  // API Configuration
  static String get baseUrl => Environment.apiBaseUrl;
  static String get webSocketUrl => Environment.webSocketUrl;
  static Map<String, String> get defaultHeaders => Environment.defaultHeaders;

  // Build Configuration
  static bool get isDebugMode => Environment.isDebug;
  static bool get isReleaseMode => Environment.isRelease;
  static bool get isProfileMode => Environment.isProfile;
  static bool get isDevelopment => Environment.isDevelopment;
  static bool get isProduction => Environment.isProduction;
  static bool get isStaging => Environment.isStaging;

  // Platform Configuration
  static bool get isWeb => Environment.isWeb;
  static bool get isMobile => Environment.isMobile;
  static bool get isDesktop => Environment.isDesktop;
  static bool get isAndroid => Environment.isAndroid;
  static bool get isIOS => Environment.isIOS;

  // Feature Flags
  static bool get enableLogging => Environment.enableLogging;
  static bool get enableAnalytics => Environment.enableAnalytics;
  static bool get enableOfflineMode => Environment.enableOfflineMode;
  static bool get enableBiometricAuth => Environment.enableBiometricAuth;
  static bool get enablePushNotifications => Environment.enablePushNotifications;
  static bool get enableVideoStreaming => Environment.enableVideoStreaming;
  static bool get enableFileDownload => Environment.enableFileDownload;
  static bool get enableSocialFeatures => Environment.enableSocialFeatures;
  static bool get enableGamification => Environment.enableGamification;
  static bool get enableAIFeatures => Environment.enableAIFeatures;

  // Network Configuration
  static Duration get connectTimeout => Environment.connectTimeout;
  static Duration get receiveTimeout => Environment.receiveTimeout;
  static Duration get sendTimeout => Environment.sendTimeout;
  static int get maxRetries => Environment.maxRetries;
  static Duration get retryDelay => Environment.retryDelay;

  // Storage Configuration
  static String get databaseName => Environment.databaseName;
  static int get databaseVersion => Environment.databaseVersion;
  static String get cacheDirectoryName => Environment.cacheDirectoryName;
  static int get maxCacheSize => Environment.maxCacheSize;
  static int get cacheTimeout => Environment.cacheTimeout;

  // Security Configuration
  static Duration get tokenRefreshThreshold => Environment.tokenRefreshThreshold;
  static Duration get sessionTimeout => Environment.sessionTimeout;
  static int get maxLoginAttempts => Environment.maxLoginAttempts;
  static Duration get lockoutDuration => Environment.lockoutDuration;

  // Kenya-specific Configuration
  static String get countryCode => Environment.countryCode;
  static String get currencyCode => Environment.currencyCode;
  static String get timeZone => Environment.timeZone;
  static String get defaultLanguage => Environment.defaultLanguage;
  static List<String> get supportedLanguages => Environment.supportedLanguages;
  static String get phoneNumberPrefix => Environment.phoneNumberPrefix;

  // Educational Configuration
  static List<String> get educationLevels => Environment.educationLevels;
  static List<String> get primaryGrades => Environment.primaryGrades;
  static List<String> get secondaryForms => Environment.secondaryForms;

  // Content Configuration
  static List<String> get supportedFileTypes => Environment.supportedFileTypes;
  static int get maxFileUploadSize => Environment.maxFileUploadSize;
  static int get maxVideoUploadSize => Environment.maxVideoUploadSize;
  static int get maxImageUploadSize => Environment.maxImageUploadSize;

  // Development Configuration
  static bool get enableTestMode => Environment.enableTestMode;
  static bool get enableMockData => Environment.enableMockData;
  static bool get skipOnboarding => Environment.skipOnboarding;
  static bool get autoLogin => Environment.autoLogin;

  // Third-party API Keys (from environment)
  static String get googleApiKey => Environment.googleApiKey;
  static String get firebaseApiKey => Environment.firebaseApiKey;
  static String get sentryDsn => Environment.sentryDsn;

  // Notification Configuration
  static String get notificationChannelId => Environment.notificationChannelId;
  static String get notificationChannelName => Environment.notificationChannelName;
  static String get notificationChannelDescription => Environment.notificationChannelDescription;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  static const double borderRadius = 8.0;
  static const double largeBorderRadius = 12.0;
  static const double extraLargeBorderRadius = 16.0;
  
  static const double elevation = 2.0;
  static const double highElevation = 8.0;
  
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  // Content limits
  static const int maxMessageLength = 1000;
  static const int maxPostLength = 5000;
  static const int maxCommentLength = 500;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 5;

  // Cache configurations
  static const Duration imageCacheDuration = Duration(days: 7);
  static const Duration dataCacheDuration = Duration(hours: 1);
  static const Duration userCacheDuration = Duration(minutes: 30);

  // Validation patterns
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp phonePattern = RegExp(
    r'^\+254[0-9]{9}$', // Kenya phone number format
  );
  
  static final RegExp namePattern = RegExp(
    r'^[a-zA-Z\s]{2,50}$',
  );

  // Error messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unauthorizedErrorMessage = 'Session expired. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';

  // Success messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String registrationSuccessMessage = 'Registration successful!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  static const String passwordChangeSuccessMessage = 'Password changed successfully!';

  // Default values
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String defaultSchoolLogo = 'assets/images/default_school.png';
  static const String placeholderImage = 'assets/images/placeholder.png';

  // External URLs
  static const String privacyPolicyUrl = 'https://elimuconnect.co.ke/privacy';
  static const String termsOfServiceUrl = 'https://elimuconnect.co.ke/terms';
  static const String supportUrl = 'https://support.elimuconnect.co.ke';
  static const String websiteUrl = 'https://elimuconnect.co.ke';

  // Social media
  static const String facebookUrl = 'https://facebook.com/elimuconnect';
  static const String twitterUrl = 'https://twitter.com/elimuconnect';
  static const String instagramUrl = 'https://instagram.com/elimuconnect';
  static const String linkedinUrl = 'https://linkedin.com/company/elimuconnect';

  // Contact information
  static const String supportEmail = 'support@elimuconnect.co.ke';
  static const String contactPhone = '+254700000000';
  static const String contactAddress = 'Nairobi, Kenya';

  // App Store URLs
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.elimuconnect.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/elimuconnect';

  // Deep links
  static const String appScheme = 'elimuconnect';
  static const String webDomain = 'elimuconnect.co.ke';

  // Development utilities
  static void printConfiguration() {
    if (!isDebugMode) return;
    
    debugPrint('📱 App Configuration:');
    debugPrint('   App Name: $appName');
    debugPrint('   Version: $version ($buildNumber)');
    debugPrint('   Build Mode: ${isDevelopment ? 'Development' : isStaging ? 'Staging' : 'Production'}');
    debugPrint('   Platform: ${isWeb ? 'Web' : isMobile ? 'Mobile' : 'Desktop'}');
    debugPrint('   Base URL: $baseUrl');
    debugPrint('   Features:');
    debugPrint('     - Logging: $enableLogging');
    debugPrint('     - Analytics: $enableAnalytics');
    debugPrint('     - Offline Mode: $enableOfflineMode');
    debugPrint('     - Biometric Auth: $enableBiometricAuth');
    debugPrint('     - Push Notifications: $enablePushNotifications');
    debugPrint('     - AI Features: $enableAIFeatures');
  }
}
