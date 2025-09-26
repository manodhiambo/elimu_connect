#!/bin/bash
# Complete fix for all compilation errors

echo "🔧 Fixing all compilation errors..."

# Create directories
mkdir -p lib/src/core/di
mkdir -p lib/src/services
mkdir -p lib/src/providers

# 1. Fix Storage Service (remove Timer and IOSAccessibility issues)
cat > lib/src/services/storage_service.dart << 'EOF'
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
EOF

# 2. Create simplified API Service
cat > lib/src/services/api_service.dart << 'EOF'
// File: lib/src/services/api_service.dart

import 'package:dio/dio.dart';
import '../config/environment.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        if (Environment.isDevelopment) {
          print('Request: ${options.method} ${options.path}');
        }
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        if (Environment.isDevelopment) {
          print('Response: ${response.statusCode} ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      
      onError: (error, handler) {
        if (Environment.isDevelopment) {
          print('Error: ${error.message}');
        }

        if (error.response?.statusCode == 401) {
          _authToken = null;
        }
        
        handler.next(error);
      },
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
EOF

# 3. Create simplified Notification Service
cat > lib/src/services/notification_service.dart << 'EOF'
// File: lib/src/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _initialized = false;

  NotificationService(this._notificationsPlugin);

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      );

      await _notificationsPlugin.initialize(initializationSettings);
      _initialized = true;
      
      print('NotificationService initialized');
    } catch (e) {
      print('NotificationService failed to initialize: $e');
    }
  }

  bool isInitialized() => _initialized;

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    try {
      const androidDetails = AndroidNotificationDetails(
        'general',
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.defaultImportance,
      );

      const iosDetails = DarwinNotificationDetails();
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Failed to show notification: $e');
    }
  }
}
EOF

# 4. Create simplified Connectivity Service
cat > lib/src/services/connectivity_service.dart << 'EOF'
// File: lib/src/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  
  ConnectivityService(this._connectivity);

  Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
EOF

# 5. Create fixed Service Locator
cat > lib/src/core/di/service_locator.dart << 'EOF'
// File: lib/src/core/di/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/connectivity_service.dart';
import '../../config/app_config.dart';

class ServiceLocator {
  ServiceLocator._();

  static final GetIt _getIt = GetIt.instance;

  static GetIt get instance => _getIt;

  static Future<void> initialize() async {
    await _registerExternalDependencies();
    _registerServices();
    await _configureServices();
    
    if (AppConfig.isDebugMode) {
      _printRegisteredServices();
    }
  }

  static Future<void> _registerExternalDependencies() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    _getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    final dio = Dio();
    _getIt.registerSingleton<Dio>(dio);

    final connectivity = Connectivity();
    _getIt.registerSingleton<Connectivity>(connectivity);

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
      flutterLocalNotificationsPlugin,
    );
  }

  static void _registerServices() {
    _getIt.registerLazySingleton<StorageService>(
      () => StorageService(),
    );

    _getIt.registerLazySingleton<ApiService>(
      () => ApiService(),
    );

    _getIt.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(_getIt<Connectivity>()),
    );

    _getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(_getIt<FlutterLocalNotificationsPlugin>()),
    );
  }

  static Future<void> _configureServices() async {
    await StorageService.initialize();
    await _getIt<NotificationService>().initialize();
  }

  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }

  static T get<T extends Object>() {
    return _getIt<T>();
  }

  static void _printRegisteredServices() {
    if (!AppConfig.isDebugMode) return;
    
    print('Service Locator - Registered Services:');
    print('- SharedPreferences: ${isRegistered<SharedPreferences>()}');
    print('- Dio: ${isRegistered<Dio>()}');
    print('- ApiService: ${isRegistered<ApiService>()}');
    print('- StorageService: ${isRegistered<StorageService>()}');
    print('- ConnectivityService: ${isRegistered<ConnectivityService>()}');
    print('- NotificationService: ${isRegistered<NotificationService>()}');
  }
}
EOF

echo "✅ All files fixed!"
echo "Now run: flutter clean && flutter pub get && flutter build web"
