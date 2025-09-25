import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Student Dashboard',
      body: const Center(
        child: Text('Student Dashboard - Coming Soon!'),
      ),
    );
  }
}
