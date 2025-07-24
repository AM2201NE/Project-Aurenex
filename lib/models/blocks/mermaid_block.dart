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
      id: map['id'],
      code: map['code'] ?? '',
      caption: map['caption'],
      parentId: map['parent_id'],
    );
  }
}
