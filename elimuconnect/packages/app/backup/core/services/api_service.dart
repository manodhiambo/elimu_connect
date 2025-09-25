import 'package:dio/dio.dart';
import 'package:elimuconnect_shared/shared.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService = StorageService();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseURL: ApiConstants.apiBaseUrl,
      connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
      sendTimeout: Duration(seconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor to add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final options = error.requestOptions;
            final token = await _storageService.getToken();
            options.headers['Authorization'] = 'Bearer $token';
            
            try {
              final response = await _dio.fetch(options);
              handler.resolve(response);
              return;
            } catch (e) {
              // If retry fails, continue with original error
            }
          }
        }
        handler.next(error);
      },
    ));

    // Logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj),
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _storageService.saveToken(data['accessToken']);
        await _storageService.saveRefreshToken(data['refreshToken']);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // File upload method
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? filename,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();
      
      // Add file
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(filePath, filename: filename),
      ));
      
      // Add additional data
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _parseResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Download file method
  Future<void> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  ApiResponse<T> _parseResponse<T>(Response response) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<T>(
        success: data['success'] ?? true,
        message: data['message'] ?? 'Success',
        data: data['data'] as T?,
        errors: data['errors'] as Map<String, dynamic>?,
        statusCode: response.statusCode,
        timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      );
    } else {
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: response.data as T?,
        statusCode: response.statusCode,
        timestamp: DateTime.now(),
      );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please check your internet connection.');
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          if (data is Map<String, dynamic> && data['message'] != null) {
            return Exception(data['message']);
          }
          
          switch (statusCode) {
            case 400:
              return Exception('Invalid request. Please check your input.');
            case 401:
              return Exception('Authentication required. Please login again.');
            case 403:
              return Exception('Access forbidden. You don\'t have permission.');
            case 404:
              return Exception('Resource not found.');
            case 422:
              return Exception('Validation failed. Please check your input.');
            case 429:
              return Exception('Too many requests. Please try again later.');
            case 500:
              return Exception('Server error. Please try again later.');
            case 502:
              return Exception('Service temporarily unavailable.');
            case 503:
              return Exception('Service temporarily unavailable.');
            default:
              return Exception('An error occurred. Please try again.');
          }
        
        case DioExceptionType.cancel:
          return Exception('Request was cancelled.');
        
        case DioExceptionType.badCertificate:
          return Exception('Certificate verification failed.');
        
        case DioExceptionType.connectionError:
          return Exception('Connection error. Please check your internet connection.');
        
        case DioExceptionType.unknown:
        default:
          if (error.message?.contains('SocketException') == true) {
            return Exception('No internet connection. Please check your network.');
          }
          if (error.message?.contains('HandshakeException') == true) {
            return Exception('Secure connection failed.');
          }
          return Exception('Network error. Please try again.');
      }
    }
    
    return Exception(error.toString());
  }

  // Clear all stored tokens (useful for logout)
  Future<void> clearTokens() async {
    await _storageService.removeToken();
    await _storageService.removeRefreshToken();
  }

  // Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Add custom headers
  void addHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  // Remove custom headers
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  // Get current headers
  Map<String, dynamic> get headers => _dio.options.headers;

  // Close the client
  void close() {
    _dio.close();
  }
}
