import 'package:flutter/material.dart';
import 'base_block.dart';

class DividerBlock extends Block {
  DividerBlock({
    String? id,
    String? parentId,
  }) : super(
    id: id,
    type: 'divider',
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    return map;
  }
  
  factory DividerBlock.fromMap(Map<String, dynamic> map) {
    return DividerBlock(
      id: map['block_id'],
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return DividerBlock(
      id: id,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toMap();
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return DividerBlock(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
    );
  }
}
