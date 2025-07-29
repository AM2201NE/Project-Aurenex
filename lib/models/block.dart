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
      'content': plainText,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
      'parent_id': parentId,
    };
  }
  
  /// Create from map (database record)
  factory Block.fromMap(Map<String, dynamic> map) {
    return Block(
      id: map['block_id'] ?? '',
      type: map['type'] ?? 'paragraph',
      richText: [TextSpan(text: map['content'] ?? '')],
      parentId: map['parent_id'],
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    );
  }
}
