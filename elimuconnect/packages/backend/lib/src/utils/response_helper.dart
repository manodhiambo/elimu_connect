import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:elimuconnect_shared/shared.dart';
import 'exceptions.dart';

class ResponseHelper {
  static Response success({
    dynamic data,
    String message = 'Success',
    int statusCode = 200,
  }) {
    final response = ApiResponse.success(
      message: message,
      data: data,
      statusCode: statusCode,
    );

    return Response.ok(
      jsonEncode(response.toJson((data) => data)),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response error({
    required String message,
    int statusCode = 500,
    Map<String, dynamic>? errors,
    String? code,
  }) {
    final response = ApiResponse.error(
      message: message,
      statusCode: statusCode,
      errors: errors ?? {},
    );

    return Response(
      statusCode,
      body: jsonEncode(response.toJson((data) => data)),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response handleError(dynamic error) {
    if (error is AppException) {
      return ResponseHelper.error(
        message: error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }

    // Log unexpected errors
    print('Unexpected error: $error');
    
    return ResponseHelper.error(
      message: 'Internal server error',
      statusCode: 500,
    );
  }

  static Response badRequest(String message, [Map<String, dynamic>? errors]) {
    return error(
      message: message,
      statusCode: 400,
      errors: errors,
    );
  }

  static Response unauthorized(String message) {
    return error(
      message: message,
      statusCode: 401,
    );
  }

  static Response forbidden(String message) {
    return error(
      message: message,
      statusCode: 403,
    );
  }

  static Response notFound(String message) {
    return error(
      message: message,
      statusCode: 404,
    );
  }

  static Response conflict(String message) {
    return error(
      message: message,
      statusCode: 409,
    );
  }
}
