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
