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
    richText: [TextSpan(text: text)],
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['text'] = text;
    map['language'] = language;
    return map;
  }
  
  factory CodeBlock.fromMap(Map<String, dynamic> map) {
    return CodeBlock(
      id: map['id'],
      text: map['text'] ?? '',
      language: map['language'] ?? 'plaintext',
      parentId: map['parent_id'],
    );
  }
}
