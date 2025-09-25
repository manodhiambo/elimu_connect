import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';
import 'routing/admin_router.dart';

class ElimuConnectAdminApp extends ConsumerWidget {
  const ElimuConnectAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);

    return MaterialApp.router(
      title: 'ElimuConnect Admin',
      debugShowCheckedModeBanner: false,
      theme: ElimuTheme.lightTheme.copyWith(
        appBarTheme: ElimuTheme.lightTheme.appBarTheme.copyWith(
          backgroundColor: ElimuColors.primary,
          foregroundColor: ElimuColors.onPrimary,
        ),
      ),
      routerConfig: router,
    );
  }
}
