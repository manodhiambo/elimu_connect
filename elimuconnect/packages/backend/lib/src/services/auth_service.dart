import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:elimuconnect_shared/shared.dart';

class AuthService {
  
  Future<AuthResult> registerAdmin(AdminRegistrationRequest request) async {
    // Validate admin code
    const adminCode = 'OnlyMe@2025';
    if (request.adminCode != adminCode) {
      throw Exception('Invalid admin registration code');
    }
    
    // Validate request
    _validateRegistrationRequest(request);
    
    // Hash password
    final hashedPassword = BCrypt.hashpw(request.password, BCrypt.gensalt());
    
    // Create user (simplified for now)
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
    
    // Generate tokens (simplified)
    final tokens = _generateTokens(user);
    
    return AuthResult(
      user: user,
      accessToken: tokens['accessToken']!,
      refreshToken: tokens['refreshToken']!,
    );
  }

  Future<AuthResult> login(String email, String password) async {
    // Simplified login logic
    throw UnimplementedError('Login not yet implemented');
  }

  void _validateRegistrationRequest(dynamic request) {
    if (request.name.trim().length < 2) {
      throw Exception('Name must be at least 2 characters');
    }
    
    if (!_isValidEmail(request.email)) {
      throw Exception('Invalid email format');
    }
    
    if (request.password.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Map<String, String> _generateTokens(UserModel user) {
    // Simplified token generation
    final accessToken = 'access_token_${user.id}';
    final refreshToken = 'refresh_token_${user.id}';
    
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  String generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '').replaceAll('-', '').replaceAll('_', '');
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
