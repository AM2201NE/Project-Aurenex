import 'dart:convert';
import 'package:flutter/material.dart';
import 'base_block.dart';

class ImageBlock extends Block {
  final String source;
  final bool isAsset;
  final String? caption;

  ImageBlock({
    String? id,
    required this.source,
    required this.isAsset,
    this.caption,
    String? parentId,
  }) : super(
          id: id,
          type: 'image',
          content: {
            'url': source,
            'isAsset': isAsset,
            'caption': caption,
          },
          parentId: parentId,
        );

  factory ImageBlock.fromMap(Map<String, dynamic> map) {
    return ImageBlock(
      id: map['id'],
      source: map['content']['url'] ?? '',
      isAsset: map['content']['isAsset'] ?? false,
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
    return ImageBlock(
      id: id ?? this.id,
      source: content?['url'] ?? source,
      isAsset: content?['isAsset'] ?? isAsset,
      caption: content?['caption'] ?? caption,
      parentId: parentId ?? this.parentId,
    );
  }
}
