import 'package:flutter/material.dart';
import 'base_block.dart';

class ToggleBlock extends Block {
  ToggleBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
    Map<String, dynamic>? children,
    List<String>? childrenOrder,
  }) : super(
    id: id,
    type: 'toggle',
    richText: richText,
    parentId: parentId,
    children: children ?? {},
    childrenOrder: childrenOrder ?? [],
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    map['children'] = children;
    map['children_order'] = childrenOrder;
    return map;
  }
  
  factory ToggleBlock.fromMap(Map<String, dynamic> map) {
    return ToggleBlock(
      id: map['id'],
      richText: (map['rich_text'] as List?)
          ?.map((text) => TextSpan(text: text.toString()))
          .toList() ?? [TextSpan(text: '')],
      parentId: map['parent_id'],
      children: map['children'] as Map<String, dynamic>? ?? {},
      childrenOrder: (map['children_order'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
