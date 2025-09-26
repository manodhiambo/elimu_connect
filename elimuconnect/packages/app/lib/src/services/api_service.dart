// File: packages/app/lib/src/services/api_service.dart

import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import '../config/environment.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor - add auth headers
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        // Add request logging in debug mode
        if (Environment.isDevelopment) {
          print('🔵 Request: ${options.method} ${options.path}');
          print('📝 Headers: ${options.headers}');
          if (options.data != null) {
            print('📦 Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        // Log response in debug mode
        if (Environment.isDevelopment) {
          print('✅ Response: ${response.statusCode} ${response.requestOptions.path}');
          print('📦 Data: ${response.data}');
        }
        handler.next(response);
      },
      
      onError: (error, handler) {
        // Log errors
        if (Environment.isDevelopment) {
          print('❌ Error: ${error.message}');
          print('🔍 Response: ${error.response?.data}');
        }

        // Handle token expiration
        if (error.response?.statusCode == 401) {
          // Clear token and redirect to login
          _authToken = null;
          // You can emit an event here to notify the auth provider
        }
        
        handler.next(error);
      },
    ));

    // Retry interceptor
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Generic request methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // File upload method
  Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData();
    
    // Add file
    formData.files.add(MapEntry(
      fieldName,
      await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    ));

    // Add additional fields
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  // File download method
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) {
    return _dio.download(
      path,
      savePath,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}

// Retry interceptor for network resilience
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    
    if (_shouldRetry(err) && requestOptions.extra['retryCount'] != null) {
      final retryCount = requestOptions.extra['retryCount'] as int;
      
      if (retryCount < retries) {
        requestOptions.extra['retryCount'] = retryCount + 1;
        
        // Wait before retry
        final delayIndex = retryCount.clamp(0, retryDelays.length - 1);
        await Future.delayed(retryDelays[delayIndex]);
        
        try {
          final response = await dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to the original error handling
        }
      }
    }
    
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['retryCount'] == null) {
      options.extra['retryCount'] = 0;
    }
    handler.next(options);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors, timeouts, and 5xx server errors
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}
