import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      print("Register Error: $e");
      return null;
    }
  }

  // Sign In
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Check Current User
  User? get currentUser => _auth.currentUser;
}
