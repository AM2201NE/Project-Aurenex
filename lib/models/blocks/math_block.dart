import 'dart:convert';
import 'package:flutter/material.dart';
import 'base_block.dart';

class MathBlock extends Block {
  final String equation;
  final bool isInline;

  MathBlock({
    String? id,
    required this.equation,
    required this.isInline,
    String? parentId,
  }) : super(
          id: id,
          type: 'math',
          content: {
            'equation': equation,
            'isInline': isInline,
          },
          parentId: parentId,
        );

  factory MathBlock.fromMap(Map<String, dynamic> map) {
    return MathBlock(
      id: map['id'],
      equation: map['content']['equation'] ?? '',
      isInline: map['content']['isInline'] ?? false,
      parentId: map['parentId'],
    );
  }

  @override
  Block copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? content,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
  }) {
    return MathBlock(
      id: id ?? this.id,
      equation: content?['equation'] ?? equation,
      isInline: content?['isInline'] ?? isInline,
      parentId: parentId ?? this.parentId,
    );
  }
}
