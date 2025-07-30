import 'package:flutter/material.dart';
import 'base_block.dart';
import 'text_span_utils.dart';

class QuoteBlock extends Block {
  QuoteBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
          id: id,
          type: 'quote',
          content: {
            'text': richTextToHtml(richText),
          },
          parentId: parentId,
        );

  factory QuoteBlock.fromMap(Map<String, dynamic> map) {
    return QuoteBlock(
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
    return QuoteBlock(
      id: id ?? this.id,
      richText: content?['text'] != null
          ? htmlToRichText(content!['text'])
          : htmlToRichText(this.content['text']),
      parentId: parentId ?? this.parentId,
    );
  }
}
