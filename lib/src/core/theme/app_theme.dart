import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const _primary = Color(0xFF3F46D8);
  static const _lightScaffold = Color(0xFFF8F8FB);
  static const _darkScaffold = Color(0xFF0F1327);
  static const _lightSurface = Colors.white;
  static const _darkSurface = Color(0xFF171C34);
  static const _lightText = Color(0xFF111111);
  static const _darkText = Color(0xFFF7F8FE);

  static TextTheme _baseTextTheme(Color color) {
    return ThemeData.light().textTheme.apply(
      bodyColor: color,
      displayColor: color,
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: _primary,
        secondary: const Color(0xFF3CCB7F),
        surface: _lightSurface,
        surfaceContainerHighest: const Color(0xFFF5F6FB),
        onSurface: _lightText,
      ),
      scaffoldBackgroundColor: _lightScaffold,
      fontFamily: 'SF Pro Display',
      textTheme: _baseTextTheme(_lightText),
      dividerColor: const Color(0xFFECECF2),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF8A8EA3),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: const Color(0xFF5D6290),
        suffixIconColor: const Color(0xFF5D6290),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.55)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }

  static ThemeData dark() {
    final lightTheme = light();
    final scheme = lightTheme.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: _primary,
      secondary: const Color(0xFF3CCB7F),
      surface: _darkSurface,
      surfaceContainerHighest: const Color(0xFF20284A),
      onSurface: _darkText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _darkScaffold,
      fontFamily: 'SF Pro Display',
      textTheme: _baseTextTheme(_darkText),
      dividerColor: const Color(0xFF2B345A),
      shadowColor: Colors.black.withValues(alpha: 0.24),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFABB3D7),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: const Color(0xFFABB3D7),
        suffixIconColor: const Color(0xFFABB3D7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }
}
