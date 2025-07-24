import 'package:flutter/material.dart';
import 'base_block.dart';

class MathBlock extends Block {
  final String equation;
  final bool isInline;

  MathBlock({
    String? id,
    required this.equation,
    required this.isInline,
    String? parentId,
  }) : super(
    id: id,
    type: 'math',
    richText: [TextSpan(text: equation)],
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['equation'] = equation;
    map['is_inline'] = isInline;
    return map;
  }
  
  factory MathBlock.fromMap(Map<String, dynamic> map) {
    return MathBlock(
      id: map['id'],
      equation: map['equation'] ?? '',
      isInline: map['is_inline'] == true,
      parentId: map['parent_id'],
    );
  }
}
