// File: packages/app/lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/core/services/app_initializer.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app services and handle any startup errors
  await _initializeApp();
  
  // Run the app with proper error handling
  runApp(
    ProviderScope(
      observers: kDebugMode ? [_AppProviderObserver()] : [],
      child: const ElimuConnectApp(),
    ),
  );
}

/// Initialize application services and configuration
Future<void> _initializeApp() async {
  try {
    // Set preferred device orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize app services
    await AppInitializer.initialize();

    if (kDebugMode) {
      print('✅ ElimuConnect initialized successfully');
    }
  } catch (error, stackTrace) {
    if (kDebugMode) {
      print('❌ Failed to initialize ElimuConnect: $error');
      print('Stack trace: $stackTrace');
    }
    
    // In production, you might want to send this to a crash reporting service
    // await CrashReporting.recordError(error, stackTrace);
  }
}

/// Provider observer for development debugging
class _AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode && provider.name != null) {
      print('Provider ${provider.name}: $previousValue → $newValue');
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      print('Provider ${provider.name} failed: $error');
    }
  }
}
