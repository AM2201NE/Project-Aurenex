import 'package:flutter/material.dart';
import 'base_block.dart';

class BulletedListItemBlock extends Block {
  BulletedListItemBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: 'bulleted_list_item',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    return map;
  }
  
  factory BulletedListItemBlock.fromMap(Map<String, dynamic> map) {
    return BulletedListItemBlock(
      id: map['id'],
      richText: (map['rich_text'] as List?)
          ?.map((text) => TextSpan(text: text.toString()))
          .toList() ?? [TextSpan(text: '')],
      parentId: map['parent_id'],
    );
  }
}
