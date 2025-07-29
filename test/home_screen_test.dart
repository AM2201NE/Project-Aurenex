import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neonote/screens/home_screen.dart';
import 'package:neonote/services/storage_service.dart';
import 'package:neonote/services/theme_service.dart';

void main() {
  testWidgets('HomeScreen shows loading indicator when loading', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          storageService: StorageService(),
          themeService: ThemeService(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
