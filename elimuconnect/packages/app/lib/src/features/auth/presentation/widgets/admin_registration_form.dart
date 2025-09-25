import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_shared/shared.dart';
import 'package:elimuconnect_design_system/design_system.dart';

class AdminRegistrationForm extends ConsumerStatefulWidget {
  const AdminRegistrationForm({super.key});

  @override
  ConsumerState<AdminRegistrationForm> createState() => _AdminRegistrationFormState();
}

class _AdminRegistrationFormState extends ConsumerState<AdminRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  final _institutionIdController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminCodeController.dispose();
    _institutionIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Admin Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ElimuColors.warning.withOpacity(0.1),
              border: Border.all(color: ElimuColors.warning.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: ElimuColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Admin registration requires a special access code',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ElimuColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Name Field
          ElimuTextField(
            controller: _nameController,
            labelText: 'Full Name',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Email Field
          ElimuTextField(
            controller: _emailController,
            labelText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}).hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Phone Field
          ElimuTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              // Kenya phone number validation
              final phoneRegex = RegExp(r'^(?:\+254|0)([17]\d{8}));
              if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                return 'Please enter a valid Kenyan phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Institution ID Field
          ElimuTextField(
            controller: _institutionIdController,
            labelText: 'Institution ID / School Code',
            prefixIcon: Icons.business_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the institution ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Admin Code Field
          ElimuTextField(
            controller: _adminCodeController,
            labelText: 'Admin Access Code',
            prefixIcon: Icons.key_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the admin access code';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Password Field
          ElimuTextField(
            controller: _passwordController,
            labelText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
                return 'Password must contain uppercase, lowercase, number, and special character';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Confirm Password Field
          ElimuTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          
          // Register Button
          ElimuButton.primary(
            text: 'Create Admin Account',
            isLoading: _isLoading,
            onPressed: _handleRegistration,
          ),
          const SizedBox(height: 16),
          
          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ElimuColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = AdminRegistrationRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        adminCode: _adminCodeController.text.trim(),
        institutionId: _institutionIdController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      // TODO: Implement admin registration
      // await ref.read(authServiceProvider).registerAdmin(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
