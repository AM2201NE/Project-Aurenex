import 'package:flutter/material.dart';

/// Apple-inspired design system
class AppleDesign {
  // Colors
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color secondaryBlue = Color(0xFF5AC8FA);
  static const Color green = Color(0xFF34C759);
  static const Color red = Color(0xFFFF3B30);
  static const Color orange = Color(0xFFFF9500);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color purple = Color(0xFF5856D6);
  static const Color pink = Color(0xFFFF2D55);
  
  // Background colors
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color darkBackground = Color(0xFF1C1C1E);
  
  // Text colors
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  
  // Create light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: Colors.white,
        background: lightBackground,
        error: red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: lightTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return primaryBlue.withValues(alpha: 0.5);
              }
              return primaryBlue;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              return Colors.white;
            },
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          letterSpacing: -0.4,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          letterSpacing: -0.4,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          letterSpacing: -0.4,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          letterSpacing: -0.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
          letterSpacing: -0.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: lightTextPrimary,
          letterSpacing: -0.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: lightTextPrimary,
          letterSpacing: -0.2,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          color: lightTextSecondary,
          letterSpacing: -0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  // Create dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: Color(0xFF2C2C2E),
        background: darkBackground,
        error: red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return primaryBlue.withValues(alpha: 0.5);
              }
              return primaryBlue;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              return Colors.white;
            },
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.4,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.4,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.4,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: darkTextPrimary,
          letterSpacing: -0.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: darkTextPrimary,
          letterSpacing: -0.2,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          color: darkTextSecondary,
          letterSpacing: -0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  // Typography styles
  static TextStyle largeTitle({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 34,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      letterSpacing: -0.4,
    );
  }
  
  static TextStyle title1({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 28,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      letterSpacing: -0.4,
    );
  }
  
  static TextStyle title2({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 22,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      letterSpacing: -0.4,
    );
  }
  
  static TextStyle title3({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 20,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      letterSpacing: -0.4,
    );
  }
  
  static TextStyle headline({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 17,
      fontWeight: fontWeight ?? FontWeight.semiBold,
      color: color,
      letterSpacing: -0.4,
    );
  }
  
  static TextStyle body({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 17,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      letterSpacing: -0.4,
    );
  }
  
  static TextStyle callout({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      letterSpacing: -0.2,
    );
  }
  
  static TextStyle subhead({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 15,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      letterSpacing: -0.2,
    );
  }
  
  static TextStyle footnote({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 13,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      letterSpacing: -0.1,
    );
  }
  
  static TextStyle caption1({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      letterSpacing: 0,
    );
  }
  
  static TextStyle caption2({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 11,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      letterSpacing: 0.1,
    );
  }
  
  // Helper method to get a font weight by name
  static FontWeight getFontWeight(String name) {
    switch (name) {
      case 'ultraLight':
        return FontWeight.w100;
      case 'thin':
        return FontWeight.w200;
      case 'light':
        return FontWeight.w300;
      case 'regular':
        return FontWeight.w400;
      case 'medium':
        return FontWeight.w500;
      case 'semiBold':
        return FontWeight.w600;
      case 'bold':
        return FontWeight.w700;
      case 'heavy':
        return FontWeight.w800;
      case 'black':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }
}

// Extension for FontWeight to add named weights
extension FontWeightExtension on FontWeight {
  static const FontWeight ultraLight = FontWeight.w100;
  static const FontWeight thin = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight heavy = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}
