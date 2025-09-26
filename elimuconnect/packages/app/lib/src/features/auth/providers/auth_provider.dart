// File: packages/app/lib/src/features/auth/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import '../core/di/service_locator.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

// Models for authentication
enum UserRole { 
  student, 
  teacher, 
  parent, 
  admin 
}

enum AuthStatus { 
  initial, 
  loading, 
  authenticated, 
  unauthenticated, 
  error 
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? schoolId;
  final String? profileImageUrl;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.schoolId,
    this.profileImageUrl,
    this.metadata = const {},
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.student,
      ),
      schoolId: json['school_id'],
      profileImageUrl: json['profile_image_url'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: DateTime.parse(json['last_login_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'school_id': schoolId,
      'profile_image_url': profileImageUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? schoolId,
    String? profileImageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.isLoading = false,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading, isLoading: true);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  factory AuthState.error(String error) {
    return AuthState(status: AuthStatus.error, error: error);
  }

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error && error != null;
}

// Registration request models
abstract class RegistrationRequest {
  Map<String, dynamic> toJson();
}

class StudentRegistrationRequest implements RegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String admissionNumber;
  final String schoolId;
  final String className;
  final DateTime dateOfBirth;
  final String parentGuardianContact;
  final String countyOfResidence;

  const StudentRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.admissionNumber,
    required this.schoolId,
    required this.className,
    required this.dateOfBirth,
    required this.parentGuardianContact,
    required this.countyOfResidence,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': 'student',
      'admission_number': admissionNumber,
      'school_id': schoolId,
      'class_name': className,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'parent_guardian_contact': parentGuardianContact,
      'county_of_residence': countyOfResidence,
    };
  }
}

class TeacherRegistrationRequest implements RegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String tscNumber;
  final String schoolId;
  final List<String> subjectsTaught;
  final List<String> classesAssigned;
  final String qualification;

  const TeacherRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.tscNumber,
    required this.schoolId,
    required this.subjectsTaught,
    required this.classesAssigned,
    required this.qualification,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': 'teacher',
      'phone_number': phoneNumber,
      'tsc_number': tscNumber,
      'school_id': schoolId,
      'subjects_taught': subjectsTaught,
      'classes_assigned': classesAssigned,
      'qualification': qualification,
    };
  }
}

class ParentRegistrationRequest implements RegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String nationalId;
  final List<String> childrenAdmissionNumbers;
  final String relationshipToChildren;
  final String address;

  const ParentRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.nationalId,
    required this.childrenAdmissionNumbers,
    required this.relationshipToChildren,
    required this.address,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': 'parent',
      'phone_number': phoneNumber,
      'national_id': nationalId,
      'children_admission_numbers': childrenAdmissionNumbers,
      'relationship_to_children': relationshipToChildren,
      'address': address,
    };
  }
}

class AdminRegistrationRequest implements RegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String adminCode;
  final String institutionId;

  const AdminRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.adminCode,
    required this.institutionId,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': 'admin',
      'admin_code': adminCode,
      'institution_id': institutionId,
    };
  }
}

// Authentication Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthNotifier({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService,
        super(AuthState.initial());

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  /// Initialize authentication state from stored tokens
  Future<void> initialize() async {
    try {
      state = AuthState.loading();

      final token = await _storageService.getString(_tokenKey);
      final refreshToken = await _storageService.getString(_refreshTokenKey);
      final userData = await _storageService.getString(_userKey);

      if (token == null || userData == null) {
        state = AuthState.unauthenticated();
        return;
      }

      // Parse stored user data
      final userJson = jsonDecode(userData);
      final user = User.fromJson(userJson);

      // Verify token validity
      final isValid = await _verifyToken(token);
      if (!isValid) {
        // Try to refresh token
        if (refreshToken != null) {
          final refreshed = await _refreshAuthToken(refreshToken);
          if (!refreshed) {
            await _clearAuthData();
            state = AuthState.unauthenticated();
            return;
          }
        } else {
          await _clearAuthData();
          state = AuthState.unauthenticated();
          return;
        }
      }

      // Set API authorization header
      _apiService.setAuthToken(token);
      state = AuthState.authenticated(user);

    } catch (e) {
      await _clearAuthData();
      state = AuthState.error('Failed to initialize authentication: $e');
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, status: AuthStatus.loading);

      final response = await _apiService.post('/auth/login', data: {
        'email': email.toLowerCase().trim(),
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Extract tokens and user data
        final token = data['token'];
        final refreshToken = data['refresh_token'];
        final userData = data['user'];
        
        if (token == null || userData == null) {
          state = AuthState.error('Invalid response from server');
          return false;
        }

        // Create user object
        final user = User.fromJson(userData);

        // Store auth data
        await _storeAuthData(token, refreshToken, user);

        // Set API authorization header
        _apiService.setAuthToken(token);

        // Update state
        state = AuthState.authenticated(user);
        
        return true;
      } else {
        final errorMsg = response.data?['message'] ?? 'Login failed';
        state = AuthState.error(errorMsg);
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? 'Network error occurred';
        state = AuthState.error(errorMsg);
      } else {
        state = AuthState.error('Login failed: $e');
      }
      return false;
    }
  }

  /// Register a new user with role-specific data
  Future<bool> register(RegistrationRequest request) async {
    try {
      state = state.copyWith(isLoading: true, status: AuthStatus.loading);

      final response = await _apiService.post('/auth/register', 
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        
        // Some implementations return tokens immediately after registration
        if (data['token'] != null && data['user'] != null) {
          final token = data['token'];
          final refreshToken = data['refresh_token'];
          final userData = data['user'];
          
          final user = User.fromJson(userData);
          await _storeAuthData(token, refreshToken, user);
          _apiService.setAuthToken(token);
          state = AuthState.authenticated(user);
        } else {
          // Registration successful, but requires email verification
          state = AuthState.unauthenticated();
        }
        
        return true;
      } else {
        final errorMsg = response.data?['message'] ?? 'Registration failed';
        state = AuthState.error(errorMsg);
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? 'Network error occurred';
        state = AuthState.error(errorMsg);
      } else {
        state = AuthState.error('Registration failed: $e');
      }
      return false;
    }
  }

  /// Logout user and clear all stored data
  Future<void> logout() async {
    try {
      // Call logout endpoint
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _clearAuthData();
      _apiService.clearAuthToken();
      state = AuthState.unauthenticated();
    }
  }

  /// Refresh authentication state (check if still valid)
  Future<void> refreshAuthState() async {
    if (!state.isAuthenticated) return;

    try {
      final token = await _storageService.getString(_tokenKey);
      if (token == null) {
        await logout();
        return;
      }

      final isValid = await _verifyToken(token);
      if (!isValid) {
        final refreshToken = await _storageService.getString(_refreshTokenKey);
        if (refreshToken != null) {
          final refreshed = await _refreshAuthToken(refreshToken);
          if (!refreshed) {
            await logout();
          }
        } else {
          await logout();
        }
      }
    } catch (e) {
      // Handle silently, maintain current state
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (!state.isAuthenticated) return false;

      state = state.copyWith(isLoading: true);

      final response = await _apiService.put('/user/profile', data: updates);

      if (response.statusCode == 200) {
        final updatedUserData = response.data['user'];
        final updatedUser = User.fromJson(updatedUserData);
        
        // Update stored user data
        await _storageService.setString(_userKey, jsonEncode(updatedUser.toJson()));
        
        state = AuthState.authenticated(updatedUser);
        return true;
      } else {
        state = state.copyWith(isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// Change user password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      if (!state.isAuthenticated) return false;

      final response = await _apiService.post('/auth/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.post('/auth/forgot-password', data: {
        'email': email.toLowerCase().trim(),
      });

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiService.post('/auth/reset-password', data: {
        'token': token,
        'new_password': newPassword,
      });

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Verify email with token
  Future<bool> verifyEmail(String token) async {
    try {
      final response = await _apiService.post('/auth/verify-email', data: {
        'token': token,
      });

      if (response.statusCode == 200) {
        // If user data is returned, update current user
        final userData = response.data['user'];
        if (userData != null && state.user != null) {
          final updatedUser = User.fromJson(userData);
          await _storageService.setString(_userKey, jsonEncode(updatedUser.toJson()));
          state = AuthState.authenticated(updatedUser);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get dashboard route based on user role
  String getDashboardRoute() {
    if (!state.isAuthenticated || state.user == null) {
      return '/login';
    }

    switch (state.user!.role) {
      case UserRole.student:
        return '/dashboard/student';
      case UserRole.teacher:
        return '/dashboard/teacher';
      case UserRole.parent:
        return '/dashboard/parent';
      case UserRole.admin:
        return '/dashboard/admin';
    }
  }

  /// Check if user has permission for a specific action
  bool hasPermission(String permission) {
    if (!state.isAuthenticated || state.user == null) return false;

    // Define role-based permissions
    final rolePermissions = {
      UserRole.student: [
        'read_content',
        'take_assessments',
        'view_progress',
        'send_messages',
      ],
      UserRole.teacher: [
        'read_content',
        'create_content',
        'create_assessments',
        'grade_assessments',
        'view_class_progress',
        'send_messages',
        'manage_classes',
      ],
      UserRole.parent: [
        'view_child_progress',
        'send_messages',
        'schedule_meetings',
      ],
      UserRole.admin: [
        'manage_users',
        'manage_schools',
        'manage_content',
        'view_analytics',
        'system_settings',
      ],
    };

    final userPermissions = rolePermissions[state.user!.role] ?? [];
    return userPermissions.contains(permission);
  }

  // Private helper methods

  Future<void> _storeAuthData(String token, String? refreshToken, User user) async {
    await _storageService.setString(_tokenKey, token);
    if (refreshToken != null) {
      await _storageService.setString(_refreshTokenKey, refreshToken);
    }
    await _storageService.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearAuthData() async {
    await _storageService.remove(_tokenKey);
    await _storageService.remove(_refreshTokenKey);
    await _storageService.remove(_userKey);
  }

  Future<bool> _verifyToken(String token) async {
    try {
      final response = await _apiService.get('/auth/verify-token', 
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _refreshAuthToken(String refreshToken) async {
    try {
      final response = await _apiService.post('/auth/refresh-token', data: {
        'refresh_token': refreshToken,
      });

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refresh_token'];
        
        await _storageService.setString(_tokenKey, newToken);
        if (newRefreshToken != null) {
          await _storageService.setString(_refreshTokenKey, newRefreshToken);
        }
        
        _apiService.setAuthToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

// Provider definitions
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    apiService: ServiceLocator.instance<ApiService>(),
    storageService: ServiceLocator.instance<StorageService>(),
  );
});

// Utility providers
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

final dashboardRouteProvider = Provider<String>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.getDashboardRoute();
});

// Permission checking provider
final permissionProvider = Provider.family<bool, String>((ref, permission) {
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.hasPermission(permission);
});
