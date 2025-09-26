// packages/app/lib/src/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/service_locator.dart';
import '../../../services/storage_service.dart';
import '../../../services/api_service.dart';

// Auth state models
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final UserProfile? user;
  
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    UserProfile? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final Map<String, dynamic> additionalInfo;
  
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.additionalInfo = const {},
  });
  
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'student',
      additionalInfo: Map<String, dynamic>.from(map)
        ..removeWhere((key, value) => ['id', 'name', 'email', 'role'].contains(key)),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      ...additionalInfo,
    };
  }
}

// Registration request models
class AdminRegistrationRequest {
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
  
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'password': password,
    'admin_code': adminCode,
    'institution_id': institutionId,
    'role': 'admin',
  };
}

class TeacherRegistrationRequest {
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
  
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'password': password,
    'phone_number': phoneNumber,
    'tsc_number': tscNumber,
    'school_id': schoolId,
    'subjects_taught': subjectsTaught,
    'classes_assigned': classesAssigned,
    'qualification': qualification,
    'role': 'teacher',
  };
}

class StudentRegistrationRequest {
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
  
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'password': password,
    'admission_number': admissionNumber,
    'school_id': schoolId,
    'class_name': className,
    'date_of_birth': dateOfBirth.toIso8601String(),
    'parent_guardian_contact': parentGuardianContact,
    'county_of_residence': countyOfResidence,
    'role': 'student',
  };
}

class ParentRegistrationRequest {
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
  
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'password': password,
    'phone_number': phoneNumber,
    'national_id': nationalId,
    'children_admission_numbers': childrenAdmissionNumbers,
    'relationship_to_children': relationshipToChildren,
    'address': address,
    'role': 'parent',
  };
}

// Auth provider implementation
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;
  
  AuthNotifier({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService,
       super(const AuthState()) {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isAuthenticated = await _storageService.isAuthenticated();
      if (isAuthenticated) {
        final profileData = await _storageService.getUserProfile();
        if (profileData != null) {
          final user = UserProfile.fromMap(profileData);
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: user,
          );
          return;
        }
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication: $e',
      );
    }
  }
  
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        // Save tokens
        if (data['access_token'] != null && data['refresh_token'] != null) {
          await _storageService.saveAuthTokens(
            accessToken: data['access_token'],
            refreshToken: data['refresh_token'],
          );
        }
        
        // Save user profile
        if (data['user'] != null) {
          final userData = data['user'] as Map<String, dynamic>;
          await _storageService.saveUserProfile(userData);
          
          final user = UserProfile.fromMap(userData);
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: user,
          );
        }
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login error: $e',
      );
      return false;
    }
  }
  
  Future<bool> registerAdmin(AdminRegistrationRequest request) async {
    return _register(request.toMap());
  }
  
  Future<bool> registerTeacher(TeacherRegistrationRequest request) async {
    return _register(request.toMap());
  }
  
  Future<bool> registerStudent(StudentRegistrationRequest request) async {
    return _register(request.toMap());
  }
  
  Future<bool> registerParent(ParentRegistrationRequest request) async {
    return _register(request.toMap());
  }
  
  Future<bool> _register(Map<String, dynamic> registrationData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.register(
        name: registrationData['name'],
        email: registrationData['email'],
        password: registrationData['password'],
        role: registrationData['role'],
        additionalData: Map<String, dynamic>.from(registrationData)
          ..removeWhere((key, value) => ['name', 'email', 'password', 'role'].contains(key)),
      );
      
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        // Save tokens if provided (some APIs auto-login after registration)
        if (data['access_token'] != null && data['refresh_token'] != null) {
          await _storageService.saveAuthTokens(
            accessToken: data['access_token'],
            refreshToken: data['refresh_token'],
          );
          
          // Save user profile if provided
          if (data['user'] != null) {
            final userData = data['user'] as Map<String, dynamic>;
            await _storageService.saveUserProfile(userData);
            
            final user = UserProfile.fromMap(userData);
            state = state.copyWith(
              isAuthenticated: true,
              isLoading: false,
              user: user,
            );
          }
        } else {
          // Registration successful but not auto-logged in
          state = state.copyWith(isLoading: false);
        }
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration error: $e',
      );
      return false;
    }
  }
  
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Clear local storage
      await _storageService.clearAuthTokens();
      await _storageService.clearUserData();
      
      state = const AuthState();
    } catch (e) {
      print('Logout error: $e');
      // Even if there's an error, we should clear the state
      state = const AuthState();
    }
  }
  
  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.refreshToken();
      
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        if (data['access_token'] != null && data['refresh_token'] != null) {
          await _storageService.saveAuthTokens(
            accessToken: data['access_token'],
            refreshToken: data['refresh_token'],
          );
          return true;
        }
      }
      
      // If refresh fails, logout user
      await logout();
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
      return false;
    }
  }
  
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.updateUserProfile(profileData);
      
      if (response.isSuccess && response.data != null) {
        final userData = response.data!;
        await _storageService.saveUserProfile(userData);
        
        final user = UserProfile.fromMap(userData);
        state = state.copyWith(
          isLoading: false,
          user: user,
        );
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Profile update failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Profile update error: $e',
      );
      return false;
    }
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider definitions
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    apiService: ServiceLocator.get<ApiService>(),
    storageService: ServiceLocator.get<StorageService>(),
  );
});

// Computed providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.role;
});
