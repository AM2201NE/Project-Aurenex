import 'package:flutter/material.dart';
import 'base_block.dart';
import 'text_span_utils.dart';

class ParagraphBlock extends Block {
  ParagraphBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
          id: id,
          type: 'paragraph',
          content: {
            'text': richTextToHtml(richText),
          },
          parentId: parentId,
        );

  factory ParagraphBlock.fromMap(Map<String, dynamic> map) {
    return ParagraphBlock(
      id: map['id'],
      richText: htmlToRichText(map['content']['text'] ?? ''),
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
    return ParagraphBlock(
      id: id ?? this.id,
      richText: content?['text'] != null
          ? htmlToRichText(content!['text'])
          : htmlToRichText(this.content['text']),
      parentId: parentId ?? this.parentId,
    );
  }
}
