import 'dart:convert';
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
          content: {
            'code': code,
            'caption': caption,
          },
          parentId: parentId,
        );

  factory MermaidBlock.fromMap(Map<String, dynamic> map) {
    return MermaidBlock(
      id: map['id'],
      code: map['content']['code'] ?? '',
      caption: map['content']['caption'],
      parentId: map['parentId'],
    );
  }

  @override
  Block copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? content,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
  }) {
    return MermaidBlock(
      id: id ?? this.id,
      code: content?['code'] ?? code,
      caption: content?['caption'] ?? caption,
      parentId: parentId ?? this.parentId,
    );
  }
}
