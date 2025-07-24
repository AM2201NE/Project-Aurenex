import 'package:flutter/material.dart';

/// Block model representing a content block in a page
class Block {
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
  }) {
    return Block(
      id: id ?? this.id,
      type: type ?? this.type,
      richText: richText ?? this.richText,
      parentId: parentId ?? this.parentId,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'block_id': id,
      'type': type,
      'content': _encodeRichText(richText),
      'metadata': _encodeMetadata(metadata),
      'parent_id': parentId,
    };
  }
  
  /// Create from map (database record)
  factory Block.fromMap(Map<String, dynamic> map) {
    return Block(
      id: map['block_id'] ?? '',
      type: map['type'] ?? 'paragraph',
      richText: _decodeRichText(map['content']),
      parentId: map['parent_id'],
      metadata: _decodeMetadata(map['metadata']),
    );
  }
  
  /// Encode rich text to string
  static String _encodeRichText(List<TextSpan> richText) {
    // Simple encoding for now, just extract text
    final buffer = StringBuffer();
    for (final span in richText) {
      buffer.write(span.text);
    }
    return buffer.toString();
  }
  
  /// Decode rich text from string
  static List<TextSpan> _decodeRichText(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return [];
    }
    
    // Simple decoding for now, just create a single span
    return [TextSpan(text: encoded)];
  }
  
  /// Encode metadata to string
  static String _encodeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) {
      return '{}';
    }
    
    // Simple JSON-like encoding
    final buffer = StringBuffer('{');
    var first = true;
    
    for (final entry in metadata.entries) {
      if (!first) {
        buffer.write(',');
      }
      first = false;
      
      buffer.write('"${entry.key}":');
      
      if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else if (entry.value is bool || entry.value is num) {
        buffer.write('${entry.value}');
      } else if (entry.value is List) {
        buffer.write('[');
        var firstItem = true;
        for (final item in entry.value as List) {
          if (!firstItem) {
            buffer.write(',');
          }
          firstItem = false;
          
          if (item is String) {
            buffer.write('"$item"');
          } else {
            buffer.write('$item');
          }
        }
        buffer.write(']');
      } else {
        buffer.write('null');
      }
    }
    
    buffer.write('}');
    return buffer.toString();
  }
  
  /// Decode metadata from string
  static Map<String, dynamic>? _decodeMetadata(String? encoded) {
    if (encoded == null || encoded.isEmpty || encoded == '{}') {
      return null;
    }
    
    // For now, return an empty map
    // In a real implementation, this would parse the JSON-like string
    return {};
  }
}
