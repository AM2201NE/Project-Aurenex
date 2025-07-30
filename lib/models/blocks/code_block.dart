import 'dart:convert';
import 'package:flutter/material.dart';
import 'base_block.dart';

class CodeBlock extends Block {
  final String text;
  final String language;

  CodeBlock({
    String? id,
    required this.text,
    required this.language,
    String? parentId,
  }) : super(
          id: id,
          type: 'code',
          content: {
            'code': text,
            'language': language,
          },
          parentId: parentId,
        );

  factory CodeBlock.fromMap(Map<String, dynamic> map) {
    return CodeBlock(
      id: map['id'],
      text: map['content']['code'] ?? '',
      language: map['content']['language'] ?? 'plaintext',
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
    return CodeBlock(
      id: id ?? this.id,
      text: content?['code'] ?? text,
      language: content?['language'] ?? language,
      parentId: parentId ?? this.parentId,
    );
  }
}
