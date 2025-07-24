import 'package:flutter/material.dart';
import 'base_block.dart';

/// Database block for structured data
class DatabaseBlock extends Block {
  String title;
  List<DatabaseColumn> columns;
  List<DatabaseRow> rows;
  DatabaseViewType viewType;
  
  DatabaseBlock({
    String? id,
    required this.title,
    required this.columns,
    required this.rows,
    this.viewType = DatabaseViewType.table,
    String? parentId,
  }) : super(
    id: id,
    type: 'database',
    parentId: parentId,
  );
  
  @override
  Block copy() {
    return DatabaseBlock(
      title: title,
      columns: columns.map((col) => col.copy()).toList(),
      rows: rows.map((row) => row.copy()).toList(),
      viewType: viewType,
      parentId: parentId,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'title': title,
      'columns': columns.map((col) => col.toJson()).toList(),
      'rows': rows.map((row) => row.toJson()).toList(),
      'view_type': viewType.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a database block from a JSON map
  factory DatabaseBlock.fromJson(Map<String, dynamic> json) {
    return DatabaseBlock(
      id: json['id'] as String,
      title: json['title'] as String,
      columns: (json['columns'] as List)
          .map((e) => DatabaseColumn.fromJson(e as Map<String, dynamic>))
          .toList(),
      rows: (json['rows'] as List)
          .map((e) => DatabaseRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      viewType: _parseViewType(json['view_type'] as String),
      parentId: json['parent_id'] as String,
    );
  }
  
  static DatabaseViewType _parseViewType(String value) {
    switch (value) {
      case 'table':
        return DatabaseViewType.table;
      case 'board':
        return DatabaseViewType.board;
      case 'gallery':
        return DatabaseViewType.gallery;
      case 'list':
        return DatabaseViewType.list;
      case 'calendar':
        return DatabaseViewType.calendar;
      default:
        return DatabaseViewType.table;
    }
  }
}

/// Database view types
enum DatabaseViewType {
  table,
  board,
  gallery,
  list,
  calendar,
}

/// Database column types
enum DatabaseColumnType {
  text,
  number,
  select,
  multiSelect,
  date,
  person,
  file,
  checkbox,
  url,
  email,
  phone,
}

/// Database column definition
class DatabaseColumn {
  String id;
  String name;
  DatabaseColumnType type;
  Map<String, dynamic>? options;
  
  DatabaseColumn({
    String? id,
    required this.name,
    required this.type,
    this.options,
  }) : id = id ?? _generateId();
  
  /// Generate a unique ID for the column
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (10000 + (DateTime.now().microsecond % 10000)).toString();
  }
  
  /// Create a copy of the column
  DatabaseColumn copy() {
    return DatabaseColumn(
      id: id,
      name: name,
      type: type,
      options: options != null ? Map<String, dynamic>.from(options!) : null,
    );
  }
  
  /// Convert the column to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      if (options != null) 'options': options,
    };
  }
  
  /// Create a column from a JSON map
  factory DatabaseColumn.fromJson(Map<String, dynamic> json) {
    return DatabaseColumn(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseColumnType(json['type'] as String),
      options: json['options'] as Map<String, dynamic>?,
    );
  }
  
  static DatabaseColumnType _parseColumnType(String value) {
    switch (value) {
      case 'text':
        return DatabaseColumnType.text;
      case 'number':
        return DatabaseColumnType.number;
      case 'select':
        return DatabaseColumnType.select;
      case 'multiSelect':
        return DatabaseColumnType.multiSelect;
      case 'date':
        return DatabaseColumnType.date;
      case 'person':
        return DatabaseColumnType.person;
      case 'file':
        return DatabaseColumnType.file;
      case 'checkbox':
        return DatabaseColumnType.checkbox;
      case 'url':
        return DatabaseColumnType.url;
      case 'email':
        return DatabaseColumnType.email;
      case 'phone':
        return DatabaseColumnType.phone;
      default:
        return DatabaseColumnType.text;
    }
  }
}

/// Database row
class DatabaseRow {
  String id;
  Map<String, dynamic> cells;
  
  DatabaseRow({
    String? id,
    required this.cells,
  }) : id = id ?? _generateId();
  
  /// Generate a unique ID for the row
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (10000 + (DateTime.now().microsecond % 10000)).toString();
  }
  
  /// Create a copy of the row
  DatabaseRow copy() {
    return DatabaseRow(
      id: id,
      cells: Map<String, dynamic>.from(cells),
    );
  }
  
  /// Convert the row to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cells': cells,
    };
  }
  
  /// Create a row from a JSON map
  factory DatabaseRow.fromJson(Map<String, dynamic> json) {
    return DatabaseRow(
      id: json['id'] as String,
      cells: json['cells'] as Map<String, dynamic>,
    );
  }
}
