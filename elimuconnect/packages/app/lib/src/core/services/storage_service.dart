import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elimuconnect_shared/shared.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';
  static const String _settingsKey = 'app_settings';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<void> removeRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      } catch (e) {
        print('Error parsing stored user: $e');
        await removeUser();
        return null;
      }
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        return jsonDecode(settingsJson) as Map<String, dynamic>;
      } catch (e) {
        print('Error parsing stored settings: $e');
        return {};
      }
    }
    return {};
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings);
    await prefs.setString(_settingsKey, settingsJson);
  }

  Future<T?> getValue<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  Future<void> setValue<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      // For complex objects, convert to JSON
      await prefs.setString(key, jsonEncode(value));
    }
  }

  Future<void> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Theme settings
  Future<bool> isDarkMode() async {
    final settings = await getSettings();
    return settings['darkMode'] ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    final settings = await getSettings();
    settings['darkMode'] = isDark;
    await saveSettings(settings);
  }

  // Language settings
  Future<String> getLanguage() async {
    final settings = await getSettings();
    return settings['language'] ?? 'en';
  }

  Future<void> setLanguage(String language) async {
    final settings = await getSettings();
    settings['language'] = language;
    await saveSettings(settings);
  }

  // Notification settings
  Future<bool> areNotificationsEnabled() async {
    final settings = await getSettings();
    return settings['notificationsEnabled'] ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final settings = await getSettings();
    settings['notificationsEnabled'] = enabled;
    await saveSettings(settings);
  }
}
