// packages/app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app dependencies
  await _initializeApp();
  
  // Run the app with error handling
  runApp(
    ProviderScope(
      child: ElimuConnectApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    // Initialize shared preferences
    await SharedPreferences.getInstance();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    print('ElimuConnect initialized successfully');
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class ElimuConnectApp extends ConsumerWidget {
  const ElimuConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: ElimuTheme.lightTheme,
      darkTheme: ElimuTheme.darkTheme,
      themeMode: themeMode,
      
      // Routing
      routerConfig: router,
      
      // Localization
      supportedLocales: AppConfig.supportedLocales,
      
      // App metadata
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

// App Configuration
class AppConfig {
  static const String appName = 'ElimuConnect';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:8080';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('sw', 'KE'), // Swahili
  ];
  
  // Kenya-specific configuration
  static const List<String> kenyanCounties = [
    'Nairobi', 'Mombasa', 'Kwale', 'Kilifi', 'Tana River', 'Lamu',
    'Taita Taveta', 'Garissa', 'Wajir', 'Mandera', 'Marsabit', 'Isiolo',
    'Meru', 'Tharaka Nithi', 'Embu', 'Kitui', 'Machakos', 'Makueni',
    'Nyandarua', 'Nyeri', 'Kirinyaga', 'Murang\'a', 'Kiambu', 'Turkana',
    'West Pokot', 'Samburu', 'Trans Nzoia', 'Uasin Gishu', 'Elgeyo Marakwet',
    'Nandi', 'Baringo', 'Laikipia', 'Nakuru', 'Narok', 'Kajiado',
    'Kericho', 'Bomet', 'Kakamega', 'Vihiga', 'Bungoma', 'Busia',
    'Siaya', 'Kisumu', 'Homa Bay', 'Migori', 'Kisii', 'Nyamira'
  ];
  
  // Education system configuration
  static const List<String> educationLevels = [
    'Pre-Primary 1 (PP1)',
    'Pre-Primary 2 (PP2)',
    'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6',
    'Grade 7', 'Grade 8', 'Grade 9',
    'Form 1', 'Form 2', 'Form 3', 'Form 4'
  ];
  
  static const List<String> cbcSubjects = [
    'English', 'Kiswahili', 'Mathematics', 'Science and Technology',
    'Social Studies', 'Creative Arts', 'Physical and Health Education',
    'Religious Education', 'Home Science', 'Agriculture',
    'Pre-Technical Studies', 'Business Studies'
  ];
}

// Theme Configuration
class ElimuTheme {
  // Kenya-inspired color scheme
  static const Color primaryColor = Color(0xFF1976D2); // Blue
  static const Color secondaryColor = Color(0xFF388E3C); // Green
  static const Color accentColor = Color(0xFFFF5722); // Orange
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color successColor = Color(0xFF388E3C);
  
  // Kenyan flag inspired colors
  static const Color kenyanBlack = Color(0xFF000000);
  static const Color kenyanRed = Color(0xFFCE1126);
  static const Color kenyanGreen = Color(0xFF007A3D);
  static const Color kenyanWhite = Color(0xFFFFFFFF);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(Colors.black87),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(Colors.white),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
  
  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: baseColor,
      ),
    );
  }
}

// Providers
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/dashboard' : '/welcome',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuth = state.fullPath?.startsWith('/auth') ?? false;
      
      if (!isAuthenticated && !isOnAuth) {
        return '/welcome';
      }
      if (isAuthenticated && isOnAuth) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      // Welcome and onboarding routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: 'assessments',
            builder: (context, state) => const AssessmentScreen(),
          ),
          GoRoute(
            path: 'messages',
            builder: (context, state) => const MessagesScreen(),
          ),
        ],
      ),
    ],
  );
});

// State Notifiers
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.unauthenticated());
  
  Future<void> login(String email, String password, UserRole role) async {
    state = const AuthState.loading();
    try {
      // TODO: Implement actual authentication logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      final user = User(
        id: 'user_123',
        name: 'John Doe',
        email: email,
        role: role,
      );
      
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> register(RegistrationData data) async {
    state = const AuthState.loading();
    try {
      // TODO: Implement actual registration logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      final user = User(
        id: 'user_123',
        name: data.name,
        email: data.email,
        role: data.role,
      );
      
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  void logout() {
    state = const AuthState.unauthenticated();
  }
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);
  
  void setThemeMode(ThemeMode themeMode) {
    state = themeMode;
    // TODO: Persist theme preference
  }
}

// Data Models
enum UserRole { student, teacher, parent, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? schoolId;
  final String? profileImage;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.schoolId,
    this.profileImage,
  });
}

class RegistrationData {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final Map<String, dynamic> additionalData;
  
  const RegistrationData({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.additionalData = const {},
  });
}

// Auth State
abstract class AuthState {
  const AuthState();
  
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
  
  bool get isAuthenticated => this is _Authenticated;
  bool get isLoading => this is _Loading;
  User? get user => this is _Authenticated ? (this as _Authenticated).user : null;
}

class _Loading extends AuthState {
  const _Loading();
}

class _Authenticated extends AuthState {
  final User user;
  const _Authenticated(this.user);
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _Error extends AuthState {
  final String message;
  const _Error(this.message);
}

// Screen Widgets
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ElimuTheme.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: ElimuTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // Welcome text
              Text(
                'Karibu ElimuConnect',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: ElimuTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Kuunganisha wanafunzi, walimu, na shule kote Kenya kwa elimu ya dijiti ya hali ya juu',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Connecting students, teachers, and schools across Kenya with quality digital education',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Kenya flag inspired decoration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 20, height: 4, color: ElimuTheme.kenyanBlack),
                  Container(width: 20, height: 4, color: ElimuTheme.kenyanRed),
                  Container(width: 20, height: 4, color: ElimuTheme.kenyanGreen),
                ],
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/auth/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Anza Hapa / Get Started'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/onboarding'),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Jifunze Zaidi / Learn More'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuhusu ElimuConnect'),
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ElimuConnect ni jukwaa la elimu ambalo linalenga kuunganisha mazingira ya kujifunza nchini Kenya.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Features coming soon:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Digital library with CBC-aligned content'),
            Text('• Interactive assessments and quizzes'),
            Text('• Real-time communication platform'),
            Text('• Offline learning capabilities'),
            Text('• Multi-language support (English/Swahili)'),
            Text('• Parent-teacher collaboration tools'),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingia / Login'),
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authStateProvider);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kenya-themed header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ElimuTheme.primaryColor.withOpacity(0.1),
                          ElimuTheme.secondaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.school,
                          size: 48,
                          color: ElimuTheme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Karibu Tena!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: ElimuTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Role selection
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mimi ni / I am a:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: UserRole.values.map((role) {
                              return ChoiceChip(
                                label: Text(_getRoleDisplayName(role)),
                                selected: _selectedRole == role,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedRole = role);
                                  }
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: ElimuTheme.primaryColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _selectedRole == role 
                                    ? ElimuTheme.primaryColor 
                                    : Colors.grey[700],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Barua pepe / Email',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Tafadhali ingiza barua pepe yako';
                      }
                      if (!value!.contains('@')) {
                        return 'Ingiza barua pepe halali';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Nywila / Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Tafadhali ingiza nywila yako';
                      }
                      if (value!.length < 6) {
                        return 'Nywila lazima iwe na angalau herufi 6';
                      }
                      return null;
                    },
                  ),
                  
                  // Admin code field (shown only for admin role)
                  if (_selectedRole == UserRole.admin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Admin Code',
                        prefixIcon: Icon(Icons.admin_panel_settings),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (_selectedRole == UserRole.admin && value != 'OnlyMe@2025') {
                          return 'Invalid admin code';
                        }
                        return null;
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Login button
                  ElevatedButton.icon(
                    onPressed: authState.isLoading ? null : () => _handleLogin(ref),
                    icon: authState.isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.login),
                    label: Text(authState.isLoading ? 'Kuingia...' : 'Ingia / Login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Register link
                  OutlinedButton.icon(
                    onPressed: () => context.go('/auth/register'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Huna akaunti? Jisajili / Register'),
                  ),
                  const SizedBox(height: 8),
                  
                orgot password link
                  TextButton(
                    onPressed: () => context.go('/auth/forgot-password'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.help_outline),
                        SizedBox(width: 8),
                        Text('Umesahau nywila? / Forgot Password?'),
                      ],
                    ),
                  ),
                 
                  // Error message
                  if (authState is _Error)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (authState as _Error).message,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                                   ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Mwanafunzi / Student';
      case UserRole.teacher:
        return 'Mwalimu / Teacher';
      case UserRole.parent:
        return 'Mzazi / Parent';
      case UserRole.admin:
        return 'Msimamizi / Admin';
    }
  }

  void _handleLogin(WidgetRef ref) {
    if (_formKey.currentState?.validate() ?? f {
      ref.read(authStateProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
        _selectedRole,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jisajili / Register,
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add,
              size: 64,
              color: ElimuTheme.primaryColor,
            ),
            SizedBox(height: 24),
            Text(
              'Registration Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Role-based registration forms will be implemented here based on your comprehensive roadmap',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildCont context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahau Nywila / Forgot Password'),
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_reset,
              size: 64,
              color: ElimuTheme.warningColor,
            ),
            SizedBox(height: 24),
            Text(
              'Password Recovery',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Password recovery functionality will be implemented here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  c DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Karibu, ${user?.name ?? "User"}'),
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Scessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon')),
              );
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Profile'),
                onTap: () => context.go('/dashboard/profile'),
              ),
              PopupMenuItem(
                child: const Text('Settings'),
           onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon')),
                  );
                },
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () => ref.read(authStateProvider.notifier).logout(),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
     ld: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card with Kenya theme
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ElimuTheme.primaryColor,
                    EimuTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ElimuTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          _getRoleIcon(user?.role ?? UserRole.student),
                          size: 32,
                          color: ElimuTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded                       child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Karibu, ${user?.name ?? "User"}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                            Text(
                              _getRoleDisplayName(user?.role ?? UserRole.student),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.school, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                    'ElimuConnect - Elimu kwa Wote',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Vitabu',
                    sule: 'Books',
                    value: '150+',
                    icon: Icons.book,
                    color: ElimuTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Jaribio',
                    subtitle: 'Assessments',
                    value: '25',
                    icon: Icons.quiz,
                    color: ElimuTheme.warningColor,
                  ),
            ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Ujumbe',
                    subtitle: 'Messages',
                    value: '8',
                    icon: Icons.message,
                    color: ElimuTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
               child: _StatCard(
                    title: 'Maendeleo',
                    subtitle: 'Progress',
                    value: '75%',
                    icon: Icons.trending_up,
                    color: ElimuTheme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick actions
            Text(
              'Vitendo vya Haraka / Quick Actions',
              style: Theme.of(context).textTheme.titLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _QuickActionCard(
                  title: 'Maktaba',
                  sutitle: 'Library',
                  icon: Icons.library_books,
                  onTap: () => context.go('/dashboard/library'),
                ),
                _QuickActionCard(
                  title: 'Jaribio',
                  subtitle: 'Assessments',
                  icon: Icons.quiz,
                  onTap: () => context.go('/dashboard/assessments'),
                ),
                _QuickActionCard(
                  title: 'Ujumbe',
                  subtitle: 'Messages',
                  icons.message,
                  onTap: () => context.go('/dashboard/messages'),
                ),
                _QuickActionCard(
                  title: 'Wasifu',
                  subtitle: 'Profile',
                  icon: Icons.person,
                  onTap: () => context.go('/dashboard/profile'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  IconData _getRoleIcon(UserRole role) {
  itch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.teacher:
        return Icons.person;
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Mwanafunzi / Student';
      case UserRole.teacher:
        return 'Mwalimu / Teacher';
      case UserRole.parent:
         'Mzazi / Parent';
      case UserRole.admin:
        return 'Msimamizi / Admin';
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: ElimuTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Nyumbani',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.libraryooks),
          label: 'Maktaba',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: 'Jaribio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Ujumbe',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/dashboard/library');
            break;
          case 2:
            context('/dashboard/assessments');
            break;
          case 3:
            context.go('/dashboard/messages');
            break;
        }
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContexext) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                vale,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 1          color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: ElimuTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16                 fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Other screen implementations
class ProfileScreen extends ConsumerWidget {
  const PrfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wasifu / Profile'),
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: ElimuTheme.primaryColor,
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'User Name',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              user?.email ?? 'user@example.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile management features will be implemented here',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: cont('Maktaba / Library'),
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 64,
              color: ElimuTheme.successColor,
            ),
            SizedBox(height: 16),
            Text(
              'Digital Library',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'CBC-aligned educational content will be available here',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: conxt('Jaribio / Assessments'),
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: 64,
              color: ElimuTheme.warningColor,
            ),
            SizedBox(height: 16),
            Text(
              'Assessment System',
       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Interactive quizzes and assessments will be available here',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ujumbe / Messages'),
        backgroundColor: ElimuTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message,
              size: 64,
              color: ElimuTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Communication Platform           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Real-time messaging between teachers, students, and parents',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
