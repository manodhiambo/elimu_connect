import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_shared/shared.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Auth state provider
final authStateProvider = StreamProvider<UserModel?>((ref) async* {
  final authService = ref.read(authServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  
  // Check for stored token on app start
  final token = await storageService.getToken();
  if (token != null) {
    try {
      final user = await authService.getCurrentUser();
      yield user;
    } catch (e) {
      // Token is invalid, remove it
      await storageService.removeToken();
      yield null;
    }
  } else {
    yield null;
  }
  
  // Listen to auth state changes
  await for (final user in authService.authStateStream) {
    yield user;
  }
});

// Current user provider
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value;
});

// Authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// User role provider
final userRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

// Admin check provider
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.admin;
});

// Teacher check provider
final isTeacherProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.teacher;
});

// Student check provider
final isStudentProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.student;
});

// Parent check provider
final isParentProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.parent;
});

// Loading state provider for auth operations
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Error state provider for auth operations
final authErrorProvider = StateProvider<String?>((ref) => null);

// Login provider
final loginProvider = Provider<Future<void> Function(String email, String password)>((ref) {
  final authService = ref.read(authServiceProvider);
  
  return (String email, String password) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    
    try {
      await authService.login(email, password);
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  };
});

// Registration provider
final registerProvider = Provider<Future<void> Function(dynamic request, UserRole role)>((ref) {
  final authService = ref.read(authServiceProvider);
  
  return (dynamic request, UserRole role) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    
    try {
      switch (role) {
        case UserRole.admin:
          await authService.registerAdmin(request as AdminRegistrationRequest);
          break;
        case UserRole.teacher:
          await authService.registerTeacher(request as TeacherRegistrationRequest);
          break;
        case UserRole.student:
          await authService.registerStudent(request as StudentRegistrationRequest);
          break;
        case UserRole.parent:
          await authService.registerParent(request as ParentRegistrationRequest);
          break;
      }
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  };
});

// Logout provider
final logoutProvider = Provider<Future<void> Function()>((ref) {
  final authService = ref.read(authServiceProvider);
  
  return () async {
    ref.read(authLoadingProvider.notifier).state = true;
    
    try {
      await authService.logout();
    } catch (e) {
      // Even if logout fails on server, clear local state
      print('Logout error: $e');
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  };
});
