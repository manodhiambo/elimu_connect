import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Teacher Dashboard',
      body: const Center(
        child: Text('Teacher Dashboard - Coming Soon!'),
      ),
    );
  }
}
