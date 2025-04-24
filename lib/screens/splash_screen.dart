import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate splash duration

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userData = snapshot.data();
        final role = userData?['role'];
        final userName = userData?['username'] ?? 'Unknown';
        final userId = user.uid;

        final args = {
          'userId': userId,
          'userName': userName,
        };

        switch (role) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/adminDashboard', arguments: args);
            break;
          case 'teacher':
            Navigator.pushReplacementNamed(context, '/teacherDashboard', arguments: args);
            break;
          case 'student':
            Navigator.pushReplacementNamed(context, '/studentDashboard', arguments: args);
            break;
          default:
            Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ElimuConnect',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
