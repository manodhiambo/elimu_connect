class AppException implements Exception {
  final String message;
  final int statusCode;
  final String? code;

  AppException(this.message, {this.statusCode = 500, this.code});

  @override
  String toString() => 'AppException: $message';
}

class ValidationException extends AppException {
  ValidationException(String message) 
      : super(message, statusCode: 400, code: 'VALIDATION_ERROR');
}

class AuthenticationException extends AppException {
  AuthenticationException(String message) 
      : super(message, statusCode: 401, code: 'AUTHENTICATION_ERROR');
}

class AuthorizationException extends AppException {
  AuthorizationException(String message) 
      : super(message, statusCode: 403, code: 'AUTHORIZATION_ERROR');
}

class NotFoundException extends AppException {
  NotFoundException(String message) 
      : super(message, statusCode: 404, code: 'NOT_FOUND');
}

class DatabaseException extends AppException {
  DatabaseException(String message) 
      : super(message, statusCode: 500, code: 'DATABASE_ERROR');
}

class FileException extends AppException {
  FileException(String message) 
      : super(message, statusCode: 500, code: 'FILE_ERROR');
}

class NetworkException extends AppException {
  NetworkException(String message) 
      : super(message, statusCode: 502, code: 'NETWORK_ERROR');
}
