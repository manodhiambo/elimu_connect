// File: packages/app/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/config/app_config.dart';
import 'src/config/environment.dart';
import 'src/config/theme_config.dart';
import 'src/core/di/service_locator.dart';
import 'src/providers/theme_provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/services/storage_service.dart';
import 'src/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await Environment.initialize();
  
  // Initialize dependency injection
  await ServiceLocator.initialize();

  // Initialize storage service
  await StorageService.initialize();

  // Initialize notifications
  await ServiceLocator.instance<NotificationService>().initialize();

  // Print configuration in debug mode
  if (AppConfig.isDebugMode) {
    Environment.printEnvironmentInfo();
    AppConfig.printConfiguration();
  }

  runApp(
    ProviderScope(
      child: ElimuConnectApp(),
    ),
  );
}

class ElimuConnectApp extends ConsumerWidget {
  const ElimuConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize providers
    ref.listen(themeProvider, (_, __) {});
    ref.listen(authProvider, (_, __) {});

    // Watch theme state
    final themeMode = ref.watch(effectiveThemeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.isDebugMode,
      
      // Theme configuration
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      
      // Localization
      locale: const Locale('en', 'KE'), // English (Kenya)
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'KE'),
        Locale('sw', 'KE'), // Swahili (Kenya)
      ],
      
      // Home screen
      home: const AppInitializer(),
      
      // Navigation
      onGenerateRoute: (settings) => _generateRoute(settings),
      
      // Builder for additional configuration
      builder: (context, child) {
        // Handle system theme changes
        final brightness = MediaQuery.of(context).platformBrightness;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(themeProvider.notifier).updateSystemDarkMode(
            brightness == Brightness.dark,
          );
        });

        return child!;
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const AppInitializer(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case '/dashboard/student':
        return MaterialPageRoute(
          builder: (_) => const StudentDashboard(),
          settings: settings,
        );
      case '/dashboard/teacher':
        return MaterialPageRoute(
          builder: (_) => const TeacherDashboard(),
          settings: settings,
        );
      case '/dashboard/parent':
        return MaterialPageRoute(
          builder: (_) => const ParentDashboard(),
          settings: settings,
        );
      case '/dashboard/admin':
        return MaterialPageRoute(
          builder: (_) => const AdminDashboard(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isInitializing = true;
  String _initializationStep = 'Starting...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize theme
      setState(() => _initializationStep = 'Loading theme...');
      await ref.read(themeProvider.notifier).initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Initialize authentication
      setState(() => _initializationStep = 'Checking authentication...');
      await ref.read(authProvider.notifier).initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Complete initialization
      setState(() => _initializationStep = 'Almost ready...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate based on authentication state
      _navigateBasedOnAuthState();
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('App initialization error: $e');
      }
      // Navigate to login on error
      _navigateToLogin();
    }
  }

  void _navigateBasedOnAuthState() {
    final authState = ref.read(authProvider);
    
    if (authState.isAuthenticated) {
      final dashboardRoute = ref.read(authProvider.notifier).getDashboardRoute();
      Navigator.of(context).pushReplacementNamed(dashboardRoute);
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App Name
                    Text(
                      AppConfig.appName,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tagline
                    Text(
                      'Connecting Education in Kenya',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Loading Indicator
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Initialization Step
                    Text(
                      _initializationStep,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder screens - these will be created in separate files
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64),
            SizedBox(height: 16),
            Text('Login Screen'),
            Text('Coming Soon...'),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 64),
            SizedBox(height: 16),
            Text('Register Screen'),
            Text('Coming Soon...'),
          ],
        ),
      ),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64),
            SizedBox(height: 16),
            Text('Student Dashboard'),
            Text('Welcome, Student!'),
          ],
        ),
      ),
    );
  }
}

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64),
            SizedBox(height: 16),
            Text('Teacher Dashboard'),
            Text('Welcome, Teacher!'),
          ],
        ),
      ),
    );
  }
}

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom, size: 64),
            SizedBox(height: 16),
            Text('Parent Dashboard'),
            Text('Welcome, Parent!'),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 64),
            SizedBox(height: 16),
            Text('Admin Dashboard'),
            Text('Welcome, Administrator!'),
          ],
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('404 - Page Not Found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
