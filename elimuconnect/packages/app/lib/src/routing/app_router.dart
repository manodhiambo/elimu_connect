import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:elimuconnect_shared/shared.dart';
import '../core/providers/app_providers.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/registration_page.dart';
import '../features/dashboard/student_dashboard/presentation/pages/student_dashboard_page.dart';
import '../features/dashboard/teacher_dashboard/presentation/pages/teacher_dashboard_page.dart';
import '../features/dashboard/parent_dashboard/presentation/pages/parent_dashboard_page.dart';
import '../features/dashboard/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: RouteNames.home,
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.fullPath == RouteNames.login || 
                         state.fullPath == RouteNames.register;
      
      if (!isLoggedIn && !isLoggingIn) {
        return RouteNames.login;
      }
      
      if (isLoggedIn && isLoggingIn) {
        return _getHomeRouteForUser(authState.user);
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) {
          final user = ref.read(currentUserProvider);
          return _getDashboardForUser(user);
        },
      ),
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
      GoRoute(
        path: RouteNames.studentDashboard,
        name: 'studentDashboard',
        builder: (context, state) => const StudentDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.teacherDashboard,
        name: 'teacherDashboard',
        builder: (context, state) => const TeacherDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.parentDashboard,
        name: 'parentDashboard',
        builder: (context, state) => const ParentDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
    ],
  );
});

Widget _getDashboardForUser(user) {
  if (user == null) return const LoginPage();
  
  switch (user.role) {
    case UserRole.student:
      return const StudentDashboardPage();
    case UserRole.teacher:
      return const TeacherDashboardPage();
    case UserRole.parent:
      return const ParentDashboardPage();
    case UserRole.admin:
      return const AdminDashboardPage();
  }
}

String _getHomeRouteForUser(user) {
  if (user == null) return RouteNames.login;
  
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
