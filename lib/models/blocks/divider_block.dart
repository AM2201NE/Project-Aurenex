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
      id: map['id'],
      parentId: map['parent_id'],
    );
  }
}
