import 'package:flutter/material.dart';
import 'base_block.dart';

class MermaidBlock extends Block {
  final String code;
  final String? caption;

  MermaidBlock({
    String? id,
    required this.code,
    this.caption,
    String? parentId,
  }) : super(
    id: id,
    type: 'mermaid',
    richText: caption != null ? [TextSpan(text: caption)] : [],
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['code'] = code;
    map['caption'] = caption;
    return map;
  }
  
  factory MermaidBlock.fromMap(Map<String, dynamic> map) {
    return MermaidBlock(
      id: map['block_id'],
      code: map['content'] ?? '',
      caption: map['metadata'] != null ? jsonDecode(map['metadata'])['caption'] : null,
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return MermaidBlock(
      id: id,
      code: code,
      caption: caption,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['metadata'] = jsonEncode({'caption': caption});
    return map;
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return MermaidBlock(
      id: id ?? this.id,
      code: (metadata?['code'] ?? this.code) as String,
      caption: (metadata?['caption'] ?? this.caption) as String?,
      parentId: parentId ?? this.parentId,
    );
  }
}
