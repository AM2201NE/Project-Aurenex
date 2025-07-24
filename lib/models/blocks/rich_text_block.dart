import 'package:flutter/material.dart';
import 'base_block.dart';
import 'text_span_utils.dart';

/// Block with rich text content (used for paragraphs, headings, quotes, etc.)
class RichTextBlock extends Block {
  RichTextBlock({
    String? id,
    required String type,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: type,
    richText: richText,
    parentId: parentId,
  );

  @override
  Map<String, dynamic> toJson() {
    return {
      'block_id': id,
      'type': type,
      'parent_id': parentId,
      'rich_text': richText.whereType<TextSpan>().map((span) => span.toJson()).toList(),
    };
  }

  @override
  Block copy() {
    return RichTextBlock(
      id: id,
      type: type,
      richText: richText.whereType<TextSpan>().map((span) => span.copy()).toList(),
      parentId: parentId,
    );
  }
}
