import 'package:flutter/material.dart';
import 'base_block.dart';
import 'parent_block.dart';
import 'rich_text_block.dart';
import 'text_span_utils.dart';

/// Paragraph block for plain text content
class ParagraphBlock extends RichTextBlock {
  ParagraphBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: 'paragraph',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return ParagraphBlock(
      richText: richText.map((span) => span.copy()).toList(),
      parentId: parentId,
    );
  }
  
  /// Create a paragraph block from a JSON map
  factory ParagraphBlock.fromJson(Map<String, dynamic> json) {
    return ParagraphBlock(
      id: json['id'] as String,
      richText: (json['rich_text'] as List)
          .map((e) => TextSpanCopy.fromJson(e as Map<String, dynamic>))
          .toList(),
      parentId: json['parent_id'] as String?,
    );
  }
}

/// Heading block for section titles with different levels
class HeadingBlock extends RichTextBlock {
  final int level;
  
  HeadingBlock({
    String? id,
    required this.level,
    required List<TextSpan> richText,
    String? parentId,
  }) : assert(level >= 1 && level <= 3),
       super(
        id: id,
        type: 'heading_$level',
        richText: richText,
        parentId: parentId,
      );
  
  @override
  Block copy() {
    return HeadingBlock(
      level: level,
      richText: richText.map((span) => span.copy()).toList(),
      parentId: parentId,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['level'] = level;
    json['created_at'] = createdAt.toIso8601String();
    json['updated_at'] = updatedAt.toIso8601String();
    return json;
  }
  
  /// Create a heading block from a JSON map
  factory HeadingBlock.fromJson(Map<String, dynamic> json) {
    return HeadingBlock(
      id: json['id'] as String,
      level: json['level'] as int,
      richText: (json['rich_text'] as List)
          .map((e) => TextSpanCopy.fromJson(e as Map<String, dynamic>))
          .toList(),
      parentId: json['parent_id'] as String?,
    );
  }
}

/// Quote block for quotations or callouts
class QuoteBlock extends RichTextBlock {
  QuoteBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
  }) : super(
    id: id,
    type: 'quote',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return QuoteBlock(
      richText: richText.map((span) => span.copy()).toList(),
      parentId: parentId,
    );
  }
  
  /// Create a quote block from a JSON map
  factory QuoteBlock.fromJson(Map<String, dynamic> json) {
    return QuoteBlock(
      id: json['id'] as String,
      richText: (json['rich_text'] as List)
          .map((e) => TextSpanCopy.fromJson(e as Map<String, dynamic>))
          .toList(),
      parentId: json['parent_id'] as String?,
    );
  }
}

/// Toggle block that can be expanded/collapsed
class ToggleBlock extends RichTextBlock implements ParentBlock {
  @override
  Map<String, Block> children;
  
  @override
  List<String> childrenOrder;
  
  ToggleBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
  }) : 
    children = children ?? {},
    childrenOrder = childrenOrder ?? [],
    super(
      id: id,
      type: 'toggle',
      richText: richText,
      parentId: parentId,
    );
  
  @override
  Block copy() {
    return ToggleBlock(
      richText: richText.map((span) => span.copy()).toList(),
      parentId: parentId,
      children: children.map((key, value) => MapEntry(key, value.copy())),
      childrenOrder: List.from(childrenOrder),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['children'] = children.map((key, value) => MapEntry(key, value.toJson()));
    json['children_order'] = childrenOrder;
    json['created_at'] = createdAt.toIso8601String();
    json['updated_at'] = updatedAt.toIso8601String();
    return json;
  }
  
  /// Create a toggle block from a JSON map
  factory ToggleBlock.fromJson(Map<String, dynamic> json) {
    final block = ToggleBlock(
      id: json['id'] as String,
      richText: (json['rich_text'] as List)
          .map((e) => TextSpanCopy.fromJson(e as Map<String, dynamic>))
          .toList(),
      parentId: json['parent_id'] as String?,
      childrenOrder: (json['children_order'] as List).map((e) => e as String).toList(),
    );
    
    // Add children
    final childrenJson = json['children'] as Map<String, dynamic>;
    childrenJson.forEach((key, value) {
      // This would need a block factory to properly deserialize
      // For now, we'll leave it empty
    });
    
    return block;
  }
  
  @override
  void addChild(Block block) {
    children[block.id] = block;
    if (!childrenOrder.contains(block.id)) {
      childrenOrder.add(block.id);
    }
    touch();
  }
  
  @override
  void removeChild(String blockId) {
    children.remove(blockId);
    childrenOrder.remove(blockId);
    touch();
  }
  
  @override
  void moveChild(String blockId, {required int toIndex}) {
    if (!children.containsKey(blockId) || !childrenOrder.contains(blockId)) {
      return;
    }
    
    childrenOrder.remove(blockId);
    childrenOrder.insert(toIndex.clamp(0, childrenOrder.length), blockId);
    touch();
  }
  
  @override
  void touch() {}
}

/// Code block for code snippets
class CodeBlock extends Block {
  String text;
  String language;
  
  CodeBlock({
    String? id,
    required this.text,
    required this.language,
    String? parentId,
  }) : super(
    id: id,
    type: 'code',
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return CodeBlock(
      text: text,
      language: language,
      parentId: parentId,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'text': text,
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a code block from a JSON map
  factory CodeBlock.fromJson(Map<String, dynamic> json) {
    return CodeBlock(
      id: json['id'] as String,
      text: json['text'] as String,
      language: json['language'] as String,
      parentId: json['parent_id'] as String?,
    );
  }
}

/// Divider block for visual separation
class DividerBlock extends Block {
  DividerBlock({
    String? id,
    String? parentId,
  }) : super(
    id: id,
    type: 'divider',
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return DividerBlock(
      parentId: parentId,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a divider block from a JSON map
  factory DividerBlock.fromJson(Map<String, dynamic> json) {
    return DividerBlock(
      id: json['id'] as String,
      parentId: json['parent_id'] as String?,
    );
  }
}
