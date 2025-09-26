import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;
  
  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  }) : _secureStorage = secureStorage, _sharedPreferences = sharedPreferences;
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userProfileKey = 'user_profile';
  
  // Auth methods
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
  
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
  
  Future<void> clearAuthTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
  
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  // Profile methods
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _secureStorage.write(key: _userProfileKey, value: jsonEncode(profile));
  }
  
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final profileString = await _secureStorage.read(key: _userProfileKey);
      if (profileString != null) {
        return jsonDecode(profileString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error reading profile: $e');
    }
    return null;
  }
  
  Future<void> clearUserData() async {
    await _secureStorage.delete(key: _userProfileKey);
  }
  
  // Generic SharedPreferences methods
  Future<String?> getString(String key) async {
    return _sharedPreferences.getString(key);
  }
  
  Future<void> setString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }
  
  Future<int?> getInt(String key) async {
    return _sharedPreferences.getInt(key);
  }
  
  Future<void> setInt(String key, int value) async {
    await _sharedPreferences.setInt(key, value);
  }
  
  Future<bool?> getBool(String key) async {
    return _sharedPreferences.getBool(key);
  }
  
  Future<void> setBool(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
  }
  
  Future<double?> getDouble(String key) async {
    return _sharedPreferences.getDouble(key);
  }
  
  Future<void> setDouble(String key, double value) async {
    await _sharedPreferences.setDouble(key, value);
  }
  
  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }
  
  Future<void> clearAllData() async {
    await clearAuthTokens();
    await clearUserData();
    await _sharedPreferences.clear();
  }
}
