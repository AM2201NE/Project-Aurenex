import 'dart:convert';
import 'package:flutter/material.dart';
import 'base_block.dart';
import 'text_span_utils.dart';

class TodoBlock extends Block {
  final bool checked;

  TodoBlock({
    String? id,
    required List<TextSpan> richText,
    required this.checked,
    String? parentId,
  }) : super(
          id: id,
          type: 'to_do',
          content: {
            'text': richTextToHtml(richText),
            'checked': checked,
          },
          parentId: parentId,
        );

  factory TodoBlock.fromMap(Map<String, dynamic> map) {
    return TodoBlock(
      id: map['id'],
      richText: htmlToRichText(map['content']['text'] ?? ''),
      checked: map['content']['checked'] ?? false,
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
    return TodoBlock(
      id: id ?? this.id,
      richText: content?['text'] != null
          ? htmlToRichText(content!['text'])
          : htmlToRichText(this.content['text']),
      checked: content?['checked'] ?? checked,
      parentId: parentId ?? this.parentId,
    );
  }
}
