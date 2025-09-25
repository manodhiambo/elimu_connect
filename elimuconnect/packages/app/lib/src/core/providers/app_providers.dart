// File: packages/app/lib/src/core/providers/app_providers.dart (Updated)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_shared/shared.dart';

// Theme provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Auth providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// User provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

// Auth State Management
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });
  
  const AuthState.initial() : status = AuthStatus.initial, user = null, errorMessage = null;
  
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(const AuthState.initial());
  
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
  
  Future<void> registerAdmin(AdminRegistrationRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.registerAdmin(request);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
  
  Future<void> registerTeacher(TeacherRegistrationRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.registerTeacher(request);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
  
  Future<void> registerStudent(StudentRegistrationRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.registerStudent(request);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
  
  Future<void> registerParent(ParentRegistrationRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.registerParent(request);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState.initial();
  }
}

// Enhanced AuthService with all registration types
class AuthService {
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    return User(
      id: 'user_123',
      name: 'Test User',
      email: email,
      role: _getUserRoleFromEmail(email),
      status: UserStatus.active,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  Future<User> registerAdmin(AdminRegistrationRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (request.adminCode != AppConstants.adminRegistrationCode) {
      throw Exception('Invalid admin registration code');
    }
    
    final now = DateTime.now();
    return Admin(
      id: 'admin_${now.millisecondsSinceEpoch}',
      name: request.name,
      email: request.email,
      createdAt: now,
      updatedAt: now,
      institutionId: request.institutionId,
      permissions: ['full_access'],
    );
  }
  
  Future<User> registerTeacher(TeacherRegistrationRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    return Teacher(
      id: 'teacher_${now.millisecondsSinceEpoch}',
      name: request.name,
      email: request.email,
      phoneNumber: request.phoneNumber,
      createdAt: now,
      updatedAt: now,
      tscNumber: request.tscNumber,
      schoolId: request.schoolId,
      subjectsTaught: request.subjectsTaught,
      classesAssigned: request.classesAssigned,
      qualification: request.qualification,
      countyOfWork: request.countyOfWork,
    );
  }
  
  Future<User> registerStudent(StudentRegistrationRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    return Student(
      id: 'student_${now.millisecondsSinceEpoch}',
      name: request.name,
      email: request.email,
      createdAt: now,
      updatedAt: now,
      admissionNumber: request.admissionNumber,
      schoolId: request.schoolId,
      className: request.className,
      dateOfBirth: request.dateOfBirth,
      parentGuardianContact: request.parentGuardianContact,
      countyOfResidence: request.countyOfResidence,
    );
  }
  
  Future<User> registerParent(ParentRegistrationRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    return Parent(
      id: 'parent_${now.millisecondsSinceEpoch}',
      name: request.name,
      email: request.email,
      phoneNumber: request.phoneNumber,
      createdAt: now,
      updatedAt: now,
      nationalId: request.nationalId,
      childrenAdmissionNumbers: request.childrenAdmissionNumbers,
      relationshipToChildren: request.relationshipToChildren,
      address: request.address,
      countyOfResidence: request.countyOfResidence,
    );
  }
  
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  UserRole _getUserRoleFromEmail(String email) {
    if (email.contains('admin')) return UserRole.admin;
    if (email.contains('teacher')) return UserRole.teacher;
    if (email.contains('parent')) return UserRole.parent;
    return UserRole.student;
  }
}
