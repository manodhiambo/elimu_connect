import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Please select your role:'),
            ElevatedButton(
              onPressed: () async {
                await _setRole('admin');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboard()),
                );
              },
              child: const Text('Admin'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _setRole('teacher');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TeacherDashboard()),
                );
              },
              child: const Text('Teacher'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _setRole('student');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentDashboard()),
                );
              },
              child: const Text('Student'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setRole(String role) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.set({
      'role': role,
      'email': user.email,
      'name': user.displayName ?? 'Unknown',
    });
  }
}
