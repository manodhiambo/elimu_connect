import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:elimuconnect_shared/shared.dart';
import '../services/school_service.dart';
import '../repositories/school_repository.dart';
import '../utils/response_helper.dart';
import '../middleware/auth_middleware.dart';

class SchoolHandler {
  final SchoolService _schoolService;
  late final Router _router;

  SchoolHandler() : _schoolService = SchoolService(SchoolRepository()) {
    _setupRoutes();
  }

  Router get router => _router;

  void _setupRoutes() {
    _router = Router()
      // Public routes
      ..get('/search', _searchSchools)
      
      // Protected routes
      ..get('/', Pipeline().addMiddleware(authMiddleware).addHandler(_getSchools))
      ..post('/', Pipeline().addMiddleware(adminOnlyMiddleware).addHandler(_createSchool))
      ..get('/<id>', Pipeline().addMiddleware(authMiddleware).addHandler(_getSchool))
      ..patch('/<id>', Pipeline().addMiddleware(adminOnlyMiddleware).addHandler(_updateSchool))
      ..delete('/<id>', Pipeline().addMiddleware(adminOnlyMiddleware).addHandler(_deleteSchool))
      
      // School-specific endpoints
      ..get('/<id>/teachers', Pipeline().addMiddleware(authMiddleware).addHandler(_getSchoolTeachers))
      ..get('/<id>/students', Pipeline().addMiddleware(authMiddleware).addHandler(_getSchoolStudents))
      ..get('/<id>/classes', Pipeline().addMiddleware(authMiddleware).addHandler(_getSchoolClasses));
  }

  Future<Response> _getSchools(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
      final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;
      final county = queryParams['county'];
      final schoolType = queryParams['type'];

      final schools = await _schoolService.getSchools(
        page: page,
        limit: limit,
        county: county != null ? County.values.firstWhere(
          (c) => c.toString().split('.').last == county,
          orElse: () => throw ArgumentError('Invalid county'),
        ) : null,
        schoolType: schoolType != null ? SchoolType.values.firstWhere(
          (t) => t.toString().split('.').last == schoolType,
          orElse: () => throw ArgumentError('Invalid school type'),
        ) : null,
      );

      return ResponseHelper.success(
        data: schools,
        message: 'Schools retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _createSchool(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final registrationRequest = SchoolRegistrationRequest.fromJson(data);
      final school = await _schoolService.createSchool(registrationRequest);

      return ResponseHelper.success(
        data: school.toJson(),
        message: 'School created successfully',
        statusCode: 201,
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getSchool(Request request) async {
    try {
      final schoolId = request.params['id']!;
      final school = await _schoolService.getSchoolById(schoolId);

      if (school == null) {
        return ResponseHelper.notFound('School not found');
      }

      return ResponseHelper.success(
        data: school.toJson(),
        message: 'School retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _updateSchool(Request request) async {
    try {
      final schoolId = request.params['id']!;
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final updatedSchool = await _schoolService.updateSchool(schoolId, data);

      return ResponseHelper.success(
        data: updatedSchool.toJson(),
        message: 'School updated successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _deleteSchool(Request request) async {
    try {
      final schoolId = request.params['id']!;
      await _schoolService.deleteSchool(schoolId);

      return ResponseHelper.success(
        message: 'School deleted successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _searchSchools(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final query = queryParams['q'] ?? '';
      final county = queryParams['county'];

      if (query.isEmpty) {
        return ResponseHelper.badRequest('Search query is required');
      }

      final schools = await _schoolService.searchSchools(
        query: query,
        county: county != null ? County.values.firstWhere(
          (c) => c.toString().split('.').last == county,
          orElse: () => throw ArgumentError('Invalid county'),
        ) : null,
      );

      return ResponseHelper.success(
        data: schools,
        message: 'Search completed successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getSchoolTeachers(Request request) async {
    try {
      final schoolId = request.params['id']!;
      final teachers = await _schoolService.getSchoolTeachers(schoolId);

      return ResponseHelper.success(
        data: teachers,
        message: 'School teachers retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getSchoolStudents(Request request) async {
    try {
      final schoolId = request.params['id']!;
      final queryParams = request.url.queryParameters;
      final className = queryParams['class'];

      final students = await _schoolService.getSchoolStudents(
        schoolId,
        className: className,
      );

      return ResponseHelper.success(
        data: students,
        message: 'School students retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }

  Future<Response> _getSchoolClasses(Request request) async {
    try {
      final schoolId = request.params['id']!;
      final classes = await _schoolService.getSchoolClasses(schoolId);

      return ResponseHelper.success(
        data: classes,
        message: 'School classes retrieved successfully',
      );
    } catch (e) {
      return ResponseHelper.handleError(e);
    }
  }
}
