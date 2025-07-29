import 'package:flutter_test/flutter_test.dart';
import 'package:neonote/main.dart';
import 'package:neonote/services/storage_service.dart';
import 'package:neonote/services/theme_service.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(NeonoteApp(storageService: StorageService(), themeService: ThemeService()));
  });
}
