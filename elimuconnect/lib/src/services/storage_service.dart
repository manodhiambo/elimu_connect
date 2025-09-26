// File: lib/src/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call StorageService.initialize() first.');
    }
    return _prefs!;
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    try {
      return await _preferences.setString(key, value);
    } catch (e) {
      print('Error storing string: $e');
      return false;
    }
  }

  Future<String?> getString(String key) async {
    try {
      return _preferences.getString(key);
    } catch (e) {
      print('Error retrieving string: $e');
      return null;
    }
  }

  // Secure string operations
  Future<bool> setSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      print('Error storing secure string: $e');
      return false;
    }
  }

  Future<String?> getSecureString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('Error retrieving secure string: $e');
      return null;
    }
  }

  // Integer operations
  Future<bool> setInt(String key, int value) async {
    try {
      return await _preferences.setInt(key, value);
    } catch (e) {
      print('Error storing int: $e');
      return false;
    }
  }

  Future<int?> getInt(String key) async {
    try {
      return _preferences.getInt(key);
    } catch (e) {
      print('Error retrieving int: $e');
      return null;
    }
  }

  // Boolean operations
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _preferences.setBool(key, value);
    } catch (e) {
      print('Error storing bool: $e');
      return false;
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      return _preferences.getBool(key);
    } catch (e) {
      print('Error retrieving bool: $e');
      return null;
    }
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _preferences.setDouble(key, value);
    } catch (e) {
      print('Error storing double: $e');
      return false;
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      return _preferences.getDouble(key);
    } catch (e) {
      print('Error retrieving double: $e');
      return null;
    }
  }

  // List operations
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _preferences.setStringList(key, value);
    } catch (e) {
      print('Error storing string list: $e');
      return false;
    }
  }

  Future<List<String>?> getStringList(String key) async {
    try {
      return _preferences.getStringList(key);
    } catch (e) {
      print('Error retrieving string list: $e');
      return null;
    }
  }

  // JSON operations
  Future<bool> setJson(String key, dynamic value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('Error storing JSON: $e');
      return false;
    }
  }

  Future<dynamic> getJson(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      print('Error retrieving JSON: $e');
      return null;
    }
  }

  Future<bool> setSecureJson(String key, dynamic value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setSecureString(key, jsonString);
    } catch (e) {
      print('Error storing secure JSON: $e');
      return false;
    }
  }

  Future<dynamic> getSecureJson(String key) async {
    try {
      final jsonString = await getSecureString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      print('Error retrieving secure JSON: $e');
      return null;
    }
  }

  // Removal operations
  Future<bool> remove(String key) async {
    try {
      return await _preferences.remove(key);
    } catch (e) {
      print('Error removing key: $e');
      return false;
    }
  }

  Future<bool> removeSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (e) {
      print('Error removing secure key: $e');
      return false;
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return _preferences.containsKey(key);
    } catch (e) {
      print('Error checking key existence: $e');
      return false;
    }
  }

  Future<bool> containsSecureKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      print('Error checking secure key existence: $e');
      return false;
    }
  }

  // Clear operations
  Future<bool> clear() async {
    try {
      return await _preferences.clear();
    } catch (e) {
      print('Error clearing storage: $e');
      return false;
    }
  }

  Future<bool> clearSecure() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      print('Error clearing secure storage: $e');
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      final normalClear = await clear();
      final secureClear = await clearSecure();
      return normalClear && secureClear;
    } catch (e) {
      print('Error clearing all storage: $e');
      return false;
    }
  }

  // Utility methods
  Set<String> getAllKeys() {
    try {
      return _preferences.getKeys();
    } catch (e) {
      print('Error getting all keys: $e');
      return <String>{};
    }
  }

  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final keys = getAllKeys();
      int totalSize = 0;
      
      for (String key in keys) {
        final value = await getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }
      
      return {
        'keyCount': keys.length,
        'approximateSize': totalSize,
        'keys': keys.toList(),
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {
        'keyCount': 0,
        'approximateSize': 0,
        'keys': <String>[],
      };
    }
  }
}
