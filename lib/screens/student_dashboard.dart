import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  void _navigate(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
              'Welcome, ${user?.email ?? "Student"}!',
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
                      icon: Icons.inbox,
                      label: 'Messages',
                      onTap: () => _navigate(context, '/studentInbox'),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat with Others',
                      onTap: () => _navigate(context, '/chat'),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.book,
                      label: 'Books & Materials',
                      onTap: () => _navigate(context, '/books'),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.description,
                      label: 'Past Papers',
                      onTap: () => _navigate(context, '/pastPapers'),
                    ),
                    _buildCard(
                      context,
                      icon: Icons.school,
                      label: 'Revision Center',
                      onTap: () => _navigate(context, '/revision'),
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
                      label: 'My Profile',
                      onTap: () => _navigate(context, '/profile'),
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
                Icon(icon, size: 36, color: Colors.indigo),
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
