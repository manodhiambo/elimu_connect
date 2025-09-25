import 'package:flutter/material.dart';

class ElimuColors {
  // Primary Colors - Kenya flag inspired
  static const Color primary = Color(0xFF1B5E20); // Dark Green
  static const Color primaryContainer = Color(0xFFA8E6A1);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF002106);

  // Secondary Colors - Education themed
  static const Color secondary = Color(0xFFFF9800); // Amber/Orange
  static const Color secondaryContainer = Color(0xFFFFE0B2);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF5D1A00);

  // Tertiary Colors - Knowledge themed
  static const Color tertiary = Color(0xFF2196F3); // Blue
  static const Color tertiaryContainer = Color(0xFFBBDEFB);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF0D47A1);

  // Error Colors
  static const Color error = Color(0xFFB00020);
  static const Color errorContainer = Color(0xFFFDEDF0);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410000);

  // Success Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  // Warning Colors
  static const Color warning = Color(0xFFF57C00);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFFE65100);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1C1C1E);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // Background Colors
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1C1E);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFE1E1E1);

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFAEAEB2);

  // Border Colors
  static const Color border = Color(0xFFE5E5E7);
  static const Color borderFocus = primary;

  // Kenya-specific Colors
  static const Color kenyaRed = Color(0xFFD32F2F);
  static const Color kenyaBlack = Color(0xFF000000);
  static const Color kenyaWhite = Color(0xFFFFFFFF);
  static const Color kenyaGreen = Color(0xFF1B5E20);

  // Semantic Colors
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x66000000);

  // Grade Level Colors
  static const Map<String, Color> gradeLevelColors = {
    'pp': Color(0xFFFF9800), // Orange for pre-primary
    'primary': Color(0xFF4CAF50), // Green for primary
    'secondary': Color(0xFF2196F3), // Blue for secondary
  };

  // Subject Colors
  static const Map<String, Color> subjectColors = {
    'Mathematics': Color(0xFF3F51B5),
    'English': Color(0xFF9C27B0),
    'Kiswahili': Color(0xFFFF5722),
    'Science': Color(0xFF009688),
    'Social Studies': Color(0xFF795548),
    'Religious Education': Color(0xFF607D8B),
    'Creative Arts': Color(0xFFE91E63),
    'Physical Education': Color(0xFF8BC34A),
  };
}
