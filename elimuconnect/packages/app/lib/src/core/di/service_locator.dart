// File: packages/app/lib/src/core/di/service_locator.dart

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
import '../../config/environment.dart';

class ServiceLocator {
  ServiceLocator._();

  static final GetIt _getIt = GetIt.instance;

  /// Get the GetIt instance
  static GetIt get instance => _getIt;

  /// Initialize all services
  static Future<void> initialize() async {
    await _registerExternalDependencies();
    _registerServices();
    await _configureServices();
    
    if (AppConfig.isDebugMode) {
      _printRegisteredServices();
    }
  }

  /// Register external dependencies (third-party packages)
  static Future<void> _registerExternalDependencies() async {
    // Shared Preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    _getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // Dio HTTP Client
    final dio = Dio();
    _configureDio(dio);
    _getIt.registerSingleton<Dio>(dio);

    // Connectivity
    final connectivity = Connectivity();
    _getIt.registerSingleton<Connectivity>(connectivity);

    // Local Notifications
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
      flutterLocalNotificationsPlugin,
    );
  }

  /// Register application services
  static void _registerServices() {
    // Storage Service
    _getIt.registerLazySingleton<StorageService>(
      () => StorageService(),
    );

    // API Service
    _getIt.registerLazySingleton<ApiService>(
      () => ApiService(),
    );

    // Connectivity Service
    _getIt.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(_getIt<Connectivity>()),
    );

    // Notification Service
    _getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(
        _getIt<FlutterLocalNotificationsPlugin>(),
      ),
    );
  }

  /// Configure services after registration
  static Future<void> _configureServices() async {
    // Initialize Storage Service
    await StorageService.initialize();

    // Configure notifications
    await _configureNotifications(
      _getIt<FlutterLocalNotificationsPlugin>(),
    );
  }

  /// Configure Dio HTTP client
  static void _configureDio(Dio dio) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.connectTimeout = AppConfig.connectTimeout;
    dio.options.receiveTimeout = AppConfig.receiveTimeout;
    dio.options.sendTimeout = AppConfig.sendTimeout;
    dio.options.headers.addAll(AppConfig.defaultHeaders);

    // Add logging interceptor in debug mode
    if (AppConfig.enableLogging) {
      dio.interceptors.add(LogInterceptor(
        requestBody: AppConfig.isDebugMode,
        responseBody: AppConfig.isDebugMode,
        requestHeader: AppConfig.isDebugMode,
        responseHeader: false,
        error: true,
      ));
    }

    // Add error handling interceptor
    dio.interceptors.add(ApiErrorInterceptor());

    // Add request/response transform interceptor
    dio.interceptors.add(ApiTransformInterceptor());
  }

  /// Configure local notifications
  static Future<void> _configureNotifications(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
      macOS: iosInitializationSettings,
    );

    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
    );

    // Request permissions for iOS
    if (Environment.isIOS) {
      await plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Handle notification tap
  static void _handleNotificationTap(NotificationResponse response) {
    if (AppConfig.isDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    
    // Handle notification tap based on payload
    // This can be extended to navigate to specific screens
    if (response.payload != null) {
      // Parse payload and handle navigation
      // Example: Navigate to specific screen based on payload
    }
  }

  /// Check if a service is registered
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }

  /// Get a service instance
  static T get<T extends Object>() {
    return _getIt<T>();
  }

  /// Reset all registrations (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }

  /// Unregister a specific service
  static Future<void> unregister<T extends Object>() async {
    if (_getIt.isRegistered<T>()) {
      await _getIt.unregister<T>();
    }
  }
}

/// API Error Interceptor
class ApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final handledError = _handleApiError(err);
    handler.next(handledError);
  }

  DioException _handleApiError(DioException error) {
    String message;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.badResponse:
        message = _handleResponseError(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: error.error,
      message: message,
    );
  }

  String _handleResponseError(Response? response) {
    if (response == null) return 'Unknown error occurred.';

    switch (response.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        if (response.statusCode! >= 500) {
          return 'Server error. Please try again later.';
        } else if (response.statusCode! >= 400) {
          return 'Client error. Please check your request.';
        }
        return 'Unknown error occurred.';
    }
  }
}

/// API Transform Interceptor
class ApiTransformInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add common headers
    options.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch;
    options.headers['X-Platform'] = Environment.isWeb ? 'web' : 
                                   Environment.isAndroid ? 'android' : 
                                   Environment.isIOS ? 'ios' : 'unknown';
    options.headers['X-App-Version'] = AppConfig.version;
    
    if (AppConfig.isDebugMode) {
      print('🔵 API Request: ${options.method} ${options.path}');
      print('📋 Headers: ${options.headers}');
    }
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.isDebugMode) {
      print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
      print('⏱️ Duration: ${DateTime.now().millisecondsSinceEpoch - 
             (response.requestOptions.headers['X-Timestamp'] as int? ?? 0)}ms');
    }
    
    // Transform response data if needed
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      
      // Add metadata
      data['_meta'] = {
        'timestamp': DateTime.now().toIso8601String(),
        'status_code': response.statusCode,
        'request_id': response.headers.value('x-request-id'),
      };
    }
    
    handler.next(response);
  }
}

/// Additional service locator methods for testing and development
extension ServiceLocatorExtensions on ServiceLocator {
  /// Register a mock service (for testing)
  static void registerMockService<T extends Object>(T mockService) {
    if (_getIt.isRegistered<T>()) {
      _getIt.unregister<T>();
    }
    _getIt.registerSingleton<T>(mockService);
  }

  /// Replace an existing service
  static Future<void> replaceService<T extends Object>(T newService) async {
    if (_getIt.isRegistered<T>()) {
      await _getIt.unregister<T>();
    }
    _getIt.registerSingleton<T>(newService);
  }

  /// Health check for all registered services
  static Future<Map<String, bool>> performHealthCheck() async {
    final results = <String, bool>{};

    try {
      // Check API Service
      final apiService = ServiceLocator.instance<ApiService>();
      results['ApiService'] = await _checkApiService(apiService);
    } catch (e) {
      results['ApiService'] = false;
    }

    try {
      // Check Storage Service
      final storageService = ServiceLocator.instance<StorageService>();
      results['StorageService'] = await _checkStorageService(storageService);
    } catch (e) {
      results['StorageService'] = false;
    }

    try {
      // Check Connectivity Service
      final connectivityService = ServiceLocator.instance<ConnectivityService>();
      results['ConnectivityService'] = await _checkConnectivityService(connectivityService);
    } catch (e) {
      results['ConnectivityService'] = false;
    }

    try {
      // Check Notification Service
      final notificationService = ServiceLocator.instance<NotificationService>();
      results['NotificationService'] = await _checkNotificationService(notificationService);
    } catch (e) {
      results['NotificationService'] = false;
    }

    return results;
  }

  static Future<bool> _checkApiService(ApiService apiService) async {
    try {
      // Perform a simple health check endpoint call
      final response = await apiService.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkStorageService(StorageService storageService) async {
    try {
      // Test basic storage operations
      const testKey = '_health_check_test';
      const testValue = 'test_value';
      
      await storageService.setString(testKey, testValue);
      final retrievedValue = await storageService.getString(testKey);
      await storageService.remove(testKey);
      
      return retrievedValue == testValue;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkConnectivityService(ConnectivityService connectivityService) async {
    try {
      final hasConnection = await connectivityService.hasConnection();
      return hasConnection != null; // Just check if we get a result
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkNotificationService(NotificationService notificationService) async {
    try {
      // Check if notification service is initialized
      return notificationService.isInitialized();
    } catch (e) {
      return false;
    }
  }

  /// Print debug information about registered services
  static void _printRegisteredServices() {
    if (!AppConfig.isDebugMode) return;
    
    print('🔧 Service Locator - Registered Services:');
    print('- SharedPreferences: ${ServiceLocator.isRegistered<SharedPreferences>()}');
    print('- Dio: ${ServiceLocator.isRegistered<Dio>()}');
    print('- ApiService: ${ServiceLocator.isRegistered<ApiService>()}');
    print('- StorageService: ${ServiceLocator.isRegistered<StorageService>()}');
    print('- ConnectivityService: ${ServiceLocator.isRegistered<ConnectivityService>()}');
    print('- NotificationService: ${ServiceLocator.isRegistered<NotificationService>()}');
    print('- Connectivity: ${ServiceLocator.isRegistered<Connectivity>()}');
    print('- FlutterLocalNotificationsPlugin: ${ServiceLocator.isRegistered<FlutterLocalNotificationsPlugin>()}');
  }
}
