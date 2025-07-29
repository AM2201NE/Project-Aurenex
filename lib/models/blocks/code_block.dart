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
      id: map['block_id'],
      text: map['content'] ?? '',
      language: map['metadata'] != null ? jsonDecode(map['metadata'])['language'] : 'plaintext',
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return CodeBlock(
      id: id,
      text: text,
      language: language,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['metadata'] = jsonEncode({'language': language});
    return map;
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return CodeBlock(
      id: id ?? this.id,
      text: (metadata?['text'] ?? this.text) as String,
      language: (metadata?['language'] ?? this.language) as String,
      parentId: parentId ?? this.parentId,
    );
  }
}
