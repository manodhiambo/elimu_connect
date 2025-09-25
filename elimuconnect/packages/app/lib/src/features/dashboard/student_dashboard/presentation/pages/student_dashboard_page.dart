// packages/app/lib/src/features/dashboard/student_dashboard/presentation/pages/student_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.name ?? 'Student'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStats(context, ref),
              const SizedBox(height: 24),
              _buildRecentActivity(context, ref),
              const SizedBox(height: 24),
              _buildSubjects(context, ref),
              const SizedBox(height: 24),
              _buildUpcomingAssignments(context, ref),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StudentBottomNavigation(),
    );
  }
  
  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Books Read',
            value: '12',
            icon: Icons.book,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Quizzes Taken',
            value: '8',
            icon: Icons.quiz,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
