// packages/app/lib/src/features/auth/presentation/providers/auth_provider.dart
import 'package:riverpod/riverpod.dart';
import 'package:elimuconnect_shared/shared.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState.initial());
  
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> registerAdmin(AdminRegistrationRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // Validate admin code
      if (request.adminCode != 'OnlyMe@2025') {
        throw Exception('Invalid admin registration code');
      }
      final user = await _authService.registerAdmin(request);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> registerTeacher(TeacherRegistrationRequest request) async {
    // Implementation for teacher registration
  }
  
  Future<void> registerStudent(StudentRegistrationRequest request) async {
    // Implementation for student registration
  }
  
  Future<void> registerParent(ParentRegistrationRequest request) async {
    // Implementation for parent registration
  }
}
