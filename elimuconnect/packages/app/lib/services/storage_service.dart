// packages/app/lib/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;
  
  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  }) : _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;
  
  // Constants for keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userProfileKey = 'user_profile';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _themeSettingsKey = 'theme_settings';
  static const String _languageSettingsKey = 'language_settings';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _offlineContentKey = 'offline_content';
  static const String _lastSyncTimeKey = 'last_sync_time';
  
  // Authentication methods
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }
  
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      print('Error reading access token: $e');
      return null;
    }
  }
  
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      print('Error reading refresh token: $e');
      return null;
    }
  }
  
  Future<void> clearAuthTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
  
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  // User profile methods
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _secureStorage.write(
      key: _userProfileKey, 
      value: jsonEncode(profile),
    );
    
    // Also save commonly used fields for quick access
    if (profile['id'] != null) {
      await _sharedPreferences.setString(_userIdKey, profile['id'].toString());
    }
    if (profile['role'] != null) {
      await _sharedPreferences.setString(_userRoleKey, profile['role'].toString());
    }
  }
  
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final profileString = await _secureStorage.read(key: _userProfileKey);
      if (profileString != null) {
        return jsonDecode(profileString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error reading user profile: $e');
      return null;
    }
  }
  
  Future<String?> getUserId() async {
    return _sharedPreferences.getString(_userIdKey);
  }
  
  Future<String?> getUserRole() async {
    return _sharedPreferences.getString(_userRoleKey);
  }
  
  Future<void> clearUserData() async {
    await Future.wait([
      _secureStorage.delete(key: _userProfileKey),
      _sharedPreferences.remove(_userIdKey),
      _sharedPreferences.remove(_userRoleKey),
    ]);
  }
  
  // App settings methods
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _sharedPreferences.setBool(_isFirstLaunchKey, isFirstLaunch);
  }
  
  Future<bool> isFirstLaunch() async {
    return _sharedPreferences.getBool(_isFirstLaunchKey) ?? true;
  }
  
  Future<void> saveThemeSettings(Map<String, dynamic> themeSettings) async {
    await _sharedPreferences.setString(
      _themeSettingsKey, 
      jsonEncode(themeSettings),
    );
  }
  
  Future<Map<String, dynamic>?> getThemeSettings() async {
    try {
      final settingsString = _sharedPreferences.getString(_themeSettingsKey);
      if (settingsString != null) {
        return jsonDecode(settingsString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error reading theme settings: $e');
      return null;
    }
  }
  
  Future<void> saveLanguageSettings(String languageCode) async {
    await _sharedPreferences.setString(_languageSettingsKey, languageCode);
  }
  
  Future<String?> getLanguageSettings() async {
    return _sharedPreferences.getString(_languageSettingsKey);
  }
  
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    await _sharedPreferences.setString(
      _notificationSettingsKey, 
      jsonEncode(settings),
    );
  }
  
  Future<Map<String, dynamic>?> getNotificationSettings() async {
    try {
      final settingsString = _sharedPreferences.getString(_notificationSettingsKey);
      if (settingsString != null) {
        return jsonDecode(settingsString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error reading notification settings: $e');
      return null;
    }
  }
  
  // Offline content methods
  Future<void> saveOfflineContent(String contentId, Map<String, dynamic> content) async {
    try {
      final existingContent = await getOfflineContent();
      existingContent[contentId] = content;
      
      await _sharedPreferences.setString(
        _offlineContentKey, 
        jsonEncode(existingContent),
      );
    } catch (e) {
      print('Error saving offline content: $e');
    }
  }
  
  Future<Map<String, dynamic>> getOfflineContent() async {
    try {
      final contentString = _sharedPreferences.getString(_offlineContentKey);
      if (contentString != null) {
        return jsonDecode(contentString) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Error reading offline content: $e');
      return {};
    }
  }
  
  Future<Map<String, dynamic>?> getOfflineContentById(String contentId) async {
    try {
      final allContent = await getOfflineContent();
      return allContent[contentId] as Map<String, dynamic>?;
    } catch (e) {
      print('Error reading offline content by ID: $e');
      return null;
    }
  }
  
  Future<void> removeOfflineContent(String contentId) async {
    try {
      final existingContent = await getOfflineContent();
      existingContent.remove(contentId);
      
      await _sharedPreferences.setString(
        _offlineContentKey, 
        jsonEncode(existingContent),
      );
    } catch (e) {
      print('Error removing offline content: $e');
    }
  }
  
  Future<void> clearAllOfflineContent() async {
    await _sharedPreferences.remove(_offlineContentKey);
  }
  
  // Sync methods
  Future<void> setLastSyncTime(DateTime syncTime) async {
    await _sharedPreferences.setString(
      _lastSyncTimeKey, 
      syncTime.toIso8601String(),
    );
  }
  
  Future<DateTime?> getLastSyncTime() async {
    try {
      final timeString = _sharedPreferences.getString(_lastSyncTimeKey);
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      print('Error reading last sync time: $e');
      return null;
    }
  }
  
  // Cache methods
  Future<void> saveCache(String key, dynamic value) async {
    try {
      await _sharedPreferences.setString('cache_$key', jsonEncode(value));
    } catch (e) {
      print('Error saving cache: $e');
    }
  }
  
  Future<T?> getCache<T>(String key) async {
    try {
      final cachedString = _sharedPreferences.getString('cache_$key');
      if (cachedString != null) {
        return jsonDecode(cachedString) as T;
      }
      return null;
    } catch (e) {
      print('Error reading cache: $e');
      return null;
    }
  }
  
  Future<void> clearCache(String key) async {
    await _sharedPreferences.remove('cache_$key');
  }
  
  Future<void> clearAllCache() async {
    final keys = _sharedPreferences.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith('cache_'));
    
    for (final key in cacheKeys) {
      await _sharedPreferences.remove(key);
    }
  }
  
  // Utility methods
  Future<void> clearAllData() async {
    await Future.wait([
      clearAuthTokens(),
      clearUserData(),
      clearAllOfflineContent(),
      clearAllCache(),
      _sharedPreferences.clear(),
    ]);
  }
  
  Future<Map<String, dynamic>> getStorageInfo() async {
    final keys = _sharedPreferences.getKeys();
    final secureKeys = await _secureStorage.readAll();
    
    return {
      'shared_preferences_keys': keys.length,
      'secure_storage_keys': secureKeys.length,
      'has_auth_token': await isAuthenticated(),
      'has_user_profile': await getUserProfile() != null,
      'offline_content_count': (await getOfflineContent()).length,
      'last_sync': (await getLastSyncTime())?.toIso8601String(),
    };
  }
}
