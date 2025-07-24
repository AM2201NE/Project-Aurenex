import 'package:flutter/material.dart';
import 'base_block.dart';
import 'rich_text_block.dart';
import 'text_span_utils.dart';

/// Bulleted list item block
class BulletedListItemBlock extends RichTextBlock {
  BulletedListItemBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: 'bulleted_list_item',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return BulletedListItemBlock(
      richText: richText.map((span) => span.copy()).toList(),
      parentId: parentId,
    );
  }
  
  /// Create a bulleted list item block from a JSON map
  factory BulletedListItemBlock.fromJson(Map<String, dynamic> json) {
    return BulletedListItemBlock(
      id: json['id'] as String,
      richText: (json['rich_text'] as List)
          .map((e) => TextSpanCopy.fromJson(e as Map<String, dynamic>))
          .toList(),
      parentId: json['parent_id'] as String,
    );
  }
}

/// Numbered list item block
class NumberedListItemBlock extends RichTextBlock {
  NumberedListItemBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: 'numbered_list_item',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return NumberedListItemBlock(
      richText: richText.map((span) => span.copy()).toList(),
      parentId: parentId,
    );
  }
  
  /// Create a numbered list item block from a JSON map
  factory NumberedListItemBlock.fromJson(Map<String, dynamic> json) {
    return NumberedListItemBlock(
      id: json['id'] as String,
      richText: (json['rich_text'] as List)
          .map((e) => TextSpanCopy.fromJson(e as Map<String, dynamic>))
          .toList(),
      parentId: json['parent_id'] as String,
    );
  }
}

/// Todo list item block with checkbox
class TodoBlock extends RichTextBlock {
  bool checked;
  
  TodoBlock({
    String? id,
    required List<TextSpan> richText,
    required this.checked,
    String? parentId,
  }) : super(
    id: id,
    type: 'to_do',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return TodoBlock(
      richText: richText.map((span) => span.copy()).toList(),
      checked: checked,
      parentId: parentId,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['checked'] = checked;
    return json;
  }
  
  /// Create a todo block from a JSON map
  factory TodoBlock.fromJson(Map<String, dynamic> json) {
    return TodoBlock(
      id: json['id'] as String,
      richText: (json['rich_text'] as List)
          .map((e) => TextSpanCopy.fromJson(e as Map<String, dynamic>))
          .toList(),
      checked: json['checked'] as bool,
      parentId: json['parent_id'] as String,
    );
  }
}
