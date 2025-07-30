import 'package:flutter/material.dart';
import 'base_block.dart';
import 'text_span_utils.dart';

class NumberedListItemBlock extends Block {
  NumberedListItemBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
          id: id,
          type: 'numbered_list_item',
          content: {
            'text': richTextToHtml(richText),
          },
          parentId: parentId,
        );

  factory NumberedListItemBlock.fromMap(Map<String, dynamic> map) {
    return NumberedListItemBlock(
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
    return NumberedListItemBlock(
      id: id ?? this.id,
      richText: content?['text'] != null
          ? htmlToRichText(content!['text'])
          : htmlToRichText(this.content['text']),
      parentId: parentId ?? this.parentId,
    );
  }
}
