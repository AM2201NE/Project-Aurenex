import 'package:flutter/material.dart';

class AppConfig {
  static const String modelPath = r'C:\Users\nsc\Desktop\notion_offline - Copie\assets\ai_model\Qwen2-VL-2B-Instruct-Q4_K_M.gguf';
  static const String modelName = 'Qwen2-VL-2B-Instruct-Q4_K_M.gguf';

  // Light Theme Colors
  static const Color lightPrimaryColor = Color(0xFF2E7EF7);
  static const Color lightSecondaryColor = Color(0xFF6C63FF);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightSurfaceColor = Colors.white;
  static Color lightErrorColor = Colors.red.shade700;

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF4B8EF9);
  static const Color darkSecondaryColor = Color(0xFF8C7BFF);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static Color darkErrorColor = Colors.red.shade300;
}
