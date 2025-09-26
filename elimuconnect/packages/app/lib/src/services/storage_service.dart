// File: packages/app/lib/src/services/storage_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // iOS options must be skipped for web
    iOptions: kIsWeb
        ? null
        : const IOSOptions(
            accessibility: IOSAccessibility.first_unlock_this_device,
          ),
  );

  // Initialize storage
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get SharedPreferences instance
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError(
        'StorageService not initialized. Call StorageService.initialize() first.',
      );
    }
    return _prefs!;
  }

  // ===================== String Operations =====================

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

  // ===================== Secure String Operations =====================

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

  // ===================== Integer Operations =====================

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

  // ===================== Boolean Operations =====================

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

  // ===================== Double Operations =====================

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

  // ===================== List Operations =====================

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

  // ===================== JSON Operations =====================

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

  // ===================== Removal Operations =====================

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

  // ===================== Clear Operations =====================

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

  // ===================== Utility Methods =====================

  Set<String> getAllKeys() {
    try {
      return _preferences.getKeys();
    } catch (e) {
      print('Error getting all keys: $e');
      return <String>{};
    }
  }

  Future<int> getStorageSize() async {
    try {
      int totalSize = 0;
      final keys = getAllKeys();

      for (String key in keys) {
        final value = await getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }

      return totalSize;
    } catch (e) {
      print('Error calculating storage size: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final keys = getAllKeys();
      final size = await getStorageSize();

      return {
        'keyCount': keys.length,
        'approximateSize': size,
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

  // ===================== Batch Operations =====================

  Future<bool> setBatch(Map<String, dynamic> data) async {
    try {
      bool allSuccess = true;

      for (MapEntry<String, dynamic> entry in data.entries) {
        bool success = false;

        if (entry.value is String) {
          success = await setString(entry.key, entry.value);
        } else if (entry.value is int) {
          success = await setInt(entry.key, entry.value);
        } else if (entry.value is bool) {
          success = await setBool(entry.key, entry.value);
        } else if (entry.value is double) {
          success = await setDouble(entry.key, entry.value);
        } else if (entry.value is List<String>) {
          success = await setStringList(entry.key, entry.value);
        } else {
          success = await setJson(entry.key, entry.value);
        }

        if (!success) allSuccess = false;
      }

      return allSuccess;
    } catch (e) {
      print('Error setting batch data: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getBatch(List<String> keys) async {
    final results = <String, dynamic>{};

    for (String key in keys) {
      try {
        final stringValue = await getString(key);
        if (stringValue != null) {
          results[key] = stringValue;
          continue;
        }

        final intValue = await getInt(key);
        if (intValue != null) {
          results[key] = intValue;
          continue;
        }

        final boolValue = await getBool(key);
        if (boolValue != null) {
          results[key] = boolValue;
          continue;
        }

        final doubleValue = await getDouble(key);
        if (doubleValue != null) {
          results[key] = doubleValue;
          continue;
        }

        final listValue = await getStringList(key);
        if (listValue != null) {
          results[key] = listValue;
          continue;
        }

        final jsonValue = await getJson(key);
        if (jsonValue != null) {
          results[key] = jsonValue;
        }
      } catch (e) {
        print('Error getting value for key $key: $e');
      }
    }

    return results;
  }

  Future<bool> removeBatch(List<String> keys) async {
    bool allSuccess = true;

    for (String key in keys) {
      final success = await remove(key);
      if (!success) allSuccess = false;
    }

    return allSuccess;
  }
}

// Implementation class for additional features
class StorageServiceImpl extends StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  Map<String, dynamic>? _cache;
  Timer? _cacheTimer;
  final Duration _cacheExpiry;

  StorageServiceImpl(
    this._prefs, {
    Duration cacheExpiry = const Duration(minutes: 30),
  })  : _cacheExpiry = cacheExpiry,
        _secureStorage = FlutterSecureStorage(
          aOptions: const AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: kIsWeb
              ? null
              : const IOSOptions(
                  accessibility: IOSAccessibility.first_unlock_this_device,
                ),
        );

  void _initializeCache() {
    _cache = <String, dynamic>{};
    _startCacheTimer();
  }

  void _startCacheTimer() {
    _cacheTimer?.cancel();
    _cacheTimer = Timer.periodic(_cacheExpiry, (timer) {
      _cache?.clear();
    });
  }

  void _addToCache(String key, dynamic value) {
    _cache ??= <String, dynamic>{};
    _cache![key] = {
      'value': value,
      'timestamp': DateTime.now(),
    };
  }

  T? _getFromCache<T>(String key) {
    if (_cache == null) return null;

    final cached = _cache![key];
    if (cached == null) return null;

    final timestamp = cached['timestamp'] as DateTime;
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      _cache!.remove(key);
      return null;
    }

    return cached['value'] as T?;
  }

  @override
  Future<String?> getString(String key) async {
    final cached = _getFromCache<String>(key);
    if (cached != null) return cached;

    final value = await super.getString(key);
    if (value != null) {
      _addToCache(key, value);
    }
    return value;
  }

  // Encrypted storage methods
  Future<bool> setEncryptedString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      print('Error storing encrypted string: $e');
      return false;
    }
  }

  Future<String?> getEncryptedString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('Error retrieving encrypted string: $e');
      return null;
    }
  }

  // Compressed JSON storage
  Future<bool> setCompressedJson(String key, dynamic value) async {
    try {
      final jsonString = jsonEncode(value);

      if (jsonString.length > 1000) {
        return await setSecureString(key, jsonString);
      } else {
        return await setJson(key, value);
      }
    } catch (e) {
      print('Error storing compressed JSON: $e');
      return false;
    }
  }

  Future<dynamic> getCompressedJson(String key) async {
    try {
      final secureValue = await getSecureString(key);
      if (secureValue != null) {
        return jsonDecode(secureValue);
      }
      return await getJson(key);
    } catch (e) {
      print('Error retrieving compressed JSON: $e');
      return null;
    }
  }

  Future<bool> migrateData(Map<String, String> keyMigrations) async {
    try {
      for (final entry in keyMigrations.entries) {
        final oldKey = entry.key;
        final newKey = entry.value;

        if (await containsKey(oldKey)) {
          final value = await getString(oldKey);
          if (value != null) {
            await setString(newKey, value);
            await remove(oldKey);
          }
        }
      }
      return true;
    } catch (e) {
      print('Error migrating data: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> backupData() async {
    try {
      final keys = getAllKeys();
      final backup = <String, dynamic>{};

      for (final key in keys) {
        final value = await getString(key);
        if (value != null) {
          backup[key] = value;
        }
      }

      backup['_backup_timestamp'] = DateTime.now().toIso8601String();
      backup['_backup_version'] = '1.0';

      return backup;
    } catch (e) {
      print('Error creating backup: $e');
      return null;
    }
  }

  Future<bool> restoreData(Map<String, dynamic> backup) async {
    try {
      if (!backup.containsKey('_backup_timestamp')) {
        print('Invalid backup format');
        return false;
      }

      await clear();

      for (final entry in backup.entries) {
        if (!entry.key.startsWith('_backup_')) {
          await setString(entry.key, entry.value.toString());
        }
      }

      return true;
    } catch (e) {
      print('Error restoring backup: $e');
      return false;
    }
  }

  Future<void> cleanup() async {
    _cacheTimer?.cancel();
    _cache?.clear();
  }

  Future<Map<String, bool>> validateData() async {
    final results = <String, bool>{};
    final keys = getAllKeys();

    for (final key in keys) {
      try {
        final value = await getString(key);
        results[key] = value != null;
      } catch (e) {
        results[key] = false;
      }
    }

    return results;
  }

  Future<Map<String, dynamic>> getPerformanceStats() async {
    final stopwatch = Stopwatch()..start();

    const testKey = '_perf_test_key';
    const testValue = 'test_value_for_performance_testing';

    await setString(testKey, testValue);
    await getString(testKey);
    await remove(testKey);

    stopwatch.stop();

    final stats = await getStorageInfo();
    stats['read_write_test_ms'] = stopwatch.elapsedMilliseconds;
    stats['cache_size'] = _cache?.length ?? 0;
    stats['cache_enabled'] = _cache != null;

    return stats;
  }
}
