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
      id: map['block_id'],
      equation: map['content'] ?? '',
      isInline: map['metadata'] != null ? jsonDecode(map['metadata'])['isInline'] : false,
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return MathBlock(
      id: id,
      equation: equation,
      isInline: isInline,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['metadata'] = jsonEncode({'isInline': isInline});
    return map;
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return MathBlock(
      id: id ?? this.id,
      equation: (metadata?['equation'] ?? this.equation) as String,
      isInline: (metadata?['isInline'] ?? this.isInline) as bool,
      parentId: parentId ?? this.parentId,
    );
  }
}
