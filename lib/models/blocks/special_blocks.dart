import 'package:flutter/material.dart';
import 'base_block.dart';
import 'parent_block.dart';
import 'rich_text_block.dart';
import 'text_span_utils.dart';

/// Link block for internal page links
class LinkBlock extends Block {
  String targetId;
  String title;
  
  LinkBlock({
    String? id,
    required this.targetId,
    required this.title,
    String? parentId,
  }) : super(
    id: id,
    type: 'link',
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return LinkBlock(
      targetId: targetId,
      title: title,
      parentId: parentId,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'target_id': targetId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a link block from a JSON map
  factory LinkBlock.fromJson(Map<String, dynamic> json) {
    // Defensive null safety and fallback values
    final id = (json['id'] ?? '').toString();
    final targetId = (json['target_id'] ?? '').toString();
    final title = (json['title'] ?? '').toString();
    final parentId = (json['parent_id'] ?? '').toString();
    if (id.isEmpty || targetId.isEmpty) {
      debugPrint('LinkBlock.fromJson: Missing required field(s): id=$id, targetId=$targetId');
    }
    return LinkBlock(
      id: id,
      targetId: targetId,
      title: title,
      parentId: parentId,
    );
  }
}

/// Template block for reusable content
class TemplateBlock extends ParentBlock {
  String name;
  
  TemplateBlock({
    String? id,
    required this.name,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
  }) : super(
    id: id,
    type: 'template',
    parentId: parentId,
    children: children,
    childrenOrder: childrenOrder,
  );
  
  @override
  Block copy() {
    return TemplateBlock(
      name: name,
      parentId: parentId,
      children: children.map((key, value) => MapEntry(key, value.copy())),
      childrenOrder: List.from(childrenOrder),
    );
  }
  
  @override
  void addChild(Block block) {
    children[block.id] = block;
    if (!childrenOrder.contains(block.id)) {
      childrenOrder.add(block.id);
    }
  }
  
  @override
  void removeChild(String blockId) {
    children.remove(blockId);
    childrenOrder.remove(blockId);
  }
  
  @override
  void moveChild(String blockId, {required int toIndex}) {
    if (!children.containsKey(blockId) || !childrenOrder.contains(blockId)) {
      return;
    }
    childrenOrder.remove(blockId);
    childrenOrder.insert(toIndex.clamp(0, childrenOrder.length), blockId);
  }
  
  @override
  Map<String, dynamic> toJson() {
    final map = toMap();
    map['name'] = name;
    map['children'] = children.map((key, value) => MapEntry(key, value.toJson()));
    map['children_order'] = childrenOrder;
    return map;
  }
}

/// Callout block for highlighted content
class CalloutBlock extends RichTextBlock {
  Color? backgroundColor;
  IconData? icon;
  
  CalloutBlock({
    String? id,
    required List<TextSpan> richText,
    String? parentId,
    this.backgroundColor,
    this.icon,
  }) : super(
    id: id,
    type: 'callout',
    richText: richText,
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return CalloutBlock(
      richText: richText.map((span) => span.copy()).toList(),
      parentId: parentId,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (backgroundColor != null) {
      json['background_color'] = backgroundColor!.value;
    }
    if (icon != null) {
      json['icon'] = icon!.codePoint;
      json['icon_font_family'] = icon!.fontFamily;
    }
    json['created_at'] = createdAt.toIso8601String();
    json['updated_at'] = updatedAt.toIso8601String();
    return json;
  }
  
  /// Create a callout block from a JSON map
  factory CalloutBlock.fromJson(Map<String, dynamic> json) {
    Color? backgroundColor;
    IconData? icon;
    
    if (json.containsKey('background_color')) {
      backgroundColor = Color(json['background_color'] as int);
    }
    
    if (json.containsKey('icon') && json.containsKey('icon_font_family')) {
      final iconFontFamily = (json['icon_font_family'] ?? '').toString();
      icon = IconData(
        json['icon'] as int,
        fontFamily: iconFontFamily,
      );
      if (iconFontFamily.isEmpty) {
        debugPrint('CalloutBlock.fromJson: icon_font_family is missing or null');
      }
    }
    
    // Defensive null safety and fallback values
    final id = (json['id'] ?? '').toString();
    final parentId = (json['parent_id'] ?? '').toString();
    final richTextList = (json['rich_text'] as List?) ?? [];
    final richText = richTextList
        .map((e) => TextSpanCopy.fromJson((e as Map<String, dynamic>? ?? {})))
        .toList();
    if (id.isEmpty) {
      debugPrint('CalloutBlock.fromJson: Missing required field: id');
    }
    return CalloutBlock(
      id: id,
      richText: richText,
      parentId: parentId,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }
}
