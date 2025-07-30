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
      id: map['block_id'],
      richText: [TextSpan(text: map['content'] ?? '')],
      level: map['metadata'] != null ? jsonDecode(map['metadata'])['level'] : 1,
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return HeadingBlock(
      id: id,
      level: level,
      richText: richText,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['metadata'] = jsonEncode({'level': level});
    return map;
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return HeadingBlock(
      id: id ?? this.id,
      level: (metadata?['level'] ?? this.level) as int,
      richText: richText ?? this.richText,
      parentId: parentId ?? this.parentId,
    );
  }
}
