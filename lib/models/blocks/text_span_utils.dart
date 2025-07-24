import 'package:flutter/material.dart';

extension TextSpanCopy on TextSpan {
  TextSpan copy() {
    return TextSpan(
      text: text,
      style: style,
      children: children?.whereType<TextSpan>().map((c) => c.copy()).toList(),
      recognizer: recognizer,
      semanticsLabel: semanticsLabel,
    );
  }

  static TextSpan fromJson(Map<String, dynamic> json) {
    return TextSpan(
      text: json['text'] as String?,
      style: json['style'] != null ? TextStyle() : null, // Simplified
      children: (json['children'] as List?)?.map((e) => TextSpanCopy.fromJson(e as Map<String, dynamic>)).toList(),
      semanticsLabel: json['semanticsLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'style': null, // Not serializing style for now
      'children': children?.whereType<TextSpan>().map((c) => c.toJson()).toList(),
      'semanticsLabel': semanticsLabel,
    };
  }
}
