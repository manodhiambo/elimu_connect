// File: packages/shared/lib/src/constants/app_constants.dart
class AppConstants {
  static const String appName = 'ElimuConnect';
  static const String appVersion = '1.0.0';
  static const String adminRegistrationCode = 'OnlyMe@2025';
  
  // API Constants
  static const String baseApiUrl = 'https://api.elimuconnect.ke';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  
  // File Upload Constants
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
}

