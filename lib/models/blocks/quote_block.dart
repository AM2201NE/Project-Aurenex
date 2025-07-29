import 'package:flutter/material.dart';
import 'base_block.dart';

class QuoteBlock extends Block {
  QuoteBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: 'quote',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    return map;
  }
  
  factory QuoteBlock.fromMap(Map<String, dynamic> map) {
    return QuoteBlock(
      id: map['id'],
      richText: (map['rich_text'] as List?)
          ?.map((text) => TextSpan(text: text.toString()))
          .toList() ?? [TextSpan(text: '')],
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return QuoteBlock(
      richText: richText,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    return map;
  }
}
