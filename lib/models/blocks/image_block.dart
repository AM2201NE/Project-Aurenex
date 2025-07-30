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
      id: map['block_id'],
      source: map['content'] ?? '',
      isAsset: map['metadata'] != null ? jsonDecode(map['metadata'])['isAsset'] : false,
      caption: map['metadata'] != null ? jsonDecode(map['metadata'])['caption'] : null,
      parentId: map['parent_id'],
    );
  }

  @override
  Block copy() {
    return ImageBlock(
      id: id,
      source: source,
      isAsset: isAsset,
      caption: caption,
      parentId: parentId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toMap();
    map['metadata'] = jsonEncode({'isAsset': isAsset, 'caption': caption});
    return map;
  }

  @override
  Block copyWith({String? id, String? type, List<TextSpan>? richText, String? parentId, Map<String, dynamic>? metadata}) {
    return ImageBlock(
      id: id ?? this.id,
      source: (metadata?['source'] ?? this.source) as String,
      isAsset: (metadata?['isAsset'] ?? this.isAsset) as bool,
      caption: (metadata?['caption'] ?? this.caption) as String?,
      parentId: parentId ?? this.parentId,
    );
  }
}
