import 'dart:convert';
import 'package:flutter/material.dart';
import 'base_block.dart';
import 'text_span_utils.dart';

class ToggleBlock extends Block {
  ToggleBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
  }) : super(
          id: id,
          type: 'toggle',
          content: {
            'text': richTextToHtml(richText),
          },
          parentId: parentId,
          children: children,
          childrenOrder: childrenOrder,
        );

  factory ToggleBlock.fromMap(Map<String, dynamic> map) {
    return ToggleBlock(
      id: map['id'],
      richText: htmlToRichText(map['content']['text'] ?? ''),
      parentId: map['parentId'],
      children: (map['children'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, Block.fromMap(value)),
      ),
      childrenOrder: (map['childrenOrder'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
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
    return ToggleBlock(
      id: id ?? this.id,
      richText: content?['text'] != null
          ? htmlToRichText(content!['text'])
          : htmlToRichText(this.content['text']),
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      childrenOrder: childrenOrder ?? this.childrenOrder,
    );
  }
}
