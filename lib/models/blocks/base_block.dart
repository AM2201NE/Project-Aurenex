import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Base class for all block types
abstract class Block {
  final String id;
  final String type;
  final String? parentId;
  final List<TextSpan> richText;
  final Map<String, dynamic> children;
  final List<String> childrenOrder;
  final DateTime createdAt;
  DateTime updatedAt;

  Block({
    String? id,
    required this.type,
    this.parentId,
    List<TextSpan>? richText,
    Map<String, dynamic>? children,
    List<String>? childrenOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        richText = richText ?? [],
        children = children ?? {},
        childrenOrder = childrenOrder ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String? get content => richText.isNotEmpty ? richText.first.text : null;
  String get plainText => richText.map((span) => span.text ?? '').join('');

  Map<String, dynamic> toMap() {
    return {
      'block_id': id,
      'type': type,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // Additional fields would be handled by subclasses
    };
  }

  Map<String, dynamic> toJson();
  Block copy();
}
