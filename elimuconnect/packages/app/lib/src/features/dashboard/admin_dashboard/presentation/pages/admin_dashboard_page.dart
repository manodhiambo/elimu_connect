import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Admin Dashboard',
      body: const Center(
        child: Text('Admin Dashboard - Coming Soon!'),
      ),
    );
  }
}
