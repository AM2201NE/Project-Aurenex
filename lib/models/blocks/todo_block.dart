import 'package:flutter/material.dart';
import 'base_block.dart';

class TodoBlock extends Block {
  final bool checked;

  TodoBlock({
    String? id,
    required List<TextSpan> richText,
    required this.checked,
    String? parentId,
  }) : super(
    id: id,
    type: 'to_do',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    map['checked'] = checked;
    return map;
  }
  
  factory TodoBlock.fromMap(Map<String, dynamic> map) {
    return TodoBlock(
      id: map['id'],
      richText: (map['rich_text'] as List?)
          ?.map((text) => TextSpan(text: text.toString()))
          .toList() ?? [TextSpan(text: '')],
      checked: map['checked'] == true,
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return TodoBlock(
      richText: richText,
      checked: checked,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['rich_text'] = richText.map((span) => span.text).toList();
    map['checked'] = checked;
    return map;
  }
}
