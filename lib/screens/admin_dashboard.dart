import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'manage_teachers_screen.dart';
import 'manage_students_screen.dart';
import 'upload_book_screen.dart';
import 'upload_paper_screen.dart';
import 'app_settings_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Admin Tools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ManageTeachersScreen(),
                  ),
                );
              },
              child: const Text('Manage Teachers'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ManageStudentsScreen(),
                  ),
                );
              },
              child: const Text('Manage Students'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UploadBookScreen(),
                  ),
                );
              },
              child: const Text('Upload Books'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UploadPaperScreen(),
                  ),
                );
              },
              child: const Text('Upload Past Papers'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AppSettingsScreen(),
                  ),
                );
              },
              child: const Text('App Settings'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdminProfileScreen(),
                  ),
                );
              },
              child: const Text('Admin Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
