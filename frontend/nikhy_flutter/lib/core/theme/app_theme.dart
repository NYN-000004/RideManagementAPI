import 'package:flutter/material.dart';

class AppTheme {
  // Brand color palette - Deep Blue / Indigo direction
  static const Color primary = Color(0xFF0F172A); // Slate 900 (Deep Slate Navy)
  static const Color primaryDark = Color(0xFF020617); // Slate 950
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color indigo = Color(0xFF312E81); // Deep Indigo
  static const Color accent = Color(0xFF2563EB); // Royal Blue
  static const Color accentLight = Color(0xFF3B82F6); // Blue 500
  static const Color background = Color(0xFFF8FAFC); // Slate 50 (Very light neutral)
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // High contrast slate
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successDark = Color(0xFF059669); // Emerald 600
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF0EA5E9); // Sky 500
  static const Color purple = Color(0xFF8B5CF6); // Violet 500

  // Shadows
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowSuccess => [
        BoxShadow(
          color: success.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 8,
        height: 68,
        indicatorColor: primary.withValues(alpha: 0.08),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: primary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
