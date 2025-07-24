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
      id: map['id'],
      url: map['url'] ?? '',
      title: map['title'],
      parentId: map['parent_id'],
    );
  }
}
