import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';

class ParentDashboardPage extends ConsumerWidget {
  const ParentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Parent Dashboard',
      body: const Center(
        child: Text('Parent Dashboard - Coming Soon!'),
      ),
    );
  }
}
