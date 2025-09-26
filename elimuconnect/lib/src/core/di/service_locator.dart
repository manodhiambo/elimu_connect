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
