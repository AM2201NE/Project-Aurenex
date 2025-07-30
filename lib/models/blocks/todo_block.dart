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
      id: map['block_id'],
      richText: [TextSpan(text: map['content'] ?? '')],
      checked: map['metadata'] != null ? jsonDecode(map['metadata'])['checked'] : false,
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return TodoBlock(
      id: id,
      richText: richText,
      checked: checked,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['metadata'] = jsonEncode({'checked': checked});
    return map;
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return TodoBlock(
      id: id ?? this.id,
      richText: richText ?? this.richText,
      checked: (metadata?['checked'] ?? this.checked) as bool,
      parentId: parentId ?? this.parentId,
    );
  }
}
