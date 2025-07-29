import 'package:flutter/material.dart';
import 'dart:convert';

/// Block model representing a content block in a page
abstract class Block {
  final String id;
  final String type;
  final List<TextSpan> richText;
  final String? parentId;
  final Map<String, dynamic>? metadata;
  
  Block({
    required this.id,
    required this.type,
    required this.richText,
    this.parentId,
    this.metadata,
  });
  
  /// Get plain text from rich text
  String get plainText {
    final buffer = StringBuffer();
    for (final span in richText) {
      buffer.write(span.text);
    }
    return buffer.toString();
  }
  
  /// Create a copy with updated properties
  Block copyWith({
    String? id,
    String? type,
    List<TextSpan>? richText,
    String? parentId,
    Map<String, dynamic>? metadata,
  });
  
  /// Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'block_id': id,
      'type': type,
      'content': plainText,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
      'parent_id': parentId,
    };
  }
  
  /// Create from map (database record)
  factory Block.fromMap(Map<String, dynamic> map) {
    // This will be handled by the subclasses
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson();
  Block copy();
}
