import 'package:flutter/material.dart';
import 'base_block.dart';

class DividerBlock extends Block {
  DividerBlock({
    String? id,
    String? parentId,
  }) : super(
          id: id,
          type: 'divider',
          content: {},
          parentId: parentId,
        );

  factory DividerBlock.fromMap(Map<String, dynamic> map) {
    return DividerBlock(
      id: map['id'],
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
    return DividerBlock(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
    );
  }
}
