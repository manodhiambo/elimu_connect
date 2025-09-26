import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  static GetIt get instance => _getIt;
  
  static Future<void> init() async {
    print('🔧 Initializing ServiceLocator...');
    
    // Core dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    _getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    _getIt.registerSingleton<FlutterSecureStorage>(secureStorage);
    
    // HTTP Client
    final dio = Dio();
    dio.options.baseUrl = 'http://localhost:8080/api/v1';
    dio.options.connectTimeout = const Duration(seconds: 30);
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
    
    print('✅ ServiceLocator initialized');
  }
  
  static T get<T extends Object>() => _getIt<T>();
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}
