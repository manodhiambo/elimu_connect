import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';
import 'routing/app_router.dart';
import 'core/providers/app_providers.dart';

class ElimuConnectApp extends ConsumerWidget {
  const ElimuConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ElimuConnect',
      debugShowCheckedModeBanner: false,
      theme: ElimuTheme.lightTheme,
      darkTheme: ElimuTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Prevent font scaling issues
          ),
          child: child!,
        );
      },
    );
  }
}
