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
      id: map['block_id'],
      richText: [TextSpan(text: map['content'] ?? '')],
      parentId: map['parent_id'],
      children: map['metadata'] != null ? (jsonDecode(map['metadata'])['children'] as Map<String, dynamic>).map((key, value) => MapEntry(key, Block.fromMap(value as Map<String, dynamic>))) : {},
      childrenOrder: map['metadata'] != null ? (jsonDecode(map['metadata'])['childrenOrder'] as List<dynamic>).map((e) => e.toString()).toList() : [],
    );
  }

  @override
  Block copy() {
    return ToggleBlock(
      id: id,
      richText: richText,
      parentId: parentId,
      children: children,
      childrenOrder: childrenOrder,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['metadata'] = jsonEncode({
      'children': children.map((key, value) => MapEntry(key, value.toJson())),
      'childrenOrder': childrenOrder,
    });
    return map;
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return ToggleBlock(
      id: id ?? this.id,
      richText: richText ?? this.richText,
      parentId: parentId ?? this.parentId,
      children: (metadata?['children'] as Map<String, Block>?) ?? this.children,
      childrenOrder: (metadata?['childrenOrder'] as List<String>?) ?? this.childrenOrder,
    );
  }
}
