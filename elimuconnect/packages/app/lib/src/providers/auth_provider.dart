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
