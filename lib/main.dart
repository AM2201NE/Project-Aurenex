import 'package:flutter/material.dart';
import 'platform/windows_config.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log error details to console and file
    print('GLOBAL FLUTTER ERROR: ${details.exceptionAsString()}');
    print('Stack trace: ${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    print('GLOBAL PLATFORM ERROR: $error');
    print('Stack trace: $stack');
    return true;
  };

  // Initialize platform-specific configurations
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    await WindowsConfig.initialize();
    WindowsConfig.registerPlugins();
  }

  // Initialize services
  final storageService = StorageService();
  await storageService.database; // Initialize database

  final themeService = ThemeService();
  await themeService.initialize();

  // Run the app
  runApp(NeonoteApp(
    storageService: storageService,
    themeService: themeService,
  ));
}

class NeonoteApp extends StatelessWidget {
  final StorageService storageService;
  final ThemeService themeService;
  
  const NeonoteApp({
    super.key,
    required this.storageService,
    required this.themeService,
  });
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Neonote',
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: HomeScreen(
            storageService: storageService,
            themeService: themeService,
          ),
        );
      },
    );
  }
}
