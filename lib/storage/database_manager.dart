import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Database manager for SQLite operations
class DatabaseManager {
  static const String _databaseName = 'neonote.db';
  static const int _databaseVersion = 1;
  
  late Database _database;
  String? _databasePath;
  
  /// Initialize the database manager
  Future<void> initialize(String databasePath) async {
    _databasePath = databasePath;
    _database = await _openDatabase();
  }
  
  /// Open the database
  Future<Database> _openDatabase() async {
    final dbPath = path.join(_databasePath!, _databaseName);
    
    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create workspaces table
    await db.execute('''
      CREATE TABLE workspaces (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');
    
    // Create pages table
    await db.execute('''
      CREATE TABLE pages (
        id TEXT PRIMARY KEY,
        workspace_id TEXT NOT NULL,
        data TEXT NOT NULL,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (workspace_id) REFERENCES workspaces (id) ON DELETE CASCADE
      )
    ''');
    
    // Create search index
    await db.execute('''
      CREATE VIRTUAL TABLE pages_fts USING fts5(
        title,
        content,
        tags,
        content='pages',
        content_rowid='id'
      )
    ''');
    
    // Create triggers for search index
    await db.execute('''
      CREATE TRIGGER pages_ai AFTER INSERT ON pages BEGIN
        INSERT INTO pages_fts(rowid, title, content, tags)
        VALUES (new.rowid, new.title, '', '');
      END
    ''');
    
    await db.execute('''
      CREATE TRIGGER pages_ad AFTER DELETE ON pages BEGIN
        INSERT INTO pages_fts(pages_fts, rowid, title, content, tags)
        VALUES ('delete', old.rowid, old.title, '', '');
      END
    ''');
    
    await db.execute('''
      CREATE TRIGGER pages_au AFTER UPDATE ON pages BEGIN
        INSERT INTO pages_fts(pages_fts, rowid, title, content, tags)
        VALUES ('delete', old.rowid, old.title, '', '');
        INSERT INTO pages_fts(rowid, title, content, tags)
        VALUES (new.rowid, new.title, '', '');
      END
    ''');
  }
  
  /// Upgrade database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Example upgrade to version 2
      // await db.execute('ALTER TABLE pages ADD COLUMN new_column TEXT');
    }
  }
  
  /// Get all workspaces
  Future<List<Map<String, dynamic>>> getWorkspaces() async {
    final results = await _database.query('workspaces');
    return results.map((row) {
      final map = jsonDecode(row['data'] as String? ?? '{}') as Map<String, dynamic>? ?? <String, dynamic>{};
      // Defensive: sanitize all String fields and pageOrder
      map['id'] = map['id'] as String? ?? '';
      map['name'] = map['name'] as String? ?? '';
      map['description'] = map['description'] as String? ?? '';
      map['createdAt'] = map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch;
      map['updatedAt'] = map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch;
      map['settings'] = map['settings'] ?? {};
      if (map.containsKey('pageOrder')) {
        final po = map['pageOrder'];
        if (po is List) {
          map['pageOrder'] = po.where((e) => e != null && e.toString().isNotEmpty && e.toString() != 'null').map((e) => e.toString()).toList();
        } else {
          map['pageOrder'] = <String>[];
        }
      } else {
        map['pageOrder'] = <String>[];
      }
      return map;
    }).toList();
  }
  
  /// Get a workspace by ID
  Future<Map<String, dynamic>?> getWorkspace(String id) async {
    final results = await _database.query(
      'workspaces',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(results.first['data'] as String? ?? '{}');
    if (decoded == null || decoded is! Map<String, dynamic>) {
      debugPrint('getWorkspace: Decoded workspace is null or not a Map, returning empty map');
      return <String, dynamic>{};
    }
    // Defensive: sanitize all String fields and pageOrder
    final map = decoded;
    map['id'] = map['id'] as String? ?? '';
    map['name'] = map['name'] as String? ?? '';
    map['description'] = map['description'] as String? ?? '';
    map['createdAt'] = map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch;
    map['updatedAt'] = map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch;
    map['settings'] = map['settings'] ?? {};
    if (map.containsKey('pageOrder')) {
      final po = map['pageOrder'];
      if (po is List) {
        map['pageOrder'] = po.where((e) => e != null && e.toString().isNotEmpty && e.toString() != 'null').map((e) => e.toString()).toList();
      } else {
        map['pageOrder'] = <String>[];
      }
    } else {
      map['pageOrder'] = <String>[];
    }
    return map;
  }
  
  /// Save a workspace
  Future<void> saveWorkspace(Map<String, dynamic> workspace) async {
    final id = (workspace['id'] is String && workspace['id'] != null) ? workspace['id'] : DateTime.now().millisecondsSinceEpoch.toString();
    final data = jsonEncode(workspace);
    
    await _database.insert(
      'workspaces',
      {'id': id, 'data': data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Delete a workspace
  Future<void> deleteWorkspace(String id) async {
    await _database.delete(
      'workspaces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Get a page by ID
  Future<Map<String, dynamic>?> getPage(String id) async {
    final results = await _database.query(
      'pages',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(results.first['data'] as String);
    if (decoded == null || decoded is! Map<String, dynamic>) {
      debugPrint('getPage: Decoded page is null or not a Map, returning empty map');
      return <String, dynamic>{};
    }
    return decoded;
  }
  
  /// Save a page
  Future<void> savePage(Map<String, dynamic> page) async {
    final id = (page['id'] is String && page['id'] != null) ? page['id'] : DateTime.now().millisecondsSinceEpoch.toString();
    final workspaceId = (page['workspace_id'] is String && page['workspace_id'] != null) ? page['workspace_id'] : '';
    final title = (page['title'] is String && page['title'] != null) ? page['title'] : '';
    final createdAt = (page['created_at'] is String && page['created_at'] != null) ? page['created_at'] : DateTime.now().millisecondsSinceEpoch.toString();
    final updatedAt = (page['updated_at'] is String && page['updated_at'] != null) ? page['updated_at'] : DateTime.now().millisecondsSinceEpoch.toString();
    final data = jsonEncode(page);

    await _database.insert(
      'pages',
      {
        'id': id,
        'workspace_id': workspaceId,
        'title': title,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'data': data,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update search index
    final tags = (page['tags'] is List<dynamic>) ? (page['tags'] as List<dynamic>).join(', ') : '';
    await _database.execute('''
      UPDATE pages_fts
      SET title = ?, tags = ?
      WHERE rowid = ?
    ''', [title, tags, id]);
  }
  
  /// Delete a page
  Future<void> deletePage(String id) async {
    await _database.delete(
      'pages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Search pages by query
  Future<List<Map<String, dynamic>>> searchPages(String query) async {
    final results = await _database.rawQuery('''
      SELECT p.data
      FROM pages p
      JOIN pages_fts fts ON p.rowid = fts.rowid
      WHERE pages_fts MATCH ?
      ORDER BY rank
    ''', [query]);
    
    return results.map((row) {
      final decoded = jsonDecode(row['data'] as String);
      if (decoded == null || decoded is! Map<String, dynamic>) {
        debugPrint('searchPages: Decoded page is null or not a Map, returning empty map');
        return <String, dynamic>{};
      }
      return decoded;
    }).toList();
  }
  
  /// Close the database
  Future<void> close() async {
    await _database.close();
  }
}

// Add this import at the top of the file
