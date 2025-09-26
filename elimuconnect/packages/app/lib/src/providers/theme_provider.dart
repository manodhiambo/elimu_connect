// File: packages/app/lib/src/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme_config.dart';
import '../services/storage_service.dart';
import '../core/di/service_locator.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeState {
  final AppThemeMode themeMode;
  final bool isSystemDarkMode;
  final Color? accentColor;
  final bool useSystemAccentColor;
  final double textScaleFactor;
  final bool reducedMotion;

  const ThemeState({
    required this.themeMode,
    required this.isSystemDarkMode,
    this.accentColor,
    this.useSystemAccentColor = false,
    this.textScaleFactor = 1.0,
    this.reducedMotion = false,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isSystemDarkMode,
    Color? accentColor,
    bool? useSystemAccentColor,
    double? textScaleFactor,
    bool? reducedMotion,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isSystemDarkMode: isSystemDarkMode ?? this.isSystemDarkMode,
      accentColor: accentColor ?? this.accentColor,
      useSystemAccentColor: useSystemAccentColor ?? this.useSystemAccentColor,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  ThemeMode get effectiveThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return isSystemDarkMode;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isSystemDarkMode == isSystemDarkMode &&
        other.accentColor == accentColor &&
        other.useSystemAccentColor == useSystemAccentColor &&
        other.textScaleFactor == textScaleFactor &&
        other.reducedMotion == reducedMotion;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      isSystemDarkMode,
      accentColor,
      useSystemAccentColor,
      textScaleFactor,
      reducedMotion,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final StorageService _storageService;
  
  static const String _themeModeKey = 'app_theme_mode';
  static const String _accentColorKey = 'app_accent_color';
  static const String _useSystemAccentKey = 'app_use_system_accent';
  static const String _textScaleFactorKey = 'app_text_scale_factor';
  static const String _reducedMotionKey = 'app_reduced_motion';

  ThemeNotifier(this._storageService) : super(const ThemeState(
    themeMode: AppThemeMode.system,
    isSystemDarkMode: false,
  ));

  /// Initialize theme from stored preferences
  Future<void> initialize() async {
    try {
      final themeModeString = await _storageService.getString(_themeModeKey);
      final accentColorValue = await _storageService.getInt(_accentColorKey);
      final useSystemAccent = await _storageService.getBool(_useSystemAccentKey) ?? false;
      final textScaleFactor = await _storageService.getDouble(_textScaleFactorKey) ?? 1.0;
      final reducedMotion = await _storageService.getBool(_reducedMotionKey) ?? false;

      final themeMode = _parseThemeMode(themeModeString);
      final accentColor = accentColorValue != null ? Color(accentColorValue) : null;

      state = state.copyWith(
        themeMode: themeMode,
        accentColor: accentColor,
        useSystemAccentColor: useSystemAccent,
        textScaleFactor: textScaleFactor,
        reducedMotion: reducedMotion,
      );
    } catch (e) {
      // If there's an error loading preferences, use defaults
      print('Error loading theme preferences: $e');
    }
  }

  /// Update system dark mode status
  void updateSystemDarkMode(bool isDark) {
    if (state.isSystemDarkMode != isDark) {
      state = state.copyWith(isSystemDarkMode: isDark);
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (state.themeMode != mode) {
      state = state.copyWith(themeMode: mode);
      await _storageService.setString(_themeModeKey, mode.name);
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Set custom accent color
  Future<void> setAccentColor(Color color) async {
    if (state.accentColor != color) {
      state = state.copyWith(
        accentColor: color,
        useSystemAccentColor: false,
      );
      await _storageService.setInt(_accentColorKey, color.value);
      await _storageService.setBool(_useSystemAccentKey, false);
    }
  }

  /// Use system accent color
  Future<void> useSystemAccentColor() async {
    if (!state.useSystemAccentColor) {
      state = state.copyWith(
        useSystemAccentColor: true,
        accentColor: null,
      );
      await _storageService.setBool(_useSystemAccentKey, true);
      await _storageService.remove(_accentColorKey);
    }
  }

  /// Set text scale factor for accessibility
  Future<void> setTextScaleFactor(double factor) async {
    final clampedFactor = factor.clamp(0.8, 2.0);
    if (state.textScaleFactor != clampedFactor) {
      state = state.copyWith(textScaleFactor: clampedFactor);
      await _storageService.setDouble(_textScaleFactorKey, clampedFactor);
    }
  }

  /// Toggle reduced motion for accessibility
  Future<void> setReducedMotion(bool enabled) async {
    if (state.reducedMotion != enabled) {
      state = state.copyWith(reducedMotion: enabled);
      await _storageService.setBool(_reducedMotionKey, enabled);
    }
  }

  /// Reset theme to defaults
  Future<void> resetToDefaults() async {
    state = ThemeState(
      themeMode: AppThemeMode.system,
      isSystemDarkMode: state.isSystemDarkMode,
      accentColor: null,
      useSystemAccentColor: false,
      textScaleFactor: 1.0,
      reducedMotion: false,
    );

    // Clear stored preferences
    await _storageService.remove(_themeModeKey);
    await _storageService.remove(_accentColorKey);
    await _storageService.remove(_useSystemAccentKey);
    await _storageService.remove(_textScaleFactorKey);
    await _storageService.remove(_reducedMotionKey);
  }

  /// Get current theme data
  ThemeData get lightTheme {
    var theme = ThemeConfig.lightTheme;
    
    if (state.accentColor != null && !state.useSystemAccentColor) {
      theme = theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: state.accentColor!,
          secondary: state.accentColor!,
        ),
      );
    }
    
    return _applyTextScaling(theme);
  }

  /// Get current dark theme data
  ThemeData get darkTheme {
    var theme = ThemeConfig.darkTheme;
    
    if (state.accentColor != null && !state.useSystemAccentColor) {
      theme = theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: state.accentColor!,
          secondary: state.accentColor!,
        ),
      );
    }
    
    return _applyTextScaling(theme);
  }

  /// Apply text scaling to theme
  ThemeData _applyTextScaling(ThemeData theme) {
    if (state.textScaleFactor == 1.0) return theme;
    
    return theme.copyWith(
      textTheme: _scaleTextTheme(theme.textTheme, state.textScaleFactor),
      primaryTextTheme: _scaleTextTheme(theme.primaryTextTheme, state.textScaleFactor),
    );
  }

  /// Scale text theme
  TextTheme _scaleTextTheme(TextTheme textTheme, double scaleFactor) {
    return TextTheme(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontSize: (textTheme.displayLarge?.fontSize ?? 57) * scaleFactor,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontSize: (textTheme.displayMedium?.fontSize ?? 45) * scaleFactor,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontSize: (textTheme.displaySmall?.fontSize ?? 36) * scaleFactor,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontSize: (textTheme.headlineLarge?.fontSize ?? 32) * scaleFactor,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontSize: (textTheme.headlineMedium?.fontSize ?? 28) * scaleFactor,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * scaleFactor,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: (textTheme.titleLarge?.fontSize ?? 22) * scaleFactor,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: (textTheme.titleMedium?.fontSize ?? 18) * scaleFactor,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontSize: (textTheme.titleSmall?.fontSize ?? 16) * scaleFactor,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * scaleFactor,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: (textTheme.bodyMedium?.fontSize ?? 14) * scaleFactor,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontSize: (textTheme.bodySmall?.fontSize ?? 12) * scaleFactor,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontSize: (textTheme.labelLarge?.fontSize ?? 14) * scaleFactor,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontSize: (textTheme.labelMedium?.fontSize ?? 12) * scaleFactor,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontSize: (textTheme.labelSmall?.fontSize ?? 11) * scaleFactor,
      ),
    );
  }

  /// Parse theme mode from string
  AppThemeMode _parseThemeMode(String? modeString) {
    if (modeString == null) return AppThemeMode.system;
    
    try {
      return AppThemeMode.values.firstWhere(
        (mode) => mode.name == modeString,
        orElse: () => AppThemeMode.system,
      );
    } catch (e) {
      return AppThemeMode.system;
    }
  }

  /// Get available theme options for UI
  List<ThemeOption> getThemeOptions() {
    return [
      ThemeOption(
        mode: AppThemeMode.system,
        title: 'System',
        subtitle: 'Follow system setting',
        icon: Icons.brightness_auto,
      ),
      ThemeOption(
        mode: AppThemeMode.light,
        title: 'Light',
        subtitle: 'Light theme',
        icon: Icons.light_mode,
      ),
      ThemeOption(
        mode: AppThemeMode.dark,
        title: 'Dark',
        subtitle: 'Dark theme',
        icon: Icons.dark_mode,
      ),
    ];
  }

  /// Get predefined accent colors
  List<AccentColorOption> getAccentColorOptions() {
    return [
      AccentColorOption(
        color: ThemeConfig.primaryColor,
        name: 'Blue',
        isDefault: true,
      ),
      AccentColorOption(
        color: ThemeConfig.secondaryColor,
        name: 'Orange',
      ),
      AccentColorOption(
        color: ThemeConfig.kenyaRed,
        name: 'Kenya Red',
      ),
      AccentColorOption(
        color: ThemeConfig.kenyaGreen,
        name: 'Kenya Green',
      ),
      AccentColorOption(
        color: Colors.purple,
        name: 'Purple',
      ),
      AccentColorOption(
        color: Colors.teal,
        name: 'Teal',
      ),
      AccentColorOption(
        color: Colors.indigo,
        name: 'Indigo',
      ),
      AccentColorOption(
        color: Colors.pink,
        name: 'Pink',
      ),
    ];
  }

  /// Get text scale options for accessibility
  List<TextScaleOption> getTextScaleOptions() {
    return [
      TextScaleOption(factor: 0.8, label: 'Small'),
      TextScaleOption(factor: 1.0, label: 'Normal', isDefault: true),
      TextScaleOption(factor: 1.2, label: 'Large'),
      TextScaleOption(factor: 1.4, label: 'Extra Large'),
      TextScaleOption(factor: 1.6, label: 'Huge'),
    ];
  }
}

// Provider definition
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(ServiceLocator.instance<StorageService>());
});

// Utility providers
final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.effectiveThemeMode;
});

final isDarkModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.isDarkMode;
});

final lightThemeProvider = Provider<ThemeData>((ref) {
  final themeNotifier = ref.read(themeProvider.notifier);
  return themeNotifier.lightTheme;
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final themeNotifier = ref.read(themeProvider.notifier);
  return themeNotifier.darkTheme;
});

// Helper classes
class ThemeOption {
  final AppThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;

  const ThemeOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class AccentColorOption {
  final Color color;
  final String name;
  final bool isDefault;

  const AccentColorOption({
    required this.color,
    required this.name,
    this.isDefault = false,
  });
}

class TextScaleOption {
  final double factor;
  final String label;
  final bool isDefault;

  const TextScaleOption({
    required this.factor,
    required this.label,
    this.isDefault = false,
  });
}

// Extension for easy access in widgets
extension ThemeExtensions on WidgetRef {
  ThemeNotifier get theme => read(themeProvider.notifier);
  ThemeState get themeState => watch(themeProvider);
  bool get isDark => watch(isDarkModeProvider);
  ThemeData get lightTheme => watch(lightThemeProvider);
  ThemeData get darkTheme => watch(darkThemeProvider);
}
