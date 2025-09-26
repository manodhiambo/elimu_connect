// packages/app/lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'storage_service.dart';

class ApiService {
  final Dio _dio;
  final StorageService _storageService;
  
  ApiService({
    required Dio dio,
    required StorageService storageService,
  }) : _dio = dio,
       _storageService = storageService {
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    // Request interceptor to add auth headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          print('🌐 ${options.method.toUpperCase()} ${options.uri}');
          if (options.data != null) {
            print('📤 Request: ${jsonEncode(options.data)}');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response ${response.statusCode}: ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ Error ${error.response?.statusCode}: ${error.requestOptions.uri}');
          
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            await _handleTokenExpiration();
            // Optionally retry the request with new token
            try {
              final newToken = await _storageService.getAccessToken();
              if (newToken != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final clonedRequest = await _dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );
                return handler.resolve(clonedRequest);
              }
            } catch (e) {
              print('Failed to retry request after token refresh: $e');
            }
          }
          
          handler.next(error);
        },
      ),
    );
  }
  
  Future<void> _handleTokenExpiration() async {
    await _storageService.clearAuthTokens();
    // You might want to navigate to login screen here
    // or emit an event for the app to handle
  }
  
  // Authentication endpoints
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
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        ...?additionalData,
      };
      
      final response = await _dio.post('/auth/register', data: data);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Registration failed');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        return ApiResponse.error('No refresh token available');
      }
      
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Token refresh failed');
    }
  }
  
  // User profile endpoints
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Failed to load profile');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _dio.put('/user/profile', data: profileData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Profile update failed');
    }
  }
  
  // Content endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getContent({
    String? subject,
    String? grade,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (subject != null) queryParams['subject'] = subject;
      if (grade != null) queryParams['grade'] = grade;
      if (type != null) queryParams['type'] = type;
      
      final response = await _dio.get('/content', queryParameters: queryParams);
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Failed to load content');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getContentById(String id) async {
    try {
      final response = await _dio.get('/content/$id');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Failed to load content details');
    }
  }
  
  // Assessment endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getQuizzes({
    String? subject,
    String? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (subject != null) queryParams['subject'] = subject;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      
      final response = await _dio.get('/quizzes', queryParameters: queryParams);
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Failed to load quizzes');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> submitQuizAnswer({
    required String quizId,
    required String questionId,
    required dynamic answer,
  }) async {
    try {
      final response = await _dio.post('/quizzes/$quizId/answers', data: {
        'question_id': questionId,
        'answer': answer,
      });
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Failed to submit answer');
    }
  }
  
  // File upload
  Future<ApiResponse<Map<String, dynamic>>> uploadFile(
    File file, {
    String? category,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (category != null) 'category': category,
        if (metadata != null) 'metadata': jsonEncode(metadata),
      });
      
      final response = await _dio.post('/upload', data: formData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('File upload failed');
    }
  }
  
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? error.response?.statusMessage;
        
        switch (statusCode) {
          case 400:
            return message ?? 'Bad request. Please check your input.';
          case 401:
            return 'Authentication failed. Please login again.';
          case 403:
            return 'Access denied. You don\'t have permission.';
          case 404:
            return 'Resource not found.';
          case 422:
            return message ?? 'Validation failed. Please check your input.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return message ?? 'Something went wrong. Please try again.';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
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
