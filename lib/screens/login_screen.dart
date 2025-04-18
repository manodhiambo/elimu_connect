import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'register_screen.dart';
import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import 'role_selector_screen.dart'; // Import the Role Selector Screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await routeUser(userCredential.user!.uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final doc = await userRef.get();
      if (!doc.exists) {
        // New user, need to set role
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectorScreen()),
        );
      } else {
        // Existing user, route to their dashboard
        await routeUser(user.uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> routeUser(String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      throw Exception("User data not found in Firestore.");
    }

    final role = userDoc.data()!['role'];

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } else if (role == 'teacher') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentDashboard()),
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: login,
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('No account? Register here'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
