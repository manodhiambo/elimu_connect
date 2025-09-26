#!/bin/bash

echo "🧹 Creating clean, working ElimuConnect project..."

# 1. Clean everything first
echo "Cleaning build artifacts..."
melos clean
find packages/app -name ".dart_tool" -type d -exec rm -rf {} + 2>/dev/null || true
find packages/app -name "build" -type d -exec rm -rf {} + 2>/dev/null || true
rm -rf packages/app/.dart_tool/
rm -rf packages/app/build/

# 2. Create minimal, working pubspec.yaml
echo "Creating clean pubspec.yaml..."
cat > packages/app/pubspec.yaml << 'EOF'
name: elimuconnect_app
description: ElimuConnect - Educational Platform for Kenya
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # HTTP & API
  dio: ^5.3.3
  
  # Storage
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.2.2
  
  # Dependency Injection
  get_it: ^7.6.4
  
  # UI & Design
  cupertino_icons: ^1.0.6
  
  # Utilities
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
EOF

# 3. Create directory structure
echo "Creating directory structure..."
mkdir -p packages/app/lib/core/di
mkdir -p packages/app/lib/services
mkdir -p packages/app/lib/src/providers
mkdir -p packages/app/lib/src/config
mkdir -p packages/app/assets/images

# 4. Create clean service_locator.dart
echo "Creating ServiceLocator..."
cat > packages/app/lib/core/di/service_locator.dart << 'EOF'
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
EOF

# 5. Create clean storage_service.dart
echo "Creating StorageService..."
cat > packages/app/lib/services/storage_service.dart << 'EOF'
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
EOF

# 6. Create clean api_service.dart
echo "Creating ApiService..."
cat > packages/app/lib/services/api_service.dart << 'EOF'
import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  final Dio _dio;
  final StorageService _storageService;
  
  ApiService({required Dio dio, required StorageService storageService}) 
    : _dio = dio, _storageService = storageService;

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error('Login failed: $e');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error('Failed to load profile: $e');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _dio.put('/user/profile', data: profileData);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error('Profile update failed: $e');
    }
  }
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;
  
  ApiResponse.success(this.data) : error = null, success = true;
  ApiResponse.error(this.error) : data = null, success = false;
  
  bool get isSuccess => success;
  bool get isError => !success;
}
EOF

# 7. Create simple auth provider
echo "Creating AuthProvider..."
cat > packages/app/lib/src/providers/auth_provider.dart << 'EOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/service_locator.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;
  
  AuthNotifier({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService,
       super(const AuthState()) {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final isAuth = await _storageService.isAuthenticated();
    state = state.copyWith(isAuthenticated: isAuth, isLoading: false);
  }
  
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _apiService.login(email: email, password: password);
    
    if (response.isSuccess && response.data != null) {
      await _storageService.saveAuthTokens(
        accessToken: response.data!['access_token'] ?? '',
        refreshToken: response.data!['refresh_token'] ?? '',
      );
      state = state.copyWith(isAuthenticated: true, isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Login failed', 
        isLoading: false
      );
      return false;
    }
  }
  
  Future<void> logout() async {
    await _storageService.clearAllData();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    apiService: ServiceLocator.get<ApiService>(),
    storageService: ServiceLocator.get<StorageService>(),
  );
});
EOF

# 8. Create clean main.dart
echo "Creating main.dart..."
cat > packages/app/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await ServiceLocator.init();
    print('✅ App initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize app: $e');
  }
  
  runApp(
    const ProviderScope(
      child: ElimuConnectApp(),
    ),
  );
}

class ElimuConnectApp extends ConsumerWidget {
  const ElimuConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ElimuConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ElimuConnect'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.school,
              size: 80,
              color: Color(0xFF1E88E5),
            ),
            SizedBox(height: 24),
            Text(
              'Welcome to ElimuConnect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Educational Platform for Kenya',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            Text(
              '🚀 Project successfully initialized!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ready to build amazing features!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        tooltip: 'Test App',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
EOF

# 9. Create minimal app config if referenced
mkdir -p packages/app/lib/src
cat > packages/app/lib/src/app.dart << 'EOF'
export '../main.dart';
EOF

echo ""
echo "🎯 Installation steps:"
echo "1. cd packages/app"
echo "2. flutter pub get"
echo "3. cd ../.."
echo "4. melos run web"
echo ""
echo "✅ Clean project setup complete!"
echo "This should compile without errors now."
