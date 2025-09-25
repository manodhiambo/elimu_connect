import 'dart:async';
import 'package:dio/dio.dart';
import 'package:elimuconnect_shared/shared.dart';
import 'storage_service.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();

  AuthService() 
    : _apiService = ApiService(),
      _storageService = StorageService();

  Stream<UserModel?> get authStateStream => _authStateController.stream;

  Future<void> registerAdmin(AdminRegistrationRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.registerAdminEndpoint,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        await _handleAuthSuccess(data);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> registerTeacher(TeacherRegistrationRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.registerTeacherEndpoint,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        await _handleAuthSuccess(data);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> registerStudent(StudentRegistrationRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.registerStudentEndpoint,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        await _handleAuthSuccess(data);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> registerParent(ParentRegistrationRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.registerParentEndpoint,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        await _handleAuthSuccess(data);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        await _handleAuthSuccess(data);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logoutEndpoint);
    } catch (e) {
      // Continue with logout even if server request fails
      print('Logout server error: $e');
    } finally {
      await _clearAuthState();
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return null;

      final response = await _apiService.get(ApiConstants.profileEndpoint);
      
      if (response.success && response.data != null) {
        final userData = response.data as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      await _clearAuthState();
      return null;
    }
  }

  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiService.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        await _storageService.saveToken(data['accessToken']);
        await _storageService.saveRefreshToken(data['refreshToken']);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      await _clearAuthState();
      throw e;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        ApiConstants.forgotPasswordEndpoint,
        data: {'email': email},
      );

      if (!response.success) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiService.post(
        ApiConstants.resetPasswordEndpoint,
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      if (!response.success) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    final user = UserModel.fromJson(data['user']);
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await _storageService.saveToken(accessToken);
    await _storageService.saveRefreshToken(refreshToken);
    await _storageService.saveUser(user);

    _authStateController.add(user);
  }

  Future<void> _clearAuthState() async {
    await _storageService.removeToken();
    await _storageService.removeRefreshToken();
    await _storageService.removeUser();
    _authStateController.add(null);
  }

  Exception _handleAuthError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map<String, dynamic>) {
        final errorData = error.response!.data as Map<String, dynamic>;
        return Exception(errorData['message'] ?? 'Authentication failed');
      }
      return Exception(error.message ?? 'Network error occurred');
    }
    return Exception(error.toString());
  }

  void dispose() {
    _authStateController.close();
  }
}
