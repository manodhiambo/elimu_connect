// File: packages/app/lib/src/app.dart (Updated with enhanced error handling and splash)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elimuconnect_design_system/design_system.dart';
import 'core/providers/app_providers.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'routing/app_router.dart';

class ElimuConnectApp extends ConsumerWidget {
  const ElimuConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appInitialized = ref.watch(appInitializationProvider);
    
    return MaterialApp.router(
      title: 'ElimuConnect - Education Platform for Kenya',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: ElimuTheme.lightTheme,
      darkTheme: ElimuTheme.darkTheme,
      themeMode: themeMode,
      
      // Routing configuration
      routerConfig: router,
      
      // App-wide builder for consistent behavior
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling issues on different devices
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: ScrollConfiguration(
            // Consistent scroll behavior across platforms
            behavior: const _AppScrollBehavior(),
            child: appInitialized.when(
              data: (initialized) => child ?? const SizedBox.shrink(),
              loading: () => const SplashPage(),
              error: (error, stackTrace) => AppErrorPage(
                error: error,
                onRetry: () => ref.refresh(appInitializationProvider),
              ),
            ),
          ),
        );
      },
      
      // Localization support (for future multi-language support)
      locale: const Locale('en', 'KE'), // English (Kenya)
      supportedLocales: const [
        Locale('en', 'KE'), // English (Kenya)
        Locale('sw', 'KE'), // Swahili (Kenya)
      ],
      
      // Error handling
      onGenerateTitle: (context) => 'ElimuConnect',
    );
  }
}

/// Custom scroll behavior for consistent experience
class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Remove overscroll glow on Android
  }
}

/// App initialization provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Simulate app initialization with minimum splash time
  await Future.delayed(const Duration(milliseconds: 1500));
  
  // Perform actual initialization tasks
  await AppInitializer.initialize();
  
  return true;
});
