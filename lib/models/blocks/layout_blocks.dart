import 'package:flutter/material.dart';
import 'parent_block.dart';
import 'base_block.dart';

/// Column block for vertical layout
class ColumnBlock extends ParentBlock {
  ColumnBlock({
    String? id,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
  }) : super(
    id: id,
    type: 'column',
    parentId: parentId,
    children: children,
    childrenOrder: childrenOrder,
  );
  
  @override
  Block copy() {
    return ColumnBlock(
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
  
  /// Create a column block from a JSON map
  factory ColumnBlock.fromJson(Map<String, dynamic> json) {
    final block = ColumnBlock(
      id: json['id'] as String?,
      parentId: json['parent_id'] as String?,
      childrenOrder: (json['children_order'] as List?)?.map((e) => e as String).toList(),
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
  Map<String, dynamic> toJson() {
    final map = toMap();
    map['children'] = children.map((key, value) => MapEntry(key, value.toJson()));
    map['children_order'] = childrenOrder;
    return map;
  }
}

/// Row block for horizontal layout
class RowBlock extends ParentBlock {
  RowBlock({
    String? id,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
  }) : super(
    id: id,
    type: 'row',
    parentId: parentId,
    children: children,
    childrenOrder: childrenOrder,
  );
  
  @override
  Block copy() {
    return RowBlock(
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
  
  /// Create a row block from a JSON map
  factory RowBlock.fromJson(Map<String, dynamic> json) {
    final block = RowBlock(
      id: json['id'] as String?,
      parentId: json['parent_id'] as String?,
      childrenOrder: (json['children_order'] as List?)?.map((e) => e as String).toList(),
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
  Map<String, dynamic> toJson() {
    final map = toMap();
    map['children'] = children.map((key, value) => MapEntry(key, value.toJson()));
    map['children_order'] = childrenOrder;
    return map;
  }
}

/// Container block for styling a group of blocks
class ContainerBlock extends ParentBlock {
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  
  ContainerBlock({
    String? id,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  }) : super(
    id: id,
    type: 'container',
    parentId: parentId,
    children: children,
    childrenOrder: childrenOrder,
  );
  
  @override
  Block copy() {
    return ContainerBlock(
      parentId: parentId,
      children: children.map((key, value) => MapEntry(key, value.copy())),
      childrenOrder: List.from(childrenOrder),
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      border: border,
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
    final json = toMap();
    if (backgroundColor != null) {
      json['background_color'] = backgroundColor!.value;
    }
    if (borderRadius != null) {
      json['border_radius'] = {
        'top_left': borderRadius!.topLeft.x,
        'top_right': borderRadius!.topRight.x,
        'bottom_left': borderRadius!.bottomLeft.x,
        'bottom_right': borderRadius!.bottomRight.x,
      };
    }
    if (border != null) {
      json['border'] = true;
    }
    json['children'] = children.map((key, value) => MapEntry(key, value.toJson()));
    json['children_order'] = childrenOrder;
    return json;
  }
  
  /// Create a container block from a JSON map
  factory ContainerBlock.fromJson(Map<String, dynamic> json) {
    Color? backgroundColor;
    BorderRadius? borderRadius;
    Border? border;
    
    if (json.containsKey('background_color')) {
      backgroundColor = Color(json['background_color'] as int);
    }
    
    if (json.containsKey('border_radius')) {
      final radiusJson = json['border_radius'] as Map<String, dynamic>;
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(radiusJson['top_left'] as double),
        topRight: Radius.circular(radiusJson['top_right'] as double),
        bottomLeft: Radius.circular(radiusJson['bottom_left'] as double),
        bottomRight: Radius.circular(radiusJson['bottom_right'] as double),
      );
    }
    
    if (json.containsKey('border') && json['border'] == true) {
      border = Border.all();
    }
    
    final block = ContainerBlock(
      id: json['id'] as String?,
      parentId: json['parent_id'] as String?,
      childrenOrder: (json['children_order'] as List?)?.map((e) => e as String).toList(),
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      border: border,
    );
    
    // Add children
    final childrenJson = json['children'] as Map<String, dynamic>;
    childrenJson.forEach((key, value) {
      // This would need a block factory to properly deserialize
      // For now, we'll leave it empty
    });
    
    return block;
  }
}
