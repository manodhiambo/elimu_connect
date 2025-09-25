import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:elimuconnect_shared/shared.dart';
import '../services/auth_service.dart';
import '../utils/response_helper.dart';
import '../middleware/auth_middleware.dart';
import 'package:elimuconnect_shared/src/models/user/admin_model.dart';

class AuthHandler {
  final AuthService _authService;
  late final Router _router;

  AuthHandler() : _authService = AuthService(UserRepository()) {
    _setupRoutes();
  }

  Router get router => _router;

  void _setupRoutes() {
    _router = Router()
      // Public routes
      ..post('/register/admin', _registerAdmin)
      ..post('/register/teacher', _registerTeacher)
      ..post('/register/student', _registerStudent)
      ..post('/register/parent', _registerParent)
      ..post('/login', _login)
      ..post('/refresh', _refreshToken)
      ..post('/forgot-password', _forgotPassword)
      ..post('/reset-password', _resetPassword)
      
      // Protected routes
      ..get('/me', Pipeline().addMiddleware(authMiddleware).addHandler(_getProfile))
      ..post('/logout', Pipeline().addMiddleware(authMiddleware).addHandler(_logout))
      ..patch('/profile', Pipeline().addMiddleware(authMiddleware).addHandler(_updateProfile));
  }

  Future<Response> _registerAdmin(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final registrationRequest = AdminRegistrationRequest.fromJson(data);
      final result = await _authService.registerAdmin(registrationRequest);
      
      return ResponseHelper.success(
        data: {
          'user': result.user.toJson(),
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
        },
        message: 'Admin registration successful',
        statusCode: 201,
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _registerTeacher(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final registrationRequest = TeacherRegistrationRequest.fromJson(data);
      final result = await _authService.registerTeacher(registrationRequest);
      
      return ResponseHelper.success(
        data: {
          'user': result.user.toJson(),
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
        },
        message: 'Teacher registration successful',
        statusCode: 201,
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _registerStudent(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final registrationRequest = StudentRegistrationRequest.fromJson(data);
      final result = await _authService.registerStudent(registrationRequest);
      
      return ResponseHelper.success(
        data: {
          'user': result.user.toJson(),
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
        },
        message: 'Student registration successful',
        statusCode: 201,
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _registerParent(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final registrationRequest = ParentRegistrationRequest.fromJson(data);
      final result = await _authService.registerParent(registrationRequest);
      
      return ResponseHelper.success(
        data: {
          'user': result.user.toJson(),
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
        },
        message: 'Parent registration successful',
        statusCode: 201,
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _login(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final email = data['email'] as String;
      final password = data['password'] as String;
      
      final result = await _authService.login(email, password);
      
      return ResponseHelper.success(
        data: {
          'user': result.user.toJson(),
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
        },
        message: 'Login successful',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _refreshToken(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final refreshToken = data['refreshToken'] as String;
      final result = await _authService.refreshToken(refreshToken);
      
      return ResponseHelper.success(
        data: {
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
        },
        message: 'Token refreshed successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _forgotPassword(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final email = data['email'] as String;
      await _authService.forgotPassword(email);
      
      return ResponseHelper.success(
        message: 'Password reset email sent',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _resetPassword(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final token = data['token'] as String;
      final newPassword = data['newPassword'] as String;
      
      await _authService.resetPassword(token, newPassword);
      
      return ResponseHelper.success(
        message: 'Password reset successful',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getProfile(Request request) async {
    try {
      final user = request.context['user'] as UserModel;
      final profile = await _authService.getProfile(user.id);
      
      return ResponseHelper.success(
        data: profile,
        message: 'Profile retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _logout(Request request) async {
    try {
      final user = request.context['user'] as UserModel;
      await _authService.logout(user.id);
      
      return ResponseHelper.success(
        message: 'Logged out successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _updateProfile(Request request) async {
    try {
      final user = request.context['user'] as UserModel;
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final updatedProfile = await _authService.updateProfile(user.id, data);
      
      return ResponseHelper.success(
        data: updatedProfile,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }
}
