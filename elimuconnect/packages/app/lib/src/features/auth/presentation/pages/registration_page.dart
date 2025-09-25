// File: packages/app/lib/src/features/auth/presentation/pages/registration_page.dart (COMPLETE VERSION)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';
import 'package:elimuconnect_shared/shared.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../routing/route_names.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  UserRole _selectedRole = UserRole.student;
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  bool _obscurePassword = true;
  
  // Additional state for complex fields
  KenyaCounty? _selectedCounty;
  String? _selectedClass;
  List<String> _selectedSubjects = [];
  List<String> _selectedClasses = [];
  DateTime? _selectedDateOfBirth;
  List<String> _childrenAdmissionNumbers = [];
  String? _selectedQualification;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = [
      'name', 'email', 'password', 'phoneNumber', 'adminCode', 'institutionId',
      'tscNumber', 'schoolId', 'qualification', 'admissionNumber', 
      'parentGuardianContact', 'nationalId', 'relationshipToChildren', 'address'
    ];
    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return AppScaffold(
      title: 'Create Account',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Role selector
              RoleSelector(
                selectedRole: _selectedRole,
                onRoleChanged: (role) {
                  setState(() {
                    _selectedRole = role;
                    _resetFormState();
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // Role-specific forms
              _buildRoleSpecificForm(),
              
              const SizedBox(height: 32),
              
              // Register button
              PrimaryButton(
                text: 'Create Account',
                isLoading: authState.status == AuthStatus.loading,
                onPressed: _register,
                width: double.infinity,
              ),
              
              // Error message
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
              
              // Login link
              TextButton(
                onPressed: () => context.go(RouteNames.login),
                child: const Text('Already have an account? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSpecificForm() {
    return Column(
      children: [
        // Common fields
        _buildCommonFields(),
        
        // Role-specific fields
        if (_selectedRole == UserRole.admin) _buildAdminFields(),
        if (_selectedRole == UserRole.teacher) _buildTeacherFields(),
        if (_selectedRole == UserRole.student) _buildStudentFields(),
        if (_selectedRole == UserRole.parent) _buildParentFields(),
      ],
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
        TextFormField(
          controller: _controllers['name']!,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) => AuthValidators.validateName(value),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _controllers['email']!,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => AuthValidators.validateEmail(value),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _controllers['password']!,
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
      ],
    );
  }

  Widget _buildAdminFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['adminCode']!,
          decoration: const InputDecoration(
            labelText: 'Admin Registration Code',
            prefixIcon: Icon(Icons.admin_panel_settings),
          ),
          validator: (value) => AuthValidators.validateAdminCode(value),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['institutionId']!,
          decoration: const InputDecoration(
            labelText: 'Institution ID',
            prefixIcon: Icon(Icons.business),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Institution ID is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTeacherFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['phoneNumber']!,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) => KenyaSpecificValidators.validateKenyanPhoneNumber(value),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['tscNumber']!,
          decoration: const InputDecoration(
            labelText: 'TSC Number',
            prefixIcon: Icon(Icons.card_membership),
            hintText: 'TSC/12345/2020',
          ),
          validator: (value) => KenyaSpecificValidators.validateTscNumber(value),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['schoolId']!,
          decoration: const InputDecoration(
            labelText: 'School/Institution',
            prefixIcon: Icon(Icons.school),
          ),
          validator: (value) => KenyaSpecificValidators.validateSchoolId(value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedQualification,
          decoration: const InputDecoration(
            labelText: 'Teaching Qualification',
            prefixIcon: Icon(Icons.school),
          ),
          items: const [
            'Certificate in Education',
            'Diploma in Education',
            "Bachelor's Degree in Education",
            "Master's Degree in Education",
            'PhD in Education',
          ].map((qual) => DropdownMenuItem(value: qual, child: Text(qual))).toList(),
          onChanged: (value) => setState(() => _selectedQualification = value),
          validator: (value) => KenyaSpecificValidators.validateQualification(value),
        ),
        const SizedBox(height: 16),
        ClassSelector(
          selectedClass: _selectedClass,
          onChanged: (value) => setState(() {
            _selectedClass = value;
            _selectedSubjects.clear(); // Reset subjects when class changes
          }),
        ),
        const SizedBox(height: 16),
        SubjectSelector(
          selectedSubjects: _selectedSubjects,
          selectedClass: _selectedClass,
          onChanged: (subjects) => setState(() => _selectedSubjects = subjects),
        ),
        const SizedBox(height: 16),
        CountySelector(
          selectedCounty: _selectedCounty,
          onChanged: (county) => setState(() => _selectedCounty = county),
          labelText: 'County of Work',
        ),
      ],
    );
  }

  Widget _buildStudentFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['admissionNumber']!,
          decoration: const InputDecoration(
            labelText: 'Admission Number',
            prefixIcon: Icon(Icons.badge),
          ),
          validator: (value) => KenyaSpecificValidators.validateAdmissionNumber(value),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['schoolId']!,
          decoration: const InputDecoration(
            labelText: 'School Name',
            prefixIcon: Icon(Icons.school),
          ),
          validator: (value) => KenyaSpecificValidators.validateSchoolId(value),
        ),
        const SizedBox(height: 16),
        ClassSelector(
          selectedClass: _selectedClass,
          onChanged: (value) => setState(() => _selectedClass = value),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(_selectedDateOfBirth == null 
              ? 'Select Date of Birth' 
              : 'Born: ${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'),
          onTap: _selectDateOfBirth,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['parentGuardianContact']!,
          decoration: const InputDecoration(
            labelText: 'Parent/Guardian Phone Number',
            prefixIcon: Icon(Icons.contact_phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) => KenyaSpecificValidators.validateKenyanPhoneNumber(value),
        ),
        const SizedBox(height: 16),
        CountySelector(
          selectedCounty: _selectedCounty,
          onChanged: (county) => setState(() => _selectedCounty = county),
          labelText: 'County of Residence',
        ),
      ],
    );
  }

  Widget _buildParentFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['phoneNumber']!,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) => KenyaSpecificValidators.validateKenyanPhoneNumber(value),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['nationalId']!,
          decoration: const InputDecoration(
            labelText: 'National ID Number',
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          validator: (value) => KenyaSpecificValidators.validateNationalId(value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _controllers['relationshipToChildren']!.text.isEmpty 
              ? null 
              : _controllers['relationshipToChildren']!.text,
          decoration: const InputDecoration(
            labelText: 'Relationship to Children',
            prefixIcon: Icon(Icons.family_restroom),
          ),
          items: const [
            'Father',
            'Mother',
            'Guardian',
            'Grandparent',
            'Uncle',
            'Aunt',
            'Other'
          ].map((rel) => DropdownMenuItem(value: rel, child: Text(rel))).toList(),
          onChanged: (value) {
            setState(() => _controllers['relationshipToChildren']!.text = value ?? '');
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your relationship to the children';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Children\'s Admission Numbers',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ..._childrenAdmissionNumbers.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        decoration: InputDecoration(
                          labelText: 'Child ${index + 1} Admission Number',
                          prefixIcon: const Icon(Icons.child_care),
                        ),
                        onChanged: (value) {
                          _childrenAdmissionNumbers[index] = value;
                        },
                        validator: (value) => KenyaSpecificValidators.validateAdmissionNumber(value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => setState(() {
                        _childrenAdmissionNumbers.removeAt(index);
                      }),
                    ),
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: () => setState(() {
                _childrenAdmissionNumbers.add('');
              }),
              icon: const Icon(Icons.add),
              label: const Text('Add Child'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers['address']!,
          decoration: const InputDecoration(
            labelText: 'Residential Address',
            prefixIcon: Icon(Icons.home),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Address is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CountySelector(
          selectedCounty: _selectedCounty,
          onChanged: (county) => setState(() => _selectedCounty = county),
          labelText: 'County of Residence',
        ),
      ],
    );
  }

  // MISSING METHODS - NOW COMPLETE:

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2010), // Reasonable default for student
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDateOfBirth = date);
    }
  }

  void _resetFormState() {
    // Clear form state when role changes
    setState(() {
      _selectedCounty = null;
      _selectedClass = null;
      _selectedSubjects.clear();
      _selectedClasses.clear();
      _selectedDateOfBirth = null;
      _childrenAdmissionNumbers.clear();
      _selectedQualification = null;
      
      // Clear text controllers
      for (final controller in _controllers.values) {
        controller.clear();
      }
    });
  }

  void _register() {
    // Validate children admission numbers for parents
    if (_selectedRole == UserRole.parent && _childrenAdmissionNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one child\'s admission number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate date of birth for students
    if (_selectedRole == UserRole.student && _selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate subjects for teachers
    if (_selectedRole == UserRole.teacher && _selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one subject you teach'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate county selection (not required for admin)
    if (_selectedCounty == null && _selectedRole != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your county'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      switch (_selectedRole) {
        case UserRole.admin:
          final request = AdminRegistrationRequest(
            name: _controllers['name']!.text.trim(),
            email: _controllers['email']!.text.trim(),
            password: _controllers['password']!.text,
            adminCode: _controllers['adminCode']!.text,
            institutionId: _controllers['institutionId']!.text.trim(),
          );
          ref.read(authStateProvider.notifier).registerAdmin(request);
          break;
          
        case UserRole.teacher:
          final request = TeacherRegistrationRequest(
            name: _controllers['name']!.text.trim(),
            email: _controllers['email']!.text.trim(),
            password: _controllers['password']!.text,
            phoneNumber: _controllers['phoneNumber']!.text.trim(),
            tscNumber: _controllers['tscNumber']!.text.trim().toUpperCase(),
            schoolId: _controllers['schoolId']!.text.trim(),
            subjectsTaught: _selectedSubjects,
            classesAssigned: [_selectedClass!], // For now, single class
            qualification: _selectedQualification!,
            countyOfWork: _selectedCounty!,
          );
          ref.read(authStateProvider.notifier).registerTeacher(request);
          break;
          
        case UserRole.student:
          final request = StudentRegistrationRequest(
            name: _controllers['name']!.text.trim(),
            email: _controllers['email']!.text.trim(),
            password: _controllers['password']!.text,
            admissionNumber: _controllers['admissionNumber']!.text.trim(),
            schoolId: _controllers['schoolId']!.text.trim(),
            className: _selectedClass!,
            dateOfBirth: _selectedDateOfBirth!,
            parentGuardianContact: _controllers['parentGuardianContact']!.text.trim(),
            countyOfResidence: _selectedCounty!,
          );
          ref.read(authStateProvider.notifier).registerStudent(request);
          break;
          
        case UserRole.parent:
          final validAdmissionNumbers = _childrenAdmissionNumbers
              .where((num) => num.isNotEmpty)
              .toList();
          
          final request = ParentRegistrationRequest(
            name: _controllers['name']!.text.trim(),
            email: _controllers['email']!.text.trim(),
            password: _controllers['password']!.text,
            phoneNumber: _controllers['phoneNumber']!.text.trim(),
            nationalId: _controllers['nationalId']!.text.trim(),
            childrenAdmissionNumbers: validAdmissionNumbers,
            relationshipToChildren: _controllers['relationshipToChildren']!.text,
            address: _controllers['address']!.text.trim(),
            countyOfResidence: _selectedCounty!,
          );
          ref.read(authStateProvider.notifier).registerParent(request);
          break;
      }
    }
  }
}
