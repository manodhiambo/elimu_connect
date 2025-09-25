import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/app_config.dart';
import '../repositories/user_repository.dart';
import '../utils/response_helper.dart';

Middleware authMiddleware = (Handler innerHandler) {
  return (Request request) async {
    final authHeader = request.headers['authorization'];
    
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return ResponseHelper.unauthorized('Missing or invalid authorization header');
    }

    try {
      final token = authHeader.substring(7); // Remove 'Bearer '
      final jwt = JWT.verify(token, SecretKey(AppConfig.jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      
      // Get user from database
      final userRepository = UserRepository();
      final user = await userRepository.findById(payload['userId']);
      
      if (user == null || !user.isActive) {
        return ResponseHelper.unauthorized('Invalid or inactive user');
      }

      // Add user to request context
      final updatedRequest = request.change(
        context: {
          ...request.context,
          'user': user,
          'jwt_payload': payload,
        },
      );

      return await innerHandler(updatedRequest);
    } catch (e) {
      return ResponseHelper.unauthorized('Invalid token');
    }
  };
};

Middleware roleMiddleware(List<UserRole> allowedRoles) {
  return (Handler innerHandler) {
    return (Request request) async {
      final user = request.context['user'] as UserModel?;
      
      if (user == null) {
        return ResponseHelper.unauthorized('Authentication required');
      }

      if (!allowedRoles.contains(user.role)) {
        return ResponseHelper.forbidden('Insufficient permissions');
      }

      return await innerHandler(request);
    };
  };
}

// Specific role middlewares
final adminOnlyMiddleware = roleMiddleware([UserRole.admin]);
final teacherOrAdminMiddleware = roleMiddleware([UserRole.teacher, UserRole.admin]);
final studentMiddleware = roleMiddleware([UserRole.student]);
final parentMiddleware = roleMiddleware([UserRole.parent]);
