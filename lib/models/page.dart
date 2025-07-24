import 'blocks/base_block.dart';

/// Page model representing a note page
class Page {
  final String id;
  String title;
  String description;
  List<String> tags;
  int createdAt;
  int updatedAt;
  String filePath;
  Map<String, Block> blocks;
  List<String> blockOrder;

  Page({
    required this.id,
    required this.title,
    this.description = '',
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.filePath,
    Map<String, Block>? blocks,
    List<String>? blockOrder,
  })  : blocks = blocks ?? {},
        blockOrder = blockOrder ?? [];

  /// Create a copy with updated properties
  Page copy({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    int? createdAt,
    int? updatedAt,
    String? filePath,
    Map<String, Block>? blocks,
    List<String>? blockOrder,
  }) {
    return Page(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? List.from(this.tags),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      filePath: filePath ?? this.filePath,
      blocks: blocks ?? Map.from(this.blocks),
      blockOrder: blockOrder ?? List.from(this.blockOrder),
    );
  }

  Page copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    int? createdAt,
    int? updatedAt,
    String? filePath,
    Map<String, Block>? blocks,
    List<Block>? blocksList,
    List<String>? blockOrder,
  }) {
    final newBlocks = blocks ?? (blocksList != null
        ? {for (var b in blocksList) b.id: b}
        : Map.from(this.blocks));
    final newBlockOrder = blockOrder ?? (blocksList != null
        ? blocksList.map((b) => b.id).toList()
        : List.from(this.blockOrder));
    return Page(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? List.from(this.tags),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      filePath: filePath ?? this.filePath,
      blocks: newBlocks,
      blockOrder: newBlockOrder,
    );
  }

  void addBlock(Block block, {int? index}) {
    blocks[block.id] = block;
    if (index != null && index >= 0 && index <= blockOrder.length) {
      blockOrder.insert(index, block.id);
    } else {
      blockOrder.add(block.id);
    }
  }

  void removeBlock(String blockId) {
    blocks.remove(blockId);
    blockOrder.remove(blockId);
  }

  void updateBlock(Block block) {
    if (blocks.containsKey(block.id)) {
      blocks[block.id] = block;
    }
  }

  List<Block> getOrderedBlocks() {
    return blockOrder.map((id) => blocks[id]).whereType<Block>().toList();
  }

  List<Block> getBlocksByType(String type) {
    return blocks.values.where((b) => b.type == type).toList();
  }

  List<Block> findBlocksWithText(String text) {
    return blocks.values.where((b) => b.toString().contains(text)).toList();
  }

  void addTag(String tag) {
    if (!tags.contains(tag)) tags.add(tag);
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  bool hasTag(String tag) => tags.contains(tag);

  /// Convert to JSON map for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'filePath': filePath,
      'blocks': blocks.map((k, v) => MapEntry(k, v.toJson())),
      'blockOrder': blockOrder,
    };
  }

  /// Create from JSON map (deserialization)
  static Page fromJson(Map<String, dynamic> json, {Block Function(Map<String, dynamic>)? blockFromJson}) {
    final blockMap = <String, Block>{};
    if (json['blocks'] is Map) {
      (json['blocks'] as Map).forEach((k, v) {
        if (blockFromJson != null) {
          blockMap[k] = blockFromJson(Map<String, dynamic>.from(v));
        }
      });
    }
    // Defensive: ensure all blockOrder entries are non-null, non-empty strings and explicitly convert to String
    List<String> safeBlockOrder = [];
    if (json['blockOrder'] is List) {
      for (var e in json['blockOrder']) {
        if (e == null) {
          print('Page.fromJson: Invalid blockOrder entry: type=null, value=null');
          continue;
        }
        final str = e.toString();
        if (str.isNotEmpty && str != 'null') {
          safeBlockOrder.add(str);
        } else {
          print('Page.fromJson: Invalid blockOrder entry: type=${e.runtimeType}, value=$e');
        }
      }
    }
    safeBlockOrder = safeBlockOrder.where((e) => e.isNotEmpty && e != 'null').map((e) => e.toString()).toList();
    if (safeBlockOrder.any((e) => e.isEmpty || e == 'null')) {
      print('Page.fromJson: ERROR: blockOrder contains invalid entries after sanitization, resetting to empty list');
      safeBlockOrder = <String>[];
    }
    final pageId = (json['id'] != null && json['id'].toString().isNotEmpty && json['id'].toString() != 'null') ? json['id'].toString() : '';
    return Page(
      id: pageId,
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: json['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      filePath: json['filePath'] ?? '',
      blocks: blockMap,
      blockOrder: safeBlockOrder,
    );
  }

  int get updated => updatedAt;

  Map<String, dynamic> toMetadataMap() {
    return {
      'page_id': id,
      'title': title,
      'tags': tags.join(','),
      'created': createdAt,
      'updated': updatedAt,
      'filepath': filePath,
    };
  }

  static Page fromMap(Map<String, dynamic> map) {
    return Page(
      id: map['page_id'] ?? '',
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? '',
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
      createdAt: map['created'] ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: map['updated'] ?? DateTime.now().millisecondsSinceEpoch,
      filePath: map['filepath'] ?? '',
      // blocks and blockOrder are not loaded from metadata
    );
  }
}
