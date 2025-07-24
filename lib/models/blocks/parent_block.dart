import 'package:flutter/material.dart';
import 'base_block.dart';

/// Abstract class for blocks that can have children (e.g., columns, rows, toggles, templates)
abstract class ParentBlock extends Block {
  Map<String, Block> children;
  List<String> childrenOrder;

  ParentBlock({
    String? id,
    required String type,
    String? parentId,
    Map<String, Block>? children,
    List<String>? childrenOrder,
  }) :
    children = children ?? {},
    childrenOrder = childrenOrder ?? [],
    super(
      id: id,
      type: type,
      parentId: parentId,
    );

  void addChild(Block block);
  void removeChild(String blockId);
  void moveChild(String blockId, {required int toIndex});
  void touch() {}
}
