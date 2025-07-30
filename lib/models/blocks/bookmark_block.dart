import 'dart:convert';
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
          content: {
            'url': url,
            'title': title,
          },
          parentId: parentId,
        );

  factory BookmarkBlock.fromMap(Map<String, dynamic> map) {
    return BookmarkBlock(
      id: map['id'],
      url: map['content']['url'] ?? '',
      title: map['content']['title'],
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
    return BookmarkBlock(
      id: id ?? this.id,
      url: content?['url'] ?? url,
      title: content?['title'] ?? title,
      parentId: parentId ?? this.parentId,
    );
  }
}
