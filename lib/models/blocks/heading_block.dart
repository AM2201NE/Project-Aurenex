import 'dart:convert';
import 'package:flutter/material.dart';
import 'base_block.dart';
import 'text_span_utils.dart';

class HeadingBlock extends Block {
  final int level;

  HeadingBlock({
    String? id,
    required List<TextSpan> richText,
    required this.level,
    String? parentId,
  }) : super(
          id: id,
          type: 'heading_$level',
          content: {
            'text': richTextToHtml(richText),
            'level': level,
          },
          parentId: parentId,
        );

  factory HeadingBlock.fromMap(Map<String, dynamic> map) {
    return HeadingBlock(
      id: map['id'],
      richText: htmlToRichText(map['content']['text'] ?? ''),
      level: map['content']['level'] ?? 1,
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
    return HeadingBlock(
      id: id ?? this.id,
      richText: content?['text'] != null
          ? htmlToRichText(content!['text'])
          : htmlToRichText(this.content['text']),
      level: content?['level'] ?? level,
      parentId: parentId ?? this.parentId,
    );
  }
}
