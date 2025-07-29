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
    richText: caption != null ? [TextSpan(text: caption)] : [],
    parentId: parentId,
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['source'] = source;
    map['is_asset'] = isAsset;
    map['caption'] = caption;
    return map;
  }
  
  factory ImageBlock.fromMap(Map<String, dynamic> map) {
    return ImageBlock(
      id: map['id'],
      source: map['source'] ?? '',
      isAsset: map['is_asset'] == true,
      caption: map['caption'],
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return ImageBlock(
      source: source,
      isAsset: isAsset,
      caption: caption,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['source'] = source;
    map['is_asset'] = isAsset;
    map['caption'] = caption;
    return map;
  }
}
