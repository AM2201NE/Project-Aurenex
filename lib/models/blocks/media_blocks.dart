import 'package:flutter/material.dart';
import 'base_block.dart';

/// Image block for displaying images
class ImageBlock extends Block {
  String source;
  bool isAsset;
  String? caption;
  
  ImageBlock({
    String? id,
    required String source,
    required bool isAsset,
    String? caption,
    required String parentId,
  }) : source = source,
       isAsset = isAsset,
       caption = caption,
       super(
         id: id,
         type: 'image',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return ImageBlock(
      source: source,
      isAsset: isAsset,
      caption: caption,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'source': source,
      'is_asset': isAsset,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create an image block from a JSON map
  factory ImageBlock.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final source = json['source'] ?? '';
    final isAsset = json['is_asset'] ?? false;
    if (json['id'] == null) debugPrint('ImageBlock.fromJson: id is null, using empty string');
    if (json['source'] == null) debugPrint('ImageBlock.fromJson: source is null, using empty string');
    if (json['is_asset'] == null) debugPrint('ImageBlock.fromJson: is_asset is null, using false');
    return ImageBlock(
      id: id is String ? id : id.toString(),
      source: source is String ? source : source.toString(),
      isAsset: isAsset is bool ? isAsset : false,
      caption: json['caption'] as String?,
      parentId: (json['parent_id'] as String?) ?? '',
    );
  }
}

/// Video block for displaying videos
class VideoBlock extends Block {
  String source;
  bool isAsset;
  String? caption;
  
  VideoBlock({
    String? id,
    required String source,
    required bool isAsset,
    String? caption,
    required String parentId,
  }) : source = source,
       isAsset = isAsset,
       caption = caption,
       super(
         id: id,
         type: 'video',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return VideoBlock(
      source: source,
      isAsset: isAsset,
      caption: caption,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'source': source,
      'is_asset': isAsset,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a video block from a JSON map
  factory VideoBlock.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final source = json['source'] ?? '';
    final isAsset = json['is_asset'] ?? false;
    if (json['id'] == null) debugPrint('VideoBlock.fromJson: id is null, using empty string');
    if (json['source'] == null) debugPrint('VideoBlock.fromJson: source is null, using empty string');
    if (json['is_asset'] == null) debugPrint('VideoBlock.fromJson: is_asset is null, using false');
    return VideoBlock(
      id: id is String ? id : id.toString(),
      source: source is String ? source : source.toString(),
      isAsset: isAsset is bool ? isAsset : false,
      caption: json['caption'] as String?,
      parentId: (json['parent_id'] as String?) ?? '',
    );
  }
}

/// Audio block for playing audio
class AudioBlock extends Block {
  String source;
  bool isAsset;
  String? caption;
  
  AudioBlock({
    String? id,
    required String source,
    required bool isAsset,
    String? caption,
    required String parentId,
  }) : source = source,
       isAsset = isAsset,
       caption = caption,
       super(
         id: id,
         type: 'audio',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return AudioBlock(
      source: source,
      isAsset: isAsset,
      caption: caption,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'source': source,
      'is_asset': isAsset,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create an audio block from a JSON map
  factory AudioBlock.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final source = json['source'] ?? '';
    final isAsset = json['is_asset'] ?? false;
    if (json['id'] == null) debugPrint('AudioBlock.fromJson: id is null, using empty string');
    if (json['source'] == null) debugPrint('AudioBlock.fromJson: source is null, using empty string');
    if (json['is_asset'] == null) debugPrint('AudioBlock.fromJson: is_asset is null, using false');
    return AudioBlock(
      id: id is String ? id : id.toString(),
      source: source is String ? source : source.toString(),
      isAsset: isAsset is bool ? isAsset : false,
      caption: json['caption'] as String?,
      parentId: (json['parent_id'] as String?) ?? '',
    );
  }
}

/// File block for file attachments
class FileBlock extends Block {
  String source;
  bool isAsset;
  String filename;
  String? fileType;
  int? fileSize;
  
  FileBlock({
    String? id,
    required String source,
    required bool isAsset,
    required String filename,
    String? fileType,
    int? fileSize,
    required String parentId,
  }) : source = source,
       isAsset = isAsset,
       filename = filename,
       fileType = fileType,
       fileSize = fileSize,
       super(
         id: id,
         type: 'file',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return FileBlock(
      source: source,
      isAsset: isAsset,
      filename: filename,
      fileType: fileType,
      fileSize: fileSize,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'source': source,
      'is_asset': isAsset,
      'filename': filename,
      'file_type': fileType,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a file block from a JSON map
  factory FileBlock.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final source = json['source'] ?? '';
    final isAsset = json['is_asset'] ?? false;
    final filename = json['filename'] ?? '';
    if (json['id'] == null) debugPrint('FileBlock.fromJson: id is null, using empty string');
    if (json['source'] == null) debugPrint('FileBlock.fromJson: source is null, using empty string');
    if (json['is_asset'] == null) debugPrint('FileBlock.fromJson: is_asset is null, using false');
    if (json['filename'] == null) debugPrint('FileBlock.fromJson: filename is null, using empty string');
    return FileBlock(
      id: id is String ? id : id.toString(),
      source: source is String ? source : source.toString(),
      isAsset: isAsset is bool ? isAsset : false,
      filename: filename is String ? filename : filename.toString(),
      fileType: (json['file_type'] ?? '').toString(),
      fileSize: json['file_size'] as int?,
      parentId: (json['parent_id'] ?? '').toString(),
    );
  }
}

/// Bookmark block for external links
class BookmarkBlock extends Block {
  String url;
  String? title;
  String? description;
  String? thumbnailUrl;
  
  BookmarkBlock({
    String? id,
    required String url,
    String? title,
    String? description,
    String? thumbnailUrl,
    required String parentId,
  }) : url = url,
       title = title,
       description = description,
       thumbnailUrl = thumbnailUrl,
       super(
         id: id,
         type: 'bookmark',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return BookmarkBlock(
      url: url,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'url': url,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a bookmark block from a JSON map
  factory BookmarkBlock.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final url = json['url'] ?? '';
    if (json['id'] == null) debugPrint('BookmarkBlock.fromJson: id is null, using empty string');
    if (json['url'] == null) debugPrint('BookmarkBlock.fromJson: url is null, using empty string');
    return BookmarkBlock(
      id: id is String ? id : id.toString(),
      url: url is String ? url : url.toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      thumbnailUrl: (json['thumbnail_url'] ?? '').toString(),
      parentId: (json['parent_id'] ?? '').toString(),
    );
  }
}
