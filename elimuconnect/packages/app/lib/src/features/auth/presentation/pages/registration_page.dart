import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_shared/shared.dart';
import 'package:elimuconnect_design_system/design_system.dart';
import '../widgets/role_selector.dart';
import '../widgets/admin_registration_form.dart';
import '../widgets/teacher_registration_form.dart';
import '../widgets/student_registration_form.dart';
import '../widgets/parent_registration_form.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  UserRole selectedRole = UserRole.student;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),
              
              // Role Selection
              Text(
                'I am a',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              RoleSelector(
                selectedRole: selectedRole,
                onRoleChanged: (role) => setState(() => selectedRole = role),
              ),
              const SizedBox(height: 32),
              
              // Dynamic Form
              _buildRoleSpecificForm(selectedRole),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: ElimuColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join ElimuConnect and transform your learning experience',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: ElimuColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRoleSpecificForm(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AdminRegistrationForm();
      case UserRole.teacher:
        return TeacherRegistrationForm();
      case UserRole.student:
        return StudentRegistrationForm();
      case UserRole.parent:
        return ParentRegistrationForm();
    }
  }
}
