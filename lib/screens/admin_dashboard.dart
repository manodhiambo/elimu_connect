import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'manage_teachers_screen.dart';
import 'manage_students_screen.dart';
import 'manage_users_screen.dart'; // ✅ NEW
import 'upload_book_screen.dart';
import 'upload_paper_screen.dart';
import 'app_settings_screen.dart';
import 'admin_profile_screen.dart';
import 'student_inbox_screen.dart'; // For viewing all message threads
import 'question_forum_screen.dart'; // Forum viewer

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.email ?? "Admin"}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildCard(
                      context,
                      icon: Icons.people_outline,
                      label: 'Manage Students',
                      onTap: () => _navigateTo(context, const ManageStudentsScreen()),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.person_outline,
                      label: 'Manage Teachers',
                      onTap: () => _navigateTo(context, const ManageTeachersScreen()),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.group_outlined,
                      label: 'Manage Users', // ✅ NEW CARD
                      onTap: () => _navigateTo(context, const ManageUsersScreen()),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.mail_outline,
                      label: 'Message Center',
                      onTap: () => _navigateTo(context, StudentInboxScreen()),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.forum_outlined,
                      label: 'Question Forum',
                      onTap: () => _navigateTo(context, const QuestionForumScreen()),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.book_outlined,
                      label: 'Upload Books',
                      onTap: () => _navigateTo(context, const UploadBookScreen()),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Upload Papers',
                      onTap: () => _navigateTo(context, const UploadPaperScreen()),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.settings_outlined,
                      label: 'App Settings',
                      onTap: () => _navigateTo(context, const AppSettingsScreen()),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.account_circle_outlined,
                      label: 'Admin Profile',
                      onTap: () => _navigateTo(context, const AdminProfileScreen()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 20,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: Colors.deepOrange),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
