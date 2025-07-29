import 'package:flutter/material.dart';
import 'base_block.dart';

class HeadingBlock extends Block {
  final int level;

  HeadingBlock({
    String? id,
    required List<TextSpan> richText,
    required this.level,
    String? parentId,
  }) : super(
    id: id,
    type: 'heading_${level}',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    map['level'] = level;
    return map;
  }
  
  factory HeadingBlock.fromMap(Map<String, dynamic> map) {
    return HeadingBlock(
      id: map['id'],
      richText: (map['rich_text'] as List?)
          ?.map((text) => TextSpan(text: text.toString()))
          .toList() ?? [TextSpan(text: '')],
      level: map['level'] ?? 1,
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return HeadingBlock(
      level: level,
      richText: richText,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    map['level'] = level;
    return map;
  }
}
