import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/registration_page.dart';
import '../features/dashboard/presentation/pages/student_dashboard.dart';
import '../features/dashboard/presentation/pages/teacher_dashboard.dart';
import '../features/dashboard/presentation/pages/parent_dashboard.dart';
import '../features/dashboard/presentation/pages/admin_dashboard.dart';
import '../features/library/presentation/pages/library_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../core/providers/auth_providers.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: RouteNames.login,
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isLoggingIn = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register;
      
      if (!isLoggedIn && !isLoggingIn) {
        return RouteNames.login;
      }
      
      if (isLoggedIn && isLoggingIn) {
        final user = authState.asData!.value!;
        switch (user.role) {
          case UserRole.student:
            return RouteNames.studentDashboard;
          case UserRole.teacher:
            return RouteNames.teacherDashboard;
          case UserRole.parent:
            return RouteNames.parentDashboard;
          case UserRole.admin:
            return RouteNames.adminDashboard;
        }
      }
      
      return null;
    },
    routes: [
      // Authentication Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegistrationPage(),
      ),
      
      // Dashboard Routes
      GoRoute(
        path: RouteNames.studentDashboard,
        name: 'student_dashboard',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: RouteNames.teacherDashboard,
        name: 'teacher_dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: RouteNames.parentDashboard,
        name: 'parent_dashboard',
        builder: (context, state) => const ParentDashboard(),
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        name: 'admin_dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      
      // Feature Routes
      GoRoute(
        path: RouteNames.library,
        name: 'library',
        builder: (context, state) => const LibraryPage(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
