#!/bin/bash

# Ultimate fix for the final compilation issues
set -e

echo "🔧 Applying ultimate fixes..."

cd /home/manodhiambo/elimu_connect/elimuconnect

# 1. Fix app_router.dart - add missing import
cat > packages/app/lib/src/routing/app_router.dart << 'EOF'
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
EOF

# 2. Fix login_page.dart - add missing import
cat > packages/app/lib/src/features/auth/presentation/pages/login_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';
import 'package:elimuconnect_shared/shared.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../routing/route_names.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return AppScaffold(
      title: 'Login',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.school,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to ElimuConnect',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => AuthValidators.validateEmail(value),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) => AuthValidators.validatePassword(value),
              ),
              const SizedBox(height: 24),
              
              PrimaryButton(
                text: 'Login',
                isLoading: authState.status == AuthStatus.loading,
                onPressed: _login,
                width: double.infinity,
              ),
              
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authState.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () => context.go(RouteNames.register),
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(authStateProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }
}
EOF

# 3. Fix the shared package exports
cat > packages/shared/lib/shared.dart << 'EOF'
library elimuconnect_shared;

// User models
export 'src/models/user/user_model.dart';
export 'src/models/user/student_model.dart';
export 'src/models/user/teacher_model.dart';
export 'src/models/user/parent_model.dart';
export 'src/models/user/admin_model.dart';

// Common models
export 'src/models/common/enums.dart';

// Constants
export 'src/constants/app_constants.dart';
export 'src/constants/kenya_curriculum.dart';

// Utilities
export 'src/utils/date_utils.dart';
export 'src/utils/string_utils.dart';

// Validators
export 'src/validators/auth_validators.dart';
export 'src/validators/kenya_specific_validators.dart';
EOF

# 4. Fix the auth validators to import AppConstants
cat > packages/shared/lib/src/validators/auth_validators.dart << 'EOF'
import '../constants/app_constants.dart';

class AuthValidators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    if (email.length > AppConstants.maxEmailLength) {
      return 'Email is too long';
    }
    
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (name.length > AppConstants.maxNameLength) {
      return 'Name is too long';
    }
    
    if (!name.contains(RegExp(r'^[a-zA-Z\s]+$'))) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }
  
  static String? validateAdminCode(String? code) {
    if (code == null || code.isEmpty) {
      return 'Admin registration code is required';
    }
    
    if (code != AppConstants.adminRegistrationCode) {
      return 'Invalid admin registration code';
    }
    
    return null;
  }
}
EOF

# 5. Ensure AppConstants is properly defined
cat > packages/shared/lib/src/constants/app_constants.dart << 'EOF'
class AppConstants {
  static const String appName = 'ElimuConnect';
  static const String appVersion = '1.0.0';
  static const String adminRegistrationCode = 'OnlyMe@2025';
  
  // API Constants
  static const String baseApiUrl = 'https://api.elimuconnect.ke';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  
  // File Upload Constants
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
}
EOF

# 6. Create a minimal working main.dart if the current one is complex
cat > packages/app/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';

void main() {
  runApp(const ProviderScope(child: ElimuConnectApp()));
}
EOF

# 7. Create a simple app.dart without complex initialization
cat > packages/app/lib/src/app.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';
import 'core/providers/app_providers.dart';
import 'routing/app_router.dart';

class ElimuConnectApp extends ConsumerWidget {
  const ElimuConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'ElimuConnect',
      debugShowCheckedModeBanner: false,
      theme: ElimuTheme.lightTheme,
      darkTheme: ElimuTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
EOF

echo "Building packages in correct order..."

cd packages/shared
flutter pub get

cd ../design_system
flutter pub get

cd ../app
flutter clean
flutter pub get

echo "Ultimate fixes applied! The app should now compile and run."
echo "Try: flutter run"
