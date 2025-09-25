import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:elimuconnect_shared/shared.dart';
import '../config/app_config.dart';
import '../repositories/user_repository.dart';
import '../utils/exceptions.dart';
import '../utils/validators.dart';

class AuthService {
  final UserRepository _userRepository;
  
  AuthService(this._userRepository);
  
  Future<AuthResult> registerAdmin(AdminRegistrationRequest request) async {
    // Validate admin code
    if (request.adminCode != AppConfig.adminRegistrationCode) {
      throw ValidationException('Invalid admin registration code');
    }
    
    // Validate request
    _validateRegistrationRequest(request);
    
    // Check if email already exists
    final existingUser = await _userRepository.findByEmail(request.email);
    if (existingUser != null) {
      throw ValidationException('Email already registered');
    }
    
    // Hash password
    final hashedPassword = BCrypt.hashpw(
      request.password, 
      BCrypt.gensalt(logRounds: AppConfig.bcryptRounds)
    );
    
    // Create user
    final user = UserModel(
      id: generateId(),
      name: request.name,
      email: request.email,
      role: UserRole.admin,
      isActive: true,
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      phoneNumber: request.phoneNumber,
    );
    
    final createdUser = await _userRepository.create(user, hashedPassword);
    
    // Generate tokens
    final tokens = _generateTokens(createdUser);
    
    return AuthResult(
      user: createdUser,
      accessToken: tokens['accessToken']!,
      refreshToken: tokens['refreshToken']!,
    );
  }
  
  Future<AuthResult> registerTeacher(TeacherRegistrationRequest request) async {
    _validateTeacherRegistration(request);
    
    final existingUser = await _userRepository.findByEmail(request.email);
    if (existingUser != null) {
      throw ValidationException('Email already registered');
    }
    
    // Validate TSC number (Teachers Service Commission)
    if (!_isValidTSCNumber(request.tscNumber)) {
      throw ValidationException('Invalid TSC number');
    }
    
    final hashedPassword = BCrypt.hashpw(
      request.password, 
      BCrypt.gensalt(logRounds: AppConfig.bcryptRounds)
    );
    
    final user = UserModel(
      id: generateId(),
      name: request.name,
      email: request.email,
      role: UserRole.teacher,
      isActive: true,
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      phoneNumber: request.phoneNumber,
    );
    
    final createdUser = await _userRepository.create(user, hashedPassword);
    
    // Create teacher profile
    final teacherProfile = TeacherProfile(
      user: createdUser,
      tscNumber: request.tscNumber,
      schoolId: request.schoolId,
      subjectsTaught: request.subjectsTaught,
      classesAssigned: request.classesAssigned,
      qualification: request.qualification,
      yearsOfExperience: request.yearsOfExperience,
      specialization: request.specialization,
    );
    
    await _userRepository.createTeacherProfile(teacherProfile);
    
    final tokens = _generateTokens(createdUser);
    
    return AuthResult(
      user: createdUser,
      accessToken: tokens['accessToken']!,
      refreshToken: tokens['refreshToken']!,
    );
  }
  
  Future<AuthResult> registerStudent(StudentRegistrationRequest request) async {
    _validateStudentRegistration(request);
    
    final existingUser = await _userRepository.findByEmail(request.email);
    if (existingUser != null) {
      throw ValidationException('Email already registered');
    }
    
    final hashedPassword = BCrypt.hashpw(
      request.password, 
      BCrypt.gensalt(logRounds: AppConfig.bcryptRounds)
    );
    
    final user = UserModel(
      id: generateId(),
      name: request.name,
      email: request.email,
      role: UserRole.student,
      isActive: true,
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final createdUser = await _userRepository.create(user, hashedPassword);
    
    // Create student profile
    final studentProfile = StudentProfile(
      user: createdUser,
      admissionNumber: request.admissionNumber,
      schoolId: request.schoolId,
      className: request.className,
      dateOfBirth: request.dateOfBirth,
      parentGuardianContact: request.parentGuardianContact,
      countyOfResidence: request.countyOfResidence,
      subjects: _getSubjectsForClass(request.className),
      previousSchool: request.previousSchool,
      specialNeeds: request.specialNeeds,
      enrollmentDate: DateTime.now(),
    );
    
    await _userRepository.createStudentProfile(studentProfile);
    
    final tokens = _generateTokens(createdUser);
    
    return AuthResult(
      user: createdUser,
      accessToken: tokens['accessToken']!,
      refreshToken: tokens['refreshToken']!,
    );
  }
  
  Future<AuthResult> registerParent(ParentRegistrationRequest request) async {
    _validateParentRegistration(request);
    
    final existingUser = await _userRepository.findByEmail(request.email);
    if (existingUser != null) {
      throw ValidationException('Email already registered');
    }
    
    // Validate children exist
    for (final admissionNumber in request.childrenAdmissionNumbers) {
      final child = await _userRepository.findStudentByAdmissionNumber(admissionNumber);
      if (child == null) {
        throw ValidationException('Student with admission number $admissionNumber not found');
      }
    }
    
    final hashedPassword = BCrypt.hashpw(
      request.password, 
      BCrypt.gensalt(logRounds: AppConfig.bcryptRounds)
    );
    
    final user = UserModel(
      id: generateId(),
      name: request.name,
      email: request.email,
      role: UserRole.parent,
      isActive: true,
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      phoneNumber: request.phoneNumber,
    );
    
    final createdUser = await _userRepository.create(user, hashedPassword);
    
    // Get children IDs
    final childrenIds = <String>[];
    for (final admissionNumber in request.childrenAdmissionNumbers) {
      final child = await _userRepository.findStudentByAdmissionNumber(admissionNumber);
      if (child != null) {
        childrenIds.add(child.user.id);
      }
    }
    
    final parentProfile = ParentProfile(
      user: createdUser,
      nationalId: request.nationalId,
      childrenIds: childrenIds,
      relationshipToChildren: request.relationshipToChildren,
      address: request.address,
      occupation: request.occupation,
      emergencyContact: request.emergencyContact,
      lastActiveDate: DateTime.now(),
    );
    
    await _userRepository.createParentProfile(parentProfile);
    
    final tokens = _generateTokens(createdUser);
    
    return AuthResult(
      user: createdUser,
      accessToken: tokens['accessToken']!,
      refreshToken: tokens['refreshToken']!,
    );
  }
  
  Future<AuthResult> login(String email, String password) async {
    final user = await _userRepository.findByEmail(email);
    if (user == null) {
      throw AuthenticationException('Invalid email or password');
    }
    
    if (!user.isActive) {
      throw AuthenticationException('Account is deactivated');
    }
    
    final storedPassword = await _userRepository.getPasswordHash(user.id);
    if (storedPassword == null || !BCrypt.checkpw(password, storedPassword)) {
      throw AuthenticationException('Invalid email or password');
    }
    
    // Update last login
    await _userRepository.updateLastLogin(user.id);
    
    final tokens = _generateTokens(user);
    
    return AuthResult(
      user: user,
      accessToken: tokens['accessToken']!,
      refreshToken: tokens['refreshToken']!,
    );
  }
  
  Map<String, String> _generateTokens(UserModel user) {
    final accessTokenPayload = {
      'userId': user.id,
      'email': user.email,
      'role': user.role.toString(),
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    
    final refreshTokenPayload = {
      'userId': user.id,
      'type': 'refresh',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    
    final accessToken = JWT(accessTokenPayload).sign(
      SecretKey(AppConfig.jwtSecret),
      expiresIn: Duration(hours: 24),
    );
    
    final refreshToken = JWT(refreshTokenPayload).sign(
      SecretKey(AppConfig.jwtSecret),
      expiresIn: Duration(days: 7),
    );
    
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
  
  void _validateRegistrationRequest(dynamic request) {
    if (request.name.trim().length < 2) {
      throw ValidationException('Name must be at least 2 characters');
    }
    
    if (!Validators.isValidEmail(request.email)) {
      throw ValidationException('Invalid email format');
    }
    
    if (!Validators.isValidPassword(request.password)) {
      throw ValidationException(
        'Password must be at least 8 characters with uppercase, lowercase, number, and special character'
      );
    }
  }
  
  void _validateTeacherRegistration(TeacherRegistrationRequest request) {
    _validateRegistrationRequest(request);
    
    if (!Validators.isValidKenyanPhone(request.phoneNumber)) {
      throw ValidationException('Invalid Kenyan phone number');
    }
    
    if (request.subjectsTaught.isEmpty) {
      throw ValidationException('At least one subject must be specified');
    }
    
    if (request.classesAssigned.isEmpty) {
      throw ValidationException('At least one class must be assigned');
    }
  }
  
  void _validateStudentRegistration(StudentRegistrationRequest request) {
    _validateRegistrationRequest(request);
    
    if (request.admissionNumber.trim().isEmpty) {
      throw ValidationException('Admission number is required');
    }
    
    if (!Validators.isValidKenyanPhone(request.parentGuardianContact)) {
      throw ValidationException('Invalid parent/guardian phone number');
    }
  }
  
  void _validateParentRegistration(ParentRegistrationRequest request) {
    _validateRegistrationRequest(request);
    
    if (!Validators.isValidKenyanPhone(request.phoneNumber)) {
      throw ValidationException('Invalid phone number');
    }
    
    if (!Validators.isValidKenyanNationalId(request.nationalId)) {
      throw ValidationException('Invalid national ID');
    }
    
    if (request.childrenAdmissionNumbers.isEmpty) {
      throw ValidationException('At least one child admission number is required');
    }
  }
  
  bool _isValidTSCNumber(String tscNumber) {
    // TSC numbers typically follow a pattern like TSC/12345/2020
    return RegExp(r'^TSC\/\d{5}\/\d{4}).hasMatch(tscNumber);
  }
  
  List<String> _getSubjectsForClass(String className) {
    // Convert class name to grade level and get subjects
    final gradeLevel = _classNameToGradeLevel(className);
    return KenyaCurriculum.getSubjectsForGrade(gradeLevel);
  }
  
  String _classNameToGradeLevel(String className) {
    // Map class names to grade levels
    final classMap = {
      'PP1': 'pp1',
      'PP2': 'pp2',
      'Grade 1': 'grade_1',
      'Grade 2': 'grade_2',
      'Grade 3': 'grade_3',
      'Grade 4': 'grade_4',
      'Grade 5': 'grade_5',
      'Grade 6': 'grade_6',
      'Grade 7': 'grade_7',
      'Grade 8': 'grade_8',
      'Grade 9': 'grade_9',
      'Form 1': 'form_1',
      'Form 2': 'form_2',
      'Form 3': 'form_3',
      'Form 4': 'form_4',
    };
    
    return classMap[className] ?? 'grade_1';
  }
  
  String generateId() {
    final bytes = utf8.encode(DateTime.now().toIso8601String());
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 24);
  }
}

class AuthResult {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  
  AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}
