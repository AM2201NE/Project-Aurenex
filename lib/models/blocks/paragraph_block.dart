import 'package:flutter/material.dart';
import 'base_block.dart';

class ParagraphBlock extends Block {
  ParagraphBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: 'paragraph',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    return map;
  }
  
  factory ParagraphBlock.fromMap(Map<String, dynamic> map) {
    return ParagraphBlock(
      id: map['block_id'],
      richText: [TextSpan(text: map['content'] ?? '')],
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return ParagraphBlock(
      id: id,
      richText: richText,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toMap();
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return ParagraphBlock(
      id: id ?? this.id,
      richText: richText ?? this.richText,
      parentId: parentId ?? this.parentId,
    );
  }
}
