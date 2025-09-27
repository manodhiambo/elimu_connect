// packages/app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'src/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await ServiceLocator.init();
    print('✅ App initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize app: $e');
  }
  
  runApp(
    const ProviderScope(
      child: ElimuConnectApp(),
    ),
  );
}

class ElimuConnectApp extends ConsumerWidget {
  const ElimuConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'ElimuConnect - Elimu kwa Wote',
      routerConfig: router,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildLightTheme() {
    const seedColor = Color(0xFF1E88E5); // Kenya flag blue
    const accentColor = Color(0xFFFF5722); // Kenya flag red-orange
    
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ).copyWith(
        secondary: accentColor,
        tertiary: const Color(0xFF4CAF50), // Kenya flag green
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const seedColor = Color(0xFF1E88E5);
    const accentColor = Color(0xFFFF5722);
    
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).copyWith(
        secondary: accentColor,
        tertiary: const Color(0xFF4CAF50),
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Router Configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/register';
      
      if (!isLoggedIn && !isLoggingIn && state.matchedLocation != '/') {
        return '/login';
      }
      
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/assessments',
        builder: (context, state) => const AssessmentScreen(),
      ),
    ],
  );
});

// Splash Screen
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 60,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'ElimuConnect',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elimu kwa Wote - Education for All',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        context.go('/dashboard');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(authProvider).error ?? 'Login failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your learning journey',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      hintText: 'Enter your password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Forgot password feature coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Complete Registration Screen with Role-Specific Forms
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  
  // Role-specific controllers
  final _phoneController = TextEditingController();
  final _tscNumberController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _admissionNumberController = TextEditingController();
  final _classController = TextEditingController();
  final _parentContactController = TextEditingController();
  final _countyController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _childrenAdmissionController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();
  
  String _selectedRole = 'student';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  DateTime? _selectedDateOfBirth;
  List<String> _selectedSubjects = [];
  
  final List<String> _roles = ['student', 'teacher', 'parent', 'admin'];
  final List<String> _subjects = [
    'Mathematics', 'English', 'Kiswahili', 'Science', 'Social Studies',
    'Art & Craft', 'Music', 'Physical Education', 'Computer Science',
    'Agriculture', 'Home Science', 'Business Studies'
  ];
  final List<String> _counties = [
    'Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Thika',
    'Malindi', 'Kitale', 'Garissa', 'Kakamega', 'Machakos', 'Meru',
    'Nyeri', 'Kericho', 'Kisii', 'Kilifi', 'Nyanza', 'Central', 'Coast',
    'Eastern', 'North Eastern', 'Rift Valley', 'Western', 'Other'
  ];
  
  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
  
  void _disposeControllers() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminCodeController.dispose();
    _phoneController.dispose();
    _tscNumberController.dispose();
    _schoolIdController.dispose();
    _admissionNumberController.dispose();
    _classController.dispose();
    _parentContactController.dispose();
    _countyController.dispose();
    _nationalIdController.dispose();
    _childrenAdmissionController.dispose();
    _relationshipController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final registrationData = await _buildRegistrationData();
      
      // Simulate API call - replace with actual registration logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful! Welcome to ElimuConnect, ${_nameController.text}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Sign In',
              textColor: Colors.white,
              onPressed: () => context.go('/login'),
            ),
          ),
        );
        
        // Navigate to login screen after successful registration
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<Map<String, dynamic>> _buildRegistrationData() async {
    final baseData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'role': _selectedRole,
      'created_at': DateTime.now().toIso8601String(),
      'platform': 'mobile_app',
      'version': '1.0.0',
    };
    
    switch (_selectedRole) {
      case 'admin':
        return {
          ...baseData,
          'admin_code': _adminCodeController.text,
          'institution_id': 'default_institution',
        };
        
      case 'teacher':
        return {
          ...baseData,
          'phone_number': _phoneController.text.trim(),
          'tsc_number': _tscNumberController.text.trim(),
          'school_id': _schoolIdController.text.trim(),
          'subjects_taught': _selectedSubjects,
          'qualification': _qualificationController.text.trim(),
        };
        
      case 'student':
        return {
          ...baseData,
          'admission_number': _admissionNumberController.text.trim(),
          'school_id': _schoolIdController.text.trim(),
          'class_name': _classController.text.trim(),
          'date_of_birth': _selectedDateOfBirth?.toIso8601String(),
          'parent_guardian_contact': _parentContactController.text.trim(),
          'county_of_residence': _countyController.text.trim(),
        };
        
      case 'parent':
        final childrenNumbers = _childrenAdmissionController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
            
        return {
          ...baseData,
          'phone_number': _phoneController.text.trim(),
          'national_id': _nationalIdController.text.trim(),
          'children_admission_numbers': childrenNumbers,
          'relationship_to_children': _relationshipController.text.trim(),
          'address': _addressController.text.trim(),
        };
        
      default:
        return baseData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Join ElimuConnect',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your role and create your account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Role Selection
                _buildRoleSelector(),
                const SizedBox(height: 24),
                
                // Common Fields
                _buildCommonFields(),
                
                // Role-specific Fields
                _buildRoleSpecificFields(),
                
                const SizedBox(height: 32),
                
                // Register Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.groups,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Your Role',
                  style: Theme.of(context).textTheme.titleMedm?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _roles.map((role) {
                final isSelected = _selectedRole == role;
                return ChoiceChip(
                  label: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                   ntWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedRole = role;
                        _clearRoleSpecificFields();
                      });
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
               avatar: Icon(
                    _getRoleIcon(role),
                    size: 18,
                  ),
                );
              }).toList(),
            ),
            if (_selectedRole == 'admin')
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Admin registration requires a special access code',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.school;
      case 'teacher':
        return Icons.person;
      case 'parent':
        return Icons.family_restroom;
      case 'admin':
        return Icons.admin_pasettings;
      default:
        return Icons.person;
    }
  }
  
  Widget _buildCommonFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person_outline),
            hintText: 'Enter your full name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please entr your full name';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address *',
            prefixIcon: Icon(Icons.email_outlined),
            hinext: 'Enter your email address',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        TextFormField(
          controller: _passwordController,
          ureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password *',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            hintText: 'Create g password',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase, and number';
            }
            return null;
          },
        ),
        cizedBox(height: 20),
        
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password *',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {               _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            hintText: 'Confirm your password',
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildRoleSpecificFields() {
    switch (_selectedRole) {
      case 'admin':
        return _buildAdminFields();
      case 'teacher':
        return _buildTeacherFields();
      case 'student':
        return _buildStudentFields();
      case 'parent':
        return _buildParentFields();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildAdminFields() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator Verification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _adminCodeController,
                  decoration: const InputDecoration(
                    labelTex'Admin Access Code *',
                    prefixIcon: Icon(Icons.admin_panel_settings),
                    helperText: 'Enter the special admin code to proceed',
                    hintText: 'OnlyMe@2025',
                  ),
                  validator: (value) {
                    if (_selectedRole == 'admin' && value != 'OnlyMe@2025') {
                      return 'Invalid admin code. Contact system administrator.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTeacherFields() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+254XXXXXXXXX',            ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _tscNumberController,
                  decoration: const InputDecoration(
                    labelText: 'TSC Number *'
                    prefixIcon: Icon(Icons.badge),
                    helperText: 'Teachers Service Commission Number',
                    hintText: 'e.g., TSC/123456',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your TSC number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _schoolIdController,
                  decoration: const InputDecoration(
                    labelText: 'School Name *',
                    prefixIcon: Icon(Icons.school),
                    hintText: 'Enter your school name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your school name';
                    }
                    retun null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _qualificationController,
                  decoration: const InputDecoration(
                    labelText: 'Highest Qualification *',
                    prefixIcon: Icon(Icons.school),
                    hintText: 'e.g., Bachelor of Education, Diploma',
                  ),
                  validator: (value) {
                    if value == null || value.isEmpty) {
                      return 'Please enter your qualification';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Subjects You Teach',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(hght: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _subjects.map((subject) {
                    return FilterChip(
                      label: Text(
                        subject,
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: _selectedSubjects.contains(subject),
                      onSelected: (selected) {
                        setState(() {
                    if (selected) {
                            _selectedSubjects.add(subject);
                          } else {
                            _selectedSubjects.remove(subject);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStudentFields() {
    return Column(
      children: [
        const SizedBox(height: 
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
               extFormField(
                  controller: _admissionNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Admission Number *',
                    prefixIcon: Icon(Icons.numbers),
                    hintText: 'e.g., ADM/2024/001',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your admission number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _schoolIdController,
                  decoration: const InputDecoration(
                    labelText: 'School Name *',
                    prefixIcon: Icon(Icons.school),
                    hintText: 'Enter your school name',
                  ),
                  validator: (value) {
                    if (value == null || value.is {
                      return 'Please enter your school name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(
                    labelText: 'Class/Grade *',
                    prefixIcon: Icon(Icons.class_),
                    hintText: 'e.g., Grade 5, Form 2',
                ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your class/grade';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _parentContactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDation(
                    labelText: 'Parent/Guardian Contact *',
                    prefixIcon: Icon(Icons.contact_phone),
                    hintText: '+254XXXXXXXXX',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter parent/guardian contact';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              
                DropdownButtonFormField<String>(
                  value: _countyController.text.isEmpty ? null : _countyController.text,
                  decoration: const InputDecoration(
                    labelText: 'County of Residence *',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  items: _counties.map((county) => DropdownMenuItem(
                    value: county,
                    child: Text(county),
                  )).toList(),
               onChanged: (value) {
                    setState(() {
                      _countyController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your county';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPaentFields() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent/Guardian Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
             ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+254XXXXXXXXX',
                  ),
                  validator: (value) {
                    if (value == null || valuesEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nationalIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'National ID Number *',
                    prefixIcon: Icon(Icons.credit_card),
                    hintText: 'Enter your national ID',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your national ID number';
                    }
                    if (value.length < 7 || value.length > 8) {
                      return 'Please enter a valid ID number';
                    }
                    return null;
                  },
                ),
            const SizedBox(height: 16),
                
                TextFormField(
                  controller: _childrenAdmissionController,
                  decoration: const InputDecoration(
                    labelText: 'Children Admission Numbers *',
                    prefixIcon: Icon(Icons.family_restroom),
                    helperText: 'Enter admission numbers separated by commas',
                    hintText: 'ADM001, ADM002, ADM003',
                  ),
                  maxLines: 2,
                 validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one admission number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship to Chi*',
                    prefixIcon: Icon(Icons.family_restroom),
                    hintText: 'e.g., Father, Mother, Guardian',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please specify your relationship';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
               controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Residential Address *',
                    prefixIcon: Icon(Icons.home),
                    hintText: 'Enter your residential address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    returnl;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  void _clearRoleSpecificFields() {
    _phoneController.clear();
    _tscNumberController.clear();
    _schoolIdController.clear();
    _admissionNumberController.clear();
    _classController.clear();
    _parentContactController.clear();
    _countyController.clear();
    _nationalIdController.clear();
    _childrenAdmissionController.clear();
    _relationshipController.clear();
    dressController.clear();
    _qualificationController.clear();
    _adminCodeController.clear();
    _selectedSubjects.clear();
    _selectedDateOfBirth = null;
  }
}

// Dashboard Screen
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'User';
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ElimuConnect'),
            Text(
              'Welcome, $userName',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificatns coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Container(
              h: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrssAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to ElimuConnect!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your gateway to quality education in Kenya',
                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1
            
            // Dashboard Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _DashboardCard(
                    title: 'Digital Library',
                    subtitle: 'Browse books & resources',
                    icon: Icons.library_books,
                    color: Colors.blue,
                    onTap: () => context.go('/ibrary'),
                  ),
                  _DashboardCard(
                    title: 'Assessments',
                    subtitle: 'Take quizzes & tests',
                    icon: Icons.quiz,
                    color: Colors.green,
                    onTap: () => context.go('/assessments'),
                  ),
                  _DashboardCard(
                    title: 'Messages',
                    subtitle: 'Connect with teachers',
                    icon: Icons.message,
                    cColors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Messaging system coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    title: 'Progress',
                    subtitle: 'Track your learning',
                  icon: Icons.trending_up,
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Progress tracking coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRus: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),        const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

// Profile Screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Profile'),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile coming soon!')),
                  );
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon!')),
                  );
                },
              ),
       const PopupMenuDivider(),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/logi                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: user == null 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                    children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                       ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryner,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Profile Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProfileInfoRow(
                          icon: Icons.email,
                        abel: 'Email',
                          value: user.email,
                        ),
                        _ProfileInfoRow(
                          icon: Icons.person,
                          label: 'Role',
                          value: user.role,
                        ),
                        _ProfileInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Member since',
                          value: 'Recently joined',
                        ),
                  ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Quick Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('Help & Support'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Help section coming soon!')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('About ElimuConnect'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('About ElimuConnect'),
                                content: const Text(
                                  'ElimuConnect is Kenya\'s premier educational platform, '
                                  'connecting students, teachers and parents with quality '
                                  ital learning resources.\n\n'
                                  'Version 1.0.0\n'
                                  'Elimu kwa Wote - Education for All',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext con) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              stylenst TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// Library Screen
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnac
                const SnackBar(content: Text('Search feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Digital Library',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Access thousands of educational resources\ncoming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Assessment Screen
class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessments'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Assessment Center',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Interactive quizzes and assessments\ncoming soon!',
            textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
} '
