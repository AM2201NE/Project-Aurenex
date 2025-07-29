import 'package:flutter/material.dart';
import 'base_block.dart';

class BookmarkBlock extends Block {
  final String url;
  final String? title;

  BookmarkBlock({
    String? id,
    required this.url,
    this.title,
    String? parentId,
  }) : super(
    id: id,
    type: 'bookmark',
    richText: title != null ? [TextSpan(text: title)] : [],
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['url'] = url;
    map['title'] = title;
    return map;
  }
  
  factory BookmarkBlock.fromMap(Map<String, dynamic> map) {
    return BookmarkBlock(
      id: map['block_id'],
      url: map['content'] ?? '',
      title: map['metadata'] != null ? jsonDecode(map['metadata'])['title'] : null,
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return BookmarkBlock(
      id: id,
      url: url,
      title: title,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['metadata'] = jsonEncode({'title': title});
    return map;
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return BookmarkBlock(
      id: id ?? this.id,
      url: (metadata?['url'] ?? this.url) as String,
      title: (metadata?['title'] ?? this.title) as String?,
      parentId: parentId ?? this.parentId,
    );
  }
}
