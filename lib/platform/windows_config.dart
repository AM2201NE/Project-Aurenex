import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'file_picker_windows.dart';

/// Platform-specific configuration for Windows
class WindowsConfig {
  /// Initialize Windows-specific configurations
  static Future<void> initialize() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      // Initialize SQLite FFI for Windows
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      
      // Set preferred window size for Windows
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      
      // Initialize file picker for Windows
      await FilePickerWindows.initialize();
      
      debugPrint('Windows platform configuration initialized');
    }
  }
  
  /// Register plugins that might have platform-specific issues
  static void registerPlugins() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      // Register Windows-specific plugin implementations
      FilePickerWindows.registerWith();
      
      debugPrint('Windows-specific plugin configurations registered');
    }
  }
}
