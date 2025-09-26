// packages/app/lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/sync_service.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  static GetIt get instance => _getIt;
  
  static Future<void> init() async {
    // Core dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    _getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    _getIt.registerSingleton<FlutterSecureStorage>(secureStorage);
    
    // HTTP Client
    final dio = Dio();
    dio.options.baseUrl = _getBaseUrl();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    _getIt.registerSingleton<Dio>(dio);
    
    // Services
    _getIt.registerLazySingleton<StorageService>(
      () => StorageService(
        secureStorage: _getIt<FlutterSecureStorage>(),
        sharedPreferences: _getIt<SharedPreferences>(),
      ),
    );
    
    _getIt.registerLazySingleton<ApiService>(
      () => ApiService(
        dio: _getIt<Dio>(),
        storageService: _getIt<StorageService>(),
      ),
    );
    
    _getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(),
    );
    
    _getIt.registerLazySingleton<SyncService>(
      () => SyncService(
        apiService: _getIt<ApiService>(),
        storageService: _getIt<StorageService>(),
      ),
    );
    
    await _getIt<NotificationService>().initialize();
    
    _printRegisteredServices();
  }
  
  static String _getBaseUrl() {
    // TODO: Replace with your actual API base URL
    const String devUrl = 'http://localhost:8080/api/v1';
    const String prodUrl = 'https://api.elimuconnect.com/v1';
    
    // You can use environment variables or build configurations
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodUrl : devUrl;
  }
  
  static void _printRegisteredServices() {
    print('📦 ServiceLocator initialized with services:');
    print('   ✓ SharedPreferences');
    print('   ✓ FlutterSecureStorage');
    print('   ✓ Dio HTTP Client');
    print('   ✓ StorageService');
    print('   ✓ ApiService');
    print('   ✓ NotificationService');
    print('   ✓ SyncService');
  }
  
  /// Register a mock service for testing
  static void registerMockService<T extends Object>(T mockService) {
    if (_getIt.isRegistered<T>()) {
      _getIt.unregister<T>();
    }
    _getIt.registerSingleton<T>(mockService);
  }
  
  /// Replace a service at runtime (useful for testing or hot swapping)
  static Future<void> replaceService<T extends Object>(T newService) async {
    if (_getIt.isRegistered<T>()) {
      await _getIt.unregister<T>();
    }
    _getIt.registerSingleton<T>(newService);
  }
  
  /// Reset all services (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }
  
  /// Get service instance
  static T get<T extends Object>() => _getIt<T>();
  
  /// Check if service is registered
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}
