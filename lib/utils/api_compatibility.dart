import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Extension methods for Color to handle deprecated APIs
extension ColorExtension on Color {
  /// Replacement for withOpacity that uses withValues to avoid precision loss warnings
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromRGBO(
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
      alpha ?? opacity,
    );
  }
}

/// Extension methods for Theme to handle deprecated APIs
extension ThemeExtension on ThemeData {
  /// Get a color from the color scheme with proper null safety
  Color getColorFromScheme(Color? color, Color defaultColor) {
    return color ?? defaultColor;
  }
}

/// Widget state property class to replace deprecated MaterialStateProperty
class WidgetStateProperty<T> {
  final T Function(Set<WidgetState> states) _resolve;

  const WidgetStateProperty._(this._resolve);

  /// Resolves the value for the given states.
  T resolve(Set<WidgetState> states) => _resolve(states);

  /// Creates a [WidgetStateProperty] that resolves to the given value for all states.
  static WidgetStateProperty<T> all<T>(T value) {
    return WidgetStateProperty._((states) => value);
  }

  /// Creates a [WidgetStateProperty] that resolves to different values depending on the widget state.
  static WidgetStateProperty<T> resolveWith<T>(T Function(Set<WidgetState> states) callback) {
    return WidgetStateProperty._(callback);
  }
}

/// Widget state enum to replace deprecated MaterialState
enum WidgetState {
  hovered,
  focused,
  pressed,
  dragged,
  selected,
  scrolledUnder,
  disabled,
  error,
}
