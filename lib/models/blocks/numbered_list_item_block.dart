import 'package:flutter/material.dart';
import 'base_block.dart';

class NumberedListItemBlock extends Block {
  NumberedListItemBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: 'numbered_list_item',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    return map;
  }
  
  factory NumberedListItemBlock.fromMap(Map<String, dynamic> map) {
    return NumberedListItemBlock(
      id: map['id'],
      richText: (map['rich_text'] as List?)
          ?.map((text) => TextSpan(text: text.toString()))
          .toList() ?? [TextSpan(text: '')],
      parentId: map['parent_id'],
    );
  }
}
