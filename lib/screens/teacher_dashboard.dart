import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  void _navigate(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Teacher, ${user?.email ?? ""}',
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
                      icon: Icons.book,
                      label: 'Upload Book',
                      onTap: () => _navigate(context, '/uploadBook'),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.picture_as_pdf,
                      label: 'Upload Paper',
                      onTap: () => _navigate(context, '/uploadPaper'),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.forum,
                      label: 'Question Forum',
                      onTap: () => _navigate(context, '/forum'),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.person,
                      label: 'Profile',
                      onTap: () => _navigate(context, '/profile'),
                    ),
                    // Uncomment when ready:
                    // _buildCard(
                    //   context,
                    //   icon: Icons.assignment,
                    //   label: 'Assign Homework',
                    //   onTap: () => _navigate(context, '/assignHomework'),
                    // ),
                    // _buildCard(
                    //   context,
                    //   icon: Icons.bar_chart,
                    //   label: 'Performance',
                    //   onTap: () => _navigate(context, '/studentPerformance'),
                    // ),
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
                Icon(icon, size: 36, color: Colors.orange[800]),
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
