import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:elimuconnect_shared/shared.dart';
import '../services/user_service.dart';
import '../repositories/user_repository.dart';
import '../utils/response_helper.dart';
import '../middleware/auth_middleware.dart';

class UserHandler {
  final UserService _userService;
  late final Router _router;

  UserHandler() : _userService = UserService(UserRepository()) {
    _setupRoutes();
  }

  Router get router => _router;

  void _setupRoutes() {
    _router = Router()
      // Protected routes
      ..get('/', Pipeline().addMiddleware(authMiddleware).addHandler(_getUsers))
      ..get('/<id>', Pipeline().addMiddleware(authMiddleware).addHandler(_getUser))
      ..patch('/<id>', Pipeline().addMiddleware(authMiddleware).addHandler(_updateUser))
      ..delete('/<id>', Pipeline().addMiddleware(adminOnlyMiddleware).addHandler(_deleteUser))
      ..get('/<id>/profile', Pipeline().addMiddleware(authMiddleware).addHandler(_getUserProfile))
      
      // Search endpoints
      ..get('/search', Pipeline().addMiddleware(authMiddleware).addHandler(_searchUsers))
      
      // Role-specific endpoints
      ..get('/teachers', Pipeline().addMiddleware(authMiddleware).addHandler(_getTeachers))
      ..get('/students', Pipeline().addMiddleware(authMiddleware).addHandler(_getStudents))
      ..get('/parents', Pipeline().addMiddleware(authMiddleware).addHandler(_getParents));
  }

  Future<Response> _getUsers(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
      final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;
      final role = queryParams['role'];

      final users = await _userService.getUsers(
        page: page,
        limit: limit,
        role: role != null ? UserRole.values.firstWhere(
          (r) => r.toString().split('.').last == role,
          orElse: () => throw ArgumentError('Invalid role'),
        ) : null,
      );

      return ResponseHelper.success(
        data: users,
        message: 'Users retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getUser(Request request) async {
    try {
      final userId = request.params['id']!;
      final user = await _userService.getUserById(userId);

      if (user == null) {
        return ResponseHelper.notFound('User not found');
      }

      return ResponseHelper.success(
        data: user.toJson(),
        message: 'User retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _updateUser(Request request) async {
    try {
      final userId = request.params['id']!;
      final currentUser = request.context['user'] as UserModel;
      
      // Users can only update their own profile unless they're admin
      if (userId != currentUser.id && currentUser.role != UserRole.admin) {
        return ResponseHelper.forbidden('Cannot update other users');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final updatedUser = await _userService.updateUser(userId, data);

      return ResponseHelper.success(
        data: updatedUser.toJson(),
        message: 'User updated successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _deleteUser(Request request) async {
    try {
      final userId = request.params['id']!;
      await _userService.deleteUser(userId);

      return ResponseHelper.success(
        message: 'User deleted successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getUserProfile(Request request) async {
    try {
      final userId = request.params['id']!;
      final profile = await _userService.getUserProfile(userId);

      if (profile == null) {
        return ResponseHelper.notFound('User profile not found');
      }

      return ResponseHelper.success(
        data: profile,
        message: 'User profile retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _searchUsers(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final query = queryParams['q'] ?? '';
      final role = queryParams['role'];
      final schoolId = queryParams['schoolId'];

      if (query.isEmpty) {
        return ResponseHelper.badRequest('Search query is required');
      }

      final users = await _userService.searchUsers(
        query: query,
        role: role != null ? UserRole.values.firstWhere(
          (r) => r.toString().split('.').last == role,
          orElse: () => throw ArgumentError('Invalid role'),
        ) : null,
        schoolId: schoolId,
      );

      return ResponseHelper.success(
        data: users,
        message: 'Search completed successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getTeachers(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final schoolId = queryParams['schoolId'];
      final subject = queryParams['subject'];

      final teachers = await _userService.getTeachers(
        schoolId: schoolId,
        subject: subject,
      );

      return ResponseHelper.success(
        data: teachers,
        message: 'Teachers retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getStudents(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final schoolId = queryParams['schoolId'];
      final className = queryParams['class'];

      final students = await _userService.getStudents(
        schoolId: schoolId,
        className: className,
      );

      return ResponseHelper.success(
        data: students,
        message: 'Students retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getParents(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final schoolId = queryParams['schoolId'];

      final parents = await _userService.getParents(schoolId: schoolId);

      return ResponseHelper.success(
        data: parents,
        message: 'Parents retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }
}
