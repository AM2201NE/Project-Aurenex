import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ThemeService {
  // Theme mode notifier
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);
  
  // Light theme
  late ThemeData lightTheme;
  
  // Dark theme
  late ThemeData darkTheme;
  
  // Initialize theme service
  Future<void> initialize() async {
    // Load saved theme mode
    await _loadThemeMode();
    
    // Initialize themes
    _initializeThemes();
  }
  
  // Initialize themes
  void _initializeThemes() {
    lightTheme = _createTheme(
      brightness: Brightness.light,
      primaryColor: AppConfig.lightPrimaryColor,
      secondaryColor: AppConfig.lightSecondaryColor,
      backgroundColor: AppConfig.lightBackgroundColor,
      surfaceColor: AppConfig.lightSurfaceColor,
      errorColor: AppConfig.lightErrorColor,
      onPrimaryColor: Colors.white,
      onSecondaryColor: Colors.white,
      onBackgroundColor: Colors.black,
      onSurfaceColor: Colors.black,
      onErrorColor: Colors.white,
    );

    darkTheme = _createTheme(
      brightness: Brightness.dark,
      primaryColor: AppConfig.darkPrimaryColor,
      secondaryColor: AppConfig.darkSecondaryColor,
      backgroundColor: AppConfig.darkBackgroundColor,
      surfaceColor: AppConfig.darkSurfaceColor,
      errorColor: AppConfig.darkErrorColor,
      onPrimaryColor: Colors.white,
      onSecondaryColor: Colors.white,
      onBackgroundColor: Colors.white,
      onSurfaceColor: Colors.white,
      onErrorColor: Colors.black,
    );
  }

  ThemeData _createTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color errorColor,
    required Color onPrimaryColor,
    required Color onSecondaryColor,
    required Color onBackgroundColor,
    required Color onSurfaceColor,
    required Color onErrorColor,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
      onBackground: onBackgroundColor,
      onSurface: onSurfaceColor,
      onError: onErrorColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return primaryColor.withOpacity(0.5);
              }
              return primaryColor;
            },
          ),
          foregroundColor: MaterialStateProperty.all<Color>(onPrimaryColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  // Set theme mode
  void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
    _saveThemeMode(mode);
  }

  // Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString == 'light') {
      themeModeNotifier.value = ThemeMode.light;
    } else if (themeModeString == 'dark') {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.system;
    }
  }

  // Save theme mode to shared preferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeModeString;
    if (mode == ThemeMode.light) {
      themeModeString = 'light';
    } else if (mode == ThemeMode.dark) {
      themeModeString = 'dark';
    } else {
      themeModeString = 'system';
    }
    await prefs.setString('themeMode', themeModeString);
  }
}
